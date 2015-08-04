require 'spec_helper'
require 'godigo/command_manager'
require 'godigo/commands/session_command'
module Godigo
	describe CommandManager do
		describe "#load_and_instantiate" do
			subject { manager.load_and_instantiate command_name, args, opts }
			let(:manager){ CommandManager.instance}
			let(:command_name){ 'session_command' }
			let(:args){ [] }
			let(:opts){ {} }
			let(:cmd){ double('session_command').as_null_object }
			it "returns command instance" do
				expect(Godigo::Commands::SessionCommand).to receive(:new).with(args, {})
				subject
			end
		end

	end
end