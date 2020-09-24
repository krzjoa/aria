#' @name cpu_tensor
#' @title Create `aria` tensor of arbitrary shapes
#' @description Tensor abstraction, an interface for CPU and CUDA tensors.
#' @param data numeric vector, array or data.frame
#' @param dims Dimensions
#' @param requires_grad is gradient required; logical
#' @importFrom rray rray
#' @importFrom vctrs new_vctr
#' @examples
#' library(aria)
#' x <- cpu_tensor(1:30, c(3, 10))
#' @export
cpu_tensor <- function(data, dims, requires_grad = FALSE){

  data_tensor <- rray(
    x = data,
    dim = dims
  )

  .abstract_tensor(
    data = data_tensor,
    dims = dims,
    requires_grad = requires_grad,
    .class = 'aria_cpu_tensor'
  )
}

#' @name empty_cpu_tensor
#' @title Create empty cpu_tensor
#' @export
empty_cpu_tensor <- function(){
  cpu_tensor(numeric(0), dim = 0)
}

#' @name scalar
#' @title CPU tensor
#' @export
scalar <- function(x){
  cpu_tensor(
    data          = x,
    dims          = 1,
    requires_grad = FALSE
  )
}

# data = data_tensor,
# dims  = dims,
# grad  = NULL,
# xptr  = xptr::null_xptr(),
# requires_grad = requires_grad

#' @name set_tensor_param
#' @title Set tensor parameter
#' @param tensor
#' @param param_position
#' @param value
#' @export
set_tensor_param <- function(tensor, param_position, value){
  .Call(C_set_tensor_attribute, tensor, param_position - 1, value)
}

#' @export
set_tensor_data <- function(tensor, value){
  set_tensor_param(tensor, 1, value)
}

#' @export
set_tensor_dims <- function(tensor, value){
  set_tensor_param(tensor, 2, value)
}

#' @export
set_tensor_grad <- function(tensor, value){
  set_tensor_param(tensor, 3, value)
}

set_tensor_xptr <- function(tensor, value){
  set_tensor_param(tensor, 4, value)
}

set_tensor_requires_grad <- function(tensor, value){
  set_tensor_param(tensor, 5, value)
}

# Co to jest dynamic lookup?
# DLL name: purrr
# Filename: /home/krzysztof/R/x86_64-pc-linux-gnu-library/3.6/purrr/libs/purrr.so
# Dynamic lookup: FALSE
