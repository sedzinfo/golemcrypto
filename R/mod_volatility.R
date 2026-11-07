##########################################################################################
#
##########################################################################################
#' @title Volatility module - UI
#' @description For the coin selected in the Timeseries tab: a choice of the
#' days of the volatility window and of the recent move, a button that
#' downloads the daily data behind them as CSV, three cards that say in words
#' whether the volatility of the window and the recent move are normal, and
#' what the next days may bring, and the volatility chart.
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
      class = "d-flex flex-wrap align-items-center gap-3 inline-controls",
      helpText("Coin selected in the Timeseries tab"),
      div(
        class = "d-flex align-items-center gap-2",
        tags$label(`for` = ns("month_days"), class = "form-label mb-0", "Volatility over"),
        selectInput(ns("month_days"), NULL,
          choices = c("7 days" = 7, "14 days" = 14, "30 days" = 30, "60 days" = 60, "90 days" = 90),
          selected = 30, selectize = FALSE, width = "7rem"
        )
      ),
      div(
        class = "d-flex align-items-center gap-2",
        tags$label(`for` = ns("recent_days"), class = "form-label mb-0", "Recent move"),
        selectInput(ns("recent_days"), NULL,
          choices = c("1 day" = 1, "2 days" = 2, "3 days" = 3, "7 days" = 7),
          selected = 2, selectize = FALSE, width = "7rem"
        )
      ),
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
#' Timeseries tab with [volatility_analysis()], with the days of the
#' volatility window and of the recent move chosen above the cards, and
#' shows it in words and as a chart. The CSV file, named like
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
    month_days <- reactive(if (is.null(input$month_days)) 30 else as.numeric(input$month_days))
    recent_days <- reactive(if (is.null(input$recent_days)) 2 else as.numeric(input$recent_days))

    analysis <- reactive({
      validate(need(history(), "Data not available for this coin"))
      analysis <- volatility_analysis(history(), month_days = month_days(), recent_days = recent_days())
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
