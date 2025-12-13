require 'fileutils'

# A class that handles the setup and configuration of Graphina
#
# The Setup class provides functionality for installing default panel
# configurations into the user's configuration directory. It manages the
# detection of platform-specific default configurations and facilitates the
# copying of these configurations to the appropriate location for use with the
# Graphina application
#
# @example
#   setup = Graphina::Setup.new(default_panels_name: 'c64-linux')
#   setup.install_default_panels
class Graphina::Setup
  include FileUtils::Verbose

  # The initialize method sets up a Setup instance with the specified default
  # panel name
  #
  # This method configures a new setup object with a default panel name,
  # handling the special case where the name is 'default' by setting it to nil
  # instead
  #
  # @param default_panels_name [ String ] the name of the default panels to use
  #
  # @return [ Graphina::Setup ] returns the initialized Setup instance
  def initialize(default_panels_name:)
    default_panels_name == 'default' and default_panels_name = nil
    @default_panels_name = default_panels_name
  end

  # The infer_default_panels_path_from_platform method attempts to determine
  # the appropriate default panel configuration file path based on the current
  # platform
  #
  # This method checks the RUBY_PLATFORM environment variable to identify
  # whether the system is running on an x86_64 Darwin (macOS) or x86_64 Linux
  # platform
  #
  # @return [ Pathname, nil ] returns a Pathname object pointing to the
  #   detected default panels configuration file if the platform is supported and
  #   the file exists, or nil if the platform is not supported or the file does
  #   not exist
  def infer_default_panels_path_from_platform
    case RUBY_PLATFORM
    when /\Ax86_64-darwin/, /\Ax86_64-linux/
      path = default_panels_path($&)
      if path.exist?
        path
      end
    else
      STDERR.puts "Default panel configuration cannot be inferred for platform!"
      nil
    end
  end

  # The default_panels_path method constructs and returns a Pathname object
  # for a default panels configuration file
  #
  # This method takes a panel name parameter and uses it to build a file path
  # pointing to a default panels configuration file
  # located in the panel defaults directory. It checks if the constructed path
  # exists and returns it if so, or nil if the file doesn't exist
  #
  # @param panels_name [ String ] the name of the panels configuration to look up
  #
  # @return [ Pathname, nil ] a Pathname object pointing to the default panels
  #   configuration file if it exists, or nil if it doesn't exist
  def default_panels_path(panels_name)
    path = Pathname.new(__FILE__).dirname + 'panel' + 'defaults' + (panels_name + '.yml')
    if path.exist?
      path
    end
  end

  # The panels_path_exist? method checks whether the panel configuration file
  # path exists in the user's configuration directory
  #
  # This method verifies the existence of the panels configuration file by
  # querying the predefined path in the Graphina configuration module
  #
  # @return [ Boolean ] true if the panels configuration file exists at the
  #   expected location, false otherwise
  def panels_path_exist?
    Graphina::GraphinaConfig::PANELS_PATH.exist?
  end

  # The install_default_panels method installs default panel configurations
  # into the user's configuration directory
  #
  # This method checks if a panel configuration file already exists in the
  # user's configuration directory and, if not, attempts to determine the
  # appropriate default panel configuration based on the platform or the
  # specified default panel name, then copies the default configuration file to
  # the user's configuration directory
  def install_default_panels
    if panels_path_exist?
      STDOUT.print "#{Graphina::GraphinaConfig::PANELS_PATH.to_s.inspect} exists. Overwrite (y/n)? "
      STDIN.gets !~ /\Ay/i and return
    end
    default_path = @default_panels_name ?
      default_panels_path(@default_panels_name) :
      infer_default_panels_path_from_platform
    if default_path
      mkdir_p Graphina::GraphinaConfig::CONFIG_DIR
      cp default_path, Graphina::GraphinaConfig::PANELS_PATH
      STDOUT.puts "Default panels from #{default_path.to_s.inspect} have been installed."
    else
      STDERR.puts "Default panels for #{@default_panels_name.inspect} could not be installed."
    end
  end
end
