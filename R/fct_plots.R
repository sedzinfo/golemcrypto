##########################################################################################
# 
##########################################################################################
#' @title Date range buttons of the timeseries chart
#' @noRd
range_buttons <- list(
  list(count = 1, label = "1 year", step = "year", stepmode = "backward"),
  list(count = 1, label = "year to date", step = "year", stepmode = "todate"),
  list(count = 6, label = "6 months", step = "month", stepmode = "backward"),
  list(count = 3, label = "3 months", step = "month", stepmode = "backward"),
  list(count = 1, label = "1 month", step = "month", stepmode = "backward"),
  list(count = 7, label = "7 days", step = "day", stepmode = "backward"),
  list(step = "all")
)
##########################################################################################
# 
##########################################################################################
#' @title Colors of the moving average lines, in the order of the averages
#' @description Blue and purple first, which stand out from the orange close
#' line, the green and red candles and the green volume, in light and dark mode.
#' @noRd
average_colors <- c("#3b82f6", "#a855f7", "#14b8a6", "#eab308")
##########################################################################################
#
##########################################################################################
#' @title Candlestick chart of a coin's prices
#' @description Plots the daily open, high, low and close prices, with a line
#' through the close, its moving averages, date range buttons and a range
#' slider. Underneath, smaller charts show the trading volume and the 
#' drawdown: how far the price is below its all-time high so far. A click on
#' a legend entry hides or shows that line.
#' @param history Price history of one coin from [get_history()]. The
#'   averages and the drawdown use the whole history, so pass all of it and
#'   zoom with the range buttons.
#' @param mode `"light"` (the default) or `"dark"`, to suit a light or dark
#'   page.
#' @param averages Days of the moving averages to draw (see
#'   [moving_average()]), or `NULL` for none.
#' @param show_drawdown `TRUE` to add the drawdown chart (see [drawdown()]).
#' @return A plotly object.
#' @export
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' plot_timeseries(btc)
#' # shorter averages, and no drawdown chart
#' plot_timeseries(btc, averages = c(20, 100), show_drawdown = FALSE)
plot_timeseries <- function(history, mode = "light", averages = c(50, 200), show_drawdown = TRUE) {
  check_one_coin(history)
  hover_text <- paste0(
    "\nDate=", history$timestamp,
    "\nClose=", history$close,
    "\nOpen=", history$open,
    "\nHigh=", history$high,
    "\nLow=", history$low
  )
  price <- plotly::plot_ly(history,
    x = history$timestamp,
    open = history$open,
    high = history$high,
    low = history$low,
    close = history$close,
    yaxis = "y",
    text = hover_text,
    name = "Range",
    type = "candlestick"
  ) %>%
    plotly::add_lines(
      x = history$timestamp,
      y = history$close,
      line = list(width = 1, color = "#ff7f0e"),
      inherit = FALSE,
      text = hover_text,
      name = "close"
    )
  for (i in seq_along(averages)) {
    price <- plotly::add_lines(price,
      x = history$timestamp,
      y = moving_average(history$close, averages[i]),
      line = list(width = 1.5, color = average_colors[(i - 1) %% length(average_colors) + 1]),
      inherit = FALSE,
      name = paste0(averages[i], "-day average"),
      hovertemplate = paste0("%{x}<br>", averages[i], "-day average: %{y:,.2f}<extra></extra>")
    )
  }
  price <- price %>%
    plotly::layout(
      # on the left, as the legend is centred above the chart
      title = list(text = unique(history$name), x = 0.01, xanchor = "left"),
      legend = list(orientation = "h", x = 0.5, xanchor = "center"),
      yaxis = list(title = "USD"),
      xaxis = list(
        title = "Date",
        rangeslider = list(type = "date", visible = TRUE),
        rangeselector = c(button_colors(mode), list(buttons = range_buttons))
      )
    )
  volume <- plotly::plot_ly(
    x = history$timestamp,
    y = history$volume,
    type = "scatter",
    mode = "lines",
    line = list(color = "#2ca02c"),
    name = "Volume"
  ) %>%
    # no axis title: the legend names the panel, and on a short panel the titles run into each other
    plotly::layout(yaxis = list(title = ""))
  panels <- list(price, volume)
  heights <- c(0.8, 0.2)
  if (show_drawdown) {
    from_high <- plotly::plot_ly(
      x = history$timestamp,
      y = drawdown(history$close),
      type = "scatter",
      mode = "lines",
      fill = "tozeroy",
      line = list(width = 1, color = change_color(1, gain = FALSE)),
      fillcolor = change_color(0.2, gain = FALSE),
      name = "From high",
      hovertemplate = "%{x}<br>From high: %{y:.1f}%<extra></extra>"
    ) %>%
      plotly::layout(yaxis = list(title = "", ticksuffix = "%"))
    panels <- c(panels, list(from_high))
    heights <- c(0.65, 0.15, 0.2)
  }
  plotly::subplot(panels, heights = heights, nrows = length(panels), shareX = TRUE, titleY = TRUE) %>%
    plot_theme(mode)
}
##########################################################################################
# 
##########################################################################################
#' @title Line chart of normalized close prices
#' @description One line per coin, with buttons that switch the y axis between
#' a linear and a log scale.
#' @param prices Prices from [normalize_prices()].
#' @inheritParams plot_timeseries
#' @return A plotly object.
#' @export
#' @examples
#' history <- get_history(c("Bitcoin (BTC)", "Ethereum (ETH)", "Solana (SOL)"))
#' plot_compare(normalize_prices(history))
plot_compare <- function(prices, mode = "light") {
  plotly::plot_ly(prices,
    x = ~timestamp,
    y = ~index,
    color = ~name_symbol,
    type = "scatter",
    mode = "lines",
    hovertemplate = "%{x}<br>%{y:.2f}"
  ) %>%
    plotly::layout(
      title = paste0("Normalized close (", min(prices$timestamp), " = 100)"),
      legend = list(orientation = "h", x = 0.5, xanchor = "center"),
      xaxis = list(title = "Date"),
      yaxis = list(title = "Index"),
      updatemenus = list(list(
        type = "buttons",
        direction = "right",
        x = 0,
        y = 1.08,
        # plotly draws the active button light in both modes, so the other buttons get a
        # light background too, instead of the page's, and all of them dark text
        bgcolor = "#eeeeee",
        font = list(color = "#212529"),
        buttons = list(
          list(label = "Linear", method = "relayout", args = list("yaxis.type", "linear")),
          list(label = "Log", method = "relayout", args = list("yaxis.type", "log"))
        )
      ))
    ) %>%
    plot_theme(mode)
}
##########################################################################################
#
##########################################################################################
#' @title Linear and log axes side by side
#' @description An example for the About tab: two made-up coins that grow at
#' steady rates, one doubling every year and one by 25% a year, on a linear axis
#' and on a log axis. On the log axis both are straight lines, and the steeper
#' line is the faster growth.
#' @inheritParams plot_timeseries
#' @return A plotly object.
#' @keywords internal
#' @examples
#' golemcrypto:::plot_scales()
plot_scales <- function(mode = "light") {
  years <- seq(0, 5, by = 1 / 12)
  coins <- list("Doubles every year" = 100 * 2^years, "+25% a year" = 100 * 1.25^years)
  panel <- function(type) {
    p <- plotly::plot_ly()
    for (i in seq_along(coins)) {
      p <- plotly::add_lines(p,
        x = years,
        y = coins[[i]],
        name = names(coins)[i],
        legendgroup = names(coins)[i],
        # one legend entry per coin for both panels
        showlegend = type == "linear",
        line = list(color = average_colors[i]),
        hovertemplate = "Year %{x:.1f}<br>Index %{y:,.0f}<extra></extra>"
      )
    }
    yaxis <- list(type = type, title = if (type == "linear") "Index" else "")
    # a gridline at every doubling, equally far apart on the log axis
    if (type == "log") yaxis$tickvals <- 100 * 2^(0:5)
    plotly::layout(p, xaxis = list(title = "Years"), yaxis = yaxis)
  }
  title <- function(text, x) {
    list(text = text, x = x, y = 1, xref = "paper", yref = "paper", xanchor = "center", yanchor = "bottom", showarrow = FALSE)
  }
  plotly::subplot(panel("linear"), panel("log"), titleX = TRUE, titleY = TRUE, margin = 0.07) %>%
    plotly::layout(
      # above the panel titles, clear of the axis titles under the panels
      legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 1.12, yanchor = "bottom"),
      annotations = list(title("Linear axis", 0.215), title("Log axis", 0.785)),
      margin = list(t = 80)
    ) %>%
    # an illustration: no zoom or download buttons, which would cover the panel titles
    plotly::config(displayModeBar = FALSE) %>%
    plot_theme(mode)
}
##########################################################################################
#
##########################################################################################
#' @title Treemap of the top 100 coins
#' @description Each box is sized by market cap and colored from red to green
#' by the 24h price change. The color limits are the 5th and 95th percentiles
#' of the changes, so a few outliers do not wash out the rest. Coins without
#' 24h change are labelled n/a and colored white.
#' @param listings The `data` of [get_listings()].
#' @inheritParams plot_timeseries
#' @return A plotly object.
#' @export
#' @examplesIf nzchar(Sys.getenv("COINMARKETCAP_APIKEY"))
#' plot_treemap(get_listings()$data)
plot_treemap <- function(listings, mode = "light") {
  top <- utils::head(listings, 100)
  market_cap <- top$USD_market_cap
  market_cap[is.na(market_cap)] <- 0
  change <- top$USD_percent_change_24h
  limit <- max(abs(stats::quantile(change, c(.05, .95), na.rm = TRUE)))
  # %{color} in a plotly template is the color string, so the label text is built here
  change_text <- ifelse(is.na(change), "n/a", sprintf("%.2f%%", change))
  change[is.na(change)] <- 0
  n <- nrow(top)
  plotly::plot_ly(
    type = "treemap",
    ids = c("root", as.character(seq_len(n))),
    labels = c("Top 100", top$name_symbol),
    parents = c("", rep("root", n)),
    values = c(sum(market_cap), market_cap),
    branchvalues = "total",
    marker = list(
      colors = c(0, change),
      colorscale = colorscale_change,
      cmin = -limit,
      cmax = limit,
      showscale = TRUE
    ),
    text = c("", change_text),
    texttemplate = "%{label}<br>%{text}",
    # plotly picks label colors as if the page were white, which hides them in dark mode
    textfont = list(color = text_color(mode)),
    hovertemplate = "%{label}<br>Market cap: $%{value:,.0f}<br>24h: %{text}<extra></extra>"
  ) %>%
    plotly::layout(title = "Top 100 by market cap, colored by 24h change") %>%
    plot_theme(mode)
}
##########################################################################################
# 
##########################################################################################
#' @title Heatmap of monthly returns by year
#' @description Months are colored from red to green by their return. The color
#' limit is the 95th percentile of the absolute returns, so a few extreme
#' months do not wash out the rest.
#' @param calendar Matrix from [monthly_returns()].
#' @param label Label of the coin for the title, or `NULL` for none.
#' @inheritParams plot_timeseries
#' @return A plotly object.
#' @export
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' plot_returns_calendar(monthly_returns(btc), "Bitcoin (BTC)")
plot_returns_calendar <- function(calendar, label = NULL, mode = "light") {
  limit <- unname(stats::quantile(abs(calendar), .95, na.rm = TRUE))
  plotly::plot_ly(
    x = colnames(calendar),
    y = rownames(calendar),
    z = calendar,
    type = "heatmap",
    zmin = -limit,
    zmax = limit,
    colorscale = colorscale_change,
    hovertemplate = "%{x} %{y}<br>%{z:.2f}%<extra></extra>"
  ) %>%
    plotly::layout(
      title = paste(c("Monthly returns", label), collapse = ": "),
      # the grid would show through the faint and the empty months
      xaxis = list(title = "", showgrid = FALSE),
      yaxis = list(title = "", type = "category", showgrid = FALSE)
    ) %>%
    plot_theme(mode)
}
##########################################################################################
#
##########################################################################################
#' @title Volatility chart of a coin
#' @description Three panels. The upper one is the volatility of every
#' `month_days`-day period over the whole history, annualized, with its
#' median and 95th percentile: where the line is now shows how rough the
#' last month was. The middle one shows each of the last `days` days as a bar
#' of its move in the standard deviations the GARCH model expected for it,
#' red for falls and green for rises, with lines at 2 and 4 standard
#' deviations. The lower one shows the last `context_days` closes and the
#' forecast of the next days: the median close, and the ranges of the middle
#' half and of probability `level` (see [volatility_analysis()]). Without a
#' GARCH model only the upper panel is drawn.
#' @param analysis The result of [volatility_analysis()].
#' @param days Days of the middle panel.
#' @param context_days Closes before the forecast in the lower panel.
#' @inheritParams plot_timeseries
#' @return A plotly object.
#' @export
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' plot_volatility(volatility_analysis(btc))
plot_volatility <- function(analysis, mode = "light", days = 90, context_days = 30) {
  series <- analysis$series
  month <- analysis$settings$month_days
  volatility <- series[!is.na(series$volatility_month), ]
  level <- function(p, name, dash) {
    value <- stats::quantile(volatility$volatility_month, p)
    list(
      x = range(volatility$date), y = rep(value, 2), name = name,
      line = list(width = 1, dash = dash, color = average_colors[2]),
      hovertemplate = paste0(name, ": %{y:.1f}%<extra></extra>")
    )
  }
  upper <- plotly::plot_ly(
    x = volatility$date,
    y = volatility$volatility_month,
    type = "scatter",
    mode = "lines",
    line = list(width = 1, color = "#ff7f0e"),
    name = paste0(month, "-day volatility"),
    hovertemplate = paste0("%{x}<br>", month, "-day volatility: %{y:.1f}% a year<extra></extra>")
  )
  for (line in list(level(0.5, "Median", "dash"), level(0.95, "95th percentile", "dot"))) {
    upper <- do.call(plotly::add_lines, c(list(upper, inherit = FALSE), line))
  }
  upper <- plotly::layout(upper, yaxis = list(title = "% a year", ticksuffix = "%"), xaxis = list(title = ""))
  title <- paste0(analysis$coin, ": volatility")
  if (is.null(analysis$garch)) {
    return(plotly::layout(upper, title = list(text = title, x = 0.01, xanchor = "left"), legend = list(orientation = "h", x = 0.5, xanchor = "center")) %>%
      plot_theme(mode))
  }
  recent <- utils::tail(series[!is.na(series$garch_z), ], days)
  lower <- plotly::plot_ly(
    x = recent$date,
    y = recent$garch_z,
    type = "bar",
    marker = list(color = ifelse(recent$garch_z < 0, change_color(1, gain = FALSE), change_color(1, gain = TRUE))),
    customdata = recent$return_pct,
    name = "Daily move in GARCH standard deviations",
    hovertemplate = "%{x}<br>%{customdata:+.2f}%, %{y:+.1f} standard deviations<extra></extra>"
  )
  for (z in c(-4, -2, 2, 4)) {
    lower <- plotly::add_lines(lower,
      x = range(recent$date), y = c(z, z), inherit = FALSE, showlegend = FALSE, hoverinfo = "skip",
      line = list(width = 1, dash = if (abs(z) == 2) "dash" else "dot", color = text_color(mode))
    )
  }
  lower <- plotly::layout(lower, yaxis = list(title = paste("Last", days, "days, sd")), xaxis = list(title = ""))
  ahead <- plot_forecast(analysis, context_days)
  plotly::subplot(upper, lower, ahead, nrows = 3, heights = c(0.38, 0.31, 0.31), titleY = TRUE, margin = 0.05) %>%
    plotly::layout(
      title = list(text = title, x = 0.01, xanchor = "left"),
      # below the dates of the lower panel, which plotly would otherwise draw it over
      legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 0, yanchor = "bottom", yref = "container"),
      margin = list(b = 90),
      bargap = 0.2
    ) %>%
    plot_theme(mode)
}
##########################################################################################
#
##########################################################################################
#' @title Forecast panel of the volatility chart
#' @description The last closes and the forecast ranges of the next days,
#' which start from the last close, for [plot_volatility()]. Hover over the
#' median line for the ranges of a day.
#' @param analysis The result of [volatility_analysis()], with a forecast.
#' @param context_days Closes before the forecast.
#' @return A plotly object.
#' @keywords internal
#' @examples
#' \dontrun{
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' golemcrypto:::plot_forecast(volatility_analysis(btc), 30)
#' }
plot_forecast <- function(analysis, context_days) {
  level <- round(100 * analysis$settings$level)
  closes <- utils::tail(analysis$series, context_days)
  last <- utils::tail(closes, 1)
  # the ranges start from the last close
  columns <- c("low", "low_50", "median", "high_50", "high")
  start <- data.frame(date = last$date, matrix(last$close, 1, 5, dimnames = list(NULL, columns)))
  cone <- rbind(start, analysis$forecast$days[c("date", columns)])
  color <- average_colors[1]
  band <- function(alpha) sprintf("rgba(59,130,246,%s)", alpha)
  plotly::plot_ly(
    x = closes$date,
    y = closes$close,
    type = "scatter",
    mode = "lines",
    line = list(width = 1.5, color = color),
    name = "Close",
    hovertemplate = "%{x}<br>Close: $%{y:,.6~g}<extra></extra>"
  ) %>%
    plotly::add_ribbons(
      x = cone$date, ymin = cone$low, ymax = cone$high, inherit = FALSE,
      name = paste0(level, "% range"), fillcolor = band(0.15), line = list(width = 0), hoverinfo = "skip"
    ) %>%
    plotly::add_ribbons(
      x = cone$date, ymin = cone$low_50, ymax = cone$high_50, inherit = FALSE,
      name = "50% range", fillcolor = band(0.3), line = list(width = 0), hoverinfo = "skip"
    ) %>%
    plotly::add_lines(
      x = cone$date, y = cone$median, inherit = FALSE, name = "Forecast median",
      line = list(width = 1.5, dash = "dash", color = color),
      customdata = lapply(seq_len(nrow(cone)), function(i) unname(unlist(cone[i, c("low", "low_50", "high_50", "high")]))),
      hovertemplate = paste0(
        "%{x}<br>Median: $%{y:,.6~g}<br>50%: $%{customdata[1]:,.6~g} to $%{customdata[2]:,.6~g}<br>",
        level, "%: $%{customdata[0]:,.6~g} to $%{customdata[3]:,.6~g}<extra></extra>"
      )
    ) %>%
    plotly::layout(yaxis = list(title = "Next days, USD"), xaxis = list(title = ""))
}
##########################################################################################
#
##########################################################################################
#' @title Drawdown chart of a coin
#' @description Two panels over the whole history. The upper one is the
#' close on a log scale with the all-time high so far; the lower one is the
#' drawdown, how far each close is below that high (see [drawdown()]), with
#' a dashed line at `min_depth` percent. The falls of the analysis are shaded
#' from their peak to their recovery, the current one in amber, and their
#' troughs carry their rank, as in [drawdown_table()]; hover over a trough
#' for its dates.
#' @param analysis The result of [drawdown_analysis()].
#' @inheritParams plot_timeseries
#' @return A plotly object.
#' @export
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' plot_drawdowns(drawdown_analysis(btc))
plot_drawdowns <- function(analysis, mode = "light") {
  series <- analysis$series
  episodes <- analysis$episodes
  current <- "rgba(245,158,11,%s)"
  price <- plotly::plot_ly(
    x = series$date,
    y = series$close,
    type = "scatter",
    mode = "lines",
    line = list(width = 1, color = "#ff7f0e"),
    name = "close",
    hovertemplate = "%{x}<br>Close: $%{y:,.6~g}<extra></extra>"
  ) %>%
    plotly::add_lines(
      x = series$date,
      y = series$high,
      inherit = FALSE,
      line = list(width = 1, dash = "dot", color = text_color(mode)),
      name = "All-time high so far",
      hovertemplate = "%{x}<br>All-time high so far: $%{y:,.6~g}<extra></extra>"
    ) %>%
    plotly::layout(yaxis = list(title = "USD, log scale", type = "log"))
  under <- plotly::plot_ly(
    x = series$date,
    y = series$drawdown_pct,
    type = "scatter",
    mode = "lines",
    fill = "tozeroy",
    line = list(width = 1, color = change_color(1, gain = FALSE)),
    fillcolor = change_color(0.2, gain = FALSE),
    name = "From high",
    hovertemplate = "%{x}<br>From high: %{y:.1f}%<extra></extra>"
  ) %>%
    plotly::add_lines(
      x = range(series$date), y = rep(-analysis$min_depth, 2), inherit = FALSE, showlegend = FALSE, hoverinfo = "skip",
      line = list(width = 1, dash = "dash", color = text_color(mode))
    )
  shapes <- list()
  if (nrow(episodes) > 0) {
    end <- ifelse(episodes$ongoing, as.character(analysis$last_date), as.character(episodes$recovery_date))
    back <- ifelse(
      episodes$ongoing,
      paste0("not back at the high yet, ", fmt(episodes$days_total, 0), " days so far"),
      paste0("back at the high ", episodes$recovery_date, ", ", fmt(episodes$days_total, 0), " days after the peak")
    )
    under <- plotly::add_trace(under,
      x = episodes$trough_date,
      y = episodes$depth_pct,
      type = "scatter",
      mode = "markers+text",
      inherit = FALSE,
      text = episodes$rank,
      textposition = "bottom center",
      textfont = list(color = text_color(mode), size = 11),
      marker = list(size = 7, color = ifelse(episodes$ongoing, sprintf(current, 1), change_color(1, gain = FALSE))),
      name = paste0("Falls of ", analysis$min_depth, "% or more"),
      customdata = paste0(
        "#", episodes$rank, ": ", sprintf("%.1f", episodes$depth_pct), "%<br>",
        "peak ", episodes$peak_date, ", trough ", episodes$trough_date, "<br>", back
      ),
      hovertemplate = "%{customdata}<extra></extra>"
    )
    shapes <- lapply(seq_len(nrow(episodes)), function(i) {
      list(
        type = "rect", xref = "x", yref = "paper", x0 = as.character(episodes$peak_date[i]), x1 = end[i], y0 = 0, y1 = 1,
        fillcolor = if (episodes$ongoing[i]) sprintf(current, 0.15) else change_color(0.12, gain = FALSE),
        line = list(width = 0), layer = "below"
      )
    })
  }
  under <- plotly::layout(under, yaxis = list(title = "From high", ticksuffix = "%"))
  chart <- plotly::subplot(price, under, nrows = 2, heights = c(0.55, 0.45), shareX = TRUE, titleY = TRUE, margin = 0.03)
  # set directly: layout() merges with modifyList(), which drops a list of shapes without names
  chart$x$layout$shapes <- shapes
  chart %>%
    plotly::layout(
      title = list(text = paste0(analysis$coin, ": falls from the all-time high"), x = 0.01, xanchor = "left"),
      legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 0, yanchor = "bottom", yref = "container"),
      margin = list(b = 60),
      xaxis = list(title = "")
    ) %>%
    plot_theme(mode)
}
##########################################################################################
#
##########################################################################################
#' @title Table of the falls of a coin
#' @description A sortable table of the falls of [drawdown_analysis()], the
#' deepest first, with the numbers of the chart of [plot_drawdowns()]. The
#' fall is shaded red, more strongly the deeper it is, and the current fall,
#' which has not got back to its high, is in bold.
#' @param analysis The result of [drawdown_analysis()].
#' @return A DT datatable.
#' @export
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' drawdown_table(drawdown_analysis(btc))
drawdown_table <- function(analysis) {
  episodes <- analysis$episodes
  table <- data.frame(
    episodes$rank, episodes$peak_date, episodes$peak_price, episodes$trough_date, episodes$trough_price,
    episodes$depth_pct, episodes$days_to_trough, episodes$recovery_date, episodes$days_to_recover, episodes$days_total,
    episodes$ongoing
  )
  names(table) <- c(
    "#", "Peak", "High", "Trough", "Low", "Fall", "Days to trough", "Back at high", "Days to recover", "Days in all", "ongoing"
  )
  # prices of a few dollars and of fractions of a cent in one column, as in the text of the cards
  price <- DT::JS(
    "function(data, type) {",
    "  if (type !== 'display' || data === null) return data;",
    "  var x = Number(data);",
    "  if (x >= 1000) return '$' + x.toLocaleString('en-US', {maximumFractionDigits: 0});",
    "  if (x >= 1) return '$' + x.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});",
    "  return '$' + Number(x.toPrecision(4)).toLocaleString('en-US', {maximumSignificantDigits: 4});",
    "}"
  )
  # the dates and days a fall that goes on does not have yet
  missing <- function(text) DT::JS(sprintf("function(data, type) { return type === 'display' && data === null ? '%s' : data; }", text))
  days <- DT::JS(
    "function(data, type) {",
    "  if (type !== 'display') return data;",
    "  return data === null ? '\\u2013' : Number(data).toLocaleString('en-US');",
    "}"
  )
  DT::datatable(table,
    rownames = FALSE,
    selection = "none",
    options = list(
      dom = if (nrow(table) > 20) "tp" else "t",
      pageLength = 20,
      columnDefs = list(
        list(targets = c(2, 4), render = price),
        list(targets = 7, render = missing("not yet")),
        list(targets = c(6, 8, 9), render = days),
        list(targets = 10, visible = FALSE),
        list(targets = c(0, 2, 4:6, 8:9), className = "dt-right")
      )
    )
  ) %>%
    DT::formatCurrency("Fall", currency = "%", before = FALSE, digits = 1) %>%
    DT::formatStyle("Fall", backgroundColor = DT::styleInterval(
      seq(-90, -10, by = 10), change_color(seq(1, 0.1, length.out = 10), gain = FALSE)
    )) %>%
    DT::formatStyle(names(table), valueColumns = "ongoing", fontWeight = DT::styleEqual(TRUE, "bold"))
}
##########################################################################################
#
##########################################################################################
#' @title Seasonality chart of a coin
#' @description Two panels with a bar per group of [seasonality_analysis()].
#' The upper one shows the mean return, green above 0 and red below, with the
#' median as a diamond; the lower one shows the share of the returns above 0,
#' with a dashed line at 50%. Hover over a bar for all the numbers of its
#' group.
#' @param analysis The result of [seasonality_analysis()].
#' @inheritParams plot_timeseries
#' @return A plotly object.
#' @export
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' plot_seasonality(seasonality_analysis(btc, "month"))
#' plot_seasonality(seasonality_analysis(btc, "day"), mode = "dark")
plot_seasonality <- function(analysis, mode = "light") {
  groups <- analysis$groups
  words <- seasonality_periods[[analysis$period]]
  digits <- return_digits(analysis$period)
  # plotly reads week numbers as numbers, so the groups are text on a category axis
  x <- as.character(groups$group)
  number <- function(value) sprintf(paste0("%+.", digits, "f%%"), value)
  hover <- paste0(
    words$group, ": ", x, "<br>",
    "Mean: ", number(groups$mean_pct), "<br>",
    "Median: ", number(groups$median_pct), "<br>",
    "Up: ", round(groups$up_pct * groups$returns / 100), " of ", groups$returns, " (", sprintf("%.0f", groups$up_pct), "%)<br>",
    "Best: ", number(groups$best_pct), ", worst: ", number(groups$worst_pct)
  )
  returns <- plotly::plot_ly(
    x = x,
    y = groups$mean_pct,
    type = "bar",
    marker = list(color = ifelse(groups$mean_pct >= 0, change_color(1, gain = TRUE), change_color(1, gain = FALSE))),
    name = "Mean",
    customdata = hover,
    hovertemplate = "%{customdata}<extra></extra>"
  ) %>%
    plotly::add_trace(
      x = x,
      y = groups$median_pct,
      type = "scatter",
      mode = "markers",
      inherit = FALSE,
      marker = list(symbol = "diamond", size = 8, color = text_color(mode)),
      name = "Median",
      customdata = hover,
      hovertemplate = "%{customdata}<extra></extra>"
    ) %>%
    plotly::layout(yaxis = list(title = "Return", ticksuffix = "%"))
  up <- plotly::plot_ly(
    x = x,
    y = groups$up_pct,
    type = "bar",
    marker = list(color = ifelse(groups$up_pct >= 50, change_color(0.5, gain = TRUE), change_color(0.5, gain = FALSE))),
    name = "Share up",
    customdata = hover,
    hovertemplate = "%{customdata}<extra></extra>"
  ) %>%
    plotly::layout(yaxis = list(title = "Up", ticksuffix = "%", range = c(0, 100)))
  chart <- plotly::subplot(returns, up, nrows = 2, heights = c(0.6, 0.4), shareX = TRUE, titleY = TRUE, margin = 0.03)
  # set directly: layout() merges with modifyList(), which drops a list of shapes without names
  chart$x$layout$shapes <- list(list(
    type = "line", xref = "paper", x0 = 0, x1 = 1, yref = "y2", y0 = 50, y1 = 50,
    line = list(width = 1, dash = "dash", color = text_color(mode))
  ))
  chart %>%
    plotly::layout(
      title = list(text = paste0(analysis$coin, ": ", words$title), x = 0.01, xanchor = "left"),
      legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 0, yanchor = "bottom", yref = "container"),
      margin = list(b = 60),
      xaxis = list(title = "", type = "category", categoryorder = "array", categoryarray = x)
    ) %>%
    plot_theme(mode)
}
##########################################################################################
#
##########################################################################################
#' @title Table of the seasonality of a coin
#' @description A table with a row per group of [seasonality_analysis()], in
#' their natural order, with the numbers of the chart of
#' [plot_seasonality()]. The mean and the median are shaded red below 0 and
#' green above it, and the share up red below 50% and green above it, more
#' strongly the further they are from the middle.
#' @param analysis The result of [seasonality_analysis()].
#' @return A DT datatable.
#' @export
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' seasonality_table(seasonality_analysis(btc, "month"))
seasonality_table <- function(analysis) {
  groups <- analysis$groups
  digits <- return_digits(analysis$period)
  # week numbers sort as numbers when a header is clicked
  group <- if (analysis$period == "week") as.integer(as.character(groups$group)) else as.character(groups$group)
  table <- data.frame(group, groups$returns, groups$mean_pct, groups$median_pct, groups$up_pct, groups$best_pct, groups$worst_pct)
  names(table) <- c(seasonality_periods[[analysis$period]]$group, "Returns", "Mean", "Median", "Up", "Best", "Worst")
  # 5 shades on each side of the middle, up to the largest distance from it
  shade <- function(values, middle) {
    limit <- max(abs(values - middle), 1e-9)
    steps <- c(1, 0.8, 0.6, 0.4, 0.2)
    DT::styleInterval(
      middle + limit * seq(-0.9, 0.9, by = 0.2),
      c(change_color(steps, gain = FALSE), change_color(0, gain = TRUE), change_color(rev(steps), gain = TRUE))
    )
  }
  DT::datatable(table,
    rownames = FALSE,
    selection = "none",
    options = list(
      dom = "t",
      pageLength = nrow(table),
      # the natural order of the groups, not the alphabetical one
      order = list(),
      columnDefs = list(list(targets = 1:6, className = "dt-right"))
    )
  ) %>%
    DT::formatCurrency(c("Mean", "Median", "Best", "Worst"), currency = "%", before = FALSE, digits = digits) %>%
    DT::formatCurrency("Up", currency = "%", before = FALSE, digits = 0) %>%
    DT::formatStyle(c("Mean", "Median"), backgroundColor = shade(c(groups$mean_pct, groups$median_pct), 0)) %>%
    DT::formatStyle("Up", backgroundColor = shade(groups$up_pct, 50))
}
##########################################################################################
# 
##########################################################################################
#' @title Table of the market listings
#' @description A sortable table with 100 rows per page and numbers rounded 
#' to 2 decimals, showing the price in dollars and the price changes in 
#' percent. Losses are shaded red and gains green, more strongly the larger the
#' change, in steps of 0.1 percentile from the 5th to the 95th. Changes near
#' zero keep the table's own background, so the table suits the light and the
#' dark mode.
#' @param listings The `data` of [get_listings()].
#' @return A DT datatable.
#' @export
#' @examplesIf nzchar(Sys.getenv("COINMARKETCAP_APIKEY"))
#' listings_table(get_listings()$data)
listings_table <- function(listings) {
  names(listings) <- gsub("USD_|percent_", "", names(listings))
  listings <- data.frame(listings, check.names = FALSE)
  numeric_columns <- vapply(listings, is.numeric, logical(1))
  listings[numeric_columns] <- round(listings[numeric_columns], 2)

  change_columns <- c("change_24h", "change_7d", "change_30d", "change_60d", "change_90d")
  breaks <- stats::quantile(unlist(listings[change_columns]), probs = seq(.05, .95, .001), na.rm = TRUE)
  colors <- c(
    change_color(seq(1, 0, length.out = sum(breaks < 0)), gain = FALSE),
    change_color(seq(0, 1, length.out = sum(breaks >= 0) + 1), gain = TRUE)
  )

  DT::datatable(listings, options = list(
    stateSave = TRUE,
    pageLength = 100,
    lengthMenu = list(c(20, 50, 100, -1), c("20", "50", "100", "All"))
  )) %>%
    DT::formatStyle(change_columns, backgroundColor = DT::styleInterval(breaks, colors)) %>%
    DT::formatCurrency("price", currency = "$", digits = 4) %>%
    DT::formatCurrency(change_columns, currency = "%", before = FALSE, digits = 2)
}
