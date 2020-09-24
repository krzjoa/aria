#include "context.h"

// Helper function, move to another file
int match_index_int(SEXP int_list, int value){
   int list_length = length(int_list);
   for(int i=0; i<list_length; i++){
      if (INTEGER(int_list)[i] == value)
         return i;
   }
   return -1;
}

// Consider using typedef, but it may be confusing
int find_connection(SEXP Dlr_context, struct Ops* first_ops_ptr, struct Ops* second_ops_ptr){
  struct Link* current_link = first_ops_ptr->inputs_header;
  while(current_link){
    if (current_link->contained->number == second_ops_ptr->number){
      return 1;
    }
    current_link = current_link->next;
  }
  return 0;
}

/* @name C_compare_ptr
 * @title Check if two pointers are the same
 * @param x external pointer
 * @param y external pinter
 * @return logical: are pointers the same?
 */
SEXP C_compare_ptr(SEXP x, SEXP y){
  return Rf_ScalarLogical(R_ExternalPtrAddr(x) == R_ExternalPtrAddr(y));
}

/*
 * Get adjacency matrix for all the operations in the context
 */
SEXP C_adjacency_matrix(SEXP ctx){
 CAST_PTR(context, AriaContext, ctx);

 if (!context->head)
   return R_NilValue;

 SEXP adj_mat = PROTECT(allocMatrix(INTSXP, context->V, context->V));
 SEXP ops_names = PROTECT(allocVector(INTSXP, context->V));
 struct Ops* ops_pointers[context->V];

 // Loop over all the ops
 struct Link *current_link = context->head;
 int current_index = 0;

 // Get allthe names
 // TODO: export this fragment to separate function
 while(current_link){
   INTEGER(ops_names)[current_index] = current_link->contained->number;
   ops_pointers[current_index] = current_link->contained;
   current_link = current_link->next;
   current_index++;
 }

 // Setting dimnaes
 SEXP dimnames = PROTECT(allocVector(VECSXP, 2));
 SET_VECTOR_ELT(dimnames, 0, ops_names);
 SET_VECTOR_ELT(dimnames, 1, ops_names);
 setAttrib(adj_mat, R_DimNamesSymbol, dimnames);

 // Looping over all the nodes to get adjacencies
 current_link = context->head;
 current_index = 0;

 // Casted R matrix
 int* int_matrix = INTEGER(adj_mat);
 int* ops_names_int = INTEGER(ops_names);

 // TODO: check length(dimnames) vs int mat_length = length(dimnames);
 // Iterate over all the 'cells' in the matrix
 for (int row=0; row < length(ops_names); row++){
    for (int col=0; col < length(ops_names); col++){
       // Getting right value to set
       int_matrix[row * length(ops_names) + col] = find_connection(ctx, ops_pointers[row], ops_pointers[col]);
    }
 }

 // TODO: add attribute with list of pointers
  UNPROTECT(3);
  return adj_mat;
}




