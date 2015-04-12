class Parser
  options no_result_var

rule
  target  : expr

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
          | NUMBER

  exprs   : expr
            {
              [val[0]]
            }
          | exprs expr
            {
              val[0].push(val[1])
            }
end

---- header
require 'strscan'

module Rubic
  class UnknownCharacterError < StandardError; end

---- inner
EOT = [false, nil] # end of token

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
  else
    raise UnknownCharacterError, "unknown character #{@s.getch}"
  end
end

---- footer
end # of module Rubic
