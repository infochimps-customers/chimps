module Chimps
  module Utils
    module UsesModel

      def model
        @model ||= self.class::MODELS.first
      end

      def plural_model
        if model[-1].chr == 'y'
          model[1..-1] + 'ies'
        else
          model + 's'
        end
      end

      def model_identifier
        raise CLIError.new("Must provide an ID or URL-escaped handle as the first argument") if argv.first.blank?
        argv.first
      end

      def models_path
        "#{plural_model}.json"
      end

      def model_path
        "#{plural_model}/#{model_identifier}.json"
      end
      
      def model= model
        raise CLIError.new("Invalid model: #{model}.  Must be one of #{models_string}") unless self.class::MODELS.include?(model)
        @model = model
      end

      def models_string
        returning(self.class::MODELS.dup) do |parts|
          parts[0]   = "#{parts.first} (default)"
          parts[-1]  = "or #{parts.last}"
        end.join(', ')
      end

      def define_model_option
        on_tail("-m", "--model MODEL", "Use a different resource, one of: #{models_string}") do |m|
          self.model= m
        end
      end
    end
  end
end

    
