# Use the official ASP.NET Core runtime image from Microsoft, based on Alpine
FROM mcr.microsoft.com/dotnet/aspnet:7.0-alpine AS base


# Install required packages and cleanup
RUN apk add --no-cache ca-certificates wget bash \
    && rm -rf /var/cache/apk/*

RUN mkdir -p /usr/local/newrelic-dotnet-agent
    

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
    

# Set the working directory and ownership
WORKDIR /app
RUN chown -R appuser:appgroup /app
    && chown -R appuser:appgroup /usr/local/newrelic-dotnet-agent

# Switch to the non-root user
USER appuser


# Download and extract the New Relic agent
ARG NEWRELIC_AGENT_VERSION=10.24.0
RUN wget -O newrelic-dotnet-agent_${NEWRELIC_AGENT_VERSION}_amd64.tar.gz https://download.newrelic.com/dot_net_agent/previous_releases/10.24.0/newrelic-dotnet-agent_${NEWRELIC_AGENT_VERSION}_amd64.tar.gz \
    && tar -xzf newrelic-dotnet-agent_${NEWRELIC_AGENT_VERSION}_amd64.tar.gz -C /usr/local/newrelic-dotnet-agent --strip-components=1 \
    && rm newrelic-dotnet-agent_${NEWRELIC_AGENT_VERSION}_amd64.tar.gz

# Set required environment variables
ENV CORECLR_ENABLE_PROFILING=1 \
    CORECLR_PROFILER={36032161-FFC0-4B61-B559-F6C5D41BAE5A} \
    CORECLR_NEWRELIC_HOME=/usr/local/newrelic-dotnet-agent \
    CORECLR_PROFILER_PATH=/usr/local/newrelic-dotnet-agent/libNewRelicProfiler.so

# Use a dummy value for the license key in the build stage
ENV NEW_RELIC_LICENSE_KEY="eu01xx897bb460a31b2397bb69e47267FFFFNRAL"

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

# Set the actual license key from an environment variable or a secure source
ARG NEW_RELIC_LICENSE_KEY
ENV NEW_RELIC_LICENSE_KEY=$NEW_RELIC_LICENSE_KEY
ENV NEW_RELIC_APP_NAME="HelloWorldApp"

WORKDIR /app
COPY --from=publish /app/publish .

# Give full access to the run.sh script
RUN chmod 755 /usr/local/newrelic-dotnet-agent/run.sh

# Run the application and the New Relic agent as the non-root user
USER appuser
ENTRYPOINT ["/usr/local/newrelic-dotnet-agent/run.sh", "dotnet", "HelloWorldApp.dll"]
