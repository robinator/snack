Gem::Specification.new do |s|
  s.name        = 'snack'
  s.version     = '0.2.3'
  s.date        = '2013-09-13'
  s.summary     = 'A static website framework.'
  s.description = 'Snack is a small framework for building static websites.'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = '>= 1.3.6'

  s.author   = 'Rob Law'
  s.email    = 'rob@robmadethis.com'
  s.homepage = 'http://robmadethis.com/snack'
  s.license           = 'MIT'

  s.files              = Dir['{bin,lib,test}/**/*']
  s.executables        = %w[ snack ]

  s.add_dependency 'rack', '~> 0'
  s.add_dependency 'tilt', '~> 0'
  s.add_dependency 'coffee-script', '~> 0'
  s.add_development_dependency 'haml', '~> 2.2', '>= 2.2.11'
  s.add_development_dependency 'sass', '~> 0'
  s.add_development_dependency 'minitest', '~> 5'
  s.add_development_dependency 'rack-test', '~> 0'
  s.add_development_dependency 'coveralls', '~> 0'
  s.add_development_dependency 'rake', '~> 0'
end