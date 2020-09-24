# nocov start
.onLoad <- function(libname, pkgname){
  # Create global graph to track all the operations
  options("aria_default_context" = aria_context())
}

# nocov end
