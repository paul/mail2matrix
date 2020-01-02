# frozen_string_literal: true

require "spec_helper"

RSpec.describe Mail2Matrix::CLI do
  let(:options) { [] }
  let(:command_line) { Array(command).concat options }
  let(:stdin) { StringIO.new("") }
  let(:cli) { described_class.start command_line, stdin }

  shared_examples_for "a help command" do
    it "prints usage" do
      pattern = Mail2Matrix::CLI::BANNER

      expect { cli }
        .to raise_error(SystemExit)
        .and output(include(pattern)).to_stdout
    end
  end

  context "with no args" do
    let(:command) { nil }

    it_behaves_like "a help command"
  end

  describe "--help" do
    let(:command) { "--help" }

    it_behaves_like "a help command"
  end

  describe "-h" do
    let(:command) { "-h" }

    it_behaves_like "a help command"
  end
end
