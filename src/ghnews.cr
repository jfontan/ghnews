require "./ghnews/*"
require "./github/*"

include Ghnews

maintainer = [
  "src-d/borges",
  "src-d/go-billy",
  "src-d/go-billy-siva",
  "src-d/go-queue",
]

rule_set = [
  # Test
  Rule.new(RuleFunc.new { true }, 1),
  # Unread
  Rule.new(RuleFunc.new { |n|
    n.unread
  }, 5),
  # Older than 2 days
  Rule.new(RuleFunc.new { |n|
    t = Time.now - n.updated_at
    t.days > 2
  }, 5),
  # Older than 10 days
  Rule.new(RuleFunc.new { |n|
    t = Time.now - n.updated_at
    t.days > 10
  }, 10),
  # Is a pull request
  Rule.new(RuleFunc.new { |n|
    n.subject.type == "PullRequest"
  }, 5),
  # In the maintainer's list
  Rule.new(RuleFunc.new { |n|
    maintainer.includes?(n.repository.full_name)
  }, 20),
]

def panic(string)
  STDERR.puts(string)
  exit(1)
end

token = ENV["GITHUB_TOKEN"]?

panic("no GITHUB_TOKEN set") if !token

file = "notifications.json"

notifications = Notifications.load(file)
notifications.download(token)
notifications.save(file)

r = Rules.new(rule_set)
o = r.grade(notifications.notifications)

o.reverse.each do |g|
  n = g.notification
  puts "#{g.value} - #{n.repository.full_name} - #{n.subject.title}"
end
