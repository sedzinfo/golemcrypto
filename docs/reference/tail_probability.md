# Probability of a Student-t move at least this far from 0

For the Student-t distribution scaled to a variance of 1, as in
[`garch_fit()`](https://sedzinfo.github.io/golemcrypto/reference/garch_fit.md):
the probability of a value as low as `z` when `z` is negative, or as
high as `z` when it is positive.

## Usage

``` r
tail_probability(z, nu)
```

## Arguments

- z:

  Numeric vector of moves in standard deviations.

- nu:

  Degrees of freedom, above 2.

## Value

A numeric vector of probabilities.

## Examples

``` r
golemcrypto:::tail_probability(c(-4, 2), nu = 4)
#> [1] 0.002406339 0.023710328
```
