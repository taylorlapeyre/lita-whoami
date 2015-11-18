Gem::Specification.new do |spec|
  spec.name          = "lita-whoami"
  spec.version       = "0.1.1"
  spec.authors       = ["Taylor Lapeyre"]
  spec.email         = ["taylorlapeyre@gmail.com"]
  spec.description   = "Allows you to tell Lita who people are."
  spec.summary       = "Allows you to tell Lita who people are."
  spec.homepage      = "http://github.com/taylorlapeyre/lita-whoami"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.6"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
