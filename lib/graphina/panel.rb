# A class that represents a panel configuration for graph visualization
#
# The Panel class encapsulates the settings and behavior for a graph display
# panel, including title, update interval, data source command, color
# configuration, and formatting options. It provides methods for initializing
# from configuration data or command-line options, and for generating the
# appropriate data value provider proc based on the configured command or
# default random data generation.
class Graphina::Panel
  # The from_opts method creates a new Panel instance configured from
  # command-line options
  #
  # This method serves as a factory constructor for Panel objects, taking a
  # hash of command-line options and using them to initialize and configure a
  # new panel instance with appropriate settings
  #
  # @param opts [ Hash ] a hash containing command-line option values
  #
  # @return [ Graphina::Panel ] a new Panel instance configured with the
  #   provided options
  def self.from_opts(opts)
    new.configure_from_opts(opts)
  end

  # The configure_from_opts method configures the panel settings based on
  # command-line options
  #
  # This method takes a hash of command-line options and uses them to set up
  # the panel's configuration values including title, update interval, data
  # source command, color settings, and formatting options
  #
  # @param opts [ Hash ] a hash containing command-line option values indexed
  #   by their short names
  #
  # @return [ Graphina::Panel ] returns the Panel instance to allow for method
  #   chaining
  def configure_from_opts(opts)
    configure(
      title:            opts[?t],
      interval:         opts[?n],
      command:          opts[?e],
      color:            opts[?c],
      color_secondary:  opts[?C],
      foreground_color: opts[?f],
      background_color: opts[?b],
      resolution:       opts[?r],
      format_value:     opts[?F]
    )
  end

  # The initialize method sets up a Panel instance with default configuration
  # values
  #
  # This method configures a new panel object with predefined default settings
  # for title, update interval, resolution mode, color scheme, and formatting
  # options before applying any custom configuration provided in the config
  # hash
  #
  # @param config [ Hash ] a hash containing panel configuration values to
  #   override defaults
  #
  # @return [ Graphina::Panel ] returns the initialized Panel instance
  def initialize(config = {})
    self.title            = 'Data'
    self.interval         = 10.0
    self.resolution       = :double
    self.foreground_color = :white
    self.background_color = :black
    self.format_value     = :as_default
    configure(config)
  end

  # The configure method sets panel attributes based on a configuration hash
  #
  # This method iterates over a configuration hash and dynamically assigns
  # values to panel attributes by calling corresponding setter methods
  #
  # @param config [ Hash ] a hash containing panel configuration values to be
  #   applied
  #
  # @return [ Graphina::Panel ] returns the Panel instance to allow for method
  #   chaining
  def configure(config)
    config.to_h.each do |name, value|
      value.nil? and next
      respond_to?("#{name}=") or raise ArgumentError, "invalid attribute #{name.inspect}"
      send("#{name}=", value)
    end
  end

  attr_accessor :title

  # The interval reader method provides access to the interval attribute that
  # was set during object initialization.
  #
  # This method returns the value of the interval instance variable, which
  # typically represents the update interval in seconds for the graph
  # visualization.
  #
  # @return [ Numeric ] the interval value stored in the instance variable
  attr_reader :interval

  # The interval= method sets the update interval for the graph visualization
  #
  # This method assigns a new value to the interval instance variable, ensuring
  # that the interval is at least 0.01 seconds to prevent excessively rapid
  # updates
  #
  # @param value [ Object ] the new interval value to be set
  #
  # @return [ Numeric ] the normalized interval value that is at least 0.01
  #   seconds
  def interval=(value)
    @interval = [ 0.01, value.to_f ].max
  end

  # The command accessor method provides read and write access to the command
  # attribute
  #
  # This method creates a public getter and setter for the command instance
  # variable which stores the external command string used to generate data
  # values for visualization
  #
  # @attr [ String, nil ] command the external command string for data generation
  attr_accessor :command

  # The color accessor method provides read and write access to the color
  # attribute
  #
  # This method creates a public getter and setter for the color instance
  # variable which stores the primary color value used for graph visualization
  #
  # @attr [ Object, nil ] color the primary color value for graph visualization
  attr_accessor :color

  # The color_secondary accessor method provides read and write access to the
  # color_secondary attribute
  #
  # This method creates a public getter and setter for the color_secondary
  # instance variable which stores the secondary color value used for enhanced
  # visual effects
  # in graph visualization
  #
  # @attr [ Object, nil ] color_secondary the secondary color value for graph
  #   visualization
  attr_accessor :color_secondary

  # The foreground_color accessor method provides read and write access to the
  # foreground_color attribute
  #
  # This method creates a public getter and setter for the foreground_color
  # instance variable which stores the text color value used for graph
  # visualization
  #
  # @attr [ Symbol ] foreground_color the text color value for graph
  #   visualization
  attr_accessor :foreground_color

  # The background_color accessor method provides read and write access to the
  # background_color attribute
  #
  # This method creates a public getter and setter for the background_color
  # instance variable which stores the background color value used for graph
  # visualization
  #
  # @attr [ Symbol ] background_color the background color value for graph
  #   visualization
  attr_accessor :background_color

  # The resolution accessor method provides read and write access to the
  # resolution attribute
  #
  # This method creates a public getter and setter for the resolution instance
  # variable which stores the display resolution mode for the graph
  # visualization
  #
  # @attr [ Symbol ] resolution the display resolution mode (:single or
  #   :double) for graph visualization
  attr_accessor :resolution

  # The format_value accessor method provides read and write access to the
  # format_value attribute
  #
  # This method creates a public getter and setter for the format_value
  # instance variable which stores the formatting strategy used for displaying
  # data values
  #
  # @attr [ Symbol, Proc, nil ] format_value the formatting strategy for
  #   displaying data values
  attr_accessor :format_value

  # The value method returns a proc that generates data values for graph
  # display
  #
  # This method creates and returns a proc object that serves as the data
  # source for the graph visualization. When the graph needs a new data point,
  # it invokes this proc with an index parameter. The proc either executes a
  # configured external command and converts its output to a float, or
  # generates a random float value between 0 and 100 if no command is specified
  #
  # @return [ Proc ] a proc that takes an index parameter and returns a numeric
  #   value for graph plotting
  def value
    if @command
      -> i { `#@command`.to_f }
    else
      -> i { rand(100).to_f }
    end
  end
end

require 'graphina/panel/chooser'
