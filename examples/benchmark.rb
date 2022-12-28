lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fritzbox/smarthome'

Fritzbox::Smarthome.configure do |config|
  config.endpoint   = 'https://fritz.box'
  config.username   = 'smarthome'
  config.password   = 'verysmart'
  config.verify_ssl = false
  config.logger     = Logger.new(STDOUT)
end

require 'benchmark'

n = 10

puts Benchmark.measure {
  n.times do |i|
    puts "--- #{i} -------------------------------------"
    Fritzbox::Smarthome::Actor.all
  end
}
