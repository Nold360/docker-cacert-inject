# Build CA/Cert and run nginx
# then run patched image & wget https://nginx
FROM nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY certs /certs
