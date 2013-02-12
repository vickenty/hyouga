# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hyouga/version', __FILE__)

Gem::Specification.new do |gem|
	gem.authors       = ["Vickenty Fesunov"]
	gem.email         = ["kent@setattr.net"]
	gem.description   = <<-EOF
		Hyouga is a command-line tool to access Amazon Glacier storage.
	EOF

	gem.summary       = "Command-line tool to access AWS Glacier."
	gem.homepage      = "http://gitub.com/vickenty/hyouga"

	gem.files         = `git ls-files`.split($\)
	gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
	gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
	gem.name          = "hyouga"
	gem.require_paths = ["lib"]
	gem.version       = Hyouga::VERSION
end

