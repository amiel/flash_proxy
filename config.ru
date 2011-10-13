require "rubygems"
require "bundler"
Bundler.setup
Bundler.require

$: << File.expand_path(File.dirname(__FILE__) + '/lib')
require 'request_logger'

use RequestLogger, 'log/request_logger.log'

run FlashProxy.new('log/requests.log', 'log/responses.log')