class NaverCafeService
  def self.create_post(token, naver_cafe_id, naver_cafe_menu_id)
    api_url = build_api_url(naver_cafe_id, naver_cafe_menu_id)
    header = "Bearer #{token}"

    response = send_post_request(api_url, header, prepare_post_data)

    handle_response(response)
  end

  private
  def self.build_api_url(naver_cafe_id, naver_cafe_menu_id)
    "https://openapi.naver.com/v1/cafe/#{naver_cafe_id}/menu/#{naver_cafe_menu_id}/articles"
  end

  def self.prepare_post_data
    URI.encode_www_form(
      subject: ContentProvider.get_subject,
      content: ContentProvider.get_content
    )
  end

  def self.send_post_request(url, header, body)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = header
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    request.body = body

    http.request(request)
  end

  def self.handle_response(response)
    if response.is_a?(Net::HTTPSuccess)
      puts response.body
    else
      puts "Error Code: #{response.code}"
      puts response.body
    end
  end
end