##########################################################################################
#
##########################################################################################
#' @title Days in a year of crypto trading
#' @description Crypto trades every day, so a year is 365 days, not the about
#' 252 trading days of shares.
#' @noRd
year_days <- 365
##########################################################################################
#
##########################################################################################
#' @title Rolling sum and standard deviation
#' @description Right-aligned windows: the value of day t covers days
#' t - width + 1 to t, and the first `width - 1` days are `NA`. Computed from
#' cumulative sums, so a long history takes no time.
#' @param x Numeric vector without `NA`.
#' @param width Number of days in each window.
#' @return A numeric vector as long as `x`.
#' @keywords internal
#' @examples
#' golemcrypto:::rolling_sum(1:5, 2)
#' golemcrypto:::rolling_sd(c(1, 3, 2, 5, 4), 3)
rolling_sum <- function(x, width) {
  if (width > length(x)) {
    return(rep(NA_real_, length(x)))
  }
  total <- cumsum(c(0, x))
  c(rep(NA_real_, width - 1), total[-(1:width)] - utils::head(total, -width))
}
#' @rdname rolling_sum
#' @keywords internal
rolling_sd <- function(x, width) {
  # centred first, so the sums of squares stay small and exact enough
  x <- x - mean(x)
  mean_x <- rolling_sum(x, width) / width
  variance <- (rolling_sum(x^2, width) - width * mean_x^2) / (width - 1)
  sqrt(pmax(variance, 0))
}
##########################################################################################
#
##########################################################################################
#' @title Shift a vector later by some days
#' @param x A vector.
#' @param days Number of days.
#' @return `x` without its last `days` values, after `days` `NA`s, so that
#'   day t holds the value of day t - days.
#' @keywords internal
#' @examples
#' golemcrypto:::shift(1:5, 2)
shift <- function(x, days) {
  c(rep(NA, days), utils::head(x, -days))
}
##########################################################################################
#
##########################################################################################
#' @title Conditional variance of a GARCH(1,1) model
#' @description `variance(t) = omega + alpha * e(t-1)^2 + beta * variance(t-1)`,
#' started at `start`. Each day's variance depends only on the days before it,
#' so it is the variance the model expects for that day.
#' @param e Numeric vector of the returns minus their mean.
#' @param omega,alpha,beta The parameters of the model.
#' @param start The variance of the first day.
#' @return A numeric vector of variances, as long as `e`.
#' @keywords internal
#' @examples
#' golemcrypto:::garch_variance(c(1, -2, 0.5, 3), omega = 0.1, alpha = 0.1, beta = 0.8, start = 2)
garch_variance <- function(e, omega, alpha, beta, start) {
  if (length(e) == 1) {
    return(start)
  }
  later <- stats::filter(omega + alpha * utils::head(e, -1)^2, beta, method = "recursive", init = start)
  c(start, as.numeric(later))
}
##########################################################################################
#
##########################################################################################
#' @title Probability of a Student-t move at least this far from 0
#' @description For the Student-t distribution scaled to a variance of 1, as
#' in [garch_fit()]: the probability of a value as low as `z` when `z` is
#' negative, or as high as `z` when it is positive.
#' @param z Numeric vector of moves in standard deviations.
#' @param nu Degrees of freedom, above 2.
#' @return A numeric vector of probabilities.
#' @keywords internal
#' @examples
#' golemcrypto:::tail_probability(c(-4, 2), nu = 4)
tail_probability <- function(z, nu) {
  stats::pt(-abs(z) * sqrt(nu / (nu - 2)), nu)
}
##########################################################################################
#
##########################################################################################
#' @title Fit a GARCH(1,1) model with Student-t errors
#' @description The model of daily volatility most used in finance: a day's
#' return is `mu + sigma(t) * z(t)`, where `z` follows a Student-t distribution
#' scaled to a variance of 1 and `sigma(t)^2` follows [garch_variance()]. The
#' parameters are fitted by maximum likelihood with [stats::optim()], in a
#' form that keeps `omega` positive, `alpha` and `beta` positive with
#' `alpha + beta` below 1, and `nu` above 2.
#' @param r Numeric vector of daily returns, in percent.
#' @return A list with `mu`, `omega`, `alpha`, `beta`, `nu` and `start`, the
#'   variance of the first day, or `NULL` when the fit fails.
#' @keywords internal
#' @examples
#' set.seed(1)
#' golemcrypto:::garch_fit(rnorm(1000, sd = 3))[c("alpha", "beta", "nu")]
garch_fit <- function(r) {
  start <- stats::var(r)
  unpack <- function(p) {
    persistence <- 0.999 * stats::plogis(p[3])
    share <- stats::plogis(p[4])
    list(mu = p[1], omega = exp(p[2]), alpha = persistence * share, beta = persistence * (1 - share), nu = 2.05 + exp(p[5]))
  }
  minus_log_likelihood <- function(p) {
    m <- unpack(p)
    variance <- garch_variance(r - m$mu, m$omega, m$alpha, m$beta, start)
    nu <- m$nu
    value <- -sum(
      lgamma((nu + 1) / 2) - lgamma(nu / 2) - 0.5 * log(pi * (nu - 2)) - 0.5 * log(variance) -
        (nu + 1) / 2 * log1p((r - m$mu)^2 / (variance * (nu - 2)))
    )
    if (is.finite(value)) value else 1e10
  }
  # from a typical fit: persistence 0.95, of which a tenth from the last day's move, nu = 5
  first <- c(mean(r), log(start * 0.05), stats::qlogis(0.95 / 0.999), stats::qlogis(0.1), log(5 - 2.05))
  fit <- tryCatch(stats::optim(first, minus_log_likelihood, method = "BFGS", control = list(maxit = 500)), error = function(e) NULL)
  if (is.null(fit) || fit$convergence != 0) {
    return(NULL)
  }
  c(lapply(unpack(fit$par), unname), list(start = start))
}
##########################################################################################
#
##########################################################################################
#' @title How rare a move is, in words
#' @description The thresholds are in days, as crypto trades every day: a move
#' seen about every month or more often is normal, less often than monthly but
#' more than once a year unusual, once in 1 to 10 years rare, and rarer than
#' that very rare.
#' @param one_in_days A move this large happens about once in so many days.
#' @param up `TRUE` for a rise, `FALSE` for a fall.
#' @return A character string such as "rare fall", or `NA`.
#' @keywords internal
#' @examples
#' golemcrypto:::move_verdict(c(12, 400, 5000), up = c(TRUE, FALSE, FALSE))
move_verdict <- function(one_in_days, up) {
  word <- cut(one_in_days, c(-Inf, 30, year_days, 10 * year_days, Inf), c("normal", "unusual", "rare", "very rare"), right = FALSE)
  ifelse(is.na(one_in_days), NA_character_, paste(word, ifelse(up, "rise", "fall")))
}
##########################################################################################
#
##########################################################################################
#' @title Volatility level from its percentile
#' @param percentile Where the volatility falls among all the coin's past
#'   periods of the same length, from 0 to 100.
#' @return "normal" below the 60th percentile, "elevated" to the 85th, "high"
#'   to the 95th and "extreme" above it.
#' @keywords internal
#' @examples
#' golemcrypto:::volatility_level(c(40, 70, 90, 99))
volatility_level <- function(percentile) {
  as.character(cut(percentile, c(-Inf, 60, 85, 95, Inf), c("normal", "elevated", "high", "extreme")))
}
##########################################################################################
#
##########################################################################################
#' @title Quantile of the Student-t distribution scaled to a variance of 1
#' @param p Numeric vector of probabilities.
#' @param nu Degrees of freedom, above 2.
#' @return The quantiles, in standard deviations.
#' @keywords internal
#' @examples
#' golemcrypto:::t_quantile(c(0.025, 0.975), nu = 4)
t_quantile <- function(p, nu) {
  stats::qt(p, nu) * sqrt((nu - 2) / nu)
}
##########################################################################################
#
##########################################################################################
#' @title Run code with a fixed random seed
#' @description The random numbers repeat from one run to the next, and the
#' random state of the R session is put back afterwards, so the code does not
#' change the random numbers of the user.
#' @param seed An integer for [set.seed()].
#' @param code The code to run.
#' @return The value of `code`.
#' @keywords internal
#' @examples
#' golemcrypto:::with_seed(1, runif(2))
with_seed <- function(seed, code) {
  had_seed <- exists(".Random.seed", envir = globalenv(), inherits = FALSE)
  if (had_seed) {
    old <- get(".Random.seed", envir = globalenv(), inherits = FALSE)
  }
  on.exit(if (had_seed) assign(".Random.seed", old, envir = globalenv()) else rm(".Random.seed", envir = globalenv()))
  set.seed(seed)
  code
}
##########################################################################################
#
##########################################################################################
#' @title Forecast of a GARCH model for the next days
#' @description The variance the model expects for each of the next days,
#' and the range of the return from the last close to the end of each day.
#' The variance of the next day is known from the last day,
#' `omega + alpha * e^2 + beta * variance`, and later days fall back to the
#' long-run variance `omega / (1 - alpha - beta)` at the rate
#' `alpha + beta` a day. The range of the next day is exact, from the
#' Student-t distribution of the model; the ranges of the later days come from
#' `paths` simulated paths of the model, with a fixed seed so that they do
#' not change from one run to the next.
#' @param garch A model from [garch_fit()].
#' @param e_last The last day's return minus `mu`, in percent.
#' @param variance_last The variance the model expected for the last day.
#' @param days Number of days to forecast.
#' @param level Probability of the range, such as 0.95.
#' @param paths Number of simulated paths.
#' @return A data frame with a row per day and the columns `day`, `sigma`
#'   (the daily standard deviation the model expects, in percent) and the
#'   quantiles of the log return from the last close, in percent: `low` and
#'   `high` for the range of probability `level`, `low_50` and `high_50` for
#'   the middle half, and `median`.
#' @keywords internal
#' @examples
#' garch <- list(mu = 0.05, omega = 0.4, alpha = 0.1, beta = 0.85, nu = 4)
#' golemcrypto:::garch_forecast(garch, e_last = -5, variance_last = 6, days = 7, level = 0.95)
garch_forecast <- function(garch, e_last, variance_last, days, level, paths = 50000) {
  outer <- (1 - level) / 2
  probs <- c(outer, 0.25, 0.5, 0.75, 1 - outer)
  scale <- sqrt((garch$nu - 2) / garch$nu)
  variance <- garch$omega + garch$alpha * e_last^2 + garch$beta * variance_last
  total <- with_seed(1, {
    s2 <- rep(variance, paths)
    cumulative <- 0
    total <- matrix(0, paths, days)
    for (h in seq_len(days)) {
      e <- sqrt(s2) * stats::rt(paths, garch$nu) * scale
      cumulative <- cumulative + garch$mu + e
      total[, h] <- cumulative
      s2 <- garch$omega + garch$alpha * e^2 + garch$beta * s2
    }
    total
  })
  q <- matrix(apply(total, 2, stats::quantile, probs = probs, names = FALSE), nrow = days, byrow = TRUE)
  # the first day needs no simulation: its return is mu + sigma * z
  q[1, ] <- garch$mu + sqrt(variance) * t_quantile(probs, garch$nu)
  colnames(q) <- c("low", "low_50", "median", "high_50", "high")
  long_run <- garch$omega / (1 - garch$alpha - garch$beta)
  expected <- long_run + (garch$alpha + garch$beta)^(seq_len(days) - 1) * (variance - long_run)
  data.frame(day = seq_len(days), sigma = sqrt(expected), q)
}
##########################################################################################
#
##########################################################################################
#' @title Value at risk and expected shortfall of a day
#' @description For a day whose log return, in percent, is `mu + sigma * z`
#' with `z` from the Student-t distribution scaled to a variance of 1: the
#' value at risk is the loss exceeded with probability `1 - level`, and the
#' expected shortfall the average loss beyond it. Both are price falls in
#' percent, `100 * (1 - exp(r / 100))`, so they cannot exceed 100.
#' @param mu,sigma Mean and standard deviation of the log return, in percent.
#' @param nu Degrees of freedom, above 2.
#' @param level Probability, such as 0.95 for the worst 5% of days.
#' @return A list with `var` and `es`, in percent.
#' @keywords internal
#' @examples
#' golemcrypto:::garch_risk(mu = 0, sigma = 2.5, nu = 4, level = 0.95)
garch_risk <- function(mu, sigma, nu, level) {
  tail <- 1 - level
  scale <- sqrt((nu - 2) / nu)
  q <- t_quantile(tail, nu)
  loss <- function(z) 100 * (1 - exp((mu + sigma * z) / 100))
  density <- function(z) stats::dt(z / scale, nu) / scale
  es <- stats::integrate(function(z) loss(z) * density(z), -Inf, q)$value / tail
  list(var = loss(q), es = es)
}
##########################################################################################
#
##########################################################################################
#' @title Kupiec test of a value at risk
#' @description Is the value at risk exceeded as often as it should be? The
#' likelihood ratio test of Kupiec (1995) compares the share of days with a
#' loss beyond it with the share it promises, such as 5%.
#' @param exceedances Number of days with a loss beyond the value at risk.
#' @param days Number of days tested.
#' @param p The share of days it should be exceeded on, such as 0.05.
#' @return The p-value of the test.
#' @keywords internal
#' @examples
#' golemcrypto:::kupiec_test(c(18, 40), days = 365, p = 0.05)
kupiec_test <- function(exceedances, days, p) {
  vapply(exceedances, function(x) {
    rate <- x / days
    log_lik <- function(q) (if (x < days) (days - x) * log(1 - q) else 0) + (if (x > 0) x * log(q) else 0)
    stats::pchisq(2 * (log_lik(rate) - log_lik(p)), df = 1, lower.tail = FALSE)
  }, numeric(1))
}
##########################################################################################
#
##########################################################################################
#' @title Volume of each day against the days before it
#' @description Each day's volume divided by the median volume of the `days`
#' days before it: 2 is twice the usual volume of the time, 0.5 half of it.
#' The median keeps a single busy day from raising the bar, and the ratio
#' follows the coin's volume as it grows over the years. Days without volume
#' (0 or missing, as 'CoinMarketCap' has for the earliest days of some coins)
#' are left out, and a day needs volume on two thirds of the days before it.
#' @param volume Numeric vector of daily volumes, sorted by date.
#' @param days Number of days before each day to compare with.
#' @return A numeric vector as long as `volume`, `NA` where there is no
#'   ratio.
#' @keywords internal
#' @examples
#' golemcrypto:::volume_ratio(c(rep(100, 30), 300, 50), days = 30)
volume_ratio <- function(volume, days = 30) {
  volume[!is.finite(volume) | volume <= 0] <- NA
  n <- length(volume)
  if (n <= days) {
    return(rep(NA_real_, n))
  }
  # a row per day from day days + 1: the day, then the days before it, latest first
  window <- stats::embed(volume, days + 1)
  usual <- apply(window[, -1, drop = FALSE], 1, function(x) {
    if (sum(!is.na(x)) >= 2 / 3 * days) stats::median(x, na.rm = TRUE) else NA_real_
  })
  c(rep(NA_real_, days), window[, 1] / usual)
}
##########################################################################################
#
##########################################################################################
#' @title How rare a volume is, in words
#' @param one_in_days A volume this far from usual comes about once in so many
#'   days.
#' @return "normal", "unusual", "rare" or "very rare", with the thresholds of
#'   [move_verdict()], or `NA`.
#' @keywords internal
#' @examples
#' golemcrypto:::volume_verdict(c(10, 100, 1000, 5000))
volume_verdict <- function(one_in_days) {
  as.character(cut(one_in_days, c(-Inf, 30, year_days, 10 * year_days, Inf), c("normal", "unusual", "rare", "very rare"), right = FALSE))
}
##########################################################################################
#
##########################################################################################
#' @title Volatility analysis of a coin
#' @description Is the coin's recent volatility normal? The analysis looks at
#' the daily log returns, `log(close(t) / close(t-1))`, in two ways.
#'
#' **The last month** (`month_days` days): its volatility, the standard
#' deviation of the daily returns times `sqrt(365)`, against the year before
#' it and against every past period of the same length; an F test and the
#' Fligner-Killeen test, which is robust to a few extreme days, of whether
#' its variance is larger than the year before; its largest daily move, in
#' standard deviations of the year before; and its return against every past
#' period of the same length.
#'
#' **The last days** (`recent_days` days): their return against every past
#' period of as many days; the same, in standard deviations of the year
#' before; a GARCH(1,1) model with Student-t errors (see [garch_fit()]),
#' fitted to the `garch_years` years before them, which judges each day
#' against the volatility the model expected for it given the days before;
#' and each day's volume against the `month_days` days before it (see
#' [volume_ratio()]), judged by how often the coin's volume was as far from
#' usual.
#'
#' **The next days** (`forecast_days` days): the same model, with its
#' variance brought up to the last day, forecasts the volatility and the range
#' of the price (see [garch_forecast()]), and gives the value at risk and the
#' expected shortfall of the next day (see [garch_risk()]). A Kupiec test (see
#' [kupiec_test()]) checks how often the model's value at risk was exceeded
#' over the last year. The value at risk and expected shortfall of the last
#' year's daily returns are given without the model too.
#' @param history Price history of one coin from [get_history()], sorted by
#'   date. The comparisons use the whole history, so pass all of it.
#' @param month_days Days in the month.
#' @param recent_days Days in the recent move.
#' @param garch_years Years of history to fit the GARCH model to.
#' @param forecast_days Days to forecast.
#' @param level Probability of the forecast ranges, and of the value at risk:
#'   0.95 is the 95% range and the worst 5% of days.
#' @return `NULL` when the history is shorter than a year and a month, or
#'   the price did not move at all in the year before the month or the last
#'   days, otherwise a list with
#'   * `coin`, `first_date` and `last_date`;
#'   * `month`: a list of the month's measures, see the code;
#'   * `recent`: a list of the measures of the last days, with a `days` data
#'     frame of each day's return, GARCH measures, `volume`, `volume_ratio`
#'     and `volume_one_in_days` (`NA` without volume);
#'   * `garch`: the fitted model, or `NULL` when it could not be fitted or
#'     there are fewer than 500 days before the last days;
#'   * `forecast`: `NULL` without a model, otherwise a list with `days`, a
#'     data frame with a row per day ahead: its `date`, `sigma` (the daily
#'     standard deviation the model expects, in percent) and the closes
#'     `low`, `low_50`, `median`, `high_50` and `high` of the ranges (see
#'     [garch_forecast()]); `sigma` and `sigma_long_run`, the daily standard
#'     deviation expected for the next day and in the long run; `half_life`,
#'     the days for the volatility to get half-way back to the long run;
#'     `var` and `es`, the value at risk and expected shortfall of the next
#'     day; and `backtest`, the `days`, `exceedances` and `p_value` of the
#'     Kupiec test;
#'   * `history_risk`: `var` and `es` of the daily returns of the last
#'     `days` (365) days, in percent;
#'   * `series`: a data frame with a row per day and the columns `date`,
#'     `close`, `volume`, `return_pct`, `volume_ratio` (see
#'     [volume_ratio()]), `volatility_month` (annualized, in percent),
#'     `garch_sigma` (the daily standard deviation the model expected, in
#'     percent), `garch_z` (the day's move in those standard deviations) and
#'     `garch_var` (the model's value at risk for the day, in percent);
#'   * `settings`: `month_days`, `recent_days`, `garch_years`,
#'     `forecast_days` and `level`.
#' @export
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' analysis <- volatility_analysis(btc)
#' analysis$month$level
#' analysis$recent$days
#' analysis$forecast$days
#' volatility_text(analysis)
volatility_analysis <- function(history, month_days = 30, recent_days = 2, garch_years = 4,
                                forecast_days = 7, level = 0.95) {
  check_one_coin(history)
  history <- history[is.finite(history$close) & history$close > 0, ]
  r <- diff(log(history$close))
  dates <- history$timestamp[-1]
  n <- length(r)
  if (n < year_days + max(month_days, recent_days) + 1) {
    return(NULL)
  }
  # a price that did not move in the year before has no standard deviation to compare with
  if (stats::sd(r[(n - month_days - year_days + 1):(n - month_days)]) == 0 ||
    stats::sd(r[(n - recent_days - year_days + 1):(n - recent_days)]) == 0) {
    return(NULL)
  }
  pct <- function(x) 100 * (exp(x) - 1)
  # the standard deviation of the year that ends the day before each day
  year_sd <- shift(rolling_sd(r, year_days), 1)

  # ---- the last month --------------------------------------------------------------
  m <- month_days
  last_month <- utils::tail(r, m)
  year_before <- r[(n - m - year_days + 1):(n - m)]
  volatility_month <- rolling_sd(r, m) * sqrt(year_days)
  volatility_now <- stats::sd(last_month) * sqrt(year_days)
  month_return <- rolling_sum(r, m)
  biggest <- which.max(abs(last_month))
  biggest_sigma <- abs(last_month[biggest]) / stats::sd(year_before)
  p_value <- function(test) tryCatch(test()$p.value, error = function(e) NA_real_)
  volatility_percentile <- 100 * mean(volatility_month <= volatility_now, na.rm = TRUE)
  month <- list(
    from = dates[n - m + 1],
    return_pct = pct(sum(last_month)),
    return_percentile = 100 * mean(month_return <= sum(last_month), na.rm = TRUE),
    volatility = 100 * volatility_now,
    volatility_year_before = 100 * stats::sd(year_before) * sqrt(year_days),
    volatility_median = 100 * stats::median(volatility_month, na.rm = TRUE),
    volatility_percentile = volatility_percentile,
    level = volatility_level(volatility_percentile),
    variance_ratio = stats::var(last_month) / stats::var(year_before),
    p_f = p_value(function() stats::var.test(last_month, year_before, alternative = "greater")),
    p_fligner = p_value(function() stats::fligner.test(list(year_before, last_month))),
    biggest_date = dates[n - m + biggest],
    biggest_pct = pct(last_month[biggest]),
    biggest_sigma = biggest_sigma,
    # how many days a year moved at least as many standard deviations of their year before
    biggest_per_year = year_days * mean(abs(r) / year_sd >= biggest_sigma, na.rm = TRUE)
  )

  # ---- the last days ---------------------------------------------------------------
  k <- recent_days
  last_days <- utils::tail(r, k)
  move <- sum(last_days)
  moves <- rolling_sum(r, k)
  as_extreme <- function(x, value) if (value < 0) x <= value else x >= value
  z_move <- move / (stats::sd(r[(n - k - year_days + 1):(n - k)]) * sqrt(k))
  z_moves <- moves / (shift(rolling_sd(r, year_days), k) * sqrt(k))
  recent <- list(
    from = dates[n - k + 1],
    return_pct = pct(move),
    percentile = 100 * mean(moves <= move, na.rm = TRUE),
    per_year = year_days * mean(as_extreme(moves, move), na.rm = TRUE),
    z = z_move,
    z_per_year = year_days * mean(as_extreme(z_moves, z_move), na.rm = TRUE),
    days = data.frame(
      date = utils::tail(dates, k), return_pct = pct(last_days), garch_z = NA_real_, one_in_days = NA_real_,
      volume = NA_real_, volume_ratio = NA_real_, volume_one_in_days = NA_real_
    ),
    garch_z = NA_real_,
    one_in_days = NA_real_
  )

  # ---- GARCH, fitted to the years before the last days ------------------------------
  window <- max(1, n - k - garch_years * year_days + 1):n
  train <- 100 * r[utils::head(window, -k)]
  garch <- if (length(train) >= 500) garch_fit(train)
  series <- data.frame(
    date = history$timestamp,
    close = history$close,
    volume = if (is.null(history$volume)) NA_real_ else history$volume,
    return_pct = c(NA, pct(r)),
    volume_ratio = if (is.null(history$volume)) NA_real_ else volume_ratio(history$volume, month_days),
    volatility_month = c(NA, 100 * volatility_month),
    garch_sigma = NA_real_,
    garch_z = NA_real_,
    garch_var = NA_real_
  )
  # ---- volume of the last days, against how often the coin's volume was as far from usual
  ratios <- series$volume_ratio[is.finite(series$volume_ratio)]
  last_ratio <- utils::tail(series$volume_ratio, k)
  if (length(ratios) > 0 && all(is.finite(last_ratio))) {
    recent$days$volume <- utils::tail(series$volume, k)
    recent$days$volume_ratio <- last_ratio
    recent$days$volume_one_in_days <- 1 / vapply(last_ratio, function(x) mean(if (x >= 1) ratios >= x else ratios <= x), numeric(1))
  }

  # ---- value at risk of the last year, without a model --------------------------------
  last_year <- pct(utils::tail(r, year_days))
  cutoff <- stats::quantile(last_year, 1 - level, names = FALSE)
  history_risk <- list(var = -cutoff, es = -mean(last_year[last_year <= cutoff]), days = year_days)

  forecast <- NULL
  if (!is.null(garch)) {
    e <- 100 * r[window] - garch$mu
    sigma <- sqrt(garch_variance(e, garch$omega, garch$alpha, garch$beta, garch$start))
    series$garch_sigma[window + 1] <- sigma
    series$garch_z[window + 1] <- e / sigma
    z <- utils::tail(e / sigma, k)
    recent$days$garch_z <- z
    recent$days$one_in_days <- 1 / tail_probability(z, garch$nu)
    recent$garch_z <- sum(utils::tail(e, k)) / sqrt(sum(utils::tail(sigma, k)^2))
    recent$one_in_days <- 1 / tail_probability(recent$garch_z, garch$nu)

    # ---- the next days, from the same model brought up to the last day -----------------
    q <- t_quantile(1 - level, garch$nu)
    series$garch_var[window + 1] <- 100 * (1 - exp((garch$mu + sigma * q) / 100))
    ahead <- garch_forecast(garch, utils::tail(e, 1), utils::tail(sigma, 1)^2, forecast_days, level)
    last_close <- utils::tail(history$close, 1)
    prices <- c("low", "low_50", "median", "high_50", "high")
    ahead[prices] <- last_close * exp(ahead[prices] / 100)
    ahead <- data.frame(date = utils::tail(history$timestamp, 1) + ahead$day, ahead[c("sigma", prices)])
    risk <- garch_risk(garch$mu, ahead$sigma[1], garch$nu, level)
    # the model's value at risk against the last year's days, the last ones included
    tested <- utils::tail(e / sigma, min(year_days, length(sigma)))
    exceedances <- sum(tested < q)
    persistence <- garch$alpha + garch$beta
    forecast <- list(
      days = ahead,
      sigma = ahead$sigma[1],
      sigma_long_run = sqrt(garch$omega / (1 - persistence)),
      half_life = log(0.5) / log(persistence),
      var = risk$var,
      es = risk$es,
      backtest = list(days = length(tested), exceedances = exceedances, p_value = kupiec_test(exceedances, length(tested), 1 - level))
    )
  }

  list(
    coin = unique(history$name_symbol),
    first_date = history$timestamp[1],
    last_date = utils::tail(history$timestamp, 1),
    month = month,
    recent = recent,
    garch = garch,
    forecast = forecast,
    history_risk = history_risk,
    series = series,
    settings = list(
      month_days = month_days, recent_days = recent_days, garch_years = garch_years,
      forecast_days = forecast_days, level = level
    )
  )
}
##########################################################################################
#
##########################################################################################
#' @title The daily data of a volatility analysis, as one table
#' @description The `series` of [volatility_analysis()], followed by the days
#' of its forecast, for the CSV button of the Volatility tab.
#' @param analysis The result of [volatility_analysis()].
#' @return A data frame with a row per day, sorted by date: the columns of
#'   `series`, and the forecast columns `forecast_sigma`, `forecast_low`,
#'   `forecast_low_50`, `forecast_median`, `forecast_high_50` and
#'   `forecast_high`, which are filled on the days ahead only. Without a
#'   forecast, `series` alone.
#' @keywords internal
#' @examples
#' \dontrun{
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' utils::tail(golemcrypto:::volatility_csv(volatility_analysis(btc)), 10)
#' }
volatility_csv <- function(analysis) {
  if (is.null(analysis$forecast)) {
    return(analysis$series)
  }
  ahead <- analysis$forecast$days
  names(ahead)[-1] <- paste0("forecast_", names(ahead)[-1])
  merge(analysis$series, ahead, by = "date", all = TRUE)
}
##########################################################################################
#
##########################################################################################
#' @title Number formats of the volatility text
#' @noRd
fmt <- function(x, digits = 1) formatC(x, format = "f", digits = digits, big.mark = ",")
#' @noRd
signed <- function(x, digits = 1) {
  x <- round(x, digits)
  paste0(ifelse(x > 0, "+", ifelse(x < 0, "\u2212", "")), fmt(abs(x), digits))
}
#' @noRd
ordinal <- function(x) {
  x <- round(x)
  suffix <- ifelse(x %% 100 %in% 11:13, "th", c("th", "st", "nd", "rd", rep("th", 6))[x %% 10 + 1])
  paste0(x, suffix)
}
#' @noRd
with_article <- function(x) paste(ifelse(grepl("^[aeiou]", x), "an", "a"), x)
#' @noRd
short_date <- function(date) paste(as.integer(format(date, "%d")), month.abb[as.integer(format(date, "%m"))])
#' @noRd
money_text <- function(x) {
  units <- c(tn = 1e12, bn = 1e9, m = 1e6, k = 1e3)
  i <- which(x >= units)[1]
  if (is.na(i)) paste0("$", fmt(x, 0)) else paste0("$", fmt(x / units[i]), names(units)[i])
}
#' @noRd
price_text <- function(x) {
  if (x >= 1000) {
    paste0("$", fmt(x, 0))
  } else if (x >= 1) {
    paste0("$", fmt(x, 2))
  } else {
    paste0("$", format(signif(x, 4), scientific = FALSE))
  }
}
##########################################################################################
#
##########################################################################################
#' @title How often something happens, in words
#' @param per_year Times a year.
#' @return A character string such as "about 3 times a year" or "about once
#'   every 4 years".
#' @keywords internal
#' @examples
#' golemcrypto:::how_often(c(0, 0.25, 3))
how_often <- function(per_year) {
  vapply(per_year, function(f) {
    if (is.na(f)) {
      NA_character_
    } else if (f <= 0) {
      "never before in its history"
    } else if (f >= 1.05) {
      paste("about", fmt(f, if (f >= 10) 0 else 1), "times a year")
    } else if (f >= 0.95) {
      "about once a year"
    } else {
      paste("about once every", fmt(1 / f), "years")
    }
  }, character(1))
}
##########################################################################################
#
##########################################################################################
#' @title The volatility analysis in words
#' @description Sentences built from the numbers of [volatility_analysis()],
#' for the Volatility tab.
#' @param analysis The result of [volatility_analysis()].
#' @return A list with `month`, `recent` and `forecast`, each with a `headline` and
#'   `points`, a character vector of sentences.
#' @export
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' volatility_text(volatility_analysis(btc))
volatility_text <- function(analysis) {
  m <- analysis$month
  since <- format(analysis$first_date, "%Y")
  days <- analysis$settings$month_days
  significant <- function(p) isTRUE(p < 0.05)
  p_text <- function(p) if (is.na(p)) "n/a" else format(signif(p, 2), scientific = FALSE)
  comparison <- if (significant(m$p_f) && significant(m$p_fligner)) {
    sprintf("Its variance is %s times that of the year before, significant in both tests: the whole month was rougher.", fmt(m$variance_ratio))
  } else if (significant(m$p_f)) {
    sprintf(
      "Its variance is %s times that of the year before (F test p = %s), but the robust Fligner test finds no difference (p = %s): a few very large days, not a rougher month overall.",
      fmt(m$variance_ratio), p_text(m$p_f), p_text(m$p_fligner)
    )
  } else {
    sprintf("No significant difference from the year before (variance ratio %s, p = %s and %s).", fmt(m$variance_ratio, 2), p_text(m$p_f), p_text(m$p_fligner))
  }
  big_word <- if (m$biggest_per_year < 1) "rare" else if (m$biggest_per_year < 3) "unusual" else "common"
  return_word <- if (m$return_percentile < 5 || m$return_percentile > 95) {
    "one of the most extreme months"
  } else if (m$return_percentile < 15) {
    "a weak month"
  } else if (m$return_percentile > 85) {
    "a strong month"
  } else {
    "an ordinary month"
  }
  month <- list(
    headline = sprintf("Volatility of the last %d days: %s", days, m$level),
    points = c(
      sprintf(
        "%s%% a year, against %s%% in the year before and a median of %s%% for all %d-day periods since %s: the %s percentile.",
        fmt(m$volatility), fmt(m$volatility_year_before), fmt(m$volatility_median), days, since, ordinal(m$volatility_percentile)
      ),
      comparison,
      sprintf(
        "The largest day, %s (%s%%), was %s standard deviations of the year before: %s, as days that large come %s.",
        short_date(m$biggest_date), signed(m$biggest_pct, 2), fmt(m$biggest_sigma), big_word, how_often(m$biggest_per_year)
      ),
      sprintf(
        "The return of the %d days, %s%%, is in the %s percentile of all %d-day periods: %s.",
        days, signed(m$return_pct), ordinal(m$return_percentile), days, return_word
      )
    )
  )

  r <- analysis$recent
  k <- analysis$settings$recent_days
  up <- r$return_pct > 0
  day_moves <- paste0(short_date(r$days$date), " ", signed(r$days$return_pct, 2), "%", collapse = ", ")
  # without the model, the rarity comes from the moves in standard deviations of their year before
  one_in <- if (is.na(r$one_in_days)) year_days / r$z_per_year else r$one_in_days
  points <- c(
    sprintf("Day by day: %s.", day_moves),
    sprintf("Since %s, %d-day moves this large came %s (the %s percentile).", since, k, how_often(r$per_year), ordinal(r$percentile)),
    sprintf(
      "Against the volatility of the year before, the move is %s standard deviations, which came %s.",
      signed(r$z), how_often(r$z_per_year)
    )
  )
  if (!is.na(r$garch_z)) {
    z <- r$days$garch_z
    opposite <- if (length(z) > 1 && length(unique(sign(z))) > 1) " The days went opposite ways, so they partly cancel out." else ""
    points <- c(points, sprintf(
      "A GARCH model fitted to the %d years before saw %s standard deviations (%s together), given the volatility it expected: about 1 in %s days.%s",
      analysis$settings$garch_years, paste(signed(z), collapse = " and "), signed(r$garch_z), fmt(r$one_in_days, 0), opposite
    ))
    if (length(z) > 1) {
      worst <- which.max(abs(z))
      d <- r$days[worst, ]
      points <- c(points, sprintf(
        "The most extreme single day, %s (%s%%), was %s standard deviations: %s, about 1 in %s days (%s).",
        short_date(d$date), signed(d$return_pct, 2), signed(d$garch_z), with_article(move_verdict(d$one_in_days, d$garch_z > 0)),
        fmt(d$one_in_days, 0), how_often(year_days / d$one_in_days)
      ))
    }
  }
  v <- r$days
  if (all(is.finite(v$volume_ratio))) {
    d <- v[which.max(v$volume_one_in_days), ]
    points <- c(points, sprintf(
      "Volume: %s, %s times the median of the %d days before; %s is %s for the coin, as volume that far %s its month came %s.",
      paste(short_date(v$date), vapply(v$volume, money_text, character(1)), collapse = " and "),
      paste(fmt(v$volume_ratio), collapse = " and "), analysis$settings$month_days, short_date(d$date),
      volume_verdict(d$volume_one_in_days), if (d$volume_ratio >= 1) "above" else "below",
      how_often(year_days / d$volume_one_in_days)
    ))
  }
  recent <- list(
    headline = sprintf("Last %d days: %s%% together, %s", k, signed(r$return_pct), with_article(move_verdict(one_in, up))),
    points = points
  )

  list(month = month, recent = recent, forecast = forecast_text(analysis, p_text))
}
##########################################################################################
#
##########################################################################################
#' @title The forecast and the value at risk in words
#' @description The third card of the Volatility tab, see [volatility_text()].
#' @param analysis The result of [volatility_analysis()].
#' @param p_text Function that formats a p-value.
#' @return A list with a `headline` and `points`, a character vector of
#'   sentences.
#' @keywords internal
#' @examples
#' \dontrun{
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' golemcrypto:::forecast_text(volatility_analysis(btc), format)
#' }
forecast_text <- function(analysis, p_text) {
  level <- round(100 * analysis$settings$level)
  worst <- 100 - level
  h <- analysis$history_risk
  last_year <- sprintf(
    "In the last year, the worst %d%% of days lost at least %s%%, and %s%% on average.",
    worst, fmt(h$var), fmt(h$es)
  )
  f <- analysis$forecast
  if (is.null(f)) {
    return(list(
      headline = sprintf("Value at risk: the worst %d%% of days lost at least %s%%", worst, fmt(h$var)),
      points = c(last_year, "No forecast: the GARCH model needs 500 days of history before the last days.")
    ))
  }
  close <- utils::tail(analysis$series$close, 1)
  change <- function(price) 100 * (price / close - 1)
  first <- f$days[1, ]
  last <- f$days[nrow(f$days), ]
  # relative to the model's own long run: with fat tails its standard deviation is larger than
  # the 30-day volatility of the first card, so the two numbers side by side would mislead
  ratio <- f$sigma / f$sigma_long_run
  long_run <- sprintf("its long-run level of the last %d years", analysis$settings$garch_years)
  trend <- if (abs(ratio - 1) < 0.05) {
    sprintf("The model expects the volatility on %s to be close to %s.", short_date(first$date), long_run)
  } else {
    sprintf(
      "The model expects the volatility on %s to be %s%% %s %s: it should %s, half-way in %s days.",
      short_date(first$date), fmt(100 * abs(ratio - 1), 0), if (ratio > 1) "above" else "below", long_run,
      if (ratio > 1) "ease" else "rise towards it", fmt(f$half_life, 0)
    )
  }
  b <- f$backtest
  rate <- 100 * b$exceedances / b$days
  calibration <- if (is.na(b$p_value) || b$p_value >= 0.05) {
    sprintf("in line with the %d%% expected", worst)
  } else if (rate > worst) {
    "more often than expected: the model understates the risk"
  } else {
    "less often than expected: the model overstates the risk"
  }
  list(
    headline = sprintf(
      "Expected move on %s (%d%% range): %s%% to %s%%",
      short_date(first$date), level, signed(change(first$low)), signed(change(first$high))
    ),
    points = c(
      sprintf(
        "Over the next %d days, to %s (%d%% range): %s%% to %s%%, a close between %s and %s.",
        nrow(f$days), short_date(last$date), level, signed(change(last$low)), signed(change(last$high)),
        price_text(last$low), price_text(last$high)
      ),
      trend,
      sprintf(
        "Value at risk: on 1 day in %d, the loss on %s would exceed %s%%, and average %s%% on those days (the %d%% VaR and expected shortfall).",
        round(100 / worst), short_date(first$date), fmt(f$var), fmt(f$es), level
      ),
      last_year,
      sprintf(
        "Check: losses beyond the model's daily VaR came on %d of the last %d days (%s%%), %s (Kupiec test p = %s).",
        b$exceedances, b$days, fmt(rate), calibration, p_text(b$p_value)
      )
    )
  )
}
