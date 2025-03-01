
FROM node:18
WORKDIR /app
COPY package.json package.json
COPY server.js server.js
RUN npm install
EXPOSE 4000
CMD ["node", "server.js"]
