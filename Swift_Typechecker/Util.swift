// RANDOM GENERATION BETWEEN 0 AND 1
var lastRandom = 42.0
var m = 139968.0
var a = 3877.0
var c = 29573.0

func random() -> Double {
  lastRandom = ((lastRandom * a + c).truncatingRemainder(dividingBy:m))
  return lastRandom / m
}

func create_string(integer : Int) -> String {
  var string = "";
  for _ in 0..<integer {
    if(random() >= 0.5) {
      string.append("1");
    } else {
      string.append("0");
    }
  }
  //print(string, terminator : "");
  return string;
}
// *********************************

func fst<T1,T2>(pair : (T1,T2)) -> T1 {
  switch pair {
  case let (t1, _) :
      return t1;
  }
}

func snd<T1,T2>(pair : (T1,T2)) -> T2 {
  switch pair {
  case let (_, t2) :
      return t2;
  }
}

// *********************************

func length<T>(list : List<T>) -> Int {
  switch list {
  case let .Cons(_, tail) :
    return 1 + length(list : tail);
  case .Nil :
    return 0;
  }
}

func cons<T>(element : T, list : List<T>) -> List<T> {
  return .Cons(element, list);
}

func hd<T>(list : List<T>) throws -> T {
  switch list {
  case let .Cons(head, _) :
    return head;
  case .Nil :
      throw(ListError.FunctionFailed(functionError : "hd"));
  }
}

func tl<T>(list : List<T>) throws -> List<T> {
  switch list {
  case let .Cons(_, tail) :
    return tail;
  case .Nil :
    throw(ListError.FunctionFailed(functionError : "tl"));
  }
}

func map<T1,T2>(function : @escaping (T1) -> T2, list : List<T1>) -> List<T2> {
  func aux(tmp : List<T1>) -> List<T2> {
    switch tmp {
    case let .Cons(head, tail) :
      return List.Cons(function(head), aux(tmp : tail));
    case .Nil :
      return List.Nil
    }
  }
  return aux(tmp : list);
}

func mem<T:Comparable>(element : T, list : List<T>) -> Bool {
  func aux(tmp : List<T>) -> Bool {
    switch tmp {
    case let .Cons(head, tail) :
      if (head == element) { return true; } else { return aux(tmp : tail); }
    case .Nil :
       return false;
    }
  }
  return aux(tmp : list)
}

func substract<T:Comparable>(list_1 : List<T>, list_2 : List<T>) -> List<T> {
  func aux(tmp : List<T>) -> List<T> {
    switch tmp {
    case .Nil :
      return .Nil;
    case let .Cons(head, tail) :
      if(mem(element : head, list : list_2)) {
        return aux(tmp : tail);
      }
      else {
        return .Cons(head, aux(tmp : tail));
      }
    }
  }
  return aux(tmp : list_1);
}

func fold_right<T1,T2>(function : @escaping (T1,T2) -> T2, list : List<T1>, element : T2) -> T2 {
  func aux(tmp : List<T1>) -> T2 {
    switch tmp {
    case let .Cons(head, tail) :
      return function(head, aux(tmp : tail));
    case .Nil :
      return element;
    }
  }
  return aux(tmp : list);
}

func fold_left<T1,T2>(function : @escaping (T1,T2) -> T1, element : T1, list : List<T2>) -> T1 {
  func aux(tmp : List<T2>, acc : T1) -> T1 {
    switch tmp {
    case let .Cons(head, tail) :
       return aux(tmp : tail, acc : function(acc, head));
      case .Nil :
       return acc;
    }
  }
  return aux(tmp : list, acc : element);
}

func iter<T>(function : @escaping (T) -> (), list : List<T>) {
  func aux(tmp : List<T>) {
    switch tmp {
    case let .Cons(head, tail) :
        function(head);
        aux(tmp : tail)
      case .Nil :
        break
    }
  }
  aux(tmp : list);
}

func assoc<T1:Comparable,T2>(element : T1, list : List<(T1,T2)>) throws -> T2 {
  func aux(tmp : List<(T1,T2)>) throws -> T2 {
    switch tmp {
    case let .Cons((key, value), tail) :
    if (key == element) {
      return value;
    } else {
    return try aux(tmp : tail)
    }
    case .Nil :
      throw(ListError.Not_Found(functionError : "assoc"))
    }
  }
  return try aux(tmp : list);
}

func combine<T1,T2>(list_1 : List<T1>, list_2 : List<T2>) throws -> List<(T1,T2)> {
  func aux(tmp1 : List<T1>, tmp2 : List<T2>) -> List<(T1,T2)> {
    switch tmp1 {
    case let .Cons(head_1, tail_1) :
        switch tmp2 {
        case let .Cons(head_2, tail_2) :
            return cons(element : (head_1, head_2), list : aux(tmp1 : tail_1, tmp2 : tail_2));
        case .Nil :
            return List.Nil;
        }
      case .Nil :
        return List.Nil;
    }
  }
  if length(list : list_1) == length(list : list_2) {
    return aux(tmp1 : list_1, tmp2 : list_2);
  } else {
    throw(ListError.Invalid_Argument(functionError : "combine"));
  }
}

func rev<T>(list : List<T>) -> List<T> {
  func aux(tmp : List<T>, acc : List<T>) -> List<T> {
    switch tmp {
    case let .Cons(head, tail) :
      return aux(tmp : tail, acc :cons(element : head,list : acc));
    case .Nil :
      return acc;
    }
  }
  return aux(tmp : list, acc : List.Nil);
}

func append<T>(list_1 : List<T>, list_2 : List<T>) -> List<T> {
  func aux(tmp : List<T>) -> List<T> {
    switch tmp {
    case let .Cons(head, tail) :
      return cons(element : head, list : aux(tmp : tail));
    case .Nil :
      return list_2;
    }
  }
  return aux(tmp : list_1);
}

func concat<T>(list : List<List<T>>) -> List<T> {
  func aux(tmp : List<List<T>>) -> List<T> {
    switch tmp {
    case let .Cons(head, tail) :
      return append(list_1 : head, list_2 : aux(tmp : tail));
    case .Nil :
      return .Nil;
    }
  }
  return aux(tmp : list);
}

func flatten<T>(list : List<List<T>>) -> List<T> {
  return concat(list : list);
}

/**** TODO : to translate ****
(* une fonction de nettoyage de fichiers *)
let remove_file f =
  try
    Sys.remove f
  with Sys_error _ ->
    ()
;;
*/

func do_list<T>(function : @escaping (T) -> (), list : List<T>) {
  iter(function : function, list : list);
}


/**** TODO : to translate ****
let create_string = String.create;;
let string_length = String.length;;
let blit_string = String.blit;;
let set_nth_char = String.set;;
let sub_string = String.sub;;
let get_lexeme_char = Lexing.lexeme_char;;
let get_lexeme = Lexing.lexeme;;
*/
