require 'sinatra'
require File.join(File.dirname(__FILE__), 'webrick_patch')

class Basic < Sinatra::Base
  set :environment, :production
  enable :dump_errors

  get('/content-length/:value') do |value|
    headers("Custom" => "Foo: bar")
    'x' * value.to_i
  end

  post('/body-sink') do
    request.body.read.size.to_s
  end

  post('/echo') do
    echo
  end

  put('/echo') do
    echo
  end

  get('/echo dirty') do
    echo
  end

  private

  def echo
    request.body.read
  end

end
