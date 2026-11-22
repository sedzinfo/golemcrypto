# Changelog

## golemcrypto 0.1.0

### Breaking changes

- The package is called golemcrypto instead of crypto: install and load
  it as
  [`library(golemcrypto)`](https://sedzinfo.github.io/golemcrypto/).
- The app starts with
  [`run_app()`](https://sedzinfo.github.io/golemcrypto/reference/run_app.md),
  the name golem apps use and the one of golemstockindices, instead of
  `crypto()`:
  [`golemcrypto::run_app()`](https://sedzinfo.github.io/golemcrypto/reference/run_app.md).
  `crypto()` is gone.
- [`run_app()`](https://sedzinfo.github.io/golemcrypto/reference/run_app.md)
  needs your own CoinMarketCap API key, set in the
  `COINMARKETCAP_APIKEY` environment variable (for example in
  `.Renviron`) or passed as `run_app(api_key = )`. The package no longer
  comes with a key. See the README for how to get a free one.
- [`library(golemcrypto)`](https://sedzinfo.github.io/golemcrypto/) no
  longer attaches shiny, plotly, crypto2, coinmarketcapr and
  shinyWidgets. Load them yourself if your code uses their functions.

### New features

- Six new tabs:
  - **Compare** plots up to 10 coins from a chosen start date, each
    starting at 100, with a linear or log scale.
  - **Treemap** shows the top 100 coins sized by market cap and colored
    by their 24h change.
  - **Returns calendar** shows the monthly returns, by year, of the coin
    selected in the Timeseries tab.
  - **Seasonality** asks whether some days of the week, weeks of the
    year, months or years of Bitcoin’s 4-year halving cycle bring the
    coin selected in the Timeseries tab better returns than others. Two
    cards name the best and the worst group, by their mean and median
    return and how often they rose, and say whether the differences
    could be chance, with a Kruskal-Wallis test. A chart shows the mean
    and median return of each group and the share of its returns that
    were gains, and a table lists the groups. Only complete periods
    count.
    [`seasonal_returns()`](https://sedzinfo.github.io/golemcrypto/reference/seasonal_returns.md),
    [`seasonality_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/seasonality_analysis.md),
    [`seasonality_text()`](https://sedzinfo.github.io/golemcrypto/reference/seasonality_text.md),
    [`plot_seasonality()`](https://sedzinfo.github.io/golemcrypto/reference/plot_seasonality.md)
    and
    [`seasonality_table()`](https://sedzinfo.github.io/golemcrypto/reference/seasonality_table.md)
    do the same from R.
  - **Drawdowns** says how far the coin selected in the Timeseries tab
    is below its all-time high, the rise it needs to get back there, and
    how long its earlier falls that went as deep took to recover. A
    chart shows the close on a log scale and the distance from the high,
    with each fall of 10%, 20%, 30%, 40% or 50% or more shaded and
    numbered, and a table lists those falls with their peak, trough,
    depth and days.
    [`drawdown_episodes()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_episodes.md),
    [`drawdown_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_analysis.md),
    [`drawdown_text()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_text.md),
    [`plot_drawdowns()`](https://sedzinfo.github.io/golemcrypto/reference/plot_drawdowns.md)
    and
    [`drawdown_table()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_table.md)
    do the same from R.
  - **Volatility** says in words whether the volatility of the last 30
    days and the move of the last 2 days of the coin selected in the
    Timeseries tab are normal: against the year before, against the
    coin’s whole history, and against a GARCH(1,1) model with Student-t
    errors. It also says whether the volume of the 2 days is unusual for
    the coin, against the median of the 30 days before each. A third
    card forecasts the next 7 days with the same model: the 95% range of
    the price and the value at risk and expected shortfall of the next
    day, beside those of the last year, with a Kupiec test of how well
    the model’s value at risk held. A chart shows the 30-day volatility
    over the whole history, the last 90 days in the standard deviations
    the model expected, and the forecast of the price. Two pickers above
    the chart measure the volatility over 7, 14, 60 or 90 days instead
    of 30, and the recent move over 1, 3 or 7 days instead of 2; the
    volume is still compared with the 30 days before.
    [`volatility_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/volatility_analysis.md),
    [`volatility_text()`](https://sedzinfo.github.io/golemcrypto/reference/volatility_text.md)
    and
    [`plot_volatility()`](https://sedzinfo.github.io/golemcrypto/reference/plot_volatility.md)
    do the same from R; the model is fitted in base R, with no new
    dependency.
- An **About** tab explains what every tab shows and how its numbers are
  calculated, with the formulas: the candles, moving averages and
  drawdown of the Timeseries tab, the index of the Compare tab, the
  columns of the Top 100 table and the colors of the tables and charts.
  It also explains linear and log scales, with an example chart, and
  when a log scale helps.
- The Timeseries chart shows the 50- and 200-day moving averages, and a
  drawdown chart of how far the price is below its all-time high.
  [`moving_average()`](https://sedzinfo.github.io/golemcrypto/reference/moving_average.md)
  and
  [`drawdown()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown.md)
  compute them, and
  [`plot_timeseries()`](https://sedzinfo.github.io/golemcrypto/reference/plot_timeseries.md)
  gained the `averages` and `show_drawdown` arguments. Its vertical axes
  follow the days in view, so the candles of a zoomed-in week fill the
  chart instead of lying flat, and Linear and Log buttons switch the
  axis of the prices.
- The app has a name, a Bootstrap 5 theme, a favicon and a light/dark
  mode toggle. The charts and the Top 100 table follow the mode: price
  changes are shaded in a red and a green that fade into the page, so
  values near zero no longer show as white cells in dark mode.
- Every tab has a CSV button that downloads the data behind it: the
  coin’s daily prices, the listings, the normalized prices, the treemap
  data and the monthly returns.
- Charts show a loading spinner while their data downloads.
- The Top 100 listings refresh every 10 minutes and show when they were
  last updated.
- The data, calculations and charts of the app can be used directly from
  R:
  [`get_coins()`](https://sedzinfo.github.io/golemcrypto/reference/get_coins.md),
  [`get_history()`](https://sedzinfo.github.io/golemcrypto/reference/get_history.md),
  [`get_listings()`](https://sedzinfo.github.io/golemcrypto/reference/get_listings.md),
  [`normalize_prices()`](https://sedzinfo.github.io/golemcrypto/reference/normalize_prices.md),
  [`monthly_returns()`](https://sedzinfo.github.io/golemcrypto/reference/monthly_returns.md),
  [`plot_timeseries()`](https://sedzinfo.github.io/golemcrypto/reference/plot_timeseries.md),
  [`plot_compare()`](https://sedzinfo.github.io/golemcrypto/reference/plot_compare.md),
  [`plot_returns_calendar()`](https://sedzinfo.github.io/golemcrypto/reference/plot_returns_calendar.md),
  [`plot_treemap()`](https://sedzinfo.github.io/golemcrypto/reference/plot_treemap.md)
  and
  [`listings_table()`](https://sedzinfo.github.io/golemcrypto/reference/listings_table.md).
- Price histories and the list of coins are kept on disk between R
  sessions. After the first download of a coin, only the days since the
  last download are fetched, so charts appear faster and the app makes
  far fewer requests to CoinMarketCap. Set
  `options(crypto.cache_dir = )` to keep the downloads in another
  folder.
- `run_app(analytics = TRUE)` adds Google Analytics, through the cookie
  banner of the sedzinfo.github.io sites, which loads it only after the
  visitor accepts. The tabs and the CSV downloads are reported as pages
  and downloads. It is off by default and on in `app.R`, the file used
  to deploy the app on shinyapps.io.
- [`run_app()`](https://sedzinfo.github.io/golemcrypto/reference/run_app.md)
  passes further arguments on to
  [`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html),
  for example `run_app(options = list(port = 8080))`.
- **Timeseries** can add the 20-day Bollinger bands and a panel of the
  14-day RSI, from two boxes above the chart.
  [`bollinger_bands()`](https://sedzinfo.github.io/golemcrypto/reference/bollinger_bands.md),
  [`rsi()`](https://sedzinfo.github.io/golemcrypto/reference/rsi.md) and
  `plot_timeseries(bollinger = , show_rsi = )` do the same from R.
- **Compare** can show the coins relative to one of them, picked under
  “Relative to”: the ratio of their lines, so a line that rises beat the
  base, and Ethereum relative to Bitcoin is the ETH/BTC ratio.
  [`relative_prices()`](https://sedzinfo.github.io/golemcrypto/reference/relative_prices.md)
  does the same from R, and `plot_compare(base = )` draws it.
- **Seasonality** also tests three calendar effects of the stock market
  against the rest: the turn of the month (the last day of a month and
  the first 3 of the next), the Santa rally (the last 5 days of December
  and the first 2 of January) and Sell in May (May to October against
  November to April).
  [`effect_days()`](https://sedzinfo.github.io/golemcrypto/reference/effect_days.md)
  puts the days in or out of an effect.

### Bug fixes and smaller changes

- A failed download shows a short message, such as “Data not available
  for this coin”, instead of an R error.
- The app no longer stops at start when the market listings cannot be
  downloaded, for example when the API key has used up its CoinMarketCap
  credits. The Top 100 and Treemap tabs say why instead, and when the
  credits reset, the other tabs work as usual, and the download is tried
  again every 10 minutes.
  [`get_listings()`](https://sedzinfo.github.io/golemcrypto/reference/get_listings.md)
  returns why in its new `problem` element instead of an error.
- The keep-alive pings now get an answer from the server, so idle
  connections stay open behind proxies. `run_app(keep_alive = FALSE)`
  turns them off, as `app.R` does, so that the app can go to sleep on
  shinyapps.io when nobody uses it.
- Small prices are no longer shown in scientific notation, and the app
  no longer changes the options of your R session to do so.
- Treemap labels show the 24h change instead of NaN.
- The date range buttons of the Timeseries chart are readable in dark
  mode.
- Bitcoin’s full history no longer triggers a warning about dates before
  2013-04-29.
- A download that misses days, which can happen when CoinMarketCap
  limits requests, is not kept, so the next request downloads it again.

### Internal

- The code follows a golem-style layout, with one Shiny module per tab.
- Every function has a help page.
- Tests run offline, and R CMD check runs on GitHub Actions for every
  push.
