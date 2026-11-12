##########################################################################################
#
##########################################################################################
#' @title Falls of the price from its all-time high
#' @description Splits a price history into its falls, the drawdown episodes.
#' A fall starts on the last close at an all-time high, the peak, goes down
#' to its lowest close, the trough, and ends on the first close back at or
#' above the peak. The last fall is still going on when the price has not got
#' back to its high. The highs are those of the history given: for a coin
#' whose history starts after its real all-time high, the first fall starts
#' on the first day.
#' @param close Numeric vector of close prices, sorted by date.
#' @param date Dates of the closes.
#' @param min_depth Smallest fall to keep, in percent below the peak: 20
#'   keeps the falls that went at least 20% down. The default, 0, keeps them
#'   all.
#' @return A data frame with a row per fall, the deepest first:
#'   `peak_date` and `peak_price`, `trough_date` and `trough_price`,
#'   `depth_pct` (from -100 to 0), `days_to_trough` (from the peak),
#'   `recovery_date` (`NA` while the fall goes on), `days_to_recover` (from
#'   the trough), `days_total` (from the peak to the recovery, or to the last
#'   date while the fall goes on) and `ongoing`.
#' @export
#' @examples
#' drawdown_episodes(c(100, 120, 90, 130, 65, 70), as.Date("2026-01-01") + 0:5)
#' # only the falls of at least 40%
#' drawdown_episodes(c(100, 120, 90, 130, 65, 70), as.Date("2026-01-01") + 0:5, min_depth = 40)
drawdown_episodes <- function(close, date, min_depth = 0) {
  n <- length(close)
  date <- as.Date(date)
  runs <- rle(close < cummax(close))
  ends <- cumsum(runs$lengths)[runs$values]
  starts <- ends - runs$lengths[runs$values] + 1L
  peak <- starts - 1L
  trough <- peak + vapply(seq_along(starts), function(i) which.min(close[starts[i]:ends[i]]), integer(1))
  ongoing <- ends == n
  recovery <- ifelse(ongoing, NA_integer_, ends + 1L)
  last <- ifelse(ongoing, n, recovery)
  days <- function(from, to) as.numeric(date[to] - date[from])
  episodes <- data.frame(
    peak_date = date[peak],
    peak_price = close[peak],
    trough_date = date[trough],
    trough_price = close[trough],
    depth_pct = (close[trough] / close[peak] - 1) * 100,
    days_to_trough = days(peak, trough),
    recovery_date = date[recovery],
    days_to_recover = days(trough, recovery),
    days_total = days(peak, last),
    ongoing = ongoing
  )
  episodes <- episodes[episodes$depth_pct <= -min_depth, ]
  episodes <- episodes[order(episodes$depth_pct, episodes$peak_date), ]
  rownames(episodes) <- NULL
  episodes
}
##########################################################################################
#
##########################################################################################
#' @title Drawdown analysis of a coin
#' @description How far is the coin below its all-time high, and how does
#' that compare with its earlier falls? See [drawdown_episodes()] for how
#' the falls are found.
#'
#' **Now**: the last close against the all-time high, the lowest close since
#' that high, the rise the price needs to get back to it, and the earlier
#' falls that went at least as deep as the current one has so far: how many
#' days they took to get back to their high.
#'
#' **The history**: the falls of at least `min_depth` percent, the deepest
#' first, the share of days that closed that far below the high, and the
#' days that closed at a new all-time high.
#' @param history Price history of one coin from [get_history()], with all
#'   of it: the highs are those of the history given.
#' @param min_depth Smallest fall of the history to list, in percent below
#'   the high.
#' @return `NULL` when there are fewer than 2 prices, or a list with:
#'   \describe{
#'     \item{coin, first_date, last_date, min_depth}{What was analysed.}
#'     \item{now}{`date` and `close` of the last day, `drawdown_pct`, `high_date`
#'       and `high_price` of the all-time high, `days_since_high`, and
#'       `rise_needed_pct` to get back to it. While the price is below the
#'       high also `low_date` and `low_price`, the lowest close since the
#'       high, `deepest_pct` how far that is below it, `rank` of the current
#'       fall among all the falls of the history by that depth, 1 for the
#'       deepest, and `earlier`, the earlier falls at least as deep, as rows of
#'       [drawdown_episodes()]. At the high, `previous` holds the last fall of
#'       at least `min_depth` percent, or no rows.}
#'     \item{episodes}{The falls of at least `min_depth` percent from
#'       [drawdown_episodes()], with their `rank` in front, 1 for the
#'       deepest.}
#'     \item{series}{A row per day: `date`, `close`, `high` (the all-time
#'       high so far) and `drawdown_pct` (see [drawdown()]).}
#'     \item{share_under}{Percent of the days that closed at least
#'       `min_depth` percent below the high.}
#'     \item{new_highs}{Days that closed at a new all-time high, the first
#'       day of the history left out.}
#'   }
#' @export
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' analysis <- drawdown_analysis(btc)
#' analysis$now$drawdown_pct
#' analysis$episodes
#' drawdown_text(analysis)
drawdown_analysis <- function(history, min_depth = 20) {
  check_one_coin(history)
  history <- history[is.finite(history$close) & history$close > 0, ]
  history <- history[order(history$timestamp), ]
  n <- nrow(history)
  if (n < 2) {
    return(NULL)
  }
  close <- history$close
  date <- as.Date(history$timestamp)
  high <- cummax(close)
  from_high <- drawdown(close)
  all <- drawdown_episodes(close, date)
  at_high <- max(which(close >= high))
  now <- list(
    date = date[n],
    close = close[n],
    drawdown_pct = from_high[n],
    high_date = date[at_high],
    high_price = close[at_high],
    days_since_high = as.numeric(date[n] - date[at_high]),
    rise_needed_pct = (close[at_high] / close[n] - 1) * 100
  )
  episodes <- all[all$depth_pct <= -min_depth, ]
  episodes <- data.frame(rank = seq_len(nrow(episodes)), episodes)
  if (any(all$ongoing)) {
    current <- all[all$ongoing, ]
    past <- all[!all$ongoing, ]
    now$low_date <- current$trough_date
    now$low_price <- current$trough_price
    now$deepest_pct <- current$depth_pct
    now$rank <- sum(past$depth_pct < current$depth_pct) + 1
    now$earlier <- past[past$depth_pct <= current$depth_pct, ]
  } else {
    now$previous <- utils::head(episodes[order(episodes$peak_date, decreasing = TRUE), ], 1)
  }
  list(
    coin = unique(history$name_symbol),
    first_date = date[1],
    last_date = date[n],
    min_depth = min_depth,
    now = now,
    episodes = episodes,
    series = data.frame(date = date, close = close, high = high, drawdown_pct = from_high),
    share_under = mean(from_high <= -min_depth) * 100,
    new_highs = sum(close[-1] > high[-n])
  )
}
##########################################################################################
#
##########################################################################################
#' @title Number and date formats of the drawdown text
#' @noRd
long_date <- function(date) paste(short_date(date), format(date, "%Y"))
#' @noRd
days_text <- function(days) paste(fmt(days, 0), if (length(days) == 1 && days == 1) "day" else "days")
#' @noRd
spread_text <- function(days) {
  if (length(days) == 1) {
    days_text(days)
  } else {
    sprintf("%s to %s days (median %s)", fmt(min(days), 0), fmt(max(days), 0), fmt(stats::median(days), 0))
  }
}
#' @noRd
falls_text <- function(count) if (count == 1) "1 fall" else paste(fmt(count, 0), "falls")
##########################################################################################
#
##########################################################################################
#' @title The drawdown analysis in words
#' @description Sentences built from the numbers of [drawdown_analysis()],
#' for the Drawdowns tab.
#' @param analysis The result of [drawdown_analysis()].
#' @return A list with `now` and `history`, each with a `headline` and
#'   `points`, a character vector of sentences.
#' @export
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' drawdown_text(drawdown_analysis(btc))
drawdown_text <- function(analysis) {
  list(now = drawdown_now_text(analysis), history = drawdown_history_text(analysis))
}
##########################################################################################
#
##########################################################################################
#' @title The current fall in words
#' @param analysis The result of [drawdown_analysis()].
#' @return A list with a `headline` and `points`.
#' @keywords internal
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' golemcrypto:::drawdown_now_text(drawdown_analysis(btc))
drawdown_now_text <- function(analysis) {
  now <- analysis$now
  depth <- analysis$min_depth
  if (now$drawdown_pct == 0) {
    previous <- now$previous
    points <- c(
      sprintf("The last close, %s on %s, is the highest in the coin's history.", price_text(now$close), long_date(now$date)),
      if (nrow(previous) == 0) {
        sprintf("It has had no fall of %d%% or more from a high.", depth)
      } else {
        sprintf(
          "The last fall of %d%% or more went %s%% from the high of %s, down to %s on %s; the price was back at the high on %s, %s after the peak.",
          depth, signed(previous$depth_pct), long_date(previous$peak_date), price_text(previous$trough_price),
          long_date(previous$trough_date), long_date(previous$recovery_date), days_text(previous$days_total)
        )
      }
    )
    return(list(headline = "Now: at an all-time high", points = points))
  }
  earlier <- now$earlier
  rank <- if (now$rank == 1) "its deepest fall ever" else paste("its", ordinal(now$rank), "deepest fall")
  points <- c(
    sprintf(
      "The all-time high: %s on %s, %s ago. The lowest close since: %s on %s, %s%%.",
      price_text(now$high_price), long_date(now$high_date), days_text(now$days_since_high),
      price_text(now$low_price), long_date(now$low_date), signed(now$deepest_pct)
    ),
    sprintf("Back to the high takes a rise of %s%% from the last close of %s.", signed(now$rise_needed_pct), price_text(now$close)),
    if (nrow(earlier) == 0) {
      sprintf("No earlier fall went as deep as %s%%.", signed(now$deepest_pct))
    } else {
      sprintf(
        "Earlier falls as deep as %s%% or deeper: %d. They got back to their high %s after the peak, and %s after the trough. This fall has lasted %s so far.",
        signed(now$deepest_pct), nrow(earlier), spread_text(earlier$days_total), spread_text(earlier$days_to_recover),
        days_text(now$days_since_high)
      )
    }
  )
  list(
    headline = sprintf("Now: %s%% from the all-time high, in %s", signed(now$drawdown_pct), rank),
    points = points
  )
}
##########################################################################################
#
##########################################################################################
#' @title The falls of the history in words
#' @param analysis The result of [drawdown_analysis()].
#' @return A list with a `headline` and `points`.
#' @keywords internal
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' golemcrypto:::drawdown_history_text(drawdown_analysis(btc))
drawdown_history_text <- function(analysis) {
  episodes <- analysis$episodes
  depth <- analysis$min_depth
  since <- long_date(analysis$first_date)
  days <- as.numeric(analysis$last_date - analysis$first_date) + 1
  highs <- sprintf(
    "Of its %s, %s%% closed %d%% or more below the high so far, and %s set a new all-time high.",
    days_text(days), fmt(analysis$share_under, 0), depth, if (analysis$new_highs == 0) "no day" else days_text(analysis$new_highs)
  )
  if (nrow(episodes) == 0) {
    return(list(headline = sprintf("Since %s: no fall of %d%% or more", since, depth), points = highs))
  }
  deepest <- episodes[1, ]
  end <- if (deepest$ongoing) {
    "it has not got back to the high yet"
  } else {
    sprintf("the price was back at the high on %s, %s after the peak", long_date(deepest$recovery_date), days_text(deepest$days_total))
  }
  done <- episodes[!episodes$ongoing, ]
  typical <- if (nrow(episodes) >= 3 && nrow(done) >= 2) {
    sprintf(
      "The median fall: %s%%, with the trough %s after the peak; the falls that ended got back to the high a median of %s after it.",
      signed(stats::median(episodes$depth_pct)), days_text(stats::median(episodes$days_to_trough)), days_text(stats::median(done$days_total))
    )
  }
  list(
    headline = sprintf("Since %s: %s of %d%% or more", since, falls_text(nrow(episodes)), depth),
    points = c(
      sprintf(
        "The deepest: %s%%, from %s on %s to %s on %s; %s.",
        signed(deepest$depth_pct), price_text(deepest$peak_price), long_date(deepest$peak_date),
        price_text(deepest$trough_price), long_date(deepest$trough_date), end
      ),
      typical,
      highs
    )
  )
}
##########################################################################################
#
##########################################################################################
#' @title The falls of a drawdown analysis, as one table
#' @description The table behind the CSV button of the Drawdowns tab.
#' @param analysis The result of [drawdown_analysis()].
#' @return The `episodes` of the analysis, with the depth renamed
#'   `fall_pct`.
#' @keywords internal
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' head(golemcrypto:::drawdown_csv(drawdown_analysis(btc)))
drawdown_csv <- function(analysis) {
  episodes <- analysis$episodes
  names(episodes)[names(episodes) == "depth_pct"] <- "fall_pct"
  episodes
}
