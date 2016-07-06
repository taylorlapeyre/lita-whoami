require "spec_helper"
require "rspec/expectations"
require "rspec/mocks"

describe Lita::Handlers::Whoami, lita_handler: true do

  let(:bot_user) { Lita::User.create('1', name: 'slackbot') }

  it "will assign a person a descriptior" do
    send_command 'taylor is a bad programmer'

    expect(replies).to_not be_empty
    expect(replies.last).to eq "Okay, taylor is a bad programmer!"
  end

  it "won't accept assignments from bots" do
    send_command 'taylor is a good programmer', as: bot_user

    expect(replies).to be_empty
  end

  it "definitely won't accept 'Do Not Disturb'-related messages" do
    send_command 'taylor is currently in Do Not Disturb mode and may not be alerted of this message right away. If it’s urgent, click here...'

    expect(replies).to be_empty
  end

  it "can tell you what people are" do
    send_command("taylor is a bad programmer")
    send_command("who is taylor")

    expect(replies.last).to eq "taylor is a bad programmer"
    expect(replies.count).to eq 2
  end

  it "can unassign a descriptor from someone" do
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

  it "can describe everyone" do
    send_command("taylor is a bad programmer")
    send_command("danny is a mediocre programmer")

    send_command("I don't know who anyone is")
    expect(replies.last).to include 'taylor is a bad programmer'
    expect(replies.last).to include 'danny is a mediocre programmer'
  end
end
