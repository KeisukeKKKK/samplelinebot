class ApplicationController < ActionController::Base
  private

  def line_client
    @line_client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    end
  end

  def slack_client
    @slack_client ||= Slack::Web::Client.new
  end
end