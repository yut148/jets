---
title: Email Sending
---

Jets supports sending emails via ActionMailer.

## Configuration

You can configure it with [initializers](http://rubyonjets.com/docs/initializers/).  Example:

```ruby
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  address:         ENV['SMTP_ADDRESS'],
  port:            587,
  domain:          ENV['SMTP_DOMAIN'],
  authentication:  :login,
  user_name:       ENV['SMTP_USER_NAME'],
  password:        ENV['SMTP_PASSWORD'],
  enable_starttls_auto: true
}
```

We can configure the variables with [env files]({% link _docs/env-files.md %}).  Example:

.env.production:

```sh
SMTP_ADDRESS=
SMTP_DOMAIN=
SMTP_USER_NAME=
SMTP_PASSWORD=
```

## Testing SMTP

One way to test SMTP server connection is with telnet. Example:

    $ telnet email-smtp.us-west-2.amazonaws.com 587
    Connected to email-smtp.us-west-2.amazonaws.com.
    Escape character is '^]'.
    telnet> quit
    $

Note, to escape out of the telnet session you have to use the escape sequence `^]`.  That's the control key plus close square bracket key.  Then you can type `quit`.

## Synchronous Sending
Though ActiveMailer itself supports sending email asynchronously, Jets use of ActionMailer does not currently. Emails are delivered synchronously. Asynchronously support will be added in time and will probably come in the form or an ActiveJob Lambda function adapter. Pull requests are welcome.

<a id="prev" class="btn btn-basic" href="{% link _docs/email-sending.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/email-sending.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
