require 'configliere'

module Chimps

  Config.use :commands

  # A namespace to hold the various commands Chimps defines.
  module Commands

    def self.class_for name
      "Chimps::Commands::#{name.to_s.capitalize}".constantize
    end

    def self.included obj
      obj.extend(ClassMethods)
    end

    module ClassMethods
      # Create a new command from the given +command_name+.  The
      # resulting command will be initialized but will not have been
      # executed.
      #
      # @return [Chimps::Command]
      def command
        raise Chimps::CLIError.new("Must specify a command.  Try `chimps help'.") unless Chimps::Config.command
        Chimps::Config.command_settings.resolve!
        Chimps::Commands.class_for(Chimps::Config.command_name).new(Chimps::Config.command_settings)
      end
    end

    protected
    
    def self.define_skip_column_names command
      command.define :skip_column_names, :description => "Don't print column names in output", :flag => :s, :type => :boolean
    end

    def self.define_model command, models=%w[dataset collection source license]
      models_string = models[0..-2].map { |m| "'#{m}'" }.join(', ') + ", or '#{models.last}'"
      command.define :model, :description => "Model to search (one of #{models_string})", :flag => :m, :default => models.first, :type => String
    end

    def self.define_data_file command
      command.define :data_file, :description => "Path to a file containing YAML data.", :flag => :d
    end

    #
    # Core REST actions
    #

    Chimps::Config.define_command :list, :description => "List resources" do |command|
      define_skip_column_names(command)
      define_model(command)
      command.define :all, :description => "List all resources, not just those owned by you", :flag => :a
    end
    
    Chimps::Config.define_command :show, :description => "Show a resource in detail" do |command|
      define_model(command, %w[dataset collection source license category tag])
    end

    Chimps::Config.define_command :create, :description => "Create a new resource" do |command|
      define_model(command, %w[dataset source license])
      define_data_file(command)
    end

    Chimps::Config.define_command :update, :description => "Update an existing resource" do |command|
      define_model(command, %w[dataset source license])
      define_data_file(command)
    end

    Chimps::Config.define_command :destroy, :description => "Destroy an existing resource" do |command|
      define_model(command, %w[dataset package source license])
    end

    #
    # Workflows
    #

    Chimps::Config.define_command :download, :description => "Download a dataset" do |command|
      command.define :output, :description => "Path to output file (defaults to sensible path in current directory)", :flag => :o, :type => String
      command.define :format, :description => "Preferred data-format (csv, tsv, xls, &c.)", :flag => :f, :type => String
      command.define :pkg_fmt, :description => "Preferred package-format (zip, tar.bz2, &c.)", :flag => :p, :type => String
    end

    Chimps::Config.define_command :upload, :description => "Upload a dataset" do |command|
      command.define :archive, :description => "Path to the local archive that will be created (defaults to a sensibly named ZIP file in the current directory)", :type => String, :flag => :a
      command.define :format, :description => "Data format (tsv, csv, xls, &c.) of the uploaded data (will guess if not given)", :type => String, :flag => :f
    end

    Chimps::Config.define_command :batch, :description => "Perform a batch processing request" do |command|
      command.define :output, :description => "Path to store the server's response", :type => String, :flag => :o
      command.define :force, :description => "Force upload of data even if there were errors in the batch request.", :flag => :F
      command.define :format, :description => "Data format to annotate each upload with (will guess if not given)", :type => String, :flag => :f
      define_data_file(command)
    end

    #
    # Miscellaneous
    #

    Chimps::Config.define_help_command!

    Chimps::Config.define_command :search, :description => 'Search resources' do |command|
      define_skip_column_names(command)
      define_model(command)
    end

    Chimps::Config.define_command :query, :description => "Get a response from the Query API" do |command|
      command.define :pretty_print, :description => "Pretty-print output", :flag => :p
      define_data_file(command)
    end
    
    Chimps::Config.define_command :test, :description => "Test your authentication credentials with Infochimps"


    # A list of all the commmand names defined by Chimps.  Each name
    # maps to a corresponding subclass of Chimps::Command living in
    # the Chimps::Commands module.
    #Configliere::COMMANDS += %w[search help test create show update destroy upload list download batch query]
    
    Chimps::Config.commands.keys.each do |command|
      autoload command.to_s.capitalize.to_sym, "chimps/commands/#{command}"
    end

  end
end
