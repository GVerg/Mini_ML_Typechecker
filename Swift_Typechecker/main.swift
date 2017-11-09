let p1 = "_let x = _let y = 2 in y in x;;"
let p2 = "_let x = 5 in x;;"
let p3 = "_let y = function x -> x in y;;"
let p4 = "_let a = 5 in _let y = function x -> x in y a;;" //l'inferance de type ne marche pas
let p5 = "_let a = (5., 3) in a;;"
let p6 = "_let a = (function x -> x, function y -> y) in a;;"
let p7 = "_let a = if true then 5 else 9 in a;;"

let l = Lexer(input: p6); // changez l'exemple ici

let ast = parse(tokens: l.tokenize())

print("Affichage de l'ast : \n \(ast)")

print("-----------------------")
if case .Expr(let x) = ast {
   type_check(expr : x)
}

