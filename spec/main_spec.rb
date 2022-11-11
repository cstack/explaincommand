require_relative "../main.rb"

describe ".parse_command_line_arguments" do
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
        parsed = parse_command_line_arguments(string)
        expect(parsed).to eq(expected)
      end
    end
  end
end

describe ".parse_man_page" do
  Dir["./man-pages/*"].each do |path|
    filename = path.split("/").last
    command = filename.split(".").first
    context filename do
      it "parses as expected" do
        string = File.read(path)
        parsed = parse_man_page(string).transform_keys(&:to_s)
        fixture_path = "./spec/fixtures/man-pages/#{command}.json"
        # File.write(fixture_path, JSON.pretty_generate(parsed))
        expected = JSON.parse(File.read(fixture_path))
        expect(parsed).to eq(expected)
      end
    end
  end
end

describe '.explain_command_line_arguments' do
  [
    [
      "ls -ltr /tmp",
      [
        ["-l", "(The lowercase letter âellâ.) List files in the long format, as  described in the The Long Format subsection below."],
        ["-t", "Sort by descending time modified (most recently modified first).  If two files have the same modification timestamp, sort their  names in ascending lexicographical order. The -r option reverses  both of these sort orders."],
        ["-r", "Reverse the order of the sort."],
      ],
    ],
  ].each do |string, expected|
    context string do
      it "explains the command" do
        explanation = explain_command_line_arguments(string)
        expect(explanation).to eq(expected)
      end
    end
  end
end