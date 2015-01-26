require './lib/mina/version'

Gem::Specification.new do |s|
  s.name = "colorful-mina"
  s.version = Mina.version
  s.summary = %{Really fast deployer and server automation tool.}
  s.description = %Q{Really fast deployer and server automation tool.}
  s.authors = ["Rico Sta. Cruz", "Michael Galero", "Weverton Timoteo"]
  s.email = ["weverton.ct@gmail.com"]
  s.homepage = "http://github.com/wevtimoteo/colorful-mina"
  s.files = `git ls-files`.strip.split("\n")
  s.executables = Dir["bin/*"].map { |f| File.basename(f) }

  s.add_dependency "rake"
  s.add_dependency "open4", "~> 1.3.4"
  s.add_development_dependency "rspec", "~> 3.0.0"
end
