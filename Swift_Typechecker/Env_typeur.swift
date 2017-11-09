func mk_type(ct1 : consttype, ct2 : consttype, ct3 : consttype) -> quantified_type {
  return .Forall(.Nil, .Fun_type(.Pair_type(.Const_type(ct1), .Const_type(ct2)), .Const_type(ct3)));
}

let int_ftype = mk_type(ct1 : .Int_type, ct2 : .Int_type, ct3 : .Int_type)
let float_ftype = mk_type(ct1 : .Float_type, ct2 : .Float_type, ct3 : .Float_type)
let int_predtype = mk_type(ct1 : .Int_type, ct2 : .Int_type, ct3 : .Bool_type)
let float_predtype = mk_type(ct1 : .Float_type, ct2 : .Float_type, ct3 : .Bool_type)
var alpha = ml_type.Var_type(.Unknown(1))
var beta = ml_type.Var_type(.Unknown(2))

var initial_typing_env =
  cons(element : ("=", .Forall(.Cons(1, .Nil), .Fun_type(.Pair_type(alpha, alpha), .Const_type(.Bool_type)))), list :
  cons(element : ("true", .Forall(.Nil, .Const_type(.Bool_type))), list :
  cons(element : ("false", .Forall(.Nil, .Const_type(.Bool_type))), list :
  append(list_1 : map(function : {(s : String) -> (String,quantified_type) in return (s,int_ftype)}, list : .Cons("*", .Cons("+", .Cons("-", .Cons("/", .Nil))))), list_2 :
  append(list_1 : map(function : {(s : String) -> (String,quantified_type) in return (s,float_ftype)}, list : .Cons("*.", .Cons("+.", .Cons("-.", .Cons("/.", .Nil))))), list_2 :
  append(list_1 : map(function : {(s : String) -> (String,quantified_type) in return (s,int_predtype)}, list : .Cons("<", .Cons(">", .Cons("<=", .Cons(">=", .Nil))))), list_2 :
  append(list_1 : map(function : {(s : String) -> (String,quantified_type) in return (s,float_predtype)}, list : .Cons("<.", .Cons(">.", .Cons("<=.", .Cons(">=.", .Nil))))), list_2 :
  .Cons(("hd", .Forall(.Cons(1, .Nil), .Fun_type(.List_type(alpha), alpha))),
  .Cons(("tl", .Forall(.Cons(1, .Nil), .Fun_type(.List_type(alpha), .List_type(alpha)))),
  .Cons(("fst", .Forall(.Cons(1, .Cons(2, .Nil)), .Fun_type(.Pair_type(alpha, beta), alpha))),
  .Cons(("snd", .Forall(.Cons(1, .Cons(2, .Nil)), .Fun_type(.Pair_type(alpha, beta), beta))),
  .Cons(("ref", .Forall(.Cons(1, .Nil), .Fun_type(alpha, .Ref_type(alpha)))),
  .Cons(("!", .Forall(.Cons(1, .Nil), .Fun_type(.Ref_type(alpha), alpha))),
  .Cons((":=", .Forall(.Cons(1, .Nil), .Fun_type(.Pair_type(.Ref_type(alpha), alpha), .Const_type(.Unit_type)))), .Nil))))))))))))));

func add_initial_typing_env(name : String, q_t : quantified_type) {
  initial_typing_env = .Cons((name, q_t), initial_typing_env);
}

func type_check(expr : ml_expr) {
    do {
      let t = try typing_handler(typing_fun : type_expr, env : initial_typing_env, expr : expr);
      //print(t)
      let qt = snd(pair : try hd(list : generalize_types(gamma : initial_typing_env, list : .Cons(("it", t), .Nil))));
      print("Type : ", terminator : "");
      try print_quantified_type(q_t : qt);
      print();
    } catch {
      print("type_check --> ERROR UNEXPECTED")
    }
}

/*func type_check(expr : ml_expr) -> (ml_type, quantified_type) {
  do {
    let et = try typing_handler(typing_fun : type_expr, env : initial_typing_env, expr : expr);
    let t = et;
    let qt = snd(pair : try hd(list : generalize_types(gamma : initial_typing_env, list : .Cons(("_zztop", t), .Nil))));
    return (et, qt);
  } catch {
    print("type_check --> ERROR UNEXPECTED")
    return (ml_type.Var_type(.Unknown(0)), .Forall(.Cons(0, .Nil), ml_type.Var_type(.Unknown(0))))
  }
}*/
