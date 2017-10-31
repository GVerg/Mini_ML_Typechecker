/*
let new_unknown,reset_unknowns,max_unknown =
  let c = ref 1
  and max = ref 10000
  in
   ( (function () -> c:=!c+1; if !c >= !max then failwith "No more types";
                     Var_type( ref(Unknown !c))),
     (function () -> c:=1),
     (function () -> Var_type(ref(Unknown !max))))
;;
*/

indirect enum quantified_type {
case Forall(List<Int>, ml_type);
}

// ATTENTION : List<T> changed to List<Int> because of compilation error
func vars_of_type(type : ml_type) -> List<Int> {
  func vars(list : List<Int>, type_1 : ml_type) -> List<Int> {
    switch type_1 {
    case .Const_type(_) :
      return list;
    case .Var_type(let vt) :
      switch vt {
      case .Unknown(let n) :
        if(mem(element : n, list : list)) {
          return list;
        } else {
          return .Cons(n, list);
        }
      case .Instanciated(let t) :
        return vars(list : list, type_1 : t);
      }
    case .Pair_type(let t1, let t2) :
      return vars(list : (vars(list : list, type_1 : t1)), type_1 : t2);
    case .List_type(let t) :
      return vars(list : list, type_1 : t);
    case .Fun_type(let t1, let t2) :
      return vars(list : (vars(list : list, type_1 : t1)), type_1 : t2);
    case .Ref_type(let t) :
      return vars(list : list, type_1 : t);
    }
  }
  return vars(list : .Nil, type_1 : type);
}

func subtract<T:Comparable>(list_1 : List<T>, list_2 : List<T>) -> List<T> {
  func tmp(element : T) -> List<T> {
    if(mem(element : element, list : list_2)) {
      return .Nil;
    } else {
      return .Cons(element, .Nil);
    }
  }
  return flatten(list : (map (function : tmp, list : list_1)));
}

// ATTENTION : List<T> changed to List<Int> because of compilation error
func free_vars_of_type(list : List<Int>, type : ml_type) -> List<Int> {
  return substract(list_1 : (vars_of_type(type : type)), list_2 : list);
}

// ATTENTION : List<T> changed to List<Int> because of compilation error
func bound_vars_of_type(list : List<Int>, type : ml_type) -> List<Int> {
  return substract(list_1 : (vars_of_type(type : type)), list_2 : list);
}
