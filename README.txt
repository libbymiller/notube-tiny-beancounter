These utilities generate html and rdf weighted interest profiles from 
BBC programmes data using a SPARQL endpoint. It can take some minutes to run.

Files:

* beancounter_utilities.rb - enhancement, saving and other utilities, 
using a sparql endpoint
* by_pid.rb - uses beancounter_utilities.rb to generate a profile from a 
list of BBC pids (e.g. p006h6rl)
* twitter_mini_beancounter.rb - uses beancounter_utilities.rb to 
generate a profile using the last 200 public tweets of a specified 
username

It uses either Jruby and Jena or a ruby and a 4store instance. See 
INSTALL.txt for installation.

