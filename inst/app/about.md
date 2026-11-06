Crypto Time Series Analyzer shows the prices of cryptocurrencies from <a href="https://coinmarketcap.com" target="_blank" rel="noopener">CoinMarketCap</a>, in US dollars. This page explains what each tab shows and how its numbers are calculated. The CSV button of each tab downloads the data behind it, unrounded. The app is for exploring market data; it is not investment advice.

**On this page:** [Timeseries](#about-timeseries) · [Compare](#about-compare) · [Linear and log scales](#about-scales) · [Top 100](#about-top100) · [Treemap](#about-treemap) · [Returns calendar](#about-calendar) · [Volatility](#about-volatility) · [Data and updates](#about-data)

<h3 id="about-timeseries">Timeseries</h3>

The daily prices of one coin, from its first day in CoinMarketCap's data (29 April 2013 at the earliest) to the last day that has ended. Type part of a name or symbol in the search box to find a coin.

**Candles.** One per day, a UTC day from 00:00 to 23:59:59. The body spans the open and the close, and the thin lines reach the day's high and low. A green candle closed above its open, a red one below it. Hover over a day for its four prices.

**close** (the orange line) is the last price of each day. Every calculation in the app starts from it.

**50-day and 200-day average** are simple moving averages of the close:

```
average(t) = (close(t) + close(t−1) + … + close(t−n+1)) / n        n = 50 or 200
```

Each day's value is the mean of the last n closes, that day included, so the first n − 1 days have none, and a coin younger than n days has no line. The averages smooth out the daily swings: a price above its average trades above its recent trend. Traders call the 50-day average crossing above the 200-day one a *golden cross*, and crossing below it a *death cross*. Both lag the price by design, the 200-day average more. Crypto trades every day, so 200 days are about six and a half months, not the ten months that 200 trading days make for shares.

**Volume** is the US dollars of the coin traded that day, on the exchanges CoinMarketCap tracks. Spikes mark unusually busy days. CoinMarketCap has no volume for the earliest days, which show 0; for Bitcoin, until 26 December 2013.

**From high**, the drawdown, is how far each close is below the highest close up to that day:

```
from high(t) = (close(t) / highest close up to t − 1) × 100
```

It is 0% on a day that closes at a new high, and −50% at half of it. The high is taken over the whole history, so zooming in does not change it. A fall needs a larger rise to recover: from −50% the price has to double (+100%), from −80% rise fivefold (+400%), from −90% tenfold (+900%):

```
rise needed = (100 / (100 + from high) − 1) × 100
```

**Zoom** with the buttons above the chart (7 days to all) or the slider under it; the averages and the drawdown always use the whole history. Click a legend entry to hide or show its line.

<h3 id="about-compare">Compare</h3>

Up to 10 coins on one chart, each starting at 100, so that coins with very different prices can be compared:

```
index(t) = 100 × close(t) / close(t₀)
```

t₀ is the first day, on or after the start date, on which every selected coin has a price; a coin that started trading after the start date moves t₀ to its first day. The chart title shows t₀.

The index has no unit: it is the price as a percentage of the price on t₀. Read it as what 100 dollars put into the coin at the close of t₀ would be worth, before fees: 150 means +50% since t₀, 80 means −20%, and 1,000 means ten times as much. The ratio of two lines compares two coins: when A is at 300 and B at 150, A has done twice as well as B since t₀.

The average growth per year (the compound annual growth rate) after d days is

```
growth per year = ((index(t) / 100) ^ (365 / d) − 1) × 100
```

For example, an index of 400 after two years (730 days) is +100% a year, as 4 ^ (365 / 730) = 2: the money doubled twice. Crypto trades every day, hence 365 days in a year rather than the about 252 trading days of shares.

<h3 id="about-scales">Linear and log scales</h3>

The Linear and Log buttons above the Compare chart change how the vertical axis is drawn, not the data.

- **Linear**: equal distances on the axis are equal differences. 100 → 200 is as tall as 1,000 → 1,100, a rise of 100 points either way, although the first doubled the money and the second added 10%.
- **Log** (logarithmic): equal distances are equal ratios, because each value sits at the height of its logarithm, log₁₀(index). 100 → 200 is as tall as 1,000 → 2,000, as both doubled, and 100 → 1,000 as tall as 1,000 → 10,000. Between powers of ten, plotly may label the gridlines with their first digit only: 2 and 5 after 100 stand for 200 and 500.

<!-- scales example -->

The same two made-up coins on both axes: one doubles every year, the other grows by 25% a year. On the linear axis the slower one looks flat, and the faster one seems to take off only at the end, although both grow at a steady rate. On the log axis both are straight lines, and the steeper line is the faster growth.

A log axis helps when:

- **the moves are large**: over long periods, or for coins that rose tenfold next to coins that rose by half. On a linear axis the largest line squeezes the others into a flat band at the bottom.
- **percentages matter more than points**: a 50% fall is equally tall at any level, so crashes that started from different heights can be compared.
- **you judge the trend**: a steady growth rate is a straight line, and its slope is the rate. A line that curves upwards grows faster and faster; one that bends down is slowing.
- **you compare coins**: the vertical gap between two lines is the ratio of their indexes, so lines that run parallel performed the same over that stretch, however far apart they are.

A log axis cannot show 0 or negative values, which the index never reaches, as prices stay above zero. A linear axis is the better choice for short periods and small moves, within about ±20% of 100, where the two look almost the same, and when you want the gain in points: on the Compare chart, points are dollars of the 100 put in.

<h3 id="about-top100">Top 100</h3>

The 100 largest coins by market cap, as CoinMarketCap lists them now; the line above the table says when they were downloaded. Click a column header to sort; the table keeps your sorting and page for two hours. The numbers are rounded in the table and unrounded in the CSV.

| Column | What it is |
|---|---|
| `name_symbol` | The coin's name and its ticker symbol |
| `price` | The price in US dollars: CoinMarketCap's volume-weighted average over the exchanges it tracks |
| `volume_24h` | The US dollars traded in the last 24 hours |
| `volume_change_24h` | The change of that volume against the 24 hours before, in percent |
| `change_24h`, `change_7d`, `change_30d`, `change_60d`, `change_90d` | The price change in percent over the last 24 hours, 7, 30, 60 and 90 days: rolling periods that end now, not calendar weeks or months |
| `market_cap` | Price × circulating supply, the coins that are out in the market |
| `market_cap_dominance` | The coin's share of the market cap of all cryptocurrencies, in percent |
| `fully_diluted_market_cap` | Price × maximum supply: the market cap if every coin that can ever exist were in circulation. For coins without a maximum, CoinMarketCap uses the total supply |
| `last_updated` | When CoinMarketCap last updated the coin's numbers, in UTC |

The change columns are shaded red for falls and green for rises. The shade follows the rank of each change among the values of all five change columns: the lowest 5% get the deepest red, the highest 5% the deepest green, and values close to zero fade into the page. As the scale follows the spread of the day, compare shades within the table, not from one day to the next.

<h3 id="about-treemap">Treemap</h3>

The same top 100 as rectangles. The area of each rectangle is the coin's market cap, so its share of the whole is its share of the market cap of the top 100. The color is the price change of the last 24 hours, red for falls and green for rises. The color scale is symmetric around 0 and reaches its deepest shades at the larger of the 5th and 95th percentiles of the day's changes, in absolute value; the bar on the right shows that range. A few extreme moves therefore do not wash out the rest, and coins beyond the range get the deepest shade. A coin without a 24h change reads n/a and stays uncolored. Hover over a rectangle for its market cap.

<h3 id="about-calendar">Returns calendar</h3>

The monthly returns of the coin picked in the Timeseries tab, a row per year and a column per month:

```
return(month) = (last close of the month / last close of the month before − 1) × 100
```

The coin's first month has no month before it and stays empty, as do the months to come. The current month is the return so far, up to the latest close, and changes until the month ends.

Returns compound; they do not add up. A year's return is

```
return(year) = ((1 + r₁ / 100) × (1 + r₂ / 100) × … × (1 + r₁₂ / 100) − 1) × 100
```

so +50% in one month and −50% in the next leave −25%, not 0.

The colors are red for losses and green for gains, symmetric around 0, and reach their deepest at the 95th percentile of the coin's monthly returns in absolute value. They are scaled to the coin's own swings, so the same shade means a bigger move for a volatile coin than for a calm one. Reading down a column compares the same month across years; with a dozen years at most, a pattern there can easily be chance.

<h3 id="about-volatility">Volatility</h3>

Is the coin's recent volatility normal, and what may the next days bring? The tab answers for the coin picked in the Timeseries tab, in words in three cards and in a chart. Everything starts from the daily log returns,

```
r(t) = log(close(t) / close(t−1))
```

which add up over days; the percentages shown are converted back, (e^r − 1) × 100. A coin needs more than a year of history for the tab.

**The last 30 days.** The volatility is the standard deviation of the 30 daily returns, annualized with the 365 days of a crypto year:

```
volatility = sd(r over 30 days) × √365 × 100        in % a year
```

The card compares it with the year before the 30 days, and with every 30-day period in the coin's history: its percentile among them gives the level, *normal* below the 60th, *elevated* to the 85th, *high* to the 95th and *extreme* above. Two tests ask whether the 30 days varied more than the year before: the F test of their variances, which a few extreme days can sway, and the Fligner-Killeen test, which they cannot. When only the F test finds a difference (p < 0.05), a few large days made the month look rough, not the month as a whole. The largest day is measured in standard deviations of the year before it, and the card says how often days moved that many of their own year's standard deviations in the coin's history. Last, the return of the 30 days is placed among all 30-day returns.

**The last 2 days.** Three measures of how rare the move of the last two days is:

1. **History**: the share of all 2-day moves in the coin's history that were as large in the same direction, as times a year.
2. **Against the year before**: the move in standard deviations of the year before it, z = (r₁ + r₂) / (sd × √2), and how often 2-day moves reached as many standard deviations of their own year.
3. **GARCH**: a model of how volatility clusters, the most used in finance. Each day's variance is expected from the day before:

```
σ²(t) = ω + α × e(t−1)² + β × σ²(t−1)        e = r − μ
```

so a large move raises the volatility the model expects for the next days, which then fades at the rate β. The daily moves e / σ follow a Student-t distribution, whose fat tails allow more extreme days than the normal distribution. The model is fitted by maximum likelihood to the 4 years before the two days, so it judges them against the volatility it expected without having seen them. The probability of a move at least as large, p, gives *about 1 in 1/p days*. The verdict follows it: *normal* for about once a month or more often (under 30 days), *unusual* for less than monthly but more than once a year (under 365), *rare* for once in 1 to 10 years, and *very rare* beyond. The card also judges the most extreme of the two days alone, as a large move can hide in a 2-day total when the other day went the opposite way. A coin with less than 500 days before the two days has no model, and the verdict comes from the second measure.

**Volume.** The last point of the card compares each day's volume, the US dollars traded, with the median volume of the 30 days before it:

```
volume ratio(t) = volume(t) / median(volume(t−30), …, volume(t−1))
```

2 is twice the usual volume of the time and 0.5 half of it. The median keeps a single busy day from raising the bar, and the ratio follows the coin's volume as it grows over the years. How unusual a ratio is comes from the coin's history: the share of days whose own ratio was at least as high, or as low for a quiet day, with the same words and thresholds as for the moves. A large move on unusually high volume had many traders behind it; on normal or low volume it happened in a thinner market, where smaller trades move the price more. Days without volume, which CoinMarketCap has for the earliest days of some coins, are left out.

The history measures say how large a move is; the standard deviations and the model say how large it is given the volatility of the time, as a 5% day is a shock in a calm market and routine in a rough one. The probabilities hold if the model holds: in crashes the tails are often fatter still, so *1 in N days* tends to overstate how rare a move is.

**The next days.** The third card looks ahead with the same model, its variance brought up to the last day. The variance of the next day follows from the last day, and later days fall back towards the model's long-run level at the rate α + β a day:

```
σ²(T+1) = ω + α × e(T)² + β × σ²(T)
σ²(T+h) = σ²∞ + (α + β)^(h−1) × (σ²(T+1) − σ²∞)        σ²∞ = ω / (1 − α − β)
```

The half-life, log(0.5) / log(α + β), is the number of days the volatility takes to get half-way back to that level. The card compares the next day's volatility with it rather than with the 30-day volatility of the first card: with fat tails, the model's standard deviation counts the rare extreme days, which a calm month may not have had, so it runs higher than the volatility measured over 30 days.

The range of the next day comes straight from the model's Student-t distribution. The ranges of the next 7 days come from 50,000 simulated paths of the model, in which a large day raises the volatility of the days after it; the paths start from a fixed seed, so the numbers do not change when the chart is drawn again. A 95% range leaves 2.5% of the outcomes below it and 2.5% above.

The value at risk (VaR) is the loss exceeded on the worst 5% of days, and the expected shortfall (ES) the average loss on those days. The card gives both for the next day, from the model, and for the last 365 days, from the daily returns themselves:

```
VaR = −(5th percentile of the daily returns)        ES = −(average of the returns below it)
```

Losses are price falls in percent. The 95% range and the 95% VaR differ: the range leaves out 2.5% on each side, the VaR 5% on the downside alone, so the VaR is the smaller loss. The last point checks the model's VaR against the last 365 days with the Kupiec test: a well-calibrated VaR is exceeded on about 5% of the days, some 18 a year, and a p-value below 0.05 means it was exceeded more often, so the model understates the risk, or less often, so it overstates it. The forecast assumes that the model holds. It cannot foresee news: its ranges say how far the price usually moves at this level of volatility, not where it will go.

**The chart.** At the top, the 30-day volatility over the whole history, with its median and 95th percentile. In the middle, each of the last 90 days in the standard deviations the model expected, with dashed lines at ±2 and dotted ones at ±4. At the bottom, the last 30 closes and the forecast of the next 7 days: the median close, the middle half of the outcomes (50%) and the 95% range; hover over the median for a day's ranges. The CSV button downloads the data day by day: the daily return, the volume and its ratio, the 30-day volatility, the standard deviation and value at risk the model expected, and the forecast of the days ahead.

<h3 id="about-data">Data and updates</h3>

- All prices come from CoinMarketCap and are in US dollars. Days are UTC days.
- The Top 100 and Treemap tabs use CoinMarketCap's market listings. They are downloaded at most every {{refresh_minutes}} minutes and shared by everyone using the app at the time.
- The daily prices are downloaded with the crypto2 package and kept on the server. A coin's history is brought up to date when it is more than {{history_minutes}} minutes old; its newest day is the last one that has ended.
- The list of coins in the search boxes is refreshed every {{coins_hours}} hours and holds the coins that are still traded.
- When CoinMarketCap limits the requests, a chart can take about a minute to appear. When the listings cannot be downloaded, the Top 100 and Treemap tabs say why.
