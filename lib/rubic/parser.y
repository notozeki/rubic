class Parser
  options no_result_var

rule
  program : opt_seq

  expr  : '(' KW_AND seq ')'
          {
            [:and, *val[2]]
          }
        | '(' KW_OR seq ')'
          {
            [:or, *val[2]]
          }
        | '(' expr opt_seq ')'
          {
            [val[1], *val[2]]
          }
        | '(' ')'
          {
            []
          }
        | IDENT
        | number
        | STRING
        | define
        | cond
        | if
        | lambda
        | let
        | quote
        | set
        | begin

  seq     : expr
            {
              [val[0]]
            }
          | seq expr
            {
              val[0].push(val[1])
            }

  opt_seq : /* empty */
            {
              []
            }
          | seq

  /* Define statement */
  define  : '(' KW_DEFINE IDENT expr ')'
            {
              [:define, val[2], val[3]]
            }
          | '(' KW_DEFINE '(' IDENT params ')' seq ')'
            {
              [:define, [val[3], *val[4]], *val[6]]
            }

  params      : /* empty */
                {
                  []
                }
              | params IDENT
                {
                  val[0].push(val[1])
                }

  /* Condition statement */
  cond    : '(' KW_COND clauses ')'
            {
              [:cond, *val[2]]
            }

  clauses : clause
            {
              [val[0]]
            }
          | clauses clause
            {
              val[0].push(val[1])
            }

  clause  : '(' expr expr ')'
            {
              [val[1], val[2]]
            }
          | '(' KW_ELSE expr ')'
            {
              [:else, val[2]]
            }

  /* If statement */
  if  : '(' KW_IF expr expr expr ')'
        {
          [:if, val[2], val[3], val[4]]
        }

  /* lambda expression */
  lambda  : '(' KW_LAMBDA '(' params ')' seq ')'
            {
              [:lambda, val[3], *val[5]]
            }

  /* let expression */
  let   : '(' KW_LET '(' defs ')' seq ')'
          {
            [:let, val[3], *val[5]]
          }
  defs  : /* empty */
          {
            []
          }
        | defs '(' IDENT expr ')'
          {
            val[0].push([val[2], val[3]])
          }

  /* quote expression */
  quote : '(' KW_QUOTE expr ')'
          {
            [:quote, val[2]]
          }
        | '\'' expr
          {
            [:quote, val[1]]
          }

  /* set expression */
  set : '(' KW_SET_BANG IDENT expr ')'
        {
          [:set!, val[2], val[3]]
        }

  /* begin expression */
  begin : '(' KW_BEGIN seq ')'
          {
            [:begin, *val[2]]
          }

  number  : binary NUM_END { val[0] }
          | octal NUM_END { val[0] }
          | decimal NUM_END { val[0] }
          | hexadecimal NUM_END { val[0] }

  binary    : b_prefix b_complex
              { val[0].nil? ? val[1] : (val[0] ? to_exact(val[1]) : to_inexact(val[1])) }
  b_complex : b_real
            | b_real '@' b_real      { Complex.polar(val[0], val[2]) }
            | b_real '+' b_ureal 'i' { Complex(val[0], val[2]) }
            | b_real '-' b_ureal 'i' { Complex(val[0], -val[2]) }
            | b_real '+' 'i'         { Complex(val[0], 1) }
            | b_real '-' 'i'         { Complex(val[0], -1) }
            | '+' b_ureal 'i'        { Complex(0, val[1]) }
            | '-' b_ureal 'i'        { Complex(0, -val[1]) }
            | '+' 'i'                { Complex(0, 1) }
            | '-' 'i'                { Complex(0, -1) }
  b_real    : sign b_ureal           { val[0] == '-' ? -val[1] : val[1] }
  b_ureal   : b_uint
            | b_uint '/' b_uint      { Rational(val[0], val[2]) }
  b_uint    : b_chars                { val[0].to_i(2) }
  b_chars   : b_char
            | b_chars b_char         { val[0] << val[1] }
  b_char    : '0' | '1'
  b_prefix  : NUM_PREFIX_B exactness { val[1] }
            | exactness NUM_PREFIX_B { val[0] }

  octal     : o_prefix o_complex
              { val[0].nil? ? val[1] : (val[0] ? to_exact(val[1]) : to_inexact(val[1])) }
  o_complex : o_real
            | o_real '@' o_real      { Complex.polar(val[0], val[2]) }
            | o_real '+' o_ureal 'i' { Complex(val[0], val[2]) }
            | o_real '-' o_ureal 'i' { Complex(val[0], -val[2]) }
            | o_real '+' 'i'         { Complex(val[0], 1) }
            | o_real '-' 'i'         { Complex(val[0], -1) }
            | '+' o_ureal 'i'        { Complex(0, val[1]) }
            | '-' o_ureal 'i'        { Complex(0, -val[1]) }
            | '+' 'i'                { Complex(0, 1) }
            | '-' 'i'                { Complex(0, -1) }
  o_real    : sign o_ureal           { val[0] == '-' ? -val[1] : val[1] }
  o_ureal   : o_uint
            | o_uint '/' o_uint      { Rational(val[0], val[2]) }
  o_uint    : o_chars                { val[0].to_i(8) }
  o_chars   : o_char
            | o_chars o_char         { val[0] << val[1] }
  o_char    : '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7'
  o_prefix  : NUM_PREFIX_O exactness { val[1] }
            | exactness NUM_PREFIX_O { val[0] }

  decimal   : d_prefix d_complex
              { val[0].nil? ? val[1] : (val[0] ? to_exact(val[1]) : to_inexact(val[1])) }
  d_complex : d_real
            | d_real '@' d_real      { Complex.polar(val[0], val[2]) }
            | d_real '+' d_ureal 'i' { Complex(val[0], val[2]) }
            | d_real '-' d_ureal 'i' { Complex(val[0], -val[2]) }
            | d_real '+' 'i'         { Complex(val[0], 1) }
            | d_real '-' 'i'         { Complex(val[0], -1) }
            | '+' d_ureal 'i'        { Complex(0, val[1]) }
            | '-' d_ureal 'i'        { Complex(0, -val[1]) }
            | '+' 'i'                { Complex(0, 1) }
            | '-' 'i'                { Complex(0, -1) }
  d_real    : sign d_ureal           { val[0] == '-' ? -val[1] : val[1] }
  d_ureal   : d_uint
            | d_uint '/' d_uint      { Rational(val[0], val[2]) }
            | d_decimal
  d_decimal : d_uint suffix          { val[0].to_f * (10 ** val[1]) }
            | '.' d_chars suffix     { "0.#{val[1]}".to_f * (10 ** val[2]) }
            | d_chars '.' d_chars suffix
              { "#{val[0]}.#{val[2]}".to_f * (10 ** val[3]) }
            | d_chars '.' suffix     { val[0].to_f * (10 ** val[2]) }
  d_uint    : d_chars                { val[0].to_i(10) }
  d_chars   : d_char
            | d_chars d_char         { val[0] << val[1] }
  d_char    : '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
  d_prefix  : NUM_PREFIX_D exactness { val[1] }
            | exactness NUM_PREFIX_D { val[0] }
            | exactness

  hexadecimal : h_prefix h_complex
                { val[0].nil? ? val[1] : (val[0] ? to_exact(val[1]) : to_inexact(val[1])) }
  h_complex : h_real
            | h_real '@' h_real      { Complex.polar(val[0], val[2]) }
            | h_real '+' h_ureal 'i' { Complex(val[0], val[2]) }
            | h_real '-' h_ureal 'i' { Complex(val[0], -val[2]) }
            | h_real '+' 'i'         { Complex(val[0], 1) }
            | h_real '-' 'i'         { Complex(val[0], -1) }
            | '+' h_ureal 'i'        { Complex(0, val[1]) }
            | '-' h_ureal 'i'        { Complex(0, -val[1]) }
            | '+' 'i'                { Complex(0, 1) }
            | '-' 'i'                { Complex(0, -1) }
  h_real    : sign h_ureal           { val[0] == '-' ? -val[1] : val[1] }
  h_ureal   : h_uint
            | h_uint '/' h_uint      { Rational(val[0], val[2]) }
  h_uint    : h_chars                { val[0].to_i(16) }
  h_chars   : h_char
            | h_chars h_char         { val[0] << val[1] }
  h_char    : '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
            | 'a' | 'b' | 'c' | 'd' | 'e' | 'f'
  h_prefix  : NUM_PREFIX_X exactness { val[1] }
            | exactness NUM_PREFIX_X { val[0] }

  suffix    : /* empty */
              { 0 }
            | exponent_marker sign d_chars
              { val[1] == '-' ? -val[2].to_i : val[2].to_i }
  exponent_marker : 'e'
  sign      : /* empty */ | U_PLUS | U_MINUS
  exactness : /* empty */ | NUM_PREFIX_E | NUM_PREFIX_I
