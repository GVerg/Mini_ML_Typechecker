indirect enum vartype {
case Unknown(Int);
case Instanciated(ml_type);
}

indirect enum consttype {
case Int_type;
case Float_type;
case String_type;
case Bool_type;
case Unit_type;
}

indirect enum ml_type {
case Var_type(vartype); // Var_type of vartype ref
case Const_type(consttype);
case Pair_type(ml_type, ml_type);
case List_type(ml_type);
case Fun_type(ml_type, ml_type);
case Ref_type(ml_type);
}

indirect enum ml_expr {
case Const(ml_const);
case Var(String);
case Unop(String, ml_expr);
case Binop(String, ml_expr, ml_expr);
case Pair(ml_expr, ml_expr);
case Cons(ml_expr, ml_expr);
case Cond(ml_expr, ml_expr, ml_expr);
case App(ml_expr, ml_expr);
case Abs(String, ml_expr);
case Letin(Bool, String, ml_expr, ml_expr);
case Ref(ml_expr);
// nouvelle entree
case Straint (ml_expr, ml_type);
}

indirect enum ml_const {
case Int(Int);
case Bool(Bool);
case String(String);
case EmptyList;
case Unit;
}

indirect enum ml_decl {
case Let(Bool, String, ml_expr);
}

indirect enum ml_phrase {
case Expr(ml_expr);
case Decl(ml_decl);
}
