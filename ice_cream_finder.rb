require 'addressable/uri'
require 'json'
require "rest-client"
require_relative "./server_api"


class IceCreamFinder
  include APIKey

  attr_reader :address, :latitude, :longitude

  def initialize(address)
    @address = address

    @latitude, @longitude = get_current_location
  end

  def get_current_location
    @base_uri = Addressable::URI.new(
      :scheme => "http",
      :host => "maps.googleapis.com",
      :path => "maps/api/geocode/json",
      :query_values => { :address => address, :sensor => false }
      ).to_s

    json = RestClient.get(@base_uri)
    location = JSON.parse(json)["results"].first["geometry"]["location"]

    lat = location["lat"]
    long = location["lng"]

    [lat, long]
  end

  def find_ice_cream
    # https://maps.googleapis.com/maps/api/place/nearbysearch/output?parameters
    uri = Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/place/nearbysearch/json",
    :query_values => { :key => get_key,
      :location => "#{latitude},#{longitude}",
      :rankby => :distance,
      :sensor => false
      }
    ).to_s

    puts uri
  end
end

icf = IceCreamFinder.new("1061 Market St, San Francisco CA")
icf.find_ice_cream