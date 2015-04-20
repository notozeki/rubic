# Rubic - A tiny Scheme interpreter

[![Gem Version](https://badge.fury.io/rb/rubic.svg)](http://badge.fury.io/rb/rubic)
[![Build Status](https://travis-ci.org/notozeki/rubic.svg)](https://travis-ci.org/notozeki/rubic)
[![Coverage Status](https://coveralls.io/repos/notozeki/rubic/badge.svg)](https://coveralls.io/r/notozeki/rubic)

**Rubic** is a very simple Scheme interpreter written in Ruby.

NOTE: This is my hobby project. You may find it is good for nothing in practical uses :wink:

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubic'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rubic

## Usage

Once you install this gem, the `rubic` executable can be used. Simply run it as:

    $ rubic

then the <abbr title="Read-Eval-Print Loop">REPL</abbr> will start. Or pass the Scheme source file as:

    $ rubic /path/to/your_code.scm

then the program will be executed.

You can also evaluate Scheme code from your Ruby application:

```ruby
require 'rubic'
rubic = Rubic::Interpreter.new
rubic.evaluate('(define x 100)')
rubic.evaluate('(+ x 3)')        # => 103
rubic.evaluate('(list 1 2 3)')   # => [1, [2, [3, []]]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/notozeki/rubic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
