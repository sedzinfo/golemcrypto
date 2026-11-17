# Google Analytics for the public deployment

Loads the cookie banner shared with the sites of sedzinfo.github.io,
which loads Google Analytics only after the visitor accepts and gives
the banner the navy of those sites, and the script shared by the apps
that reports the tabs and the CSV downloads of the app as pages and
downloads (`https://sedzinfo.github.io/shiny/analytics.js`).

## Usage

``` r
analytics_resources()
```

## Value

A `tagList` for the head of the page.

## Examples

``` r
golemcrypto:::analytics_resources()
#> <script src="https://sedzinfo.github.io/consent.js" defer></script>
#> <script src="https://sedzinfo.github.io/shiny/analytics.js"></script>
```
