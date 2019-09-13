# ZoomSlack
A Hammerspoon Spoon to set your Slack status when on a Zoom call

## Prerequisites

* [Hammerspoon](http://www.hammerspoon.org)

## Installation

1. `git clone https://github.com/chrisscott/ZoomSlack.git ~/.hammerspoon/Spoons`
1. Get a [legacy Slack token](https://api.slack.com/custom-integrations/legacy-tokens)
1. Edit your `~/.hammerspoon/init.lua` to include and configure this Spoon with your Slack token and any other [configuration options](./markdown/ZoomSlack.md). e.g:

	```
	local zoom = hs.spoons.use(
		"ZoomSlack", 
		{
			config = { 
				slackToken = "[YOUR SLACK TOKEN]",
				statusEmoji = ":zoom:"
			}
		}
	)
	if zoom then
		spoon.ZoomSlack:start()
	end
	```
