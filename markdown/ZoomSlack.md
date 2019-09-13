# [docs](index.md) » ZoomSlack
---

Set your Slack status when in a Zoom meeting. Clear it when you're done.

You'll need to use a [legacy token](https://api.slack.com/custom-integrations/legacy-tokens)
and pass it in to the configuration along with any other configuration options. e.g.:

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

https://github.com/chrisscott

## API Overview
* Variables - Configurable values
 * [dryRun](#dryRun)
 * [expiration](#expiration)
 * [logger](#logger)
 * [slackToken](#slackToken)
 * [statusEmoji](#statusEmoji)
 * [statusText](#statusText)
* Methods - API calls which can only be made on an object returned by a constructor
 * [start](#start)

## API Documentation

### Variables

| [dryRun](#dryRun)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `ZoomSlack.dryRun`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | When set to true, don't send messages to the Slack API and don't send notifications. Defaults to false.                                                                     |

| [expiration](#expiration)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `ZoomSlack.expiration`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | String indicating how long until the status expires. Default is "N" (Never). Status will always be cleared when a meeting is stopped so this is more insurance than anything if set. Valid expiration times: "N", "30M", "45M", and "1H"                                                                     |

| [logger](#logger)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `ZoomSlack.logger`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.                                                                     |

| [slackToken](#slackToken)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `ZoomSlack.slackToken`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | String Slack token. Uses a [legacy token](https://api.slack.com/custom-integrations/legacy-tokens)                                                                     |

| [statusEmoji](#statusEmoji)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `ZoomSlack.statusEmoji`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | String Status emoji. Defaults to ":spiral_calendar_pad:" if not set.                                                                     |

| [statusText](#statusText)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `ZoomSlack.statusText`                                                                    |
| **Type**                                    | Variable                                                                     |
| **Description**                             | String Status text. Defaults to "On a Call" if not set.                                                                     |

### Methods

| [start](#start)         |                                                                                     |
| --------------------------------------------|-------------------------------------------------------------------------------------|
| **Signature**                               | `ZoomSlack:start()`                                                                    |
| **Type**                                    | Method                                                                     |
| **Description**                             | Start ZoomSlack                                                                     |
| **Parameters**                              | <ul><li>None</li></ul> |
| **Returns**                                 | <ul><li>None</li></ul>          |

