module Chimps
  module Utils
    module UsesModel

      def model
        config[:model]
      end

      def plural_model
        if model[-1].chr == 'y'
          model[1..-1] + 'ies'
        else
          model + 's'
        end
      end

      def model_identifier
        raise CLIError.new("Must provide an ID or URL-escaped handle as the first argument") if config.argv.first.blank?
        config.argv.first
      end

      def models_path
        "#{plural_model}.json"
      end

      def model_path
        "#{plural_model}/#{model_identifier}.json"
      end
      
    end
  end
end

    
