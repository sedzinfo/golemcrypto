test_that("rolling_sum() and rolling_sd() match the windows they cover", {
  x <- c(1, 3, 2, 5, 4, 9)
  expect_equal(golemcrypto:::rolling_sum(x, 3), c(NA, NA, 6, 10, 11, 18))
  expect_equal(golemcrypto:::rolling_sd(x, 3), c(NA, NA, sd(x[1:3]), sd(x[2:4]), sd(x[3:5]), sd(x[4:6])))
  expect_true(all(is.na(golemcrypto:::rolling_sum(x, 10))))
})

test_that("garch_variance() follows the GARCH(1,1) recursion", {
  e <- c(1, -2, 0.5)
  expect_equal(
    golemcrypto:::garch_variance(e, omega = 0.1, alpha = 0.2, beta = 0.7, start = 2),
    c(2, 0.1 + 0.2 * 1 + 0.7 * 2, 0.1 + 0.2 * 4 + 0.7 * (0.1 + 0.2 + 1.4))
  )
})

test_that("garch_fit() finds the parameters of a simulated series", {
  history <- garch_history(3000)
  fit <- golemcrypto:::garch_fit(100 * diff(log(history$close)))
  expect_equal(fit$alpha, 0.1, tolerance = 0.5)
  expect_equal(fit$beta, 0.85, tolerance = 0.1)
  expect_lt(fit$alpha + fit$beta, 1)
})

test_that("move_verdict() and volatility_level() put numbers into words", {
  expect_equal(
    golemcrypto:::move_verdict(c(10, 100, 1000, 5000, NA), up = c(TRUE, FALSE, FALSE, TRUE, TRUE)),
    c("normal rise", "unusual fall", "rare fall", "very rare rise", NA)
  )
  expect_equal(golemcrypto:::volatility_level(c(40, 70, 90, 99)), c("normal", "elevated", "high", "extreme"))
  expect_equal(golemcrypto:::how_often(c(0, 0.25, 1, 3, 40)), c(
    "never before in its history", "about once every 4.0 years", "about once a year",
    "about 3.0 times a year", "about 40 times a year"
  ))
})

test_that("volatility_analysis() needs more than a year of moving prices", {
  expect_null(volatility_analysis(garch_history(300)))
  flat <- data.frame(name_symbol = "Alpha (A)", timestamp = as.Date("2022-01-01") + 0:899, close = 1)
  expect_null(volatility_analysis(flat))
  expect_error(volatility_analysis(history), "holds 2 coins")
})

test_that("volatility_analysis() measures the month and the last days", {
  analysis <- volatility_analysis(garch_history())
  expect_named(analysis, c("coin", "first_date", "last_date", "month", "recent", "garch", "forecast", "history_risk", "series", "settings"))
  expect_equal(nrow(analysis$series), 901)
  expect_equal(nrow(analysis$recent$days), 2)
  expect_true(all(analysis$month$volatility_percentile >= 0, analysis$month$volatility_percentile <= 100))
  expect_false(is.null(analysis$garch))
  # the GARCH measures of the last days are the last values of the series
  expect_equal(analysis$recent$days$garch_z, utils::tail(analysis$series$garch_z, 2))
})

test_that("a crash in the last days reads as a rare fall", {
  analysis <- volatility_analysis(garch_history(last = c(-25, -20)))
  expect_lt(analysis$recent$garch_z, -4)
  expect_gt(analysis$recent$one_in_days, 365)
  text <- volatility_text(analysis)
  expect_match(text$recent$headline, "^Last 2 days: −36\\.\\d% together, a (very )?rare fall$")
  expect_match(text$month$headline, "^Volatility of the last 30 days: ")
  expect_true(any(grepl("GARCH", text$recent$points)))
})

test_that("without enough days for the model, the last days are judged without it", {
  analysis <- volatility_analysis(garch_history(450))
  expect_null(analysis$garch)
  expect_true(all(is.na(analysis$series$garch_z)))
  text <- volatility_text(analysis)
  expect_false(any(grepl("GARCH", text$recent$points)))
  expect_s3_class(plot_volatility(analysis), "plotly")
})

test_that("plot_volatility() draws the volatility and the recent moves", {
  p <- plot_volatility(volatility_analysis(garch_history()), mode = "dark")
  expect_s3_class(p, "plotly")
  expect_no_error(plotly::plotly_build(p))
})

test_that("t_quantile() and garch_risk() match the normal distribution for large nu", {
  expect_equal(golemcrypto:::t_quantile(c(0.05, 0.975), 1e7), qnorm(c(0.05, 0.975)), tolerance = 1e-5)
  risk <- golemcrypto:::garch_risk(mu = 0.1, sigma = 3, nu = 1e7, level = 0.95)
  q <- 0.1 + 3 * qnorm(0.05)
  es <- integrate(function(r) 100 * (1 - exp(r / 100)) * dnorm(r, 0.1, 3), -Inf, q)$value / 0.05
  expect_equal(risk$var, 100 * (1 - exp(q / 100)), tolerance = 1e-5)
  expect_equal(risk$es, es, tolerance = 1e-4)
})

test_that("garch_risk() matches a simulation of fat-tailed days", {
  risk <- golemcrypto:::garch_risk(mu = 0, sigma = 2.5, nu = 4, level = 0.95)
  loss <- golemcrypto:::with_seed(5, 100 * (1 - exp(2.5 * rt(1e6, 4) * sqrt(2 / 4) / 100)))
  cutoff <- quantile(loss, 0.95, names = FALSE)
  expect_equal(risk$var, cutoff, tolerance = 0.01)
  expect_equal(risk$es, mean(loss[loss >= cutoff]), tolerance = 0.01)
  expect_gt(risk$es, risk$var)
})

