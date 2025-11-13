# Stage 1 — build with Node & Parcel
FROM node:18 AS builder

WORKDIR /app

# Install build dependencies
COPY package.json package-lock.json* ./
RUN npm ci --only=production || npm install

# Install parcel (local devDependencies included)
RUN npm install --save-dev parcel

# Copy source files
COPY src ./src
COPY styles ./styles
COPY . .

# ✅ Build all HTML pages at once
RUN npx parcel build src/*.html --dist-dir ./dist --public-url ./

# Stage 2 — serve with nginx
FROM nginx:alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy built files to nginx web root
COPY --from=builder /app/dist /usr/share/nginx/html