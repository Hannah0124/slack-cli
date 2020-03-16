require_relative 'recipient'

module Slack 
  class Channel < Recipient

    attr_reader :slack_id, :name, :topic, :member_count 

    def initialize(topic: nil, member_count: nil, **args) 
      super(**args)
      @topic = topic 
      @member_count = member_count
    end 


    def details 
      return {
        :slack_id => @slack_id,
        :name => @name, 
        :topic => @topic, 
        :member_count => @member_count
      }
    end 
    

    def self.list_all 
      response_data = self.get(CHANNEL_URL, SLACK_TOKEN)

      channels = response_data["channels"]

      return channels.map do |info|
        self.new({
          slack_id: info["id"], 
          name: info["name"], 
          topic: info["topic"]["value"], 
          member_count: info["num_members"]
        })
      end 
    end 


    # optional
    def load_message_history 
      params = {
        token: ENV["SLACK_TOKEN"],
        channel: self.slack_id, # Conversation ID 
        limit: 10
      }

      response = HTTParty.get(HISTORY_URL, {
        query: params
      })

      unless response.code == 200 && response.parsed_response["ok"]
        raise SlackApiError, "We failed to get information from API"
      end 

      response_data = JSON.parse(response.body)
      return response_data["messages"]
    end  


    # optional
    def message_history

      workspace = Slack::Workspace.new
      messages = self.load_message_history

      list = []

      messages.each do |message|
        
        if message["subtype"] != "bot_add" && message["subtype"] != "channel_purpose" && message["subtype"] != "channel_join"

          (message["username"]) ? name = message["username"] : name = workspace.find_user_by_id(message["user"]).name

          list << [name, message["text"], Time.at(message["ts"].to_f)]
        end    
      end 
      
      return list
    end 

  end 
end 