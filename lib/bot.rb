require 'telegram/bot'

module Bot
  def self.start!
    Telegram::Bot::Client.run($settings[:token]) do |bot|
      bot.listen do |message|
        case message.text
        when '/help'

          ans = "
You can control me by sending these commands:

/list
/add [name]
/update [old_name] [new_name]
/remove [name]
/random

          "
          bot.api.send_message(chat_id: message.chat.id, text: ans)
        when '/list'
          list = $redis.lrange('LUNCH_LIST', 0, -1)
          ans = "目前餐廳有：\n\n#{list.join("\n")}"
          bot.api.send_message(chat_id: message.chat.id, text: list.empty? ? '無資料請先新增' : ans, parse_mode: 'HTML')

        when /\A(\/add)(\s)(.+)/
          $redis.lpush('LUNCH_LIST', "#{$3}")
          bot.api.send_message(chat_id: message.chat.id, text: "已新增 #{$3} 。")

        when  /\A(\/update)(\s)(.+)(\s)(.+)/
          list = $redis.lrange('LUNCH_LIST', 0, -1) # ["aaa", "bbb", "ccc"] 0 1 2
          range_index = list.index("#{$3}")
          if range_index
            $redis.lset('LUNCH_LIST', range_index, "#{$5}")
            bot.api.send_message(chat_id: message.chat.id, text: "#{$3} 已更新為 #{$5} 。")
          else
            bot.api.send_message(chat_id: message.chat.id, text: "找不到 #{$3} 。")
          end

        when /\A(\/remove)(\s)(.+)/
          if list.index("#{$3}")
            $redis.lrem('LUNCH_LIST', 0, "#{$3}")
            bot.api.send_message(chat_id: message.chat.id, text: "已移除 #{$3} 。")
          else
            bot.api.send_message(chat_id: message.chat.id, text: "找不到 #{$3} 。")
          end

        when '/choose', '/random'
          list = $redis.lrange('LUNCH_LIST', 0, -1)
          list[rand(list.length)]
          bot.api.send_message(chat_id: message.chat.id, text: "吃 #{list[rand(list.length)]} ?")
        end
      end
    end
  end
end

