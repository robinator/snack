Gem::Specification.new do |s|
  s.name        = 'snack'
  s.version     = '0.1'
  s.date        = '2010-10-17'
  s.summary     = 'A static website framework.'
  s.description = 'Snack is a small framework for building static websites.'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = '>= 1.3.6'

  s.author   = 'Rob Law'
  s.email    = 'rob@varietyour.com'
  s.homepage = 'http://github.com/robinator/snack/'

  s.files              = Dir['{bin,lib,test}/**/*']
  s.executables        = %w[ snack ]
  s.default_executable = 'snack'

  s.add_development_dependency 'rack'
  s.add_development_dependency 'ostruct'
  s.add_development_dependency 'tilt'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'haml', '>= 2.2.11'
  s.add_development_dependency 'coffee-script'
end