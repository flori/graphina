# Graphina 📊📈

## Description

A Ruby gem for creating terminal-based data visualizations with real-time
graphical displays using Unicode characters and ANSI styling 🎨📊

## Screenshots (run in tmux)

![graphina Screenshot](./img/graphina.png "graphina Screenshot")

## Documentation

Complete API documentation is available at: [GitHub.io](https://flori.github.io/graphina/)

## Features

- **Real-time Data Visualization**: Create dynamic, continuously updating
  graphs in terminal environments
- **Unicode Graphics**: Utilize Unicode block characters for high-resolution
  terminal graphics (2px vertical resolution)
- **ANSI Color Support**: Full color management with 256-color and true-color
  (24-bit) support
- **Multiple Display Modes**: Single and double resolution modes for different
  terminal capabilities
- **Flexible Data Sources**: Support for custom data providers via Proc objects
- **Multiple Formatting Options**: Built-in formatters for bytes, hertz,
  celsius, and percentage values
- **Efficient Rendering**: Delta-based updates to minimize terminal I/O
  overhead
- **Signal Handling**: Graceful shutdown and terminal resize handling
- **String-based Color Derivation**: Automatically derive consistent colors
  from titles and labels
- **Panel Configuration System**: Predefined panel configurations for reuse
- **Interactive Selection**: Choose from available panels with fuzzy matching

## Installation

Add this gem to your Gemfile:

```ruby
gem 'graphina'
```

And install it using Bundler:

```bash
bundle install
```

Or install the gem directly:

```bash
gem install graphina
```

## Panel Configuration Setup

Graphina now supports predefined panel configurations. You can create a
`panels.yml` file in your configuration directory
(`"$XDG_CONFIG_HOME/graphina"`, usually `~/.config/graphina/panels.yml`) to
define reusable panel setups.

To install one of the included defaults you can try
```bash
graphina -S default
```

which attempts to infer a default config for your platform.


Currently these platforms are included:

  - MacOS x86 64 see [x86_64-darwin](lib/graphina/panel/defaults/x86_64-darwin.yml).
  - Linux x86 64 see [x86_64-linux](lib/graphina/panel/defaults/x86_64-linux.yml).

These can be installed eplicitly via:
```bash
graphina -S x86_64-darwin
```

Then to use a specific panel:
```bash
graphina -P cpu_usage_percentage
```

To see all available panels:
```bash
graphina
```

## Usage

### 1. Basic Usage with Random Data

```bash
# Simple usage with random data or interactive panel selection
graphina
```

### 2. Custom Title and Text Colors

```bash
# Custom title with specific colors
graphina -t "CPU Usage (faked)" -f blue -b black
```

### 3. More complex CPU Usage Monitoring example

```bash
# Monitor CPU usage in real-time
graphina -t 'CPU Usage' -n 1 -F as_percent -e "top -l 1 -n 0 | grep 'CPU usage' | awk '{print \$3+\$5}'"
```

### 4. Using Predefined Panels

```bash
# Use a predefined panel configuration
graphina -P cpu_usage_percentage

# Interactive panel selection
graphina
```

See below under **Panel Configuration** how to setup these panel configurations
on your system.

### 5. Custom Data Source

```ruby
# Using the library directly in Ruby code
require 'graphina'

graph = Graphina::Graph.new(
  title: 'CPU Usage',
  value: ->(i) { rand(100) },
  format_value: :as_percent,
  sleep: 1,
  color: 33
)
graph.start
```

### 6. Custom Command with External Data

```ruby
# Using external command for data
graph = Graphina::Graph.new(
  title: 'Temperature',
  value: ->(i) { `sensors | grep 'Tctl' | awk '{print \$2}'`.to_f },
  format_value: :as_celsius,
  sleep: 2
)
graph.start
```

## Command Line Options

```
Usage: graphina [OPTIONS]

  OPTIONS are

    -t TITLE      Title for the graph (default: 'Data')
    -n SECONDS    Update interval in seconds (default: 5)
    -r MODE       Resolution mode (:single or :double, default: :double)
    -f COLOR      Foreground color (default: :white)
    -b COLOR      Background color (default: :black)
    -c COLOR      Primary color (default: derived from title)
    -C COLOR      Secondary color (default: derived from primary)
    -F FORMAT     Format function (:as_bytes, :as_hertz, :as_celsius, :as_percent, :as_default, default: :as_default)
    -P PANEL      Use predefined panel configuration (default: interactive selection)
    -S CONFIG     Setup panel config (default infers from OS)
    -e COMMAND    External command to execute for data values (default: random data)
    -h            this help
```

## Author

[Florian Frank](mailto:flori@ping.de) 🧑‍💻

## License

[MIT License](./LICENSE) 📄
