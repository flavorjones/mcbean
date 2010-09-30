# -*- ruby -*-

require 'rubygems'
gem 'hoe', '>= 2.5.0'
require 'hoe'

Hoe.plugin :git
Hoe.plugin :gemspec
Hoe.plugin :bundler

Hoe.spec 'mcbean' do
  developer "Mike Dalessio", "mike.dalessio@gmail.com"

  self.extra_rdoc_files = FileList["*.rdoc"]
  self.history_file     = "CHANGELOG.rdoc"
  self.readme_file      = "README.rdoc"

  self.extra_deps << ["loofah", ">= 0.4.7"]
  self.extra_deps << ["rdiscount", ">= 1.6.0"]
  self.extra_deps << ["RedCloth", ">= 4.2.0"]
  self.extra_dev_deps << ["minitest", ">= 1.6.0"]
  self.extra_dev_deps << ["hoe-git"]
  self.extra_dev_deps << ["hoe-gemspec"]
  self.extra_dev_deps << ["hoe-bundler"]

  self.testlib = :minitest
end

task :redocs => :fix_css
task :docs => :fix_css
task :fix_css do
  better_css = <<-EOT
    .method-description pre {
      margin                    : 1em 0 ;
    }

    .method-description ul {
      padding                   : .5em 0 .5em 2em ;
    }

    .method-description p {
      margin-top                : .5em ;
    }

    h2 + ul {
      margin-top                : 1em;
    }
  EOT
  puts "* fixing css"
  File.open("doc/rdoc.css", "a") { |f| f.write better_css }
end

# vim: syntax=ruby
