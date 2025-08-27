# Development stage - install all gems
FROM ruby:3.2-alpine AS development

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    git \
    nodejs \
    npm \
    tzdata \
    bash \
    curl \
    && rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /usr/src/app

# Create user to avoid running as root
RUN addgroup -g 1000 -S jekyll && \
    adduser -u 1000 -S jekyll -G jekyll

# Copy Gemfile first for better caching
COPY --chown=jekyll:jekyll Gemfile* ./

# Install all gems (including development gems)
RUN bundle install

# Copy application code
COPY --chown=jekyll:jekyll . .

# Create necessary directories
RUN mkdir -p _site .jekyll-cache && \
    chown -R jekyll:jekyll _site .jekyll-cache

USER jekyll

# Expose port
EXPOSE 4000

# Default command for development
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--port", "4000", "--livereload", "--force_polling"]

# Production stage - optimized build
FROM ruby:3.2-alpine AS production

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    git \
    nodejs \
    npm \
    tzdata \
    bash \
    curl \
    && rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /usr/src/app

# Create user
RUN addgroup -g 1000 -S jekyll && \
    adduser -u 1000 -S jekyll -G jekyll

# Copy Gemfile first
COPY --chown=jekyll:jekyll Gemfile* ./

# Install only production gems
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install --no-cache && \
    bundle clean

# Copy application code
COPY --chown=jekyll:jekyll . .

# Build the site
RUN bundle exec jekyll build

USER jekyll

EXPOSE 4000

# Serve static files for production
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--port", "4000", "--no-watch"]