end

---- header
require 'strscan'

module Rubic

---- inner
EOT = [false, nil] # end of token
SYM_CHARS = Regexp.escape("+-*/<>=!?")

def parse(str)
  @s = StringScanner.new(str)
  @lex_state = :start
  do_parse
end

def next_token
  case @lex_state
  when :start
    @s.skip(/\s+/)
    return EOT if @s.eos?

    case
    when @s.check(/[+-]?[.0-9]|[+-]i/)
      @lex_state = :num_char
      next_token

    when @s.check(/#/)
      @lex_state = :num_prefix
      next_token

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
      when 'set!'
        [:KW_SET_BANG, nil]
      when 'begin'
        [:KW_BEGIN, nil]
      else
        [:IDENT, @s[0].to_sym]
      end

    when @s.scan(/"([^"]*)"/)
      [:STRING, @s[1]]

    else
      raise Rubic::ParseError, "unknown character #{@s.getch}"

    end

  when :num_prefix
    case
    when @s.scan(/#[eibodx]/)
      {
        '#e' => [:NUM_PREFIX_E, true],
        '#i' => [:NUM_PREFIX_I, false],
        '#b' => [:NUM_PREFIX_B, nil],
        '#o' => [:NUM_PREFIX_O, nil],
        '#d' => [:NUM_PREFIX_D, nil],
        '#x' => [:NUM_PREFIX_X, nil],
      }[@s[0]]
    else
      @lex_state = :num_char
      next_token
    end

  when :num_char
    case
    when @s.check(/[+-]?[.0-9a-f\/]*i/i) # complex
      @lex_state = :num_char_complex
      next_token
    when @s.scan(/\+/)
      [:U_PLUS, '+']
    when @s.scan(/-/)
      [:U_MINUS, '-']
    when @s.scan(/[@.0-9a-f\/]/i)
      [@s[0].downcase, @s[0].downcase]
    else
      @lex_state = :num_suffix
      next_token
    end

  when :num_char_complex
    case
    when @s.scan(/[-+@.0-9a-fi\/]/i)
      [@s[0].downcase, @s[0].downcase]
    else
      @lex_state = :num_suffix
      next_token
    end

  when :num_suffix
    case
    when @s.eos? || @s.check(/[\s()";]/) # separator characters
      @lex_state = :start
      [:NUM_END, nil]
    when @s.scan(/ie/i) # i is imaginary, e is exponent marker
      [@s[0].downcase, @s[0].downcase]
    when @s.scan(/\+/)
      [U_PLUS, '+']
    when @s.scan(/-/)
      [U_MINUS, '-']
    when @s.scan(/[0-9]/)
      [@s[0], @s[0]]
    else
      @lex_state = :start
      next_token
    end

  else # NOT REACHED
    raise "unknown state: #{@lex_state}"

  end
end

def on_error(t, val, vstack)
  raise Rubic::ParseError, "parse error near #{token_to_str(t)}"
end

def to_exact(num)
  case num
  when Integer, Rational
    num
  when Float
    num.to_r
  when Complex
    Complex(num.real.to_r, num.imag.to_r)
  else
    raise TypeError, "unexpected type of number: #{num.class}"
  end
end

def to_inexact(num)
  case num
  when Integer, Rational, Float
    num.to_f
  when Complex
    Complex(num.real.to_f, num.imag.to_f)
  else
    raise TypeError, "unexpected type of number: #{num.class}"
  end
end

---- footer
end # of module Rubic
