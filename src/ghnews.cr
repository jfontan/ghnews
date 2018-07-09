require "./ghnews/*"
require "./github/*"

def panic(string)
  STDERR.puts(string)
  exit(1)
end

token = ENV["GITHUB_TOKEN"]?

panic("no GITHUB_TOKEN set") if !token

g = GitHub::Client.new(token)
n = g.notifications

pp n
