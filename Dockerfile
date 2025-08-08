# Gentoo stage3 base image
FROM gentoo/stage3:amd64-openrc

# Install distcc, crossdev and ccache
RUN emerge-webrsync \
    && emerge --verbose --update --newuse --deep \
        app-portage/crossdev \
        sys-devel/distcc \
        dev-util/ccache

# Prepare dedicated crossdev repository
RUN mkdir -p /var/db/repos/crossdev/{profiles,metadata} \
    && echo crossdev > /var/db/repos/crossdev/profiles/repo_name \
    && printf 'masters = gentoo\nthin-manifests = true\n' \
         > /var/db/repos/crossdev/metadata/layout.conf \
    && chown -R portage:portage /var/db/repos/crossdev \
    && mkdir -p /etc/portage/repos.conf \
    && printf '[crossdev]\nlocation = /var/db/repos/crossdev\npriority = 10\nmasters = gentoo\nauto-sync = no\n' \
         > /etc/portage/repos.conf/crossdev.conf

# Install multiple cross toolchains
ARG CROSS_TARGETS="powerpc-unknown-linux-gnu"
RUN for T in $CROSS_TARGETS ; do \
        crossdev --stable -t "$T" ; \
    done

# Create distcc masquerade links for all compilers
RUN DISTCCD_MASQ=/usr/lib/distcc/bin && \
    mkdir -p $DISTCCD_MASQ && \
    for p in $(printf '%s\n' $CROSS_TARGETS | \
               xargs -I{} echo '/usr/{}/bin/{}-*' | xargs ls -1) ; do \
        ln -s "$p" "$DISTCCD_MASQ/$(basename "$p")" ; \
    done && \
    ln -s $(type -P gcc)  $DISTCCD_MASQ/gcc && \
    ln -s $(type -P g++) $DISTCCD_MASQ/g++

# Make masquerade directory take precedence
ENV PATH="/usr/lib/distcc/bin:${PATH}" \
    DISTCC_VERBOSE=1 \
    CCACHE_DIR=/var/cache/ccache

# Create unprivileged user and ccache directory
RUN useradd -m -G users,distcc crossdevuser \
    && mkdir -p /var/cache/ccache \
    && chown -R crossdevuser:users /var/cache/ccache

USER crossdevuser
WORKDIR /home/crossdevuser

EXPOSE 3632

ENTRYPOINT ["/usr/bin/distccd", "--daemon", "--no-detach", "--log-level", "info", \
            "--user", "crossdevuser", "--allow", "0.0.0.0/0", "--port", "3632"]
