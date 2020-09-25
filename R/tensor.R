#' @name tensor
#' @title Create `aria` tensor of arbitrary shapes
#' @description Tensor abstraction, an interface for CPU and CUDA tensors.
#' @param data numeric vector, array or data.frame
#' @param dims Dimensions
#' @param requires_grad is gradient required; logical
#' @importFrom rray rray
#' @importFrom vctrs new_vctr
#' @examples
#' library(aria)
#' x <- tensor(1:30, c(3, 10))
tensor <- function(data, dims, requires_grad = FALSE){
  .tensor <- getOption("aria_backend")
  .tensor(data, dims, requires_grad = FALSE)
}

#' @name empty_tensor
#' @title Create empty cpu_tensor
#' @export
empty_tensor <- function(){
  tensor(numeric(0), dim = 0)
}

#' @name scalar
#' @title A shortcut to create scalar as `aria_tensor`
#' @param x A single numeric
#' @return An instance of `aria_tensor`
#' @description
#' You don't have to use scalar explicitly.
#' @examples
#' x <- scalar(2)
#' x
#' @export
scalar <- function(x){
  tensor(
    data          = x,
    dims          = 1,
    requires_grad = FALSE
  )
}
