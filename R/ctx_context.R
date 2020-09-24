# Helper functions to create context, which handles computational graph
#' TODO: check, if all the operations still exists
#' Thera are several potential solutions of this problem
#' TODO: variable names convention

#' TODO: context enironment should keep exact pointers to all the dlr objects
#' For example, if we create in global
#' x <- tensor(1:100, c(2, 50))
#' We create pointer to this object, which should prevent object removal.
#' We should do exactly the same in the case of local variables
#' However, there are still two main problems to solve:
#' * how to handle object assignmnet (like this y <- x)
#' * duplicated funs in the environmnet: we don't need hundreads copies of power function etc.
#' Possible solution: duplicated register: object register vs ops register (?)
#' See: http://adv-r.had.co.nz/Environments.html

#' @name aria_context
#' @title Create graph to track computations
#' @return external pointer (EXPTREXP)
#' @export
aria_context <- function(){
  ctx_container <- .Call(C_create_context)
  ctx <- new.env()
  ctx$container  <- ctx_container
  ctx$ops        <- list()
  ctx$paired_ops <- list()
  class(ctx) <- c("aria_context", "environment")
  return(ctx)
}

#' @name get_context
#' @title Get default dlr context
#' @export
get_context <- function(){
  getOption("aria_default_context")
}

#' @name reset_context
#' @title Reset context by removing all the objects from that
reset_context <- function(ctx = get_context()){

}

#' @name get_all_ops
#' @title Get all ops in context
#' @export
get_all_ops <- function(ctx){
  .Call(C_get_all_ops, ctx$container)
}

#' @name get_all_ops_ptr
#' @title Get all ops in context
#' @export
get_all_ops_ptr <- function(ctx){
  .Call(C_get_all_ops_ptr, ctx$container)
}

#' @name get_ops_number
#' @title Get operation number
#' @export
get_ops_number <- function(ptr) {
  .Call(C_get_ops_number, ptr)
}

#' @name get_r_ops
#' @title Get R operations
#' @export
get_r_ops <- function(ctx, number) {
  .Call(C_get_r_ops, ctx$container, number)
}

#' @name register_ops
#' @title Create an operation inside the context.
#' It may be a tensor or a function
#' @export
register_ops <- function(ctx, r_ops, paired_ops = NULL){
  ptr     <- .Call(C_register_ops, ctx[['container']], r_ops, paired_ops)
  ops.num <- get_ops_number(ptr)
  ctx$ops[[as.character(ops.num)]] <- r_ops
  if (!is.null(paired_ops))
    ctx$paired_ops[[as.character(ops.num)]] <- paired_ops
  if (inherits(r_ops, "aria_tensor"))
    set_tensor_xptr(r_ops, ptr)
  return(ptr)
}


#' @export
n_nodes <- function(ctx = get_context()) {
  .Call(C_n_nodes, ctx$container)
}
