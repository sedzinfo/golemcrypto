##########################################################################################
#
##########################################################################################
#' @title Seasonality module - UI
#' @description For the coin selected in the Timeseries tab: a choice of
#' the returns to compare (days by day of the week, weeks by week of the
#' year, months by month or years by year of the halving cycle), a button
#' that downloads the numbers as CSV, two cards that name the best and the
#' worst group and say whether the differences could be chance, the
#' seasonality chart and the table of the groups.
#' @param id Character. Module namespace id.
#' @return A `tagList` of Shiny UI elements.
#' @keywords internal
#' @examples
#' \dontrun{
#' shiny::fluidPage(golemcrypto:::mod_seasonality_ui("seasonality"))
#' }
mod_seasonality_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # the cards and the chart fill the window, as in the Drawdowns tab, and the table follows
    div(
      class = "fill-page two-panels",
      div(
        class = "d-flex flex-wrap align-items-center gap-3 inline-controls",
        helpText("Coin selected in the Timeseries tab"),
        div(
          class = "d-flex align-items-center gap-2",
          tags$label(`for` = ns("period"), class = "form-label mb-0", "Returns of"),
          selectInput(ns("period"), NULL,
            choices = c(
              "days, by day of the week" = "day",
              "weeks, by week of the year" = "week",
              "months, by month" = "month",
              "years, by halving cycle" = "year"
            ),
            selected = "month", selectize = FALSE, width = "17rem"
          )
        ),
        downloadButton(ns("csv"), "CSV", class = "btn-sm")
      ),
      uiOutput(ns("summary")),
      shinycssloaders::withSpinner(
        plotly::plotlyOutput(ns("plot"), width = "100%", height = "100%")
      )
    ),
    div(class = "mt-3 mb-4", DT::DTOutput(ns("table")))
  )
}
##########################################################################################
#
##########################################################################################
#' @title Seasonality module - server
#' @description Analyses the returns of the coin selected in the Timeseries
#' tab by day of the week, week of the year, month or year of the halving
#' cycle with [seasonality_analysis()], and shows them in words, as a chart
#' and as a table. The CSV file, named like
#' `bitcoin-btc-seasonality-month-2026-11-07.csv`, holds [seasonality_csv()]:
#' a row per group.
#' @param id Character. Module namespace id, must match the id used in
#'   [mod_seasonality_ui()].
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
#'   mod_seasonality_server("seasonality", history, dark_mode)
#' }
#' }
mod_seasonality_server <- function(id, history, dark_mode) {
  moduleServer(id, function(input, output, session) {
    period <- reactive(if (is.null(input$period)) "month" else input$period)

    analysis <- reactive({
      validate(need(history(), "Data not available for this coin"))
      analysis <- seasonality_analysis(history(), period())
      units <- seasonality_periods[[period()]]$units
      validate(need(analysis, paste0("Not enough history: the returns need at least two complete ", units, " in a row")))
      analysis
    })

    output$summary <- renderUI({
      text <- seasonality_text(analysis())
      bslib::layout_columns(
        col_widths = bslib::breakpoints(sm = 12, lg = 6),
        class = "mt-2",
        summary_card(text$groups),
        summary_card(text$chance)
      )
    })

    output$plot <- plotly::renderPlotly(plot_seasonality(analysis(), dark_mode()))

    output$table <- DT::renderDT(seasonality_table(analysis()))

    output$csv <- csv_download(
      reactive(seasonality_csv(analysis())),
      reactive(paste0(file_stem(analysis()$coin), "-seasonality-", analysis()$period))
    )
  })
}
