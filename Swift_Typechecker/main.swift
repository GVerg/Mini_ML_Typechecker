let s : vartype = .Unknown(2);

func f(a:vartype) -> Int {
  switch a {
  case .Unknown(let x) :
    return x
  case _ :
    return 0
  }
}

print(f(a:s));

let s2 : ml_const = .Bool(true);
let s3 : ml_expr = .Const(s2);

func f(a:ml_const) -> Bool {
  switch a {
  case .Bool(let x) :
    return x
  case _ :
    return false
  }
}

func f(a:ml_expr) -> Bool {
    switch a {
    case .Const(let x) :
      return f(a:x);
    case _ :
      return false;
    }
}

print(f(a:s3));
