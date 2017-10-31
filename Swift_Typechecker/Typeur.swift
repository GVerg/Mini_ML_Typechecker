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

/**** Fucking Compilation Error... HELP

TO TRANSLATE :
let flat ll = List.fold_right (@) ll [];;

TRANSLATION :
func flat<T1,T2>(list : List<T1>) -> List<T2> {
  return fold_right(function : append, list : list, element : .Nil);
}

COMPILATION ERROR :
cannot convert value of type (List<_>, List<_>) -> List<_> to expected argument
type (_, List<_>) -> List<_>

****/

/**** BLOCKED BECAUSE OF FLAT FUNCTION

TO TRANSLATE :
let free_vars_of_type_env l =
     flat ( List.map (function (id,Forall (v,t))
                        -> free_vars_of_type (v,t)) l) ;;

TRANSLATION :
func free_vars_of_type_env<T>(list : List<T>) -> List<T> {
  func tmp(element : T, q_t : quantified_type) -> List<T> {
    let .Forall(l, t) = q_t;
    return free_vars_of_type(list : l, type : t);
  }
  return flat(list : (map(function : tmp, list : list)));
}

****/
