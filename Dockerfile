# Use the official ASP.NET Core runtime image from Microsoft, based on Alpine
FROM mcr.microsoft.com/dotnet/aspnet:7.0-alpine AS base
WORKDIR /app


# Install the agent
# Install the agent
RUN apk add --no-cache --virtual .build-deps ca-certificates gnupg wget \
    && wget -qO- https://download.newrelic.com/548C16BF.gpg | gpg --dearmor | dd of=/etc/apk/keys/newrelic.rsa.pub \
    && echo "http://apt.newrelic.com/alpine/3.16/main" >> /etc/apk/repositories \
    && apk add --no-cache newrelic-dotnet-agent \
    && rm -rf /var/cache/apk/* \
    && apk del .build-deps

# Enable the agent
ENV CORECLR_ENABLE_PROFILING=1 \
    CORECLR_PROFILER={36032161-FFC0-4B61-B559-F6C5D41BAE5A} \
    CORECLR_NEWRELIC_HOME=/usr/local/newrelic-dotnet-agent \
    CORECLR_PROFILER_PATH=/usr/local/newrelic-dotnet-agent/libNewRelicProfiler.so \
    NEW_RELIC_LICENSE_KEY=eu01xx1dd5a7b92e7370982b1e28b0d4FFFFNRAL \
    NEW_RELIC_APP_NAME="HelloWorldApp"

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
ENTRYPOINT ["dotnet", "HelloWorldApp.dll"]

