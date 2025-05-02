ARG IMAGE=$TARGETARCH
FROM quay.io/pypa/manylinux_2_28_$IMAGE AS build

ARG GOOS
ARG GOVERSION
ARG GOARCH
ARG DUCKDB_LIB_PATH
ARG GO_BUILD_TAGS=''
ARG GO_BUILD_RELATIVE_DIR=''

# install go
ADD "https://go.dev/dl/go$GOVERSION.$GOOS-$GOARCH.tar.gz" ./go.tar.gz
RUN tar -C /usr/local -xzf go.tar.gz && rm go.tar.gz
ENV PATH="$PATH:/usr/local/go/bin"

# copy duckdb lib
COPY $DUCKDB_LIB_PATH /duckdb_libs/libduckdb_bundle.a

ENV GOOS=$GOOS
ENV GOARCH=$GOARCH
ENV CGO_ENABLED=1
ENV CPPFLAGS="-DDUCKDB_STATIC_BUILD"
ENV CGO_LDFLAGS="-lduckdb_bundle -lstdc++ -lm -ldl -L/duckdb_libs"

WORKDIR /build
COPY .. .

WORKDIR /build/$GO_BUILD_RELATIVE_DIR
RUN go build -o /build/__libduckdb_output_binary -tags "duckdb_use_static_lib,$GO_BUILD_TAGS"

FROM scratch
COPY --from=build /build/__libduckdb_output_binary /