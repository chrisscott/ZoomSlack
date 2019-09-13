--- === ZoomSlack ===
---
--- Set your Slack status when in a Zoom meeting. Clear it when you"re done.
---
--- https://github.com/chrisscott

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ZoomSlack"
obj.version = "1.0"
obj.author = "Chris Scott"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- ZoomSlack.slackToken
--- Variable
--- String Slack token. Uses a [legacy token] (https://api.slack.com/custom-integrations/legacy-tokens)
obj.slackToken = nil

--- ZoomSlack.statusText
--- Variable
--- String Status text. Defaults to "On a Call" if not set.
obj.statusText = "On a Call"

--- ZoomSlack.statusEmoji
--- Variable
--- String Status emoji. Defaults to ":spiral_calendar_pad:" if not set.
obj.statusEmoji = ":spiral_calendar_pad:"

--- ZoomSlack.expiration
--- Variable
--- String indicating how long until the status expires. Default is "N" (Never). Status will always be cleared when a meeting is stopped so this is more insurance than anything if set.
--- Valid expiration times:
--- N
--- 30M
--- 45M
--- 1H
obj.expiration = "N"


--- ZoomSlack.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new("ZoomSlack")

obj.sawMeetingWindow = false
obj.sawShareWindow = false

--- ZoomSlack:start()
--- Method
--- Start ZoomSlack
---
--- Parameters:
---  * None
function obj:start()
  assert(obj.slackToken, "Slack token must be provided")

  if obj.expiration == "N" then obj.status_expiration_seconds = 0
    elseif obj.expiration == "30M" then obj.status_expiration_seconds = 1800
    elseif obj.expiration == "45M" then obj.status_expiration_seconds = 2700
    elseif obj.expiration == "1H" then obj.status_expiration_seconds = 3600
  end

  local wf = hs.window.filter.new(false):setAppFilter("zoom.us")

  -- for when a meeting is started from the app's main window vs. browser
	wf:subscribe("windowTitleChanged", function(window, name)
		obj.logger.d("Window title changed. Setting sawMeetingWindow to true")
		obj.logger.df("sawShareWindow is %s", obj.sawShareWindow)
		obj.sawMeetingWindow = true
		if not obj.sawShareWindow then
			obj.setSlackStatus()
		end
  end)

  -- for when a meeting is started from the browser
	wf:subscribe("windowCreated", function(window, name)
		obj.logger.d("Window created")
		print(string.format("title %s", window:title()))
		print(string.format("role %s", window:role()))
		print(string.format("subrole %s", window:subrole()))
		if window:subrole() == "AXSystemDialog" and window:title() == "" then
			obj.logger.d("Looks like a screen share. setting sawShareWindow to true")
			obj.sawShareWindow = true
		end

		if string.find(window:title(), "Zoom Meeting ID") then
			obj.logger.d("Found Zoom Meeting window, setting status, setting sawMeetingWindow to true")
			obj.sawMeetingWindow = true
      obj.setSlackStatus()
    end
  end)

  wf:subscribe("windowDestroyed", function(window, name)
    local app = window:application()
		local meetingWindow = app:findWindow("Zoom Meeting ID")
		obj.logger.d("Window destroyed")
		obj.logger.df("meetingWindow is %s", meetingWindow)

		if (meetingWindow) then
			obj.logger.d("Setting sawMeetingWindow to true")
      obj.sawMeetingWindow = true
		end
		
		obj.logger.df("sawMeetingWindow is %s, sawShareWindow is %s", obj.sawMeetingWindow, obj.sawShareWindow)

    -- make sure the meeting was ended and the modal window wasn't canceled instead
    if (obj.sawMeetingWindow and not meetingWindow) or (obj.sawMeetingWindow and obj.sawShareWindow) then
      obj.sawMeetingWindow = false
      obj.clearSlackStatus()
    end
    end)
end

function obj:sendStatus(text, emoji, expiration)
  obj.logger.d("POSTing to Slack API")
  local jsonreq = {
    profile = {
      status_text = text,
      status_emoji = emoji,
      status_expiration = expiration
    }
  }
  hs.http.asyncPost(
    "https://slack.com/api/users.profile.set",
    hs.json.encode(jsonreq),
    {
      ["Authorization"] = "Bearer " .. obj.slackToken, 
      ["Content-type"] = "application/json; charset=utf-8"
    },
		function(http_code, body)
			local res = hs.json.decode(body)
			if http_code == 200 then
				if not res.ok then
					hs.notify.new({title = "Setting Slack Status Failed!", informativeText = res.error}):send()
					obj.logger.df("Slack API response error: %s", res.error)
					return false
				end
			else
					hs.notify.new({title = "Setting Slack Status Failed!", informativeText = res.error}):send()
					obj.logger.df("Slack API response error: %s", res.error)
					return false
			end

    end
  )
end

function obj:setSlackStatus()
	local status_expiration = obj.status_expiration_seconds * os.time(os.date("!*t"))
	obj.logger.d("Setting Slack status '%s' with emoji '%s' and an expiration in %s seconds", obj.statusText, obj.statusEmoji, obj.status_expiration_seconds)
	obj:sendStatus(obj.statusText, obj.statusEmoji, status_expiration)
	hs.notify.show("", "Zoom Started", "Slack status set")
end

function obj:clearSlackStatus()
	obj.logger.d("Clearing Slack status")
	obj:sendStatus("", "", 0)
	hs.notify.show("", "Zoom Stopped", "Slack status cleared")
end

return obj
