##########################################################################################
#
##########################################################################################
#' @title The periods of the seasonality analysis
#' @description For each period: the name of its groups, in the chart, the
#' table and the CSV file, and the words of the text.
#' @noRd
seasonality_periods <- list(
  day = list(group = "Day of the week", unit = "day", units = "days", groups = "days of the week", title = "returns by day of the week", digits = 2),
  week = list(group = "Week of the year", unit = "week", units = "weeks", groups = "weeks of the year", title = "returns by week of the year", digits = 1),
  month = list(group = "Month", unit = "month", units = "months", groups = "months", title = "returns by month", digits = 1),
  year = list(group = "Year of the cycle", unit = "year", units = "years", groups = "years of the cycle", title = "returns by year of the cycle", digits = 1),
  turn = list(
    group = "Days", unit = "day", units = "days", groups = "turn of the month and the rest of the month",
    title = "the turn of the month", digits = 2, effect = TRUE, per = "a day",
    about = "The turn of the month is the last day of a month and the first 3 of the next, the days on which stock markets tend to rise, as salaries and pension contributions are invested."
  ),
  santa = list(
    group = "Days", unit = "day", units = "days", groups = "days of the Santa rally and the other days",
    title = "the Santa rally", digits = 2, effect = TRUE, per = "a day",
    about = "The Santa rally is the last 5 days of December and the first 2 of January, the days on which Yale Hirsch found in 1972 that US stocks tend to rise."
  ),
  half = list(
    group = "Half of the year", unit = "half-year", units = "half-years", groups = "two halves of the year",
    title = "Sell in May, May to October against November to April", digits = 1, effect = TRUE, per = "a half-year",
    about = "\"Sell in May and go away\": May to October runs from the close of 30 April to the close of 31 October, and November to April from there to the close of the next 30 April."
  )
)
#' @title The periods of the seasonality analysis that compare a calendar effect of days with the rest
#' @description Their returns are those of the days, put in two groups by
#' [effect_days()].
#' @noRd
effect_day_periods <- c("turn", "santa")
#' @noRd
weekday_names <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
#' @noRd
cycle_names <- c("Halving year", "Halving + 1", "Halving + 2", "Halving + 3")
##########################################################################################
#
##########################################################################################
#' @title First and last day of the period of each date
#' @description Weeks run from Monday to Sunday, as in ISO 8601. Weekdays are
#' worked out from the date itself, not from the names of the locale.
#' @param date Dates.
#' @param period `"day"`, `"week"`, `"month"`, `"year"` or `"half"`, the
#'   halves of the year from May to October and from November to April.
#' @return A list with the `start` and the `end` of the period of each date.
#' @keywords internal
#' @examples
#' golemcrypto:::period_bounds(as.Date(c("2024-02-14", "2024-12-31")), "week")
period_bounds <- function(date, period) {
  date <- as.Date(date)
  year <- as.POSIXlt(date)$year + 1900
  month <- as.POSIXlt(date)$mon + 1
  start <- switch(period,
    day = date,
    week = date - (as.POSIXlt(date)$wday + 6) %% 7,
    month = as.Date(format(date, "%Y-%m-01")),
    year = as.Date(format(date, "%Y-01-01")),
    half = as.Date(ifelse(month %in% 5:10, paste0(year, "-05-01"), paste0(year - (month <= 4), "-11-01")))
  )
  end <- switch(period,
    day = date,
    week = start + 6,
    # the first of the next month, less a day
    month = as.Date(format(start + 31, "%Y-%m-01")) - 1,
    year = as.Date(format(date, "%Y-12-31")),
    half = {
      start_year <- as.POSIXlt(start)$year + 1900
      as.Date(ifelse(as.POSIXlt(start)$mon == 4, paste0(start_year, "-10-31"), paste0(start_year + 1, "-04-30")))
    }
  )
  list(start = start, end = end)
}
##########################################################################################
#
##########################################################################################
#' @title ISO 8601 week number of dates
#' @description Week 1 is the week, Monday to Sunday, with the first Thursday
#' of the year, so the last days of December can be in week 1 and the first
#' days of January in week 52 or 53 of the year before.
#' @param date Dates.
#' @return Integers from 1 to 53.
#' @keywords internal
#' @examples
#' golemcrypto:::iso_week(as.Date(c("2021-01-03", "2024-01-01", "2024-12-30")))
iso_week <- function(date) {
  date <- as.Date(date)
  thursday <- date - (as.POSIXlt(date)$wday + 6) %% 7 + 3
  as.integer(as.POSIXlt(thursday)$yday %/% 7 + 1)
}
##########################################################################################
#
##########################################################################################
#' @title The group of each day in a calendar effect
#' @description Puts each day in or out of a calendar effect. Coins trade
#' every day, so the days are those of the calendar:
#' \describe{
#'   \item{turn}{The turn of the month: the last day of a month and the
#'     first 3 of the next.}
#'   \item{santa}{The Santa rally: the last 5 days of December, from the
#'     27th, and the first 2 of January.}
#' }
#' @param date Dates.
#' @param period `"turn"` or `"santa"`.
#' @return A factor as long as `date`, the days in the effect first.
#' @keywords internal
#' @examples
#' days <- as.Date("2024-12-25") + 0:10
#' data.frame(days, group = golemcrypto:::effect_days(days, "santa"))
effect_days <- function(date, period = c("turn", "santa")) {
  period <- match.arg(period)
  date <- as.Date(date)
  day <- as.POSIXlt(date)$mday
  month <- as.POSIXlt(date)$mon + 1
  levels <- switch(period, turn = c("Turn of the month", "Rest of the month"), santa = c("Santa rally", "Other days"))
  inside <- switch(period,
    # the last day of a month is the one before the first of the next
    turn = day <= 3 | as.POSIXlt(date + 1)$mday == 1,
    santa = (month == 12 & day >= 27) | (month == 1 & day <= 2)
  )
  factor(ifelse(inside, levels[1], levels[2]), levels = levels)
}
##########################################################################################
#
##########################################################################################
#' @title The return of each complete period of a coin
#' @description A period's return is its last close relative to the last
#' close of the period before, in percent, as in [monthly_returns()]. Only
#' complete periods count: the period and the one before must both have a
#' close on their last day. The first period, which has none before it, the
#' current one, which has not ended, and the periods next to missing days
#' are left out.
#'
#' Each return is put in a group: the day of the week for days, the ISO 8601
#' week of the year for weeks (Monday to Sunday), the month for months, and
#' the year of the 4-year cycle of Bitcoin's halvings for years. The
#' halvings came in 2012, 2016, 2020 and 2024, so a year divisible by 4 is a
#' halving year and 2025 is "Halving + 1".
#'
#' The calendar effects put the returns in two groups: `"turn"` and
#' `"santa"` the returns of the days, in or out of the turn of the month or
#' the Santa rally (see [effect_days()]), and `"half"` the returns of the
#' halves of the year, May to October and November to April, of "Sell in May
#' and go away".
#' @param history Price history of one coin from [get_history()], with
#'   `timestamp` and `close` columns.
#' @param period `"day"`, `"week"`, `"month"` or `"year"`, or a calendar
#'   effect: `"turn"`, `"santa"` or `"half"`.
#' @return A data frame with a row per complete period, the oldest first:
#'   `start` and `end`, the first and last day of the period, `group`, a
#'   factor with the groups in their natural order, and `return_pct`.
#' @export
#' @examples
#' history <- data.frame(
#'   timestamp = as.Date("2024-01-01") + 0:120,
#'   close = 100 * cumprod(c(1, rep(1.002, 120)))
#' )
#' seasonal_returns(history, "month")
#' head(seasonal_returns(history, "day"))
seasonal_returns <- function(history, period = c("day", "week", "month", "year", "turn", "santa", "half")) {
  period <- match.arg(period)
  check_one_coin(history)
  history <- history[is.finite(history$close) & history$close > 0, ]
  history <- history[order(history$timestamp), ]
  if (period %in% effect_day_periods) {
    returns <- seasonal_returns(history, "day")
    returns$group <- effect_days(returns$start, period)
    return(returns)
  }
  date <- as.Date(history$timestamp)
  bounds <- period_bounds(date, period)
  # the last close of each period
  last <- !duplicated(bounds$start, fromLast = TRUE)
  start <- bounds$start[last]
  end <- bounds$end[last]
  last_date <- date[last]
  close <- history$close[last]
  n <- length(close)
  if (n < 2) {
    return(data.frame(start = as.Date(character()), end = as.Date(character()), group = factor(), return_pct = numeric()))
  }
  previous <- c(NA, seq_len(n - 1))
  complete <- c(FALSE, last_date[-1] == end[-1] & last_date[-n] == start[-1] - 1)
  returns <- data.frame(
    start = start,
    end = end,
    return_pct = (close / close[previous] - 1) * 100
  )[complete, ]
  returns$group <- switch(period,
    day = factor(weekday_names[(as.POSIXlt(returns$start)$wday + 6) %% 7 + 1], levels = weekday_names),
    week = factor(iso_week(returns$start), levels = 1:53),
    month = factor(month.abb[as.POSIXlt(returns$start)$mon + 1], levels = month.abb),
    year = factor(cycle_names[as.POSIXlt(returns$start)$year %% 4 + 1], levels = cycle_names),
    half = factor(ifelse(as.POSIXlt(returns$start)$mon == 4, "May to October", "November to April"),
                  levels = c("May to October", "November to April"))
  )
  rownames(returns) <- NULL
  returns[c("start", "end", "group", "return_pct")]
}
##########################################################################################
#
##########################################################################################
#' @title Seasonality analysis of a coin
#' @description Do some days of the week, weeks of the year, months or years
#' of the halving cycle bring better returns than others? The returns of the
#' complete periods (see [seasonal_returns()]) are summed up by group, and a
#' Kruskal-Wallis test asks whether the differences between the groups are
#' larger than chance would give. The test compares the ranks of the
#' returns, so a few extreme months do not decide it, but it takes the
#' returns as independent, which crypto returns are only roughly: calm and
#' wild stretches come in runs.
#'
#' The calendar effects (`"turn"`, `"santa"` and `"half"`, see
#' [seasonal_returns()]) have two groups, the returns in the effect and the
#' rest, for which the test is the same as a Wilcoxon rank-sum test.
#' @param history Price history of one coin from [get_history()], with all
#'   of it.
#' @param period `"day"`, `"week"`, `"month"` or `"year"`, or a calendar
#'   effect: `"turn"` (the turn of the month), `"santa"` (the Santa rally) or
#'   `"half"` (Sell in May).
#' @return `NULL` when the history has no complete period with one before
#'   it, or a list with:
#'   \describe{
#'     \item{coin, period}{What was analysed.}
#'     \item{returns}{The returns of [seasonal_returns()].}
#'     \item{groups}{A row per group that has returns, in their natural
#'       order: `group`, `returns` (how many), `mean_pct`, `median_pct`,
#'       `up_pct` (the share of the returns above 0), `best_pct` and
#'       `worst_pct`.}
#'     \item{all}{The same numbers for all the returns together, as a list.}
#'     \item{p_value}{The p-value of the Kruskal-Wallis test, `NA` when
#'       fewer than two groups have returns, or no group has two.}
#'   }
#' @export
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' analysis <- seasonality_analysis(btc, "month")
#' analysis$groups
#' analysis$p_value
#' seasonality_text(analysis)
seasonality_analysis <- function(history, period = c("day", "week", "month", "year", "turn", "santa", "half")) {
  period <- match.arg(period)
  returns <- seasonal_returns(history, period)
  if (nrow(returns) == 0) {
    return(NULL)
  }
  summarise <- function(x) {
    list(returns = length(x), mean_pct = mean(x), median_pct = stats::median(x), up_pct = mean(x > 0) * 100,
         best_pct = max(x), worst_pct = min(x))
  }
  groups <- droplevels(returns$group)
  rows <- lapply(split(returns$return_pct, groups), function(x) as.data.frame(summarise(x)))
  table <- data.frame(group = factor(levels(groups), levels = levels(groups)), do.call(rbind, rows), row.names = NULL)
  p_value <- if (nlevels(groups) >= 2 && any(table$returns >= 2)) {
    tryCatch(stats::kruskal.test(returns$return_pct, groups)$p.value, error = function(e) NA_real_)
  } else {
    NA_real_
  }
  # returns that are all the same give no statistic, and no difference between the groups
  if (is.nan(p_value)) p_value <- 1
  list(
    coin = unique(history$name_symbol),
    period = period,
    returns = returns,
    groups = table,
    all = summarise(returns$return_pct),
    p_value = p_value
  )
}
##########################################################################################
#
##########################################################################################
#' @title Number formats of the seasonality text
#' @noRd
p_text <- function(p) {
  if (p < 0.001) "p < 0.001" else paste("p =", format(signif(p, 2), scientific = FALSE))
}
#' @noRd
return_digits <- function(period) seasonality_periods[[period]]$digits
#' @noRd
group_label <- function(group, period) {
  switch(period,
    week = paste("week", group),
    month = month.name[match(as.character(group), month.abb)],
    as.character(group)
  )
}
#' @noRd
group_line <- function(row, period) {
  digits <- return_digits(period)
  label <- group_label(row$group, period)
  sprintf(
    "%s: mean %s%%, median %s%%, up %s of %s times (%s%%).",
    paste0(toupper(substr(label, 1, 1)), substring(label, 2)), signed(row$mean_pct, digits), signed(row$median_pct, digits),
    fmt(round(row$up_pct * row$returns / 100), 0), fmt(row$returns, 0), fmt(row$up_pct, 0)
  )
}
##########################################################################################
#
##########################################################################################
#' @title The seasonality analysis in words
#' @description Sentences built from the numbers of [seasonality_analysis()],
#' for the Seasonality tab: the best and the worst group, or for a calendar
#' effect its two groups, and whether the differences between the groups
#' could be chance.
#' @param analysis The result of [seasonality_analysis()].
#' @return A list with `groups` and `chance`, each with a `headline` and
#'   `points`, a character vector of sentences.
#' @export
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' seasonality_text(seasonality_analysis(btc, "day"))
seasonality_text <- function(analysis) {
  list(groups = seasonality_groups_text(analysis), chance = seasonality_chance_text(analysis))
}
##########################################################################################
#
##########################################################################################
#' @title The best and the worst group in words
#' @description By the mean return, among the groups with at least half the
#' returns of the largest group: week 53, which only some years have, would
#' otherwise often come first or last by luck. A calendar effect gives both
#' of its groups, however few the returns of the effect, and how the effect
#' is defined.
#' @param analysis The result of [seasonality_analysis()].
#' @return A list with a `headline` and `points`.
#' @keywords internal
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' golemcrypto:::seasonality_groups_text(seasonality_analysis(btc, "month"))
seasonality_groups_text <- function(analysis) {
  words <- seasonality_periods[[analysis$period]]
  digits <- return_digits(analysis$period)
  groups <- analysis$groups
  label <- function(group) group_label(group, analysis$period)
  all <- analysis$all
  together <- sprintf(
    "All %s %s together: mean %s%%, median %s%%, up %s%% of the time.",
    fmt(all$returns, 0), words$units, signed(all$mean_pct, digits), signed(all$median_pct, digits), fmt(all$up_pct, 0)
  )
  if (isTRUE(words$effect)) {
    # "rest of the month" in the middle of a sentence, but "November to April"
    lower <- function(text) if (analysis$period == "half") text else tolower(text)
    # the effect against the rest: both groups, however few the returns of the effect
    points <- c(vapply(seq_len(nrow(groups)), function(i) group_line(groups[i, ], analysis$period), ""), together, words$about)
    headline <- if (nrow(groups) == 2) {
      sprintf(
        "%s: mean %s%% %s; %s: %s%%",
        label(groups$group[1]), signed(groups$mean_pct[1], digits), words$per,
        lower(label(groups$group[2])), signed(groups$mean_pct[2], digits)
      )
    } else {
      sprintf("Only %s so far: mean %s%% %s", lower(label(groups$group[1])), signed(groups$mean_pct[1], digits), words$per)
    }
    return(list(headline = headline, points = points))
  }
  # a group with few returns, such as week 53, which only some years have, owes its rank to luck
  few <- groups$returns < max(groups$returns) / 2
  ranked <- groups[!few, ]
  best <- ranked[which.max(ranked$mean_pct), ]
  worst <- ranked[which.min(ranked$mean_pct), ]
  points <- c(
    group_line(best, analysis$period),
    if (nrow(ranked) > 1) group_line(worst, analysis$period),
    if (any(few)) {
      sprintf(
        "Left out of the best and the worst, with fewer than half the returns of the others: %s.",
        paste0(label(groups$group[few]), " (", groups$returns[few], ")", collapse = ", ")
      )
    },
    together,
    if (analysis$period == "year") {
      "The cycle follows Bitcoin's halvings, every four years: the halving years were 2012, 2016, 2020 and 2024, so Halving + 1 is 2013, 2017, 2021 and 2025."
    }
  )
  headline <- if (nrow(ranked) > 1) {
    sprintf(
      "Best %s: %s, mean %s%%; worst: %s, %s%%",
      if (analysis$period == "year") "year of the cycle" else words$unit,
      label(best$group), signed(best$mean_pct, digits), label(worst$group), signed(worst$mean_pct, digits)
    )
  } else {
    sprintf("Only %s so far: mean %s%%", label(best$group), signed(best$mean_pct, digits))
  }
  list(headline = headline, points = points)
}
##########################################################################################
#
##########################################################################################
#' @title Whether the differences could be chance, in words
#' @param analysis The result of [seasonality_analysis()].
#' @return A list with a `headline` and `points`.
#' @keywords internal
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' golemcrypto:::seasonality_chance_text(seasonality_analysis(btc, "month"))
seasonality_chance_text <- function(analysis) {
  words <- seasonality_periods[[analysis$period]]
  groups <- analysis$groups
  returns <- analysis$returns
  p <- analysis$p_value
  span <- sprintf(
    "The returns run from %s to %s: %s %s, %s per group.",
    long_date(min(returns$start)), long_date(max(returns$end)), fmt(nrow(returns), 0), words$units,
    if (min(groups$returns) == max(groups$returns)) fmt(min(groups$returns), 0) else paste(fmt(min(groups$returns), 0), "to", fmt(max(groups$returns), 0))
  )
  if (is.na(p)) {
    return(list(
      headline = paste("Too few", words$units, "to test"),
      points = c(span, sprintf("Testing whether the %s differ takes returns in at least two of them, and two in one.", words$groups))
    ))
  }
  luck <- if (isTRUE(words$effect)) {
    "The effect got its name in the stock market, and a pattern of the past need not hold: the crypto market has changed a lot since 2013."
  } else {
    sprintf(
      "With %d %s to pick from, the best one looks good partly by luck, and a pattern of the past need not hold: the crypto market has changed a lot since 2013.",
      nrow(groups), words$groups
    )
  }
  test <- sprintf(
    "A Kruskal-Wallis test asks whether the returns of the %s could all come from the same distribution: %s, so differences as large as these would turn up %s.",
    words$groups, p_text(p),
    if (p < 0.001) "less than once in 1,000 histories in which they did not matter" else sprintf("in about %s%% of histories in which they did not matter", fmt(p * 100, if (p < 0.01) 1 else 0))
  )
  list(
    headline = if (p < 0.05) {
      sprintf("The %s differ by more than chance usually gives (%s)", words$groups, p_text(p))
    } else {
      sprintf("The differences between the %s could well be chance (%s)", words$groups, p_text(p))
    },
    points = c(test, span, luck)
  )
}
##########################################################################################
#
##########################################################################################
#' @title The groups of a seasonality analysis, as one table
#' @description The table behind the CSV button of the Seasonality tab.
#' @param analysis The result of [seasonality_analysis()].
#' @return The `groups` of the analysis, with the period in front and the
#'   group column named after the period, such as `month`.
#' @keywords internal
#' @examples
#' btc <- get_history("Bitcoin (BTC)", as.Date("2013-04-29"))
#' golemcrypto:::seasonality_csv(seasonality_analysis(btc, "month"))
seasonality_csv <- function(analysis) {
  groups <- analysis$groups
  names(groups)[1] <- gsub(" ", "_", tolower(seasonality_periods[[analysis$period]]$group))
  groups
}
