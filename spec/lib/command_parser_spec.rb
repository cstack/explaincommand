require 'rails_helper'

describe CommandParser do
  describe ".parse" do
    [
      [
        "ls",
        {
          "command": "ls",
          "flags": [],
          "arguments": [],
        }
      ],
      [
        "ls -l",
        {
          "command": "ls",
          "flags": ["-l"],
          "arguments": [],
        }
      ],
      [
        "ls -lh",
        {
          "command": "ls",
          "flags": ["-l", "-h"],
          "arguments": [],
        }
      ],
      [
        "ls -ltr",
        {
          "command": "ls",
          "flags": ["-l", "-t", "-r"],
          "arguments": [],
        }
      ],
      [
        "ls --version",
        {
          "command": "ls",
          "flags": ["--version"],
          "arguments": [],
        }
      ],
      [
        "ls /tmp",
        {
          "command": "ls",
          "flags": [],
          "arguments": ["/tmp"]
        }
      ],
      [
        "ls -ld /tmp",
        {
          "command": "ls",
          "flags": ["-l", "-d"],
          "arguments": ["/tmp"]
        }
      ],
      [
        "ls --color=auto",
        {
          "command": "ls",
          "flags": [["--color", "auto"]],
          "arguments": []
        }
      ],
    ].each do |string, expected|
      context string do
        it "parses as expected" do
          parsed = described_class.parse(string)
          expect(parsed).to eq(expected)
        end
      end
    end
  end
end