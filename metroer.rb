require 'rubygems'
require 'json'
require 'net/http'
require 'cgi'
require 'yaml'
require 'fastercsv'
require 'httparty'
require 'pathname'
require 'uri'
require 'csv'


def read_config
	config = YAML.load_file("config.yaml")
	@username = config["config"]["username"]
	@password = config["config"]["password"]
	@inputfile = config["config"]["inputfilename"]
	@outputfile = config["config"]["filename"]
	@overlayid = config["config"]["overlayid"]
end

def parse_venues(path)
  FasterCSV.read(path)
end

def http_get(domain,path,params)
  return Net::HTTP.get(domain, "#{path}?".concat(params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&'))) if not params.nil?
  return Net::HTTP.get(domain, path)
end

def get_venue_info(venues)
  venue_responses = []
  venues.each {|venue|
      venue_responses <<  http_get("api.foursquare.com", "/v1/venue.json", {:vid => venue[1]})
  }
 venue_responses
end



def parse_locations(venues)
  outputfile = File.open(@outputfile,"wb")
    CSV::Writer.generate(outputfile) do |csv|  
   csv << ["id","name", "latitude","longitude", "peoplehere","checkins"]
    venues.each{ |venue|
      parsed_venue = JSON.parse(venue)["venue"]
       csv << [parsed_venue["id"],parsed_venue["name"],parsed_venue["geolat"],parsed_venue["geolong"],parsed_venue["stats"]["herenow"],parsed_venue["stats"]["checkins"]]
      
     }
    
  
  end
  outputfile.close
end




venues = parse_venues(@inputfile)
venue_responses = get_venue_info(venues)
parse_locations(venue_responses)
#url = URI.parse('http://geocommons.com/overlays/' + @overlayid )
#req = Net::HTTP::Get.new url.path
##req.basic_auth @username, @password
#res = Net::HTTP.new(url.host, url.port).start { |http| http.request(req) }



