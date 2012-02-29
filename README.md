# Content Spinning

content_spinning is a ruby lib to spin some text.

## Example

```ruby
"Hi {there|you}! I'm {efficient|productive}.".spin
# or
ContentSpinning.spin "Hi {there|you}! I'm {efficient|productive}."
```

returns this array :

```ruby
["Hi there! I'm efficient.", "Hi there! I'm productive.", "Hi you! I'm efficient.", "Hi you! I'm productive."]
```

## Install

```
gem install content_spinning
```

