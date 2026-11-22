##########################################################################################
#
##########################################################################################
#' @title Compare module - UI
#' @description A picker for up to 10 coins, a start date, a coin to show
#' the others relative to, a button that downloads the normalized prices as
#' CSV, and a chart of the coins' close prices normalized to 100.
#' @param id Character. Module namespace id.
#' @param coins Data frame of coins from [get_coins()], whose `name_symbol`
#'   labels fill the picker.
#' @param top_coins Coin labels sorted by market cap; the first three that
#'   are in `coins` are selected at start.
#' @return A `tagList` of Shiny UI elements.
#' @keywords internal
#' @examples
#' \dontrun{
#' coins <- golemcrypto:::get_coins()
#' shiny::fluidPage(golemcrypto:::mod_compare_ui(
#'                 "compare",
#'                  coins,
#'                  c("Bitcoin (BTC)", "Ethereum (ETH)")))
#' }
mod_compare_ui <- function(id, coins, top_coins) {
  ns <- NS(id)
  tagList(
    div(
      class = "d-flex flex-wrap align-items-end gap-3",
      shinyWidgets::pickerInput(ns("coins"),
        label = "Coins",
        choices = unique(coins$name_symbol),
        selected = utils::head(intersect(top_coins, coins$name_symbol), 3),
        multiple = TRUE,
        options = list(`live-search` = TRUE, `max-options` = 10, style = "border bg-body text-body")
      ),
      dateInput(ns("start"), label = "Start date", value = Sys.Date() - 365, max = Sys.Date() - 1),
      # filled with the selected coins by the server
      selectInput(ns("base"), label = "Relative to", choices = c("None" = ""), selectize = FALSE, width = "14rem"),
      div(class = "mb-3", downloadButton(ns("csv"), "CSV"))
    ),
    shinycssloaders::withSpinner(
      # the rest of the window below the controls, with a minimum in styles.css
      plotly::plotlyOutput(ns("plot"), width = "100%", height = "calc(100vh - 170px)")
    )
  )
}
##########################################################################################
#
##########################################################################################
#' @title Compare module - server
#' @description Downloads the price history of the selected coins from the start
#' date, renders their close prices normalized to 100, and serves them as a CSV
#' file named like `compare-2026-10-24.csv`, with the columns `date`,
#' `name_symbol`, `close` and `index`. The download waits until the selection
#' has not changed for 1.5 seconds, instead of starting on every click in the
#' picker. With a coin picked under "Relative to", the chart shows the others
#' relative to it with [relative_prices()], and the CSV file, named like
#' `compare-vs-bitcoin-btc-2026-10-24.csv`, adds `base` and `relative`.
#' @param id Character. Module namespace id, must match the id used in
#'   [mod_compare_ui()].
#' @param coins Data frame of coins from [get_coins()].
#' @param dark_mode Reactive returning `"light"` or `"dark"`, the mode of the
#'   app.
#' @return None. Called for its side effect of registering the module server.
#' @keywords internal
#' @examples
#' \dontrun{
#' # inside app_server():
#' function(input, output, session) {
#'   mod_compare_server("compare", coins, reactive(input$dark_mode))
#' }
#' }
mod_compare_server <- function(id, coins, dark_mode) {
  moduleServer(id, function(input, output, session) {
    selected <- debounce(reactive(input$coins), 1500)
    history <- reactive({
      req(selected(), input$start)
      get_history(selected(), input$start, coins)
    })
    prices <- reactive({
      validate(need(history(), "Data not available for the selected coins"))
      normalize_prices(history())
    })

    # the base can be any selected coin; it stays picked while it is selected
    observeEvent(selected(), ignoreNULL = FALSE, {
      keep <- if (isTRUE(input$base %in% selected())) input$base else ""
      updateSelectInput(session, "base", choices = c("None" = "", selected()), selected = keep)
    })
    base <- reactive({
      base <- input$base
      if (is.null(base) || !nzchar(base) || !base %in% selected()) NULL else base
    })
    relative <- reactive({
      req(base())
      validate(need(base() %in% prices()$name_symbol, paste("No prices of", base(), "to compare with")))
      validate(need(length(unique(prices()$name_symbol)) >= 2, "Select another coin to compare with the base"))
      relative_prices(prices(), base())
    })

    output$plot <- plotly::renderPlotly({
      if (is.null(base())) plot_compare(prices(), dark_mode()) else plot_compare(relative(), dark_mode(), base = base())
    })

    output$csv <- csv_download(
      reactive({
        rows <- if (is.null(base())) prices() else relative()
        csv <- data.frame(
          date = rows$timestamp,
          name_symbol = rows$name_symbol,
          close = rows$close,
          index = if (is.null(base())) rows$index else rows$index * rows$base_index / 100
        )
        if (!is.null(base())) {
          csv$base <- rows$base
          csv$relative <- rows$index
        }
        csv
      }),
      function() paste0("compare", if (!is.null(base())) paste0("-vs-", file_stem(base())))
    )
  })
}
