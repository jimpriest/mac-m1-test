# Mac M1 Test using Docker + CommandBox and ColdFusion 2021

We are migrating from CF2018 to CF2021. During testing it was discovered that our
previous CF setup which was using the native Adobe zip installer would not work on Mac M1 laptops.

This is a simplified test to spin up a version of our dev environment using CommandBox.

#### This uses:

- CommandBox
- Apache
- 'multi-stage' build with Adobe JDK and Debian (to mimic prod env)
- CFPM - new in CF2021 for package management
- CFConfig for configuring server

#### URLs

- Site: http://local.local/admin/


