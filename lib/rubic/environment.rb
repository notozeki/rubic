module Rubic
  class RubicRuntimeError < StandardError; end

  class Environment
    def initialize(outer=nil)
      @outer = outer
      @table = {}
    end

    def defvar(name, value)
      @table[name] = value
    end

    def refvar(name)
      if @table.key? name
        @table[name]
      elsif @outer
        @outer.refvar(name)
      else
        raise RubicRuntimeError, "undefined variable `#{name}'"
      end
    end

    def bind(params, args)
      if params.size != args.size
        raise RubicRuntimeError, "wrong number of arguments (#{args.size} for #{params.size})"
      end

      params.each.with_index do |name, i|
        @table[name] = args[i]
      end
    end

    alias []= defvar
    alias [] refvar
  end
end
