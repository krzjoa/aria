#' @name compare_ptr
#' @title Compare two pointers
#' @param x external pointer
#' @param y external pointer
#' @examples
#' library(aria)
#' ctx <- get_context()
#' register_ops(ctx, cars)
#' register_ops(ctx, data.frame)
#' x <- cpu_tensor(5, dims = 1)
#' all_ops <- get_all_ops_ptr(ctx)
#' compare_ptr(x@pointer, all_ops[[3]])
#' @export
compare_ptr <- function(x, y){
  .Call(C_compare_ptr, x, y)
}

#' @name is_in_pointer_list
#' @title Check if externaptr object occurs in the given list of externalptrs
#' @param ptr externalptr object
#' @param ptr.list list of externalptr objects
#' @examples
#' library(aria)
#' ctx <- get_context()
#' register_ops(ctx, cars)
#' register_ops(ctx, data.frame)
#' x <- cpu_tensor(5, dims = 1)
#' y <- x ** 3
#' all_ops <- get_all_ops_ptr(ctx)
#' is_in_pointer_list(aria$xptr,  all_ops)
#' @export
is_in_pointer_list <- function(ptr, ptr.list){
  any(unlist(Map(function(x) compare_ptr(x, ptr), ptr.list)))
}

#' @name get_aria_pointer
#' @title Retun pointer to soprano graph's nodes
#' @description If obj is a pointer, it returns obj.
get_aria_pointer <- function(obj){
  if (inherits(obj, "aria_tensor"))
    return(obj$xptr)
  else
    return(obj)
}
