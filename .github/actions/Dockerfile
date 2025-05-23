ARG IMAGE=$TARGETARCH
FROM quay.io/pypa/manylinux_2_28_$IMAGE AS build

ARG GOOS
ARG GOVERSION
ARG GOARCH
ARG DUCKDB_LIB_PATH
ARG GO_BUILD_TAGS=''
ARG GO_BUILD_RELATIVE_DIR=''
ARG GO_CACHE
ARG GO_MOD_CACHE

# install go
ADD "https://go.dev/dl/go$GOVERSION.$GOOS-$GOARCH.tar.gz" ./go.tar.gz
RUN tar -C /usr/local -xzf go.tar.gz && rm go.tar.gz
ENV PATH="$PATH:/usr/local/go/bin"

# copy go cache
COPY ${GO_CACHE}/ libduckdb_gocache/
RUN (stat "$(go env GOCACHE)" || mkdir -p "$(go env GOCACHE)") && cp -r "libduckdb_gocache/" "$(go env GOCACHE)/" && rm -rf "libduckdb_gocache"

# copy go mod cache
COPY ${GO_MOD_CACHE}/ libduckdb_gomodcache/
RUN (stat "$(go env GOMODCACHE)" || mkdir -p "$(go env GOMODCACHE)") && cp -r "libduckdb_gomodcache/" "$(go env GOMODCACHE)/" && rm -rf "libduckdb_gomodcache"

# copy duckdb lib
COPY $DUCKDB_LIB_PATH /duckdb_libs/libduckdb_bundle.a

ENV GOOS=$GOOS
ENV GOARCH=$GOARCH
ENV CGO_ENABLED=1
ENV CPPFLAGS="-DDUCKDB_STATIC_BUILD"
ENV CGO_LDFLAGS="-lduckdb_bundle -lstdc++ -lm -ldl -L/duckdb_libs"

WORKDIR /build
COPY ../.. .

WORKDIR /build/$GO_BUILD_RELATIVE_DIR
RUN go build -o /build/__libduckdb_output_binary -tags "duckdb_use_static_lib,$GO_BUILD_TAGS"

RUN mkdir "/build/__libduckdb_gocache" && cp -r "$(go env GOCACHE)/" "/build/__libduckdb_gocache/" && chmod -R 755 "/build/__libduckdb_gocache"
RUN mkdir "/build/__libduckdb_gomodcache" && cp -r "$(go env GOMODCACHE)/" "/build/__libduckdb_gomodcache/" && chmod -R 755 "/build/__libduckdb_gomodcache"

FROM scratch
COPY --from=build /build/__libduckdb_output_binary /
COPY --from=build /build/__libduckdb_gocache/ /__libduckdb_gocache/
COPY --from=build /build/__libduckdb_gomodcache/ /__libduckdb_gomodcache/