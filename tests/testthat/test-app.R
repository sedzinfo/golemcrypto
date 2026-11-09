test_that("Google Analytics and its cookie banner are in the page only when asked for", {
  page <- function(analytics) htmltools::renderTags(app_ui(coins, "Alpha (A)", analytics = analytics))
  with <- page(TRUE)
  expect_match(with$head, "https://sedzinfo.github.io/consent.js", fixed = TRUE)
  expect_match(with$head, "www/analytics.js", fixed = TRUE)
  expect_match(with$html, "#cookie-settings", fixed = TRUE)
  without <- page(FALSE)
  expect_no_match(without$head, "consent.js", fixed = TRUE)
  expect_no_match(without$html, "cookie-settings", fixed = TRUE)
})

test_that("the keep-alive pings can be turned off", {
  page <- function(keep_alive) htmltools::renderTags(app_ui(coins, "Alpha (A)", keep_alive = keep_alive))
  on <- page(TRUE)
  expect_match(on$head, "www/keep_alive.js", fixed = TRUE)
  expect_match(on$html, "id=\"keep_alive\"", fixed = TRUE)
  off <- page(FALSE)
  expect_no_match(off$head, "keep_alive.js", fixed = TRUE)
  expect_no_match(off$html, "keep_alive", fixed = TRUE)
})

test_that("the head has the description and the address of the live app for link previews", {
  head <- htmltools::renderTags(app_ui(coins, "Alpha (A)"))$head
  expect_match(head, paste0("<meta name=\"description\" content=\"", app_meta$description, "\"/>"), fixed = TRUE)
  expect_match(head, "<meta property=\"og:url\" content=\"https://sedzinfo-golemcrypto.share.connect.posit.cloud/\"/>", fixed = TRUE)
  # search engines cut descriptions longer than about 160 characters
  expect_lte(nchar(app_meta$description), 160)
})
