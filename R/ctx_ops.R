# Functions, which arguments are R objects such as functions and tensors

# Abstract function
# .call_soprano <- function(ops){
#   if(is.null(ops))
#     return(NULL)
#   .Call(get_soprano_pointer(ops_ptr))
# }

#' @name get_object
#' @title Get paired operatin such as function derivative
#' @export
get_object <- function(ops.ptr){
  .Call(C_get_object, ops.ptr)
}

#' @name get_paired_object
#' @title Get paired operatin such as function derivative
#' @export
get_paired_object <- function(ops_ptr){
  .Call(C_get_paired_object, get_aria_pointer(ops_ptr))
}

#' Function for getting artificial number of the operation
#' @name add_input
#' @title Add node inputs
#' @export
add_input <- function(ops, input){
  .Call(C_add_input, ops, input)
}

#' @name add_output
#' @title Add node inputs
#' @export
add_output <- function(ops, output){
  .Call(C_add_output, ops, output)
}

#' @name get_inputs
#' @title Get operation inputs
#' @export
get_inputs <- function(ops_ptr) {
  .Call(C_get_inputs, get_aria_pointer(ops_ptr))
}

#' @name get_outputs
#' @title Get operation inputs
#' @export
get_outputs <- function(ops_ptr) {
  .Call(C_get_outputs, get_aria_pointer(ops_ptr))
}

#' @name is_root
#' @title Check, if the current node is root
#' @export
is_root <- function(ops_ptr){
  .Call(C_is_root, ops_ptr)
}

#' TODO: rename input and output
#' FIXME: it's probably a crucial function!
#' @name connect
#' @title Connect tensors and functions to track computational chain.
#' It's needed to compute gradients
#' @param input Input operations (tensors or functions)
#' @param output Output operations (tensors or functions)
connect <- function(input, output){
  # return(NULL)
  # browser()
  # Wrap inputs and outputs with lists
  if (!inherits(input, "list"))
    input <- list(input)
  if (!inherits(output, "list"))
    output <- list(output)
  # Suboptimal implementation with ordinary R for loop
  for (inp in input) {
    inp <- get_aria_pointer(inp)
    for (out in output) {
      out <- get_aria_pointer(out)
      add_output(inp, out)
      add_input(out, inp)
    }
  }
}

#' @name reassign_ops
#' @title Workaround for the copy-on-modify case
#' TODO: Does only tensors are impacted by this problem
#' @export
reassign_ops <- function(ops){
  if (inherits(ops, "cpu_tensor")){
    #if (!identical(get_r_ops(get_context(), get_ops_number(ops@pointer)), ops)) {
    ops$xptr <- register_ops(get_context(), ops)
    #}
  }
  return(ops)
}

#' @examples
#' library(dlr)
#' ctx <- get_context()
#'
#' # Arithmetic operations
#' x <- cpu_tensor(5, dims = 1)
#' y <- x ** 3
#'
#' # Show context
#' n_nodes()
#' get_all_ops(get_context())
#' all.ops <- get_all_ops_ptr(get_context())
#'
#' get_r_ops(get_context(), 4)
#' get_r_ops(get_context(), 7)
#'
#' get_input_ptr(all.ops[[3]])
#'
#' get_inputs(all.ops[[2]])
#' get_outputs(all.ops[[2]])
#'
#' # Adding links to nodes
#' .add_node_inputs(ctx, 13, as.integer(c(20, 45)))
#' .get_linked_nodes(ctx, 13)
#'
#' # Not working! :get_inputs(x)
#' y
# backward(y)
