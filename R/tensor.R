#' @name tensor
#' @title Abstract tensor
.abstract_tensor <- function(data, dims, grad, .class, requires_grad){

  struct <- list(
    data = data,
    dims  = dims,
    grad  = NULL,
    xptr  = xptr::null_xptr(),
    requires_grad = requires_grad
  )

  .tensor <-  new_vctr(
    .data = struct,
    class = c("aria_tensor", .class)
  )

  # Adding tensor
  ctx <- get_context()
  register_ops(ctx, .tensor)

  .tensor
}
