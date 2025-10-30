require 'const_conf'

# A module that provides configuration management for Graphina
#
# The GraphinaConfig module handles the setup and retrieval of configuration
# values for the Graphina application. It uses the ConstConf library to define
# and manage constants with default values, decoding mechanisms, and environment
# variable support. The module specifically manages paths for configuration
# directories and panel configurations using XDG Base Directory specifications
# for proper cross-platform configuration handling
#
# @example
#   Graphina::GraphinaConfig::CONFIG_DIR
#   # => Pathname object pointing to the Graphina config directory
module Graphina::GraphinaConfig
  include ConstConf

  plugin ConstConf::YAMLPlugin

  description 'Graphina configuration module'
  prefix      'GRAPHINA'

  XDG_CONFIG_HOME = set do
    description 'XDG Configuration directory path'
    prefix ''
    default { '~/.config' }
    decode  { Pathname.new(_1) }
  end

  CONFIG_DIR = set do
    description 'Graphina config directory'
    decode { XDG_CONFIG_HOME + 'graphina' }
  end

  PANELS_PATH = set do
    description 'Panels configuration file path'

    default CONFIG_DIR + 'panels.yml'
  end

  PANELS = set do
    description 'Panels configuration file'
    default yaml(PANELS_PATH)
  end
end
