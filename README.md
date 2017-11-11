# Kisi notification service

When receiving a POST /events, the webhook will eventually notify via email a list of subscribers following the given rule set.

The rule set is defined in a configuration file: `config/rules.yml`.

If an event is matched by one of the rules, an email will be sent to the configured recipients with the configured subject (the use-case in mind is mainly for alarms).

The syntax of the conditions is as follows:
```yaml
  conditions:
    time: # 24h HH:MM format, UTC time!!
      begin: '18:00'
      end: '08:00'
    # The Kisi documentation did not mention an `actor_email`, but I added anyway as a possible event payload to match against the user condition
    user: 'someone@work.com'
    # action and object are case sensitive
    action: 'unlock'
    object: 'Lock'
    # note that the Kisi documentation states that the success field sent to the webhook is a string, so I followed accordingly
    success: 'false' | 'true' | 'any'
```

If any condition is not present (`nil`), then I assume this part should not be used to "filter" the event. Therefore, an empty `conditions` results in emails for each event POSTed.

The final task can be proven by running the complete test suite.

## Notes:
I made the project almost production ready. The shortcuts taken are on the operational level. So I skipped:
* setting up Redis - therefore no sidekiq
* Sendgrid - therefore no real emailing
* CI - therefore one needs to run the tests manually
* Heroku app setup - so no live environments for manual tests

The actual email could be sent in yet another queue (`.deliver_later`). I just chose deliver_now for easier tests and less moving pieces. If this would be come a bottleneck, we could optimize the code further.

Another important point of optimization is the `config/puma.rb`. No changes were made from the default rails new generated one.

## Running the project in production
For Heroku, just push to an app there.

For Kubernetes, we would need to create a container to run the web part, and another to run the job parts.

## Running the project in dev mode
Assuming RVM or Rbenv, there's a `.ruby-version` specifying the aimed version. So just ensure it's installed.

Then:
```bash
bundle install
bundle exec foreman start
```

## Running tests
```bash
bundle install
bundle exec rspec spec
```
