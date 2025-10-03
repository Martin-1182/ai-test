# Laravel Deployment with Coolify

Laravel is a web application framework with expressive, elegant syntax. This guide covers deploying Laravel applications using Coolify.

**Example repository:** [https://github.com/coollabsio/coolify-examples/tree/main/laravel](https://github.com/coollabsio/coolify-examples/tree/main/laravel)

## Deploy with Nixpacks

### Requirements

* Set `Build Pack` to `nixpacks`
* Set the required environment variables
* Add `nixpacks.toml` with the configuration below
* Set `Ports Exposes` to `80`

### Environment Variables

If your application needs a database or Redis, create them beforehand in the Coolify dashboard. You will receive connection strings to use as environment variables:

```bash
DB_CONNECTION=mysql
DB_HOST=<DB_HOST>
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=

REDIS_HOST=<REDIS_HOST>
REDIS_PASSWORD=null
REDIS_PORT=6379
```

### All-in-one Container Configuration

To start queue worker, scheduler, etc. within one container (recommended), create a `nixpacks.toml` file in your repository:

```toml
[phases.setup]
nixPkgs = ["...", "python311Packages.supervisor"]

[phases.build]
cmds = [
    "mkdir -p /etc/supervisor/conf.d/",
    "cp /assets/worker-*.conf /etc/supervisor/conf.d/",
    "cp /assets/supervisord.conf /etc/supervisord.conf",
    "chmod +x /assets/start.sh",
    "..."
]

[start]
cmd = '/assets/start.sh'

[staticAssets]
"start.sh" = '''
#!/bin/bash

# Transform the nginx configuration
node /assets/scripts/prestart.mjs /assets/nginx.template.conf /etc/nginx.conf

# Start supervisor
supervisord -c /etc/supervisord.conf -n
'''

"supervisord.conf" = '''
[unix_http_server]
file=/assets/supervisor.sock

[supervisord]
logfile=/var/log/supervisord.log
logfile_maxbytes=50MB
logfile_backups=10
loglevel=info
pidfile=/assets/supervisord.pid
nodaemon=false
silent=false
minfds=1024
minprocs=200

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///assets/supervisor.sock

[include]
files = /etc/supervisor/conf.d/*.conf
'''

"worker-nginx.conf" = '''
[program:worker-nginx]
process_name=%(program_name)s_%(process_num)02d
command=nginx -c /etc/nginx.conf
autostart=true
autorestart=true
stdout_logfile=/var/log/worker-nginx.log
stderr_logfile=/var/log/worker-nginx.log
'''

"worker-phpfpm.conf" = '''
[program:worker-phpfpm]
process_name=%(program_name)s_%(process_num)02d
command=php-fpm -y /assets/php-fpm.conf -F
autostart=true
autorestart=true
stdout_logfile=/var/log/worker-phpfpm.log
stderr_logfile=/var/log/worker-phpfpm.log
'''

"worker-laravel.conf" = '''
[program:worker-laravel]
process_name=%(program_name)s_%(process_num)02d
command=bash -c 'exec php /app/artisan queue:work --sleep=3 --tries=3 --max-time=3600'
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
numprocs=12 # To reduce memory/CPU usage, change to 2.
startsecs=0
stopwaitsecs=3600
stdout_logfile=/var/log/worker-laravel.log
stderr_logfile=/var/log/worker-laravel.log
'''

"php-fpm.conf" = '''
[www]
listen = 127.0.0.1:9000
user = www-data
group = www-data
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 50
pm.min_spare_servers = 4
pm.max_spare_servers = 32
pm.start_servers = 18
clear_env = no
php_admin_value[post_max_size] = 35M
php_admin_value[upload_max_filesize] = 30M
'''

"nginx.template.conf" = '''
user www-data www-data;
worker_processes 5;
daemon off;

worker_rlimit_nofile 8192;

events {
  worker_connections  4096;  # Default: 1024
}

http {
    include    $!{nginx}/conf/mime.types;
    index    index.html index.htm index.php;

    default_type application/octet-stream;
    log_format   main '$remote_addr - $remote_user [$time_local]  $status '
        '"$request" $body_bytes_sent "$http_referer" '
        '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx-access.log;
    error_log /var/log/nginx-error.log;
    sendfile     on;
    tcp_nopush   on;
    server_names_hash_bucket_size 128; # this seems to be required for some vhosts

    server {
        listen ${PORT};
        listen [::]:${PORT};
        server_name localhost;

        $if(NIXPACKS_PHP_ROOT_DIR) (
            root ${NIXPACKS_PHP_ROOT_DIR};
        ) else (
            root /app;
        )

        add_header X-Content-Type-Options "nosniff";

        client_max_body_size 35M;

        index index.php;

        charset utf-8;

        $if(NIXPACKS_PHP_FALLBACK_PATH) (
            location / {
                try_files $uri $uri/ ${NIXPACKS_PHP_FALLBACK_PATH}?$query_string;
            }
        ) else (
          location / {
                try_files $uri $uri/ /index.php?$query_string;
           }
        )

        location = /favicon.ico { access_log off; log_not_found off; }
        location = /robots.txt  { access_log off; log_not_found off; }

        $if(IS_LARAVEL) (
            error_page 404 /index.php;
        ) else ()

        location ~ \.php$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
            include $!{nginx}/conf/fastcgi_params;
            include $!{nginx}/conf/fastcgi.conf;
        }

        location ~ /\.(?!well-known).* {
            deny all;
        }
    }
}
'''
```

### Deployment with Inertia.js

#### Increasing NGINX Buffer Size for Inertia Requests

Due to a known issue with Inertia.js and default NGINX configuration, you may need to increase the buffer size:

```diff
"nginx.template.conf" = '''
# ...
http {
    # ...
    server {
        # ...
        location ~ \.php$ {
+            fastcgi_buffer_size 8k;
            fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
            include $!{nginx}/conf/fastcgi_params;
            include $!{nginx}/conf/fastcgi.conf;
            # ...
        }
    }
}
```

#### Inertia SSR (Server-Side Rendering)

For Inertia.js with SSR, add another worker in your `nixpacks.toml`:

```toml
"worker-inertia-ssr.conf" = '''
[program:inertia-ssr]
process_name=%(program_name)s_%(process_num)02d
command=bash -c 'exec php /app/artisan inertia:start-ssr'
autostart=true
autorestart=true
stderr_logfile=/var/log/worker-inertia-ssr.log
stdout_logfile=/var/log/worker-inertia-ssr.log
'''
```

**Note:** Nixpacks runs `npm run build` by default. Update your `package.json` scripts:

```diff
"scripts": {
-     "build": "vite build",
+     "build": "vite build && vite build --ssr",
    "build:ssr": "vite build && vite build --ssr",
}
```

Or add the build command directly in `nixpacks.toml`:

```diff
[phases.build]
cmds = [
+    "npm run build:ssr",
   "mkdir -p /etc/supervisor/conf.d/",
   # ...
]
```

### Persistent php.ini Customizations

Customize PHP settings using the `php_admin_value` directive in `php-fpm.conf`:

```toml
"php-fpm.conf" = '''
[www]
listen = 127.0.0.1:9000
user = www-data
group = www-data
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 50
pm.min_spare_servers = 4
pm.max_spare_servers = 32
pm.start_servers = 18
clear_env = no

php_admin_value[memory_limit] = 512M
php_admin_value[max_execution_time] = 60
php_admin_value[max_input_time] = 60
php_admin_value[post_max_size] = 256M
'''
```

## Deploy with Dockerfile and Nginx Unit

Coolify also supports deployment using a Dockerfile with Nginx Unit. Check the official Coolify documentation for detailed Dockerfile configuration options.

## Key Configuration Recommendations

- Create databases/Redis before deployment
- Use `nixpacks.toml` for comprehensive container setup
- Configure queue worker and scheduler in a single container
- Support for Inertia.js with additional configuration
- Set appropriate memory and execution time limits
- Configure PHP-FPM settings
- Use environment-specific configurations
- Implement proper SSL and proxy settings

## Deployment Best Practices

- Set default environment variables appropriately
- Configure post-deployment scripts
- Support various PHP extensions and optimizations
- Handle queue workers and background processes
- Configure proper health checks

---

**Source:** [Coolify Laravel Documentation](https://coolify.io/docs/applications/laravel)
