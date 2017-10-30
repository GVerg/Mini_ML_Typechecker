let list_1 = List.Cons(1, List.Cons(2, List.Cons(3, List.Cons(4, List.Nil))));
let list_2 = List.Cons(1, List.Cons(2, List.Cons(3, List.Nil)));
let listR = substract(list_1 : list_1, list_2 : list_2);
try print(hd(list : listR));
try print(hd(list : tl(list : tl(list : list_1))));

func add(integer : Int) -> Int {
  return integer + 1;
}

let other_name = add;
try print(hd(list : map(function : other_name, list : list_1)));
print(other_name(0));



/**** Other exemples ****

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
*/
