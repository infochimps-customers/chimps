require 'chimps/config'
require 'chimps/utils/extensions'
require 'chimps/utils/error'
require 'chimps/utils/log'

module Chimps
  module Utils
    autoload :UsesCurl,     'chimps/utils/uses_curl'
    autoload :UsesModel,    'chimps/utils/uses_model'
    autoload :UsesYamlData, 'chimps/utils/uses_yaml_data'
  end

end
