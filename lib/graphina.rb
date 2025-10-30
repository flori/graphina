require 'tins'

# Graphina module
#
# The Graphina module serves as the root namespace for the Graphina gem, which
# provides terminal-based data visualization capabilities. It contains the core
# classes and modules responsible for creating real-time graphical displays
# using Unicode characters and ANSI styling in terminal environments.
#
# The module organizes the various components of the gem including graph visualization
# classes, panel configurations, display management, and formatting utilities into
# a coherent namespace structure for easy access and usage.
module Graphina
end
require 'graphina/version'
require 'graphina/graphina_config'
require 'graphina/panel'
require 'graphina/graph'
