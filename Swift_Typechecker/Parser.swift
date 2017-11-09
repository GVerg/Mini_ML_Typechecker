import Foundation

var index = 0;

func incIndex() {index = index+1}


func parseLetIn(tokens : [Token]) -> ml_phrase {
    var x : String = "";
    var e: ml_expr = ml_expr.Var("");
    var e1: ml_expr = ml_expr.Var("");
    incIndex(); // pass the _let
    
    if case let .Identifier(v) = tokens[index] {
        x = v;
    }
    
    incIndex(); // pass the =
    incIndex();
    
    let temp = parse(tokens : tokens);
    if case let .Expr(i) = temp {
        e = i;
    }
    incIndex(); // pass the in
    
    let temp1 = parse(tokens : tokens);
    if case let .Expr(i) = temp1 {
        e1 = i;
    }
    
    return .Expr(.Letin(true, x, e, e1));
}

func parseLet(tokens : [Token]) -> ml_phrase {
    var x : String = "";
    var e : ml_expr = ml_expr.Var("");
    incIndex(); // pass the let
    if case let .Identifier(v) = tokens[index] {
        x = v;
    }
    incIndex(); // pass the =
    incIndex();
    
    let temp = parse(tokens : tokens);
    
    if case let .Expr(i) = temp {
        e = i;
    }
    return .Decl(.Let(false, x, e));
}

func parseBinOp(tokens : [Token]) -> ml_phrase {
    var op : String = "";
    var e2: ml_expr = ml_expr.Var("");
    var e1: ml_expr = ml_expr.Var("");
    switch tokens[index] {
    case .OInteger(let i):
        e1 = .Const(.Int(i));
        break;
        
    case .ODouble(let i):
        e1 = .Const(.Float(i));
        break;
        
    case .Identifier(let i):
        e1 = .Var(i);
        break;
    default:
        print("problem")
        break;
    }
    incIndex();
    
    if case let .ArithOp(i) = tokens[index] {
        op = i;
    }
    incIndex();
    
    let temp = parse(tokens : tokens);
    if case let .Expr(i) = temp {
        e2 = i;
    }
    return .Expr(.Binop(op, e1, e2));
}

func parseApp(tokens : [Token]) -> ml_phrase {
    var x :String = "";
    var e: String = "";
    if case let .Identifier( v) = tokens[index] {
        x = v;
    }
    incIndex();
    
    if case let .Identifier( v) = tokens[index] {
        e = v;
    }
    incIndex();
    
    return .Expr(.App(.Var(x), .Var(e)));
}

func parsePair(tokens : [Token]) -> ml_phrase {
    incIndex(); // pass the (
    let temp1 = parse(tokens :tokens);
    
    incIndex(); // pass the Comma
    let temp2 = parse(tokens: tokens);
    
    incIndex(); // pass the )
    
    var e1: ml_expr = ml_expr.Var("");
    var e2: ml_expr = ml_expr.Var("");
    if case let .Expr(v) = temp1 {
        e1 = v;
    }
    
    if case let .Expr(v) = temp2 {
        e2 = v;
    }
    
    return .Expr(.Pair(e1,e2));
}

func parseCond(tokens : [Token]) -> ml_phrase {
    incIndex(); // pass if
    let temp = parse(tokens: tokens);
    incIndex(); // pass Then
    let temp1 = parse(tokens: tokens);
    incIndex(); // pass else
    let temp2 = parse(tokens: tokens);
    
    var cond: ml_expr = ml_expr.Var("");
    var e1: ml_expr = ml_expr.Var("");
    var e2: ml_expr = ml_expr.Var("");
    if case let .Expr(v) = temp {
        cond = v;
    }
    
    if case let .Expr(v) = temp1 {
        e1 = v;
    }
    if case let .Expr(v) = temp2 {
        e2 = v;
    }
    
    return .Expr(.Cond(cond, e1, e2));
}

func parseAbs(tokens : [Token]) -> ml_phrase {
    incIndex(); // pass Function
    var x: String = "";
    if case let .Identifier(v) = tokens[index] {
        x = v;
    }
    incIndex();
    incIndex(); // pass Arrow
    
    let temp = parse(tokens: tokens);
    var body : ml_expr = ml_expr.Var("");
    if case let .Expr(v) = temp {
        body = v;
    }
    
    return .Expr(.Abs(x, body));
}


func parse(tokens : [Token]) -> ml_phrase {
    switch tokens[index] {

    case .OLetin:
      return parseLetIn(tokens : tokens);

    case .OLet:
      return parseLet(tokens : tokens);

    case .OInteger(let i):
      if case Token.ArithOp(_) = tokens[index+1] {
        return parseBinOp(tokens : tokens);
      } /*else if case Token.Concat = tokens[index+1] {
        return parseList(tokens :tokens);
      } */else {
        incIndex();
        return .Expr(.Const(.Int(i)));
      }

    case .ODouble(let d):
      if case Token.ArithOp(_) = tokens[index+1] {
        return parseBinOp(tokens : tokens);
      } /*else if case Token.Concat = tokens[index+1] {
        return parseList(tokens :tokens);
      } */else{
        incIndex();
        return .Expr(.Const(.Float(d)));
      }

    case .OEmptyList:
      incIndex();
      return .Expr(.Const(.EmptyList));

    case .Identifier(let v):
      if case Token.Identifier(_)  = tokens[index+1] {
        return parseApp(tokens :tokens);
      } else if case Token.ArithOp(_) = tokens[index+1] {
        return parseBinOp(tokens : tokens);
      }
      incIndex();
      return .Expr(.Var(v));

    case .OUnit:
      incIndex();
      return .Expr(.Const(.Unit))

    case .ParensOpen:
      return parsePair(tokens : tokens);

    case .If:
      return parseCond(tokens : tokens);

    case .Function:
      return parseAbs(tokens : tokens);

    default:
      print("big problem : \(tokens[index])")
      return .Expr(.Var(""));
}
}
