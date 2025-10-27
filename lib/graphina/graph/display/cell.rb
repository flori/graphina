class Graphina::Graph::Display
  # A cell representation for terminal display with character, color,
  # background color, and styling attributes
  #
  # The Cell class encapsulates the properties of a single character cell in
  # a terminal display, including its visual characteristics such as the
  # displayed character, text color, background color, and styling
  # attributes. It provides methods to compare cells and convert them to
  # their string representation with ANSI escape codes for terminal
  # rendering.
  class Cell < Struct.new(:char, :color, :on_color, :styles)
    # The == method compares two Cell objects for equality by their internal
    # array representation
    #
    # This method checks if the current Cell instance is equal to another
    # Cell instance by comparing their underlying array representations
    # returned by to_a
    #
    # @param other [ Graphina::Graph::Display::Cell ] the other Cell object to
    #   compare against
    #
    # @return [ Boolean ] true if both cells have identical char, color,
    #   on_color, and styles values, false otherwise
    def ==(other)
      to_a == other.to_a
    end

    # The to_s method converts a Cell object into its string representation
    # with ANSI styling
    #
    # This method constructs a formatted string that includes the cell's
    # character along with its color, background color, and text style
    # attributes using ANSI escape sequences. The resulting string is
    # suitable for display in terminal environments that support ANSI colors.
    #
    # @return [ String ] a formatted string containing the cell's visual
    #   representation with appropriate ANSI styling codes for terminal
    #   rendering
    def to_s
      result = +''
      result << ANSI.color(color)
      result << ANSI.on_color(on_color)
      styles.each { |s| result << ANSI.send(s) }
      result << char
      result << ANSI.reset
    end
  end
end
