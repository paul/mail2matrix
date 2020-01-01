# frozen_string_literal: true

require "forwardable"
require "optparse"
require "singleton"

require "matrix_sdk"
require "redcarpet"
require "xdg"

module Mail2Matrix
  # The Command Line Interface (CLI) for the gem.
  class CLI
    include Singleton
    extend Forwardable

    def self.start
      instance.start
    end

    def start
      load_configuration
      parse_arguments
      read_stdin
      configuration.finalize!
      run
    end

    private

    def load_configuration
      XDG::Config.new
                 .all
                 .reverse
                 .map { |dir| dir.join "mail2matrix.conf" }
                 .select(&:exist?)
                 .each { |file| configuration.load_from file }
    end

    def parse_arguments
      parser.parse!
      config.message.room = ARGV.join(" ") unless ARGV.empty?
    end

    def read_stdin
      config.message.body = STDIN.read
    end

    def run
      matrix = MatrixSdk::Client.new config.auth.server
      matrix.api.access_token = config.auth.token

      room = matrix.join_room config.message.room

      text = <<~BODY
        **#{config.message.subject}**

        ```
        #{config.message.body}
        ```
      BODY

      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, fenced_code_blocks: true)
      html = markdown.render(text)
      puts text
      puts html

      p room.send_html(html, text)
    end

    def configuration
      Mail2Matrix::Configuration
    end
    delegate [:config] => :configuration

    def parser
      OptionParser.new do |opts|
        opts.banner = <<~BANNER
          #{$PROGRAM_NAME} - A drop-in replacement for mail/mailx that will post messages to a Matrix room.

          It tolerates all normal mail/mailx arguments, but ignores most of them. The only relevant ones are:
        BANNER

        opts.on("-sSUBJECT", "--subject=SUBJECT", "Used as a heading for the message") do |subject|
          configuration.config.message.subject = subject
        end

        opts.on("-rFROM", "--from=FROM", "[Ignored]")

        %w[- B D d E F i n t v ~ a c b r h A S].each do |x|
          opts.on("-#{x}", "[Ignored]")
        end

        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
      end
    end
  end
end
