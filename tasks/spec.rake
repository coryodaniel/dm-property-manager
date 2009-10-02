desc "Run specs"
task :spec do
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = Dir['./spec/**/*_spec.rb'].unshift('./spec/spec_helper.rb')          

    t.libs = ['lib']
    t.spec_opts << "--color" << "--format" << "progress" #"specdoc"
t.rcov = true    
    if ENV['RCOV']
      t.rcov = true
      t.rcov_opts << '--exclude' << 'pkg,spec,interactive.rb,install_test_suite.rb,lib/gems,' + Gem.path.join(',')
      t.rcov_opts << '--text-summary'
      t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
      t.rcov_opts << '--only-uncovered'
    end
  end  
end