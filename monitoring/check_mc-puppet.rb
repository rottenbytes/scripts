#!/usr/bin/env ruby
#
# Checks your puppetd runs freshness with mcollective : run once and get
# all the information you need.
# Brought to you by Nicolas Szalay : http://www.rottenbytes.info


require 'getoptlong'
require "mcollective"
include MCollective::RPC

options = rpcoptions do |parser, options|
   parser.define_head "Mcollective puppet client nagios check"
   parser.banner = "Usage: [options]"

   parser.on('-i', '--interval INTERVAL', 'run interval') do |v|
        options[:interval] = v
   end
   
  parser.on('-v', '--verbose', 'be verbose') do |v|
        options[:verbose] = true
   end
end

mc = rpcclient("puppetd")
mc.progress = false

old = 0
total = 0
interval = 1800

if options[:interval] then
    interval = options[:interval].to_i
end

mc.status.each do |resp|
    ago = Time.now.to_i - resp[:data][:lastrun]
    if (ago > interval) then
        old +=1
        if options[:verbose] then
            puts resp[:sender] + " check was more than " + interval.to_s + "s ago (#{ago}s ago)"
        end
    end
    
    total +=1
end

if old > 0
    puts("WARNING: #{old} / #{total} hosts not checked in within #{interval} seconds|totalhosts=#{total} outdatedhosts=#{old} currenthosts=#{total - old}")
    exit 1
else
    puts("OK: #{total} / #{total} hosts checked in within #{interval} seconds| totalhosts=#{total} outdatedhosts=#{old} currenthosts=#{total - old}")
    exit 0
end




