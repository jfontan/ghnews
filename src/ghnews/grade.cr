require "json"
require "../github/*"

module Ghnews
  alias RuleFunc = Proc(GitHub::Notification, Bool)

  struct Grade
    property id, value, notification
    def initialize(
      @id : String,
      @notification : GitHub::Notification,
      @value : Int32)
    end
  end

  class Rule
    def initialize(@func : RuleFunc, @value : Int32)
    end

    def grade(data : GitHub::Notification) : Int32
      puts @func.call(data)
      return @func.call(data) ? @value : 0
    end
  end

  class Rules
    def initialize(@rules : Array(Rule))
    end

    def grade(data : HNotifications) : Array(Grade)
      res = Array(Grade).new

      data.each do |k, d|
        grade = Grade.new(k, d, 0)

        @rules.each do |r|
          grade.value += r.grade(d)
        end

        res << grade
      end

      res.sort! { |a, b| b.value <=> a.value }
      return res
    end
  end
end
