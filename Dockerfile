FROM node:20.18-alpine AS build
WORKDIR /app

COPY package*.json ./
COPY generated_openssl_cert/ ./generated_openssl_cert
RUN npm ci && npm install -g @angular/cli

COPY . . 
RUN ng build --configuration production

FROM nginx:stable-alpine-slim
WORKDIR /app

COPY --from=build /app/dist/employeemanagerfrontend/browser/ /usr/share/nginx/html
COPY --from=build /app/generated_openssl_cert/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/generated_openssl_cert/nginx_fkey.crt /etc/nginx/certs/nginx_fkey.crt
COPY --from=build /app/generated_openssl_cert/nginx_fkey.key /etc/nginx/certs/nginx_fkey.key