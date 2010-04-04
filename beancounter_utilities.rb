   require 'java'
   require 'date'
   require 'uri'
   require 'open-uri'
   require 'net/http'
   require 'rubygems'
   require 'json/pure'
   require 'pp'

   Dir.glob("Jena-2.6.2/lib/*.jar") { |jar| require jar }

   java_import "com.hp.hpl.jena.rdf.model.Model"
   java_import "com.hp.hpl.jena.rdf.model.ModelFactory"

   java_import "com.hp.hpl.jena.util.FileManager"
   java_import "com.hp.hpl.jena.query.QueryExecution"
   java_import "com.hp.hpl.jena.query.QueryExecutionFactory"
   java_import "com.hp.hpl.jena.query.ResultSetFormatter"

      def use_store()
         return false;
      end

# Takes the urls from the enhancement, gets labels and types for them, 
# and generates some html and RDF

      def make_html_and_rdf(valscount)
         puts "Making RDF and html"

         types = {}
         labels = {}
         types_urls = {}
         puts "\nFound #{valscount.length} URLs"

         if (use_store())
            require 'lib/four_store/store'
            store = FourStore::Store.new 'http://dbtune.org/bbc/programmes/sparql/'
            valscount.each_key do |url|
               q = "SELECT distinct ?label ?type WHERE { <#{url}> <http://www.w3.org/2000/01/rdf-schema#label> ?label .}"
               q2 = "SELECT distinct ?label ?type WHERE {<#{url}> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?type .}"
               puts "Enhancing #{url}\n\n#{q}\n#{q2}\n"
               response = store.select(q)
               sleep 2
               response2 = store.select(q2)
               sleep 2
# Get types
               response2.each do |r|
                  ty = r["type"]
                  types[url] = ty
                  if(types_urls[ty]==nil)
                     arr = Array.new
                     arr.push(url)
                     types_urls[ty]=arr
                  else
                     arr = types_urls[ty]
                     arr.push(url)
                  end
               end
# Get labels
               
               response.each do |r|
                  label = r["label"]
                  labels[url] = label
               end
            end

         else
            valscount.each_key do |url|
               puts "valscount url is  #{url}"
