var c = 1;
var max = 10000;

func new_unknown() throws -> ml_type {
  c = c + 1;
  if(c >= max) {
    throw(Exception.No_More_Types);
  } else {
    return .Var_type(.Unknown(c));
  }
}

func reset_unknowns() {
  c = 1;
}

func max_unknown() -> ml_type {
    return .Var_type(.Unknown(max));
}

indirect enum quantified_type {
case Forall(List<Int>, ml_type);
}

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


func type_instance(q_t : quantified_type) -> ml_type {
  switch q_t {
  case let .Forall(list, type) :
    func tmp(integer : Int) -> (Int, ml_type) {
      do {
        return (integer, try new_unknown());
      } catch {
        print("type_instance --> INEXPECTED ERROR");
        return (integer, .Var_type(.Unknown(integer)));
      }
    }
    let unknowns = map(function : tmp, list : list);
    func instance(type : ml_type) -> ml_type {
      switch type {
      case let .Var_type(.Unknown(n)) :
        do {
          return try assoc(element : n, list : unknowns);
        } catch {
          return type;
        }
      case let .Var_type(.Instanciated(t)) :
        return instance(type : t);
      case .Const_type(_) :
        return type;
      case let .Pair_type(t1, t2) :
        return .Pair_type(instance(type : t1), instance(type : t2));
      case let .List_type(t) :
        return .List_type(instance(type : t));
      case let .Fun_type(t1, t2) :
        return .Fun_type(instance(type : t1), instance(type : t2));
      case let .Ref_type(t) :
        return .Ref_type(instance(type : t));
      }
    }
    return instance(type : type);
  }
}
