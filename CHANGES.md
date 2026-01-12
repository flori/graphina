# Changes

## 2026-01-12 v0.5.0

- Added `CHANGES.md` file to track version history and changes
- Added `changelog` section to `Rakefile` to include `CHANGES.md` in gem build
  process
- Updated `rubygems_version` from **4.0.2** to **4.0.3**
- Updated `gem_hadar` development dependency from **~> 2.10** to **>= 2.16.2**
- Added GPU monitoring sections to **x86_64-linux.yml** with fan, clock, and
  temperature panels
- Enhanced **x86_64-linux.yml** with hardware fan monitoring support for case,
  CPU, and pump fans
- Introduced new documentation headers for **arm64-darwin.yml**,
  **x86_64-darwin.yml**, and **x86_64-linux.yml**
- Updated memory usage color from **`#689d6a`** to **`#fabd2f`** in
  **x86_64-linux.yml**
- Standardized color schemes across all platform configurations
- Added detailed inline documentation for the `usage` method with comprehensive help text
- Included descriptive comments at the top of the file explaining Graphina's
  purpose and features

## 2025-12-19 v0.4.1

- Updated `gem_hadar` development dependency from version **2.8** to **2.10**

## 2025-12-18 v0.4.0

- Updated `tins` gem dependency from **1.45** to **1.49**
- Replaced manual SI prefix construction with `:si_uc` format option in
  `as_hertz` method
- Updated `rubygems` version requirement from **3.7.2** to **4.0.2** in gemspec
- Removed workaround code for prefix formatting in
  `lib/graphina/graph/formatters.rb`

## 2025-12-16 v0.3.0

- Added support for **MacOS ARM 64** platform with new `arm64-darwin.yml`
  default config
- Updated `README.md` to reflect that installation now includes config
  inference and installation
- Simplified CPU usage extraction command in `README.md` by removing
  unnecessary `grep` step
- Refactored temperature sensor data extraction in `README.md` to use single
  `awk` command instead of `grep | awk` pipeline
- Added support for **arm64**-darwin platform in `Graphina::Setup`
- Introduced `arm64-darwin.yml` default panel configuration
- Updated `x86_64-darwin.yml` and `x86_64-linux.yml` with standardized titles
- Enhanced `as_hertz` method in `Graphina::Graph` to use custom prefixes
- Replaced `Tins::Unit.format` with custom prefix handling for better control
- Updated CPU clock command for **x86_64-darwin** to use `powermetrics` with
  `-i 100 -n 9` flags
- Changed title format for all metrics from "(%)" to "%" for consistency
- Used `%.3f%U` format string for `as_hertz` to ensure proper unit display

## 2025-12-13 v0.2.0

- Added support for predefined panel configurations with new `Graphina::Setup`
  class
- Introduced `-S` command-line option to install default panel configurations
  from `lib/graphina/panel/defaults/`
- Added default panel configuration files for **x86_64-darwin** and
  **x86_64-linux** architectures
- Enhanced `bin/graphina` to handle the new `-S` option and call
  `Graphina::Setup#install_default_panels`
- Updated `lib/graphina.rb` to require `graphina/setup`
- Added `lib/graphina/setup.rb` with platform detection and configuration
  copying functionality
- Extended documentation in `README.md` for panel configuration setup and usage
- Added `project_structure` tag to tree command for documentation
  categorization
- Introduced `structure` namespace with `tree` command for project layout
  analysis
- Updated Linux system monitoring panel configurations:
  - Renamed `cpu` panel to `cpu_usage_percentage` in `README.md`
  - Renamed `memory` panel to `memory_usage` in `README.md`
  - Added new `memory_usage_percentage` panel with percentage calculation
  - Renamed `temperature` panel to `cpu_temperature` in `README.md`
- Configured tree command to capture project file hierarchy
- Enabled documentation generation for gem directory structure
- Added `lib/graphina/setup.rb` to `extra_rdoc_files` and `files` in
  `graphina.gemspec`
- Updated file tagging in `.contexts/code_comment.rb` to include `code` and
  `config` tags for YAML files

## 2025-11-29 v0.1.1

- Updated Celsius temperature symbol from `"°"` to `"℃"` for better Unicode
  representation
- Added platform-specific panel configuration examples to `README.md` including
  a Linux example for `panels.yml` configuration
- Added `img/graphina.png` screenshot to `README.md` with a new section `##
  Screenshots (run in tmux)` and alt text "graphina Screenshot"
- Introduced new `.utilsrc` configuration file for code indexing and searching
- Added `cscope.out` to `.gitignore` and `Rakefile`
- Updated panel configuration with new names and improved formatting

## 2025-10-30 v0.1.0

- Added support for predefined panel configurations via the new `-P PANEL`
  command line option
- Implemented panel configuration system with `Graphina::Panel` class for
  managing graph display settings
- Introduced `Graphina::Panel::Chooser` module for interactive panel selection
  with fuzzy matching
- Enhanced CLI with backwards compatible `-e` flag support for executing
  external data commands
- Updated documentation to reflect XDG base directory specification for
  configuration files
- Added `GraphinaConfig` module with support for XDG Base Directory
  specification and YAML configuration loading
- Added new dependencies: `const_conf` (**0.4**), `amatch` (**0.5**), and
  `search_ui`
- Extended `format_value` method to support both `Symbol` and `String` types
  for method calls
- Refactored graph initialization to use panel values instead of raw
  command-line options
- Added `configure_from_opts` method to `Graphina::Panel` for backward
  compatibility
- Updated `Graphina::Graph` initialization to use panel values
- Added `Tins` dependency for additional utilities
- Improved README documentation with `panels.yml` configuration examples and
  `cpu`/`memory` panel examples
- Added interactive panel selection when no panel is specified
- Updated `Graphina::Panel` to support dynamic attribute assignment via
  `configure` method
- Added accessor methods for title, interval, command, color settings,
  resolution, and `format_value`
- Added `value` method that returns data generation proc (external command or
  random data)
- Added `from_opts` factory method for creating panel instances from
  command-line options
- Updated gemspec file lists to include new files: `graphina_config.rb`,
  `panel.rb`, and `panel/chooser.rb`
- Added YARD documentation cheatsheet and guidelines for consistent
  documentation practices
- Documented `-e COMMAND` option for executing external data commands with
  examples using `top` and `free` commands
- Split long lines in README.md for better readability
- Removed incorrect parameter documentation from `clear` method

## 2025-10-27 v0.0.0

* Start
