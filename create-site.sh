#!/bin/bash

# create-site.sh - Helper script to create Nginx config for a new project

if [ -z "$1" ]; then
    echo "Usage: ./create-site.sh <domain.test> <relative_path_from_root>"
    echo "Example: ./create-site.sh laravel.test example/laravel/public"
    exit 1
fi

DOMAIN=$1
PROJECT_PATH=$2
CONFIG_FILE="./services/nginx/conf.d/${DOMAIN}.conf"

# Check if config already exists
if [ -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration for $DOMAIN already exists."
    exit 1
fi

# Create the config file
cat > "$CONFIG_FILE" <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    root /var/www/${PROJECT_PATH};

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
}
EOF

echo "✅ Configuration created: $CONFIG_FILE"
echo "🔄 Restarting Nginx..."
docker-compose restart nginx
echo "🎉 Done! Add '127.0.0.1 $DOMAIN' to your hosts file and visit http://$DOMAIN"
