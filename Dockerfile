FROM nginx:alpine
LABEL maintainer="jaeuk"
LABEL description="Custom Nginx Web Server for Dev Workstation"
ENV APP_ENV=production
COPY app/index.html /usr/share/nginx/html/index.html
EXPOSE 80
