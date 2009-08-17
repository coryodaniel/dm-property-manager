load 'dm-property-manager.gem_spec'

Rake::GemPackageTask.new(GEM_SPEC) do |package|
  package.gem_spec = GEM_SPEC
end

desc "Run :package and install the resulting .gem"
task :install => :package do
  sh %{sudo gem install --local pkg/#{NAME}-#{DataMapper::PropertyManager::VERSION}.gem --no-rdoc --no-ri}
end

desc "Run :clean and uninstall the .gem"
task :uninstall => :clean do
  sh %{sudo gem uninstall #{NAME}}
end
