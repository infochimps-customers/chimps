module ICS

  module PrettyPrinters

    # Returns an array of strings
    def pretty_print hash, options={}
      returning([]) do |lines|
        hash.each_pair do |object_name, data|
          method = "pretty_print_#{object_name.to_s}"
          if respond_to?(method)
            lines.concat(send(method, data, options))
          else
            $stderr.puts("WARNING: Unknown object #{object_name} in server response")
          end
        end
      end
    end
    
    protected

    #
    # Each of the following methods must return an Array of Strings
    #

    def pretty_print_list data, options={}
      data.map do |hash|
        pretty_print hash, options.merge(:single_line => true)
      end
    end

    def pretty_print_string data, options={}
      [data]
    end

    def pretty_print_errors data, options={}
      data.map { |error_message| "  #{error_message}" }
    end

    def pretty_print_search data, options={}
      data['results'].map do |result|
        pretty_print(result, :single_line => true)
      end
    end

    def pretty_print_api_account data, options={}
      returning([]) do |lines|
        lines << "USERNAME:     #{data['owner']['username']}"
        lines << "API KEY:      #{data['api_key']}"
        lines << "LAST UPDATED: #{data['updated_at']}"
      end
    end

    def pretty_print_dataset data, options={}
      if options[:single_line]
        [[data['id'], data['updated_at'], data['main_link'], data['title']].join("\t")]
      else
        returning([]) do |lines|
          lines << "ID:           #{data['id']}"
          lines << "TITLE:        #{data['title']}"
          lines << "SUBTITLE:     #{data['subtitle']}"            unless data['subtitle'].blank?
          lines << "TAGS:         #{data['tag_list'].join(', ')}" unless data['tag_list'].blank?
          lines << "LAST UPDATED: #{data['updated_at']}"
          lines << "PROTECTED:    #{!!data['protected']}"
          lines << "OWNER:        #{data['owner_id']}"
          lines << '' unless data['notes'].blank?
          data['notes'].each do |note|
            lines << "#{note['title'].upcase}:"
            lines << "#{note['body']}"
          end

          # FIXME add categories, sources, fields, snippet, &c...

        end
      end

    end

  end
end
  
