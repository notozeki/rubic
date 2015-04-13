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
      'not' => -> (a) { !a },
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
        _, (name, *params), *body = list
        env[name] = -> (*args) do
          local = Environment.new(env)
          local.bind(params, args)
          body.map {|expr| execute(expr, local) }.last
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
      when :if
        _, pred, cons, alt = list
        return execute(pred, env) ? execute(cons, env) : execute(alt, env)
      when :and
        _, *exprs = list
        exprs.each do |expr|
          return false unless execute(expr, env)
        end
        return true
      when :or
        _, *exprs = list
        exprs.each do |expr|
          return true if execute(expr, env)
        end
        return false
      when :lambda
        _, (*params), *body = list
        return -> (*args) do
          local = Environment.new(env)
          local.bind(params, args)
          body.map {|expr| execute(expr, local) }.last
        end
      else
        # fallthrough
      end

      # Anything else
      op, *args = list.map {|e| execute(e, env) }
      op.call(*args)
    end
  end
end
