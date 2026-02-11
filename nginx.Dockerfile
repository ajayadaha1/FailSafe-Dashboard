# ============================================================================
# Stage 1: Build MkDocs sites
# ============================================================================
FROM python:3.12-slim AS docs-builder

WORKDIR /build

# Install shared docs dependencies
COPY Silicon-Trace/docs-requirements.txt /build/st-docs-requirements.txt
COPY L3_Debug/docs-requirements.txt /build/l3-docs-requirements.txt
RUN pip install --no-cache-dir -r /build/st-docs-requirements.txt -r /build/l3-docs-requirements.txt

# Build Silicon Trace docs
COPY Silicon-Trace/mkdocs.yml /build/silicon-trace/mkdocs.yml
COPY Silicon-Trace/docs /build/silicon-trace/docs
RUN cd /build/silicon-trace && mkdocs build --clean

# Build L3_Debug docs
COPY L3_Debug/mkdocs.yml /build/l3-debug/mkdocs.yml
COPY L3_Debug/docs /build/l3-debug/docs
RUN cd /build/l3-debug && mkdocs build --clean

# ============================================================================
# Stage 2: Nginx with built docs
# ============================================================================
FROM nginx:alpine

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy static website files
COPY failsafedashboard.github.io /usr/share/nginx/html/static

# Copy MkDocs-built documentation sites from builder stage
COPY --from=docs-builder /build/silicon-trace/site /usr/share/nginx/html/silicon-trace-docs
COPY --from=docs-builder /build/l3-debug/site /usr/share/nginx/html/L3-Debug-Doc

# Expose ports
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
