var const_num = 1;
var max = 10000;

func new_unknown() throws -> ml_type {
  const_num = const_num + 1;
  if(const_num >= max) {
    throw(Exception.No_More_Types);
  } else {
    return .Var_type(.Unknown(const_num));
  }
}

func reset_unknowns() {
  const_num = 1;
}

func max_unknown() -> ml_type {
    return .Var_type(.Unknown(max));
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

func free_vars_of_type(list : List<Int>, type : ml_type) -> List<Int> {
  return substract(list_1 : (vars_of_type(type : type)), list_2 : list);
}

func bound_vars_of_type(list : List<Int>, type : ml_type) -> List<Int> {
  return substract(list_1 : (vars_of_type(type : type)), list_2 : list);
}

func flat(list : List<List<Int>>) -> List<Int> {
  return fold_right(function : append, list : list, element : .Nil);
}

func free_vars_of_type_env<T>(list : List<(T,quantified_type)>) -> List<Int> {
  func tmp(element : T, q_t : quantified_type) -> List<Int> {
    switch q_t {
    case let .Forall(l,t) :
      return free_vars_of_type(list : l, type : t);
    }
  }
  return flat(list : (map(function : tmp, list : list)));
}

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

func occurs(element : Int, type : ml_type) -> Bool {
  return mem(element : element, list : (vars_of_type(type : type)));
}

func shorten(type : ml_type) -> ml_type {
  switch type {
  case var .Var_type(vt) :
    switch vt {
    case .Unknown(_) :
      return type;
    case let .Instanciated(t1) :
      switch t1 {
      case .Var_type(_) :
        let t2 = shorten(type : t1);
        vt = .Instanciated(t1);
        return t2;
      default :
        return t1;
      }
    }
  case _ :
    return type;
  }
}

func unify_types(type_1 : ml_type, type_2 : ml_type) throws {
  let lt1 = shorten(type : type_1);
  let lt2 = shorten(type : type_2);
  switch (lt1, lt2) {
  case (.Var_type(var occn), .Var_type(.Unknown(let m))) :
    switch occn {
    case let .Unknown(n) :
      if(n != m) {
        occn = .Instanciated(lt2);
      }
    case _ :
      print("unify_types --> SHOULD NOT BE THERE");
    }
  case (.Var_type(var occn), _) :
    switch occn {
    case let .Unknown(n) :
      if(occurs(element : n, type : lt2)) {
        throw(Exception.Type_error(.Clash(lt1, lt2)));
      } else {
        occn = .Instanciated(lt2);
      }
    case _ :
      print("unify_types --> SHOULD NOT BE THERE");
    }
  case (_, .Var_type(.Unknown(_))) :
    try unify_types(type_1 : lt2, type_2 : lt1);
  case let (.Const_type(ct1), .Const_type(ct2)) :
    if(ct1 != ct2) {
      throw(Exception.Type_error(.Clash(lt1, lt2)));
    }
  case let (.Pair_type(t1, t2), .Pair_type(t3, t4)) :
    try unify_types(type_1 : t1, type_2 : t3);
    try unify_types(type_1 : t2, type_2 : t4);
  case let (.List_type(t1), .List_type(t2)) :
    try unify_types(type_1 : t1, type_2 : t2);
  case let (.Fun_type(t1, t2), .Fun_type(t3, t4)) :
    try unify_types(type_1 : t1, type_2 : t3);
    try unify_types(type_1 : t2, type_2 : t4);
  case (.Ref_type(_), .Ref_type(_)) :
    print("No unification for ref type");
  case _ :
    throw(Exception.Type_error(.Clash(lt1, lt2)));
  }
}

func type_const(type : ml_const) throws -> ml_type {
  switch type {
  case .Int(_) :
    return .Const_type(.Int_type);
  case .Float(_) :
    return .Const_type(.Float_type);
  case .String(_) :
    return .Const_type(.String_type);
  case .Bool(_) :
    return .Const_type(.Bool_type);
  case .Unit :
    return .Const_type(.Unit_type);
  case .EmptyList :
    return .List_type(try new_unknown());
  }
}

func generalize_types<T1,T2>(gamma : List<(T1,quantified_type)>, list : List<(T2,ml_type)>) -> List<(T2,quantified_type)> {
  let fvg = free_vars_of_type_env(list : gamma);
  return map(function : {(s : T2, t : ml_type) -> (T2, quantified_type) in (s, .Forall(free_vars_of_type(list : fvg, type : t), t))}, list : list);
}

func type_expr(gamma : List<(String,quantified_type)>, expression : ml_expr) throws -> ml_type {
  func type_rec(expr : ml_expr) throws -> ml_type {
    switch expr {
    case let .Const(c) :
      return try type_const(type : c);
    case let .Var(s) :
      do {
        let t = try assoc(element : s, list : gamma);
        return type_instance(q_t : t);
      } catch {
        throw(Exception.Type_error(.Unbound_var(s)));
      }
    case let .Unop(s,e) :
      do {
        let t = try assoc(element : s, list : gamma);
        let t1 = type_instance(q_t : t);
        let t2 = try type_rec(expr : e);
        let u = try new_unknown();
        try unify_types(type_1 : t1, type_2 : .Fun_type(t2,u));
        return u;
      } catch {
        throw(Exception.Type_error(.Unbound_var(s)));
      }
    case let .Binop(s,e1,e2) :
      do {
        let t = try assoc(element : s, list : gamma);
        let t0 = type_instance(q_t : t);
        let t1 = try type_rec(expr : e1);
        let t2 = try type_rec(expr : e2);
        let u = try new_unknown();
        let _ = try new_unknown(); // v is never used
        try unify_types(type_1 : t0, type_2 : .Fun_type(.Pair_type(t1,t2),u));
        return u;
      } catch {
        throw(Exception.Type_error(.Unbound_var(s)));
      }
    case let .Pair(e1,e2) :
      return .Pair_type(try type_rec(expr : e1), try type_rec(expr : e2));
    case let .Cons(e1,e2) :
      let t1 = try type_rec(expr : e1);
      let t2 = try type_rec(expr : e2);
      try unify_types(type_1 : .List_type(t1), type_2 : t2);
      return t2;
    case let .Cond(e1,e2,e3) :
      try unify_types(type_1 : .Const_type(.Bool_type), type_2 : try type_rec(expr : e1));
      let t2 = try type_rec(expr : e2);
      let t3 = try type_rec(expr : e3);
      try unify_types(type_1 : t2, type_2 : t3);
      return t2;
    case let .App(e1,e2) :
      let t1 = try type_rec(expr : e1);
      let t2 = try type_rec(expr : e2);
      let u = try new_unknown();
      try unify_types(type_1 : t1, type_2 : .Fun_type(t2,u));
      return u;
    case let .Abs(s,e) :
      let t = try new_unknown();
      let new_env = List.Cons((s, .Forall(.Nil, t)), gamma);
      return .Fun_type(t, try type_expr(gamma : new_env, expression : e));
    case let .Letin(false,s,e1,e2) :
      let t1 = try type_rec(expr : e1);
      let new_env = generalize_types(gamma : gamma, list : .Cons((s,t1), .Nil));
      return try type_expr(gamma : append(list_1 : new_env, list_2 : gamma), expression : e2);
    case let .Letin(true,s,e1,e2) :
      let u = try new_unknown();
      let new_env = List.Cons((s, .Forall(.Nil,u)), gamma);
      let t1 = try type_expr(gamma : append(list_1 : new_env, list_2 : gamma), expression : e1);
      let final_env = generalize_types(gamma : gamma, list : .Cons((s,t1), .Nil));
      return try type_expr(gamma : append(list_1 : final_env, list_2 : gamma), expression : e2);
    case .Ref(_) :
      throw(Exception.Failwith("not implemented yet"));
    case .Straint(_) :
      throw(Exception.Failwith("not implemented yet"));
    }
  }
  return try type_rec(expr : expression);
}

/**** BLOCKED BECAUSE OF FLAT FUNCTION
        | Abs(s,e) ->
            let t = new_unknown() in
              let new_env = (s,Forall ([],t))::gamma in
                Fun_type (t, type_expr new_env e)
        | Letin (false,s,e1,e2) ->
            let t1 = type_rec e1 in
              let new_env = generalize_types gamma [ (s,t1) ] in
                type_expr (new_env@gamma) e2
        | Letin (true,s,e1,e2) ->
            let u = new_unknown () in
              let new_env = (s,Forall([  ],u))::gamma in
                let t1 = type_expr (new_env@gamma) e1 in
                  let final_env = generalize_types gamma [ (s,t1) ] in
                    type_expr (final_env@gamma) e2
        | Ref e -> failwith "not yet implemented"
    in
      type_rec;;

 ****/

func print_consttype(type : consttype) {
  switch type {
  case .Int_type :
    print("int");
  case .Float_type :
    print("float");
  case .String_type :
    print("string");
  case .Bool_type :
    print("bool");
  case .Unit_type :
    print("unit");
  }
}

func ascii(integer : Int) -> String {
  var string = create_string(integer : 1);
  string.remove(at : string.startIndex);
  string.insert(Character(UnicodeScalar(integer)!), at : string.startIndex);
  return string
}

func var_name(integer : Int) -> String {
  func name_of(i : Int) -> String {
    let q = i / 26;
    let r = i % 26;
    if(q == 0) {
      return "\(ascii(integer : (96+r)))";
    } else {
      return "\(name_of(i : q))\(ascii(integer : (96+r)))";
    }
  }
  return "'\(name_of(i : integer))";
}

func print_quantified_type(q_t : quantified_type) throws {
  switch q_t {
  case let .Forall(gv, t) :
    func names_of(integer : Int, list : List<Int>) -> List<String> {
      switch (integer, list) {
      case (_, .Nil) :
        return .Nil
      case let (_, .Cons(_, lv)) :
        return .Cons(var_name(integer : integer), names_of(integer : integer + 1, list : lv));
      }
    }
    let names = names_of(integer : 1, list : gv);
    let var_names = try combine(list_1 : rev(list : gv), list_2 : names);
    func print_rec(type : ml_type) throws {
      switch type {
      case let .Var_type(.Instanciated(t)) :
        try print_rec(type : t);
      case let .Var_type(.Unknown(n)) :
        do {
            let name = try assoc(element : n, list : var_names);
            print(name);
        } catch {
          print("print_rec --> Non quantified variable in type");
        }
      case let .Const_type(ct) :
        print_consttype(type : ct);
      case let .Pair_type(t1,t2) :
        print("(\(try print_rec(type : t1)) * \(try print_rec(type : t2)))*");
      case let .List_type(t) :
        print("((\(try print_rec(type : t))) list)");
      case let .Fun_type(t1,t2) :
        print("(\(try print_rec(type : t1)) -> \(try print_rec(type : t2)))*");
      case let .Ref_type(t) :
        print("((\(try print_rec(type : t))) ref)");
      }
    }
    try print_rec(type : t);
  }
}

func print_type(type : ml_type) throws {
  try print_quantified_type(q_t : .Forall(free_vars_of_type(list : .Nil, type : type), type));
}



/*

let typing_handler typing_fun env expr =
  reset_unknowns();
  try typing_fun env expr
  with
    Type_error (Clash(lt1,lt2)) ->
        print_string  "Type clash between ";print_type lt1;
        print_string " and ";print_type lt2; print_newline();
        failwith "type_check"
  | Type_error (Unbound_var s)  ->
        prerr_string "Unbound variable ";
        prerr_endline s;
        failwith "type_check"
;;
*/
