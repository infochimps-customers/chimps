module Chimps

  # Responses from Infochimps (once parsed from the original JSON or
  # YAML) consist of nested hashes:
  #
  #   { 'dataset' => {
  #                    'title'       => 'My dataset',
  #                    'description' => 'An amazing dataset which...',
  #                    ...
  #                    'sources' => {
  #                                  'source' => {
  #                                                'title' => 'Trustworthy Source'
  #                                                ...
  #                                              },
  #                                  'source' => {..},
  #                                  ...
  #                                  }
  #                   },
  #     ...
  #   }
  #
  # This class utilizes a typewriter and a team of trained chimpanizes
  # to create pretty, line-oriented output from these hashes.
  class Typewriter < Array

    # The response that this Typewriter will print.
    attr_accessor :response
    
    # Widths of columns as determined by the maximum number of
    # characters in any row.
    attr_accessor :column_widths

    # Fields to print for each resource.  Given as humanized names,
    # will be automatically converted to key names.
    RESOURCE_FIELDS = ["ID", "Cached Slug", "Updated At", "Title"]

    # String to insert between fields in output.
    FIELD_SEPARATOR = "    "

    # Return a Typewriter to print +data+.
    #
    # @param [Chimps::Response] response
    # @return [Chimps::Typewriter]
    def initialize response, options={}
      super()
      @response          = response
      @column_widths     = []
      @skip_column_names = options[:skip_column_names]
      accumulate(response)
    end

    # Print column names as well as values?
    #
    # @return [true, nil]
    def skip_column_names?
      @skip_column_names
    end

    # Print the accumulated lines in this Typewriter.
    #
    # Will first calculate appropriate column widths for any
    # Array-like lines.
    def print
      calculate_column_widths!
      each do |line|
        if line.is_a?(Array)
          puts pad_and_join(line)
        else
          puts line
        end
      end
    end

    # Accumulate lines to print from +obj+.
    #
    # If +obj+ is a string then it will be accumulated as a single
    # line to print.
    #
    # If +obj+ is an Array then each element will be passed to
    # Chimps::Typewriter#accumulate.
    #
    # If +obj+ is a Hash then each key will be mapped to a method
    # <tt>accumulate_KEY</tt> and the corresponding value passed in.
    # This method is responsible for accumulating lines to print.
    #
    # @param [Array, Hash, String] obj
    def accumulate obj
      case obj
      when Hash
        obj.each_pair do |resource_name, resource_data|
          case 
          when %w[datasets sources licenses].include?(resource_name.to_s)
            accumulate_listing(resource_data)
          when %w[dataset source license].include?(resource_name.to_s)
            accumulate_resource(resource_name, resource_data)
          when %w[errors batch search api_account].include?(resource_name.to_s)
            send("accumulate_#{resource_name}", resource_data)
          when :array  == resource_name         # constructed by Chimps::Response
            accumulate_listing(resource_data)
          when :string == resource_name         # constructed by Chimps::Response 
            self << obj[:string]
          else
            $stderr.puts resource_data.inspect if Chimps.verbose?
            raise PrintingError.new("Unrecognized resource type `#{resource_name}'.")
          end
        end
      when Array
        obj.each { |element| accumulate(element) }
      when String
        self << obj
      else 
        raise PrintingError.new("Cannot print a #{obj.class}")
      end
    end

    protected

    # Loop through the accumulated lines, finding the maximum widths
    # of each element in each Array-like line.
    def calculate_column_widths!
      each do |line|
        next unless line.is_a?(Array) # don't try to align strings
        line.each_with_index do |value, field|
          current_max_width = column_widths[field]
          unless current_max_width
            current_max_width = 0
            column_widths << current_max_width
          end
          value_size = value.to_s.size
          column_widths[field] = value_size if value_size > current_max_width
        end
      end
    end

    # Return a string with +values+ joined by FIELD_SEPARATOR each
    # padded to the corresponding maximum column size.
    #
    # Must have called Chimps::Typewriter#calculate_column_widths!
    # first.
    #
    # @param [Array] values
    # @return [String]
    def pad_and_join values
      returning([]) do |padded_values|
        values.each_with_index do |value, field|
          max_width    = column_widths[field]
          value_width  = value.to_s.size
          padded_values << value.to_s + (' ' * (max_width - value_width))
        end
      end.join(FIELD_SEPARATOR)
    end

    # Accumulate lines for the given +resource_name+ from the given
    # +resource_data+.
    #
    # Fields to accumulate in each line are set in
    # Chimps::Typewriter::RESOURCE_FIELDS.
    #
    # The structure of the response for a resource looks like:
    #
    #   {
    #     'dataset' => {
    #                    'id'    => 39293,
    #                    'title' => 'My Awesome Dataset',
    #                    ...
    #                  }
    #   }
    #
    # The key is +resource_name+ and the value is +resource_data+.
    #
    # @param [String] resource_name
    # @param [Hash] resource_data
    def accumulate_resource resource_name, resource_data
      self << self.class::RESOURCE_FIELDS.map { |field_name| resource_data[field_name.downcase.tr(' ', '_')] }
    end

    # Accumulate lines for each of the +resources+, all of the given
    # +type+.
    #
    # The structure of the response for a listing looks like:
    #
    #   {
    #     'datasets' => [
    #                     {
    #                       'dataset' => {
    #                                    'id'    => 39293,
    #                                    'title' => 'My Awesome Dataset',
    #                                    ...
    #                                    },
    #                     },
    #                     {
    #                       'dataset' => {
    #                                    'id'    => 28998,
    #                                    'title' => 'My Other Awesome Dataset',
    #                                    ...
    #                                    },
    #                     },
    #                     ...
    #                   ]
    #   }
    #
    # The value is +resources+.
    #
    # @param [Array<Hash>] resources
    def accumulate_listing resources
      return if resources.blank?
      self << self.class::RESOURCE_FIELDS unless skip_column_names?
      resources.each { |resource| accumulate(resource) }
    end

    # Accumulate lines for each of the error messages in +errors+.
    #
    # The structure of the response looks like
    #
    #   {
    #     'errors' => [
    #                   "A title is required.",
    #                   "A description is required.",
    #                   ...
    #                 ]
    #   }
    #
    # The value is +errors+.
    #
    # @param [Array] errors
    def accumulate_errors errors
      errors.each do |error|
        self << error
      end
    end

    # Accumulate lines for each of the batch responses in +batch+.
    #
    # The structure of the response looks like
    #
    #   {
    #     'batch' => [
    #                  {
    #                    'status'   => 'created',
    #                    'resource' => {
    #                                   'dataset' => {
    #                                                  'id'    => 39293,
    #                                                  'title' => "My Awesome Dataset",
    #                                                  ...
    #                                                },
    #                                 },
    #                    'errors' => nil,
    #                    'local_paths' => [...] # this is totally optional
    #                  },
    #                  {
    #                    'status'  => 'invalid',
    #                    'errors' => [
    #                                  "A title is required.",
    #                                  "A description is required."
    #                                ]
    #                  },
    #                  ...
    #                ]
    #   }
    #
    # The value is +batch+.
    def accumulate_batch batch
      self << ["Status", "Resource", "ID", "Errors"] unless skip_column_names?
      batch.each do |response|
        status = response['status']
        errors = response['errors']
        if response['resource'] && errors.blank?
          resource_type = response['resource'].keys.first
          resource      = response['resource'][resource_type]
          id            = resource['id']
          self << [status, resource_type, id]
        else
          self << ([status, nil, nil] + errors)
        end
      end
    end

    # Accumulate lines for the results in +search+.
    #
    # The structure of the response looks like
    #
    #   {
    #     'search' => {
    #                   'results' => [
    #                                  { 'dataset' => {...} },
    #                                  { 'dataset' => {...} },
    #                                  ...
    #                                ]
    #                                
    #                 }
    #   }
    #
    # The value keyed to +search+ is +search+.
    def accumulate_search search
      return if search['results'].blank?
      self << self.class::RESOURCE_FIELDS unless skip_column_names?
      search['results'].each { |resource| accumulate(resource) }
    end

    # Accumulate lines for the +api_account+.
    #
    # The structure of the response looks like
    #
    #   { 'api_account' => {
    #                        'api_key' => ...,
    #                        'owner'   => {
    #                                       'username' => 'Infochimps',
    #                                       ...
    #                                     },
    #                        'updated_at' => ...,
    #                        ...
    #                      }
    #   }
    #
    # The value is +api_account+
    def accumulate_api_account api_account
      # FIXME this is sort of ugly...
      self << "USERNAME:     #{api_account['owner']['username']}"
      self << "API KEY:      #{api_account['api_key']}"
      self << "LAST UPDATED: #{api_account['updated_at']}"
    end
    
  end
  
end
  
