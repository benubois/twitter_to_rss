$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
$stdout.sync = true

require 'bundler/setup'
require 'tweetstream'
require 'twitter'
require "builder"
require "time"
require 'net/http'

TweetStream.configure do |config|
  config.consumer_key       = ENV['CONSUMER_KEY']
  config.consumer_secret    = ENV['CONSUMER_SECRET']
  config.oauth_token        = ENV['OAUTH_TOKEN']
  config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
  config.auth_method        = :oauth
end

def xml(options)
  builder = Builder::XmlMarkup.new
  builder.instruct! :xml, :version => "1.0"
  builder.feed xmlns: "http://www.w3.org/2005/Atom" do
    builder.title('Twitter Links')
    builder.link href: "#{ENV['TWITTER_SERVER']}/atom.xml", rel: "self"
    builder.link href: "http://pubsubhubbub.superfeedr.com/", rel: "hub"
    builder.link href: ENV['TWITTER_SERVER']
    builder.updated(Time.now.iso8601.to_s)
    builder.id(ENV['TWITTER_SERVER'])
    builder.entry do |entry|
      entry.author {|author| author.name(options[:author_name]) }
      entry.title(options[:title])
      entry.link href: options[:href]
      entry.published(Time.now.iso8601.to_s)
      entry.id(options[:id])
      entry.content(options[:content], type: 'html')
    end
  end
end

def write_xml(status)
  author = "#{status.user.name} - @#{status.user.screen_name}"
  File.open("./public/atom.xml", 'w') do |file|
    file.write xml(title: status.text, content: author, href: status.urls.first.expanded_url, author_name: author, id: status.id)
  end
end

def notify_hub
  uri = URI('http://pubsubhubbub.superfeedr.com/')
  Net::HTTP.post_form(uri,
    'hub.mode' => "publish",
    'hub.url' => "#{ENV['TWITTER_SERVER']}/atom.xml"
  )
end

client = TweetStream::Client.new
client.userstream do |status|
  if  status.class == Twitter::Tweet && status.urls.any?
    write_xml(status)
    notify_hub
  end
end
