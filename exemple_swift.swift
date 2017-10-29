let (a,b) = (2,3)

indirect enum piece {
  case Pile
  case Face
}

indirect enum val_piece {
  case Dame(piece)
  case Roi(piece)
}

indirect enum val_piece2 {
  case Dame(Int)
  case Roi(Int)
}

let a : val_piece = (.Dame(.Pile))

func f(a:val_piece) -> Int {
  switch a {
    case .Dame(.Face) :
    return 1
    case .Dame(.Pile) : 
    return 2
    default : 
    return 3
  }
}

func f(a:String, b:String) -> String {
  return a + b
}


f(a:"coucou", b:" Hatem !!!!")

indirect enum Liste<E> {
  case Nil
  case S(E, Liste)
}

func f2(a1 : Liste<Int>) -> Liste<Int> {
  switch a1 {
    case Liste.S(let h3, Liste.S(let g4, let t5)) :
      return t5
    case Liste.Nil :
      return Liste.Nil
    case _ :
      return Liste.Nil
  }
}

let a : Liste<Int> = .S(3,.Nil)

func f<E,F>(a:E, b:F) -> Int {
  2+2
  return 42
}

func cons<E>(elem:E, list:Liste<E>) -> Liste<E> {
  return Liste.S(elem, list)
}

func long(l:Liste<Int>) -> Int {
  switch l {
    case .Nil : 
    return 0
    case Liste.S(let deb, let suite) :
    return 1 + long(l : suite)
  }
}

let l = Liste.S(3,Liste.S(2,Liste.Nil))



let c = (re:2,im:3)

func imply(v:(Bool,Bool)) -> Bool {
  switch v {
    case (true, let x) :
    return x
    case (false, _) : 
    return true
  }
}

let a = imply(v:(true, false))