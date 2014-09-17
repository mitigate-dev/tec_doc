# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "tec_doc/version"

Gem::Specification.new do |s|
  s.name        = "tec_doc"
  s.version     = TecDoc::VERSION
  s.authors     = ["Edgars Beigarts"]
  s.email       = ["edgars.beigarts@makit.lv"]
  s.homepage    = ""
  s.summary     = %q{Ruby client for TecDoc}
  s.description = s.summary

  s.rubyforge_project = "tec_doc"

  s.files         = Dir.glob("lib/**/*") + %w(README.md LICENSE)
  s.test_files    = Dir.glob("spec/**/*")
  s.executables   = ["tec_doc"]
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 2.8"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "vcr", "~> 1.11.3"
  s.add_development_dependency "fakeweb", "~> 1.3.0"
  s.add_development_dependency "yard"
  s.add_development_dependency "redcarpet"

  s.add_runtime_dependency "savon", [">= 0.9.7", "< 2"]
  s.add_runtime_dependency "httpi", ">= 0.9.6"
  s.add_runtime_dependency "i18n"
end
