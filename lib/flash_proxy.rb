require 'rack-proxy'

require 'logger'

class FlashProxy < Rack::Proxy

  def initialize(request_log_filename, response_log_filename)
    @request_log_filename, @response_log_filename = request_log_filename, response_log_filename
    @request_log = Logger.new(request_log_filename)
    @response_log = Logger.new(response_log_filename)
    formatter = proc { |severity, datetime, progname, msg|
      "#{datetime}: #{msg}\n"
    }
    @response_log.formatter = formatter
    @request_log.formatter = formatter
  end



  def call(env)
    if '/crossdomain.xml' == env["PATH_INFO"]
      [
        200,
        { 'Content-Type' => 'text/xml' },
        [%q(<?xml version="1.0"?><!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd"><cross-domain-policy><allow-access-from domain="*" secure="false" /></cross-domain-policy>)]
      ]
    else
      super
    end
  end

  def rewrite_env(env)
    log_request("pre env", env)

    rewrite_host(env)
    enable_ssl(env)

    log_request("post env", env)

    # binding.pry

    env
  end

  def rewrite_response(triplet)
    status, headers, body = triplet

    log_response([status, headers, body])

    triplet
  end


private
  def rewrite_host(env)
    host = env['HTTP_HOST']

    host.gsub! /\.dev(:\d+)?/, '.com'

    env['SERVER_PORT'] = '80'
    env['SERVER_NAME'] = host
    env['HTTP_HOST'] = host
  end

  def enable_ssl(env)
    # TODO: Some sort of header or switch to turn this on
    env['HTTPS'] = 'on'
    env['rack.url_scheme'] = 'https'
    env['SERVER_PORT'] = '443'
  end


  def log_request(msg, env)
    @request_log.info("#{ msg } -- #{ env["REQUEST_METHOD"] } #{ env["PATH_INFO"] } for: #{ env["HTTP_HOST"] }")
  end

  def log_response(triplet)
    @response_log.info(triplet.inspect)
  end
end