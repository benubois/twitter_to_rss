twitter_to_rss
==============

Safari has a [shared links](http://support.apple.com/kb/TI45) feature that shows you the tweets from people you follow that contain links.

This project attempts to deliver this functionality through RSS.

Setup
-----

You'll need to [create a new application](https://dev.twitter.com/apps) on the Twitter Developer website. It just needs read only access.

Use these environment variables:

```
CONSUMER_KEY='from Twitter'
CONSUMER_SECRET='from Twitter'
OAUTH_TOKEN='from Twitter'
OAUTH_TOKEN_SECRET='from Twitter'
TWITTER_SERVER='url to your server'
```

Next you will need a way to serve the generated XML to the internet. A sample nginx virtual host might look like:

```
server {
	listen   80;
	root /srv/twitter_to_rss/public;
	server_name _;
}
```

finally run the app with:

```ruby
ruby app.rb
```