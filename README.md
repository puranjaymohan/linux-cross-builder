<!--
SPDX-FileCopyrightText: 2023 Rivos Inc.

SPDX-License-Identifier: Apache-2.0
-->

# ARM cross-builder

arm-cross-builder contains Dockerfiles to generate a container image
that is:

* An x86-64 RISC-V cross-compiler environment suitable to build a
  armhf kernel image, the corresponding kselftest.
* A armhf rootfs, that shares the same libraries as the
  cross-compiler environment. This rootfs is used to execute the
  kselftest.

Create the Docker container:
```
docker build -f Dockerfile . -t debain-arm-builder
```
You now have a container named "debian-arm-builder".

Run the container, pointing to your Linux kernel source tree,
e.g. `/src/linux`:
```
docker run --tty --interactive --privileged --volume "/src/linux":/workspace debian-arm-builder:latest /bin/bash
```

In the container, build the kernel, and the kselftest using:
```
build-selftest
```

When the build is complete, the following artifacts reside in
`/src/linux`:
* `rootfs.ext4` contains the rootfs
* `initramfs` the rootfs with the kselfself bundled
* `arch/arm/boot/zImage` contains the kernel Image

The image is created. Boot the image, e.g.:
```
sudo ./run.sh 
```
