test_that("every plot builds in light and dark mode", {
  alpha <- history[history$name_symbol == "Alpha (A)", ]
  for (mode in c("light", "dark")) {
    expect_no_error(plotly::plotly_build(plot_timeseries(alpha, mode)))
    expect_no_error(plotly::plotly_build(plot_compare(normalize_prices(history), mode)))
    expect_no_error(plotly::plotly_build(plot_treemap(listings, mode)))
    expect_no_error(plotly::plotly_build(plot_returns_calendar(monthly_returns(alpha), "Alpha (A)", mode)))
    expect_no_error(plotly::plotly_build(plot_scales(mode)))
  }
})

test_that("the scales example draws the same coins on a linear and a log axis", {
  built <- plotly::plotly_build(plot_scales())$x
  expect_equal(c(built$layout$yaxis$type, built$layout$yaxis2$type), c("linear", "log"))
  expect_length(built$data, 4)
  expect_equal(built$data[[1]]$y, built$data[[3]]$y)
  # both coins end at their growth over 5 years
  expect_equal(c(max(built$data[[1]]$y), max(built$data[[2]]$y)), c(100 * 2^5, 100 * 1.25^5))
})

test_that("the plots default to light mode, and the calendar to a title without a coin", {
  alpha <- history[history$name_symbol == "Alpha (A)", ]
  compare <- plotly::plotly_build(plot_compare(normalize_prices(history)))$x$layout
  calendar <- plotly::plotly_build(plot_returns_calendar(monthly_returns(alpha)))$x$layout
  expect_equal(compare$font$color, "#212529")
  expect_equal(unname(unlist(calendar$title))[1], "Monthly returns")
})

test_that("plot_timeseries() adds the moving averages and the drawdown, unless asked not to", {
  alpha <- history[history$name_symbol == "Alpha (A)", ]
  trace_names <- function(p) {
    vapply(plotly::plotly_build(p)$x$data, function(trace) if (is.null(trace$name)) "" else trace$name, "")
  }
  expect_true(all(c("2-day average", "3-day average", "From high") %in% trace_names(plot_timeseries(alpha, averages = 2:3))))
  plain <- trace_names(plot_timeseries(alpha, averages = NULL, show_drawdown = FALSE))
  expect_false(any(grepl("average|From high", plain)))
})

test_that("dark mode dims the grid of every panel and the legend stays centred", {
  alpha <- history[history$name_symbol == "Alpha (A)", ]
  layout <- plotly::plotly_build(plot_timeseries(alpha, "dark"))$x$layout
  for (axis in c("xaxis", "yaxis", "yaxis2", "yaxis3")) {
    expect_equal(layout[[axis]]$gridcolor, "rgba(255,255,255,0.1)", label = axis)
  }
  expect_equal(layout$legend$x, 0.5)
})

test_that("the returns calendar has no grid", {
  alpha <- history[history$name_symbol == "Alpha (A)", ]
  layout <- plotly::plotly_build(plot_returns_calendar(monthly_returns(alpha), mode = "dark"))$x$layout
  expect_false(layout$xaxis$showgrid)
  expect_false(layout$yaxis$showgrid)
})

test_that("plot_timeseries() refuses a history of several coins", {
  expect_error(plot_timeseries(history), "holds 2 coins")
})

test_that("plot_theme() switches the text color with the mode", {
  point <- plotly::plot_ly(x = 1, y = 1, type = "scatter", mode = "markers")
  font_color <- function(mode) plotly::plotly_build(plot_theme(point, mode))$x$layout$font$color
  expect_equal(font_color("light"), "#212529")
  expect_equal(font_color("dark"), "#dee2e6")
})

test_that("the treemap shows n/a for a missing 24h change", {
  treemap <- plotly::plotly_build(plot_treemap(listings, "light"))$x$data[[1]]
  expect_equal(treemap$text, c("", "2.50%", "-4.00%", "n/a"), ignore_attr = TRUE)
})

