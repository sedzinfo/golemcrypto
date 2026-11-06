# Run code with a fixed random seed

The random numbers repeat from one run to the next, and the random state
of the R session is put back afterwards, so the code does not change the
random numbers of the user.

## Usage

``` r
with_seed(seed, code)
```

## Arguments

- seed:

  An integer for [`set.seed()`](https://rdrr.io/r/base/Random.html).

- code:

  The code to run.

## Value

The value of `code`.

## Examples

``` r
golemcrypto:::with_seed(1, runif(2))
#> [1] 0.2655087 0.3721239
```
