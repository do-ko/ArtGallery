FROM node:slim AS build
WORKDIR /app

COPY ./package.json ./package-lock.json ./

RUN npm install
RUN apt update && apt install -y curl

COPY . .

RUN npm run build

FROM nginx:1.25.4

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
