ARG base_img
FROM nvidia/cuda:12.3.2-devel-centos7 as build

ARG version
ARG commit

RUN yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
RUN yum install -y rpm-build make
# default git has problems while cloning some repository
# RUN yum install -y https://repo.ius.io/ius-release-el7.rpm \
#  && yum install -y git222

ENV GOLANG_VERSION 1.14.3
RUN curl -sSL https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz \
    | tar -C /usr/local -xz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN go env -w  GOPROXY=https://goproxy.cn,direct

RUN mkdir -p /root/rpmbuild/{SPECS,SOURCES}

COPY gpu-manager.spec /root/rpmbuild/SPECS
COPY gpu-manager-source.tar.gz /root/rpmbuild/SOURCES

RUN echo '%_topdir /root/rpmbuild' > /root/.rpmmacros \
  && echo '%__os_install_post %{nil}' >> /root/.rpmmacros \
  && echo '%debug_package %{nil}' >> /root/.rpmmacros
WORKDIR /root/rpmbuild/SPECS
RUN rpmbuild -bb --quiet \
  --define 'version '${version}'' \
  --define 'commit '${commit}'' \
  gpu-manager.spec

FROM $base_img

ARG version
ARG commit


RUN yum install epel-release -y && \
  yum install -y which jq

# gpu manager storage
VOLUME ["/etc/gpu-manager/vm"]
VOLUME ["/etc/gpu-manager/vdriver"]
VOLUME ["/var/log/gpu-manager"]

# nvidia library search location
VOLUME ["/usr/local/host"]

ENV PATH=$PATH:/usr/local/nvidia/bin
COPY start.sh /
COPY copy-bin-lib.sh /

RUN echo "/usr/local/nvidia/lib" > /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

# cgroup
VOLUME ["/sys/fs/cgroup"]

# kubelet
VOLUME ["/var/lib/kubelet/device-plugins"]

# Install packages
COPY --from=build /root/rpmbuild/RPMS/x86_64/gpu-manager-${version}-${commit}.el7.x86_64.rpm /tmp
RUN rpm -ivh /tmp/gpu-manager-${version}-${commit}.el7.x86_64.rpm \
	&& rm -rf /tmp/gpu-manager-${version}-${commit}.el7.x86_64.rpm

# display
EXPOSE 5678

CMD ["/start.sh"]
