require 'addressable/uri'
require 'json'
require "rest-client"
require_relative "./api_key"
require 'nokogiri'


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

  def find_ice_cream(radius = 1000)
    # https://maps.googleapis.com/maps/api/place/nearbysearch/output?parameters
    uri = Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/place/nearbysearch/json",
    :query_values => { :key => get_key,
      :location => "#{latitude},#{longitude}",
      :radius => radius,
      :sensor => false,
      :keyword => "ice cream"
      }
    ).to_s

    json = RestClient.get(uri)
    location = JSON.parse(json)

    results = location["results"]
    prints_results(results)
  end

  def prints_results(results)
    results.each do |result|
      puts result["name"]
      location = result["geometry"]["location"]
      get_directions(location["lat"],location["lng"])
    end
  end

  def get_directions(lat, long)
    uri = Addressable::URI.new(
    :scheme => "http",
    :host => "maps.googleapis.com",
    :path => "maps/api/directions/json",
    :query_values => { :origin => "#{latitude},#{longitude}",
                       :destination => "#{lat},#{long}",
                       :sensor => false,
                       :mode => :walking
                     }
    ).to_s

    json = RestClient.get(uri)
    results = JSON.parse(json)

    if results["status"] == "OK"
      prints_directions(results["routes"])
    else
      puts results["status"]
    end
  end

  def prints_directions(routes)
    routes.each_with_index do |route, index|
      puts "Route #{index + 1}"
      route["legs"].each_with_index do |leg, index|
        puts "  Leg #{index + 1}"

        leg["steps"].each_with_index do |step, index|
          puts "    Step #{index + 1}"
          parsed_html = Nokogiri::HTML(step["html_instructions"])
          puts "      #{parsed_html.text}"
        end
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  print "Enter current location: "
  location = gets.chomp
  icf = IceCreamFinder.new(location)
  icf.find_ice_cream
end
