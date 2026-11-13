##########################################################################################
# 
##########################################################################################
#' @title The application user interface
#' @description A navbar page with one tab per module, a light/dark mode toggle
#' and, with `keep_alive`, a hidden output that answers the keep-alive pings.
#' @param coins Data frame of coins from `get_coins()`, for the coin pickers.
#' @param top_coins Coin labels sorted by market cap, for the default
#'   selection of the Compare tab.
#' @param analytics `TRUE` to add Google Analytics and its cookie banner,
#'   see `analytics_resources()`.
#' @param keep_alive `TRUE` to ping the server every 15 seconds while the
#'   page is open, so that proxies do not close idle connections.
#' @return A `tagList` with the whole page.
#' @noRd
#' @examples
#' \dontrun{
#' coins <- get_coins()
#' shiny::shinyApp(ui = app_ui(coins, get_listings()$data$name_symbol), server = app_server(coins))
#' }
app_ui <- function(coins, top_coins, analytics = FALSE, keep_alive = TRUE) {
  app_name <- "Crypto Time Series Analyzer"
  tagList(
    add_external_resources(analytics, keep_alive),
    bslib::page_navbar(
      title = app_name,
      window_title = app_name,
      theme = bslib::bs_theme(version = 5, primary = "#F7931A"),
      # keep the fixed plot heights instead of squeezing the plots to the window
      fillable = FALSE,
      footer = if (analytics) analytics_footer(),
      tabPanel("Timeseries", mod_timeseries_ui("timeseries", coins)),
      tabPanel("Compare", mod_compare_ui("compare", coins, top_coins)),
      tabPanel("Top 100", mod_top100_ui("top100")),
      tabPanel("Treemap", mod_treemap_ui("treemap")),
      tabPanel("Returns calendar", mod_returns_calendar_ui("returns_calendar")),
      tabPanel("Seasonality", mod_seasonality_ui("seasonality")),
      tabPanel("Volatility", mod_volatility_ui("volatility")),
      tabPanel("Drawdowns", mod_drawdowns_ui("drawdowns")),
      tabPanel("About", mod_about_ui("about")),
      bslib::nav_spacer(),
      bslib::nav_item(bslib::input_dark_mode(id = "dark_mode"))
    ),
    # rendering this output makes the server answer the keep-alive pings
    if (keep_alive) div(style = "display:none", textOutput("keep_alive"))
  )
}
##########################################################################################
#
##########################################################################################
#' @title Address and description of the live app, for search engines and link previews
#' @description Used by `add_external_resources()` for the description that
#' search engines show and the Open Graph tags of the preview that other sites
#' show for a link to the app. `title` is the window title that `app_ui()` gives
#' the page, and `image` the first screenshot of the README.
#' @noRd
app_meta <- list(
  url = "https://sedzinfo-golemcrypto.share.connect.posit.cloud/",
  title = "Crypto Time Series Analyzer",
  description = "Explore cryptocurrency prices since 2013 with interactive candlestick charts, the top 100 coins by market cap, returns, volatility and drawdowns.",
  image = "https://raw.githubusercontent.com/sedzinfo/golemcrypto/main/screenshots/crypto1.png"
)
##########################################################################################
#
##########################################################################################
#' @title Add external resources to the application
#' @description Serves `inst/app/www` under the `www/` path and adds the
#' description and Open Graph tags of `app_meta`, the favicon and the
#' stylesheet to the head of the page, and the keep-alive script and Google
#' Analytics when asked for.
#' @param analytics `TRUE` to add Google Analytics and its cookie banner.
#' @param keep_alive `TRUE` to add the script that pings the server every 15
#'   seconds.
#' @return A `tags$head()` tag.
#' @noRd
#' @examples
#' \dontrun{
#' # called from inside app_ui():
#' shiny::tagList(add_external_resources(), bslib::page_navbar())
#' }
add_external_resources <- function(analytics = FALSE, keep_alive = TRUE) {
  addResourcePath("www", app_sys("app/www"))
  tags$head(
    tags$meta(name = "description", content = app_meta$description),
    tags$meta(property = "og:type", content = "website"),
    tags$meta(property = "og:site_name", content = "sedzinfo"),
    tags$meta(property = "og:title", content = app_meta$title),
    tags$meta(property = "og:description", content = app_meta$description),
    tags$meta(property = "og:url", content = app_meta$url),
    tags$meta(property = "og:image", content = app_meta$image),
    tags$meta(name = "twitter:card", content = "summary_large_image"),
    tags$link(rel = "icon", type = "image/svg+xml", href = "www/favicon.svg"),
    tags$link(rel = "stylesheet", href = "www/styles.css"),
    # on a phone the tabs are in a menu that opens under the navigation bar and stays open
    # after a tab is picked, covering half of the screen: close it when a tab is picked
    # (on wider screens the tabs are not in an opened menu, and nothing happens)
    tags$script(HTML(
      "document.addEventListener('click', function (e) {
        var menu = document.querySelector('.navbar-collapse.show');
        if (menu && e.target.closest('.navbar-collapse a[data-bs-toggle=\"tab\"]'))
          bootstrap.Collapse.getOrCreateInstance(menu).hide();
      });"
    )),
    if (keep_alive) tags$script(src = paste0(shared_url, "keep_alive.js")),
    if (analytics) analytics_resources()
  )
}
