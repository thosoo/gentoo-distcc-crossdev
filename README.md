# Gentoo Multi-Arch Cross-Compile Docker Project

This project provides a Docker setup for cross-compiling for Gentoo using `distcc` and `crossdev`, running natively on AMD64. It builds stable toolchains for **arm64**, **arm**, **ppc32**, and **x86** targets.

## Features

- Gentoo Stage3 AMD64 base image.
- `distcc` and `crossdev` for efficient cross-compiling.
- Stable toolchains for arm64, arm, ppc32, and x86 cross-compilation.
- Customizable `distccd` and `crossdev` settings.

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
## Configuration

- You can adjust `distccd` and `crossdev` settings in the `docker-compose.yml` file.
- For advanced configuration, modify the Dockerfile as per your requirements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Gentoo Linux
- Docker
