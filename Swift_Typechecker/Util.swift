indirect enum List<T>{
case Cons(T, List);
case Nil;
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

func substract<T:Comparable>(list1 : List<T>, list2 : List<T>) -> List<T> {
  func aux(tmp : List<T>) -> List<T> {
    switch tmp {
    case .Nil :
      return .Nil;
    case let .Cons(head, tail) :
      if(mem(element : head, list : list2)) {
        return aux(tmp : tail);
      }
      else {
        return .Cons(head, aux(tmp : tail));
      }
    }
  }
  return aux(tmp : list1);
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

/**** TODO : to translate ****
(* une fonction de nettoyage de fichiers *)
let remove_file f =
  try
    Sys.remove f
  with Sys_error _ ->
    ()
;;
*/

/**** TODO : to translate ****
let do_list = List.iter;;
let assoc = List.assoc;;
let combine = List.combine;;
let rev = List.rev;;
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
