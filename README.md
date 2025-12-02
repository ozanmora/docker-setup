# Docker Development Environment

A complete, Docker-based development environment for PHP projects. This setup includes Nginx, multiple PHP versions (8.5, 8.2, 7.4), MariaDB, and PhpMyAdmin.

## Features

-   **Nginx**: Web server configured to handle multiple sites (HTTP & HTTPS).
-   **SSL/HTTPS**: Auto-generated self-signed certificates for `*.test` and `localhost`.
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

3.  **Prepare Scripts:**
    *   **Mac/Linux**: Make script executable:
        ```bash
        chmod +x cli.sh
        ```
    *   **Windows**: Allow local scripts:
        ```powershell
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
        ```

4.  **Start the Environment:**
    ```bash
    docker-compose up -d
    ```

5.  **Generate SSL Certificates (Optional):**
    *By default, the setup uses HTTP. If you want HTTPS:*
    ```bash
    ./cli.sh ssl-generate
    # Windows: ./cli.ps1 ssl-generate
    ```
    *Then trust the certificate:*
    ```bash
    sudo ./cli.sh ssl-trust
    # Windows: ./cli.ps1 ssl-trust
    ```
    *Then uncomment the SSL lines in your Nginx config files and restart Nginx.*

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

### Dynamic Project Management (Recommended)
Instead of adding every single project to `docker-compose.override.yaml`, the best practice is to map your **Main Projects Folder** (e.g., `~/Projects`) using the `PROJECTS_ROOT` variable in `.env`.

1.  **Set Root**: In `.env`, set `PROJECTS_ROOT=/Users/username/Projects`.
2.  **Automatic Access**: Now, **ALL** subfolders (e.g., `~/Projects/example1/laravel`, `~/Projects/example2/wordpress`) are automatically accessible inside the container at `/var/www/example1/laravel`, `/var/www/example2/wordpress`, etc.
3.  **Create Site**:
    *   **Mac/Linux**:
        ```bash
        ./cli.sh create-site laravel.test example/laravel/public
        ```
    *   **Windows**:
        ```powershell
        ./cli.ps1 create-site laravel.test example/laravel/public
        ```
    *(This creates the Nginx config and restarts the server automatically.)*

### Advanced: Mapping Scattered Projects
If you have a project completely outside your main `PROJECTS_ROOT` (e.g., on an external drive), then use the `docker-compose.override.yaml` method described below.

#### Automated Mapping (Recommended for Scattered Projects)
If you have a project outside your main folder, use the helper script to add it automatically:

*   **Mac/Linux**:
    ```bash
    ./cli.sh add-path /Users/username/Projects/example/laravel laravel-project
    ```
*   **Windows**:
    ```powershell
    ./cli.ps1 add-path "C:\Users\username\Projects\example\laravel" laravel-project
    ```
*(This adds the path to `docker-compose.override.yaml` and restarts Docker.)*

#### Manual Mapping (Legacy)

1.  Copy the example file:
    ```bash
    cp docker-compose.override.example.yaml docker-compose.override.yaml
    ```
2.  Open `docker-compose.override.yaml` and add your custom volume mappings. You must add them to **both** Nginx and the PHP services you intend to use.

    ```yaml
    services:
      nginx:
        volumes:
          - /Users/username/Projects/example/laravel:/var/www/laravel-project
          - /Users/username/Projects/example/wordpress:/var/www/wordpress-project
      php85:
        volumes:
          - /Users/username/Projects/example/laravel:/var/www/laravel-project
          - /Users/username/Projects/example/wordpress:/var/www/wordpress-project
    ```
3.  Restart Docker: `docker-compose up -d`.
4.  Your project will be available at `http://localhost/laravel-project` and `http://localhost/wordpress-project`.

### Custom Domains (e.g., laravel.test)
To use a custom domain like `http://laravel.test` instead of `http://localhost/laravel-project`:

> [!TIP]
> **Enable HTTPS:** To enable HTTPS for a site:
> 1.  Run `./cli.sh ssl-generate`.
> 2.  Uncomment the `listen 443 ssl` and `ssl_certificate` lines in `services/nginx/conf.d/YOUR_SITE.conf`.
> 3.  Restart Nginx: `docker-compose restart nginx`.
>
> **Remove SSL Warnings:** After enabling HTTPS, you can trust the certificate to remove browser warnings:
> *   **Mac**: `sudo ./cli.sh ssl-trust`
> *   **Windows**: `./cli.ps1 ssl-trust`
> *   **Firefox**: Type `about:config`, set `security.enterprise_roots.enabled` to `true`, and restart Firefox.
1.  **Add Domain to Hosts File**:
    *   **Mac/Linux**: Edit `/etc/hosts`
    *   **Windows**: Edit `C:\Windows\System32\drivers\etc\hosts`
    *   Add the line: `127.0.0.1 laravel.test`

2.  **Create Nginx Config**:
    *   Go to `services/nginx/conf.d/`
    *   Copy `project.conf.example` to `laravel.conf`
    *   Edit `laravel.conf`:
        *   Change `server_name` to `laravel.test`
        *   Change `root` to `/var/www/laravel-project/public`
        *   (Optional) Change `fastcgi_pass` to use a different PHP version.

3.  **Restart Nginx**:
    ```bash
    docker-compose restart nginx
    ```

### Applying Changes (Workflow)
*   **New Nginx Config**: Run `docker-compose restart nginx`.
*   **New Volume in docker-compose**: Run `docker-compose up -d` (this recreates the container with new settings).
*   **PHP Code Changes**: No restart needed (changes are instant).
*   **New PHP Extension**: Edit Dockerfile and run `docker-compose up -d --build`.

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
