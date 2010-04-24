# this whole file is a waste of time.  i wish the yaml api worked.

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
            $stderr.puts data.inspect if ICS.verbose?
          end
        end
      end
    end
    
    protected

    #
    # Each of the following methods must return an Array of Strings
    #

    def pretty_print_batch data, options={}
      output = []
      data.each do |response|
        status = response['status']
        if response['resource']
          resource_type = response['resource'].keys.first
          resource_id   = response['resource'][resource_type]['id']
          output << [status, resource_type, resource_id].map(&:to_s).join("\t")
        end
        if response['errors']
          output.concat(pretty_print_errors(response['errors']))
        end
        if response['debug']
          output << [response['debug']['type'], response['debug']['message']].map(&:to_s).join("\t")
          output.concat(response['debug']['backtrace'])
        end
      end
      output
    end

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
          lines << "DATASET #{data['id']}"
          lines << "  TITLE:        #{data['title']}"
          lines << "  SUBTITLE:     #{data['subtitle']}"            unless data['subtitle'].blank?
          lines << "  TAGS:         #{data['tag_list'].join(', ')}" unless data['tag_list'].blank?
          lines << "  LAST UPDATED: #{data['updated_at']}"
          lines << "  PROTECTED:    #{!!data['protected']}"
          lines << "  OWNER:        #{data['owner_id']}"
          lines << '' unless data['notes'].blank?
          data['notes'].each do |note|
            lines << "  #{note['title'].upcase}:"
            lines.concat(word_wrap(note['body'], :indent => 4))
          end

          data['packages'].each_with_index do |package, index|
            lines.concat(pretty_print_package(package, options.merge(:indent => 2)))
            lines << '' unless (index + 1) == data['packages'].length
          end

          # FIXME add categories, sources, fields, snippet, &c...

        end
      end

    end

    def pretty_print_package data, options={}
      spacer = options[:indent] ? ' ' * options[:indent] : ''
      returning([]) do |lines|
        lines << "#{spacer}PACKAGE #{data['id']}"
        lines << "#{spacer}  FILENAME:     #{data['basename']}"
        lines << "#{spacer}  FORMAT:       #{data['fmt']}"
        lines << "#{spacer}  ARCHIVE TYPE: #{data['pkg_fmt']}"
        lines << "#{spacer}  SIZE:         #{data['pkg_size']}"
        lines << "#{spacer}  NUM FILES:    #{data['num_files']}"   unless data['num_files'].blank?
        lines << "#{spacer}  RECORDS:      #{data['num_records']}" unless data['num_records'].blank?
      end
    end

    def word_wrap string, options={}
      options[:columns] = 80 unless options[:columns]
      spacer  = options[:indent] ? ' ' * options[:indent] : ''
      # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/10655
      string.gsub(/\t/,"     ").gsub(/.{1,#{options[:columns]}}(?:\s|\Z)/){($& + 5.chr).gsub(/\n\005/,"\n").gsub(/\005/,"\n")}.split("\n").map { |line| spacer + line }
    end
  end
  
end
  
