   require 'date'
   require 'webrick' 
   require 'webrick/accesslog'
   include WEBrick
   require 'uri'
   require 'open-uri'
   require 'net/http'
   require 'rubygems'
   require 'json/pure' 
#   require 'hpricot'
#   require 'lib/four_store/store'
   require 'beancounter_utilities.rb'

# Make a list of twitter urls
      
      def get_twitter_urls(twittername, max)
            urls = Array.new  
            urls.push("http://twitter.com/statuses/user_timeline/#{twittername}.json")
            urls.push("http://twitter.com/statuses/user_timeline/#{twittername}.json")
   
            (2..max).each do |x|
              url = "http://twitter.com/statuses/user_timeline/#{twittername}.json?page=#{x}"
              urls.push(url)
            end
            return urls
      end
   
   
# Given an array of twitter json urls, get them and find the pids

      def parse_PIDs(urls)
              arr = Array.new
              urls.each do |u|
                sleep 10
                puts "Getting url #{u}"
                puts "Getting url #{u}"
                data = get_json_url(u)
                data.each do |d|
                  text = d["text"]
                  b = text.match(/\/([b-df-hj-np-tv-z][0-9b-df-hj-np-tv-z]{7,15})/)
                  print "." 
                  if b!=nil
                    arr.push(b[1])
                    puts "Adding PID #{b[1]}"
                  end
                end
              end
              return arr
      end
   
   
# run it

      begin
         if (ARGV[0])
           twittername = ARGV[0]
           filename = "profile"
           urls = get_twitter_urls(twittername,9)
           puts urls.length
           pids = parse_PIDs(urls)
           pids = pids.uniq
           if pids.length > 0
             valscount = enhance_data(pids)
             str,str2=make_html_and_rdf(valscount)
             save(str,"#{filename}.html")
             save(str2,"#{filename}.rdf")
           end
         else
           puts "This gets the last 200 tweets from twittername specified, looks for pids, enhances the data and returns a profile"
           puts "Usage jruby twitter-mini-beancounter.rb twittername"
         end
      end
