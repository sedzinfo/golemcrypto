# Kupiec test of a value at risk

Is the value at risk exceeded as often as it should be? The likelihood
ratio test of Kupiec (1995) compares the share of days with a loss
beyond it with the share it promises, such as 5%.

## Usage

``` r
kupiec_test(exceedances, days, p)
```

## Arguments

- exceedances:

  Number of days with a loss beyond the value at risk.

- days:

  Number of days tested.

- p:

  The share of days it should be exceeded on, such as 0.05.

## Value

The p-value of the test.

## Examples

``` r
golemcrypto:::kupiec_test(c(18, 40), days = 365, p = 0.05)
#> [1] 9.520191e-01 5.453917e-06
```
