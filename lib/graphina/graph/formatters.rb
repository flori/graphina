class Graphina::Graph
  # A module that provides various formatting methods for converting numeric
  # values into human-readable strings with appropriate units and display
  # formats.
  #
  # The Formatters module contains a collection of utility methods designed to
  # transform raw numeric data into formatted strings that are more suitable
  # for display purposes. These methods handle common formatting tasks such as
  # converting byte measurements, frequency values, temperature readings, and
  # percentages into clean, readable representations.
  #
  # Each formatter method in this module is intended to be used with data
  # visualization or reporting scenarios where presenting numerical information
  # in an easily understandable format is important. The module also includes
  # specialized functionality for deriving consistent color values based on
  # input strings, which can be useful for maintaining visual coherence when
  # displaying multiple data series.
  #
  # @example
  #   include Graphina::Graph::Formatters
  #
  #   as_bytes(1024 * 1024)        # => "1.000MB"
  #   as_hertz(2500000000)        # => "2.500GHz"
  #   as_celsius(37.5)            # => "37.5°"
  #   as_percent(95.7)            # => "95.7%"
  #   as_default(42)              # => "42"
  module Formatters
    # The as_bytes method formats a numeric value into a human-readable byte
    # representation
    #
    # This method takes a numeric input and converts it into a formatted string
    # representing the value in bytes with appropriate binary prefixes (KB,
    # MB, GB, etc.)
    #
    # @param value [ Numeric ] the numeric value to be formatted as bytes
    #
    # @return [ String ] the formatted byte representation with unit suffix
    def as_bytes(value)
      Tins::Unit.format(value, prefix: :uc, format: '%.3f%U', unit: 'B')
    end

    # The as_hertz method formats a numeric value into a human-readable
    # frequency representation
    #
    # This method takes a numeric input and converts it into a formatted string
    # representing the value in hertz with appropriate metric prefixes (kHz,
    # MHz, GHz, etc.)
    #
    # @param value [ Numeric ] the numeric frequency value to be formatted
    #
    # @return [ String ] the formatted frequency representation with unit suffix
    def as_hertz(value)
      prefix = [
        '', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y',
      ].each_with_index.map { |n, i| Tins::Unit::Prefix.new(n.freeze, 1000, 1000 ** i, false) }.freeze
      Tins::Unit.format(value, prefix:, format: '%.3f%U', unit: 'Hz')
    end

    # The as_celsius method formats a temperature value with a degree symbol
    #
    # This method takes a numeric temperature value and returns a string
    # representation with the degree Celsius symbol appended to it
    #
    # @param value [ Numeric ] the temperature value to be formatted
    #
    # @return [ String ] the temperature value formatted with a degree Celsius symbol
    def as_celsius(value)
      "#{value}℃"
    end

    # The as_percent method formats a numeric value as a percentage string
    #
    # This method takes a numeric input and returns a string representation
    # with a percent sign appended to it, providing a simple way to format
    # numeric values as percentages for display purposes
    #
    # @param value [ Numeric ] the numeric value to be formatted as a percentage
    #
    # @return [ String ] the numeric value formatted as a percentage string
    def as_percent(value)
      "#{value}%"
    end

    # The as_default method converts a value to its string representation
    #
    # This method takes any input value and converts it to a string using the to_s method
    # It serves as a fallback formatting option when no specific formatting is required
    #
    # @param value [ Object ] the value to be converted to a string
    #
    # @return [ String ] the string representation of the input value
    def as_default(value)
      value.to_s
    end

    # The derive_color_from_string method calculates a color value based on the
    # input string by generating an MD5 hash and selecting from a predefined
    # set of dark colors
    #
    # @param string [ String ] the input string used to derive the color value
    #
    # @return [ Integer ] the derived color value from the set of dark ANSI attributes
    def derive_color_from_string(string)
      cs = (21..226).select { |d|
        Term::ANSIColor::Attribute[d].to_rgb_triple.to_hsl_triple.
          lightness < 40
      }
      s = Digest::MD5.digest(string).unpack('Q*')
      cs[ s.first % cs.size ]
    end

    self
  end
end
