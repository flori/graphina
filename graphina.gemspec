# -*- encoding: utf-8 -*-
# stub: graphina 0.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "graphina".freeze
  s.version = "0.4.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "1980-01-02"
  s.description = "Gem that provides terminal-based data visualization capabilities, enabling\ndevelopers to create dynamic, real-time graphical displays of numerical data\ndirectly within terminal environments using Unicode characters and ANSI\nstyling.\n".freeze
  s.email = "flori@ping.de".freeze
  s.executables = ["graphina".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "lib/graphina.rb".freeze, "lib/graphina/graph.rb".freeze, "lib/graphina/graph/display.rb".freeze, "lib/graphina/graph/display/cell.rb".freeze, "lib/graphina/graph/formatters.rb".freeze, "lib/graphina/graphina_config.rb".freeze, "lib/graphina/panel.rb".freeze, "lib/graphina/panel/chooser.rb".freeze, "lib/graphina/setup.rb".freeze, "lib/graphina/version.rb".freeze]
  s.files = [".utilsrc".freeze, "Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "VERSION".freeze, "bin/graphina".freeze, "graphina.gemspec".freeze, "img/graphina.png".freeze, "lib/graphina.rb".freeze, "lib/graphina/graph.rb".freeze, "lib/graphina/graph/display.rb".freeze, "lib/graphina/graph/display/cell.rb".freeze, "lib/graphina/graph/formatters.rb".freeze, "lib/graphina/graphina_config.rb".freeze, "lib/graphina/panel.rb".freeze, "lib/graphina/panel/chooser.rb".freeze, "lib/graphina/panel/defaults/arm64-darwin.yml".freeze, "lib/graphina/panel/defaults/x86_64-darwin.yml".freeze, "lib/graphina/panel/defaults/x86_64-linux.yml".freeze, "lib/graphina/setup.rb".freeze, "lib/graphina/version.rb".freeze]
  s.homepage = "https://github.com/flori/graphina".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--title".freeze, "Graphina - Gem for creating terminal-based data visualizations with real-time\ngraphical displays using Unicode characters and ANSI styling.\n".freeze, "--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "4.0.2".freeze
  s.summary = "Gem for creating terminal-based data visualizations with real-time graphical displays using Unicode characters and ANSI styling.".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 2.10".freeze])
  s.add_development_dependency(%q<debug>.freeze, ["~> 1.0".freeze])
  s.add_runtime_dependency(%q<tins>.freeze, ["~> 1.49".freeze])
  s.add_runtime_dependency(%q<term-ansicolor>.freeze, ["~> 1.11".freeze])
  s.add_runtime_dependency(%q<const_conf>.freeze, ["~> 0.4".freeze, ">= 0.4.3".freeze])
  s.add_runtime_dependency(%q<amatch>.freeze, ["~> 0.5".freeze])
  s.add_runtime_dependency(%q<search_ui>.freeze, [">= 0".freeze])
end
