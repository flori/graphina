require 'term/ansicolor'
require 'tins'
require 'digest/md5'

require 'graphina/graph/formatters.rb'

# A class that provides graphical display functionality for terminal-based data
# visualization
#
# The Graph class enables the creation of dynamic, real-time visualizations of
# data values within a terminal environment. It manages the rendering of
# graphical representations such as line charts or graphs, updating them
# continuously based on provided data sources. The class handles terminal
# control operations, including cursor positioning, color management, and
# screen clearing to ensure smooth visual updates. It also supports
# configuration of display parameters like title, formatting strategies for
# values, update intervals, and color schemes for different data series.
#
# @example
#   graph = Graphina::Graph.new(
#     title: 'CPU Usage',
#     value: ->(i) { rand(100) },
#     format_value: :as_percent,
#     sleep: 1,
#     color: 33
#   )
#   graph.start
#   # Starts the graphical display loop
#
# @example
#   graph = Graphina::Graph.new(
#     title: 'Memory Usage',
#     value: ->(i) { `vm_stat`.match(/Pages free: (\d+)/)[1].to_i },
#     format_value: :as_bytes,
#     sleep: 2
#   )
#   graph.start
#   # Starts a memory usage graph with custom data source and formatting
class Graphina::Graph
  include Term::ANSIColor
  include Graphina::Graph::Formatters

  # The initialize method sets up a Graph instance by configuring its display parameters and internal state.
  #
  # This method configures the graph visualization with title, value provider,
  # formatting options, update interval, and color settings. It initializes
  # internal data structures for storing historical values and manages
  # synchronization through a mutex for thread-safe operations.
  #
  # @param title [ String ] the title to display at the bottom of the graph
  # @param value [ Proc ] a proc that takes an index and returns a numeric
  #   value for plotting
  # @param format_value [ Proc, Symbol, nil ] formatting strategy for
  #   displaying values
  # @param sleep [ Numeric ] time in seconds between updates
  # @param color [ Object, Proc, nil ] color or proc or nil. nil
  #   determineicolor dynamically from the title
  # @param color_secondary [ Object, nil ] secondary color or nil
  #   for enhanced visuals, nil derives secondary color from (primary) color
  # @param adjust_brightness [ Symbol ] the method to call on the color for
  #   brightness adjustment (:lighten or :darken), defaults to :lighten
  # @param adjust_brightness_percentage [ Float ] the percentage value to use
  #   for the brightness adjustment
  # @param foreground_color [ Symbol ] the default text color for the display
  # @param background_color [ Symbol ] the default background color for the
  #   display
  # @param resolution [ Symbol ] the resolution mode (:single or :double) for
  #   the graph display, defaults to :double.
  #
  # @raise [ ArgumentError ] if the sleep parameter is negative
  # @raise [ TypeError ] if the sleep parameter is not numeric
  # @raise [ ArgumentError ] if the resolution parameter is not :single or :double
  def initialize(
    title:,
    value:                        -> i { 0 },
    format_value:                 nil,
    sleep:                        5,
    true_coloring:                true,
    color:                        nil,
    color_secondary:              nil,
    adjust_brightness:            :lighten,
    adjust_brightness_percentage: 15,
    foreground_color:             :white,
    background_color:             :black,
    resolution:                   :double
  )
    @title                        = title
    @value                        = value
    @format_value                 = format_value
    sleep = Float(sleep)
    sleep >= 0 or raise ArgumentError, 'sleep has to be >= 0'
    @sleep                        = sleep
    @continue                     = false
    @data                         = []
    @color                        = color
    @color_secondary              = color_secondary
    adjust_brightness             = adjust_brightness.to_sym
    if %i[ lighten darken ].include? adjust_brightness
      @adjust_brightness          = adjust_brightness
    else
      raise ArgumentError, 'adjust_brightness required to be either :lighten or :darken'
    end
    @adjust_brightness_percentage = Float(adjust_brightness_percentage)
    @foreground_color             = foreground_color
    @background_color             = background_color
    resolution                    = resolution.to_sym
    if %i[ single double ].include? resolution
      @resolution                 = resolution
    else
      raise ArgumentError, 'resolution required to be either :single or :double'
    end
    Term::ANSIColor.true_coloring = true_coloring
    @mutex                        = Mutex.new
  end

  # The start method initiates the graphical display process by setting up
  # signal handlers, performing an initial terminal reset, and entering the
  # main update loop
  #
  # This method serves as the entry point for starting the graph visualization
  # functionality. It configures the necessary signal handlers for graceful
  # shutdown and terminal resizing, performs an initial full reset of the
  # display state, and then begins the continuous loop that updates and renders
  # graphical data.
  def start
    install_handlers
    full_reset
    start_loop
  end

  # The stop method terminates the graphical display process by performing a
  # full reset and setting the continue flag to false
  #
  # This method serves as the shutdown mechanism for the graph visualization
  # functionality. It ensures that all display resources are properly cleaned
  # up and the terminal state is restored to its original condition before
  # stopping the continuous update loop.
  def stop
    full_reset
    @continue = false
  end

  private

  # Draws the graphical representation of the data on the display.
  #
  # This method renders the data as a graph using Unicode block characters (▀)
  # to achieve 2px vertical resolution in terminal graphics. Each data point is
  # plotted with appropriate color blending for visual appeal.
  def draw_graph
    y_width         = data_range
    color           = pick_color
    color_secondary = pick_secondary_color(
      color,
      adjust_brightness:            @adjust_brightness,
      adjust_brightness_percentage: @adjust_brightness_percentage
    )
    data.each_with_index do |value, i|
      x  = 1 + i + columns - data.size
      y0 = ((value - data.min) * lines / y_width.to_f)
      y  = lines - y0.round + 1
      y.upto(lines) do |iy|
        if iy > y
          @display.at(iy, x).on_color(color_secondary).write(' ')
        else
          case @resolution
          when :double
            fract = 1 - (y0 - y0.floor).abs
            case
            when (0...0.5) === fract
              @display.at(iy, x).on_color(@background_color).color(color).write(?▄)
            else
              @display.at(iy, x).on_color(color).color(color_secondary).write(?▄)
            end
          else
            @display.at(iy, x).on_color(color).color(color_secondary).write(' ')
          end
        end
      end
    end
  end

  # The data_range method calculates the range of data values by computing the
  # difference between the maximum and minimum values in the data set and
  # converting the result to a float
  #
  # @return [ Float ] the calculated range of the data values as a float
  def data_range
    (data.max - data.min).abs.to_f
  end

  # The start_loop method executes a continuous loop to update and display
  # graphical data
  #
  # This method manages the main execution loop for rendering graphical
  # representations of data values over time. It initializes display state,
  # processes incoming data, calculates visual representations, and handles
  # terminal updates while respecting configured timing intervals.
  #
  # It continuously updates the display and handles data processing in a loop
  # until explicitly stopped.
  def start_loop
    full_reset
    @counter    = -1
    @continue = true
    while @continue
      @start = Time.now
      @full_reset and full_reset
      perform hide_cursor

      @data << @value.(@counter += 1)
      @data = data.last(columns)

      if data_range.zero?
        @display.reset.bottom.styled(:bold).
          write_centered("#@title / #{sleep_duration}").
          reset.centered.styled(:italic).write_centered("no data")
        perform_display_diff
        sleep_now
        next
      end

      @display.reset
      draw_graph

      @display.reset.bottom.styled(:bold).
        write_centered("#@title #{format_value(data.last)} / #{sleep_duration}")
      @display.reset.styled(:bold).
        left.top.write(format_value(data.max)).
        left.bottom.write(format_value(data.min))

      perform_display_diff
      sleep_now
    end
  rescue Interrupt
  ensure
    stop
  end

  def perform(*a)
    print(*a)
  end

  # The columns method returns the number of columns in the display
  #
  # This method provides access to the horizontal dimension of the graphical
  # display by returning the total number of columns available for rendering
  # content
  #
  # @return [ Integer ] the number of columns (characters per line) in the display object
  def columns
    @display.columns
  end

  # The lines method returns the number of lines in the display
  #
  # This method provides access to the vertical dimension of the graphical
  # display by returning the total number of rows available for rendering
  # content
  #
  # @return [ Integer ] the number of lines (rows) in the display object
  def lines
    @display.lines
  end

  # The data reader method provides access to the data attribute that was set
  # during object initialization.
  #
  # This method returns the value of the data instance variable, which
  # typically contains structured information that has been processed or
  # collected by the object.
  #
  # @return [ Array<Object>, Hash, nil ] the data value stored in the instance variable, or nil if not set
  attr_reader :data

  # The sleep_duration method returns a string representation of the configured
  # sleep interval with the 's' suffix appended to indicate seconds.
  #
  # @return [ String ] a formatted string containing the sleep duration in seconds
  def sleep_duration
    "#{@sleep}s"
  end

  # The format_value method processes a given value using the configured
  # formatting strategy
  #
  # This method applies the appropriate formatting to a value based on the
  # \@format_value instance variable configuration It supports different
  # formatting approaches including custom Proc objects, String- or
  # Symbol-based method calls, and default formatting
  #
  # @param value [ Object ] the value to be formatted according to the configured strategy
  #
  # @return [ String ] the formatted string representation of the input value
  def format_value(value)
    case @format_value
    when Proc
      @format_value.(value)
    when Symbol, String
      send(@format_value, value)
    else
      send(:as_default, value)
    end
  end

  # The pick_color method determines and returns an ANSI color attribute based
  # on the configured color setting
  #
  # This method evaluates the @color instance variable to decide how to select
  # a color attribute. If @color is a Proc, it invokes the proc with the @title
  # to determine the color. If @color is nil, it derives a color from the title
  # string. Otherwise, it uses the @color value directly as an index into the
  # ANSI color attributes.
  #
  # @return [ Term::ANSIColor::Attribute ] the selected color attribute object
  def pick_color
    Term::ANSIColor::Attribute[
      case @color
      when Proc
        @color.(@title)
      when nil
        derive_color_from_string(@title)
      else
        @color
      end
    ]
  end

  # The pick_secondary_color method determines a secondary color based on a
  # primary color and brightness adjustment parameters It returns the
  # pre-configured secondary color if one exists, otherwise
  # calculates a new color by adjusting the brightness of the primary color
  #
  # @param color [ Term::ANSIColor::Attribute ] the primary color attribute to
  #   be used as a base for calculation
  # @param adjust_brightness [ Symbol ] the method to call on the color for
  #   brightness adjustment
  # @param adjust_brightness_percentage [ Integer ] the percentage value to use
  #   for the brightness adjustment
  # @return [ Term::ANSIColor::Attribute ] the secondary color attribute,
  #   either pre-configured or calculated from the primary color
  def pick_secondary_color(color, adjust_brightness:, adjust_brightness_percentage:)
    @color_secondary and return @color_secondary
    color_primary = color.to_rgb_triple.to_hsl_triple
    color_primary.send(adjust_brightness, adjust_brightness_percentage) rescue color
  end

  # The sleep_now method calculates and executes a sleep duration based on the
  # configured sleep time and elapsed time since start
  #
  # This method determines how long to sleep by calculating the difference
  # between the configured sleep interval and the time elapsed since the last
  # operation started. If no start time is recorded, it uses the full
  # configured sleep duration. The method ensures that negative sleep durations
  # are not used by taking the maximum of the calculated duration and zero.
  def sleep_now
    duration = if @start
                 [ @sleep - (Time.now - @start).to_f, 0 ].max
               else
                 @sleep
               end
    sleep duration
  end

  # The perform_display_diff method calculates and displays the difference
  # between the current and previous display states to update only the changed
  # portions of the terminal output
  #
  # This method synchronizes access to shared display resources using a mutex,
  # then compares the current display with the previous state to determine what
  # needs updating. It handles dimension mismatches by resetting the old
  # display, computes the visual difference, and outputs only the modified
  # portions to reduce terminal update overhead
  #
  # When the DEBUG_BYTESIZE environment variable is set, it also outputs
  # debugging information about the size of the diff and the time elapsed since
  # the last debug output
  def perform_display_diff
    @mutex.synchronize do
      unless @old_display && @old_display.dimensions == @display.dimensions
        @old_display = @display.dup.clear
      end
      diff = @display - @old_display
      if ENV['DEBUG_BYTESIZE']
        unless @last
          STDERR.puts %w[ size duration ] * ?\t
        else
          STDERR.puts [ diff.size, (Time.now - @last).to_f ] * ?\t
        end
        @last = Time.now
      end
      perform diff
      @display, @old_display = @old_display.clear, @display
      perform move_to(lines, columns)
    end
  end


  # The normalize_value method converts a value to its appropriate numeric
  # representation
  #
  # This method takes an input value and normalizes it to either a Float or
  # Integer type depending on its original form. If the value is already a
  # Float, it is returned as-is. For all other types, the method attempts to
  # convert the value to an integer using to_i
  #
  # @param value [ Object ] the value to be normalized
  #
  # @return [ Float, Integer ] the normalized numeric value as either a Float
  #   or Integer
  def normalize_value(value)
    case value
    when Float
      value
    else
      value.to_i
    end
  end

  # The full_reset method performs a complete reset of the display and terminal
  # state
  #
  # This method synchronizes access to shared resources using a mutex, then
  # executes a series of terminal control operations to reset the terminal
  # state, clear the screen, move the cursor to the home position, and make the
  # cursor visible. It also initializes new display objects with the current
  # terminal dimensions and updates the internal
  # display state.
  def full_reset
    @mutex.synchronize do
      perform reset, clear_screen, move_home, show_cursor
      winsize = Tins::Terminal.winsize
      opts = {
           color: @foreground_color,
        on_color: @background_color,
      }
      @display     = Graphina::Graph::Display.new(*winsize, **opts)
      @old_display = Graphina::Graph::Display.new(*winsize, **opts)
      perform @display
      @full_reset = false
    end
  end

  # The install_handlers method sets up signal handlers for graceful shutdown
  # and terminal resize handling
  #
  # This method configures two signal handlers: one for the exit hook that
  # performs a full reset, and another for the SIGWINCH signal that handles
  # terminal resize events by setting a flag and displaying a sleeping message
  def install_handlers
    at_exit { full_reset }
    trap(:SIGWINCH) do
      @full_reset = true
      perform reset, clear_screen, move_home, 'Zzz…'
    end
  end
end

require 'graphina/graph/display'
