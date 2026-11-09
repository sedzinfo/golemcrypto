##########################################################################################
#
##########################################################################################
#' @title Drawdowns module - UI
#' @description For the coin selected in the Timeseries tab: a choice of the
#' smallest fall to list, a button that downloads the falls as CSV, the
#' drawdown chart, the table of the falls, and under it two cards that say in
#' words how far the coin is below its all-time high and how that compares
#' with its earlier falls.
#' @param id Character. Module namespace id.
#' @return A `tagList` of Shiny UI elements.
#' @keywords internal
#' @examples
#' \dontrun{
#' shiny::fluidPage(golemcrypto:::mod_drawdowns_ui("drawdowns"))
#' }
mod_drawdowns_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # the chart fills the window, as in the Volatility tab, and the table and the cards follow
    div(
      class = "fill-page two-panels",
      div(
        class = "d-flex flex-wrap align-items-center gap-3 inline-controls",
        helpText("Coin selected in the Timeseries tab"),
        div(
          class = "d-flex align-items-center gap-2",
          tags$label(`for` = ns("min_depth"), class = "form-label mb-0", "Falls of"),
          selectInput(ns("min_depth"), NULL,
            choices = c("10% or more" = 10, "20% or more" = 20, "30% or more" = 30, "50% or more" = 50),
            selected = 20, selectize = FALSE, width = "9rem"
          )
        ),
        downloadButton(ns("csv"), "CSV", class = "btn-sm")
      ),
      shinycssloaders::withSpinner(
        plotly::plotlyOutput(ns("plot"), width = "100%", height = "100%")
      )
    ),
    div(class = "mt-3", DT::DTOutput(ns("table"))),
    div(class = "mt-3 mb-4", uiOutput(ns("summary")))
  )
}
##########################################################################################
#
##########################################################################################
#' @title Drawdowns module - server
#' @description Analyses the falls of the coin selected in the Timeseries
#' tab from its all-time high with [drawdown_analysis()], and shows them in
#' words, as a chart and as a table. The CSV file, named like
#' `bitcoin-btc-drawdowns-2026-11-06.csv`, holds [drawdown_csv()]: a row per
#' fall of the chosen size.
#' @param id Character. Module namespace id, must match the id used in
#'   [mod_drawdowns_ui()].
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
#'   mod_drawdowns_server("drawdowns", history, dark_mode)
#' }
#' }
mod_drawdowns_server <- function(id, history, dark_mode) {
  moduleServer(id, function(input, output, session) {
    min_depth <- reactive(if (is.null(input$min_depth)) 20 else as.numeric(input$min_depth))

    analysis <- reactive({
      validate(need(history(), "Data not available for this coin"))
      analysis <- drawdown_analysis(history(), min_depth())
      validate(need(analysis, "Not enough history: the falls need at least two days of prices"))
      analysis
    })

    output$summary <- renderUI({
      text <- drawdown_text(analysis())
      bslib::layout_columns(
        col_widths = bslib::breakpoints(sm = 12, lg = 6),
        class = "mt-2",
        summary_card(text$now),
        summary_card(text$history)
      )
    })

    output$plot <- plotly::renderPlotly(plot_drawdowns(analysis(), dark_mode()))

    output$table <- DT::renderDT(drawdown_table(analysis()))

    output$csv <- csv_download(
      reactive(drawdown_csv(analysis())),
      reactive(paste0(file_stem(analysis()$coin), "-drawdowns"))
    )
  })
}
