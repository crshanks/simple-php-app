# Use an official PHP image. php:8.2-cli is a good choice for the built-in server.
# It's a multi-arch image, so it will work on your M1 Mac (linux/arm64).
FROM php:8.2-cli

# ARG for New Relic Agent Version - allows easy updates
# Check the latest version from: https://github.com/newrelic/newrelic-php-agent/releases
# Ensure it's 10.10.0 or newer for aarch64 binaries.
ARG NR_AGENT_VERSION="11.9.0.23" # Fetched latest version as of May 2025, please update if needed

LABEL maintainer="your-email@example.com"
LABEL description="Simple PHP application with New Relic APM agent."

# Set working directory
WORKDIR /var/www/html

# Install dependencies needed for downloading and installing New Relic agent.
# gnupg is sometimes needed by the install script or for key verification, though often not strictly.
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    gnupg \
    procps \
    vim \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Download, extract, and install the New Relic PHP Agent.
# Using 'linux' tarball for glibc-based systems like the official php:*-cli images.
RUN cd /tmp && \
    wget "https://download.newrelic.com/php_agent/release/newrelic-php5-${NR_AGENT_VERSION}-linux.tar.gz" -O newrelic-php-agent.tar.gz && \
    tar -xzf newrelic-php-agent.tar.gz && \
    cd newrelic-php5-* && \
    export NR_INSTALL_SILENT=1 && \
    export NR_INSTALL_USE_CP_NOT_LN=1 && \
    ./newrelic-install install && \
    rm -rf /tmp/newrelic-php5-* /tmp/newrelic-php-agent.tar.gz

# Copy the PHP application files into the container
COPY src/ .

# # Copy the New Relic configuration file into the container
# # Ensure the file is named correctly and contains the right settings.
# COPY newrelic.ini /usr/local/etc/php/conf.d/

# Copy and set up the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Expose the port the PHP built-in server will run on
EXPOSE 8080

# The New Relic agent and daemon should start automatically with PHP.
# No changes needed to your CMD for basic instrumentation.
CMD ["php", "-S", "0.0.0.0:8080", "-t", "."]