# About module - UI

What each tab shows and how its numbers are calculated, from
[`about_text()`](https://sedzinfo.github.io/golemcrypto/reference/about_text.md),
with an example of the linear and log axes of the Compare tab where the
text marks its place.

## Usage

``` r
mod_about_ui(id)
```

## Arguments

- id:

  Character. Module namespace id.

## Value

A `div` of Shiny UI elements.

## Examples

``` r
if (FALSE) { # \dontrun{
shiny::fluidPage(golemcrypto:::mod_about_ui("about"))
} # }
```
