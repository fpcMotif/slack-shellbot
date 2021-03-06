require 'spec_helper'

describe SlackShellbot::Commands::Cat do
  let(:team) { Fabricate(:team) }
  let(:app) { SlackShellbot::Server.new(team: team) }
  let(:client) { app.send(:client) }
  context 'echo' do
    let!(:fs) { team.fs['channel'] }
    let!(:file) { Fabricate(:file_entry, data: 'hello world', parent_directory_entry: fs.root_directory_entry) }
    it 'pipe into a file' do
      expect(client).to receive(:say).with(channel: 'channel', text: 'hello world')
      app.send(:message, client, text: "#{SlackRubyBot.config.user} cat #{file.name}", channel: 'channel')
    end
  end
end
