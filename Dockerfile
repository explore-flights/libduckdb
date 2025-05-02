ARG IMAGE=$TARGETARCH
FROM quay.io/pypa/manylinux_2_28_$IMAGE AS build_duckdb

ARG EXTENSION_CONFIG
ARG VCPKG_TARGET_TRIPLET
ARG DUCKDB_GIT_REF
ARG VCPKG_GIT_REF

WORKDIR /build

# install dependencies
RUN yum install -y perl-IPC-Cmd curl zip unzip tar gcc gcc-c++ ninja-build
# checkout duckdb
RUN (mkdir duckdb && cd duckdb && git init && git remote add origin "https://github.com/duckdb/duckdb.git" && git fetch --all && git checkout "$DUCKDB_GIT_REF")
# checkout vcpkg
RUN (mkdir duckdb/vcpkg && cd duckdb/vcpkg && git init && git remote add origin "https://github.com/microsoft/vcpkg.git" && git fetch origin "$VCPKG_GIT_REF" && git checkout "$VCPKG_GIT_REF")

# setup vcpkg
RUN (cd duckdb/vcpkg && ./bootstrap-vcpkg.sh)

# copy extension config
COPY $EXTENSION_CONFIG ./extension_config.cmake

ENV CMAKE_BUILD_PARALLEL_LEVEL=2
ENV EXTENSION_CONFIGS="/build/extension_config.cmake"
ENV ENABLE_EXTENSION_AUTOLOADING=1
ENV ENABLE_EXTENSION_AUTOINSTALL=1
ENV FORCE_WARN_UNUSED=1
ENV VCPKG_TARGET_TRIPLET="$VCPKG_TARGET_TRIPLET"
ENV VCPKG_ROOT="/build/duckdb/vcpkg"
ENV VCPKG_TOOLCHAIN_PATH="/build/duckdb/vcpkg/scripts/buildsystems/vcpkg.cmake"
ENV USE_MERGED_VCPKG_MANIFEST=1
ENV STATIC_OPENSSL=1
ENV STATIC_LIBCPP=1
ENV EXTENSION_STATIC_BUILD=1

# gather libs
RUN make gather-libs -C ./duckdb

FROM quay.io/pypa/manylinux_2_28_$IMAGE AS build_bundle

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