import Foundation

public enum Token {
    case Let
    case In
    case Identifier(String)
    case Number(Float)
    case ParensOpen
    case ParensClose
    case Comma
    case Other(String)
    case Equal
    case ArithOp(String)
    case Semicolon
    case If
    case Then
    case Else
    case Arrow
    case Function
    case EmptyList
    case Concat
    case Unit
}

typealias TokenGenerator = (String) -> Token?
let tokenList: [(String, TokenGenerator)] = [
    ("[ \t\n]", { _ in nil }),
    ("\\[\\]", { _ in .EmptyList }),
    ("\\(\\)", { _ in .Unit }),
    ("let", { _ in .Let }),
    ("in", { _ in .In }),
    ("if", { _ in .If }),
    ("then", { _ in .Then }),
    ("else", { _ in .Else }),
    ("function", { _ in .Function }),
    ("[a-zA-Z][a-zA-Z0-9]*", {.Identifier($0) }),
    ("[0-9.]+", { (r: String) in .Number((r as NSString).floatValue) }),
    ("\\(", { _ in .ParensOpen }),
    ("\\)", { _ in .ParensClose }),
    ("->", { _ in .Arrow }),
    ("::", { _ in .Concat }),
    (",", { _ in .Comma }),
    ("=", { _ in .equal }),
    ("[+-/]", { .ArithOp($0) }),
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
                if let m = content.match(pattern) {
                    if let t = generator(m) {
                        tokens.append(t)
                    }

                    content = content.substringFromIndex(content.startIndex.advancedBy(m.characters.count))
                    matched = true
                    break
                }
            }

            if !matched {
                let index = content.startIndex.advancedBy(1)
                tokens.append(.Other(content.substringToIndex(index)))
                content = content.substringFromIndex(index)
            }
        }
        return tokens
    }
}
