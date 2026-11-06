# Small offline data shaped like the downloads, so the tests need no internet

# keep the downloads of the tests out of the user's cache folder
options(crypto.cache_dir = tempfile("crypto-cache-"))

coins <- data.frame(
  id = 1:2,
  name = c("Alpha", "Beta"),
  symbol = c("A", "B"),
  name_symbol = c("Alpha (A)", "Beta (B)")
)

# Beta starts a month after Alpha
history <- data.frame(
  name = rep(c("Alpha", "Beta"), c(4, 3)),
  symbol = rep(c("A", "B"), c(4, 3)),
  name_symbol = rep(c("Alpha (A)", "Beta (B)"), c(4, 3)),
  timestamp = as.Date(c(
    "2024-01-31", "2024-02-29", "2024-03-01", "2024-03-31",
    "2024-02-29", "2024-03-01", "2024-03-31"
  )),
  close = c(100, 110, 99, 121, 50, 55, 25)
)
history$open <- history$close
history$high <- history$close * 1.1
history$low <- history$close * 0.9
history$volume <- 1000

listings <- data.frame(
  name_symbol = c("Alpha (A)", "Beta (B)", "Gamma (C)"),
  USD_price = c(121, 25, 0.00001234),
  USD_volume_24h = c(1e9, 5e8, 1e3),
  USD_volume_change_24h = c(1.5, -2, NA),
  USD_percent_change_24h = c(2.5, -4, NA),
  USD_percent_change_7d = c(10, -1, 3),
  USD_percent_change_30d = c(-5, 20, 0),
  USD_percent_change_60d = c(7, -12, 1),
  USD_percent_change_90d = c(30, -40, 2),
  USD_market_cap = c(2e12, 3e11, NA),
  USD_market_cap_dominance = c(60, 9, 0),
  USD_fully_diluted_market_cap = c(2.1e12, 3e11, 1e6),
  USD_last_updated = "2024-03-31T12:00:00.000Z"
)

# a coin of 900 days whose returns follow a GARCH(1,1) model, so the analysis has a model to find
garch_history <- function(days = 900, last = NULL, seed = 1) {
  set.seed(seed)
  r <- numeric(days)
  variance <- 4
  for (t in seq_len(days)) {
    r[t] <- sqrt(variance) * stats::rt(1, df = 5) / sqrt(5 / 3)
    variance <- 0.2 + 0.1 * r[t]^2 + 0.85 * variance
  }
  if (!is.null(last)) r[days - seq_along(last) + 1] <- rev(last)
  data.frame(
    name_symbol = "Alpha (A)",
    timestamp = as.Date("2022-01-01") + 0:days,
    close = 100 * exp(cumsum(c(0, r / 100)))
  )
}
