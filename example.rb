require_relative 'parcel_perfect'

pp = ParcelPerfect.new(email: ENV['EMAIL'], password: ENV['PASSWORD'])

puts 'Get places by Postcode'
post_code_lookup = pp.places_by_postcode('6730')
ap post_code_lookup

puts 'Get places by Name'
name_lookup = pp.places_by_name('Johan')
ap name_lookup

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
ap updated_quote

quote_to_waybill_params = {
  quoteno: updated_quote.first['quoteno'],
  specins: 'special instructions'
}

waybill = pp.quote_to_waybill(quote_to_waybill_params)
ap waybill
