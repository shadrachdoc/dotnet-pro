#!/bin/sh

# Download the NewRelic .NET agent
NEWRELIC_DOWNLOAD_URL=https://download.newrelic.com/dot_net_agent/latest_release/newrelic-dotnet-agent_10.23.1_amd64.tar.gz
NEWRELIC_ARCHIVE=newrelic-dotnet-agent_10.23.1_amd64.tar.gz

wget -O ${NEWRELIC_ARCHIVE} ${NEWRELIC_DOWNLOAD_URL}

# Extract the agent files
mkdir -p /usr/local/newrelic-dotnet-agent
tar -xzf ${NEWRELIC_ARCHIVE} -C /usr/local/newrelic-dotnet-agent --strip-components=1

# Clean up
rm ${NEWRELIC_ARCHIVE}

# Set required environment variables
export CORECLR_ENABLE_PROFILING=1
export CORECLR_PROFILER={36032161-FFC0-4B61-B559-F6C5D41BAE5A}
export CORECLR_NEWRELIC_HOME=/usr/local/newrelic-dotnet-agent
export CORECLR_PROFILER_PATH=/usr/local/newrelic-dotnet-agent/libNewRelicProfiler.so
export NEW_RELIC_LICENSE_KEY=eu01xx897bb460a31b2397bb69e47267FFFFNRAL
export NEW_RELIC_APP_NAME="HelloWorldApp"