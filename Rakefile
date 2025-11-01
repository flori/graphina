# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'graphina'
  module_type :module
  author      'Florian Frank'
  email       'flori@ping.de'
  homepage    "https://github.com/flori/#{name}"
  summary <<~EOT
    Gem for creating terminal-based data visualizations with real-time
    graphical displays using Unicode characters and ANSI styling.
  EOT
  description <<~EOT
    Gem that provides terminal-based data visualization capabilities, enabling
    developers to create dynamic, real-time graphical displays of numerical data
    directly within terminal environments using Unicode characters and ANSI
    styling.
  EOT
  test_dir    'spec'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', '.AppleDouble', '.bundle',
    '.yardoc', 'tags', 'doc', 'cscope.out'
  package_ignore '.gitignore', '.contexts', '.github'

  readme      'README.md'

  github_workflows(
    'static.yml' => {}
  )

  required_ruby_version  '>= 3.1'

  executables << 'graphina'

  dependency  'tins',             '~> 1.45'
  dependency  'term-ansicolor',   '~> 1.11'
  dependency  'const_conf',       '~> 0.4', '>= 0.4.3'
  dependency  'amatch',           '~> 0.5'
  dependency  'search_ui'
  development_dependency 'debug', '~> 1.0'

  licenses << 'MIT'
end
