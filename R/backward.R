#' https://towardsdatascience.com/pytorch-autograd-understanding-the-heart-of-pytorchs-magic-2686cd94ec95
#' https://www.cs.toronto.edu/~rgrosse/courses/csc321_2018/slides/lec10.pdf
#' http://www.cs.toronto.edu/~rgrosse/courses/csc421_2019/readings/L06%20Automatic%20Differentiation.pdf
#' https://j-towns.github.io/2017/06/12/A-new-trick.html
#' See: https://pytorch.org/docs/stable/autograd.html
#' https://github.com/HIPS/autograd/blob/master/autograd/numpy/numpy_vjps.py

#' @name backward
#' @title This function traverses the graph back and computes all the gradients where it's needed
#' @param ops tensor
#' @param gradient
#' TODO: potentially hard to handle: dimshuffles etc.
#' TODO: transform into S4 method
#'
#' TODO: unify names ops vs ops_ptr
#' TODO: flatten graph(?)
#'
#' We need to propagate information, if gradient is required or not
#' @examples
#' library(dlr)
#' ctx <- get_context()
#' register_ops(ctx, cars)
#' register_ops(ctx, data.frame)
#' x <- cpu_tensor(5, dims = 1)
#' y <- (x ** 3) / 2
#' bkw_fun <- get_inputs(y)[[1]]
#' get_paired_object(bkw_fun)
#' all.ops <- get_all_ops_ptr(ctx)
#' backward(y, 1)
#' TODO: sposób iteracji - obecnie idziemy jak najbardziej wgłąb
#' TODO: powstają jakieś niezamiezone kopie tensorów - gdzie i kiedy?
#' @export
backward <- function(ops, gradient){
  #' For simplicity, suppose we have only
  #' one sequence of operations
  #' if (!inherits(ops, "cpu_tensor"))
  #'   stop("Error!")

  if (is.null(ops))
    return(NULL)

  # Tensors has only one "inputs", i.e. backward functions
  if (inherits(ops, "aria_tensor")) {
    inputs <- get_inputs(ops)
    .backward_function <- inputs[[1]]
    backward(.backward_function, gradient)
    return(NULL)
  # if (inherits(ops, "function"))
  } else {
      inputs  <- get_inputs(ops)
      deriv   <- get_paired_object(ops)
      .result <- get_object(get_outputs(ops)[[1]])

      if (is.null(deriv))
        return(NULL)

    #' For every input to the function
    #' 1. Find all the argumnets
    #' 2. Get matching function
    for (inp in seq_along(deriv)) {
      deriv_at <- deriv[[inp]]
      .x <- get_object(inputs[[1]])
      .y <- get_object(inputs[[2]])
      .result <- get_object(get_outputs(ops)[[1]])$data
      .grad <- deriv_at(.x$data, .y$data, .result, gradient)
      .ops <- inputs[[inp]]
      .obj <- get_object(.ops)
       set_tensor_grad(.obj, .grad)
      # Shortcut: we jump over the tensor to the backward function
      .backward_function <- get_inputs(.ops)[[1]]
      backward(.backward_function, .grad)
    }
  }
}

#' backward.function and backwad.cpu_tensor
#' backward.externalptr instead of functions
