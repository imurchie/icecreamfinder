Ice Cream Finder
================

A simple Ruby class using Google APIs in order to locate places selling Ice Cream in your area. 

Usage:

Create a file "api_key.rb" in which you have a module `APIKey`:

        ```ruby
        module APIKey
          def get_key
            # enter your Google API key
          end
        end
        ```

        ```ruby
        require "ice_cream_finder"
        
        location = "1600 Pennsylvania Ave NW, Washington, D.C."
        icf = IceCreamFinder.new(location)
        icf.find_ice_cream
        
        # or with a radius, in meters
        icf.find_ice_cream(10)
        ```

