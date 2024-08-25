require 'selenium-webdriver'
require 'dotenv/load'
require 'uri'
require 'net/http'
require 'json'

require_relative './service/naver_login_service.rb'
require_relative './service/naver_cafe_service.rb'
require_relative './service/content_provider.rb'

task :naver_cafe_post_creator => :environment do
  naver_id = ENV['NAVER_ID']
  naver_pw = ENV['NAVER_PW']
  naver_cafe_id = ENV['NAVER_CAFE_ID']
  naver_cafe_menu_id = ENV['NAVER_CAFE_MENU_ID']
  naver_cid = ENV['NAVER_CLIENT_ID']
  naver_csec = ENV['NAVER_CLIENT_SECRET']
  naver_redirect = ENV['NAVER_REDIRECT']
  state = "STATE"

  code = NaverLoginService.get_login_code(naver_id, naver_pw, naver_cid, naver_redirect, state)
  token = NaverLoginService.get_access_token(naver_cid, naver_csec, naver_redirect, code, state)
  NaverCafeService.create_post(token, naver_cafe_id, naver_cafe_menu_id)
end