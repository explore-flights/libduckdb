ARG IMAGE_REFERENCE="scratch"
FROM $IMAGE_REFERENCE AS build_duckdb

ARG EXTENSION_CONFIG
ARG VCPKG_TARGET_TRIPLET
ARG DUCKDB_GIT_REF
ARG VCPKG_TARGET_TRIPLET

WORKDIR /build

# install dependencies
RUN yum install -y gcc-toolset-14-libasan-devel gcc-toolset-14-libubsan-devel

# checkout duckdb
RUN (mkdir duckdb && cd duckdb && git init && git remote add origin "https://github.com/duckdb/duckdb.git" && git fetch --all && git checkout "$DUCKDB_GIT_REF")

# copy ci tools
COPY ./extension-ci-tools /build/extension-ci-tools

# copy extension config
COPY $EXTENSION_CONFIG ./extension_config.cmake

ENV VCPKG_TARGET_TRIPLET="$VCPKG_TARGET_TRIPLET"
ENV VCPKG_OVERLAY_PORTS="/build/extension-ci-tools/vcpkg_ports"
ENV OPENSSL_ROOT_DIR="/build/duckdb/build/release/vcpkg_installed/$VCPKG_TARGET_TRIPLET"
ENV OPENSSL_DIR="/build/duckdb/build/release/vcpkg_installed/$VCPKG_TARGET_TRIPLET"
ENV OPENSSL_USE_STATIC_LIBS="true"
ENV ENABLE_EXTENSION_AUTOINSTALL="1"
ENV ENABLE_EXTENSION_AUTOLOADING="1"
ENV LINUX_CI_IN_DOCKER="1"

ENV EXTENSION_CONFIGS="/build/extension_config.cmake"
ENV STATIC_OPENSSL="1"
ENV STATIC_LIBCPP="1"
ENV USE_MERGED_VCPKG_MANIFEST="1"

# gather libs
RUN make gather-libs -C ./duckdb

FROM $IMAGE_REFERENCE AS build_bundle

ARG VCPKG_TARGET_TRIPLET

WORKDIR /build
COPY --from=build_duckdb "/build/duckdb/build/release/libs/*.a" ./
COPY --from=build_duckdb "/build/duckdb/build/release/vcpkg_installed/$VCPKG_TARGET_TRIPLET/lib/*.a" ./

# create ar-extract helper
RUN echo -e '#!/bin/sh\n\
set -eux\n\
mkdir -p "objs-$1"\n\
cd "objs-$1"\n\
ftemp=$(mktemp)\n\
cp "../$1" "$ftemp"\n\
i=0\n\
while true\n\
do\n\
  member=$(ar t "$ftemp" | head -n 1)\n\
  if [ -z "$member" ]; then\n\
    break\n\
  fi\n\
  (mkdir -p "$i" && cd "$i" && ar x "$ftemp" "$member")\n\
  ar d "$ftemp" "$member"\n\
  i=$((i+1))\n\
done\n\
rm "$ftemp"\n\
' >> /usr/local/ar-extract.sh

RUN chmod +x /usr/local/ar-extract.sh

# extract archives
RUN ls *.a | xargs -n1 sh /usr/local/ar-extract.sh
# bundle fat archive
RUN ls objs-*/*/*.o | xargs ar rcs libduckdb_bundle.a

FROM scratch
COPY --from=build_bundle /build/libduckdb_bundle.a ./
