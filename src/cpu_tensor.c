#include "context.h"

/*
 * Additional, inplace operations for CPU tensors
 */

// Sprawdź, jaką wartość ma XLENGTH(position)
// Przypisuje do złej pozycji
SEXP C_set_tensor_attribute(SEXP tensor, SEXP position, SEXP value){
  SET_VECTOR_ELT(tensor, asInteger(position), value);
  return tensor;
}
