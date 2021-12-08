FROM centos:7

MAINTAINER Jamie Curnow <jc@jc21.com>
LABEL maintainer="Jamie Curnow <jc@jc21.com>"

ENV S6_FIX_ATTRS_HIDDEN=1
RUN echo "fs.file-max = 65535" > /etc/sysctl.conf

# root filesystem
COPY rootfs /

# Yum
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && yum -y install deltarpm \
    && yum -y update \
    && yum -y install which wget curl postgresql-libs unixODBC mariadb-libs ca-certificates \
    && yum -y install http://sphinxsearch.com/files/sphinx-2.3.2-1.rhel7.x86_64.rpm \
    && yum clean all \
    && rm -rf /var/cache/yum

# SSL Fix
RUN ln -s /etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt

# s6 overlay
RUN curl -L -o /tmp/s6-overlay-amd64.tar.gz "https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz" \
    && tar xzf /tmp/s6-overlay-amd64.tar.gz -C / --exclude="./bin" --exclude="./sbin" \
    && tar xzf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin

# SphinxQL port
EXPOSE 9306
# SphinxAPI port
EXPOSE 9312

# Data
VOLUME /var/lib/sphinx

# Other
ADD env/.bashrc /root/
CMD [ "/init" ]
