#include "context.h"

struct Ops;

void _Ops_finalizer(SEXP ext){
  // struct Ops *ptr = (struct Ops*) R_ExternalPtrAddr(ext);
  CAST_PTR(ops, Ops, ext);
  // If real object, remove whole chain
  // free_chain()
  // Temporary!!!!
  // Free(ops);
}

// This function should neve be called outside of the context
struct Ops* create_Ops(int node_no, SEXP R_ops, SEXP R_paired_ops){
  struct Ops* ops = (struct Ops*) calloc(1, sizeof(struct Ops));
  ops->number = node_no;
  ops->R_ops = R_ops;
  ops->R_paired_ops = R_paired_ops;
  ops->inputs_counter = 0;
  ops->outputs_counter = 0;
  return ops;
}

// Combine with add_output_Ops
void add_input_Ops(struct Ops* ops, struct Ops* input_ops){
  ops->inputs_counter++;
  if(!ops->inputs_header)
    ops->inputs_header = create_Link(input_ops, NULL);
  else
    last_link(ops->inputs_header)->next = create_Link(input_ops, NULL);
  // append_link(ops->inputs_header, input_ops, &(ops->inputs_counter));
}

void add_output_Ops(struct Ops* ops, struct Ops* output_ops){
  ops->outputs_counter++;
  if(!ops->outputs_header)
    ops->outputs_header = create_Link(output_ops, NULL);
  else
    last_link(ops->outputs_header)->next = create_Link(output_ops, NULL);
  //append_link(ops->outputs_header, output_ops, &(ops->outputs_counter));
}

SEXP C_get_ops_number(SEXP ops_ptr){
  CAST_PTR(ptr, Ops, ops_ptr);
  return ScalarInteger(ptr->number);
}

SEXP C_get_inputs(SEXP ops_ptr){
  CAST_PTR(ops, Ops, ops_ptr);
  return get_list(ops->inputs_header, ops->inputs_counter);
}

SEXP C_get_outputs(SEXP ops_ptr){
  CAST_PTR(ops, Ops, ops_ptr);
  return get_list(ops->outputs_header, ops->outputs_counter);
}

/*
 * Get contained R object from Ops
 */
SEXP C_get_object(SEXP ops_ptr){
  CAST_PTR(ops, Ops, ops_ptr);
  if(!ops->R_ops)
    return R_NilValue;
  return ops->R_ops;
}

SEXP C_get_paired_object(SEXP ops_ptr){
  CAST_PTR(ops, Ops, ops_ptr);
  if(!ops->R_paired_ops)
    return R_NilValue;
  return ops->R_paired_ops;
}

/*
 * Check, if operation is a root node
 * Node is a root node if it has no 'inputs'
 */
SEXP C_is_root(SEXP ops_ptr){
  CAST_PTR(ops, Ops, ops_ptr);
  return ScalarLogical((int) (ops->inputs_header == NULL));
}

// Free all the virtual objects from the inputs and their inputs
// It can be real object only
void free_chain(struct Ops* ops){
  // Check, if object is 'real'
  // free_chain recursively till reaching a real object
}
