require 'rubic/inspector'

module Rubic
  module Builtin
    class Output
      using Rubic::Inspector

      def display(a)
        print a
      end

      def newline
        puts
      end
    end
  end
end
