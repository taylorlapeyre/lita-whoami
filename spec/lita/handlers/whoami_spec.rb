require "spec_helper"
require "rspec/expectations"
require "rspec/mocks"

describe Lita::Handlers::Whoami, lita_handler: true do
  it "will assign a person a descriptior." do
    send_command("taylor is a bad programmer")
    expect(replies).to_not be_empty
    expect(replies.last).to eq "Okay, taylor is a bad programmer!"
  end

  it "Can tell you what people are." do
    send_command("taylor is a bad programmer")
    send_command("who is taylor")

    expect(replies.last).to eq "taylor is a bad programmer"
    expect(replies.count).to eq 2
  end

  it "Can unassign a descriptior from someone." do
    send_command("taylor is a bad programmer")
    send_command("who is taylor")

    expect(replies.last).to eq "taylor is a bad programmer"
    expect(replies.count).to eq 2

    send_command("taylor isn't a bad programmer")
    expect(replies.last).to eq "Okay, taylor is not a bad programmer."
    expect(replies.count).to eq 3

    send_command("who is taylor")
    expect(replies.last).to eq "taylor is "
  end

  it "Can describe everyone" do
    send_command("taylor is a bad programmer")
    send_command("danny is a mediocre programmer")

    send_command("I don't know who anyone is")
    expect(replies.last).to include 'taylor is a bad programmer'
    expect(replies.last).to include 'danny is a mediocre programmer'
  end
end
