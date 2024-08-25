class NaverLoginService
  def self.get_login_code(naver_id, naver_pw, naver_client_id, naver_redirect_uri, state)
    driver = initialize_selenium_driver
    navigate_to_login_page(driver)

    input_credentials(driver, naver_id, naver_pw)
    authenticate(driver)

    code = fetch_oauth_code(driver, naver_client_id, naver_redirect_uri, state)

    driver.quit
    code
  end

  def self.get_access_token(naver_client_id, naver_client_secret, naver_redirect_uri, code, state)
    response = request_access_token(naver_client_id, naver_client_secret, naver_redirect_uri, code, state)

    if response.code.to_i == 200
      token = extract_token_from_response(response)
      puts "Access Token: #{token}"
      token
    else
      handle_token_error(response)
    end
  end

  private
  def self.initialize_selenium_driver
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--disable-blink-features=AutomationControlled')
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')

    Selenium::WebDriver.for :chrome, options: options
  end

  def self.navigate_to_login_page(driver)
    driver.get('https://nid.naver.com/nidlogin.login')
  end

  def self.input_credentials(driver, naver_id, naver_pw)
    wait = Selenium::WebDriver::Wait.new(timeout: 60)

    wait.until { driver.find_element(name: 'id') }.tap do |id_input|
      driver.execute_script("arguments[0].value = '#{naver_id}'", id_input)
    end

    wait.until { driver.find_element(name: 'pw') }.tap do |pw_input|
      driver.execute_script("arguments[0].value = '#{naver_pw}'", pw_input)
    end
  end

  def self.authenticate(driver)
    wait = Selenium::WebDriver::Wait.new(timeout: 60)
    wait.until { driver.find_element(css: 'button#log\\.login') }.click
    sleep(2)
  end

  def self.fetch_oauth_code(driver, naver_client_id, naver_redirect_uri, state)
    req_url = build_oauth_request_url(naver_client_id, naver_redirect_uri, state)
    driver.get(req_url)

    wait = Selenium::WebDriver::Wait.new(timeout: 60)
    wait.until { driver.current_url.include?('code=') }

    extract_code_from_url(driver.current_url)
  end

  def self.build_oauth_request_url(client_id, redirect_uri, state)
    "https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=#{client_id}&redirect_uri=#{redirect_uri}&state=#{state}"
  end

  def self.extract_code_from_url(url)
    URI.parse(url).query.match(/code=([^&]*)/)[1]
  end

  def self.request_access_token(client_id, client_secret, redirect_uri, code, state)
    token_url = URI.parse('https://nid.naver.com/oauth2.0/token')
    params = {
      grant_type: 'authorization_code',
      client_id: client_id,
      client_secret: client_secret,
      redirect_uri: redirect_uri,
      code: code,
      state: state
    }

    http = Net::HTTP.new(token_url.host, token_url.port)
    http.use_ssl = (token_url.scheme == 'https')

    request = Net::HTTP::Post.new(token_url.request_uri)
    request.set_form_data(params)
    request['X-Naver-Client-Id'] = client_id
    request['X-Naver-Client-Secret'] = client_secret

    http.request(request)
  end

  def self.extract_token_from_response(response)
    JSON.parse(response.body)['access_token']
  end

  def self.handle_token_error(response)
    puts "Error Code: #{response.code}"
    nil
  end
end
