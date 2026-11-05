FROM nginx:stable-alpine
LABEL org.opencontainers.image.title="mission1-web"
COPY site/ /usr/share/nginx/html/
COPY nginx/templates/default.conf.template /etc/nginx/templates/default.conf.template
