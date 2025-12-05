context do
  namespace "structure" do
    command "tree", tags: %w[ project_structure ]
  end

  namespace "bin" do
    Dir['bin/*'].each do |filename|
      file filename, tags: 'bin'
    end
  end

  namespace "lib" do
    Dir['lib/**/*.rb'].each do |filename|
      file filename, tags: 'lib'
    end
  end

  file 'README.md', tags: [ 'documentation' ]

  file '.contexts/yard.md', tags: [ 'yard', 'cheatsheet' ]

  meta guidelines: <<~EOT
    # Guidelines for creating YARD documentation

    - Look into the file, with tags yard and cheatsheet for how comment ruby
      constructs.
    - In comments above initialize methods **ALWAYS** omit @return
    - To document attr_accessor **ALWAYS** use the @attr tag and **NOT** the @return tag.
    - To document attr_reader **ALWAYS** use the @attr_reader tag and **NOT** the @return tag.
    - To document attr_writer **ALWAYS** use the @attr_writer tag and **NOT** the @return tag.
  EOT
end
