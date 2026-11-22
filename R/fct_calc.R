##########################################################################################
# 
##########################################################################################
#' @title Normalize close prices to 100
#' @description Every coin starts at 100 on the first date on which all of them
#' have data, so their lines can be compared directly: 150 means the price rose
#' by half since that date.
#' @param history Price history from [get_history()], with `name_symbol`,
#'   `timestamp` and `close` columns, sorted by coin and date.
#' @return `history` from the first common date on, with an `index` column.
#' @export
#' @examples
#' history <- data.frame(
#'   name_symbol = rep(c("Alpha (A)", "Beta (B)"), each = 3),
#'   timestamp = rep(as.Date("2024-01-01") + 0:2, 2),
#'   close = c(10, 11, 12, 200, 180, 220)
#' )
#' normalize_prices(history)
normalize_prices <- function(history) {
  first_date <- as.Date(
    max(tapply(as.numeric(history$timestamp), history$name_symbol, min)),
    origin = "1970-01-01"
  )
  prices <- history[history$timestamp >= first_date, ]
  prices$index <- stats::ave(prices$close, prices$name_symbol, FUN = function(x) x / x[1] * 100)
  prices
}
##########################################################################################
#
##########################################################################################
#' @title Normalized prices relative to one of the coins
#' @description The relative strength of each coin against a base coin: the
#' ratio of their normalized prices, so 100 on the first common date, as in
#' [normalize_prices()]. A line that rises did better than the base, one
#' that falls did worse, and 120 means 20% better since the start: Ethereum
#' against Bitcoin is the ETH/BTC ratio, normalized to 100. On a day the base
#' has no close, its last close before stands in.
#' @param prices Prices from [normalize_prices()].
#' @param base The `name_symbol` of the coin to divide by, one of those of
#'   `prices`.
#' @return The rows of `prices` of the other coins, with `index` the ratio to
#'   the base times 100, the base's own `index` in `base_index`, and `base`.
#' @export
#' @examples
#' history <- data.frame(
#'   name_symbol = rep(c("Alpha (A)", "Beta (B)"), each = 3),
#'   timestamp = rep(as.Date("2024-01-01") + 0:2, 2),
#'   close = c(10, 11, 12, 200, 180, 220)
#' )
#' relative_prices(normalize_prices(history), "Beta (B)")
relative_prices <- function(prices, base) {
  if (!base %in% prices$name_symbol) stop("base must be one of the coins of prices", call. = FALSE)
  base_prices <- prices[prices$name_symbol == base, ]
  base_prices <- base_prices[order(base_prices$timestamp), ]
  others <- prices[prices$name_symbol != base, ]
  # the base's last close on or before each day
  at <- findInterval(as.numeric(others$timestamp), as.numeric(base_prices$timestamp))
  others <- others[at > 0, ]
  base_index <- base_prices$index[at[at > 0]]
  others$base_index <- base_index
  others$index <- others$index / base_index * 100
  others$base <- rep(base, nrow(others))
  rownames(others) <- NULL
  others
}
##########################################################################################
# 
##########################################################################################
#' @title Monthly returns of a coin
#' @description Each month's return is its last close relative to the last close
#' of the month before, in percent. The first month, and the months still to
#' come, are `NA`.
#' @param history Price history of one coin from [get_history()], with
#'   `timestamp` and `close` columns, sorted by date.
#' @return A year by month matrix of returns in percent, rounded to 2
#'   decimals, with the years as row names and `month.abb` as column names.
#' @export
#' @examples
#' history <- data.frame(
#'   timestamp = as.Date(c("2024-01-31", "2024-02-29", "2024-03-31")),
#'   close = c(100, 110, 121)
#' )
#' monthly_returns(history)
monthly_returns <- function(history) {
  check_one_coin(history)
  month_close <- tapply(history$close, format(history$timestamp, "%Y-%m"), function(x) x[length(x)])
  month_return <- round((month_close / c(NA, utils::head(month_close, -1)) - 1) * 100, 2)
  months <- names(month_close)
  calendar <- tapply(
    month_return,
    list(substr(months, 1, 4), factor(as.integer(substr(months, 6, 7)), levels = 1:12)),
    sum
  )
  colnames(calendar) <- month.abb
  calendar
}
##########################################################################################
#
##########################################################################################
#' @title Moving average of prices
#' @description The simple moving average: each day's value is the mean of the
#' last `days` closes, that day included, so the first `days - 1` days have
#' none.
#' @param close Numeric vector of close prices, sorted by date.
#' @param days Number of days to average, such as 50 or 200.
#' @return A numeric vector as long as `close`, `NA` for the first
#'   `days - 1` days, and all `NA` when there are fewer than `days` closes,
#'   as for a coin younger than the average.
#' @export
#' @examples
#' moving_average(c(1, 2, 3, 4, 5), days = 3)
moving_average <- function(close, days) {
  if (days > length(close)) {
    return(rep(NA_real_, length(close)))
  }
  as.numeric(stats::filter(close, rep(1 / days, days), sides = 1))
}
##########################################################################################
#
##########################################################################################
#' @title Bollinger bands of prices
#' @description John Bollinger's bands: the moving average of the last `days`
#' closes (see [moving_average()]), and `width` standard deviations of those
#' closes above and below it. The bands widen when the coin swings and
#' narrow when it is calm; a close outside them is far from its recent level.
#' The standard deviation is that of the closes in the window, divided by
#' `days` and not `days - 1`, as Bollinger defined it.
#' @param close Numeric vector of close prices, sorted by date.
#' @param days Number of days of the average, 20 by default.
#' @param width Number of standard deviations from the average to the bands,
#'   2 by default.
#' @return A data frame as long as `close` with `middle`, `upper` and
#'   `lower`, `NA` for the first `days - 1` days.
#' @export
#' @examples
#' bollinger_bands(c(10, 11, 12, 11, 10, 12, 14), days = 3)
bollinger_bands <- function(close, days = 20, width = 2) {
  middle <- moving_average(close, days)
  n <- length(close)
  variance <- rep(NA_real_, n)
  if (n >= days) {
    # the closes of each window, a row per day: the squared distances from the window's own
    # average, which the mean of the squares less the square of the mean would lose in rounding
    windows <- stats::embed(close, days)
    variance[days:n] <- rowMeans((windows - middle[days:n])^2)
  }
  spread <- width * sqrt(variance)
  data.frame(middle = middle, upper = middle + spread, lower = middle - spread)
}
##########################################################################################
#
##########################################################################################
#' @title Relative strength index of prices
#' @description J. Welles Wilder's RSI, from 0 to 100: the share of the
#' average daily rise in the average daily move,
#' `100 - 100 / (1 + average rise / average fall)`. The first averages are
#' the means of the rises and the falls of the first `days` days; after that
#' each day counts for `1 / days` of the average and the day before for the
#' rest, as Wilder smoothed them. Traders read above 70 as overbought, a run
#' up that may pause, and below 30 as oversold.
#' @param close Numeric vector of close prices, sorted by date.
#' @param days Number of days of the averages, 14 by default.
#' @return A numeric vector as long as `close`, `NA` for the first `days`
#'   days, 100 when the coin only rose and 50 when it did not move.
#' @export
#' @examples
#' rsi(c(100, 101, 102, 101, 103, 104, 103, 105), days = 3)
rsi <- function(close, days = 14) {
  n <- length(close)
  out <- rep(NA_real_, n)
  if (n <= days) {
    return(out)
  }
  change <- diff(close)
  rise <- pmax(change, 0)
  fall <- pmax(-change, 0)
  smooth <- function(x) {
    first <- mean(x[seq_len(days)])
    rest <- x[-seq_len(days)]
    if (length(rest) == 0) {
      return(first)
    }
    c(first, as.numeric(stats::filter(rest / days, (days - 1) / days, method = "recursive", init = first)))
  }
  up <- smooth(rise)
  down <- smooth(fall)
  value <- ifelse(down == 0, ifelse(up == 0, 50, 100), 100 - 100 / (1 + up / down))
  out[(days + 1):n] <- value
  out
}
##########################################################################################
#
##########################################################################################
#' @title Drawdown of prices
#' @description How far each close is below the highest close up to that day,
#' the all-time high so far, in percent: 0 on a new high and -50 at half of it.
#' @param close Numeric vector of close prices, sorted by date.
#' @return A numeric vector as long as `close`, from -100 to 0.
#' @export
#' @examples
#' drawdown(c(100, 120, 90, 130, 65))
drawdown <- function(close) {
  (close / cummax(close) - 1) * 100
}
