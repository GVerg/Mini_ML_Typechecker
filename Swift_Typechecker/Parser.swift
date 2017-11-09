import Foundation

var index = 0;

func incIndex() {index = index+1}

func parse(tokens : [Token]) -> ml_phrase {
    switch tokens[index] {

    case .OLetin:
      return parseLetIn(tokens : tokens);

    case .OLet:
      return parseLet(tokens : tokens);

    case .Integer(let i):
      if tokens[index+1] == Token.ArithOp(_){
        return parseBinOp(tokens : tokens);
      } else if tokens[index+1] == Token.Concat{
        return parseList(tokens :tokens);
      } else {
        incIndex();
        return .Expr(.Const(.Int(i)));
      }

    case .ODouble(let d):
      if tokens[index+1] == Token.ArithOp(_){
        return parseBinOp(tokens : tokens);
      } else if tokens[index+1] == Token.Concat{
        return parseList(tokens :tokens);
      } else{
        incIndex();
        return .Expr(.Const(.Float(d)));
      }

    case .OEmptyList:
      incIndex();
      return .Expr(.Const(.EmptyList));

    case .Identifier(let v):
      if tokens[index+1] == Token.Identifier(_) {
        return parseApp(tokens :tokens);
      } else if tokens[index+1] == Token.ArithOp(_){
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
      print("big problem : " + tokens[index])
      return .Expr(.Var("caca"));
}

func parseLetIn(tokens : [Token]) -> ml_phrase {
  var x;
  var e;
  var e1;
  incIndex(); // pass the _let

  if case let .Identifier(let v) = tokens[index] {
    x = v;
  }

  incIndex(); // pass the =
  incIndex();

  let temp = parse(tokens : tokens);
  if case let .Expr(let i) = temp {
     e = i;
  }
  incIndex(); // pass the in

  let temp1 = parse(tokens : tokens);
  if case let .Expr(let i) = temp1 {
     e1 = i;
  }

  return .Expr(.Letin(true, x, e, e1));
}

func parseLet(tokens : [Token]) -> ml_phrase {
  var x;
  var e;
  incIndex(); // pass the let
  if case let .Identifier(let v) = tokens[index] {
    x = v;
  }
  incIndex(); // pass the =
  incIndex();

  let temp = parse(tokens : tokens);

  if case let .Expr(let i) = temp {
    e = i;
  }
  return .Decl(.Let(false, x, e));
}

func parseBinOp(tokens : [Token]) -> ml_phrase {
  var op;
  var e2;
  var e1;
  switch tokens[index] {
  case .Integer(let i):
    e1 = .Cost(.Int(i));
    break;

  case .ODouble(let i):
    e1 = .Cost(.Float(i));
    break;

  case .Identifier(let i):
    e1 = .Var(i);
    break;
  }
  incIndex();

  if case let .ArithOp(let i) = tokens[index] {
    op = i;
  }
  incIndex();

  let temp = parse(tokens : tokens);
  if case let .Expr(let i) = temp {
    e2 = i;
  }
  return .Expr(.Binop(op, e1, e2));
}

func parseApp(tokens : [Token]) -> ml_phrase {
  var x;
  var e;
  if case let .Identifier(let v) = tokens[index] {
    x = v;
  }
  incInedx();

  if case let .Identifier(let v) = tokens[index] {
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

  var e1;
  var e2;
  if case let .Expr(let v) = temp1 {
    e1 = v;
  }

  if case let .Expr(let v) = temp2 {
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

  var cond;
  var e1;
  var e2;
  if case let .Expr(let v) = temp {
    cond = v;
  }

  if case let .Expr(let v) = temp1 {
    e1 = v;
  }
  if case let .Expr(let v) = temp2 {
    e2 = v;
  }

  return .Expr(.Cond(cond, e1, e2));
}

func parseAbs(tokens : [Token]) -> ml_phrase {
  incIndex(); // pass Function
  var x;
  if case let .Identifier(let v) = tokens[index] {
    x = v;
  }
  incIndex();
  invIndex(): // pass Arrow

  let temp = parse(tokens: tokens);
  var body;
  if case let .Expr(let v) = temp {
    body = v;
  }

  return .Expr(.Abs(x, body));
}
