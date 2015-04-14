module Rubic
  module Inspector
    refine Array do
      def inspect
        "(#{inspect_rec})"
      end

      def inspect_rec
        if empty?
          ''
        elsif last.is_a?(Array)
          [first.inspect, last.inspect_rec].join(' ').strip
        else
          "#{first.inspect} . #{last.inspect}"
        end
      end
    end

    refine Proc do
      def inspect
        "#<lambda:#{object_id}>"
      end
    end
  end
end
