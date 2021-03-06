module SlackShellbot
  module Commands
    class Rm < SlackRubyBot::Commands::Base
      def self.call(client, data, match)
        fs = client.owner.fs[data.channel]
        file = Shellwords.split(match['expression']).first if match.names.include?('expression')
        fail 'usage: rm <file> ...' unless file
        file_entry = fs.current_directory_entry.rm(file)
        client.say(channel: data.channel, text: file_entry.path)
        logger.info "RM: #{client.owner}, #{fs}, file=#{file_entry.path}, user=#{data.user}"
      end
    end
  end
end
