require 'rubic/builtin'
require 'rubic/environment'
require 'rubic/parser'

module Rubic
  class Interpreter
    DEFAULT_GLOBAL_VARS = {
      :not => -> (a) { !a },
      :eq? => -> (a, b) { a.equal? b },

      :true => true,
      :false => false,
      :nil => [],
    }

    def initialize
      @parser = Parser.new
      @global = Environment.new
      DEFAULT_GLOBAL_VARS.each {|k, v| @global[k] = v }
      builtins = Rubic::Builtin.constants.map {|c| Rubic::Builtin.const_get(c) }
      builtins.each {|ext| @global.extend(ext) }
    end

    def evaluate(str)
      seq = @parser.parse(str)
      execute_sequence(seq, @global)
    end

    private

    def execute(list_or_atom, env)
      # Atom
      case list_or_atom
      when Numeric, String
        atom = list_or_atom
      when Symbol
        atom = env[list_or_atom]
      else
        # fallthrough
      end
      return atom unless atom.nil?

      list = list_or_atom

      # Empty list
      return [] if list.empty?

      # Special Forms
      case list.first
      when :define
        if list[1].is_a?(Array) # procedure definition
          _, (name, *params), *body = list
          env[name] = -> (*args) do
            local = Environment.new(env)
            local.bind(params, args)
            execute_sequence(body, local)
          end
          return
        else # variable definition
          _, name, expr = list
          env[name] = execute(expr, env)
          return
        end

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
          execute_sequence(body, local)
        end

      when :let
        _, (*defs), *body = list
        local = Environment.new(env)
        defs.each {|name, expr| local[name] = execute(expr, env) }
        return execute_sequence(body, local)

      when :quote
        _, expr = list
        return quote(expr)

      when :set!
        _, name, expr = list
        env.assign(name, execute(expr, env))
        return

      when :begin
        _, *seq = list
        return execute_sequence(seq, env)

      else
        # fallthrough
      end

      # Procedure call
      op, *args = list.map {|e| execute(e, env) }
      unless op.respond_to? :call
        raise Rubic::RuntimeError, "`#{op}' is not a procedure"
      end
      required = op.arity >= 0 ? op.arity : -op.arity - 1
      if op.arity >= 0 ? required != args.size : required > args.size
        raise Rubic::ArgumentError, "wrong number of arguments (#{args.size} for #{required})"
      end
      op.call(*args)
    end

    def execute_sequence(seq, env)
      # execute expressions sequentially and returns the last result
      seq.reduce(nil) {|res, expr| res = execute(expr, env) }
    end

    def quote(expr)
      if expr.is_a? Array
        expr.map {|e| quote(e) }.reverse.reduce([]) {|res, e| [e, res] }
      else
        expr
      end
    end
  end
end
