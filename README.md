# Docker Development Environment

A complete, Docker-based development environment for PHP projects. This setup includes Nginx, multiple PHP versions (8.5, 8.2, 7.4), MariaDB, and PhpMyAdmin.

## Features

-   **Nginx**: Web server configured to handle multiple sites.
-   **Multiple PHP Versions**:
    -   PHP 8.5 (Latest)
    -   PHP 8.2 (Stable)
    -   PHP 7.4 (Legacy support)
-   **MariaDB 11**: Database server.
-   **PhpMyAdmin**: Database management interface.
-   **Node.js**: Included in PHP containers for frontend tooling.
-   **Composer**: Pre-installed in PHP containers.

## Prerequisites

-   [Docker](https://www.docker.com/get-started)
-   [Docker Compose](https://docs.docker.com/compose/install/)

## Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/ozanmora/docker-setup.git
    cd docker-setup
    ```

2.  **Configure Environment Variables:**
    Copy the example environment file to create your local configuration:
    ```bash
    cp .env.example .env
    ```
    *Note: You can adjust database passwords and users in `.env` if needed.*

3.  **Start the Environment:**
    ```bash
    docker-compose up -d
    ```

## Usage

### Project Structure
Place your PHP projects in the `www/` directory. Nginx is configured to serve files from this directory.

```
docker-setup/
├── www/                # Your project files go here
├── services/           # Docker service configurations
├── docker-compose.yaml # Main Docker configuration
└── .env                # Environment variables
```

### Accessing Services

-   **Web Server**: `http://localhost`
-   **PhpMyAdmin**: `http://localhost:8080`

### Switching PHP Versions
By default, Nginx is configured to use specific PHP upstreams. You can modify the Nginx configuration in `services/nginx/conf.d/` to point to the desired PHP container (`php85`, `php82`, or `php74`).

### Running Commands
To run Composer or Artisan commands, execute them inside the container:

```bash
# For PHP 8.5
docker exec -it mora_php85 bash

# Inside the container:
composer install
php artisan migrate
```

## License

This project is open-sourced software licensed under the [MIT license](LICENSE).
