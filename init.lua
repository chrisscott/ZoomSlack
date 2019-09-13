--- === ZoomSlack ===
---
--- Set your Slack status when in a Zoom meeting. Clear it when you're done.
---
--- You'll need to use a [legacy token] (https://api.slack.com/custom-integrations/legacy-tokens)
--- and pass it in to the configuration along with any other configuration options. e.g.:
---
--- local zoom = hs.spoons.use(
---   "ZoomSlack", 
---   {
---     config = { 
---       slackToken = "[YOUR SLACK TOKEN]",
---       statusEmoji = ":zoom:"
---     }
---   }
--- )
--- if zoom then
---   spoon.ZoomSlack:start()
--- end
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

--- ZoomSlack.dryRun
--- Variable
--- When set to true, don't send messages to the Slack API and don't send notifications. Defaults to false.
obj.dryRun = false

--- ZoomSlack:start()
--- Method
--- Start ZoomSlack
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:start()
  assert(obj.slackToken, "Slack token must be provided")

  if obj.expiration == "N" then obj.status_expiration_seconds = 0
    elseif obj.expiration == "30M" then obj.status_expiration_seconds = 1800
    elseif obj.expiration == "45M" then obj.status_expiration_seconds = 2700
    elseif obj.expiration == "1H" then obj.status_expiration_seconds = 3600
    else obj.status_expiration_seconds = 0
  end

  obj.logger.df("Status expiration set to '%s' which is '%d' in seconds", obj.expiration, obj.status_expiration_seconds)

  hs.application.watcher.new(function(name, event, app)
    if name == 'zoom.us' then
      if event == hs.application.watcher.launched then
        obj.setSlackStatus()
      elseif event == hs.application.watcher.terminated then
        obj.clearSlackStatus()
      end
    end
  end):start()
end

function obj:setSlackStatus()
  local status_expiration = obj.status_expiration_seconds + os.time(os.date("*t"))

  obj.logger.i("Setting Slack status")
  obj.logger.df("Setting Slack status '%s' with emoji '%s' and an expiration in %d seconds (unixtime of %d)",
    obj.statusText,
    obj.statusEmoji,
    obj.status_expiration_seconds,
    status_expiration
  )

  obj:sendStatus(obj.statusText, obj.statusEmoji, status_expiration)
  if not obj.dryRun then
    hs.notify.show("", "Zoom Started", "Slack status set")
  end
end

function obj:clearSlackStatus()
  obj.logger.i("Clearing Slack status")

  obj:sendStatus("", "", 0)
  if not obj.dryRun then
    hs.notify.show("", "Zoom Terminated", "Slack status cleared")
  end
end

function obj:sendStatus(text, emoji, expiration)
  if obj.dryRun then
    obj.logger.d("Dry run enabled. POSTing to Slack API disabled.")
    return
  end

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

      obj.logger.df("Slack API response body: \n%s", body)
      
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

return obj
