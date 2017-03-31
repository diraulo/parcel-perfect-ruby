require 'dotenv/load'

require 'httparty'
require 'pry'
require 'pry-byebug'
require 'yajl'
require 'awesome_print'
require 'digest/md5'

class ParcelPerfect
  include HTTParty
  base_uri 'http://adpdemo.pperfect.com/ecomService/v7/Json/'

  def initialize(opts = {})
    @auth = {
      email:    opts[:email],
      password: opts[:password]
    }

    request_token
  end

  def places_by_postcode(postcode)
    query_params('Quote', 'getPlacesByPostcode', postcode: postcode)

    execute_query
    @response['results']
  end

  def places_by_name(name)
    query_params('Quote', 'getPlacesByName', name: name)

    execute_query
    @response['results']
  end

  def quote(params = {})
    query_params('Quote', 'requestQuote', params)

    execute_query
    @response['results']
  end

  def update_quote(params = {})
    query_params('Quote', 'updateService', params)

    execute_query
    @response['results']
  end

  def quote_to_waybill(params = {})
    query_params('Quote', 'quoteToWaybill', params)

    execute_query
    @response['results']
  end

  private

  def salt
    query_params('Auth', 'getSalt', email: @auth[:email])

    execute_query
    @response['results'].first['salt']
  end

  def request_token
    @auth[:password] = Digest::MD5.hexdigest(@auth[:password] + salt)
    query_params('Auth', 'getSecureToken', @auth)

    execute_query
    @token ||= @response['results'].first['token_id']
  end

  def execute_query
    response = self.class.get('', query: @options)
    @response = Yajl::Parser.parse(response.to_s)

    raise @response['errormessage'] if @response['errorcode'] == 1
  end

  def query_params(request_class, method, params = {})
    @options = {
      params: Yajl::Encoder.encode(params),
      method: method,
      class:  request_class
    }

    @options[:token_id] = @token if @token
  end
end
