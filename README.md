# Mac M1 Test using Docker + CommandBox and ColdFusion 2021

We are migrating from CF2018 to CF2021. During testing it was discovered that our
previous CF setup which was using the native Adobe zip installer would not work on Mac M1 laptops.

Testing with CommandBox seemed to work so this is a test envirnment to spin up a simplified
version of our dev envirnment using CommandBox.

#### This uses:

- CommandBox
- Apache
- 'multi-stage' build with Adobe JDK and Debian (to mimic prod env)
- CFPM - new in CF2021 for package management
- CFConfig for configuring server

#### Issue:

I have everything working for the most part but have run into an issue with Apache.

Currently we are using htaccess files throughout the app to provide basic authentication.

I cannot change that.

When setting up the proxy to CommandBox I cannot figure out how to also get the authentication working.

I've tried various things with no success:

- using ```<proxy> ... </proxy>``` to configure things
- using a rewrite rule with the [P] proxy flag
