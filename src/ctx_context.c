#include "context.h"

// Transform to OpsContainer or something like that;
struct AriaContext;

static void _AriaContext_finalizer(SEXP ext)
{
  CAST_PTR(ptr, AriaContext, ext);
  Free(ptr);
  // TODO: free all the children?
}

SEXP C_create_context(){
  struct AriaContext* context = (struct AriaContext*) malloc(sizeof(struct AriaContext));
  context->V = 0;
  context->head = NULL;
  SEXP ptr_graph = PROTECT(R_MakeExternalPtr(context, R_NilValue, R_NilValue));
  R_RegisterCFinalizerEx(ptr_graph, _AriaContext_finalizer, TRUE);
  UNPROTECT(1);
  return ptr_graph;
}

// Create an operation and add it to the context
SEXP C_register_ops(SEXP AriaContext_ptr, SEXP R_ops, SEXP R_paired_ops){
  CAST_PTR(context, AriaContext, AriaContext_ptr);
  // Increment ops counter
  (context)->V++;
  int val = context->V;
  // New Ops
  struct Ops *new_ops = create_Ops(val, R_ops, R_paired_ops);
  // New link
  struct Link *new_link = create_Link(new_ops, NULL);
  if (!context->head)
    context->head = new_link;
  else
    last_link(context->head)->next = new_link;

  // Transform into the ExternalPointer
  SEXP new_ops_ptr = PROTECT(R_MakeExternalPtr(new_ops, R_NilValue, R_NilValue));
  R_RegisterCFinalizerEx(new_ops_ptr, _Ops_finalizer, TRUE);
  UNPROTECT(1);

  return new_ops_ptr;
}

SEXP C_get_r_ops(SEXP AriaContext_ptr, SEXP number){
  CAST_PTR(context, AriaContext, AriaContext_ptr);
  int int_number = asInteger(number);
  struct Link *current_link = context->head;
  while(current_link){
    if (current_link->contained->number == int_number)
      return current_link->contained->R_ops;
    current_link = current_link->next;
  }
  return R_NilValue;
}

struct Ops* get_ops(SEXP AriaContext_ptr, SEXP number){
    CAST_PTR(context, AriaContext, AriaContext_ptr);
  int int_number = asInteger(number);
  struct Link *current_link = context->head;
  while(current_link){
    if (current_link->contained->number == int_number)
      return current_link->contained;
    current_link = current_link->next;
  }
  return NULL;
}

SEXP C_n_nodes(SEXP AriaContext_ptr){
  CAST_PTR(context, AriaContext, AriaContext_ptr);
  return ScalarInteger(context->V);
}

SEXP C_get_all_ops(SEXP AriaContext_ptr){
  CAST_PTR(context, AriaContext, AriaContext_ptr);

  if (!context->head)
    return R_NilValue;

  SEXP out = PROTECT(allocVector(INTSXP, context->V));

  struct Link *current_link = context->head;
  int current_index = 0;

  while(current_link){
    INTEGER(out)[current_index] = current_link->contained->number;
    current_link = current_link->next;
    current_index++;
  }

  UNPROTECT(1);
  return out;
}


/*
 * @return EXPTR (Ops)
 */
SEXP C_get_all_ops_ptr(SEXP AriaContext_ptr){
  CAST_PTR(context, AriaContext, AriaContext_ptr);

  if (!context->head)
    return R_NilValue;

  SEXP out = PROTECT(allocVector(VECSXP, context->V));

  struct Link *current_link = context->head;
  int current_index = 0;

  while(current_link){
    SEXP new_ops_ptr = PROTECT(R_MakeExternalPtr(current_link->contained, R_NilValue, R_NilValue));
    R_RegisterCFinalizerEx(new_ops_ptr, _Ops_finalizer, TRUE);
    SET_VECTOR_ELT(out, current_index, new_ops_ptr);
    current_link = current_link->next;
    current_index++;
  }

  UNPROTECT((context->V) + 1);
  return out;
}

SEXP C_add_input(SEXP node_ptr, SEXP input_ptr){
  CAST_PTR(ops, Ops, node_ptr);
  CAST_PTR(ops_input, Ops, input_ptr);
  add_input_Ops(ops, ops_input);
  return R_NilValue;
}

SEXP C_add_output(SEXP node_ptr, SEXP output_ptr){
  CAST_PTR(ops, Ops, node_ptr);
  CAST_PTR(ops_output, Ops, output_ptr);
  add_output_Ops(ops, ops_output);
  return R_NilValue;
}

