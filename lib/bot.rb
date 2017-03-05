require 'telegram/bot'

module Bot
  def self.start!
    Telegram::Bot::Client.run($settings[:token]) do |bot|
      bot.listen do |message|
        case message.text
        when '/help'
          bot.api.send_message(chat_id: message.chat.id, text: message.chat.id)
        when '/list'
          bot.api.send_message(chat_id: message.chat.id, text: 'pong')
        when /\A(\/add)(\s)(.+)/
          bot.api.send_message(chat_id: message.chat.id, text: "#{$3}")

        when '/delete'
          bot.api.send_message(chat_id: message.chat.id, text: 'pong')
        end
      end
    end
  end
end
