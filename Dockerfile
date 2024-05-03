# Use the official ASP.NET Core runtime image from Microsoft, based on Alpine
FROM mcr.microsoft.com/dotnet/aspnet:7.0-alpine AS base

WORKDIR /app

# Install the agent
RUN apk add --no-cache ca-certificates wget

# Copy the installation script
COPY install-newrelic.sh /tmp/

# Make the script executable and run it
RUN chmod +x /tmp/install-newrelic.sh && /tmp/install-newrelic.sh

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
#RUN chmod 755 /usr/local/newrelic-dotnet-agent/run.sh

# Run the application and the New Relic agent
ENTRYPOINT ["/usr/local/newrelic-dotnet-agent/run.sh", "dotnet", "HelloWorldApp.dll"]
