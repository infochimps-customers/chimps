module Chimps
  module Commands
    module UsesKeyValueData

      attr_reader :data_file

      def data
        data_from_stdin.merge(data_from_file.merge(data_from_command_line))
      end
      
      protected
      def data_from_command_line
        returning({}) do |p|
          argv.each do |arg|
            next unless arg =~ /^(\w+) *=(.*)$/
            name, value = $1.downcase.to_sym, $2.strip
            p[name] = value
          end
        end
      end

      def data_from_file
        data_file ? YAML.load_file(data_file) : {}
      end

      def data_from_stdin
        return {} unless $stdin.stat.size > 0
        returning({}) do |documents_data|
          YAML.load_stream($stdin).each do |document|
            documents_data.merge!(document)
          end
        end
      end

      def define_data_options
        on_tail("-d", "--data-file PATH", "Path to a file containing key=value data") do |p|
          @data_file = File.expand_path(p)
        end
      end
      
    end
  end
end
