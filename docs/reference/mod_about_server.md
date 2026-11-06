# About module - server

Draws the example of the linear and log axes in the light or dark mode
of the app.

## Usage

``` r
mod_about_server(id, dark_mode)
```

## Arguments

- id:

  Character. Module namespace id, must match the id used in
  [`mod_about_ui()`](https://sedzinfo.github.io/golemcrypto/reference/mod_about_ui.md).

- dark_mode:

  Reactive returning `"light"` or `"dark"`, the mode of the app.

## Value

None. Called for its side effect of registering the module server.

## Examples

``` r
if (FALSE) { # \dontrun{
# inside app_server():
function(input, output, session) {
  mod_about_server("about", reactive(input$dark_mode))
}
} # }
```
