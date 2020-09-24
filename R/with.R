#' @name with_context
#' @title Temporarily modifies the used context
#' @param ctx An `aria_context` object
#' @param code `aria` expressions to execute
#' with the chosen context
#' @return The results of the evaluation of
#' the `aria` expressions in the selected context
with_context <- function(ctx, code){
  with_options(
    list("aria_default_context"),
    code
  )
}

#' @name with_scope
#' @title Temporarily modifies the used scope name
#' @param ctx An `aria_context` object
#' @param code `aria` expressions to execute
#' with the chosen context
#' @return The results of the evaluation of
#' the `aria` expressions in the selected context
with_scope <- function(ctx, code){
  with_options(
    list("aria_current_scope"),
    code
  )
}
