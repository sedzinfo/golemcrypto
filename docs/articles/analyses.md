# Volatility, drawdowns and seasonality

The Volatility, Drawdowns and Seasonality tabs of the [golemcrypto
app](https://sedzinfo-golemcrypto.share.connect.posit.cloud/) work the
same way in R. An `_analysis()` function does the calculations, and its
result goes to three functions:

- `_text()` sums it up in sentences, as the app does above its charts;
- `plot_` draws its chart;
- `_table()`, for drawdowns and seasonality, shows its numbers as a
  sortable table.

All three analyses compare the present with a coin’s past, so pass them
the whole history. [Price charts in
R](https://sedzinfo.github.io/golemcrypto/articles/golemcrypto.md) shows
how to find coins and download their prices.

``` r

library(golemcrypto)
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
```

## Volatility

[`volatility_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/volatility_analysis.md)
asks whether the volatility of the last 30 days, and the move of the
last 2 days, are normal for the coin. It compares them with the coin’s
history and with a GARCH(1,1) model, and forecasts the next 7 days. It
needs more than a year of history.

``` r

analysis <- volatility_analysis(btc)
volatility_text(analysis)$month
#> $headline
#> [1] "Volatility of the last 30 days: normal"
#> 
#> $points
#> [1] "44.7% a year, against 44.2% in the year before and a median of 55.7% for all 30-day periods since 2013: the 31st percentile."             
#> [2] "No significant difference from the year before (variance ratio 1.02, p = 0.44 and 0.62)."                                                 
#> [3] "The largest day, 14 Nov (−6.04%), was 2.7 standard deviations of the year before: common, as days that large come about 8.6 times a year."
#> [4] "The return of the 30 days, −23.0%, is in the 6th percentile of all 30-day periods: a weak month."
```

[`volatility_text()`](https://sedzinfo.github.io/golemcrypto/reference/volatility_text.md)
has two more parts, `$recent` for the last 2 days and `$forecast` for
the next 7. The numbers behind the sentences are in the analysis, such
as the forecast ranges of the next closes:

``` r

analysis$forecast$days
#>         date    sigma      low   low_50   median  high_50     high
#> 1 2026-11-19 2.924955 59674.95 62183.07 63013.23 63854.48 66538.26
#> 2 2026-11-20 2.941630 58401.23 61774.04 63032.07 64341.63 68078.73
#> 3 2026-11-21 2.958069 57375.96 61446.64 63051.09 64713.21 69442.10
#> 4 2026-11-22 2.974278 56560.84 61198.75 63114.77 65070.85 70473.61
#> 5 2026-11-23 2.990261 55823.03 60965.57 63142.59 65363.38 71400.16
#> 6 2026-11-24 3.006024 55075.36 60748.83 63168.15 65637.13 72273.95
#> 7 2026-11-25 3.021572 54529.33 60583.75 63201.90 65902.26 73072.94
```

[`plot_volatility()`](https://sedzinfo.github.io/golemcrypto/reference/plot_volatility.md)
draws three panels:

- the volatility of every 30-day period of the history, with its median
  and 95th percentile;
- each of the last 90 days, as its move in the standard deviations the
  GARCH model expected;
- the last 30 closes, followed by the forecast.

``` r

plot_volatility(analysis)
```

The arguments of
[`volatility_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/volatility_analysis.md)
change the periods. For example, `month_days = 7` and `recent_days = 1`
ask about the last week and the last day:

``` r

week <- volatility_analysis(btc, month_days = 7, recent_days = 1)
volatility_text(week)$month$headline
#> [1] "Volatility of the last 7 days: normal"
volatility_text(week)$recent$headline
#> [1] "Last day, 18 Nov: −2.9%, a normal fall"
```

[`plot_volatility()`](https://sedzinfo.github.io/golemcrypto/reference/plot_volatility.md)
takes `days` for the days of the middle panel and `context_days` for the
closes before the forecast.

## Drawdowns

[`drawdown_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_analysis.md)
measures how far the coin is below its all-time high, and lists its
earlier falls of 20% or more with how long they took to recover:

``` r

falls <- drawdown_analysis(btc)
drawdown_text(falls)$now
#> $headline
#> [1] "Now: −49.5% from the all-time high, in its 5th deepest fall"
#> 
#> $points
#> [1] "The all-time high: $124,753 on 6 Oct 2025, 408 days ago. The lowest close since: $58,559 on 30 Jun 2026, −53.1%."                                                                                                
#> [2] "Back to the high takes a rise of +98.1% from the last close of $62,987."                                                                                                                                         
#> [3] "Earlier falls as deep as −53.1% or deeper: 4. They got back to their high 189 to 1,127 days (median 964) after the peak, and 91 to 721 days (median 592) after the trough. This fall has lasted 408 days so far."
```

The falls are in `falls$episodes`, the deepest first. A fall that has
not got back to its high yet is marked `ongoing`:

``` r

columns <- c("peak_date", "trough_date", "depth_pct", "recovery_date", "days_total", "ongoing")
head(falls$episodes[, columns])
#>    peak_date trough_date depth_pct recovery_date days_total ongoing
#> 1 2013-12-04  2015-01-14 -84.52852    2017-01-04       1127   FALSE
#> 2 2017-12-16  2018-12-15 -83.39901    2020-11-30       1080   FALSE
#> 3 2021-11-08  2022-11-21 -76.63456    2024-03-04        847   FALSE
#> 4 2021-04-13  2021-07-20 -53.06185    2021-10-19        189   FALSE
#> 5 2025-10-06  2026-06-30 -53.05998          <NA>        408    TRUE
#> 6 2013-04-29  2013-07-05 -52.65601    2013-10-15        169   FALSE
```

[`plot_drawdowns()`](https://sedzinfo.github.io/golemcrypto/reference/plot_drawdowns.md)
draws the close on a log scale with the all-time high so far, and under
it the drawdown. The falls are shaded from their peak to their recovery,
and their troughs are numbered by depth:

``` r

plot_drawdowns(falls)
```

[`drawdown_table()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_table.md)
shows the same falls as a sortable table:

``` r

drawdown_table(falls)
```

To list smaller falls as well, lower `min_depth`, for example
`drawdown_analysis(btc, min_depth = 10)`.

## Seasonality

[`seasonality_analysis()`](https://sedzinfo.github.io/golemcrypto/reference/seasonality_analysis.md)
asks whether some periods bring better returns than others. The period
is one of:

- `"day"`, the days of the week;
- `"week"`, the weeks of the year;
- `"month"`, the months;
- `"year"`, the years of the four-year halving cycle of Bitcoin.

A Kruskal-Wallis test then asks whether the differences could be chance.

``` r

months <- seasonality_analysis(btc, "month")
text <- seasonality_text(months)
text$groups$headline
#> [1] "Best month: November, mean +41.8%; worst: September, −2.5%"
text$chance$headline
#> [1] "The differences between the months could well be chance (p = 0.35)"
```

The `$points` of each part give the details, such as the p-value of the
test and how many months it compared.

[`plot_seasonality()`](https://sedzinfo.github.io/golemcrypto/reference/plot_seasonality.md)
shows the mean return of each group, with the median as a diamond, and
under it the share of returns above 0. Hover over a bar for all the
numbers of its group:

``` r

plot_seasonality(months)
```

[`seasonality_table()`](https://sedzinfo.github.io/golemcrypto/reference/seasonality_table.md)
shows the numbers as a table:

``` r

seasonality_table(months)
```

The other periods work the same way, for example the days of the week:

``` r

plot_seasonality(seasonality_analysis(btc, "day"))
```

## Dark mode and saving

Like the price charts, every `plot_` function takes `mode = "dark"` for
a dark page. The charts are plotly objects, and the tables are DT
tables, so
[`htmlwidgets::saveWidget()`](https://rdrr.io/pkg/htmlwidgets/man/saveWidget.html)
saves any of them as a web page:

``` r

htmlwidgets::saveWidget(plot_drawdowns(falls), "drawdowns.html")
htmlwidgets::saveWidget(drawdown_table(falls), "drawdowns_table.html")
```
