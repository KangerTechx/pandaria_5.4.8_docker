# --- Base image ---
ARG BASE_IMAGE=debian:bookworm-slim
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

# Timezone (optional)
ARG TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install build tools, libraries, and default Clang (14 on Bookworm)
RUN apt-get update && apt-get install -y \
    tzdata vim tmux git curl jq \
    clang clang++ clang-tools lldb \
    cmake make gcc g++ \
    libreadline-dev libssl-dev libboost-all-dev \
    libace-dev libbz2-dev unzip wget \
    default-mysql-client default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy utility dispatcher
COPY utility /bin/utility
RUN chmod +x /bin/utility

# Copy all command scripts
COPY commands/ /bin/commands/
RUN chmod +x /bin/commands/*.sh

# Set entrypoint
ENTRYPOINT ["/bin/utility"]

# Default compilers for build
ENV CMAKE_C_COMPILER=/usr/bin/clang
ENV CMAKE_CXX_COMPILER=/usr/bin/clang++
