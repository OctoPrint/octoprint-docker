# Contributing to the official octoprint Docker image

Call for maintainers! Are you experienced with Docker? Are you an OctoPrint enthusiast?
Do you have a hour or more of time to spare each week answering questions about octoprint-docker
and reviewing PR's? Let us know! 

If this sounds like you, join the [OctoPrint Discord][] and message `@CHIEFdotJS` in the `#dev-docker` channel.

- [Contributing to the official octoprint Docker image](#contributing-to-the-official-octoprint-docker-image)
  - [Pull Requests](#pull-requests)
  - [Building images](#building-images)
    - [Smoke test](#smoke-test)
    - [Simple test images](#simple-test-images)
    - [Testing your changes on all architectures](#testing-your-changes-on-all-architectures)
  - [How the workflows run](#how-the-workflows-run)
    - [Build Images](#build-images)
    - [Release Images](#release-images)
    - [In a fork](#in-a-fork)

## Pull Requests

- Pull Requests that are intended to fix a bug should have a related issue. It is acceptable to create the issue
at the time you open the PR.
  - Pull Requests that are for fixing typos, updating docs, or adding features/enhancements can be submitted without a related issue
  - Pull Requests that add enhancements should have an adequate description, and should make any relevant changes to documentation
- Pull Requests that will result in new images being published must build on all supported architectures (`arm64,arm/v7,amd64`) (see [Testing your changes on all architectures](#testing-your-changes-on-all-architectures))
- any documentation should be exclusive to this project, or affect the majority of users/contributors.
- any packages/dependencies added to the image should be available on all supported architectures, AND:
  - should be required by the majority of users or plugins OR
  - be bundled by OctoPi (try to increase parity with usage docs of OctoPi whenever possible)

## Building images

Prerequisites:

- docker and its dependencies installed and up to date, including the buildx and compose plugins

### Smoke test

To check that an image starts and serves OctoPrint, run:

```
make smoke           # main image, answers on container port 80
make smoke-minimal   # minimal image, answers on container port 5000
```

Each target builds the image for your machine's architecture, starts it, and waits up to two minutes for an HTTP
answer. It also checks that the installed OctoPrint version matches `octoprint_ref`, which defaults to the latest
stable release. CI runs the same check, `scripts/smoke-test.sh`, on every pull request.

### Simple test images

Simple test images are built only for the architecture of the machine you are on, using docker compose.

We have simplified running the docker compose commands using the Makefile. To build and run the test image,
make your changes to the repo, then run:

```
make build && make up
```

This will build the image from the main Dockerfile, and stand it up, with the logs running in the terminal.
Octoprint will be accessible on [http://localhost:53333](), and the config-editor will be stood up on [http://localhost:8443]()

### Testing your changes on all architectures

Before submitting your changes, you should make sure the image builds on all supported architectures. 

Running `make test` will build the image for all supported architectures, using cache from both your local machine
and the latest upstream docker image tag.

If you don't have multi-arch support enabled on your machine, you can run `make setup-multi-arch` to add this support.

## How the workflows run

There are two workflows, and both run unchanged in forks. Neither needs any secrets or repository variables:
publishing uses the workflow's own `GITHUB_TOKEN`.

### Build Images

[`build.yml`](.github/workflows/build.yml) runs on pull requests into `main` and on pushes to any other branch. It never
publishes anything.

- It builds only the images whose files changed, as listed in [`.github/filters.yml`](.github/filters.yml). Changes to
  `build.yml`, `filters.yml` or `scripts/smoke-test.sh` build both images.
- For each image it builds for amd64, runs `scripts/smoke-test.sh` against it, then builds for all three platforms.
- Every run also runs `scripts/test-release-scripts.sh`, so changes to the release logic are tested before they reach
  `main`.

### Release Images

[`release.yml`](.github/workflows/release.yml) builds, smoke-tests and publishes both images to
`ghcr.io/<owner>/octoprint`, where `<owner>` is the lowercased owner of the repository it runs in. In
`OctoPrint/octoprint-docker` that's `ghcr.io/octoprint/octoprint`; in a fork owned by `jane`, it's
`ghcr.io/jane/octoprint`.

| Trigger | OctoPrint version built |
| --- | --- |
| A push to `main` that changes an image, the smoke test or the release workflow | The latest stable release |
| A manual run: Actions » Release Images » Run workflow | The version you enter, such as `2.0.2` or `dev`. Empty means the latest stable release |
| A `released`, `prereleased` or `dev` dispatch | The release or branch it names. OctoPrint's own repository sends these, so only `OctoPrint/octoprint-docker` gets them |

| Main image | Minimal image | Points at |
| --- | --- | --- |
| `X.Y.Z` | `X.Y.Z-minimal` | That OctoPrint release |
| `X.Y`, `X`, `latest` | `X.Y-minimal`, `X-minimal`, `minimal` | The latest stable release |
| `edge` | `edge-minimal` | The newest release, prereleases included |
| `dev` | `dev-minimal` | OctoPrint's `dev` branch |

Every tag also gets a `-pythonX.Y` alias, such as `latest-python3.13` or `2.0.2-minimal-python3.13`, with the Python
version read from the image that was just built. [`scripts/release-plan.sh`](scripts/release-plan.sh) decides the
version and which tags move, and [`scripts/release-tags.sh`](scripts/release-tags.sh) turns that into tags.

Release builds don't use a layer cache and always pull the base image, so every release includes current Debian
security updates.

### In a fork

- **Pushing to your fork's `main` publishes.** Merging a change to an image into your `main` publishes the latest
  stable OctoPrint release to `ghcr.io/<you>/octoprint`, with the tags above. If you don't want that, disable
  Release Images in your fork's Actions tab.
- **The first publish creates a private package.** To let others pull your test images, open the package from the
  Packages tab of your profile and change its visibility to public.
- **Actions must be enabled** on the fork. Nothing else needs setting up.
- **Pull requests from your fork** into `OctoPrint/octoprint-docker` run Build Images in this repository too.

[OctoPrint Discord]: https://discord.octoprint.org
