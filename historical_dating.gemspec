require_relative 'lib/historical_dating/version'

Gem::Specification.new do |spec|
  spec.name          = "historical_dating"
  spec.version       = HistoricalDating::VERSION
  spec.authors       = ["Moritz Schepp"]
  spec.email         = ["moritz.schepp@gmail.com"]

  spec.summary       = "parse human historical datings"
  spec.description   = "parse human historical datings and convert them to Julian day ranges"
  spec.homepage      = "https://github.com/wendig-ou/historical-dating"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/wendig-ou/historical-dating"
  # spec.metadata["changelog_uri"] = "https://github.com/wendig-ou/historical-dating"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'parslet', '~> 1.8'
  spec.add_runtime_dependency 'activesupport', '>= 3.0.0'

  spec.add_development_dependency 'rspec', '~> 3.9.0'
  spec.add_development_dependency 'pry'
end
