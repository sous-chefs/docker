Shindo.tests('HTTPStatusError request/response debugging') do

  tests('new raises errors for bad URIs').returns(true) do
    begin
      Excon.new('foo')
      false
    rescue => err
      err.to_s.include? 'foo'
    end
  end

  with_server('error') do

    tests('message does not include response or response info').returns(true) do
      begin
        Excon.get('http://127.0.0.1:9292/error/not_found', :expects => 200)
      rescue Excon::Errors::HTTPStatusError => err
        err.message.include?('Expected(200) <=> Actual(404 Not Found)') &&
          !err.message.include?('excon.error.request') &&
          !err.message.include?('excon.error.response')
      end
    end

    tests('message includes only request info').returns(true) do
      begin
        Excon.get('http://127.0.0.1:9292/error/not_found', :expects => 200,
                  :debug_request => true)
      rescue Excon::Errors::HTTPStatusError => err
        err.message.include?('Expected(200) <=> Actual(404 Not Found)') &&
          err.message.include?('excon.error.request') &&
          !err.message.include?('excon.error.response')
      end
    end

    tests('message includes only response info').returns(true) do
      begin
        Excon.get('http://127.0.0.1:9292/error/not_found', :expects => 200,
                  :debug_response => true)
      rescue Excon::Errors::HTTPStatusError => err
        err.message.include?('Expected(200) <=> Actual(404 Not Found)') &&
          !err.message.include?('excon.error.request') &&
          err.message.include?('excon.error.response')
      end
    end

    tests('message include request and response info').returns(true) do
      begin
        Excon.get('http://127.0.0.1:9292/error/not_found', :expects => 200,
                  :debug_request => true, :debug_response => true)
      rescue Excon::Errors::HTTPStatusError => err
        err.message.include?('Expected(200) <=> Actual(404 Not Found)') &&
          err.message.include?('excon.error.request') &&
          err.message.include?('excon.error.response')
      end
    end

  end
end
