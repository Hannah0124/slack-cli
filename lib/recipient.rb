require 'httparty'
require 'dotenv'
require 'time'

class SlackApiError < StandardError; end
class NoSlackTokenError < StandardError; end

Dotenv.load 

def validate_env(token) 
  unless token
    raise NoSlackTokenError, "Could not load SLACK_TOKEN. Add `SLACK_TOKEN` in the environment variable."
  end 
end 


module Slack 

  class Recipient 

    USER_URL = "https://slack.com/api/users.list"
    CHANNEL_URL = "https://slack.com/api/conversations.list"
    MESSAGE_URL = "https://slack.com/api/chat.postMessage"
    HISTORY_URL = "https://slack.com/api/conversations.history"


    SLACK_TOKEN = {
      token: ENV["SLACK_TOKEN"]
    }

    validate_env(SLACK_TOKEN[:token])

    attr_reader :slack_id, :name 

    def initialize(slack_id: , name:)
      @slack_id = slack_id 
      @name = name 
    end 


    def send_message(text, selected)
      response = HTTParty.post(
        MESSAGE_URL,
        headers: {
          'Content-Type' => 'application/x-www-form-urlencoded'
        },
        body: {
          token: ENV["SLACK_TOKEN"],
          text: text,
          channel: selected.slack_id,
          username: "My Bot"
        }
      )

      unless response.code == 200 && response.parsed_response["ok"]
        raise SlackApiError, "There is an error when posting #{text} to #{name}, error: #{response.parsed_response["error"]}"
      end 

      return true  
    end 


    def details 
      raise NotImplementedError, 'Implement me in a child class!'
    end 


    def self.get(url, params)
      response = HTTParty.get(url, query: params)

      # TO DO
      unless response.code == 200 && response.parsed_response["ok"]
        raise SlackApiError, "We failed to get information from API"
      end 

      response_data = JSON.parse(response.body)

      return response_data
    end  


    def self.list_all 
      raise NotImplementedError, 'Implement me in a child class!'
    end 
    
    # TO DO (refactor): I was going to implement #load_message_history in Recipient so that I could use it in 2 sub classes (User, Channel). However, I was not able to find a channel ID for each user. So, instead, I did not give an end user an option (check message history) 
    # def load_message_history 
    #   raise NotImplementedError, 'Implement me in a child class!'
    # end 
  end 
end 