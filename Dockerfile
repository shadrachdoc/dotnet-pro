# Use the official ASP.NET Core runtime image from Microsoft, based on Alpine
FROM mcr.microsoft.com/dotnet/aspnet:7.0-alpine AS base
WORKDIR /app


# Install the agent
RUN apt-get update && apt-get install -y wget ca-certificates gnupg \
&& echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list \
&& wget https://download.newrelic.com/548C16BF.gpg \
&& apt-key add 548C16BF.gpg \
&& apt-get update \
&& apt-get install -y 'newrelic-dotnet-agent' \
&& rm -rf /var/lib/apt/lists/*

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