#serivces are problematic in the url retrival case so we bypass them

               if url.match("service")
                  label = url.gsub(/\#.*/,"")
                  label = label.gsub(/http:\/\/www\.bbc\.co\.uk\//,"")
                  ty = "http://purl.org/ontology/po/Service"
                  types[url]=ty
                  labels[url]=label

                  if(types_urls[ty]==nil)
                     arr = Array.new
                     arr.push(url)
                     types_urls[ty]=arr
                  else
                     arr = types_urls[ty]
                     arr.push(url)
                  end

               else
                  uu = url.gsub(/\#.*$/,".rdf")

                  m = ModelFactory.createDefaultModel()
                  m.read(uu)

                  q = "SELECT distinct ?label WHERE { <#{url}> <http://purl.org/dc/elements/1.1/title> ?label .}"

                  q2 = "SELECT distinct ?type WHERE {<#{url}> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?type .}"
                  qexec = QueryExecutionFactory.create(q, m) ;
                  qexec2 = QueryExecutionFactory.create(q2, m) ;
                  response = qexec.execSelect()
                  response2 = qexec2.execSelect()
#                 ResultSetFormatter.out(java.lang.System.out, response)
#                 ResultSetFormatter.out(java.lang.System.out, response2)

# Get types

                  response2.each do |r|
                     ty = r.get("type").to_s
                     types[url] = ty
                     if(types_urls[ty]==nil)
                        arr = Array.new
                        arr.push(url)
                        types_urls[ty]=arr
                     else
                        arr = types_urls[ty]
                        arr.push(url)
                     end
                  end

# Get labels
               
                  response.each do |r|
                     label = r.get("label").to_s
                     labels[url] = label
                  end

               end
            end
         end

#        pp valscount

# Make the html
               
         cc = 0
         str = "<html><body>"
                  
         types_urls.each_key do |t|
            str = str + "<h3>" + t + "</h3>\n<p>"
            u = types_urls[t]
            u.each do |uu|
              label = labels[uu]  
              c = valscount[uu]
              cc = cc + c
              str = "#{str} <a href='#{uu}'>#{label}</a>: #{c} <br />\n"
            end

            str = str + "</p>\n"
            
         end

         str = str + "</body></html>"
         
# Now the rdf
                  
         topstr = "<rdf:RDF
xmlns:owl=\"http://www.w3.org/2002/07/owl#\"
xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
xmlns:foaf=\"http://xmlns.com/foaf/0.1/\"
xmlns:wi=\"http://xmlns.notu.be/wi#\"
xmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"
xmlns:tl=\"http://perl.org/NET/c4dm/timeline.owl#\"
xmlns:days=\"http://ontologi.es/days#\"
xmlns:po=\"http://purl.org/ontology/po/\"
xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"
>           
<foaf:Person>
"
         endstr = "
</foaf:Person>
<wi:Context rdf:about=\"#default\">
<wi:timePeriod>   
 <days:DayInterval> <!-- i.e. every day, all day -->
  <tl:at rdf:datatype=\"http://www.w3.org/2001/XMLSchema#time\">00:00:00</tl:at>
  <tl:end rdf:datatype=\"http://www.w3.org/2001/XMLSchema#time\">23:59:59</tl:end>
 </days:DayInterval>
</wi:timePeriod>
</wi:Context>
</rdf:RDF>
"
         totalnums = cc.to_f
         str2 = topstr
            
         valscount.each_key do |u|
            t = types[u]
            label = labels[u]
            label.gsub!("&","and")
            c = valscount[u].to_f  
            weight = c
            puts "weight is #{c} #{totalnums}"
            tmpl =
"
<wi:preference>
  <wi:WeightedInterest>
    <wi:topic rdf:resource=\"#{u}\" />
    <rdf:type rdf:resource=\"#{t}\"/>
    <rdfs:label>#{label}</rdfs:label>
    <wi:weight>#{weight}</wi:weight>
    <wi:scale>0..#{cc}</wi:scale>
    <wi:reason>You watched #{weight} of a total of #{cc} items in topic #{label}</wi:reason>
    <wi:context rdf:resource=\"#default\" />
  </wi:WeightedInterest>
</wi:preference>
"
            str2 = str2 + tmpl     
         end
         str2 = str2 + endstr
         return str,str2
      end


# This uses the programmes RDF to find interesting information about 
# a programme Channel, category, Series / Brand (this also covers 
# people)
# could also use the endpoint

      def enhance_data(arr)
            puts "Enhancing data"
            valscount = {}

####
            if (use_store())
               require 'lib/four_store/store'
               store = FourStore::Store.new 'http://dbtune.org/bbc/programmes/sparql/'


               arr.each do |pid|

                  q = "SELECT ?vals WHERE
{{<http://www.bbc.co.uk/programmes/#{pid}#programme>
<http://purl.org/ontology/po/masterbrand> ?vals .} UNION
{<http://www.bbc.co.uk/programmes/#{pid}#programme>
<http://purl.org/ontology/po/category> ?vals . } UNION {?vals
<http://purl.org/ontology/po/episode>
<http://www.bbc.co.uk/programmes/#{pid}#programme> . }}"

                  puts "Making query for #{pid}\n#{q}"
                  response = store.select(q)

                  response.each do |r|
                     url = r["vals"]
                     if(valscount[url]==nil)
                        valscount[url]=1
                     else
                        count = valscount[url]
                        count = count+1
                        valscount[url]=count
                     end
                  end
                  sleep 2
               end
            else
#not store
               arr.each do |pid|

                  url = "http://www.bbc.co.uk/programmes/#{pid}.rdf"
                  puts "pid url is  #{url}"
                  m = ModelFactory.createDefaultModel()
                  m.read(url)
    
                  q = "SELECT ?vals WHERE
{{<http://www.bbc.co.uk/programmes/#{pid}#programme>
<http://purl.org/ontology/po/masterbrand> ?vals .} UNION
{<http://www.bbc.co.uk/programmes/#{pid}#programme>
<http://purl.org/ontology/po/category> ?vals . } UNION {?vals
<http://purl.org/ontology/po/episode>
<http://www.bbc.co.uk/programmes/#{pid}#programme> . }}"
                  puts "Making query for #{pid}\n#{q}"

                  qexec = QueryExecutionFactory.create(q, m) ;
                  response = qexec.execSelect()
#                 ResultSetFormatter.out(java.lang.System.out, response)
                  response.each do |r|
                     url = r.get("vals").to_s
                     puts "got result #{url}"
                     if(valscount[url]==nil)
                        valscount[url]=1
                     else
                        count = valscount[url]
                        count = count+1
                        valscount[url]=count
                     end
                  end
                  sleep 2
               end

            end
            pp valscount
####
            return valscount
     end

               
# Saving file utility
               
      def save(data, filename)   
            puts "Saving to #{filename}" 
            open(filename, 'w') { |f|
              f.puts data
              f.close
            }
      end
                     
                  
# Get url (assumed to be json) and returns the parsed json
               
      def get_json_url(url) 
              useragent = "NotubeMiniCrawler/0.1"
              u =  URI.parse url

              req = Net::HTTP::Get.new(u.request_uri,{'User-Agent' => useragent})

              begin

                res = Net::HTTP.new(u.host, u.port).start {|http|http.request(req) }

              end
              j = nil
              begin
                 j = JSON.parse(res.body)
              rescue OpenURI::HTTPError=>e
                case e.to_s
                    when /^404/
                       raise 'Not Found'
                    when /^304/
                       raise 'No Info'
                    end
              end
              return j
      end



      def get_url(url)
              useragent = "NotubeMiniCrawler/0.1"
              u =  URI.parse url
              req = Net::HTTP::Get.new(u.request_uri,{'User-Agent' => useragent})

              begin          

                res = Net::HTTP.new(u.host, u.port).start {|http|http.request(req) }

              end
              j = nil
              begin
                 j = res.body
              rescue OpenURI::HTTPError=>e
                 case e.to_s
                    when /^404/
                       raise 'Not Found'
                    when /^304/
                       raise 'No Info'
                    end
              end
              return j
      end

