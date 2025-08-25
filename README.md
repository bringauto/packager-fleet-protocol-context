# BringAuto Package Context Directory

This Context directory is used for generating Packages for Fleet Protocol. It is a component of [BacPack system]. The build of Packages is done by [Packager] and the built Packages are stored in this [Package Repository].

## Compatibility

- [Packager] v1.2.0 or newer

## `config` Directory

This directory is not specified by [Context Directory Specification]. It contains common configuration files for the build process.

## Helper Scripts

- **`add_docker_to_matrix.sh`** - Adds a new Docker image to all package JSON files in the context directory. In the example, it adds the `ubuntu2310` Docker image to all package JSON files.

- **`change_docker_name.sh`** - Changes the Docker image name in all package JSON files in the context directory. In the example, it changes `fleet-os-2` to `fleet-os-3`.



[BacPack system]: https://github.com/bacpack-system
[Packager]: https://github.com/bacpack-system/packager
[Package Repository]: https://gitea.bringauto.com/fleet-protocol/package-repository
[Context Directory Specification]: https://github.com/bacpack-system/packager/blob/master/doc/ContextStructure.md
