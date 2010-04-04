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

   m = ModelFactory.createDefaultModel()
   m.read("http://www.bbc.co.uk/programmes/b008s9l8.rdf")
   q = "Select * where {?a ?b ?c .}" 
   qexec = QueryExecutionFactory.create(q, m) ;
   res = qexec.execSelect()
   ResultSetFormatter.out(java.lang.System.out, res)
