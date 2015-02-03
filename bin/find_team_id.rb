#!/usr/bin/env ruby
# Copyright 2001-2014 Rally Software Development Corp. All Rights Reserved.
# $: << 'lib' << '.'

require 'rallyeif-wrk'
require 'rallyeif-rtc'

begin
  #puts "#{ARGV}"
  
  if (ARGV.length != 2)
    puts
    puts "USAGE: ruby find_team_id.rb <config file> <team name>"
  end
  config_file = ARGV[0]
  team_name = ARGV[1]
  
  root = XMLUtils.read_config_file(config_file,"RTCConnection")

  rtc_connection = RallyEIF::WRK::RTCConnection.new(root)
  rtc_connection.connect()
   
  puts "#{team_name} id: #{rtc_connection.find_team_area_id(team_name)}"
  
  # connector_runner.run()
rescue => ex
  RallyEIF::WRK::RallyLogger.exception(self, ex)
end
