require_relative "test_helper"

describe "User class" do
  # describe "#initialize" do 
  # end 

  describe "self.get" do 
    it "returns a response of users list from API" do
      VCR.use_cassette("users-list-endpoint") do
        url = "https://slack.com/api/users.list"

        response = Slack::User.get(url)
        
        expect(response["ok"]).must_equal true
      end  
    end     
  end 


  describe "#send_message" do 
    it "sends a message to a selected user" do 
      VCR.use_cassette("users-list-endpoint") do 

        workspace = Slack::Workspace.new

        user = workspace.select_user("USLACKBOT")       

        expect(user.send_message("Good morning SLACKBOT!", user)).must_equal true 
      end  
    end 


    it "raises SlackApiError" do
      VCR.use_cassette("users-list-endpoint") do
        user = Slack::User.new(slack_id: "123456", name: "test-channel")

        expect{user.send_message("Hungry", user)}.must_raise SlackApiError
      end 
    end 
  end 


  describe "#details" do
    it "returns the user details" do 
      VCR.use_cassette("users-list-endpoint") do 
        slack_id = "USLACKBOT"
        name = "slackbot"
        real_name = "Slack bot"
        status_text = "Wroking remotely"
        status_emoji = "🏡"

        user = Slack::User.new(slack_id: slack_id, name: name, real_name: real_name, status_text: status_text, status_emoji: status_emoji)

        expect(user.details).must_be_kind_of Hash      
        expect(user.details.length).must_equal 5   
        expect(user.details[:slack_id]).must_equal slack_id    
        expect(user.details[:name]).must_equal name  
        expect(user.details[:real_name]).must_equal real_name  
        expect(user.details[:status_text]).must_equal status_text  
        expect(user.details[:status_emoji]).must_equal status_emoji   
      end 
    end 
  end 


  describe "self.list_all" do 
    it "creates and returns instances of users" do 
      VCR.use_cassette("users-list-endpoint") do 
        user_list = Slack::User.list_all 

        expect(user_list).must_be_kind_of Array 

        user_list.each do |user|
          expect(user).must_be_kind_of Slack::User
        end 
      end 
    end 
  end 
end