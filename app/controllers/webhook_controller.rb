class WebhookController < ApplicationController
  CHANNEL = '#bot'

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless line_client.validate_signature(body, signature)
      error 400, 'Bad Request'
    end

    events = line_client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          post_message(event.message['text'])
        when Line::Bot::Event::MessageType::Image
          image_response = line_client.get_message_content(event.message['id'])
          file = File.open("/tmp/#{Time.current.strftime('%Y%m%d%H%M%S')}.jpg", 'w+b')
          file.write(image_response.body)

          slack_client.files_upload(channels: CHANNEL,
                                    file: Faraday::UploadIO.new(file.path, 'image/jpeg'),
                                    as_user: true,
                                    title: File.basename(file.path),
                                    filename: File.basename(file.path),
                                    initial_comment: '写真が送信されました')
        when Line::Bot::Event::MessageType::Video
          post_message('ビデオが送信されました。')
        when Line::Bot::Event::MessageType::Sticker
          post_message('スタンプが送信されました。')
        end
      end
    end

    head :ok
  end

  private

  def post_message(text)
    slack_client.chat_postMessage(channel: CHANNEL, text: text)
  end
end