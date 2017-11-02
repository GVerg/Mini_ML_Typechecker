indirect enum Exception : Error {
case Error(Exception, Int, Int);
case Unterminated_string;
case Unterminated_comment;
case Unterminated_stringt;
case Bad_char_constant;
case Illegal_character;
case No_More_Types;
case Type_error(typing_error);
}

enum ListError: Error {
case FunctionFailed(functionError : String);
case Invalid_Argument(functionError : String);
case Not_Found(functionError : String);
}
