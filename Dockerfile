# Use Gentoo stage3 AMD64 as the base image
ARG BASE_IMAGE=gentoo/stage3:amd64-openrc
FROM ${BASE_IMAGE}

# Update the system and sync portage
RUN emerge-webrsync

# Install necessary packages including distcc, crossdev, git
RUN emerge distcc crossdev

# Set environment variables for distccd configuration
ENV DISTCCD_JOBS=4 \
    DISTCCD_ALLOW=192.168.1.0/0 \
    DISTCCD_LOG_LEVEL=info \
    DISTCCD_LOG_FILE=/home/crossdevuser/distcc.log

# Set environment variables for crossdev versions
ARG STABLE_BUILD
ARG BINUTILS_VER
ARG GCC_VER
ARG KERNEL_VER
ARG LIBC_VER
# Available arches: amd64 alpha arm arm64 hppa loong mips m68k ppc riscv s390 sparc x86
ARG CROSSDEV_TARGETS="aarch64-unknown-linux-gnu arm-unknown-linux-gnueabi powerpc-unknown-linux-gnu i686-pc-linux-gnu"

# Manually create a crossdev repository
RUN mkdir -p /var/db/repos/crossdev/{profiles,metadata} \
    && echo 'crossdev' > /var/db/repos/crossdev/profiles/repo_name \
    && echo -e 'masters = gentoo\nthin-manifests = true' > /var/db/repos/crossdev/metadata/layout.conf \
    && chown -R portage:portage /var/db/repos/crossdev

# Instruct Portage to use the new ebuild repository
RUN mkdir -p /etc/portage/repos.conf \
    && echo -e '[crossdev]\nlocation = /var/db/repos/crossdev\npriority = 10\nmasters = gentoo\nauto-sync = no' > /etc/portage/repos.conf/crossdev.conf

# Conditional execution based on STABLE for each target
RUN for target in ${CROSSDEV_TARGETS}; do \
        if [ "${STABLE_BUILD}" = "yes" ]; then \
            crossdev -S --target ${target} --show-fail-log; \
        else \
            crossdev --b "~${BINUTILS_VER}" --g "~${GCC_VER}" --k "~${KERNEL_VER}" --l "~${LIBC_VER}" --target ${target} --show-fail-log; \
        fi; \
    done

# Create a non-root user for security purposes
RUN useradd -m -G users,distcc crossdevuser

# Switch to the non-root user
USER crossdevuser

# Set working directory
WORKDIR /home/crossdevuser

# Expose distcc port
EXPOSE 3632

# Default command to keep the container running
CMD ["sh", "-c", "distccd --daemon --no-detach --jobs $DISTCCD_JOBS --allow $DISTCCD_ALLOW --log-level $DISTCCD_LOG_LEVEL --log-file $DISTCCD_LOG_FILE"]
