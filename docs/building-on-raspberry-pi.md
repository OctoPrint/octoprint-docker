## Docker build error on Raspbian OS

If you attempt to build the docker image on raspbian you may encounter the following error, this is resolved by the steps below.

```
docker build .
Sending build context to Docker daemon    404kB
Step 1/34 : ARG PYTHON_BASE_IMAGE=3.8-slim-buster
Step 2/34 : FROM ubuntu AS s6build
 ---> bcf7edb34eae
Step 3/34 : ARG S6_RELEASE
 ---> Using cache
 ---> 99f464256f7d
Step 4/34 : ENV S6_VERSION ${S6_RELEASE:-v2.1.0.0}
 ---> Using cache
 ---> 50eaf72a62cb
Step 5/34 : RUN apt-get update
 ---> Running in 0142d3ca0ea6
Get:1 http://ports.ubuntu.com/ubuntu-ports focal InRelease [265 kB]
Get:2 http://ports.ubuntu.com/ubuntu-ports focal-updates InRelease [114 kB]
Get:3 http://ports.ubuntu.com/ubuntu-ports focal-backports InRelease [101 kB]
Get:4 http://ports.ubuntu.com/ubuntu-ports focal-security InRelease [109 kB]
Err:1 http://ports.ubuntu.com/ubuntu-ports focal InRelease
  At least one invalid signature was encountered.
Err:2 http://ports.ubuntu.com/ubuntu-ports focal-updates InRelease
  At least one invalid signature was encountered.
Err:3 http://ports.ubuntu.com/ubuntu-ports focal-backports InRelease
  At least one invalid signature was encountered.
Err:4 http://ports.ubuntu.com/ubuntu-ports focal-security InRelease
  At least one invalid signature was encountered.
Reading package lists...
W: GPG error: http://ports.ubuntu.com/ubuntu-ports focal InRelease: At least one invalid signature was encountered.
E: The repository 'http://ports.ubuntu.com/ubuntu-ports focal InRelease' is not signed.
W: GPG error: http://ports.ubuntu.com/ubuntu-ports focal-updates InRelease: At least one invalid signature was encountered.
E: The repository 'http://ports.ubuntu.com/ubuntu-ports focal-updates InRelease' is not signed.
W: GPG error: http://ports.ubuntu.com/ubuntu-ports focal-backports InRelease: At least one invalid signature was encountered.
E: The repository 'http://ports.ubuntu.com/ubuntu-ports focal-backports InRelease' is not signed.
W: GPG error: http://ports.ubuntu.com/ubuntu-ports focal-security InRelease: At least one invalid signature was encountered.
E: The repository 'http://ports.ubuntu.com/ubuntu-ports focal-security InRelease' is not signed.
The command '/bin/sh -c apt-get update' returned a non-zero code: 100
```

This steps are direct from [Method 2 of the accepted answer](https://askubuntu.com/questions/1263284/apt-update-throws-signature-error-in-ubuntu-20-04-container-on-arm)

Following the steps, it will take you to [Package: libseccomp2](https://packages.debian.org/sid/libseccomp2), you should determine the correct achetecture of your device

```
dpkg --print-architecture
```

Select that page from the list, Pi 4 on Raspbian OS should be `armhf`, download the current package from a mirror listed, ie:

```
http://ftp.de.debian.org/debian/pool/main/libs/libseccomp/libseccomp2_2.5.0-3+b1_armhf.deb
```

Once downloaded install the package manually `sudo dpkg -i libseccomp2_2.5.0-3+b1_armhf.deb`

You should now be able to complete the docker image build with out the above error.

