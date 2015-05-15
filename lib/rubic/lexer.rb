require 'strscan'

module Rubic
  class Lexer
    EOT = [false, nil] # end of token
    SYM_CHARS = Regexp.escape("+-*/<>=!?")
    KEYWORD_TABLE = {
      'define' => :KW_DEFINE,
      'cond'   => :KW_COND,
      'else'   => :KW_ELSE,
      'if'     => :KW_IF,
      'and'    => :KW_AND,
      'or'     => :KW_OR,
      'lambda' => :KW_LAMBDA,
      'let'    => :KW_LET,
      'quote'  => :KW_QUOTE,
      'set!'   => :KW_SET_BANG,
      'begin'  => :KW_BEGIN,
    }

    def initialize(str)
      @s = StringScanner.new(str)
      @state = :start
    end

    def next_token
      case @state
      when :start
        @s.skip(/\s+/)
        return EOT if @s.eos?

        case
        when @s.check(/[+-]?[.0-9]|[+-]i/)
          @state = :num_char
          next_token

        when @s.check(/#/)
          @state = :num_prefix
          next_token

        when @s.scan(/[()']/)
          [@s[0], nil]

        when @s.scan(/[A-Za-z_#{SYM_CHARS}][A-Za-z0-9_#{SYM_CHARS}]*/o)
          if KEYWORD_TABLE.key? @s[0]
            [KEYWORD_TABLE.fetch(@s[0]), nil]
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
          }.fetch(@s[0])
        else
          @state = :num_char
          next_token
        end

      when :num_char
        case
        when @s.check(/[+-]?[.0-9a-f\/]*i/i) # complex
          @state = :num_char_complex
          next_token
        when @s.scan(/\+/)
          [:U_PLUS, '+']
        when @s.scan(/-/)
          [:U_MINUS, '-']
        when @s.scan(/[@.0-9a-f\/]/i)
          [@s[0].downcase, @s[0].downcase]
        else
          @state = :num_wrapup
          next_token
        end

      when :num_char_complex
        case
        when @s.scan(/[-+@.0-9a-fi\/]/i)
          [@s[0].downcase, @s[0].downcase]
        else
          @state = :num_wrapup
          next_token
        end

      when :num_wrapup
        case
        when @s.eos? || @s.check(/[\s()";]/) # separator characters
          @state = :start
          [:NUM_END, nil]
        else
          @state = :start
          next_token
        end

      else # NOT REACHED
        raise "unknown state: #{@state}"

      end
    end

  end
end
