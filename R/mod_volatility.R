##########################################################################################
#
##########################################################################################
#' @title Volatility module - UI
#' @description For the coin selected in the Timeseries tab: three cards that
#' say in words whether the volatility of the last month and the move of the
#' last days are normal, and what the next days may bring, a button that
#' downloads the daily data behind them as CSV, and the volatility chart.
#' @param id Character. Module namespace id.
#' @return A `tagList` of Shiny UI elements.
#' @keywords internal
#' @examples
#' \dontrun{
#' shiny::fluidPage(golemcrypto:::mod_volatility_ui("volatility"))
#' }
mod_volatility_ui <- function(id) {
  ns <- NS(id)
  # a column that fills the window: the cards take the height of their text and the chart
  # the rest, see styles.css
  div(
    class = "fill-page",
    div(
      class = "d-flex align-items-center gap-3",
      helpText("Coin selected in the Timeseries tab"),
      downloadButton(ns("csv"), "CSV", class = "btn-sm")
    ),
    uiOutput(ns("summary")),
    shinycssloaders::withSpinner(
      plotly::plotlyOutput(ns("plot"), width = "100%", height = "100%")
    )
  )
}
##########################################################################################
#
##########################################################################################
#' @title Volatility module - server
#' @description Analyses the price history of the coin selected in the
#' Timeseries tab with [volatility_analysis()], once per coin, and shows it in
#' words and as a chart. The CSV file, named like
#' `bitcoin-btc-volatility-2026-11-06.csv`, holds [volatility_csv()]: a row
#' per day, the days of the forecast included.
#' @param id Character. Module namespace id, must match the id used in
#'   [mod_volatility_ui()].
#' @param history Reactive returning the price history of the selected coin,
#'   from [mod_timeseries_server()].
#' @param dark_mode Reactive returning `"light"` or `"dark"`, the mode of the
#'   app.
#' @return None. Called for its side effect of registering the module server.
#' @keywords internal
#' @examples
#' \dontrun{
#' # inside app_server():
#' function(input, output, session) {
#'   dark_mode <- reactive(input$dark_mode)
#'   history <- mod_timeseries_server("timeseries", coins, dark_mode)
#'   mod_volatility_server("volatility", history, dark_mode)
#' }
#' }
mod_volatility_server <- function(id, history, dark_mode) {
  moduleServer(id, function(input, output, session) {
    analysis <- reactive({
      validate(need(history(), "Data not available for this coin"))
      analysis <- volatility_analysis(history())
      validate(need(analysis, "Not enough history for the volatility analysis: it needs more than a year of prices that move"))
      analysis
    })

    output$summary <- renderUI({
      text <- volatility_text(analysis())
      bslib::layout_columns(
        col_widths = bslib::breakpoints(sm = 12, lg = 6, xl = 4),
        class = "mt-2",
        summary_card(text$month),
        summary_card(text$recent),
        summary_card(text$forecast)
      )
    })

    output$plot <- plotly::renderPlotly(plot_volatility(analysis(), dark_mode()))

    output$csv <- csv_download(
      reactive(volatility_csv(analysis())),
      reactive(paste0(file_stem(analysis()$coin), "-volatility"))
    )
  })
}
