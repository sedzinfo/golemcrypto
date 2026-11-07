# crypto 0.1.0

## Breaking changes

* `crypto()` needs your own CoinMarketCap API key, set in the `COINMARKETCAP_APIKEY` environment variable (for example in `.Renviron`) or passed as `crypto(api_key = )`. The package no longer comes with a key. See the README for how to get a free one.
* `library(crypto)` no longer attaches shiny, plotly, crypto2, coinmarketcapr and shinyWidgets. Load them yourself if your code uses their functions.

## New features

* Six new tabs:
  * **Compare** plots up to 10 coins from a chosen start date, each starting at 100, with a linear or log scale.
  * **Treemap** shows the top 100 coins sized by market cap and colored by their 24h change.
  * **Returns calendar** shows the monthly returns, by year, of the coin selected in the Timeseries tab.
  * **Seasonality** asks whether some days of the week, weeks of the year, months or years of Bitcoin's 4-year halving cycle bring the coin selected in the Timeseries tab better returns than others. Two cards name the best and the worst group, by their mean and median return and how often they rose, and say whether the differences could be chance, with a Kruskal-Wallis test. A chart shows the mean and median return of each group and the share of its returns that were gains, and a table lists the groups. Only complete periods count. `seasonal_returns()`, `seasonality_analysis()`, `seasonality_text()`, `plot_seasonality()` and `seasonality_table()` do the same from R.
  * **Drawdowns** says how far the coin selected in the Timeseries tab is below its all-time high, the rise it needs to get back there, and how long its earlier falls that went as deep took to recover. A chart shows the close on a log scale and the distance from the high, with each fall of 10%, 20%, 30% or 50% or more shaded and numbered, and a table lists those falls with their peak, trough, depth and days. `drawdown_episodes()`, `drawdown_analysis()`, `drawdown_text()`, `plot_drawdowns()` and `drawdown_table()` do the same from R.
  * **Volatility** says in words whether the volatility of the last 30 days and the move of the last 2 days of the coin selected in the Timeseries tab are normal: against the year before, against the coin's whole history, and against a GARCH(1,1) model with Student-t errors. It also says whether the volume of the 2 days is unusual for the coin, against the median of the 30 days before each. A third card forecasts the next 7 days with the same model: the 95% range of the price and the value at risk and expected shortfall of the next day, beside those of the last year, with a Kupiec test of how well the model's value at risk held. A chart shows the 30-day volatility over the whole history, the last 90 days in the standard deviations the model expected, and the forecast of the price. Two pickers above the cards measure the volatility over 7, 14, 60 or 90 days instead of 30, and the recent move over 1, 3 or 7 days instead of 2; the volume is still compared with the 30 days before. `volatility_analysis()`, `volatility_text()` and `plot_volatility()` do the same from R; the model is fitted in base R, with no new dependency.
* An **About** tab explains what every tab shows and how its numbers are calculated, with the formulas: the candles, moving averages and drawdown of the Timeseries tab, the index of the Compare tab, the columns of the Top 100 table and the colors of the tables and charts. It also explains linear and log scales, with an example chart, and when a log scale helps.
* The Timeseries chart shows the 50- and 200-day moving averages, and a drawdown chart of how far the price is below its all-time high. `moving_average()` and `drawdown()` compute them, and `plot_timeseries()` gained the `averages` and `show_drawdown` arguments.
* The app has a name, a Bootstrap 5 theme, a favicon and a light/dark mode toggle. The charts and the Top 100 table follow the mode: price changes are shaded in a red and a green that fade into the page, so values near zero no longer show as white cells in dark mode.
* Every tab has a CSV button that downloads the data behind it: the coin's daily prices, the listings, the normalized prices, the treemap data and the monthly returns.
* Charts show a loading spinner while their data downloads.
* The Top 100 listings refresh every 10 minutes and show when they were last updated.
* The data, calculations and charts of the app can be used directly from R: `get_coins()`, `get_history()`, `get_listings()`, `normalize_prices()`, `monthly_returns()`, `plot_timeseries()`, `plot_compare()`, `plot_returns_calendar()`, `plot_treemap()` and `listings_table()`.
* Price histories and the list of coins are kept on disk between R sessions. After the first download of a coin, only the days since the last download are fetched, so charts appear faster and the app makes far fewer requests to CoinMarketCap. Set `options(crypto.cache_dir = )` to keep the downloads in another folder.
* `crypto(analytics = TRUE)` adds Google Analytics, through the cookie banner of the sedzinfo.github.io sites, which loads it only after the visitor accepts. The tabs and the CSV downloads are reported as pages and downloads. It is off by default and on in `app.R`, the file used to deploy the app on shinyapps.io.
* `crypto()` passes further arguments on to `shiny::shinyApp()`, for example `crypto(options = list(port = 8080))`.

## Bug fixes and smaller changes

* A failed download shows a short message, such as "Data not available for this coin", instead of an R error.
* The app no longer stops at start when the market listings cannot be downloaded, for example when the API key has used up its CoinMarketCap credits. The Top 100 and Treemap tabs say why instead, and when the credits reset, the other tabs work as usual, and the download is tried again every 10 minutes. `get_listings()` returns why in its new `problem` element instead of an error.
* The keep-alive pings now get an answer from the server, so idle connections stay open behind proxies. `crypto(keep_alive = FALSE)` turns them off, as `app.R` does, so that the app can go to sleep on shinyapps.io when nobody uses it.
* Small prices are no longer shown in scientific notation, and the app no longer changes the options of your R session to do so.
* Treemap labels show the 24h change instead of NaN.
* The date range buttons of the Timeseries chart are readable in dark mode.
* Bitcoin's full history no longer triggers a warning about dates before 2013-04-29.
* A download that misses days, which can happen when CoinMarketCap limits requests, is not kept, so the next request downloads it again.

## Internal

* The code follows a golem-style layout, with one Shiny module per tab.
* Every function has a help page.
* Tests run offline, and R CMD check runs on GitHub Actions for every push.
