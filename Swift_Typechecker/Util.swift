indirect enum List<T>{
case Cons(T, List);
case Nil;
}

func map<T>(function : @escaping (T) -> T, list : Liste<T>) -> Liste<T> {
  func aux(tmp : Liste<T>) -> Liste<T> {
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

func substract(list1 : List<T>, list2 : List<T>) -> List<T> {
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

indirect enum Exception : Error {
case Error(Exception, Int, Int);
case Unterminated_string;;
case Unterminated_comment;;
case Unterminated_stringt;;
case Bad_char_constant;;
case Illegal_character;;
}
