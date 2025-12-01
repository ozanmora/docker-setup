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
    *Note: You can adjust database root password in `.env` if needed.*

3.  **Start the Environment:**
    ```bash
    docker-compose up -d
    ```

## Usage

### Project Structure & Custom Paths
By default, the project uses the `www/` directory inside the repo. To use a different folder (e.g., your main Projects folder), update the `PROJECTS_ROOT` variable in your `.env` file.

**Examples:**
-   **Mac/Linux**: `PROJECTS_ROOT=/Users/username/Projects`
-   **Windows**: `PROJECTS_ROOT=C:/Users/username/Projects`

```
docker-setup/
├── services/           # Docker service configurations
├── docker-compose.yaml # Main Docker configuration
└── .env                # Environment variables (PROJECTS_ROOT defined here)
```

```

### Advanced: Mapping Scattered Projects (Recommended)
If your projects are in different locations (e.g., `~/Projects/example1/laravel` and `~/Projects/example2/wordpress`), you should use a **`docker-compose.override.yaml`** file instead of symlinks. Symlinks often fail with Docker because the container cannot see the file paths on your host machine.

1.  Copy the example file:
    ```bash
    cp docker-compose.override.example.yaml docker-compose.override.yaml
    ```
2.  Open `docker-compose.override.yaml` and add your custom volume mappings. You must add them to **both** Nginx and the PHP services you intend to use.

    ```yaml
    services:
      nginx:
        volumes:
          - /Users/username/Projects/example1/laravel:/var/www/example1-test
          - /Users/username/Projects/example2/wordpress:/var/www/example2-test
      php85:
        volumes:
          - /Users/username/Projects/example1/laravel:/var/www/example1-test
          - /Users/username/Projects/example2/wordpress:/var/www/example2-test
    ```
3.  Restart Docker: `docker-compose up -d`.
4.  Your project will be available at `http://localhost/example1-test` and `http://localhost/example2-test`.

### Custom Domains (e.g., project.test)
To use a custom domain like `http://example1.test` instead of `http://localhost/example1-test`:

1.  **Add Domain to Hosts File**:
    *   **Mac/Linux**: Edit `/etc/hosts`
    *   **Windows**: Edit `C:\Windows\System32\drivers\etc\hosts`
    *   Add the line: `127.0.0.1 example1.test`

2.  **Create Nginx Config**:
    *   Go to `services/nginx/conf.d/`
    *   Copy `project.conf.example` to `example1-test.conf`
    *   Edit `example1-test.conf`:
        *   Change `server_name` to `example1.test`
        *   Change `root` to `/var/www/example1-test`
        *   (Optional) Change `fastcgi_pass` to use a different PHP version.

3.  **Restart Nginx**:
    ```bash
    docker-compose restart nginx
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
docker exec -it dev_php85 bash

# Inside the container:
composer install
php artisan migrate
```

## License

This project is open-sourced software licensed under the [MIT license](LICENSE).
