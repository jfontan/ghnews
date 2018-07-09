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
  Rule.new(RuleFunc.new { true }, 1),
  Rule.new(RuleFunc.new { |n|
    n.unread
  }, 5),
  Rule.new(RuleFunc.new { |n|
    t = Time.now - n.updated_at
    t.days > 2
  }, 5),
  Rule.new(RuleFunc.new { |n|
    t = Time.now - n.updated_at
    t.days > 10
  }, 10),
  Rule.new(RuleFunc.new { |n|
    n.subject.type == "PullRequest"
  }, 5),
  Rule.new(RuleFunc.new { |n|
    res = maintainer.includes?(n.repository.full_name)

    puts n.repository.full_name if res

    res
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

o.each do |g|
  n = g.notification
  puts "#{g.value} - #{n.repository.full_name} - #{n.subject.title}"
end
