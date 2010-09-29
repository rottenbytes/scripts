#!/usr/bin/env ruby

require 'stomp'
require 'getoptlong'

opts = GetoptLong.new(
    [ '--host', '-H', GetoptLong::REQUIRED_ARGUMENT],
    [ '--login', '-l', GetoptLong::REQUIRED_ARGUMENT],
    [ '--password', '-p', GetoptLong::REQUIRED_ARGUMENT],
    [ '--port', '-P', GetoptLong::REQUIRED_ARGUMENT],
    [ '--queue', '-q', GetoptLong::REQUIRED_ARGUMENT]
)

server="localhost"
login="nagios"
password="zomgsecret"
port=6163
CHARS="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#!*$£^"
queue = "/queue/nagios"


opts.each do |opt, arg|
    case opt
        when '--host'
            server = arg
        when '--login'
            login = arg
        when '--password'
            password = arg
        when '--port'
            port = arg.to_i
        when '--queue'
            queue = arg
    end
end

def rnd_string(length=8)
    rslt=""
    srand()
    length.times {
        rslt << CHARS[rand(CHARS.size)]
    }

    rslt
end

producer = Stomp::Connection.new(login, password, server, port, true, :timeout => 5)
message = rnd_string(50)
producer.publish queue,message, { :persistent => false }
producer.disconnect

consumer = Stomp::Connection.open(login, password, server, port, true, :timeout => 5)
consumer.subscribe(queue)
message_test=consumer.receive.body.chomp
consumer.disconnect


if message == message_test 
    puts("OK: message was delivered & received|host=#{server} / message was #{message}")
    exit 0
else
   puts("CRITICAL: could not deliver/receive message !|host=#{server} / #{message} was expected, received #{message_test}")
    exit 1
end

