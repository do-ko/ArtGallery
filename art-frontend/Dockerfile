FROM node:slim AS build
WORKDIR /app

COPY ./package.json ./package-lock.json ./

RUN npm install
RUN apt update && apt install -y curl

COPY . .

RUN npm run build

FROM nginx:1.25.4

RUN apt-get update && apt-get install -y --no-install-recommends gettext-base \
 && rm -rf /var/lib/apt/lists/*


COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/dist /usr/share/nginx/html

COPY docker-entrypoint.d/99-generate-config.sh /docker-entrypoint.d/99-generate-config.sh
RUN chmod +x /docker-entrypoint.d/99-generate-config.sh

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]