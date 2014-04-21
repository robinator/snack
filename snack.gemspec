Gem::Specification.new do |s|
  s.name        = 'snack'
  s.version     = '0.2.5'
  s.date        = '2013-09-13'
  s.summary     = 'A static website framework.'
  s.description = 'Snack is a small framework for building static websites.'

  s.required_ruby_version     = '>= 2.0.0'
  s.required_rubygems_version = '>= 1.3.6'

  s.author   = 'Rob Law'
  s.email    = 'rob@robmadethis.com'
  s.homepage = 'http://robmadethis.com/snack'
  s.license           = 'MIT'

  s.files              = Dir['{bin,lib,test}/**/*']
  s.executables        = %w[ snack ]

  s.add_dependency 'rack', '~> 1.5'
  s.add_dependency 'tilt', '~> 2'
  s.add_dependency 'coffee-script', '~> 2.2'
  s.add_development_dependency 'haml', '~> 4'
  s.add_development_dependency 'sass', '~> 3'
  s.add_development_dependency 'minitest', '~> 5'
  s.add_development_dependency 'rack-test', '~> 0'
  s.add_development_dependency 'coveralls', '~> 0'
  s.add_development_dependency 'rake', '~> 10'
end