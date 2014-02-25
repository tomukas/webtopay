# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "webtopay/version"

Gem::Specification.new do |s|
  s.name        = "webtopay"
  s.version     = Webtopay::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Povilas Jurčys", "Laurynas Butkus", "Kristijonas Urbaitis"]
  s.email       = ["bloomrain@gmail.com", "laurynas.butkus@gmail.com", "kristis@micro.lt"]
  s.homepage    = "https://github.com/bloomrain/webtopay"
  s.summary     = %q{Provides integration with http://www.webtopay.com (mokejimai.lt) payment system}
  s.description = %q{Verifies webtopay.com (mokejimai.lt) payment data transfer}

  s.rubyforge_project = "webtopay"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rails"
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency "rspec-rails"
end

