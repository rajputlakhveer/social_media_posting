# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'httparty'

class SocialMediaPosting
  def post(image, content, publish_on)
    token = AccessToken.last.facebook_long_live_token
    response = exchange_page_token(token)
    if response['access_token'].present?
      publish_post(response['access_token'], image, content, publish_on)
    else
      check_validity(image, content)
    end
  end

  def check_validity(image, content)
    refresh_token = AccessToken.last.facebook_access_token
    long_live_token = exchange_token(refresh_token)
    AccessToken.last.update(facebook_long_live_token: long_live_token)
    page_access_token = exchange_page_token(long_live_token)
    publish_post(page_access_token['access_token'], image, content)
  end

  def exchange_token(token)
    url = URI.parse("#{ENV['FACEBOOK_URL']}/oauth/access_token")
    params = {
      grant_type: 'fb_exchange_token',
      client_id: ENV['FACEBOOK_CLIENT_ID'],
      client_secret: ENV['FACEBOOK_APP_SECRET'],
      fb_exchange_token: token
    }

    response = send_request(url, params)
    JSON.parse(response.body)['access_token']
  end

  def exchange_page_token(token)
    url = URI("#{ENV['FACEBOOK_URL']}/#{ENV['FACEBOOK_PAGE_ID']}?fields=access_token&access_token=#{token}")
    response = send_request(url)
    JSON.parse(response.body)
  end

  def publish_post(token, image, content, publish_on)
    publish_facebook_post(token, image, content) if publish_on == "facebook" || publish_on == "both"
    publish_instagram_post(token, image, content) if publish_on == "instagram" || publish_on == "both"
  end

  def publish_facebook_post(token, image, content)
    post_id = get_facebook_post_id(token, image, content)
    p "Post Published: ID: #{post_id}"
  end

  def get_facebook_post_id(token, image, content)
    url = URI("#{ENV['FACEBOOK_URL']}/#{ENV['FACEBOOK_PAGE_ID']}/photos")
    params = {
      access_token: token,
      url: image,
      message: content
    }
    response = send_request(url, params, 'POST')
    JSON.parse(response.body)['id']
  end

  def publish_instagram_post(token, image, content)
    insta_id = get_insta_id(token)
    container_id = get_container_id(token, image, content, insta_id)
    post_id = get_insta_post_id(token, insta_id, container_id)
    p "Post Published: ID: #{post_id}"
  end

  def get_insta_id(token)
    url = URI("#{ENV['FACEBOOK_URL']}/#{ENV['FACEBOOK_PAGE_ID']}/?access_token=#{token}&fields=connected_instagram_account")
    response = send_request(url, 'GET')
    JSON.parse(response.body)['connected_instagram_account']['id']
  end

  def get_container_id(token, image, content, insta_id)
    url = URI("#{ENV['FACEBOOK_URL']}/#{insta_id}/media")
    params = {
      access_token: token,
      image_url: image,
      caption: content
    }
    response = send_request(url, params, 'POST')
    JSON.parse(response.body)['id']
  end

  def get_insta_post_id(token, insta_id, container_id)
    url = URI("#{ENV['FACEBOOK_URL']}/#{insta_id}/media_publish")
    params = {
      access_token: token,
      creation_id: container_id
    }
    response = send_request(url, params, 'POST')
    JSON.parse(response.body)['id']
  end

  def send_request(url, params = {}, method = 'GET')
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    if method == 'POST'
      request = Net::HTTP::Post.new(url)
      request.set_form_data(params)
    else
      request = Net::HTTP::Get.new(url)
    end
    request['Cookie'] = ENV['FACEBOOK_COOKIE']

    https.request(request)
  end
end
