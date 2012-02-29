# Content Spinning

`ContentSpinning` is a ruby library made to spin some text.
It manages nested spinning.

## Example

```ruby
"Hi {there|you}! I'm {efficient|productive}.".spin
# or
ContentSpinning.spin "Hi {there|you}! I'm {efficient|productive}."
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

## Todo

A few things to do :

* Specs with Rspec
* Executable

