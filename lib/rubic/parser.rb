#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.12
# from Racc grammer file "".
#

require 'racc/parser.rb'

require 'strscan'

module Rubic

class Parser < Racc::Parser

module_eval(<<'...end parser.y/module_eval...', 'parser.y', 134)
EOT = [false, nil] # end of token
SYM_CHARS = Regexp.escape("+-*/<>=?")

def parse(str)
  @s = StringScanner.new(str)
  do_parse
end

def next_token
  @s.skip(/\s+/)
  return EOT if @s.eos?

  case
  when @s.scan(/[0-9]+(\.[0-9]+)?/)
    [:NUMBER, @s[0].include?('.') ? @s[0].to_f : @s[0].to_i]
  when @s.scan(/[()']/)
    [@s[0], nil]
  when @s.scan(/[A-Za-z_#{SYM_CHARS}][A-Za-z0-9_#{SYM_CHARS}]*/o)
    case @s[0] # keyword check
    when 'define'
      [:KW_DEFINE, nil]
    when 'cond'
      [:KW_COND, nil]
    when 'else'
      [:KW_ELSE, nil]
    when 'if'
      [:KW_IF, nil]
    when 'and'
      [:KW_AND, nil]
    when 'or'
      [:KW_OR, nil]
    when 'lambda'
      [:KW_LAMBDA, nil]
    when 'let'
      [:KW_LET, nil]
    when 'quote'
      [:KW_QUOTE, nil]
    else
      [:IDENT, @s[0].to_sym]
    end
  when @s.scan(/"([^"]*)"/)
    [:STRING, @s[1]]
  else
    raise Rubic::ParseError, "unknown character #{@s.getch}"
  end
end

def on_error(t, val, vstack)
  raise Rubic::ParseError, "parse error near #{token_to_str(t)}"
end

...end parser.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
     3,    64,    67,    60,     4,     5,     6,     3,    37,    75,
    47,     4,     5,     6,    15,    34,    63,    55,    62,    33,
    65,    15,     3,    17,    20,    18,     4,     5,     6,    21,
    22,    66,    23,    24,    25,    26,    15,     3,    46,    44,
     3,     4,     5,     6,     4,     5,     6,    61,    40,    60,
    70,    15,     3,    39,    15,     3,     4,     5,     6,     4,
     5,     6,    37,    54,    29,    16,    15,     3,    76,    15,
     3,     4,     5,     6,     4,     5,     6,   nil,   nil,   nil,
   nil,    15,   nil,     3,    15,    73,   nil,     4,     5,     6,
     3,   nil,    72,   nil,     4,     5,     6,    15,   nil,   nil,
   nil,     3,   nil,   nil,    15,     4,     5,     6,     3,   nil,
   nil,   nil,     4,     5,     6,    15,   nil,   nil,   nil,     3,
   nil,   nil,    15,     4,     5,     6,     3,   nil,   nil,   nil,
     4,     5,     6,    15,   nil,   nil,   nil,     3,   nil,    42,
    15,     4,     5,     6,     3,   nil,    43,   nil,     4,     5,
     6,    15,   nil,   nil,   nil,     3,   nil,   nil,    15,     4,
     5,     6,     3,   nil,   nil,   nil,     4,     5,     6,    15,
   nil,   nil,   nil,     3,   nil,   nil,    15,     4,     5,     6,
     3,   nil,   nil,   nil,     4,     5,     6,    15,   nil,   nil,
   nil,     3,   nil,   nil,    15,     4,     5,     6,     3,   nil,
   nil,   nil,     4,     5,     6,    15,   nil,   nil,   nil,     3,
   nil,   nil,    15,     4,     5,     6,   nil,   nil,    50,   nil,
   nil,   nil,   nil,    15 ]

racc_action_check = [
     0,    56,    59,    56,     0,     0,     0,    71,    35,    71,
    35,    71,    71,    71,     0,    21,    53,    45,    53,    21,
    57,    71,     3,     3,     3,     3,     3,     3,     3,     3,
     3,    58,     3,     3,     3,     3,     3,    14,    34,    32,
    15,    14,    14,    14,    15,    15,    15,    52,    25,    52,
    63,    14,    70,    24,    15,    17,    70,    70,    70,    17,
    17,    17,    22,    41,    16,     1,    70,    18,    74,    17,
    19,    18,    18,    18,    19,    19,    19,   nil,   nil,   nil,
   nil,    18,   nil,    69,    19,    69,   nil,    69,    69,    69,
    68,   nil,    68,   nil,    68,    68,    68,    69,   nil,   nil,
   nil,    23,   nil,   nil,    68,    23,    23,    23,    64,   nil,
   nil,   nil,    64,    64,    64,    23,   nil,   nil,   nil,    62,
   nil,   nil,    64,    62,    62,    62,    26,   nil,   nil,   nil,
    26,    26,    26,    62,   nil,   nil,   nil,    30,   nil,    30,
    26,    30,    30,    30,    31,   nil,    31,   nil,    31,    31,
    31,    30,   nil,   nil,   nil,    61,   nil,   nil,    31,    61,
    61,    61,    33,   nil,   nil,   nil,    33,    33,    33,    61,
   nil,   nil,   nil,    51,   nil,   nil,    33,    51,    51,    51,
    50,   nil,   nil,   nil,    50,    50,    50,    51,   nil,   nil,
   nil,    49,   nil,   nil,    50,    49,    49,    49,    38,   nil,
   nil,   nil,    38,    38,    38,    49,   nil,   nil,   nil,    37,
   nil,   nil,    38,    37,    37,    37,   nil,   nil,    37,   nil,
   nil,   nil,   nil,    37 ]

racc_action_pointer = [
    -2,    65,   nil,    20,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,    35,    38,    64,    53,    65,    68,
   nil,    13,    60,    99,    51,    46,   124,   nil,   nil,   nil,
   135,   142,    35,   160,    32,     6,   nil,   207,   196,   nil,
   nil,    59,   nil,   nil,   nil,    13,   nil,   nil,   nil,   189,
   178,   171,    43,    14,   nil,   nil,    -3,    16,    27,    -2,
   nil,   153,   117,    44,   106,   nil,   nil,   nil,    88,    81,
    50,     5,   nil,   nil,    64,   nil,   nil ]

racc_action_default = [
   -17,   -35,    -1,   -35,    -6,    -7,    -8,    -9,   -10,   -11,
   -12,   -13,   -14,   -15,   -18,   -35,   -35,   -35,   -35,   -17,
    -5,   -35,   -35,   -35,   -35,   -35,   -35,   -16,   -34,    77,
   -35,   -35,   -35,   -35,   -35,   -35,   -24,   -35,   -35,   -21,
   -31,   -35,    -2,    -3,    -4,   -35,   -21,   -23,   -25,   -35,
   -35,   -35,   -35,   -35,   -33,   -19,   -35,   -35,   -35,   -35,
   -22,   -35,   -35,   -35,   -35,   -26,   -27,   -28,   -35,   -35,
   -35,   -35,   -29,   -30,   -35,   -20,   -32 ]

racc_goto_table = [
    19,    36,     2,    52,     1,    30,    31,    35,    53,   nil,
    56,    27,    28,   nil,    48,   nil,   nil,   nil,   nil,   nil,
    38,    32,   nil,    41,   nil,   nil,   nil,    27,    27,   nil,
    45,   nil,   nil,   nil,    49,    51,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,    57,    58,    59,    68,
    69,   nil,    71,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,    27,    27,    74,    27 ]

racc_goto_check = [
     3,    13,     2,    11,     1,     4,     4,    12,    14,   nil,
    11,     3,     3,   nil,    13,   nil,   nil,   nil,   nil,   nil,
     3,     2,   nil,     3,   nil,   nil,   nil,     3,     3,   nil,
     3,   nil,   nil,   nil,     3,     3,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,     3,     3,     3,     4,
     4,   nil,     4,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,     3,     3,     3,     3 ]

racc_goto_pointer = [
   nil,     4,     2,    -3,   -12,   nil,   nil,   nil,   nil,   nil,
   nil,   -36,   -15,   -21,   -32 ]

racc_goto_default = [
   nil,   nil,   nil,    13,    14,     7,     8,     9,    10,    11,
    12,   nil,   nil,   nil,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 18, :_reduce_none,
  4, 20, :_reduce_2,
  4, 20, :_reduce_3,
  4, 20, :_reduce_4,
  2, 20, :_reduce_5,
  1, 20, :_reduce_none,
  1, 20, :_reduce_none,
  1, 20, :_reduce_none,
  1, 20, :_reduce_none,
  1, 20, :_reduce_none,
  1, 20, :_reduce_none,
  1, 20, :_reduce_none,
  1, 20, :_reduce_none,
  1, 20, :_reduce_none,
  1, 21, :_reduce_15,
  2, 21, :_reduce_16,
  0, 19, :_reduce_17,
  1, 19, :_reduce_none,
  5, 22, :_reduce_19,
  8, 22, :_reduce_20,
  0, 28, :_reduce_21,
  2, 28, :_reduce_22,
  4, 23, :_reduce_23,
  1, 29, :_reduce_24,
  2, 29, :_reduce_25,
  4, 30, :_reduce_26,
  4, 30, :_reduce_27,
  6, 24, :_reduce_28,
  7, 25, :_reduce_29,
  7, 26, :_reduce_30,
  0, 31, :_reduce_31,
  5, 31, :_reduce_32,
  4, 27, :_reduce_33,
  2, 27, :_reduce_34 ]

racc_reduce_n = 35

racc_shift_n = 77

racc_token_table = {
  false => 0,
  :error => 1,
  "(" => 2,
  :KW_AND => 3,
  ")" => 4,
  :KW_OR => 5,
  :IDENT => 6,
  :NUMBER => 7,
  :STRING => 8,
  :KW_DEFINE => 9,
  :KW_COND => 10,
  :KW_ELSE => 11,
  :KW_IF => 12,
  :KW_LAMBDA => 13,
  :KW_LET => 14,
  :KW_QUOTE => 15,
  "'" => 16 }

racc_nt_base = 17

racc_use_result_var = false

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "\"(\"",
  "KW_AND",
  "\")\"",
  "KW_OR",
  "IDENT",
  "NUMBER",
  "STRING",
  "KW_DEFINE",
  "KW_COND",
  "KW_ELSE",
  "KW_IF",
  "KW_LAMBDA",
  "KW_LET",
  "KW_QUOTE",
  "\"'\"",
  "$start",
  "program",
  "opt_seq",
  "expr",
  "seq",
  "define",
  "cond",
  "if",
  "lambda",
  "let",
  "quote",
  "params",
  "clauses",
  "clause",
  "defs" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

# reduce 1 omitted

module_eval(<<'.,.,', 'parser.y', 8)
  def _reduce_2(val, _values)
                [:and, *val[2]]
          
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 12)
  def _reduce_3(val, _values)
                [:or, *val[2]]
          
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 16)
  def _reduce_4(val, _values)
                [val[1], *val[2]]
          
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 20)
  def _reduce_5(val, _values)
                []
          
  end