test_that("price changes are shaded with see-through colors that suit both modes", {
  expect_equal(change_color(c(0, 1), gain = TRUE), c("rgba(25,135,84,0.000)", "rgba(25,135,84,0.750)"))
  styles <- as.character(listings_table(listings)$x$options$rowCallback)
  expect_match(styles, "rgba(220,53,69,", fixed = TRUE)
  expect_match(styles, "rgba(25,135,84,", fixed = TRUE)
  expect_no_match(styles, "black")
  treemap <- plotly::plotly_build(plot_treemap(listings, "dark"))$x$data[[1]]
  expect_equal(treemap$textfont$color, "#dee2e6")
})

test_that("listings_table() renames the columns shown in the table", {
  table <- listings_table(listings)
  expect_true(all(c("price", "change_24h", "market_cap") %in% names(table$x$data)))
})

test_that("the seasonality chart and table have a bar and a row per group, in their natural order", {
  analysis <- seasonality_analysis(garch_history(800), "week")
  for (mode in c("light", "dark")) {
    expect_no_error(plotly::plotly_build(plot_seasonality(analysis, mode)))
  }
  built <- plotly::plotly_build(plot_seasonality(analysis))$x
  expect_equal(built$layout$xaxis$type, "category")
  expect_equal(as.character(built$data[[1]]$x), as.character(analysis$groups$group))
  expect_equal(built$layout$shapes[[1]]$y0, 50)
  table <- seasonality_table(analysis)$x$data
  expect_equal(names(table), c("Week of the year", "Returns", "Mean", "Median", "Up", "Best", "Worst"))
  expect_equal(table[[1]], seq_len(nrow(analysis$groups)))
})

test_that("the timeseries chart switches between a linear and a log axis and fits its axes to the days in view", {
  alpha <- history[history$name_symbol == "Alpha (A)", ]
  chart <- plot_timeseries(alpha)
  buttons <- plotly::plotly_build(chart)$x$layout$updatemenus[[1]]$buttons
  expect_equal(vapply(buttons, function(button) button$label, ""), c("Linear", "Log"))
  expect_equal(buttons[[2]]$args, list("yaxis.type", "log"))
  hook <- paste(unlist(chart$jsHooks$render), collapse = "\n")
  expect_match(hook, "plotly_relayout", fixed = TRUE)
  expect_match(hook, "candlestick", fixed = TRUE)
})

test_that("plot_timeseries() adds the Bollinger bands and an RSI panel of a fixed range when asked", {
  alpha <- garch_history(300)
  alpha$open <- alpha$close
  alpha$high <- alpha$close
  alpha$low <- alpha$close
  alpha$volume <- 1000
  names_of <- function(built) vapply(built$data, function(trace) if (is.null(trace$name)) "" else trace$name, "")
  plain <- plotly::plotly_build(plot_timeseries(alpha))$x
  built <- plotly::plotly_build(plot_timeseries(alpha, bollinger = TRUE, show_rsi = TRUE))$x
  names <- names_of(built)
  expect_equal(sum(names == "Bollinger bands"), 3)
  expect_false(any(grepl("Bollinger|RSI", names_of(plain))))
  # the RSI right under the prices, from 0 to 100, with lines at 30 and 70
  expect_equal(built$data[[which(names == "RSI (14 days)")]]$yaxis, "y2")
  expect_equal(built$data[[which(names == "Volume")]]$yaxis, "y3")
  expect_equal(built$layout$yaxis2$range, c(0, 100))
  expect_true(built$layout$yaxis2$fixedrange)
  expect_equal(vapply(built$layout$shapes, function(shape) shape$y0, 0), c(30, 70))
  expect_match(paste(unlist(plot_timeseries(alpha, show_rsi = TRUE)$jsHooks$render), collapse = "\n"), "fixedrange", fixed = TRUE)
})

test_that("plot_compare() shows the coins relative to a base, with a line at 100", {
  relative <- relative_prices(normalize_prices(history), "Beta (B)")
  built <- plotly::plotly_build(plot_compare(relative, base = "Beta (B)"))$x
  expect_length(built$data, 1)
  expect_match(unname(unlist(built$layout$title))[1], "Relative to Beta (B)", fixed = TRUE)
  expect_equal(built$layout$shapes[[1]]$y0, 100)
  expect_null(plotly::plotly_build(plot_compare(normalize_prices(history)))$x$layout$shapes)
})
