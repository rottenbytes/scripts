#!/usr/bin/env ruby
# 
# MongoDB basic check
# Author : Nicolas Szalay <nico@rottenbytes.info>


require 'getoptlong'
require 'mongo'

opts = GetoptLong.new(
    [ '--host', '-H', GetoptLong::REQUIRED_ARGUMENT],
    [ '--database', '-d', GetoptLong::REQUIRED_ARGUMENT]
)

mongohost="localhost"
mongodb="test"

opts.each do |opt, arg|
    case opt
        when '--host'
            mongohost = arg
        when '--database'
            mongodb = arg
    end
end


dbh=Mongo::Connection.new(mongohost).db(mongodb)
rslt=dbh.stats

if rslt["ok"] != 1.0
    puts("CRITICAL: Something is wrong with DB #{mongodb}")
    exit 2
else
    puts("OK: DB #{mongodb} is fine")
    exit 0
end
