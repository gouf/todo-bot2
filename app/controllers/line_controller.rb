class LineController < ApplicationController
#linebotapiのインポート
require'line/bot'
  #Railsのあるセキュリティ対策を無効化
  protect_from_forgery except: [:bot]
  #LINEでメッセージを送るとこのアクションメソッドbotが走る
  def bot
    #LINEで送られてきたメッセージのデータを取得
    body = request.body.read
    #LINE以外からのアクセスの場合エラーを返す
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless
      client.validate_signature(body,signature)
      head:bad_request
    end
    #LINEで送られてきたメッセージのデータeventsというデータ構造に変更
    events = client.parse_events_from(body)
    #eventsの中身を舐める
    events.each {|event|
      #eventがメッセージだったら
      case event
      when Line::Bot::Event::Message
        #メッセージのタイプがテキストだったら（スタンプ等ではなく）
        case event.type
        when Line::Bot::Event::MessageType::Text
          #メッセージの文字列を取得して、変数taskに代入
          case event.message['text']
          when /^めも/
            memoWords = event.message['text']
            tasks = memoWords.split
            task = tasks[1]
            Task.create!(task:task)
            #登録に成功した場合、登録した旨をLINEで返す
            message = reply_word(task)
            {type:'text',text:"タスク『#{task}』を登録しました！"}
            client.reply_message(event['replyToken'], message)
          when /^ヘルプ$/
          message = {type:'text',text:"登録するときは、「めも　〇〇」と入力してください。"}
          client.reply_message(event['replyToken'], message)
          end
        end
      end
    }
    head :ok
  end

  #LINEボットを生成して返すプライベートメソッドの定義
  private
  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def reply_word(task)
    {
      type: "text",
      text: "『#{task}』を登録!, https://todo-bot2.herokuapp.com/tasks/index"
    }
  end

end


