#' Arithmetic operations
#'  "+", "-", "*", "^", "%%", "%/%", "/"
#' Dictionary:
#' x, y - inputs
#' result - cached operation result
#' grad - gradinet from previous result

#' @export
vec_arith.aria_tensor <- function(op, x, y, ...) {
  UseMethod("vec_arith.aria_tensor", y)
}

# =============================================================================================== #
#                                         TENSOR - TENSOR                                         #
# =============================================================================================== #

#' Abstract function for tensor-numeric operations
#' Backward function rather than partial derivative?
#' Problem: newly created tensor has by default
#  The simpliest solution is may be potentially dangerous and does not handle
#  simple R operations such as x <- y
#  See: https://www.brodieg.com/2019/02/18/an-unofficial-reference-for-internal-inspect/

#' Maybe we don't need to track some 'abstract tensors'
#' Memoisation can handle this case instead

.abstract_operator <- function(fun, deriv, x, y){
  # Propagate requires_grad
  requires_grad <- any(x$requires_grad,
                       y$requires_grad)

  .fun   <- register_ops(get_context(), fun, deriv)
  connect(list(x, y), .fun)

  output <- empty_cpu_tensor() # Use abstraction: empty_aria_tensor
  set_tensor_requires_grad(output, requires_grad)
  set_tensor_data(output, fun(x$data, y$data))
  # x <- reassign_ops(x)
  connect(.fun, output)
  output
}

#' ============================================================== #
#'                              ADDITION                          #
#' ============================================================== #
#' Problem:
#' We don't want to recreate functions
#' Should we use 'temporal' context?
.addition <- function(x, y) x + y
.addition_deriv <- list(
  x = function(x, y, result, grad) grad,
  y = function(x, y, result, grad) grad
)

.arith_addition <- function(x, y){
  .abstract_operator(.addition, .addition_deriv, x, y)
}

#' ============================================================== #
#'                          SUBTRACTION                           #
#' ============================================================== #
.subtraction <- function(x, y) x - y
.subtraction_deriv <- list(
  x = function(x, y, result, grad) grad,
  y = function(x, y, result, grad) -grad
)

.arith_subtraction <- function(x, y){
  .abstract_operator(.subtraction, .subtraction_deriv, x, y)
}

#' ============================================================== #
#'                          MULTIPLICATION                        #
#' ============================================================== #
.multiplication <- function(x, y) x * y
.multiplication_deriv <- list(
  x = function(x, y, result, grad) y * grad,
  y = function(x, y, result, grad) x * grad
)

.arith_multiplication<- function(x, y){
  .abstract_operator(.multiplication, .multiplication_deriv, x, y)
}

#' ============================================================== #
#'                              DIVISION                          #
#' ============================================================== #
.division <- function(x, y) x / y
.division_deriv <-list(
  x = function(x, y, result, grad) grad / y,
  y = function(x, y, result, grad) - grad * x / y**2  # check operations order
)

.arith_division <- function(x, y){
  .abstract_operator(.division, .division_deriv, x, y)
}

#' ============================================================== #
#'                              POWER                             #
#' ============================================================== #
#' Problem:
#' We don't want to recreate functions
#' Should we use 'temporal' context?
.power <- function(x, y) x ** y
.power_deriv <- list(
  x = function(x, y, result, grad) y * (x ** (y - 1)) * grad,
  y = function(x, y, result, grad) result * log(x) * grad
)

.arith_power <- function(x, y){
  .abstract_operator(.power, .power_deriv, x, y)
}

#' @export
vec_arith.aria_tensor.aria_tensor <- function(op, x, y, ...) {
  switch(op,
         `+`  = .arith_addition(x, y),
         `-`  = .arith_subtraction(x, y),
         `*`  = .arith_multiplication(x, y),
         `/`  = .arith_division(x, y),
         `^`  = .arith_power(x, y),
         # TODO:
         `%%` = .arith_power(x, y),
         `%/%` =.arith_power(x, y),
         stop_incompatible_op(op, x, y)
  )
}

# =============================================================================================== #
#                                        NUMERIC - TENSOR                                         #
# =============================================================================================== #
#' @export
vec_arith.numeric.aria_tensor <- function(op, x, y, ...) {
  x <- scalar(x)
  .Primitive(op)(x, y)
}
#' @export
vec_arith.double.aria_tensor <- function(op, x, y, ...) {
  x <- scalar(x)
  .Primitive(op)(x, y)
}
# =============================================================================================== #
#                                        TENSOR - NUMERIC                                         #
# =============================================================================================== #
#' @export
vec_arith.aria_tensor.numeric <- function(op, x, y, ...) {
  y <- scalar(y)
  .Primitive(op)(x, y)
}
#' @export
vec_arith.aria_tensor.double <- function(op, x, y, ...) {
  y <- scalar(y)
  .Primitive(op)(x, y)
}

