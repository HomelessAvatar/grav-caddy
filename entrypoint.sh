#!/bin/bash
set -e

# Set timezone if specified
if [ -n "$TZ" ]; then
    echo "Setting timezone to $TZ..."
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi

# Set custom PUID/PGID if specified
PUID=${PUID:-82} # 82 is default www-data on Alpine
PGID=${PGID:-82}

if [ "$PUID" != "82" ] || [ "$PGID" != "82" ]; then
    echo "Updating www-data UID:GID to ${PUID}:${PGID}..."
    deluser www-data 2>/dev/null || true
    addgroup -g "$PGID" www-data 2>/dev/null || true
    adduser -u "$PUID" -G www-data -s /bin/sh -D www-data 2>/dev/null || true
fi

# If empty directory, download and install latest Grav with Admin
if [ ! -f /var/www/html/index.php ]; then
    echo "No Grav installation found in /var/www/html. Downloading latest Grav..."
    GRAV_VERSION=${GRAV_VERSION:-latest}
    TEMP_DIR=$(mktemp -d)
    
    if [ "$GRAV_VERSION" = "latest" ]; then
        GRAV_URL="https://getgrav.org/download/core/grav-admin/latest"
    else
        GRAV_URL="https://github.com/getgrav/grav/releases/download/${GRAV_VERSION}/grav-admin-v${GRAV_VERSION}.zip"
    fi
    
    echo "Downloading from $GRAV_URL..."
    curl -fsSL -o "$TEMP_DIR/grav.zip" "$GRAV_URL"
    unzip -q "$TEMP_DIR/grav.zip" -d "$TEMP_DIR"
    cp -r "$TEMP_DIR"/grav-admin/* /var/www/html/
    cp -r "$TEMP_DIR"/grav-admin/.[!.]* /var/www/html/ 2>/dev/null || true
    rm -rf "$TEMP_DIR"
    echo "Grav installed successfully."
fi

# Ensure correct permissions
echo "Ensuring file permissions..."
chown -R www-data:www-data /var/www/html /var/log/caddy 2>/dev/null || true

# Signal handling for clean shutdown
_term() {
    echo "Stopping Caddy and PHP-FPM..."
    kill -TERM "$caddy_pid" 2>/dev/null || true
    kill -TERM "$php_pid" 2>/dev/null || true
}

trap _term SIGTERM SIGINT SIGQUIT

echo "Starting PHP-FPM..."
php-fpm -F &
php_pid=$!

echo "Starting Caddy..."
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
caddy_pid=$!

# Wait for both processes
wait "$php_pid" "$caddy_pid"
