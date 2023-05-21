# Frontend - Nodejs application

FROM node:latest
WORKDIR /app
RUN npm install
COPY . .
CMD ["npm", "start"]

