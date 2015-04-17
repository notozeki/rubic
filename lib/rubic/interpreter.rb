require 'rubic/parser'
require 'rubic/environment'
require 'rubic/inspector'

module Rubic
  class Interpreter
    DEFAULT_GLOBAL_VARS = {
      :+ => -> (*args) { args.reduce(:+) },
      :- => -> (*args) { args.size == 1 ? -args.first : args.reduce(:-) },
      :* => -> (*args) { args.reduce(:*) },
      :/ => -> (*args) { args.reduce(:/) },

      :< => -> (a, b) { a < b },
      :> => -> (a, b) { a > b },
      :'=' => -> (a, b) { a == b },
      :not => -> (a) { !a },
      :eq? => -> (a, b) { a.equal? b },

      :cons => -> (a, b) { [a, b] },
      :car => -> (l) { l.first },
      :cdr => -> (l) { l.last },
      :list => -> (*args) { args.reverse.reduce([]) {|res, e| [e, res] } },
      :null? => -> (l) { l.is_a?(Array) ? l.empty? : false },
      :pair? => -> (l) { l.is_a?(Array) ? l.any? : false },

      :display => -> (a) { print Rubic::Inspector.display(a) },
      :newline => -> () { puts },

      :true => true,
      :false => false,
      :nil => [],
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
      when Float, Integer, String
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
        _, name, expr = list
        env[name] = execute(expr, env)
        return
      when :define_proc
        _, (name, *params), *body = list
        env[name] = -> (*args) do
          local = Environment.new(env)
          local.bind(params, args)
          execute_sequence(body, local)
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
      else
        # fallthrough
      end

      # Procedure call
      op, *args = list.map {|e| execute(e, env) }
      unless op.respond_to? :call
        raise Rubic::RuntimeError, "`#{op}' is not a procedure"
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
