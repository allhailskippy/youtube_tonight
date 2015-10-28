$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "userstamp/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "userstamp"
  s.version     = UserStamp::VERSION
  s.authors     = ["kineticsocial"]
  s.email       = ["appdev@kineticsocial.com"]
  s.homepage    = "http://www.kineticsocial.com/"
  s.summary     = "Cron Helper for File Locking"
  s.description = "This use to be in vendor plugins and has now been moved here to get rid of deprication warnings."

  s.files = Dir["{lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"

  s.add_development_dependency "sqlite3"
end
