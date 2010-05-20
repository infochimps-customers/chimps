require 'chimps/config'
require 'chimps/utils/extensions'
require 'chimps/utils/error'

module Chimps
  module Utils
    autoload :UsesCurl,         'chimps/utils/uses_curl'
    autoload :UsesModel,        'chimps/utils/uses_model'
    autoload :UsesKeyValueData, 'chimps/utils/uses_key_value_data'
  end
end


def puts_and_again opening, closing, options={}, &block
  options[:if] = true unless options.has_key?(:if)
  begin
    if options[:if]
      $stdout.write(opening)
      $stdout.flush
    end
    yield
  ensure
    if options[:if]
      $stdout.write("#{closing}\n")
      $stdout.flush
    end
  end
end


