# Use Gentoo stage3 AMD64 as the base image
FROM gentoo/stage3:amd64-openrc

# Update the system and sync portage
RUN emerge-webrsync

# Install necessary packages including distcc, crossdev, git
RUN emerge distcc crossdev

# Set environment variables for distccd configuration
ENV DISTCCD_JOBS=4 \
    DISTCCD_ALLOW=0.0.0.0/0 \
    DISTCCD_LOG_LEVEL=info \
    DISTCCD_LOG_FILE=/var/log/distcc.log

# Set environment variables for crossdev versions
ARG BINUTILS_VER
ARG GCC_VER
ARG KERNEL_VER
ARG LIBC_VER
ARG CROSSDEV_TARGET=ppc32-unknown-linux-gnu

# Configure crossdev with specific versions
RUN crossdev --b "${BINUTILS_VER}" --g "${GCC_VER}" --k "${KERNEL_VER}" --l "${LIBC_VER}" --target ${CROSSDEV_TARGET}

# Create a non-root user for security purposes
RUN useradd -m -G users,distcc crossdevuser

# Switch to the non-root user
USER crossdevuser

# Set working directory
WORKDIR /home/crossdevuser

# Expose distcc port
EXPOSE 3632

# Default command to keep the container running
CMD ["sh", "-c", "distccd --daemon --no-detach --user crossdevuser --jobs $DISTCCD_JOBS --allow $DISTCCD_ALLOW --log-level $DISTCCD_LOG_LEVEL --log-file $DISTCCD_LOG_FILE"]
