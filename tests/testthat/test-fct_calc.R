test_that("normalize_prices() starts every coin at 100 on the first common date", {
  prices <- normalize_prices(history)
  expect_equal(min(prices$timestamp), as.Date("2024-02-29"))
  expect_equal(prices$index[prices$name_symbol == "Alpha (A)"], c(100, 90, 110))
  expect_equal(prices$index[prices$name_symbol == "Beta (B)"], c(100, 110, 50))
})

test_that("monthly_returns() compares the last close of each month", {
  calendar <- monthly_returns(history[history$name_symbol == "Alpha (A)", ])
  expect_equal(dimnames(calendar), list("2024", month.abb))
  expect_equal(unname(calendar["2024", c("Jan", "Feb", "Mar")]), c(NA, 10, 10))
  expect_true(all(is.na(calendar["2024", 4:12])))
})

test_that("moving_average() averages the last days once there are enough of them", {
  expect_equal(moving_average(c(1, 2, 3, 4, 5), days = 3), c(NA, NA, 2, 3, 4))
  expect_equal(moving_average(c(1, 2, 3), days = 1), c(1, 2, 3))
  expect_true(all(is.na(moving_average(1:5, days = 10))))
})

test_that("drawdown() measures how far each close is below the high so far", {
  expect_equal(drawdown(c(100, 120, 90, 130, 65)), c(0, 0, -25, 0, -50))
})

test_that("monthly_returns() refuses a history of several coins", {
  expect_error(monthly_returns(history), "holds 2 coins")
})

test_that("bollinger_bands() puts the bands two standard deviations of the window from its average", {
  close <- c(10, 11, 12, 11, 10, 12, 14)
  bands <- bollinger_bands(close, days = 3)
  window <- close[5:7]
  spread <- 2 * sqrt(mean((window - mean(window))^2))
  expect_equal(bands$middle[7], mean(window))
  expect_equal(c(bands$upper[7], bands$lower[7]), mean(window) + c(spread, -spread))
  expect_true(all(is.na(bands[1:2, ])))
  # flat prices give bands on the average, at the price of a coin of a fraction of a cent too
  expect_equal(bollinger_bands(rep(0.00001234, 25))$upper[25], 0.00001234)
  # fewer closes than the window
  expect_true(all(is.na(bollinger_bands(1:5)$upper)))
})

test_that("rsi() follows Wilder's smoothing", {
  close <- garch_history(200)$close
  change <- diff(close)
  rise <- pmax(change, 0)
  fall <- pmax(-change, 0)
  up <- mean(rise[1:14])
  down <- mean(fall[1:14])
  expected <- rep(NA_real_, length(close))
  expected[15] <- 100 - 100 / (1 + up / down)
  for (i in 15:length(change)) {
    up <- (up * 13 + rise[i]) / 14
    down <- (down * 13 + fall[i]) / 14
    expected[i + 1] <- 100 - 100 / (1 + up / down)
  }
  expect_equal(rsi(close), expected)
  expect_equal(rsi(1:10, 3)[4:10], rep(100, 7))
  expect_equal(rsi(rep(5, 6), 3)[4:6], rep(50, 3))
  expect_true(all(is.na(rsi(1:3, 3))))
})

test_that("relative_prices() divides by the base, carrying its last close over its missing days", {
  prices <- data.frame(
    name_symbol = rep(c("Alpha (A)", "Beta (B)"), c(3, 2)),
    timestamp = as.Date("2024-01-01") + c(0:2, 0, 2),
    close = c(10, 12, 15, 100, 50),
    index = c(100, 120, 150, 100, 50)
  )
  relative <- relative_prices(prices, "Beta (B)")
  expect_equal(relative$name_symbol, rep("Alpha (A)", 3))
  # on 2 January Beta has no close, so its close of 1 January stands in
  expect_equal(relative$index, c(100, 120, 300))
  expect_equal(relative$base_index, c(100, 100, 50))
  expect_equal(unique(relative$base), "Beta (B)")
  expect_error(relative_prices(prices, "Gamma (C)"), "base")
})
