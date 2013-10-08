require 'addressable/uri'
require 'json'
require "rest-client"
require_relative "./server_api"


class IceCreamFinder
  include APIKey

  attr_reader :latitude, :longitude

  def initialize(address)
    @base_uri = Addressable::URI.new(
      :scheme => "http",
      :host => "maps.googleapis.com",
      :path => "maps/api/geocode/json",
      :query_values => { :address => address, :sensor => false }
      ).to_s
  end

  def get_current_location
    json = RestClient.get(@base_uri)
    @latitude, @longitude = get_location(JSON.parse(json))

    self
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


  private
    def get_location(json)
      location = json["results"].first["geometry"]["location"]

      lat = location["lat"]
      long = location["lng"]

      [lat, long]
    end
end

icf = IceCreamFinder.new("1061 Market St, San Francisco CA")
icf.get_current_location.find_ice_cream