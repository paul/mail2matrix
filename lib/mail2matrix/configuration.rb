# frozen_string_literal: true

require "dry-configurable"
require "inifile"

module Mail2Matrix
  class Configuration
    extend Dry::Configurable

    setting :auth do
      setting :username
      setting :password
      setting :token
      setting :server
    end

    setting :message do
      setting :room
      setting :subject
      setting :body
    end

    def self.load_from(path)
      ini = IniFile.load path.to_s
      ini.each do |section, k, v|
        config.public_send(section.to_sym).public_send(:"#{k}=", v)
      end
    end
  end
end
