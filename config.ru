require "rubygems"
require "bundler"
Bundler.setup
Bundler.require

$: << File.expand_path(File.dirname(__FILE__) + '/lib')
require 'flash_proxy'

run FlashProxy.new('log/requests.log', 'log/responses.log')