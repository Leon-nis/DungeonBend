import Char/to_u32 as M__Char_to_u32

def _digit_value_upper(code: U32) -> Maybe(U32):
  match code > 57:
    case 1:
      none{}
    case _:
      some{code - 48}

def _digit_value(code: U32) -> Maybe(U32):
  match code < 48:
    case 1:
      none{}
    case _:
      _digit_value_upper(code)

def _parse_digits(chars: String, acc: U32) -> Maybe(U32):
  match chars:
    case []:
      some{acc}
    case head<>rest:
      match _digit_value(Char/to_u32(head)):
        case some{digit}:
          _parse_digits(rest, (acc * 10) + digit)
        case none{}:
          none{}

def to_u32(value: String) -> Maybe(U32):
  match value:
    case []:
      none{}
    case _:
      _parse_digits(value, 0)
