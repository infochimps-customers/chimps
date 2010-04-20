module ICS

  module Commands

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
          model = m
        end
      end
    end
  end
end

    
