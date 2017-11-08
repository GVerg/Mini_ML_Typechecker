func mk_type(ct1 : consttype, ct2 : consttype, ct3 : consttype) -> quantified_type {
  return .Forall(.Nil, .Fun_type(.Pair_type(.Const_type(ct1), .Const_type(ct2)), .Const_type(ct3)));
}

let int_ftype = mk_type(ct1 : .Int_type, ct2 : .Int_type, ct3 : .Int_type)
let float_ftype = mk_type(ct1 : .Float_type, ct2 : .Float_type, ct3 : .Float_type)
let int_predtype = mk_type(ct1 : .Int_type, ct2 : .Int_type, ct3 : .Bool_type)
let float_predtype = mk_type(ct1 : .Float_type, ct2 : .Float_type, ct3 : .Bool_type)
var alpha = ml_type.Var_type(.Unknown(1))
var beta = ml_type.Var_type(.Unknown(2))

func test() {
  switch alpha {
  case .Var_type(_):
      alpha = ml_type.Var_type(.Unknown(20))
  default:
      print("");
  }
}



//var initial_typing_env =

/*
let initial_typing_env =
ref(  let mk_type (ct1,ct2,ct3) =
    Forall([], Fun_type (Pair_type(Const_type ct1, Const_type ct2),Const_type ct3))
  in
    let int_ftype = mk_type(Int_type,Int_type,Int_type)
    and float_ftype = mk_type(Float_type,Float_type,Float_type)
    and int_predtype = mk_type(Int_type,Int_type,Bool_type)
    and float_predtype = mk_type(Float_type,Float_type,Bool_type)
    and alpha = Var_type(ref(Unknown 1))
    and beta = Var_type(ref(Unknown 2))
    in
      ("=",Forall([1],Fun_type (Pair_type (alpha,alpha),
                                Const_type Bool_type)))::
      ("true", Forall([],Const_type Bool_type)) ::
      ("false", Forall([],Const_type Bool_type)) ::
      (map (function s -> (s,int_ftype)) ["*";"+";"-";"/"]) @
      (map (function s -> (s,float_ftype)) ["*.";"+.";"-.";"/."]) @
      (map (function s -> (s,int_predtype)) ["<";">";"<=";">="]) @
      (map (function s -> (s,float_predtype)) ["<.";">.";"<=.";">=."]) @
      ["^", mk_type (String_type, String_type, String_type)] @
      [("hd",Forall([1], Fun_type (List_type alpha, alpha)));
       ("tl",Forall([1], Fun_type (List_type alpha, List_type alpha)));
       ("fst",Forall([1;2], Fun_type (Pair_type (alpha,beta),alpha)));
       ("snd",Forall([1;2], Fun_type (Pair_type (alpha,beta),beta)));
       ("ref",Forall([1], Fun_type (alpha, Ref_type alpha)));
       ("!",  Forall([1], Fun_type (Ref_type alpha, alpha)));
       (":=",  Forall([1], Fun_type (Pair_type(Ref_type alpha, alpha),Const_type Unit_type)))
])
;;

let add_initial_typing_env (name,typ) =
    initial_typing_env := (name,typ) :: (!initial_typing_env)
;;

let type_check e =
  let et = typing_handler type_expr !initial_typing_env e
  in
    let t =  et in
    let qt = snd(List.hd(generalize_types !initial_typing_env ["_zztop",t]))
    in
      et,qt
;;
*/
