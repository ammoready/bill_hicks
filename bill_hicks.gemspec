# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bill_hicks/version'

Gem::Specification.new do |spec|
  spec.name          = "bill_hicks"
  spec.version       = BillHicks::VERSION
  spec.authors       = ["Dale Campbell"]
  spec.email         = ["oshuma@gmail.com"]

  spec.summary       = %q{Ruby library for Bill Hicks ERP system}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency  "smarter_csv", "~> 1.1.4"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 11.3"
  spec.add_development_dependency "rspec", "~> 3.5"
end
