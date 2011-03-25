module Chimps

  module Utils

    # There are two Chimpanzees using a typewriter.  One of them presses
    # most of the keys and writes to $stdout.  The other only hits the
    # spacebar and writes to $stderr.  He's crazy.
    #
    # These two Chimps together manage to line everything up just right.
    class Typewriter < Array

      # The response that this Typewriter will print.
      attr_accessor :response
      
      # Widths of columns as determined by the maximum number of
      # characters in any row.
      attr_accessor :column_widths

      # Separates rows.
      attr_accessor :row_separator
      
      # Separates columns.
      attr_accessor :column_separator

      # Default row separator
      ROW_SEPARATOR = "\n"

      # Default columnn separator
      COLUMN_SEPARATOR = "\t"

      # FIXME
      def spacer
        2
      end

      # Return a Typewriter to print +response+.
      #
      # @param [Chimps::Response] response
      # @return [Chimps::Typewriter]
      def initialize response, options={}
        super()
        @response             = response
        @column_widths        = {}
        self.row_separator    = (options[:row_separator]    || ROW_SEPARATOR)
        self.column_separator = (options[:column_separator] || COLUMN_SEPARATOR)
        accumulate(response)
      end

      # Print the accumulated lines in this Typewriter.
      #
      # Will first calculate appropriate column widths for each line and
      # then pad with spaces each entry so that the columns line up.
      #
      # The spaces are written to $stderr and the rest of the characters
      # to $stdout.  This lets you pipe output from a Typewriter into
      # other processes and preserve the TSV structure.
      def print
        $stdout.sync = true ; $stderr.sync = true
        each do |row|
          row.each_with_index do |entry, field|
            $stdout.write entry
            max_width = column_widths[field] + spacer
            unless entry.size >= max_width
              num_spaces = max_width - entry.size
              pad = " " * num_spaces
              $stderr.write(pad)
            end
          end
          $stdout.write "\n"
        end
      end

      # Accumulate lines to print from +string+.
      #
      # Updates internal width counters as it accumulates
      # 
      # @param [Array, Hash, String] obj
      def accumulate response
        response.body.strip.split(row_separator).each do |line|
          self << [].tap do |row|
            line.split(column_separator).each_with_index do |entry, field|
              column_widths[field] = entry.size if entry.size > (column_widths[field] || 0)
              row << entry
            end
          end
        end
      end
    end
  end
end
