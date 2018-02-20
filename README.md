# Shellegram
This Metasploit plugin was created to monitor sessions, new ones and those closing in Telegram. The idea is to provide a way for consultants to see new sessions coming in when they might not have access to their listener(s). Perhaps you have stepped away from your computer with an active phishing campaign? Maybe you're using a Rubber Ducky in an office and want to get a mobile notification if your payload succeeds?

A future version use the Metasploit remote API to monitor sessions and Empire REST API to support both Meterpreter sessions and Empire agents.

Shellegram uses session subscriptions to monitor activity and then sends an message to Telegram using Bot. The alert is sent using the Telegram Bot API URL and a POST request and will send a message to specified chat_id (you could also use Telegram username to set chat_id) and provide the computer name of the server with the session (if set).

## Setup
Place the shellegram.rb file inside "/usr/share/metasploit-framework/plugins/" or a folder you have linked to this primary plugins folder (~/.msf4/plugins/).

Then create a new bot in Telegram, get the BOT-TOKEN, add that bot to your Telegram and send a message to recognise you. See (https://core.telegram.org/bots#3-how-do-i-create-a-bot)

## Sample Usage
The Shellegram plugin can be used like any other Metasploit plugin. Begin by loading Shellegram and setting your options. Then you will need to config to subscribe to session events. See the following example:
<pre>
  msf exploit(handler) > load shellegram

  [*] Successfully loaded plugin: shellegram

  msf exploit(handler) > shellegram_set_bot_token <YOUR-BOT-TOKEN>

  [*] Setting the bot_token Telegram handle to <YOUR-BOT-TOKEN>

  msf exploit(handler) > shellegram_set_user <YOUR-USER>

  [*] Setting the user to <YOUR-USER>

  msf exploit(handler) > shellegram_set_chat_id_by_user

  [*] Setting the chat_id <#chat_id>

  msf exploit(handler) > shellegram_set_source <ANY-NAME-YOU-WANT>

  [*] Setting the source to <ANY-NAME-YOU-WANT>

  msf exploit(handler) > shellegram_save

  [*] Saving options to config file
  [+] All settings saved to ~/.msf4/Shellegram.yaml

  msf exploit(handler) > shellegram_test 

  [*] Sending tests message
  [+] message sent =)

  msf exploit(handler) > shellegram_start
  
  [*] Session activity will be sent to you via Telegram API, chat_id: <#chat_id>
  [+] Shellegram Plugin Started, Monitoring Sessions
</pre>
If you have any questions, use help shellegram:

shellegram Commands
===================

    Command                         Description
    -------                         -----------
    shellegram_help                 Displays help.
    shellegram_save                 Save Settings to YAML File ~/.msf4/Shellegram.yaml.
    shellegram_set_bot_token        Set Telegram bot_token for messages.
    shellegram_set_chat_id          Set Telegram chat_id for messages.
    shellegram_set_chat_id_by_user  Use currently user whith bot_token to get chat_id.
    shellegram_set_source           Set source for identifying the source of the message.
    shellegram_set_user             Set your telegram userid to get chat_id.
    shellegram_show_options         Shows currently set parameters.
    shellegram_start                Start Shellegram Plugin after saving settings.
    shellegram_stop                 Stop monitoring for new sessions.
    shellegram_test                 Send test message to make sure confoguration is working.
