FROM node:22-slim

# Install build dependencies for native modules
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json ./

# Install dependencies (including native modules)
RUN npm install --build-from-source

# Copy source code
COPY . .

# Build TypeScript
RUN npm run build

# Create directory for qmd cache
RUN mkdir -p /root/.cache/qmd

# Create config directory and default config
RUN mkdir -p /root/.config/qmd
RUN echo 'models:\n  embed: embeddinggemma-300m\n  rerank: mmarco-mminilmv2-l12-h384-v1\n  generate: gemma-3-27b-it\n  external_api:\n    base_url: http://aia-proxy:8080\n    api_key: ""' > /root/.config/qmd/index.yml

# Expose MCP HTTP port
EXPOSE 8181

# Start qmd MCP HTTP server
CMD ["node", "dist/cli/qmd.js", "mcp", "--http", "--port", "8181"]
