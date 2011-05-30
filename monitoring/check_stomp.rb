#!/usr/bin/env ruby

require 'stomp'
require 'getoptlong'

#--------------------------------------------------------------
opts = GetoptLong.new(
    [ '--host', '-H', GetoptLong::REQUIRED_ARGUMENT],
    [ '--login', '-l', GetoptLong::REQUIRED_ARGUMENT],
    [ '--password', '-p', GetoptLong::REQUIRED_ARGUMENT],
    [ '--port', '-P', GetoptLong::REQUIRED_ARGUMENT],
    [ '--queue', '-q', GetoptLong::REQUIRED_ARGUMENT],
    [ '--queue-suffix', '-s', GetoptLong::NO_ARGUMENT],
    [ '--debug', '-d', GetoptLong::NO_ARGUMENT],
    [ '--help', '-h', GetoptLong::NO_ARGUMENT]
)
#--------------------------------------------------------------
server="localhost"
login="nagios"
password="zomgsecret"
port=6163
debugmode=false
CHARS="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#!*$£^"
queue = "/queue/nagios"
#--------------------------------------------------------------
opts.each do |opt, arg|
    case opt
        when '--help'
            puts <<-EOF
    check_stomp.rb [OPTIONS/PARAMS]

	    -h, --help:
	       show help

	    --login x, -l x
	       => sets login for stomp connection

	    --password y, -p y
	       => sets password for stomp connection

	    --port 6163, -P 6163
	       => sets remote port for stomp connection

	    --queue z, -q z
	       => sets queue name for stomp connection

	    --queue-suffix z, -s 
	       => append _hostname to queue name 

	    --host host.domain.tld, -H host.domain.tld
	       => sets remote host for stomp connection

	    --debug, -d
	       => enables debug mode for stomp probe

          EOF
        exit
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
	when '--queue-suffix'
	    queue = queue+"_"+server
        when '--debug'
            debugmode = true
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
#--------------------------------------------------------------
puts "Connecting to stomp server" if debugmode
producer = Stomp::Connection.new(login, password, server, port, true, :timeout => 5)
message = rnd_string(50)
puts "Sending stomp message to queue:" + queue if debugmode
producer.send(queue,message)
puts "Message sent: "+message if debugmode
producer.disconnect
puts "Disconnecting from stomp server" if debugmode
#--------------------------------------------------------------
puts "Re-connecting to stomp server" if debugmode
consumer = Stomp::Connection.open(login, password, server, port, true, :timeout =>5)

puts "Subscribing to queue:" + queue if debugmode
message_test = ""
consumer.subscribe(queue) 
print "Receiving nagios queue messages" if debugmode
message_test = consumer.receive.body.chomp
puts "Received message: "+ message_test if debugmode
puts "Disconnecting from stomp server" if debugmode
consumer.disconnect
#--------------------------------------------------------------
if message == message_test 
    puts("OK: message was delivered & received|host=#{server} / message was #{message}")
    exit 0
else
    puts("CRITICAL: could not deliver/received message !|host=#{server} / #{message} was expected, received #{message_test}")
    exit 1
end
