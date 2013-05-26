#server {
#  listen <ip>:80;
#  server_name  <domain>;
#  rewrite ^/(.*) http://www.<domain> permanent;
#}
server {
listen <ip>:80;
server_name <domain> www.<domain>;

access_log <log_directory><domain>.access.log;
error_log <log_directory><domain>.error.log;

root <path>/public_html/;
index index.php index.html index.htm;

if (!-e \$request_filename) {
rewrite ^/(.*)\$ /index.php?q=\$1 last;
}

# serve static files directly
location ~* ^.+.(jpg|jpeg|gif|css|png|js|ico)\$ {
access_log        off;
expires           30d;
}

location ~ \.php\$ {
fastcgi_pass 127.0.0.1:9000;
fastcgi_index index.php;
fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
include fastcgi_params;
}

}
CONFIG