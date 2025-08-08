# Gentoo Multi-Arch Cross-Compile Docker Project

This project provides a Docker setup for building multiple Gentoo cross-compilers with `crossdev` and exposing them via `distcc` on a single container. One instance can serve ARM, AArch64, PowerPC or any other target simultaneously on TCP port 3632.

## Features

- Gentoo Stage3 AMD64 base image.
- `crossdev` builds several cross toolchains specified via `CROSS_TARGETS`.
- Compilers are linked into the `distcc` masquerade directory so a single daemon exposes them all.
- `ccache` support for faster rebuilds.
- Configures a dedicated `crossdev` Portage repository and runs `distccd` as the unprivileged `crossdevuser`.

## Getting Started

### Prerequisites

- Docker and Docker Compose installed on your host machine.

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/thosoo/gentoo-distcc-crossdev.git
   ```
2. Navigate to the cloned directory:
   ```
   cd gentoo-distcc-crossdev
   ```
3. Build and run the Docker container:
   ```
   docker compose up --build
   ```

The default `docker-compose.yml` builds toolchains for `armv7a-unknown-linux-gnueabihf`, `aarch64-unknown-linux-gnu` and `powerpc-unknown-linux-gnu`. Edit the `CROSS_TARGETS` build argument in `docker-compose.yml` to customise this list.

## Using the distcc server

Point your clients at the container and call the prefixed compilers. Example for an AArch64 client:

```sh
export DISTCC_HOSTS="<container-ip>:3632/12,lzo"
export CC="distcc aarch64-unknown-linux-gnu-gcc"
make -j24
```

`distcc` will dispatch compilation to the container and automatically pick the right toolchain based on the compiler prefix.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Gentoo Linux
- Docker
