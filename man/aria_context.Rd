% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ctx-context.R
\name{aria_context}
\alias{aria_context}
\title{Create graph to track computations}
\usage{
aria_context()
}
\value{
external pointer (EXPTREXP)
}
\description{
TODO: check, if all the operations still exists
Thera are several potential solutions of this problem
TODO: variable names convention
TODO: context enironment should keep exact pointers to all the dlr objects
For example, if we create in global
x <- tensor(1:100, c(2, 50))
We create pointer to this object, which should prevent object removal.
We should do exactly the same in the case of local variables
However, there are still two main problems to solve:
* how to handle object assignmnet (like this y <- x)
* duplicated funs in the environmnet: we don't need hundreads copies of power function etc.
Possible solution: duplicated register: object register vs ops register (?)
See: http://adv-r.had.co.nz/Environments.html
}
