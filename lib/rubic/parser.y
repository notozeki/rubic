class Parser
  options no_result_var

rule
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
        | IDENT
        | NUMBER
        | STRING
        | define
        | define_proc
        | cond
        | if
        | lambda
        | let

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

  /* Procedure definition */
  define_proc : '(' KW_DEFINE '(' IDENT params ')' seq ')'
                {
                  [:define_proc, [val[3], *val[4]], *val[6]]
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
end

---- header
require 'strscan'

module Rubic

---- inner
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
  when @s.scan(/[\(\)]/o)
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

---- footer
end # of module Rubic
