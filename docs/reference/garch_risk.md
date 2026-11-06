# Value at risk and expected shortfall of a day

For a day whose log return, in percent, is `mu + sigma * z` with `z`
from the Student-t distribution scaled to a variance of 1: the value at
risk is the loss exceeded with probability `1 - level`, and the expected
shortfall the average loss beyond it. Both are price falls in percent,
`100 * (1 - exp(r / 100))`, so they cannot exceed 100.

## Usage

``` r
garch_risk(mu, sigma, nu, level)
```

## Arguments

- mu, sigma:

  Mean and standard deviation of the log return, in percent.

- nu:

  Degrees of freedom, above 2.

- level:

  Probability, such as 0.95 for the worst 5% of days.

## Value

A list with `var` and `es`, in percent.

## Examples

``` r
golemcrypto:::garch_risk(mu = 0, sigma = 2.5, nu = 4, level = 0.95)
#> $var
#> [1] 3.69848
#> 
#> $es
#> [1] 5.47662
#> 
```
