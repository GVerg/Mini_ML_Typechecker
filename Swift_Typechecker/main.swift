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
    return !x
  case _ :
    return false
  }
}

func f(a:ml_expr) -> Bool {
  switch a {
  case .Const(let x) :
    // problem here : access to the value
  let y = x.Bool(let z);
    return z;
  case _ :
    return false
  }
}


let result = f(a:s3);

if(result) {
  print(result);
} else {
  print("There is a problem\n");
}