test_that("kupiec_test() rejects a value at risk exceeded too often or too rarely", {
  expect_gt(golemcrypto:::kupiec_test(18, 365, 0.05), 0.5)
  expect_lt(golemcrypto:::kupiec_test(40, 365, 0.05), 0.001)
  expect_lt(golemcrypto:::kupiec_test(0, 365, 0.05), 0.001)
  expect_length(golemcrypto:::kupiec_test(c(10, 18, 365), 365, 0.05), 3)
})

test_that("with_seed() repeats its random numbers and leaves the session's alone", {
  set.seed(3)
  expected <- runif(1)
  set.seed(3)
  first <- golemcrypto:::with_seed(1, runif(3))
  expect_identical(runif(1), expected)
  expect_identical(golemcrypto:::with_seed(1, runif(3)), first)
})

test_that("garch_forecast() widens its ranges and falls back to the long run", {
  garch <- list(mu = 0.05, omega = 0.4, alpha = 0.1, beta = 0.85, nu = 4)
  ahead <- golemcrypto:::garch_forecast(garch, e_last = -8, variance_last = 9, days = 7, level = 0.95, paths = 20000)
  expect_equal(nrow(ahead), 7)
  ranges <- as.matrix(ahead[c("low", "low_50", "median", "high_50", "high")])
  expect_true(all(t(apply(ranges, 1, diff)) > 0))
  expect_true(all(diff(ahead$high - ahead$low) > 0))
  # after a large day the volatility is above the long run, and falls towards it
  long_run <- sqrt(0.4 / 0.05)
  expect_true(all(diff(ahead$sigma) < 0) && all(ahead$sigma > long_run))
  # the first day is exact
  sigma <- sqrt(0.4 + 0.1 * 64 + 0.85 * 9)
  expect_equal(ahead$high[1], 0.05 + sigma * golemcrypto:::t_quantile(0.975, 4))
})

test_that("volatility_analysis() forecasts the next days and leaves the random numbers alone", {
  history <- garch_history()
  set.seed(9)
  expected <- runif(1)
  set.seed(9)
  analysis <- volatility_analysis(history)
  expect_identical(runif(1), expected)
  f <- analysis$forecast
  expect_equal(f$days$date, analysis$last_date + 1:7)
  expect_true(all(f$days$low < f$days$median & f$days$median < f$days$high))
  expect_gt(f$es, f$var)
  expect_equal(f$backtest$days, 365)
  expect_true("garch_var" %in% names(analysis$series))
  expect_identical(volatility_analysis(history)$forecast, f)
  text <- volatility_text(analysis)$forecast
  expect_match(text$headline, "^Expected move on \\d+ \\w+ \\(95% range\\): ")
  expect_true(any(grepl("Kupiec", text$points)))
  csv <- golemcrypto:::volatility_csv(analysis)
  expect_equal(nrow(csv), nrow(analysis$series) + 7)
  expect_true(all(c("forecast_low", "forecast_median", "forecast_high") %in% names(csv)))
  expect_true(all(is.na(utils::tail(csv$close, 7))))
})

test_that("without a model, the third card gives the last year's value at risk only", {
  analysis <- volatility_analysis(garch_history(450))
  expect_null(analysis$forecast)
  expect_gt(analysis$history_risk$es, analysis$history_risk$var)
  text <- volatility_text(analysis)$forecast
  expect_match(text$headline, "^Value at risk: the worst 5% of days lost at least ")
  expect_true(any(grepl("No forecast", text$points)))
  expect_identical(golemcrypto:::volatility_csv(analysis), analysis$series)
})

test_that("plot_volatility() has a panel for the forecast", {
  p <- plotly::plotly_build(plot_volatility(volatility_analysis(garch_history())))
  expect_true("yaxis3" %in% names(p$x$layout))
})

test_that("volume_ratio() compares each day with the median of the days before", {
  ratio <- golemcrypto:::volume_ratio(c(rep(100, 30), 300, 50), days = 30)
  expect_equal(utils::tail(ratio, 2), c(3, 0.5))
  expect_true(all(is.na(ratio[1:30])))
  # days without volume are left out, and too few of them leave no ratio
  expect_true(is.na(utils::tail(golemcrypto:::volume_ratio(c(rep(0, 15), rep(100, 15), 200), 30), 1)))
  expect_true(is.na(utils::tail(golemcrypto:::volume_ratio(c(rep(100, 30), 0), 30), 1)))
  expect_equal(golemcrypto:::volume_verdict(c(10, 100, 1000, 5000)), c("normal", "unusual", "rare", "very rare"))
})

test_that("an unusually busy or quiet last day shows in the volume point", {
  history <- garch_history()
  set.seed(4)
  history$volume <- 1e6 * exp(rnorm(nrow(history), sd = 0.2))
  history$volume[nrow(history)] <- 6e6
  analysis <- volatility_analysis(history)
  expect_equal(analysis$recent$days$volume[2], 6e6)
  expect_gt(analysis$recent$days$volume_ratio[2], 4)
  volume <- grep("^Volume:", volatility_text(analysis)$recent$points, value = TRUE)
  expect_match(volume, "\\$6\\.0m")
  expect_match(volume, "is (rare|very rare) for the coin, as volume that far above its month")
  history$volume[nrow(history)] <- 1e5
  volume <- grep("^Volume:", volatility_text(volatility_analysis(history))$recent$points, value = TRUE)
  expect_match(volume, "far below its month")
})

test_that("without volume the last days are judged on the price alone", {
  analysis <- volatility_analysis(garch_history())
  expect_true(all(is.na(analysis$recent$days$volume_ratio)))
  expect_false(any(grepl("^Volume:", volatility_text(analysis)$recent$points)))
})
