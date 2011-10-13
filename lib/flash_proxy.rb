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


  def rewrite_env(env)
    rewrite_host(env)
    enable_ssl(env)

    log_request(env)

    env
  end

  def rewrite_response(triplet)
    status, headers, body = triplet

    log_response(triplet)

    triplet
  end


private
  def rewrite_host(env)
    host = env['HTTP_HOST']

    host.gsub! /\.dev/, '.com'

    env['HTTP_HOST'] = host
  end

  def enable_ssl(env)
    # TODO: Some sort of header or switch to turn this on
    env['HTTPS'] = 'on'
  end


  def log_request(env)
    @request_log.info("#{ env["REQUEST_METHOD"] } #{ env["PATH_INFO"] } routed to: #{ env["HTTP_HOST"] }")
  end

  def log_response(triplet)
    @response_log.info(triplet.inspect)
  end
end