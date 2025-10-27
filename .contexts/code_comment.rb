context do
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
end
