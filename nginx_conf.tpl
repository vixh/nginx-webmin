server {
listen <ip>:80;
server_name <domain>, www.<domain>

access_log /var/log/nginx/<domain>.access.log;
error_log /var/log/nginx/<domain>.error.log;


root <path>/public_html/;

location / {
index index.php;
try_files $uri $uri/ @script;
}

location @script{
rewrite ^(.*)$ /index.php last;
}

location ~ \.php$ {
fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
include /etc/nginx/fastcgi_params;
}

}