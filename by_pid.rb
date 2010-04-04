   require 'beancounter_utilities.rb'

      begin
         if ARGV.length>0
         arr = ARGV.uniq
         puts arr
            if arr.length > 0
               filename="profile"
               valscount = enhance_data(arr)
               str,str2=make_html_and_rdf(valscount)
               save(str,"#{filename}.html")
               save(str2,"#{filename}.rdf")
            end
         else
            puts "Usage: ruby by_pid.rb pid [pid] [pid] [...]"
            puts "e.g. ruby by_pid.rb p006h6qq"
         end
      end

