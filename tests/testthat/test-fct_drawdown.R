# a coin whose closes are given, one a day from 1 January 2024
closes <- function(close) {
  data.frame(name_symbol = "Alpha (A)", timestamp = as.Date("2024-01-01") + seq_along(close) - 1, close = close)
}

test_that("drawdown_episodes() finds each fall from a high, the deepest first", {
  episodes <- drawdown_episodes(c(100, 120, 90, 130, 65, 70), as.Date("2026-01-01") + 0:5)
  expect_equal(episodes$depth_pct, c(-50, -25))
  expect_equal(episodes$peak_price, c(130, 120))
  expect_equal(episodes$trough_date, as.Date(c("2026-01-05", "2026-01-03")))
  expect_equal(episodes$days_to_trough, c(1, 1))
  # the first fall got back above its high on the 4th day, the second goes on
  expect_equal(episodes$recovery_date, as.Date(c(NA, "2026-01-04")))
  expect_equal(episodes$days_to_recover, c(NA, 1))
  expect_equal(episodes$days_total, c(2, 2))
  expect_equal(episodes$ongoing, c(TRUE, FALSE))
  expect_equal(nrow(drawdown_episodes(c(100, 120, 90, 130, 65, 70), as.Date("2026-01-01") + 0:5, min_depth = 40)), 1)
})

test_that("drawdown_episodes() counts calendar days, ends a fall at its high and has no rows without falls", {
  # a missing day between the peak and the trough
  episodes <- drawdown_episodes(c(10, 5, 10), as.Date(c("2026-01-01", "2026-01-03", "2026-01-04")))
  expect_equal(episodes$days_to_trough, 2)
  expect_equal(episodes$days_total, 3)
  expect_false(episodes$ongoing)
  none <- drawdown_episodes(c(1, 2, 3), as.Date("2026-01-01") + 0:2)
  expect_equal(nrow(none), 0)
  expect_named(none, names(episodes))
})

test_that("drawdown_analysis() compares the current fall with the earlier ones", {
  analysis <- drawdown_analysis(closes(c(100, 40, 100, 120, 60, 80)))
  now <- analysis$now
  expect_equal(now$drawdown_pct, (80 / 120 - 1) * 100)
  expect_equal(now$high_price, 120)
  expect_equal(now$high_date, as.Date("2024-01-04"))
  expect_equal(now$days_since_high, 2)
  expect_equal(now$rise_needed_pct, 50)
  expect_equal(now$low_price, 60)
  expect_equal(now$deepest_pct, -50)
  # the fall to 40 went deeper
  expect_equal(now$rank, 2)
  expect_equal(now$earlier$depth_pct, -60)
  expect_equal(analysis$episodes$rank, 1:2)
  # three closes at least 20% below the high, and one new high after the first day
  expect_equal(analysis$share_under, 50)
  expect_equal(analysis$new_highs, 1)
  expect_equal(nrow(drawdown_analysis(closes(c(100, 40, 100, 120, 60, 80)), min_depth = 55)$episodes), 1)
  expect_named(analysis$series, c("date", "close", "high", "drawdown_pct"))
})

test_that("drawdown_analysis() sorts the history, drops missing prices and needs two of them", {
  shuffled <- closes(c(100, 40, NA, 100, 120, 60, 80))[c(7, 1:6), ]
  expect_equal(drawdown_analysis(shuffled)$now$close, 80)
  expect_null(drawdown_analysis(closes(100)))
  expect_error(drawdown_analysis(history), "coins")
})

test_that("drawdown_text() says where the coin stands", {
  text <- drawdown_text(drawdown_analysis(closes(c(100, 40, 100, 120, 60, 80))))
  expect_equal(text$now$headline, "Now: −33.3% from the all-time high, in its 2nd deepest fall")
  expect_match(text$now$points[2], "rise of +50.0% from the last close of $80.00", fixed = TRUE)
  expect_match(text$now$points[3], "Earlier falls as deep as −50.0% or deeper: 1", fixed = TRUE)
  expect_equal(text$history$headline, "Since 1 Jan 2024: 2 falls of 20% or more")
  expect_match(text$history$points[1], "The deepest: −60.0%, from $100.00 on 1 Jan 2024", fixed = TRUE)

  deepest <- drawdown_text(drawdown_analysis(closes(c(100, 80, 100, 120, 30, 40))))
  expect_match(deepest$now$headline, "its deepest fall ever")
  expect_match(deepest$now$points[3], "No earlier fall went as deep")

  at_high <- drawdown_text(drawdown_analysis(closes(c(100, 40, 100, 120))))
  expect_equal(at_high$now$headline, "Now: at an all-time high")
  expect_match(at_high$now$points[2], "The last fall of 20% or more went −60.0%", fixed = TRUE)
  calm <- drawdown_text(drawdown_analysis(closes(c(100, 90, 100, 120)), min_depth = 20))
  expect_match(calm$now$points[2], "no fall of 20% or more")
  expect_equal(calm$history$headline, "Since 1 Jan 2024: no fall of 20% or more")
})

test_that("drawdown_text() gives the median fall when there are enough of them", {
  close <- c(100, 70, 100, 50, 100, 75, 100, 120)
  text <- drawdown_text(drawdown_analysis(closes(close)))
  expect_match(text$history$points[2], "The median fall: −30.0%", fixed = TRUE)
})

test_that("drawdown_csv() holds a row per fall", {
  csv <- drawdown_csv(drawdown_analysis(closes(c(100, 40, 100, 120, 60, 80))))
  expect_equal(names(csv), c(
    "rank", "peak_date", "peak_price", "trough_date", "trough_price", "fall_pct", "days_to_trough",
    "recovery_date", "days_to_recover", "days_total", "ongoing"
  ))
  expect_equal(nrow(csv), 2)
})

test_that("plot_drawdowns() shades each fall and marks its trough", {
  analysis <- drawdown_analysis(closes(c(100, 40, 100, 120, 60, 80)))
  built <- plotly::plotly_build(plot_drawdowns(analysis, "dark"))
  expect_length(built$x$layout$shapes, 2)
  expect_equal(built$x$layout$yaxis$type, "log")
  troughs <- Filter(function(trace) identical(trace$mode, "markers+text"), built$x$data)
  expect_equal(as.vector(troughs[[1]]$text), 1:2)
  calm <- plotly::plotly_build(plot_drawdowns(drawdown_analysis(closes(c(1, 2, 3)))))
  expect_length(calm$x$layout$shapes, 0)
})

test_that("drawdown_table() lists the falls and hides the column of the current one", {
  table <- drawdown_table(drawdown_analysis(closes(c(100, 40, 100, 120, 60, 80))))
  expect_s3_class(table, "datatables")
  expect_equal(nrow(table$x$data), 2)
  expect_equal(names(table$x$data)[1:6], c("#", "Peak", "High", "Trough", "Low", "Fall"))
  hidden <- Filter(function(column) isFALSE(column$visible), table$x$options$columnDefs)
  expect_equal(hidden[[1]]$targets, 10)
})
