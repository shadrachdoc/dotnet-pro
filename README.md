# HelloWorldApp

This is a simple ASP.NET Core web application with New Relic monitoring integrated.

## How to Run

To run the application with Docker, please follow these steps:

1. Build the Docker image:
    ```bash
    docker build -t helloworldapp .
    ```

2. Run the Docker container:
    ```bash
    docker run -p 80:80 helloworldapp -e NEW_RELIC_REGION=eu
    ```

## New Relic Demo Access

You can access the New Relic demo with the following credentials:

- **Email:** t9ilswvbj9@sfolkar.com
- **Password:** Shad@1234
