# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/titlecase.rb'
require 'spec/rake/spectask'

Hoe.new('titleize', Titlecase::VERSION) do |p|
  p.developer("Grant Hollingworth", "grant@antiflux.org")
  p.remote_rdoc_dir = '' # Release to root
end

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

# vim: syntax=Ruby
