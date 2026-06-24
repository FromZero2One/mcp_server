FROM python:3.12-slim
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY pyproject.toml uv.lock ./
COPY mcp_server.py ./

# Install project dependencies
RUN pip install --no-cache-dir -e .

EXPOSE 8000

# Run MCP server in SSE mode
# FastMCP SSE: listens on http://0.0.0.0:8000/mcp/sse
CMD ["mcp", "run", "mcp_server.py", "--transport", "sse", "--port", "8000"]
