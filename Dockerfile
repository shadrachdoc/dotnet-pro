# Use the official ASP.NET Core runtime image from Microsoft, based on Alpine
FROM mcr.microsoft.com/dotnet/aspnet:7.0-alpine AS base

WORKDIR /app

# Install wget and bash
RUN apk add --no-cache ca-certificates wget bash

# Download and extract the New Relic agent
RUN wget -O newrelic-dotnet-agent_10.24.0_amd64.tar.gz https://download.newrelic.com/dot_net_agent/latest_release/newrelic-dotnet-agent_10.24.0_amd64.tar.gz \
    && mkdir -p /usr/local/newrelic-dotnet-agent \
    && tar -xzf newrelic-dotnet-agent_10.24.0_amd64.tar.gz -C /usr/local/newrelic-dotnet-agent --strip-components=1 \
    && rm newrelic-dotnet-agent_10.24.0_amd64.tar.gz

# Set required environment variables
ENV CORECLR_ENABLE_PROFILING=1 \
    CORECLR_PROFILER={36032161-FFC0-4B61-B559-F6C5D41BAE5A} \
    CORECLR_NEWRELIC_HOME=/usr/local/newrelic-dotnet-agent \
    CORECLR_PROFILER_PATH=/usr/local/newrelic-dotnet-agent/libNewRelicProfiler.so \
    NEW_RELIC_LICENSE_KEY=eu01xx897bb460a31b2397bb69e47267FFFFNRAL \
    NEW_RELIC_APP_NAME="HelloWorldApp"

# List the contents of the directory
RUN ls -al /usr/local/newrelic-dotnet-agent

# Use the ASP.NET Core SDK image to build the application
FROM mcr.microsoft.com/dotnet/sdk:7.0-alpine AS build

WORKDIR /src

COPY ["HelloWorldApp.csproj", "./"]

RUN dotnet restore "HelloWorldApp.csproj"

COPY . .

WORKDIR "/src/."

RUN dotnet build "HelloWorldApp.csproj" -c Release -o /app/build

FROM build AS publish

RUN dotnet publish "HelloWorldApp.csproj" -c Release -o /app/publish

# Final stage/image
FROM base AS final

WORKDIR /app

COPY --from=publish /app/publish .

# Give full access to the run.sh script
RUN chmod 755 /usr/local/newrelic-dotnet-agent/run.sh

# Run the application and the New Relic agent
ENTRYPOINT ["/usr/local/newrelic-dotnet-agent/run.sh", "dotnet", "HelloWorldApp.dll"]

