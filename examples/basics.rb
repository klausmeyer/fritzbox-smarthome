lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fritzbox/smarthome'

Fritzbox::Smarthome.configure do |config|
  config.endpoint   = 'https://fritz.box'
  config.username   = 'smarthome'
  config.password   = 'verysmart'
  config.verify_ssl = false
end

# Getting a list of actors
pp actors = Fritzbox::Smarthome::Actor.all

# Finding by AIN
begin
  Fritzbox::Smarthome::Actor.find_by!(ain: '0815 4711')
rescue Fritzbox::Smarthome::Actor::ResourceNotFound => e
  pp e
end

# Reload
actor = Fritzbox::Smarthome::Actor.find_by!(ain: actors.first.ain)
pp actor.reload
