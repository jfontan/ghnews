# ghnews

Show GitHub notifications

## Installation

To compile the executable you can execute:

```
$ shards build
```

Then drop `bin/ghnews` binary somewhere in the path.

## Usage

You need a GitHub token with permissions to read notifications. To create a new token you can follow instructions from [GitHub Help](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/). The token is then specified using `GITHUB_TOKEN` environment variable:

```
$ GITHUB_TOKEN=my_secret_token ghnews
```

Right now this will cache notifications in a file called `notifications.json` in the current directory.

## Development

The set of rules is an array of functions and an amount of points. If the function evaluates to `true` then the points are added to the notification. Example:

```crystal
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
```

## Contributing

1. Fork it (<https://github.com/jfontan/ghnews/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [jfontan](https://github.com/jfontan) Javi Fontan - creator, maintainer
