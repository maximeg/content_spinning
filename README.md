# Content Spinning

content_spinning is a ruby lib to spin some text.

```ruby
"Hi {there|you}! I'm {efficient|productive}.".spin
```

returns :

```ruby
["Hi there! I'm efficient.", "Hi there! I'm productive.", "Hi you! I'm efficient.", "Hi you! I'm productive."]
```

## Install

```
gem install content_spinning
```

