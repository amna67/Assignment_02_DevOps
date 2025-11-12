# Stage 1 — build with Node & Parcel
FROM node:18-alpine AS builder

WORKDIR /app

# Install build dependencies
COPY package.json package-lock.json* ./
RUN npm ci --only=production || npm install

# Install parcel (local devDependencies included) — prefer local install if present
RUN npm install --save-dev parcel

# Copy source
COPY src ./src
COPY styles ./styles
COPY . .

# Build (assumes entry points in src/*.html)
RUN npx parcel build src/index.html --dist-dir ./dist --public-url ./ \
 && npx parcel build src/about.html --dist-dir ./dist --public-url ./ \
 && npx parcel build src/events.html --dist-dir ./dist --public-url ./ \
 && npx parcel build src/gallery.html --dist-dir ./dist --public-url ./ \
 && npx parcel build src/contact.html --dist-dir ./dist --public-url ./

# Stage 2 — serve with nginx
FROM nginx:alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy built files
COPY --from=builder /app/dist /usr/share/nginx/html