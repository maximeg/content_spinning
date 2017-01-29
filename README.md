# Content Spinning

[![Gem Version](https://badge.fury.io/rb/content_spinning.svg)](https://badge.fury.io/rb/content_spinning) [![Build Status](https://travis-ci.org/maximeg/content_spinning.svg?branch=master)](https://travis-ci.org/maximeg/content_spinning)

`ContentSpinning` is a ruby library made to spin some text.
It manages nested spinning.

## Example

```ruby
"Hi {there|you}! I'm {efficient|productive}.".spin
# or
ContentSpinning.spin("Hi {there|you}! I'm {efficient|productive}.")
```

returns this array :

```ruby
[
  "Hi there! I'm efficient.",
  "Hi there! I'm productive.",
  "Hi you! I'm efficient.",
  "Hi you! I'm productive."
]
```

## Install

```
gem install content_spinning
```

## Usage

### All spins

Calculating the number of possibilities:

```ruby
> ContentSpinning.new("Hi {there|you}! I'm {efficient|productive}.").count

4
```

Generating:

```ruby
> ContentSpinning.new("Hi {there|you}! I'm {efficient|productive}.").spin

[
  "Hi there! I'm efficient.",
  "Hi there! I'm productive.",
  "Hi you! I'm efficient.",
  "Hi you! I'm productive."
]
```

Beware, spins being combinatory, generating all the spins could be quite long.

### Partial spins

There is no guaranty of unicity among the results returned (this is random).
If you ask for a limit greater than the number of possibilities, this returns all the possibilities.

```ruby
> ContentSpinning.new("Hi {there|you}! I'm {efficient|productive}.").spin(limit: 2)

[
  "Hi there! I'm efficient.",
  "Hi you! I'm productive."
]

> ContentSpinning.new("Hi {there|you}! I'm {efficient|productive}.").spin(limit: 500)

[
  "Hi there! I'm efficient.",
  "Hi there! I'm productive.",
  "Hi you! I'm efficient.",
  "Hi you! I'm productive."
]
```

## Todo

A few things to do :

* Executable

