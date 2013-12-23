# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guard/entangle/version'

Gem::Specification.new do |spec|
  spec.name          = "guard-entangle"
  spec.version       = Guard::EntangleVersion::VERSION
  spec.authors       = ["Deshi Rahim"]
  spec.email         = ["deshi@deshiknaves.com"]
  spec.description   = %q{
This gem leverages Guard's watch ability to insert files inline within another file. When the parser incounters a //=path/to/file, it then gets the content of that file and then inserts the content replacing the comment. Optionally that file can then be passed through Uglifier. Files with no insertions will just be copied over.
}
  spec.summary       = %q{
Inserts file content inline into another document. Optionally uglifies the output.
}
  spec.homepage      = "http://rubygems.org/gems/guard-insert"
  spec.license       = "MIT"

  spec.files         = Dir.glob('{lib}/**/*') + %w[LICENSE README.md]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'guard',    '>= 2.1.1'
  spec.add_dependency 'uglifier', '>= 2.3.3'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
