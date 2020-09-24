#include "context.h"
#include <R.h>
#include <Rinternals.h>
#include <Rdefines.h>
#include <stdio.h>
#include <R_ext/Rdynload.h>

//' Initializing DLL library
//' * https://github.com/Rdatatable/data.table/blob/a8ec94484d2cc375d8295a94bacc5353576c238a/src/init.c
  //' * https://github.com/randy3k/xptr/blob/master/src/xptr.c
//' * https://github.com/tidyverse/purrr/blob/master/src/init.c
//' * R_registerRoutines
//' * https://www.r-bloggers.com/2018/01/making-your-c-less-noteworthy/
//' * consider vctrs api https://github.com/tidyverse/purrr/blob/master/src/utils.h

static const R_CallMethodDef CallEntries[] = {
  // Ops
  {"C_get_inputs",           (DL_FUNC) &C_get_inputs,           1}, // co oznacza ta ostatnia wartość = liczba argumentów
  {"C_get_outputs",          (DL_FUNC) &C_get_outputs,          1},
  {"C_get_ops_number",       (DL_FUNC) &C_get_ops_number,       1},
  {"C_get_object",           (DL_FUNC) &C_get_object,           1},
  {"C_get_paired_object",    (DL_FUNC) &C_get_paired_object,    1},
  {"C_is_root",              (DL_FUNC) &C_is_root,              1},
  // Aria context
  {"C_create_context",       (DL_FUNC) &C_create_context,      -1},
  {"C_register_ops",         (DL_FUNC) &C_register_ops,         3},
  {"C_get_r_ops",            (DL_FUNC) &C_get_r_ops,            2},
  {"C_n_nodes",              (DL_FUNC) &C_n_nodes,              1},
  {"C_get_all_ops",          (DL_FUNC) &C_get_all_ops,          1},
  {"C_get_all_ops_ptr",      (DL_FUNC) &C_get_all_ops_ptr,      1},
  {"C_add_input",            (DL_FUNC) &C_add_input,            2},
  {"C_add_output",           (DL_FUNC) &C_add_output,           2},
  // Utils
  {"C_compare_ptr",          (DL_FUNC) &C_compare_ptr,          2},
  {"C_adjacency_matrix",     (DL_FUNC) &C_adjacency_matrix,     1},
  // Tensor utils
  {"C_set_tensor_attribute", (DL_FUNC) &C_set_tensor_attribute, 3},
  //{"C_set_tensor_grad",     (DL_FUNC) &C_set_tensor_grad,    2},
  //{"C_set_tensor_pointer",  (DL_FUNC) &C_set_tensor_pointer, 2},
  //{"C_set_slot",            (DL_FUNC) &C_set_slot,           3},

  {NULL, NULL, 0}
};

void R_init_aria(DllInfo *dll){
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE); // ?
}
