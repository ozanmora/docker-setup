#!/bin/bash

# cli.sh - Unified helper script for Docker Setup

COMMAND=$1

function show_help {
    echo "Usage: ./cli.sh <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  create-site <domain> <path>   Create a new Nginx config for a site"
    echo "  add-path <path> <name>        Map an external project path to Docker"
    echo "  ssl-generate                  Generate self-signed SSL certificates"
    echo "  ssl-trust                     Trust the generated SSL certificate"
    echo ""
    echo "Examples:"
    echo "  ./cli.sh create-site laravel.test example/laravel/public"
    echo "  ./cli.sh add-path /Users/me/Projects/site site-name"
    echo "  ./cli.sh ssl-generate"
    echo "  ./cli.sh ssl-trust"
}

if [ -z "$COMMAND" ]; then
    show_help
    exit 1
fi

case "$COMMAND" in
    "create-site")
        DOMAIN=$2
        PROJECT_PATH=$3
        if [ -z "$DOMAIN" ] || [ -z "$PROJECT_PATH" ]; then
            echo "Usage: ./cli.sh create-site <domain.test> <relative_path_from_root>"
            exit 1
        fi
        
        CONFIG_FILE="./services/nginx/conf.d/${DOMAIN}.conf"
        if [ -f "$CONFIG_FILE" ]; then
            echo "Error: Configuration for $DOMAIN already exists."
            exit 1
        fi

        cat > "$CONFIG_FILE" <<EOF
server {
    listen 80;
    listen 443 ssl;
    server_name ${DOMAIN};
    root /var/www/${PROJECT_PATH};

    ssl_certificate /etc/nginx/certs/server.crt;
    ssl_certificate_key /etc/nginx/certs/server.key;

    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass php85:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ^~ /phpmyadmin/ {
        proxy_pass http://pma/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
        echo "✅ Configuration created: $CONFIG_FILE"
        echo "🔄 Restarting Nginx..."
        docker-compose restart nginx
        echo "🎉 Done! Add '127.0.0.1 $DOMAIN' to your hosts file."
        ;;

    "add-path")
        LOCAL_PATH=$2
        CONTAINER_NAME=$3
        if [ -z "$LOCAL_PATH" ] || [ -z "$CONTAINER_NAME" ]; then
            echo "Usage: ./cli.sh add-path <local_path> <container_folder_name>"
            exit 1
        fi

        OVERRIDE_FILE="docker-compose.override.yaml"
        EXAMPLE_FILE="docker-compose.override.example.yaml"

        if [ ! -f "$OVERRIDE_FILE" ]; then
            echo "Creating $OVERRIDE_FILE from example..."
            cp "$EXAMPLE_FILE" "$OVERRIDE_FILE"
        fi

        VOLUME_LINE="      - ${LOCAL_PATH}:/var/www/${CONTAINER_NAME}"
        if grep -q "$VOLUME_LINE" "$OVERRIDE_FILE"; then
            echo "Warning: This mapping already exists."
            exit 0
        fi

        sed -i '' "/# -- CUSTOM VOLUMES END --/i\\
$VOLUME_LINE\\
" "$OVERRIDE_FILE"

        echo "✅ Added mapping: $LOCAL_PATH -> /var/www/$CONTAINER_NAME"
        echo "🔄 Recreating containers..."
        docker-compose up -d
        ;;

    "ssl-generate")
        mkdir -p certs
        echo "🔐 Generating self-signed SSL certificate..."
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout certs/server.key \
            -out certs/server.crt \
            -subj "/C=TR/ST=Istanbul/L=Istanbul/O=Development/OU=Development/CN=*.test" \
            -addext "subjectAltName=DNS:*.test,DNS:localhost"
        chmod 644 certs/server.key
        echo "✅ Certificate generated in ./certs/"
        ;;

    "ssl-trust")
        CERT_FILE="certs/server.crt"
        if [ ! -f "$CERT_FILE" ]; then
            echo "Error: Certificate not found. Run 'ssl-generate' first."
            exit 1
        fi
        echo "🔑 Adding certificate to macOS System Keychain..."
        sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$CERT_FILE"
        if [ $? -eq 0 ]; then
            echo "✅ Certificate trusted! Restart your browser."
        else
            echo "❌ Failed to trust certificate."
        fi
        ;;

    *)
        echo "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac
