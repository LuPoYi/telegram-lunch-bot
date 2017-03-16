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
/random    隨機取得
/choose    隨機三選一
/close     關閉keyboard

          "
          bot.api.send_message(chat_id: message.chat.id, text: ans)
        when '/list'
          list = $redis.lrange('LUNCH_LIST', 0, -1)
          ans = "目前餐廳有：\n#{list.join("\n")}"
          bot.api.send_message(chat_id: message.chat.id, text: list.empty? ? '無資料請先新增' : ans, parse_mode: 'HTML')

        when /\A(\/add)(\s)(.+)/
          restaurants = "#{$3}"
          list = $redis.lrange('LUNCH_LIST', 0, -1)
          ans = []
          restaurants.split(" ").each do |r|
            unless list.index(r) # 確保不重複
              $redis.lpush('LUNCH_LIST', r) 
              ans << r
            end
          end
          bot.api.send_message(chat_id: message.chat.id, text: ans.empty? ? '無法新增' : "已新增 #{ans.join(', ')}.")

        when  /\A(\/update)(\s)(.+)(\s)(.+)/
          list = $redis.lrange('LUNCH_LIST', 0, -1) # ["aaa", "bbb", "ccc"] 0 1 2
          range_index = list.index("#{$3}")
          if range_index
            $redis.lset('LUNCH_LIST', range_index, "#{$5}")
            bot.api.send_message(chat_id: message.chat.id, text: "#{$3} 已更新為 #{$5}.")
          else
            bot.api.send_message(chat_id: message.chat.id, text: "找不到 #{$3}.")
          end

        when /\A(\/remove)(\s)(.+)/
          if list.index("#{$3}")
            $redis.lrem('LUNCH_LIST', 0, "#{$3}")
            bot.api.send_message(chat_id: message.chat.id, text: "已移除 #{$3}.")
          else
            bot.api.send_message(chat_id: message.chat.id, text: "找不到 #{$3}.")
          end

        when'/random'
          list = $redis.lrange('LUNCH_LIST', 0, -1)
          list[rand(list.length)]
          bot.api.send_message(chat_id: message.chat.id, text: "吃 #{list[rand(list.length)]} ?")
        when '/choose'
          list = $redis.lrange('LUNCH_LIST', 0, -1)
          sample = list.sample(3)
          question = "吃 三選一? #{sample.join(', ')}"
          answers = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [[sample[0],sample[1]], [sample[2], 'Pass']], one_time_keyboard: true)
          bot.api.send_message(chat_id: message.chat.id, text: question, reply_markup: answers)
        when '/close'
          kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
          bot.api.send_message(chat_id: message.chat.id, text: 'Done', reply_markup: kb)
        end
      end
    end
  end
end

