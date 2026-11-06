# One card of a summary in words

A card of the Volatility and Drawdowns tabs: a headline and a list of
sentences.

## Usage

``` r
summary_card(part)
```

## Arguments

- part:

  A list with a `headline` and `points`, as in the results of
  [`volatility_text()`](https://sedzinfo.github.io/golemcrypto/reference/volatility_text.md)
  and
  [`drawdown_text()`](https://sedzinfo.github.io/golemcrypto/reference/drawdown_text.md).

## Value

A
[`bslib::card()`](https://rstudio.github.io/bslib/reference/card.html).

## Examples

``` r
golemcrypto:::summary_card(list(
  headline = "Last 2 days: +1.0% together, a normal rise",
  points = c("Day by day: 4 Nov +0.4%, 5 Nov +0.6%.", "...")
))
#> <div class="container-fluid">
#>   <div class="card bslib-card bslib-mb-spacing html-fill-item html-fill-container" data-bslib-card-init data-require-bs-caller="card()" data-require-bs-version="5">
#>     <div class="card-header bslib-gap-spacing">
#>       <strong>Last 2 days: +1.0% together, a normal rise</strong>
#>     </div>
#>     <div class="card-body bslib-gap-spacing html-fill-item html-fill-container" style="margin-top:auto;margin-bottom:auto;flex:1 1 auto;">
#>       <ul class="mb-0">
#>         <li>Day by day: 4 Nov +0.4%, 5 Nov +0.6%.</li>
#>         <li>...</li>
#>       </ul>
#>     </div>
#>     <script data-bslib-card-init>bslib.Card.initializeAllCards();</script>
#>   </div>
#> </div>
```
