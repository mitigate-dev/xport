# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'xport'
  s.version = '1.0.0'
  s.authors = ['Janis Vitols']
  s.summary = 'CSV/Excel exports with own DSL and background jobs'

  s.files = Dir['{lib}/**/*']

  s.add_dependency 'activesupport'

  s.add_development_dependency 'bundler', "~> 1.5"
  s.add_development_dependency 'rake', '~> 10.1'
  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'simplecov', '~> 0.8'

  s.add_development_dependency 'axlsx'
  s.add_development_dependency 'saxlsx'
end
