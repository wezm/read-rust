FROM archlinux:latest@sha256:703de9ba7e6cd9b2d47fe96e857cc8b60f386f70bd96693e156f09b66654eea3

# RUN apk update && apk add --no-cache \
#     curl \
#     rust cargo \
#     crystal shards \
#     nodejs yarn \
#     chromium chromium-chromedriver \
#     postgresql postgresql-contrib postgresql-client tzdata

RUN pacman -Syu --noconfirm \
    rustup \
    crystal shards \
    nodejs yarn \
    postgresql postgresql-libs \
    chromium && \
    pacman -Scc --noconfirm

# TODO merge this into the command above
RUN pacman -S --noconfirm gcc pkgconf sudo make

RUN useradd -m readrust && \
    mkdir -p /src/rust/src /target /home/readrust/.cargo/registry && \
    chown -R readrust /src /target /home/readrust/.cargo/registry && \
    mkdir -p /src/crystal/lib /src/crystal/bin /src/crystal/.shards && \
    chown -R readrust /src/crystal/lib /src/crystal/bin /src/crystal/.shards && \
    mkdir -p /src/crystal/node_modules /src/crystal/public/js /src/crystal/public/css && \
    chown -R readrust /src/crystal/node_modules /src/crystal/public/js /src/crystal/public/css && \
    mkdir /upper /work /build && \
    echo 'readrust ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/readrust

USER readrust

RUN rustup set profile minimal && rustup default 1.38.0

WORKDIR /src

# COPY rust/Cargo.toml rust/Cargo.lock /src/rust/

# RUN touch /src/rust/src/main.rs && \
#     cargo fetch --manifest-path /src/rust/Cargo.toml

VOLUME /target
