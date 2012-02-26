# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "crowddirector/version"

Gem::Specification.new do |s|
  s.name        = "crowddirector"
  s.version     = CrowdDirector::VERSION
  s.authors     = ["Pete Fritchman"]
  s.email       = ["petef@databits.net"]
  s.homepage    = "https://github.com/fetep/ruby-crowddirector"
  s.summary     = "Scrapes 3Crowd's CrowdDirector dashboard"
  s.description = %q{
    Scrapes the 3Crowd CrowdDirector dashboard. Currently supports
    read-only access to network resources.
  }

  s.rubyforge_project = "crowddirector"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "mechanize"
  s.add_runtime_dependency "trollop"
end
