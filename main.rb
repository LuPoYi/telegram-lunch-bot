require 'rubygems'
require 'telegram/bot'
require 'redis'
require 'yaml'
require_relative 'lib/bot.rb'

$settings = YAML.load_file('./config.yml')
$redis = Redis.new($settings[:redis])

Bot.start!

