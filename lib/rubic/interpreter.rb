require 'rubic/parser'
require 'rubic/environment'

module Rubic
  class Interpreter
    DEFAULT_GLOBAL_VARS = {
      '+' => -> (*args) { args.reduce(:+) },
      '-' => -> (*args) { args.size == 1 ? -args.first : args.reduce(:-) },
      '*' => -> (*args) { args.reduce(:*) },
      '/' => -> (*args) { args.reduce(:/) },
      '<' => -> (a, b) { a < b },
      '>' => -> (a, b) { a > b },
      '=' => -> (a, b) { a == b },
    }

    def initialize
      @parser = Parser.new
      @global = Environment.new
      DEFAULT_GLOBAL_VARS.each {|k, v| @global[k] = v }
    end

    def evaluate(str)
      list = @parser.parse(str)
      execute(list, @global)
    end

    private

    def execute(list_or_atom, env)
      # Atom
      case list_or_atom
      when Float, Integer
        atom = list_or_atom
      when String
        atom = env[list_or_atom]
      else
        # fallthrough
      end
      return atom if atom

      list = list_or_atom
      # Special Forms
      case list.first
      when :define
        _, name, expr = list
        env[name] = execute(expr, env)
        return
      when :define_proc
        _, (name, *params), body = list
        env[name] = -> (*args) do
          local = Environment.new(env)
          local.bind(params, args)
          execute(body, local)
        end
        return
      when :cond
        _, *clauses = list
        clauses.each do |pred, expr|
          if pred == :else || execute(pred, env)
            return execute(expr, env)
          end
        end
        return
      else
        # fallthrough
      end

      # Anything else
      op, *args = list.map {|e| execute(e, env) }
      op.call(*args)
    end
  end
end
