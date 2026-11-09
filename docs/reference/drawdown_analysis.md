# Drawdown analysis of a coin

How far is the coin below its all-time high, and how does that compare
with its earlier falls? See
[`drawdown_episodes()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_episodes.md)
for how the falls are found.

**Now**: the last close against the all-time high, the lowest close
since that high, the rise the price needs to get back to it, and the
earlier falls that went at least as deep as the current one has so far:
how many days they took to get back to their high.

**The history**: the falls of at least `min_depth` percent, the deepest
first, the share of days that closed that far below the high, and the
days that closed at a new all-time high.

## Usage

``` r
drawdown_analysis(history, min_depth = 20)
```

## Arguments

- history:

  Price history of one coin from
  [`get_history()`](https://sedzinfo.github.io/golemcrypto/reference/get_history.md),
  with all of it: the highs are those of the history given.

- min_depth:

  Smallest fall of the history to list, in percent below the high.

## Value

`NULL` when there are fewer than 2 prices, or a list with:

- coin, first_date, last_date, min_depth:

  What was analysed.

- now:

  `date` and `close` of the last day, `drawdown_pct`, `high_date` and
  `high_price` of the all-time high, `days_since_high`, and
  `rise_needed_pct` to get back to it. While the price is below the high
  also `low_date` and `low_price`, the lowest close since the high,
  `deepest_pct` how far that is below it, `rank` of the current fall
  among all the falls of the history by that depth, 1 for the deepest,
  and `earlier`, the earlier falls at least as deep, as rows of
  [`drawdown_episodes()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_episodes.md).
  At the high, `previous` holds the last fall of at least `min_depth`
  percent, or no rows.

- episodes:

  The falls of at least `min_depth` percent from
  [`drawdown_episodes()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_episodes.md),
  with their `rank` in front, 1 for the deepest.

- series:

  A row per day: `date`, `close`, `high` (the all-time high so far) and
  `drawdown_pct` (see
  [`drawdown()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown.md)).

- share_under:

  Percent of the days that closed at least `min_depth` percent below the
  high.

- new_highs:

  Days that closed at a new all-time high, the first day of the history
  left out.

## Examples

``` r
btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#> ❯ Scraping historical crypto data
#> 
#> ❯ Processing historical crypto data
#> 
analysis <- drawdown_analysis(btc)
analysis$now$drawdown_pct
#> [1] -39.28173
analysis$episodes
#>    rank  peak_date peak_price trough_date trough_price depth_pct days_to_trough recovery_date days_to_recover days_total ongoing
#> 1     1 2013-12-04    1151.17  2015-01-14      178.103 -84.52852            406    2017-01-04             721       1127   FALSE
#> 2     2 2017-12-16   19497.40  2018-12-15     3236.762 -83.39901            364    2020-11-30             716       1080   FALSE
#> 3     3 2021-11-08   67566.83  2022-11-21    15787.284 -76.63456            378    2024-03-04             469        847   FALSE
#> 4     4 2021-04-13   63503.46  2021-07-20    29807.348 -53.06185             98    2021-10-19              91        189   FALSE
#> 5     5 2025-10-06  124752.53  2026-06-30    58558.858 -53.05998            267          <NA>              NA        397    TRUE
#> 6     6 2013-04-29     144.54  2013-07-05       68.431 -52.65601             67    2013-10-15             102        169   FALSE
#> 7     7 2017-09-01    4892.01  2017-09-14     3154.950 -35.50810             13    2017-10-12              28         41   FALSE
#> 8     8 2017-06-11    2958.11  2017-07-16     1929.820 -34.76173             35    2017-08-05              20         55   FALSE
#> 9     9 2017-01-04    1154.73  2017-01-11      777.757 -32.64598              7    2017-02-23              43         50   FALSE
#> 10   10 2025-01-21  106146.26  2025-04-08    76271.950 -28.14448             77    2025-05-18              40        117   FALSE
#> 11   11 2017-03-03    1274.99  2017-03-24      937.520 -26.46844             21    2017-04-26              33         54   FALSE
#> 12   12 2024-03-13   73083.50  2024-09-06    53948.752 -26.18204            177    2024-11-06              61        238   FALSE
#> 13   13 2021-01-08   40797.61  2021-01-27    30432.547 -25.40606             19    2021-02-08              12         31   FALSE
#> 14   14 2021-02-21   57539.94  2021-02-28    45137.770 -21.55402              7    2021-03-11              11         18   FALSE
#> 15   15 2017-11-08    7459.69  2017-11-12     5950.070 -20.23704              4    2017-11-16               4          8   FALSE
drawdown_text(analysis)
#> $now
#> $now$headline
#> [1] "Now: −39.3% from the all-time high, in its 5th deepest fall"
#> 
#> $now$points
#> [1] "The all-time high: $124,753 on 6 Oct 2025, 397 days ago. The lowest close since: $58,559 on 30 Jun 2026, −53.1%."                                                                                                
#> [2] "Back to the high takes a rise of +64.7% from the last close of $75,748."                                                                                                                                         
#> [3] "Earlier falls as deep as −53.1% or deeper: 4. They got back to their high 189 to 1,127 days (median 964) after the peak, and 91 to 721 days (median 592) after the trough. This fall has lasted 397 days so far."
#> 
#> 
#> $history
#> $history$headline
#> [1] "Since 29 Apr 2013: 15 falls of 20% or more"
#> 
#> $history$points
#> [1] "The deepest: −84.5%, from $1,151 on 4 Dec 2013 to $178.10 on 14 Jan 2015; the price was back at the high on 4 Jan 2017, 1,127 days after the peak."
#> [2] "The median fall: −34.8%, with the trough 67 days after the peak; the falls that ended got back to the high a median of 86 days after it."          
#> [3] "Of its 4,941 days, 75% closed 20% or more below the high so far, and 179 days set a new all-time high."                                            
#> 
#> 
```
