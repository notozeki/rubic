require 'rubic/parser'

module Rubic
  class Interpreter
    DEFAULT_GLOBAL_VARS = {
      '+' => -> (*args) { args.reduce(:+) },
      '-' => -> (*args) { args.reduce(:-) },
      '*' => -> (*args) { args.reduce(:*) },
      '/' => -> (*args) { args.reduce(:/) },
    }

    def initialize
      @parser = Parser.new
      @global = DEFAULT_GLOBAL_VARS
    end

    def evaluate(str)
      list = @parser.parse(str)
      execute(list)
    end

    private

    def execute(list_or_atom)
      # Atom
      case list_or_atom
      when Float, Integer
        atom = list_or_atom
      when String
        atom = @global[list_or_atom]
        raise "undefined variable `#{list_or_atom}'" unless atom
      end
      return atom if atom

      list = list_or_atom
      # Special Forms
      case list.first
      when :define
        _, name, expr = list
        @global[name] = execute(expr)
        return
      else
        # fallthrough
      end

      # Anything else
      op, *args = list.map {|e| execute(e) }
      op.call(*args)
    end
  end
end
