module Chimps
  module Utils
    module UsesYamlData

      def ignore_yaml_files_on_command_line
        false
      end
      def ignore_first_arg_on_command_line
        false
      end

      def data
        @data ||= merge_all(*(data_from_stdin + data_from_file + data_from_command_line)) || {}
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
        else raise CLIError.new("Incompatible YAML data type #{data_type} -- can only combine Hashes and Arrays")
        end
      end

      def params_from_command_line
        returning([]) do |d|
          config.argv.each_with_index do |arg, index|
            next if index == 0 && ignore_first_arg_on_command_line
            next unless arg =~ /^(\w+) *=(.*)$/
            name, value = $1.downcase.to_sym, $2.strip
            d << { name => value } # always a hash
          end
        end
      end
            
      def yaml_files_from_command_line
        returning([]) do |d|
          config.argv.each_with_index do |arg, index|
            next if index == 0 && ignore_first_arg_on_command_line            
            next if arg =~ /^(\w+) *=(.*)$/
            path = File.expand_path(arg)
            raise CLIError.new("No such path #{path}") unless File.exist?(path)
            d << YAML.load(open(path)) # either a hash or an array
          end
        end
      end
      
      def data_from_command_line
        if ignore_yaml_files_on_command_line
          params_from_command_line
        else
          yaml_files_from_command_line + params_from_command_line
        end
      end

      def data_from_file
        [config[:data_file] ? YAML.load_file(File.expand_path(config[:data_file])) : nil]
      end

      def data_from_stdin
        return [nil] unless $stdin.stat.size > 0
        returning([]) do |d|
          YAML.load_stream($stdin).each do |document|
            d << document
          end
        end
      end

      def ensure_data_is_present!
        raise CLIError.new("Must provide some data to send, either on the command line, from an input file, or by piping to STDIN.  Try `chimps help #{name}'") unless data.present?
      end
      
    end
  end
end
