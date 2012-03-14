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
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "vcr"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "yard"
  s.add_development_dependency "redcarpet"

  s.add_development_dependency "guard"
  s.add_development_dependency "rb-inotify"
  s.add_development_dependency "rb-fsevent"
  s.add_development_dependency "rb-fchange"
  s.add_development_dependency "growl"
  s.add_development_dependency "libnotify"
  s.add_development_dependency "guard-rspec"

  s.add_runtime_dependency "savon"
  s.add_runtime_dependency "httpi", ">= 0.9.6"
  s.add_runtime_dependency "i18n"
end
