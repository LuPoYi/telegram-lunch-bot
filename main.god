God.watch do |w|
  w.name = "lunch_bot"
  w.start = "ruby main.rb"
  w.keepalive
  w.log = 'log/god.log'
end