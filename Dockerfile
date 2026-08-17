FROM jekyll/jekyll:4

# Copy Gemfile (Gemfile.lock optional)
COPY Gemfile ./

# Install dependencies (ignore lockfile/platform issues)
RUN bundle install || true

# Copy the rest of the site
COPY . .

CMD ["jekyll", "serve", "--force_polling", "--livereload", "--host", "0.0.0.0"]
