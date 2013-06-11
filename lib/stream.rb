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

def report_done
  report "done", :keep => true
end

def done
  puts "Shutting down"
end

EM.run do

  user_ids = [11730852]
  #TweetStream::Client.new.track("#GOT") do |msg|
  @client = TweetStream::Client.new
  #@client.sitestream(user_ids) do |msg|
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
end
