# frozen_string_literal: true

module Mail2matrix
  # Gem identity information.
  module Identity
    def self.name
      "mail2matrix"
    end

    def self.label
      "Mail2matrix"
    end

    def self.version
      "0.1.0"
    end

    def self.version_label
      "#{label} #{version}"
    end
  end
end
