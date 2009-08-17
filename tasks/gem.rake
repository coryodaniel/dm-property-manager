spec = Gem::Specification.new do |s|
  s.name         = NAME
  s.version      = DataMapper::PropertyManager::VERSION
  s.platform     = Gem::Platform::RUBY
  s.author       = "Cory O'Daniel"
  s.email        = "dm-property-manager@coryodaniel.com"
  s.homepage     = "http://github.com/coryodaniel/dm-property-manager/tree/master"
  s.summary      = "Share properties between models with one model 'managing' the creation of another."
  s.description  = "Share properties between models with one model 'managing' the creation of another."
  s.executables  = nil
  s.require_path = "lib"
  s.files        = %w( README.markdown Rakefile ) + Dir["{doc,lib,tasks,spec}/**/*"]

  # rdoc
  s.has_rdoc         = true
  s.extra_rdoc_files = %w( README.markdown )

  # Dependencies
  s.add_dependency "dm-core",">=0.9.11"
  
  # Requirements
  s.required_ruby_version = ">= 1.8.5"
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc "Run :package and install the resulting .gem"
task :install => :package do
  sh %{sudo gem install --local pkg/#{NAME}-#{DataMapper::PropertyManager::VERSION}.gem --no-rdoc --no-ri}
end

desc "Run :clean and uninstall the .gem"
task :uninstall => :clean do
  sh %{sudo gem uninstall #{NAME}}
end
