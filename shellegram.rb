##
# Author: Alex Lima @alexflima
# Tks to Chris Maddalena - It's a Frankenstein of an Frankenstein :)
##
require 'httpclient'
require 'json'
module Msf
	class Plugin::Shellegram < Msf::Plugin
		include Msf::SessionEvent
		# Checks if the constant is already set, if not it is set
		if not defined?(Shellegram_yaml)
			Shellegram_yaml = "#{Msf::Config.get_config_root}/Shellegram.yaml"
		end
		# Initialize the Class
		def initialize(framework, opts)
			super
			add_console_dispatcher(ShellegramDispatcher)
		end
		# Cleans up the event subscriber on unload
		def cleanup
			self.framework.events.remove_session_subscriber(self)
			remove_console_dispatcher('shellegram')
		end
		# Sets the name of the plugin
		def name
			"shellegram"
		end
		# Sets the description of the plugin
		def desc
			"Automatically send Telegram notifications when sessions are created and closed."
		end
		# Shellegram Dispatcher Class
		class ShellegramDispatcher
			include Msf::Ui::Console::CommandDispatcher
			@bot_token = nil
			@chat_id = nil
			@user = nil
			$source = nil
			$opened = Array.new
			$closed = Array.new
		    #Actions for when a session is created
			def on_session_open(session)
				sendMessage("GG! New session... Source: #{$source}; Session: #{session.sid}; Platform: #{session.platform}; Type: #{session.type}", session.sid, "open")
				return
			end
			# Actions for when the session is closed
			def on_session_close(session,reason = "")
				begin
					if reason == ""
						reason = "unknown, may have been killed with sessions -k"
					end
					sendMessage("F*ck Man You have made a huge mistake... Source: #{$source}; Session: #{session.sid}; Reason: #{session.type} is shutting down - #{reason}", session.sid, "close")
				rescue
					return
				end
				return
			end
			# Sets the name of the plguin
			def name
				"shellegram"
			end
			# Simple use the api.sendMessage to get work done
			def sendMessage(message, session_id, event)
				if event == "open" and $opened.exclude?(session_id)
					print_status(message)
					HTTPClient.get "https://api.telegram.org/bot#{@bot_token}/sendMessage?chat_id=#{@chat_id}&text=#{message}"
					$opened.push(session_id)
				elsif event == "close" and $closed.exclude?(session_id)
					print_status(message)
					HTTPClient.get "https://api.telegram.org/bot#{@bot_token}/sendMessage?chat_id=#{@chat_id}&text=#{message}"
					$closed.push(session_id)
				end
			end
			# Reads and set the valued from the YAML settings file
			def read_settings
				read = nil
				if File.exist?("#{Shellegram_yaml}")
					ldconfig = YAML.load_file("#{Shellegram_yaml}")
					@bot_token = ldconfig['bot_token']
					@chat_id = ldconfig['chat_id']
					$source = ldconfig['source']
					read = true
				else
					print_error("You must create a YAML File with the options")
					print_error("as: #{Shellegram_yaml}")
					return read
				end
				return read
			end
			# Sets the commands for the Metasploit plugin
			def commands
				{
					'shellegram_help'		=> "Displays help.",
					'shellegram_start' 		=> "Start Shellegram Plugin after saving settings.",
					'shellegram_stop' 		=> "Stop monitoring for new sessions.",
					'shellegram_test' 		=> "Send test message to make sure confoguration is working.",
					'shellegram_save' 		=> "Save Settings to YAML File #{Shellegram_yaml}.",
					'shellegram_set_bot_token' 	=> "Set Telegram bot_token for messages.",
					'shellegram_set_chat_id' 	=> "Set Telegram chat_id for messages.",
					'shellegram_set_source' 	=> "Set source for identifying the source of the message.",
					'shellegram_set_user' 		=> "Set your telegram userid to get chat_id.",
					'shellegram_set_chat_id_by_user'=> "Use currently user whith bot_token to get chat_id.",
					'shellegram_show_options' 	=> "Shows currently set parameters.",
				}
			end
			# Help command to help you help yourself
			def cmd_shellegram_help
				puts "Run shellegram_set_bot_token, shellegram_set_chat_id, and shellegram_set_source to setup Shellegram config. Then run shellegram_save to save them for later. Use shellegram_test to test your config and load it from the YAML file in the future. Finally, run shellegram_start when you have your listener setup."
			end
			# Re-Read YAML file and set Telegram API configuration
			def cmd_shellegram_start
				print_status "Session activity will be sent to you via Telegram API, chat_id: #{@chat_id}"
				if read_settings()
					self.framework.events.add_session_subscriber(self)
					print_good("Shellegram Plugin Started, Monitoring Sessions")
				else
					print_error("Could not set Telegram API settings.")
				end
			end
			# Stop the module and unsubscribe from the session events
			def cmd_shellegram_stop
				print_status("Stopping the monitoring of sessions to Telegram")
				self.framework.events.remove_session_subscriber(self)
			end
			# Send a test notification to Telegram
			def cmd_shellegram_test
				print_status("Sending tests message")
				if read_settings()
					self.framework.events.add_session_subscriber(self)
					HTTPClient.get "https://api.telegram.org/bot#{@bot_token}/sendMessage?chat_id=#{@chat_id}&text=hello"
					print_good("message sent =)")
				else
					print_error("Could not set Telegram API settings.")
				end
			end
			# Save settings to text file for later use
			def cmd_shellegram_save
				print_status("Saving options to config file")
				if @chat_id and @bot_token and $source
					config = {'chat_id' => @chat_id, 'bot_token' => @bot_token, 'source' => $source}
					File.open(Shellegram_yaml, 'w') do |out|
						YAML.dump(config, out)
					end
					print_good("All settings saved to #{Shellegram_yaml}")
				else
					print_error("You have not provided all the parameters!")
				end
			end
			# Set the bot_token for Shellegram alerts
			def cmd_shellegram_set_bot_token(*args)
				if args.length > 0
					print_status("Setting the bot_token Telegram handle to #{args[0]}")
					@bot_token = args[0]
				else
					print_error("Please provide a value")
				end
			end
			# Set the chat_id to Telegram
			def cmd_shellegram_set_chat_id(*args)
				if args.length > 0
					print_status("Setting the chat_id Telegram to #{args[0]}")
					@chat_id = args[0]
				else
					print_error("Please provide a value")
				end
			end
			# Set the message source, e.g. Phish5
			def cmd_shellegram_set_source(*args)
				if args.length > 0
					print_status("Setting the source to #{args[0]}")
					$source = args[0]
				else
					print_error("Please provide a value")
				end
			end
			# Set the user to get chat_id
			def cmd_shellegram_set_user(*args)
				if args.length > 0
					print_status("Setting the user to #{args[0]}")
					@user = args[0]
				else
					print_error("Please provide a value")
				end
			end
			def cmd_shellegram_set_chat_id_by_user(*args)
				if @user
					req = HTTPClient.get "https://api.telegram.org/bot#{@bot_token}/getUpdates"
					vars = JSON.parse(req.body)
					chat_id = nil
					for user in vars['result']
					  if user['message']['from']['username'] == @user
					    chat_id = user['message']['from']['id']
					    break
					  end
					end
					if chat_id
						@chat_id = chat_id
						print_status("Setting the chat_id to #{chat_id}")
					else
						print_error("No message identifying in the bot, sorry #{@user}")
					end
				else
					print_error("Please set user before runing this comand. shellegram_set_user")
				end
			end
			# Show the parameters set on the Plug-In
			def cmd_shellegram_show_options
				print_status("Parameters:")
				print_good("Bot Token: #{@bot_token}")
				print_good("Chat Id: #{@chat_id}")
				print_good("Source: #{$source}")
				print_good("User: #{@user}")
			end
		end
	end
end
