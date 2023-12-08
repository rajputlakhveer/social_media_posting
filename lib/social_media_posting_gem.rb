# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'httparty'

class SocialMediaPosting

  def initialize(access_token, page_id)
    @access_token = access_token
    @page_id = page_id
  end

  def publish_post(image, content, publish_on)
    publish_facebook_post(@access_token, image, content) if publish_on == "facebook" || publish_on == "both"
    publish_instagram_post(@access_token, image, content) if publish_on == "instagram" || publish_on == "both"
  end

  def publish_facebook_post(token, image, content)
    post_id = get_facebook_post_id(token, image, content)
    p "Post Published: ID: #{post_id}"
  end

  def get_facebook_post_id(token, image, content)
    url = URI("https://graph.facebook.com/#{@page_id}/photos")
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
    url = URI("https://graph.facebook.com/#{@page_id}/?access_token=#{token}&fields=connected_instagram_account")
    response = send_request(url, 'GET')
    JSON.parse(response.body)['connected_instagram_account']['id']
  end

  def get_container_id(token, image, content, insta_id)
    url = URI("https://graph.facebook.com/#{insta_id}/media")
    params = {
      access_token: token,
      image_url: image,
      caption: content
    }
    response = send_request(url, params, 'POST')
    JSON.parse(response.body)['id']
  end

  def get_insta_post_id(token, insta_id, container_id)
    url = URI("https://graph.facebook.com/#{insta_id}/media_publish")
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
