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

/**** BLOCKED BECAUSE OF FLAT FUNCTION

let generalize_types gamma l =
   let fvg = free_vars_of_type_env gamma
   in
     List.map (function (s,t) ->
                (s, Forall(free_vars_of_type (fvg,t),t))) l
 ;;

 let rec type_expr gamma =
    let rec type_rec expri =
      match expri with
          Const c -> type_const c
        | Var s -> let t = try List.assoc s gamma
           with Not_found -> raise (Type_error(Unbound_var s))
           in  type_instance t
        | Unop (s,e) ->
            let t = try assoc s gamma
                    with Not_found -> raise (Type_error(Unbound_var s))
             in
               let t1= type_instance t
               and t2 = type_rec e in
               let u = new_unknown()
               in
                 unify_types(t1, Fun_type(t2,u)); u
        | Binop(s,e1,e2) ->
           let t = try assoc s gamma
                   with Not_found -> raise (Type_error(Unbound_var s))
           in
             let t0 = type_instance t
             and t1 = type_rec e1
             and t2 = type_rec e2
             in
               let u = new_unknown()
               and v = new_unknown()
               in
                 unify_types(t0, Fun_type(Pair_type (t1,t2),u)); u




        | Pair (e1,e2) -> Pair_type (type_rec e1, type_rec e2)
        | Cons (e1,e2) ->
            let t1 = type_rec e1
            and t2 = type_rec e2 in
              unify_types (List_type t1, t2); t2
        | Cond (e1,e2,e3) ->
            let t1 = unify_types (Const_type Bool_type, type_rec e1)
            and t2 = type_rec e2
            and t3 = type_rec e3 in
              unify_types (t2,t3); t2
        | App (e1,e2) ->
            let t1 = type_rec e1
            and t2 = type_rec e2 in
              let u = new_unknown() in
                unify_types (t1, Fun_type (t2,u)); u
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
  var string = create_string(integer : integer);
  string.remove(at : string.startIndex);
  string.insert(Character(UnicodeScalar(integer)!), at : string.startIndex);
  return string
}
/**** TODO : to translate ****
let var_name n =
  let rec name_of n =
     let q,r = ((n / 26), (n mod 26))
     in
        if q=0 then ascii (96+r)
        else (name_of q)^(ascii (96+r))
   in "'"^(name_of n)
;;
****/




/*func print_quantified_type(q_t : quantified_type) throws {
  switch q_t {
  case let .Forall(gv, t) :
    func names_of(integer : Int, type : ml_type) {
      switch (value) {
      case value:

      default:

      }
    }
  }
}
*/
/*
let print_quantified_type (Forall(gv,t)) =
  let names =
    let rec names_of = function
      (n,[]) -> []
    | (n,(v1::lv)) -> (var_name n)::(names_of (n+1,lv))
    in (names_of (1,gv))
  in
    let var_names = combine (rev gv) names
    in
      let rec print_rec = function
         Var_type {contents=(Instanciated t)} -> print_rec t
      |  Var_type {contents=(Unknown n)} ->
           let name = (try assoc n var_names
                       with Not_found -> raise (Failure "Non quantified variable in type"))
           in print_string name
      | Const_type ct -> print_consttype ct
      | Pair_type(t1,t2) -> print_string "("; print_rec t1;
                            print_string " * "; print_rec t2; print_string ")"
      | List_type t -> print_string "(("; print_rec t; print_string ") list)"
      | Fun_type(t1,t2)  -> print_string "("; print_rec t1;
                            print_string " -> "; print_rec t2; print_string ")"
      | Ref_type t -> print_string "(("; print_rec t; print_string ") ref)"
      in
        print_rec t
;;
*/
