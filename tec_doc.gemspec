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

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

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
end
