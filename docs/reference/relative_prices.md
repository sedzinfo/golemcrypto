# Normalized prices relative to one of the coins

The relative strength of each coin against a base coin: the ratio of
their normalized prices, so 100 on the first common date, as in
[`normalize_prices()`](https://sedzinfo.github.io/golemcrypto/reference/normalize_prices.md).
A line that rises did better than the base, one that falls did worse,
and 120 means 20% better since the start: Ethereum against Bitcoin is
the ETH/BTC ratio, normalized to 100. On a day the base has no close,
its last close before stands in.

## Usage

``` r
relative_prices(prices, base)
```

## Arguments

- prices:

  Prices from
  [`normalize_prices()`](https://sedzinfo.github.io/golemcrypto/reference/normalize_prices.md).

- base:

  The `name_symbol` of the coin to divide by, one of those of `prices`.

## Value

The rows of `prices` of the other coins, with `index` the ratio to the
base times 100, the base's own `index` in `base_index`, and `base`.

## Examples

``` r
history <- data.frame(
  name_symbol = rep(c("Alpha (A)", "Beta (B)"), each = 3),
  timestamp = rep(as.Date("2024-01-01") + 0:2, 2),
  close = c(10, 11, 12, 200, 180, 220)
)
relative_prices(normalize_prices(history), "Beta (B)")
#>   name_symbol  timestamp close    index base_index     base
#> 1   Alpha (A) 2024-01-01    10 100.0000        100 Beta (B)
#> 2   Alpha (A) 2024-01-02    11 122.2222         90 Beta (B)
#> 3   Alpha (A) 2024-01-03    12 109.0909        110 Beta (B)
```
