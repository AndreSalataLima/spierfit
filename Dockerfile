  # syntax=docker/dockerfile:1
  # check=error=true

  ARG RUBY_VERSION=3.4.2
  FROM ruby:$RUBY_VERSION-slim AS base

  WORKDIR /rails

  # Install base packages
  RUN apt-get update -qq && \
      apt-get install --no-install-recommends -y \
        curl libjemalloc2 libvips postgresql-client && \
      rm -rf /var/lib/apt/lists /var/cache/apt/archives

  ENV RAILS_ENV="production" \
      BUNDLE_DEPLOYMENT="1" \
      BUNDLE_PATH="/usr/local/bundle" \
      BUNDLE_WITHOUT="development"

  # ---------------------- BUILD STAGE ------------------------
  FROM base AS build

  # Create the rails user
  RUN id -u rails 2>/dev/null || adduser --disabled-password --gecos "" rails

  # Install dependencies needed for building gems
  RUN apt-get update -qq && \
      apt-get install --no-install-recommends -y \
        build-essential git libpq-dev pkg-config libyaml-dev && \
      rm -rf /var/lib/apt/lists /var/cache/apt/archives

  USER rails

  # Install gems
  COPY --chown=rails:rails Gemfile Gemfile.lock ./
  RUN bundle install && \
      rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
      bundle exec bootsnap precompile --gemfile

  # Copy the app source
  COPY --chown=rails:rails . .
  COPY --chown=rails:rails config/tailwind.config.yml config/tailwind.config.yml


  # Precompile code and assets
  RUN bundle exec bootsnap precompile app/ lib/
  RUN mkdir -p app/assets/tailwind && cp app/assets/stylesheets/application.tailwind.css app/assets/tailwind/application.css

  RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails tailwindcss:build && SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


  # ---------------------- FINAL IMAGE ------------------------
  FROM base

  # Create rails user and set permissions
  RUN groupadd --system --gid 1000 rails && \
      useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
      mkdir -p /rails/db /rails/log /rails/storage /rails/tmp && \
      chown -R rails:rails /rails

  # Copy built app from build stage
  COPY --from=build --chown=rails:rails /usr/local/bundle /usr/local/bundle
  COPY --from=build --chown=rails:rails /rails /rails

  USER rails

  # Entrypoint and default command
  ENTRYPOINT ["/rails/bin/docker-entrypoint"]

  EXPOSE 3000
  CMD ["./bin/rails", "server"]
