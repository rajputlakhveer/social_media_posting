Gem::Specification.new do |spec|
  spec.name          = 'social_media_posting_gem'
  spec.version       = "0.1.0"
  spec.authors       = ['Lakhveer Singh Rajput']
  spec.email         = ['rajputlakhveer@gmail.com']
  spec.summary       = %q{A gem for social media posting}
  spec.description   = %q{A gem for posting content to Facebook and Instagram}
  spec.homepage      = "https://github.com/yourusername/social_media_posting"
  spec.license       = "MIT"

  # Add dependencies
  spec.add_runtime_dependency 'httparty', '>= 0.18.1'
  spec.add_runtime_dependency 'nokogiri', '>= 1.12.5'

  # Specify the files that should be included in the gem when it is released.
  spec.files         = Dir["lib/**/*", "lib/**/*.rb"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Optional: Add development dependencies, test files, and other metadata.
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'rubocop', '>= 1.0'
end