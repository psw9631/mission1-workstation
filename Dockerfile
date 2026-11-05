FROM nginx:stable-alpine
LABEL org.opencontainers.image.title="mission1-web"
COPY site/ /usr/share/nginx/html/
