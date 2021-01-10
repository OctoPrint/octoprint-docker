---
name: Bug report
about: Create a report to help us improve
title: "[BUG] Bug Description"
labels: bug
assignees: ''

---

<!--
Support for the docker image is provided on the octoprint discord and octoprint forum. It is recommended that if you are not experienced with docker, you use one of those support options to ask questions before opening an issue here.

This template is for bug reports only, and issues from this template will be closed if the issue is of a support nature or the user has not provided enough detail to demonstrate or reproduce an actual bug
-->
**Describe the bug**
A clear and concise description of what the bug is.

**Container Details**

please run `docker inspect --format '{{ index .Config.Labels "org.opencontainers.image.created"}}' octoprint/octoprint:<tag_you_are_using>' and list the date returned.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Desktop (please complete the following information):**
 - OS: [e.g. iOS]
 - Browser [e.g. chrome, safari]
 - Version [e.g. 22]

**Smartphone (please complete the following information):**
 - Device: [e.g. iPhone6]
 - OS: [e.g. iOS8.1]
 - Browser [e.g. stock browser, safari]
 - Version [e.g. 22]

**Additional context**
Add any other context about the problem here.
