$: << "." << "lib"

require 'bundler/setup'
require 'tweetstream'
require 'reporting'
require 'yaml'

twitter_config = YAML.load_file("twitter.yml")

TweetStream.configure do |config|
  config.consumer_key = twitter_config['consumer_key']
  config.consumer_secret = twitter_config['consumer_secret']
  config.oauth_token = twitter_config['access_token']
  config.oauth_token_secret = twitter_config['access_token_secret']
  config.auth_method = :oauth
end

Twitter.configure do |config|
  config.consumer_key = twitter_config['consumer_key']
  config.consumer_secret = twitter_config['consumer_secret']
  config.oauth_token = twitter_config['access_token']
  config.oauth_token_secret = twitter_config['access_token_secret']
end

def done
  puts "Shutting down"
end

class TweetHandler < EM::Connection
  include EM::Protocols::LineText2

  def receive_line(data)
    if data.length > 1 && data.length <= 140
      Twitter.update(data)
    else
      puts "Can't tweet that because the length is #{data.length}/140"
    end
  end
end

EM.run do

  @client = TweetStream::Client.new
  @client.userstream do |msg|
    puts "#{msg.user.name} - #{msg.text}"
  end

  @client.on_inited do
    puts "Stream initialized."
  end

  @client.on_error do |error|
    puts "There was an error"
    puts error
  end

  EM.next_tick do
    puts "Setup complete"
  end

  Signal.trap("INT")  { @client.stop_stream; done; EventMachine.stop }
  Signal.trap("TERM") { @client.stop_stream; done; EventMachine.stop }

  EM.open_keyboard(TweetHandler)
end