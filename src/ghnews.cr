require "./ghnews/*"
require "./github/*"

def panic(string)
  STDERR.puts(string)
  exit(1)
end

token = ENV["GITHUB_TOKEN"]?

panic("no GITHUB_TOKEN set") if !token

file = "notifications.json"

notifications = Ghnews::Notifications.load(file)
notifications.download(token)
notifications.save(file)

