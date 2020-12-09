## Version 3.0.0 Changelog

- plugins will now persist in the `/octoprint` volume (see #71 and #44)
- Settings unique to docker (such as restarting octoprint and webcam configs), are now pre-configured (implemented in #132)
- Backup/restore will now work with the docker image (fixed #92 via #135)
- the creation of `edge`, `canary`, and `bleeding` tags. See README for details on how to use these tags

### Breaking changes

PR #135 introduced a change that will not affect most users, but may be a breaking change for existing users that are using a volume mounting strategy other than the recommended strategy. Details follow: 

-  `/octoprint/octoprint` and `/octoprint/plugins` folders are now explicitly created during docker build
- octoprint service basedir is now `/octoprint/octoprint` (was previously `/octoprint`)
- the recommended mount path for the `config-editor` container to has been changed to `octoprint:/octoprint`. See updated examples and usage info in `docker-compose.yml` and `README`.

Due to the changes of the folder structure below the `/octoprint` directory, where before the root context of the volume mount looked like this:

```
/octoprint
├── config.backup
├── config.yaml
├── data
│   ├── announcements
│   ├── appkeys
│   ├── backup
│   ├── pluginmanager
│   ├── preemptive_cache_config.yaml
│   └── softwareupdate
├── generated
│   └── webassets
├── logs
│   ├── octoprint.log
│   ├── plugin_bedlevelvisualizer_debug.log
│   ├── plugin_pluginmanager_console.log
│   └── plugin_softwareupdate_console.log
├── octoprint
│   ├── config.backup
│   ├── config.yaml
│   ├── data
│   ├── generated
│   ├── logs
│   ├── plugins
│   ├── printerProfiles
│   ├── scripts
│   ├── slicingProfiles
│   ├── timelapse
│   ├── translations
│   ├── uploads
│   ├── users.yaml
│   ├── virtualSd
│   └── watched
├── plugins
│   ├── bin
│   └── lib
├── printerProfiles
│   └── _default.profile
├── scripts
├── slicingProfiles
├── timelapse
│   └── tmp
├── translations
├── uploads
├── virtualSd
└── watched
```
It will now look like this:

```
/octoprint
├── octoprint
│   ├── config.backup
│   ├── config.yaml
│   ├── data
│   ├── generated
│   ├── logs
│   ├── plugins
│   ├── printerProfiles
│   ├── scripts
│   ├── slicingProfiles
│   ├── timelapse
│   ├── translations
│   ├── uploads
│   ├── virtualSd
│   └── watched
└── plugins
```

The `/octoprint/plugins` directory is the python libraries path, and `/octoprint/octoprint/plugins`
is the path for plugin data and configuration.  Prior to this change, both of these things
existed in the `/octoprint/plugins` folder, polluting it's purpose.

This new method will allow savvy users to create distinct volumes for plugin binaries and
octoprint configuration data, giving them more ability to selectively control how state and
memory consumption are utilized in their octoprint image usage/distribution strategies.

## 2.0.0

### BREAKING CHANGES

- All usage of `MJPEG` has been replaced with `MJPG` for consistency. For now,values passed to `MJPEG_STREAMER_INPUT` will be coerced for backwards compatibility
- Webcam support is now _disabled_ by default, and enabled by passing the environment variable `ENABLE_MJPG_STREAMER=true`

## 1.0.0

BREAKING CHANGES for all existing users on their next pull, as this image will replace the existing tagged images once this PR is accepted. We should increased traffic here and on discord for a while. @foosel it would probably be good to add a blog post about this, or include a snippet of info about it in the next blog post. If you want me to author that content, just let me know what approach you want to take.

1.0.0 This will be considered the 1.0.0 release of the official image for octoprint, and will be tagged as such in this git repo once accepted.

Overview
Changed Docker.camera to Dockerfile
updated workflows
updated usage documentation for usage instructions
Changes
made the container volume for configs /octoprint, which is symlinked to ~/.octoprint (this was /data for the @nunofgs image
primary container port is now 80 (was formerly 5000 for the default image, and 8888 for the -camera image
removed cura (will add to feature backlog). Existing implementation was not working anyways, and now that we're s6 based, we need to set it up as a service
Other
added a web-accessible configuration editor service to the example compose file (see usage docs in README)
moved the old Dockerfile to /minimal folder, for the eventuality that we'll create a single process image container only octoprint at some point in the future
@nunofgs this should bring the official image completely in line with your nunofgs/octoprint image, meaning you can now archive github.com/nunofgs/docker-octoprint
