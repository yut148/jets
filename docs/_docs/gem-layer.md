---
title: Gem Layer
---


## Advantages of Gem Layer

There are some huge advantages to lazy loading which is why Jets elects to make it the default setting.

With lazying loading enabled, the actual code size of your Jets project code is usually in the KB range.  This takes the code size down to under the [3 MB](https://docs.aws.amazon.com/lambda/latest/dg/limits.html) limit, which is key. At the smaller code size, you are able to see and edit your Lambda code in the AWS Lambda console code editor live.  It is extremely helpful to debug and test without a full deploy.

Another advantage of lazying loading is that Jets is able to upload the bundled external dependencies like Ruby and Gems separately from the application code itself. This allows Jets to optimize the deploy process and upload the large bundled file only when it changes.  On a slow internet connection this significantly improves your [development speed]({% link _docs/faster-development.md %}) and happiness.

<a id="prev" class="btn btn-basic" href="{% link _docs/faster-development.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/lazy-loading.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
