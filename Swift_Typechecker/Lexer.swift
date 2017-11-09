/*
* source : https://github.com/matthewcheok/Kaleidoscope
*/

import Foundation

public enum Token {
    case OLet
    case OLetin
    case In
    case Identifier(String)
    case OInteger(Int)//TODO : to check
    case ODouble(Float)
    case ParensOpen
    case ParensClose
    case Comma
    case Other(String)
    case Equal
    case ArithOp(String)
    case Semicolon
    case DoubleSemicolon
    case If
    case Then
    case Else
    case Arrow
    case Function
    case OEmptyList
    case Concat
    case OUnit
}

typealias TokenGenerator = (String) -> Token?
let tokenList: [(String, TokenGenerator)] = [
    ("[ \t\n]", { _ in nil }),
    ("\\[\\]", { _ in .OEmptyList }),
    ("\\(\\)", { _ in .OUnit }),
    ("let", { _ in .OLet }),
    ("_let", { _ in .OLetin }),
    ("in", { _ in .In }),
    ("if", { _ in .If }),
    ("then", { _ in .Then }),
    ("else", { _ in .Else }),
    ("function", { _ in .Function }),
    ("[a-zA-Z][a-zA-Z0-9]*", {.Identifier($0) }),
    ("[0-9]+\\.[0-9]*", { (r: String) in .ODouble((r as NSString).floatValue) }),
    ("[0-9]+", { (r: String) in .OInteger(Int((r as NSString).intValue))}),//TODO : to check
    ("\\(", { _ in .ParensOpen }),
    ("\\)", { _ in .ParensClose }),
    ("->", { _ in .Arrow }),
    ("::", { _ in .Concat }),
    (",", { _ in .Comma }),
    ("=", { _ in .Equal }),
    ("[+-/]", { .ArithOp($0) }),
    (";;", { _ in .DoubleSemicolon }),
    (";", { _ in .Semicolon }),

]

public class Lexer {
    let input: String
    init(input: String) {
        self.input = input
    }
    public func tokenize() -> [Token] {
        var tokens = [Token]()
        var content = input

        while (content.characters.count > 0) {
            var matched = false

            for (pattern, generator) in tokenList {
                if let m = content.match(regex: pattern) {
                    if let t = generator(m) {
                        tokens.append(t)
                    }

                    content=content.substring(from: content.index(content.startIndex, offsetBy:m.characters.count))
                    matched = true
                    break
                }
            }

            if !matched {
                let index = content.index(content.startIndex,offsetBy: 1)
                tokens.append(.Other(content.substring(to: index)))
                content = content.substring(from:index)
            }
        }
        return tokens
    }
}
