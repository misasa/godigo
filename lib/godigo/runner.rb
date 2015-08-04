require 'godigo/command_manager'
module Godigo
	class Runner
		def initialize
		end
		def run(args=ARGV, opts = {})
			if command_name = opts[:command_name]
				command_name = opts[:command_name]
				cmd = Godigo::CommandManager.instance.load_and_instantiate command_name, args, opts
				cmd.run
			end
		end
	end
end