.,.,

# reduce 6 omitted

# reduce 7 omitted

# reduce 8 omitted

# reduce 9 omitted

# reduce 10 omitted

# reduce 11 omitted

# reduce 12 omitted

# reduce 13 omitted

# reduce 14 omitted

module_eval(<<'.,.,', 'parser.y', 34)
  def _reduce_15(val, _values)
                  [val[0]]
            
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 38)
  def _reduce_16(val, _values)
                  val[0].push(val[1])
            
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 43)
  def _reduce_17(val, _values)
                  []
            
  end
.,.,

# reduce 18 omitted

module_eval(<<'.,.,', 'parser.y', 50)
  def _reduce_19(val, _values)
                  [:define, val[2], val[3]]
            
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 54)
  def _reduce_20(val, _values)
                  [:define, [val[3], *val[4]], *val[6]]
            
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 59)
  def _reduce_21(val, _values)
                      []
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 63)
  def _reduce_22(val, _values)
                      val[0].push(val[1])
                
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 69)
  def _reduce_23(val, _values)
                  [:cond, *val[2]]
            
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 74)
  def _reduce_24(val, _values)
                  [val[0]]
            
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 78)
  def _reduce_25(val, _values)
                  val[0].push(val[1])
            
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 83)
  def _reduce_26(val, _values)
                  [val[1], val[2]]
            
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 87)
  def _reduce_27(val, _values)
                  [:else, val[2]]
            
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 93)
  def _reduce_28(val, _values)
              [:if, val[2], val[3], val[4]]
        
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 99)
  def _reduce_29(val, _values)
                  [:lambda, val[3], *val[5]]
            
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 105)
  def _reduce_30(val, _values)
                [:let, val[3], *val[5]]
          
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 109)
  def _reduce_31(val, _values)
                []
          
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 113)
  def _reduce_32(val, _values)
                val[0].push([val[2], val[3]])
          
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 119)
  def _reduce_33(val, _values)
                [:quote, val[2]]
          
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 123)
  def _reduce_34(val, _values)
                [:quote, val[1]]
          
  end
.,.,

def _reduce_none(val, _values)
  val[0]
end

end   # class Parser

end # of module Rubic
