require "json"
require "halite"

module GitHub
  class Notification
    JSON.mapping({
      id:               String,
      unread:           Bool,
      reason:           String,
      updated_at:       {type: Time, converter: Time::Format.new("%FT%TZ")},
      subject:          Subject,
      repository:       Repository,
      url:              String,
      subscription_url: String,
      last_read_at:     {
        type: Time, converter: Time::Format.new("%FT%TZ"), nilable: true,
      },
      archived: {
        type: Bool, default: false,
      },
    })
  end

  class Subject
    JSON.mapping({
      title:              String,
      url:                String,
      latest_comment_url: String?,
      type:               String,
    })
  end

  class Repository
    JSON.mapping({
      id:          UInt64,
      node_id:     String,
      name:        String,
      full_name:   String,
      private:     Bool,
      html_url:    String,
      description: String?,
      fork:        Bool,
      url:         String,
      # TODO: owner
    })
  end

  alias Notifications = Array(Notification)

  class Client
    ENDPOINT = "https://api.github.com"

    def initialize(@token : String)
      if @token.empty?
        raise "Token should not be empty"
      end
    end

    def client
      Halite.auth("Bearer #{@token}")
    end

    def get(
      path : String,
      params : (Hash(String, _) | Nil) = nil
    ) : Halite::Response
      url = "#{ENDPOINT}/#{path}"

      client.get(url, params: params)
    end

    def notifications(
      time : (Time | Nil) = nil,
      params : (Hash(String, _) | Nil) = nil
    ) : Notifications
      notifications = Notifications.new
      json = Array(String).new
      page = 1

      p = params || Hash(String, String).new

      while true
        response = get("notifications", p.merge({"page" => page.to_s}))
        if !response.success?
          raise "Could not get notifications: " +
                "(#{response.status_code}) #{response.status_message}"
        end

        data = Array(Notification).from_json(response.body)
        return notifications if data.size == 0

        if time
          data.each do |n|
            if n.updated_at < time
              return notifications
            else
              notifications << n
            end
          end
        else
          notifications += data
        end

        page += 1
      end
    end
  end
end
