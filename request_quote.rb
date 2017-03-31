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

pp = ParcelPerfect.new(email: ENV['EMAIL'], password: ENV['PASSWORD'])

puts 'Places by Postcode'
post_code_lookup = pp.places_by_postcode('6730')
puts 'Places by Name'
# binding.pry
name_lookup = pp.places_by_name('Johan')

quote_params = {
  details: {
    specinstruction: 'This is a test',
    reference: 'This is a test',

    origperadd1: 'Address line 1',
    origperadd2: 'Address line 2',
    origperadd3: 'Address line 3',
    origperadd4: 'Address line 4',
    origperphone: '012345678',
    origpercell: '012345678',

    origplace: post_code_lookup.first['place'],
    origtown: post_code_lookup.first['town'],
    origpers: 'TESTCUSTOMER',
    origpercontact: 'origcontactsname',
    origperpcode: '6730',

    destperadd1: 'Address line 1',
    destperadd2: 'Address line 2',
    destperadd3: 'Address line 3',
    destperadd4: 'Address line 4',
    destperphone: '012345678',
    destpercell: '012345678',

    destplace: name_lookup.first['place'],
    desttown: name_lookup.first['town'],
    destpers: 'TESTCUSTOMER',
    destpercontact: 'destcontactsname',
    destperpcode: '3340'
  },

  contents: [{
    item: 1,
    desc: 'this is a test',
    pieces: 1,
    dim1: 1,
    dim2: 1,
    dim3: 1,
    actmass: 1
  }, {
    item: 2,
    desc: 'ths is another test',
    pieces: 1,
    dim1: 1,
    dim2: 1,
    dim3: 1,
    actmass: 1
  }]
}

quote = pp.quote(quote_params)
ap quote

update_service_params = {
  quoteno: quote.first['quoteno'],
  service: quote.first['rates'].first['service']
}

updated_quote = pp.update_quote(update_service_params)

quote_to_waybill_params = {
  quoteno: updated_quote.first['quoteno'],
  specins: 'special instructions'
}

waybill = pp.quote_to_waybill(quote_to_waybill_params)
ap waybill
