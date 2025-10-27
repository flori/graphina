class Graphina::Graph
  # A terminal display class that manages a grid of colored cells with ANSI
  # styling support
  #
  # The Display class provides functionality for creating and managing
  # terminal-based visual displays It handles cell-level rendering with support
  # for colors, background colors, and text styles The class maintains internal
  # state for cursor position and formatting attributes while providing methods
  # to manipulate individual cells and render complete display grids to the
  # terminal
  #
  # @example
  #   display = Graphina::Graph::Display.new(24, 80)
  #   # Creates a 24x80 character display grid for terminal rendering
  class Display
    # Shortcut for Term::ANSIColor module.
    ANSI = Term::ANSIColor

    # The initialize method sets up a Display instance by configuring its grid
    # dimensions and initializing internal state
    #
    # This method creates a display grid with the specified number of lines and
    # columns, establishing the boundaries for cell positioning. It initializes
    # the internal ranges for lines and columns and performs an initial clear
    # operation to set up the display buffer with default values
    #
    # @param lines [ Integer ] the number of lines (rows) in the display grid
    # @param columns [ Integer ] the number of columns (characters per line) in
    #   the display grid
    # @param color [ Symbol ] the default text color for the display
    # @param on_color [ Symbol ] the default background color for the display
    def initialize(lines, columns, color: :white, on_color: :black)
      @lines_range   = 1..lines
      @columns_range = 1..columns
      @orig_color    = color
      @orig_on_color = on_color
      clear
    end

    # The clear method resets the display state by initializing cursor
    # position, color attributes, and cell contents to their default values
    #
    # This method prepares the terminal display for a fresh rendering by
    # resetting internal tracking variables such as cursor coordinates, color
    # settings, and text styles. It also reinitializes the two-dimensional
    # array of Cell objects that represent the display grid, filling each cell
    # with a space character and default styling attributes
    #
    # @param color [ Symbol ] the default text color for the display
    # @param on_color [ Symbol ] the default background color for the display
    #
    # @return [ Graphina::Graph::Display ] returns the Display instance to allow
    #   for method chaining
    def clear
      @x        = 1
      @y        = 1
      @color    = @orig_color
      @on_color = @orig_on_color
      @styles   = []
      @cells    =
        Array.new(lines) {
          Array.new(columns) {
            Cell.new(' ', @color, @on_color, @styles)
          }
        }
      reset
    end

    # The reset method resets the display's color and style attributes to their
    # default values
    #
    # This method reinitializes the internal color tracking variables to their
    # default state, clearing any active styling and resetting the text color
    # to white (15) and background color to black (0). It also clears all
    # active text styles.
    #
    # @return [ Graphina::Graph::Display ] returns the Display instance to allow
    #   for method chaining
    def reset
      @color    = @orig_color
      @on_color = @orig_on_color
      @styles   = []
      self
    end

    # The each method iterates over all cells in the display grid
    #
    # This method provides an iterator interface for accessing each cell in the
    # terminal display grid by yielding the row, column, and cell object for
    # each position in the grid
    #
    # @yield [ y, x, cell ] yields the row coordinate, column coordinate, and cell object
    #
    # @return [ Enumerator ] an enumerator that allows iteration over all cells in the grid
    def each(&block)
      Enumerator.new do |enum|
        @lines_range.each do |y|
          @columns_range.each do |x|
            enum.yield y, x, @cells[y - 1][x - 1]
          end
        end
      end.each(&block)
    end

    # The - method calculates the difference between two display states by
    # comparing their cells and returns a string of ANSI escape sequences that
    # represent only the changes
    #
    # This method takes another Display instance and compares it with the
    # current display state to identify which cells have changed. It generates
    # a minimal set of ANSI cursor movement and character output commands to
    # redraw only the portions of the display that have changed, making
    # terminal updates more efficient
    #
    # @param old [ Graphina::Graph::Display ] the previous display state to compare against
    #
    # @return [ String ] a string containing ANSI escape sequences for
    #   rendering only the changed cells
    def -(old)
      dimensions != old.dimensions and raise ArgumentError,
        "old dimensions #{old.dimensions.inspect} don't match #{dimensions.inspect}"
      result = +''
      each.zip(old.each) do |(my, mx, me), (_, _, old)|
        if me != old
          result << ANSI.move_to(my, mx) << me.to_s
        end
      end
      result
    end

    # The to_s method generates a string representation of the display by
    # iterating over all cells and constructing a formatted terminal output
    # with ANSI escape sequences for positioning and styling
    #
    # @return [ String ] a complete terminal display string with all cells
    #   rendered using their visual attributes and positioned according to
    #   their coordinates in the grid
    def to_s
      each.inject(ANSI.clear_screen)  do |s, (y, x, c)|
        s << ANSI.move_to(y, x) << c.to_s
      end
    end

    # The inspect method returns a string representation of the display object
    # that includes its class name along with the dimensions of the display
    # grid
    #
    # @return [ String ] a formatted string containing the class name and
    #   display dimensions in the format "#<ClassName: columns×lines>"
    def inspect
      "#<#{self.class}: #{columns}×#{lines}>"
    end

    # The x reader method provides access to the x attribute that was set
    # during object initialization.
    #
    # This method returns the value of the x instance variable, which typically
    # represents the horizontal coordinate or position within the display grid.
    #
    # @return [ Integer ] the x coordinate value stored in the instance variable
    attr_reader :x

    # The y reader method provides access to the y attribute that was set
    # during object initialization.
    #
    # This method returns the value of the y instance variable, which typically
    # represents the vertical coordinate or position within the display grid.
    #
    # @return [ Integer ] the y coordinate value stored in the instance variable
    attr_reader :y

    # The lines method returns the number of lines in the display
    #
    # This method provides access to the vertical dimension of the graphical
    # display by returning the total number of rows available for rendering
    # content
    #
    # @return [ Integer ] the number of lines (rows) in the display object
    def lines
      @lines_range.end
    end

    # The columns method returns the number of columns in the display
    #
    # This method provides access to the horizontal dimension of the graphical
    # display by returning the total number of columns available for rendering
    # content
    #
    # @return [ Integer ] the number of columns (characters per line) in the
    #   display object
    def columns
      @columns_range.end
    end

    # The dimensions method returns the size dimensions of the display grid
    #
    # This method provides access to the display's rectangular dimensions by
    # returning an array containing the number of lines (height) and columns (width)
    # that define the terminal display area
    #
    # @return [ Array<Integer> ] an array where the first element is the number of lines
    #   and the second element is the number of columns in the display grid
    def dimensions
      [ lines, columns ]
    end

    # The styled method sets the text styles for subsequent character output
    #
    # This method configures the styling attributes that will be applied to
    # characters written to the display, such as bold, italic, underline,
    # and other text formatting options. It validates that all provided style
    # names are recognized before applying them.
    #
    # @param s [ Array<Symbol> ] an array of style symbols to apply
    #
    # @return [ Graphina::Graph::Display ] returns the Display instance for method chaining
    #
    # @raise [ ArgumentError ] raised when any of the provided style symbols is not recognized
    def styled(*s)
      if nope = s.find { !style?(_1) }
        raise ArgumentError, "#{nope} is not a style"
      end
      @styles = s
      self
    end

    # The at method sets the cursor position within the display grid
    #
    # This method updates the internal y and x coordinates to the specified position,
    # validating that the coordinates fall within the defined grid boundaries before
    # making the change. It enables subsequent character output operations to occur
    # at the designated location.
    #
    # @param y [ Integer ] the vertical coordinate to move the cursor to
    # @param x [ Integer ] the horizontal coordinate to move the cursor to
    #
    # @return [ Graphina::Graph::Display ] returns the Display instance for method chaining
    #
    # @raise [ ArgumentError ] raised when the y coordinate is outside the valid lines range
    # @raise [ ArgumentError ] raised when the x coordinate is outside the valid columns range
    def at(y, x)
      @lines_range.include?(y) or
        raise ArgumentError, "y #{y} out of lines range #@lines_range"
      @columns_range.include?(x) or
        raise ArgumentError, "x #{x} out of columns range #@columns_range"
      @y, @x = y, x
      self
    end

    # The put method assigns a character to the current cursor position in the
    # display grid
    #
    # This method stores a character cell at the current vertical and
    # horizontal coordinates within the terminal display grid. It validates
    # that the input is a single character before assigning it, ensuring that
    # only valid characters are placed in the grid.
    #
    # @param char [ String ] the single character to be placed at the current cursor position
    #
    # @return [ Graphina::Graph::Display ] returns the Display instance to allow for method chaining
    #
    # @raise [ ArgumentError ] raised when the provided character is not a single character
    def put(char)
      char.size == 1 or
        raise ArgumentError, "#{char} is not single character"
      @cells[@y - 1][@x - 1] = Cell.new(char, @color, @on_color, @styles)
      self
    end

    # The write method outputs a string character by character within the
    # display grid
    #
    # This method takes a string and writes it to the current cursor position
    # in the terminal display, advancing the cursor position after each
    # character is written. It handles line wrapping by stopping when reaching
    # the end of the row.
    #
    # @param string [ String ] the string to be written to the display
    #
    # @return [ Graphina::Graph::Display ] returns the Display instance to allow
    #   for method chaining
    def write(string)
      string.each_char do |char|
        put(char)
        if x < columns - 1
          at(y, x + 1)
        else
          break
        end
      end
      self
    end

    # The top method moves the cursor position to the first line of the current
    # column
    #
    # This method sets the vertical cursor coordinate to the first line while
    # preserving the current horizontal position It is useful for positioning
    # text at the top of the current column in terminal displays
    #
    # @return [ Graphina::Graph::Display ] returns the Display instance for
    #   method chaining
    #
    def top
      at(1, x)
    end

    # The bottom method moves the cursor position to the last line of the
    # current column
    #
    # This method sets the vertical cursor coordinate to the last line while
    # preserving the current horizontal position. It is useful for positioning
    # text at the bottom of the current column in terminal displays.
    #
    # @return [ Graphina::Graph::Display ] returns the Display instance for
    #   method chaining
    def bottom
      at(lines, x)
    end

    # The left method moves the cursor position to the first column of the
    # current line
    #
    # This method sets the horizontal cursor coordinate to the first column while
    # preserving the current vertical position. It is useful for positioning text
    # at the beginning of the current line in terminal displays
    #
    # @return [ Graphina::Graph::Display ] returns the Display instance for
    #   method chaining
    def left
      at(y, 1)
    end

    # The right method moves the cursor position to the last column of the
    # current line
    #
    # This method sets the horizontal cursor coordinate to the final column
    # while maintaining the current vertical position. It is useful for
    # positioning text at the end of the current line in terminal displays
    #
    # @return [ Graphina::Graph::Display ] returns the Display instance for
    #   method chaining
    def right
      at(y, columns)
    end

    # The centered method moves the cursor position to the center of the
    # display grid
    #
    # This method calculates the midpoint coordinates of the terminal display
    # grid and positions the cursor at that location, making it convenient for
    # centering text or other content within the available terminal space
    #
    # @return [ Graphina::Graph::Display ] returns the Display instance for
    #   method chaining
    def centered
      at(lines / 2, columns / 2)
    end

    # The write_centered method positions the cursor at the horizontal center
    # of the display grid and writes a string there
    #
    # This method calculates the starting column position needed to center the
    # given string within the current display width, moves the cursor to that
    # position, and then writes the string character by character.
    # It is useful for creating centered text output in terminal displays.
    #
    # @param string [ String ] the text string to be written and centered on
    #   the current line
    #
    # @return [ Graphina::Graph::Display ] returns the Display instance to allow
    #   for method chaining
    def write_centered(string)
      at(@y, (columns - string.size) / 2).write(string)
    end

    # The get method retrieves the cell object at the current cursor position
    #
    # This method accesses the internal two-dimensional array of Cell objects
    # using the current vertical and horizontal cursor coordinates to return
    # the specific cell that is currently pointed to by the cursor
    #
    # @return [ Graphina::Graph::Display::Cell ] the cell object at the current
    #   cursor position
    def get
      @cells[@y - 1][@x - 1]
    end

    # The color method sets the text color attribute for subsequent character
    # output
    #
    # This method configures the color that will be applied to characters
    # written to the display by updating the internal color tracking variable
    # with a validated color attribute value
    #
    # @param color [ Integer ] the color index to set for subsequent text output
    #
    # @return [ Graphina::Graph::Display ] returns the Display instance to allow
    #   for method chaining
    #
    # @raise [ ArgumentError ] raised when the provided color value is not a
    #   valid color attribute
    def color(color)
      @color = attribute!(color)
      self
    end

    # The on_color method sets the background color attribute for subsequent
    # character output
    #
    # This method configures the background color that will be applied to
    # characters written to the display by updating the internal on_color
    # tracking variable with a validated color attribute value
    #
    # @param on_color [ Integer ] the background color index to set for
    #   subsequent text output
    #
    # @return [ Graphina::Graph::Display ] returns the Display instance to allow
    #   for method chaining
    #
    # @raise [ ArgumentError ] raised when the provided color value is not a
    #   valid color attribute
    def on_color(on_color)
      @on_color = attribute!(on_color)
      self
    end

    private

    # The style? method checks whether a given symbol is a valid text styling
    # attribute
    #
    # This method verifies if the provided symbol corresponds to one of the
    # supported text styles that can be applied to terminal output, such as
    # bold, italic, underline, and other formatting options
    #
    # @param s [ Symbol ] the symbol to check against the list of valid styles
    #
    # @return [ Boolean ] true if the symbol is a recognized text style, false
    #   otherwise
    def style?(s)
      [
        :bold,
        :dark,
        :faint,
        :italic,
        :underline,
        :underscore,
        :blink,
        :rapid_blink,
        :reverse,
        :negative,
        :concealed,
        :conceal,
        :strikethrough,
      ].member?(s)
    end

    # The attribute? method checks if a given value is a valid ANSI color
    # attribute
    #
    # This method validates whether the provided input corresponds to a
    # recognized ANSI color attribute within the Term::ANSIColor::Attribute
    # namespace
    #
    # @param a [ Object ] the value to check against valid ANSI attributes
    #
    # @return [ Object, nil ] the attribute if valid, nil otherwise
    def attribute?(a)
      Term::ANSIColor::Attribute[a]
    end

    # The attribute! method validates a given value against known ANSI color
    # attributes and raises an error if invalid
    #
    # This method serves as a validation wrapper around the attribute? method,
    # ensuring that a provided value is a recognized ANSI color attribute. If
    # the validation fails, it raises an ArgumentError with a descriptive
    # message indicating which value was not accepted
    #
    # @param a [ Object ] the value to validate as an ANSI color attribute
    #
    # @return [ Object ] returns the validated attribute if it passes validation
    #
    # @raise [ ArgumentError ] raised when the provided value is not recognized
    #   as a valid ANSI color attribute
    def attribute!(a)
      attribute?(a) or
        raise ArgumentError, "#{a.inspect} is not a color attribute"
    end
  end
end

require 'graphina/graph/display/cell'
