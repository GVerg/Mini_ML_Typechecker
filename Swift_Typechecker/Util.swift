indirect enum List<T>{
case Cons(T, List);
case Nil;
}

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
      throw(ListError.FonctionFailed(functionError : "hd"));
  }
}

func tl<T>(list : List<T>) throws -> List<T> {
  switch list {
  case let .Cons(_, tail) :
    return tail;
  case .Nil :
    throw(ListError.FonctionFailed(functionError : "tl"));
  }
}

func map<T>(function : @escaping (T) -> T, list : List<T>) -> List<T> {
  func aux(tmp : List<T>) -> List<T> {
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

func fold_right<T1,T2>(fonction : @escaping (T1,T2) -> T2, list : List<T1>, element : T2) -> T2 {
  func aux(tmp : List<T1>) -> T2 {
    switch tmp {
    case let .Cons(head, tail) :
      return fonction(head, aux(tmp : tail));
    case .Nil :
      return element;
    }
  }
  return aux(tmp : list);
}

func fold_left<T1,T2>(fonction : @escaping (T1,T2) -> T1, element : T1, list : List<T2>) -> T1 {
  func aux(tmp : List<T2>, acc : T1) -> T1 {
    switch tmp {
    case let .Cons(head, tail) :
       return aux(tmp : tail, acc : fonction(acc, head));
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

indirect enum Exception : Error {
case Error(Exception, Int, Int);
case Unterminated_string;
case Unterminated_comment;
case Unterminated_stringt;
case Bad_char_constant;
case Illegal_character;
}

enum ListError: Error {
case FonctionFailed(functionError : String);
case Invalid_Argument(functionError : String);
case Not_Found(functionError : String);
}
