# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mcbean}
  s.version = "0.3.0.20100929225458"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Dalessio"]
  s.date = %q{2010-09-29}
  s.default_executable = %q{mcbean}
  s.description = %q{McBean can convert documents from one format to another. McBean currently supports:

* HTML
* Markdown (a subset)
* Textile (a subset)

with the help of Loofah, Nokogiri, RDiscount and RedCloth.

"You can't teach a Sneetch." -- Sylvester McMonkey McBean}
  s.email = ["mike.dalessio@gmail.com"]
  s.executables = ["mcbean"]
  s.extra_rdoc_files = ["Manifest.txt", "CHANGELOG.rdoc", "README.rdoc"]
  s.files = [".autotest", "CHANGELOG.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "bin/mcbean", "lib/mcbean.rb", "lib/mcbean/markdown.rb", "lib/mcbean/textile.rb", "test/helper.rb", "test/test_markdown.rb", "test/test_mcbean.rb", "test/test_textile.rb", "test/test_wiki.rb"]
  s.homepage = %q{http://github.com/flavorjones/mcbean}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mcbean}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{McBean can convert documents from one format to another}
  s.test_files = ["test/test_wiki.rb", "test/test_markdown.rb", "test/test_mcbean.rb", "test/test_textile.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<loofah>, [">= 0.4.7"])
      s.add_runtime_dependency(%q<rdiscount>, [">= 1.6.0"])
      s.add_runtime_dependency(%q<RedCloth>, [">= 4.2.0"])
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<minitest>, [">= 1.6.0"])
      s.add_development_dependency(%q<hoe-git>, [">= 0"])
      s.add_development_dependency(%q<hoe-gemspec>, [">= 0"])
      s.add_development_dependency(%q<hoe-bundler>, [">= 0"])
      s.add_development_dependency(%q<hoe>, [">= 2.6.1"])
    else
      s.add_dependency(%q<loofah>, [">= 0.4.7"])
      s.add_dependency(%q<rdiscount>, [">= 1.6.0"])
      s.add_dependency(%q<RedCloth>, [">= 4.2.0"])
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<minitest>, [">= 1.6.0"])
      s.add_dependency(%q<hoe-git>, [">= 0"])
      s.add_dependency(%q<hoe-gemspec>, [">= 0"])
      s.add_dependency(%q<hoe-bundler>, [">= 0"])
      s.add_dependency(%q<hoe>, [">= 2.6.1"])
    end
  else
    s.add_dependency(%q<loofah>, [">= 0.4.7"])
    s.add_dependency(%q<rdiscount>, [">= 1.6.0"])
    s.add_dependency(%q<RedCloth>, [">= 4.2.0"])
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<minitest>, [">= 1.6.0"])
    s.add_dependency(%q<hoe-git>, [">= 0"])
    s.add_dependency(%q<hoe-gemspec>, [">= 0"])
    s.add_dependency(%q<hoe-bundler>, [">= 0"])
    s.add_dependency(%q<hoe>, [">= 2.6.1"])
  end
end
