#include "context.h"

//' Link
//' A simple structure which serves to implement linked lists
//' * linked list in DlrContext: full list of all the Dlr operations without describing relations between them
//' * individaul linked lists for every single operation, which store their inputs and outputs

struct Link;

void _Link_finalizer(struct Link *link){
  free(link); // ???
}

// create_link instead of Link?
struct Link* create_Link(struct Ops *contained_ops, struct Link *next_link){
  struct Link* l = (struct Link*) calloc(1, sizeof(struct Link));
  l->contained = contained_ops;
  l->next = next_link;
  return l;
}

struct Link* last_link(struct Link *current_link){
  while(current_link->next){
    current_link = current_link->next;
  }
  return current_link;
}

int get_chain_length(struct Link* current_link){
  int i = 0;
  while(current_link){
    i++;
    current_link = current_link->next;
  }
  return i;
}

void append_link(struct Link* link_header, struct Ops* ops, int* element_counter){
  // printf("Name: %d\n", *element_counter);
  if(!link_header)
    link_header = create_Link(ops, NULL);
  else
    last_link(link_header)->next = create_Link(ops, NULL);
  (element_counter)++;
}

/*
 * Get whole the link, starting from the header
 *
 * TODO: consider additional params with number of inputs and outputs
 */
SEXP get_list(struct Link* header_link, int list_length){

  if (!header_link)
    return R_NilValue;

  SEXP out = PROTECT(allocVector(VECSXP, list_length));
  int current_index = 0;

  // Be careful with this finalizers!
  while(current_index < list_length){
    SEXP new_ops_ptr = PROTECT(R_MakeExternalPtr(header_link->contained, R_NilValue, R_NilValue));
    R_RegisterCFinalizerEx(new_ops_ptr, _Ops_finalizer, TRUE);
    SET_VECTOR_ELT(out, current_index, new_ops_ptr);
    header_link = header_link->next;
    current_index++;
  }

  UNPROTECT(list_length + 1);
  return out;
}
