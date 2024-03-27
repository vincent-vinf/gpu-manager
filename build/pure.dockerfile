FROM registry.cn-hangzhou.aliyuncs.com/adpc/cuda:10.1-devel-centos7 as build

# install golang
ENV GOLANG_VERSION 1.14.3
RUN curl -sSL https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz \
    | tar -C /usr/local -xz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN go env -w  GOPROXY=https://goproxy.cn,direct

WORKDIR /root/gpu-manager
COPY . .
#COPY Makefile hack/ pkg/ cmd staging go.mod /root/gpu-manager/
RUN make all

#FROM ubuntu:22.04
#COPY --from=build