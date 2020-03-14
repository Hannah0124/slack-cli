require_relative "test_helper"

describe "Channel class" do 
  # describe "#initialize" do 
  # end 

  describe "self.get" do 
    it "returns a response of channels list from API" do 
      VCR.use_cassette("Channel.get") do 
        url = "https://slack.com/api/channels.list"
        query = {
          token: ENV["SLACK_TOKEN"]
        }

        response = Slack::Channel.get(url, query)

        expect(response["ok"]).must_equal true
      end 
    end
  end 


  describe "#details" do
    it "returns the channel details" do 
      VCR.use_cassette("Channel#details") do 
        slack_id = "CV60LA20G"
        name = "general"
        topic = "Hot pot"
        member_count = 5

        channel = Slack::Channel.new(slack_id: slack_id, name: name, topic: topic, member_count: member_count)

        expect(channel.details).must_be_kind_of Array      
        expect(channel.details.length).must_equal 4   
        expect(channel.details[0]).must_equal slack_id    
        expect(channel.details[1]).must_equal name  
        expect(channel.details[2]).must_equal topic  
        expect(channel.details[3]).must_equal member_count    
        
        (0..2).each do |i|
          expect(channel.details[i]).must_be_kind_of String
        end 

        expect(channel.details[3]).must_be_kind_of Integer
      end 
    end 
  end 


  describe "self.list_all" do 
    it "creates and returns instances of channels" do 
      VCR.use_cassette("Channel.list_all") do 
        channel_list = Slack::Channel.list_all

        expect(channel_list).must_be_kind_of Array

        channel_list.each do |channel|
          expect(channel).must_be_kind_of Slack::Channel 
        end 
      end 
    end 
  end 
end 