require "json"
require "../github/*"

module Ghnews
  alias HNotifications = Hash(String, GitHub::Notification)

  class Notifications
    JSON.mapping({
      notifications: HNotifications,
      last:          Time?,
    })

    property last : (Time | Nil) = nil
    property notifications : HNotifications = HNotifications.new

    def self.load(file : String)
      return self.new if !File.exists?(file)

      File.open(file) do |f|
        return self.from_json(f)
      end
    end

    def initialize
      @notifications = HNotifications.new
      @last = nil
    end

    def initialize(n : GitHub::Notifications)
      @notifications = HNotifications.new

      update(n)
    end

    def update(n : GitHub::Notifications)
      n.each do |d|
        @notifications[d.id] = d
        @last = d.updated_at if @last == nil || @last.not_nil! < d.updated_at
      end
    end

    def download(token : String)
      g = GitHub::Client.new(token)
      n = g.notifications(@last)
      update(n)
    end

    def save(file : String)
      File.open(file, "w") do |f|
        f.puts(to_json)
      end
    end
  end
end
