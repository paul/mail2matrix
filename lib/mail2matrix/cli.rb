# frozen_string_literal: true

require "forwardable"
require "optparse"
require "singleton"

require "matrix_sdk"
require "redcarpet"
require "xdg"

require_relative "configuration"

module Mail2Matrix
  # The Command Line Interface (CLI) for the gem.
  class CLI
    include Singleton
    extend Forwardable

    def self.start(args = ARGV, input = ARGF)
      instance.start(args, input)
    end

    def start(args = ARGV, input = ARGF)
      load_configuration
      parse_arguments(args)
      read_body(input) if !STDIN.tty? && !STDIN.closed?
      configuration.finalize!
      validate_config
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

    def parse_arguments(args)
      parser.parse!
      config.message.room = args.join(" ") unless args.empty?
    end

    def read_body(input)
      config.message.body = input.each_line.to_a.join("\n")
    end

    def validate_config
      unless config.auth.server && config.message.subject
        puts(parser)
        exit 1
      end
    end

    def run
      matrix = MatrixSdk::Client.new config.auth.server
      matrix.api.access_token = config.auth.token

      room = matrix.join_room config.message.room

      text = <<~BODY
        **#{config.message.subject}**

        ```
        #{config.message.body.chomp}
        ```
      BODY

      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, fenced_code_blocks: true)
      html = markdown.render(text)
      room.send_html(html, text)
    end

    def configuration
      Mail2Matrix::Configuration
    end
    delegate [:config] => :configuration

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = BANNER

        opts.on("-sSUBJECT", "--subject=SUBJECT", "Used as a heading for the message") do |subject|
          configuration.config.message.subject = subject
        end

        opts.on("-rFROM", "--from=FROM", "[Ignored]")

        %w[- B D d E F i n t v ~ a c b r h A S].each do |x|
          opts.on("-#{x}", "[Ignored]")
        end

        opts.on_tail("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
      end
    end

    BANNER = <<~BANNER
      #{$PROGRAM_NAME} - A drop-in replacement for mail/mailx that will post messages
      #to a Matrix room.

      It tolerates all normal mail/mailx arguments, but ignores most of them as they
      are irrelevant. The only args supported at `-s` for the subject, and it reads
      the body from STDIN.

      It loads credentials for the matrix server from
      $XDG_CONFIG_DIRS/mail2matrix.conf (usually ~/.config/mail2matrix.conf), which
      is in ini format. At a minimum, it needs:

          [auth]
          token = "secret-matrix-user-token"
          server = "example.modular.im"

          [message]
          room = "#example:example.modular.im"

      You may also specify `subject` and `body` as part of the `[message]` section,
      which will be used as defaults, but the command-line args will override those
      values.

      Usage:

          echo "body" | #{$PROGRAM_NAME} [-s subject]

    BANNER
  end
end
