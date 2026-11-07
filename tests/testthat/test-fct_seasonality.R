# a coin with a close every day from `from`
daily <- function(close, from = "2024-01-01") {
  data.frame(name_symbol = "Alpha (A)", timestamp = as.Date(from) + seq_along(close) - 1, close = close)
}

# a coin whose return on day k, from 2 January 2024, is returns[k]
with_returns <- function(returns) daily(100 * cumprod(c(1, 1 + returns / 100)))

test_that("iso_week() and period_bounds() follow ISO 8601 weeks, Monday to Sunday", {
  expect_equal(iso_week(as.Date(c("2021-01-03", "2021-01-04", "2024-01-01", "2024-12-30", "2026-12-31"))), c(53, 1, 1, 1, 53))
  weeks <- period_bounds(as.Date(c("2024-02-14", "2024-02-29", "2024-12-31")), "week")
  expect_equal(weeks$start, as.Date(c("2024-02-12", "2024-02-26", "2024-12-30")))
  expect_equal(weeks$end, weeks$start + 6)
  months <- period_bounds(as.Date(c("2024-02-14", "2024-12-31")), "month")
  expect_equal(months$start, as.Date(c("2024-02-01", "2024-12-01")))
  expect_equal(months$end, as.Date(c("2024-02-29", "2024-12-31")))
})

test_that("seasonal_returns() keeps the complete periods with one before them", {
  # 1 January to 10 May 2024: January has no month before it and May has not ended
  history <- daily(seq(100, by = 1, length.out = 131))
  months <- seasonal_returns(history, "month")
  expect_equal(as.character(months$group), c("Feb", "Mar", "Apr"))
  expect_equal(levels(months$group), month.abb)
  expect_equal(months$start, as.Date(c("2024-02-01", "2024-03-01", "2024-04-01")))
  expect_equal(months$return_pct, (c(159, 190, 220) / c(130, 159, 190) - 1) * 100)
  # 2 January 2024 was a Tuesday
  days <- seasonal_returns(history, "day")
  expect_equal(nrow(days), 130)
  expect_equal(as.character(days$group[1:2]), c("Tuesday", "Wednesday"))
  expect_equal(days$return_pct[1], 1)
  # 1 January 2024 was the Monday of week 1, and 10 May a Friday, in the week after the last complete one
  weeks <- seasonal_returns(history, "week")
  expect_equal(as.integer(as.character(weeks$group)), 2:18)
  expect_equal(max(weeks$end), as.Date("2024-05-05"))
})

test_that("seasonal_returns() leaves out the periods next to missing days, and sorts the history", {
  history <- daily(seq(100, by = 1, length.out = 10))[-5, ]
  days <- seasonal_returns(history[c(9, 1:8), ], "day")
  # neither 5 January, which is missing, nor 6 January, which has no close the day before
  expect_false(any(days$start %in% as.Date(c("2024-01-05", "2024-01-06"))))
  expect_equal(nrow(days), 7)
  expect_false(is.unsorted(days$start))
})

test_that("seasonal_returns() puts the years in the 4-year cycle of the halvings", {
  ends <- as.Date(paste0(2015:2021, "-12-31"))
  years <- seasonal_returns(data.frame(timestamp = ends, close = c(1, 2, 4, 2, 1, 3, 9)), "year")
  expect_equal(
    as.character(years$group),
    c("Halving year", "Halving + 1", "Halving + 2", "Halving + 3", "Halving year", "Halving + 1")
  )
  expect_equal(years$return_pct, c(100, 100, -50, -50, 200, 200))
  expect_error(seasonal_returns(daily(1:3), "decade"))
  expect_error(seasonal_returns(history, "day"), "coins")
})

test_that("seasonality_analysis() sums up each group and finds a real difference", {
  # 2 January to 10 March 2024: Mondays rise by 10%, the other days fall by 1%
  monday <- as.POSIXlt(as.Date("2024-01-02") + 0:68)$wday == 1
  analysis <- seasonality_analysis(with_returns(ifelse(monday, 10, -1)), "day")
  groups <- analysis$groups
  expect_equal(as.character(groups$group), weekday_names)
  expect_equal(groups$returns, c(9, rep(10, 6)))
  expect_equal(groups$mean_pct, c(10, rep(-1, 6)))
  expect_equal(groups$median_pct, c(10, rep(-1, 6)))
  expect_equal(groups$up_pct, c(100, rep(0, 6)))
  expect_equal(c(groups$best_pct[1], groups$worst_pct[2]), c(10, -1))
  expect_equal(analysis$all$returns, 69)
  expect_lt(analysis$p_value, 0.001)
  text <- seasonality_text(analysis)
  expect_match(text$groups$headline, "Best day: Monday, mean +10.00%", fixed = TRUE)
  expect_match(text$groups$points[1], "Monday: mean +10.00%, median +10.00%, up 9 of 9 times (100%).", fixed = TRUE)
  expect_match(text$chance$headline, "differ by more than chance usually gives (p < 0.001)", fixed = TRUE)
})

test_that("seasonality_analysis() finds no difference where every day gets the same returns", {
  # 35 days: as 5 and 7 have no common factor, each day of the week gets each of the 5 returns
  # once (returns that binary fractions hold exactly, so that the ties stay ties)
  analysis <- seasonality_analysis(with_returns(c(100, 50, 0, -50, -25)[(1:35 - 1) %% 5 + 1]), "day")
  expect_equal(analysis$groups$mean_pct, rep(15, 7))
  expect_equal(analysis$p_value, 1)
  expect_match(seasonality_text(analysis)$chance$headline, "could well be chance (p = 1)", fixed = TRUE)
  # returns that are all the same do not break the test
  expect_equal(seasonality_analysis(daily(rep(100, 20)), "day")$p_value, 1)
})

test_that("seasonality_analysis() needs a complete period, and says when it cannot test", {
  expect_null(seasonality_analysis(daily(1:20), "month"))
  # January and February 2024: one return, of February
  analysis <- seasonality_analysis(daily(seq(100, by = 1, length.out = 60)), "month")
  expect_equal(nrow(analysis$groups), 1)
  expect_true(is.na(analysis$p_value))
  text <- seasonality_text(analysis)
  expect_match(text$groups$headline, "Only February so far", fixed = TRUE)
  expect_equal(text$chance$headline, "Too few months to test")
})

test_that("the best and the worst leave out groups with few returns, such as week 53", {
  analysis <- seasonality_analysis(garch_history(2000, seed = 2), "week")
  expect_true("53" %in% analysis$groups$group)
  analysis$groups$mean_pct[analysis$groups$group == "53"] <- 1000
  text <- seasonality_text(analysis)$groups
  expect_no_match(text$headline, "week 53")
  expect_match(text$points, "Left out of the best and the worst, with fewer than half the returns of the others: week 53", fixed = TRUE, all = FALSE)
})

test_that("seasonality_csv() names the group column after the period", {
  analysis <- seasonality_analysis(garch_history(800), "month")
  csv <- seasonality_csv(analysis)
  expect_equal(names(csv), c("month", "returns", "mean_pct", "median_pct", "up_pct", "best_pct", "worst_pct"))
  expect_equal(as.character(csv$month), month.abb)
})
