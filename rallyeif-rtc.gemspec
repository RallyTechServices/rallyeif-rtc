#
# Gemspec for 'rallyeif-rtc-x.x.x.gem'
#

$LOAD_PATH << File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
require 'rallyeif/rtc/version'

Gem::Specification.new do |spec|
  spec.name          = "rallyeif-rtc"
  spec.version       = RallyEIF::RTC::Version
  spec.authors       = ["Rally Software Development Corp"]
  spec.email         = ["technical-services@rallydev.com"]
  spec.description   = %q{RTC Spoke for EIF connectors}
  spec.summary       = %q{RTC spoke for use with Hub of EIF}
  spec.homepage      = "https://github.com/RallyTechServices/rallyeif-rtc"
  spec.license       = "MIT"

  all_files          = `git ls-files`.split($/)
  spec.executables   = all_files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.files         = []
  exclusions         = %w(spec test features coverage pkg .gitignore Rakefile)
  spec.files         = all_files.reject{|fn| fn =~ /^(#{exclusions.join("|")})/}
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rallyeif-wrk",       ">= 0.5.6"
  spec.add_runtime_dependency "xml-simple",         "= 1.1.2"
  spec.add_runtime_dependency "mime-types",         "= 2.0"

  spec.add_development_dependency "bundler",        "= 1.5.1"
  spec.add_development_dependency "rake",           "= 10.1.0"
  spec.add_development_dependency "rspec",          "= 2.14.0"

end
