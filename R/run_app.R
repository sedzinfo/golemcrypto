##########################################################################################
# 
##########################################################################################
#' @title Launch the Crypto Time Series Analyzer
#' @description Starts an interactive 'shiny' application for exploring
#'   cryptocurrency exchange rates and market data from 'CoinMarketCap'.
#' @details The application has the following tabs:
#'   \describe{
#'     \item{Timeseries}{Candlestick chart of daily open, high, low and close
#'       prices in USD since 2013 for any active cryptocurrency, with its 50-
#'       and 200-day moving averages, optional Bollinger bands and relative
#'       strength index, and charts of the volume and of the drawdown (how
#'       far the price is below its all-time high) underneath.}
#'     \item{Top 100}{Table of the top 100 cryptocurrencies by market cap with
#'       price, volume, 24h to 90d price changes, market dominance and fully
#'       diluted market cap.}
#'     \item{Compare}{Close prices of up to 10 coins, normalized to 100 on the
#'       first date all of them have data, or relative to one of them.}
#'     \item{Treemap}{Top 100 coins sized by market cap and colored by 24h
#'       change.}
#'     \item{Returns calendar}{Monthly returns by year for the coin selected
#'       in the Timeseries tab.}
#'     \item{Seasonality}{The returns of the coin selected in the Timeseries
#'       tab by day of the week, week of the year, month or year of the
#'       halving cycle, or a calendar effect of the stock market against the
#'       rest (the turn of the month, the Santa rally or Sell in May), with a
#'       test of whether the differences could be chance.}
#'     \item{Volatility}{Whether the volatility of the last weeks and the
#'       move of the last days of the coin are normal, and a GARCH forecast of
#'       the next days with the value at risk.}
#'     \item{Drawdowns}{How far the coin is below its all-time high, and how
#'       deep its earlier falls went and how long they took to recover.}
#'     \item{About}{What every tab shows, and how its numbers are
#'       calculated.}
#'   }
#'   Market listings are downloaded when the app starts and refreshed every 10
#'   minutes. When they cannot be downloaded, for example because the API key
#'   has used up its credits, the app still starts, and the Top 100 and
#'   Treemap tabs tell the visitors why and when the limit resets. Historical prices are downloaded on demand with
#'   [crypto2::crypto_history()] and kept on disk between R sessions, so
#'   after the first download only the days since the last one are fetched.
#'   An internet connection is required. When 'CoinMarketCap' limits the requests,
#'   crypto2 prints "Retrying in 60 seconds" and the chart appears about a
#'   minute later.
#' @param api_key A 'CoinMarketCap' API key, needed for the market listings.
#'   By default it is read from the `COINMARKETCAP_APIKEY` environment
#'   variable, which can be set in `.Renviron`.
#' @param analytics `TRUE` to add Google Analytics, through the cookie banner
#'   shared with the sites of sedzinfo.github.io, which loads it only after the
#'   visitor accepts. Meant for the public deployment (see `app.R`); off by
#'   default, so that running the app yourself sends nothing.
#' @param keep_alive `TRUE` (the default) to ping the server every 15 seconds
#'   while the page is open, so that proxies do not close idle connections.
#'   `FALSE` lets the app go to sleep when nobody uses it, as `app.R` does on
#'   shinyapps.io, where an app that stays awake uses up the active hours of
#'   the plan.
#' @param ... Further arguments passed to [shiny::shinyApp()], for example
#'   `options = list(port = 8080)`.
#' @return A [shiny::shinyApp()] object. Printing it, or calling `run_app()` at
#'   the console, opens the app in the browser.
#' @import shiny
#' @importFrom plotly %>%
#' @keywords crypto timeseries
#' @export
#' @examples
#' if (interactive()) run_app()
#'
#' # with the API key passed directly, on a fixed port
#' if (interactive()) run_app(api_key = "your-api-key", options = list(port = 8080))
run_app <- function(api_key = Sys.getenv("COINMARKETCAP_APIKEY"), analytics = FALSE, keep_alive = TRUE, ...) {
  use_api_key(api_key)
  coins <- get_coins()
  top_coins <- get_listings()$data$name_symbol
  # without the listings, the Compare tab starts with the two largest coins
  if (is.null(top_coins)) {
    top_coins <- c("Bitcoin (BTC)", "Ethereum (ETH)")
  }

  shinyApp(
    ui = app_ui(coins, top_coins, analytics, keep_alive),
    server = app_server(coins),
    onStart = function() {
      # show small prices in full rather than as 1e-05, for this app run only
      old <- options(scipen = 999)
      onStop(function() options(old))
    },
    ...
  )
}
