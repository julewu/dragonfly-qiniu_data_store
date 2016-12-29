# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dragonfly/qiniu_data_store/version'

Gem::Specification.new do |spec|
  spec.name          = "dragonfly-qiniu_data_store"
  spec.version       = Dragonfly::QiniuDataStore::VERSION
  spec.authors       = ["Bin Li"]
  spec.email         = ["holysoros@gmail.com"]
  spec.description   = %q{Qiniu data store for Dragonfly}
  spec.summary       = %q{Data store for storing Dragonfly content (e.g. images) on Qiniu}
  spec.homepage      = "https://github.com/holysoros/dragonfly-qiniu_data_store"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "dragonfly", "~> 1.0"
  spec.add_runtime_dependency "qiniu", "~> 6.8"
  spec.add_development_dependency "rspec", "~> 2.0"

  spec.post_install_message = <<-POST_INSTALL_MESSAGE
=====================================================
Thanks for installing dragonfly-qiniu_data_store!!
=====================================================
POST_INSTALL_MESSAGE
end
