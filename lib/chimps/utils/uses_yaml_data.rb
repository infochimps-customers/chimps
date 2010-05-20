module Chimps
  module Utils
    module UsesYamlData

      attr_reader :data_file

      def data
        @data ||= merge_all *(data_from_stdin + data_from_file + data_from_command_line)
      end
      
      protected

      def merge_all *objs
        objs.compact!
        return if objs.blank?   # raising an error here is left to the caller
        klasses = objs.map(&:class).uniq
        raise CLIError.new("Mismatched YAML data types -- Hashes can only be combined with Hashes, Arrays with Arrays") if klasses.size > 1
        data_type = klasses.first.new
        case data_type
        when Array
          # greater precedence at the end so iterate in order
          returning([]) do |d|
            objs.each do |obj|
              d.concat(obj)
            end
          end
        when Hash
          # greater precedence at the end so iterate in order
          returning({}) do |d|
            objs.each do |obj|
              d.merge!(obj)
            end
          end
        else raise CLIERror.new("Unsuitable YAML data type #{data_type} -- can only combine Hashes and Arrays")
        end
      end
      
      def data_from_command_line
        returning([]) do |d|
          argv.each do |arg|
            if arg =~ /^(\w+) *=(.*)$/
              name, value = $1.downcase.to_sym, $2.strip
              d << { name => value } # always a hash
            else
              path = File.expand_path(arg)
              raise CLIError.new("No such path #{path}") unless File.exist?(path)
              d << YAML.load(open(path)) # either a hash or an array
            end
          end
        end
      end

      def data_from_file
        [data_file ? YAML.load_file(data_file) : nil]
      end

      def data_from_stdin
        return [nil] unless $stdin.stat.size > 0
        returning([]) do |d|
          YAML.load_stream($stdin).each do |document|
            d << document
          end
        end
      end

      def define_data_options
        on_tail("-d", "--data-file PATH", "Path to a file containing key=value data") do |p|
          @data_file = File.expand_path(p)
        end
      end

      def ensure_data_is_present!
        raise CLIError.new("Must provide some data to send, either on the command line, from an input file, or by piping to STDIN.  Try `chimps help #{name}'") unless data.present?
      end
      
    end
  end
end
