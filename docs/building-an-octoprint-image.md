# Building your own octoprint image

In some circumstances, the best approach will be to build off of the base
`octoprint/octoprint` image and add your own customizations and reproducible
builds. Here are a few common scenarios you might find yourself wanting to do this:

- you require additional OS packages for plugins
- you want to distribute your own special version of OctoPrint 
- you want a common set of plugins installed for a distributable image
- you want to [preconfigure your octoprint instance](preconfigure-your-octoprint.md)

Helpful resources on building with docker:

- [Dockerfile Tutorial with Example | Creating your First Dockerfile | Docker Training | Edureka](https://www.youtube.com/watch?v=2lU9zdrs9bM)

## Configuring Docker

We recommend enabling experimental support for your docker engine. The examples used in these docs all 
