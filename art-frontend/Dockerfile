FROM node:slim AS build
ARG IP
ARG COGNITO_USER_POOL_ID
ARG COGNITO_CLIENT_ID
ARG API_GATEWAY_ID
WORKDIR /app

COPY ./package.json ./package-lock.json ./

RUN npm install
RUN apt update && apt install -y curl

COPY . .
#
#RUN sed -i "s/localhost/$IP/g" ./src/pages/MainPage.jsx
#RUN sed -i "s/localhost/$IP/g" ./src/other/axios.js
#RUN sed -i "s/userpoolid/$COGNITO_USER_POOL_ID/g" ./src/other/UserPool.js
#RUN sed -i "s/userpoolclientid/$COGNITO_CLIENT_ID/g" ./src/other/UserPool.js
#RUN sed -i "s/apigatewayid/$API_GATEWAY_ID/g" ./src/other/axios.js

RUN npm run build

FROM nginx:1.25.4

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
