class Parser
  options no_result_var

rule
  target  : expr
          | define

  expr    : '(' '+' exprs ')'
            {
              val[2].reduce(&:+)
            }
          | '(' '-' exprs ')'
            {
              val[2].reduce(&:-)
            }
          | '(' '*' exprs ')'
            {
              val[2].reduce(&:*)
            }
          | '(' '/' exprs ')'
            {
              val[2].reduce(&:'/')
            }
          | IDENT
            {
              @global[val[0]]
            }
          | NUMBER

  exprs   : expr
            {
              [val[0]]
            }
          | exprs expr
            {
              val[0].push(val[1])
            }

  define  : '(' KW_DEFINE IDENT expr ')'
            {
              @global[val[2]] = val[3]
            }
end

---- header
require 'strscan'

module Rubic
  class UnknownCharacterError < StandardError; end

---- inner
EOT = [false, nil] # end of token

def initialize
  @global = {}
end

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
  when @s.scan(/[#{Regexp.escape("()+-*/")}]/o)
    [@s[0], nil]
  when @s.scan(/[A-Za-z_][A-Za-z0-9_]*/)
    case @s[0] # keyword check
    when 'define'
      [:KW_DEFINE, nil]
    else
      [:IDENT, @s[0]]
    end
  else
    raise UnknownCharacterError, "unknown character #{@s.getch}"
  end
end

---- footer
end # of module Rubic
