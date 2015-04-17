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

      def to_s
        "(#{to_s_rec})"
      end

      def to_s_rec
        if empty?
          ''
        elsif last.is_a?(Array)
          [first.to_s, last.to_s_rec].join(' ').strip
        else
          "#{first.to_s} . #{last.to_s}"
        end
      end
    end

    refine Proc do
      def inspect
        "#<lambda:#{object_id}>"
      end

      def to_s
        "#<lambda:#{object_id}>"
      end
    end

    refine Symbol do
      def inspect
        to_s
      end
    end
  end
end
