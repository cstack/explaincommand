FROM ruby:3.1.1

WORKDIR /myapp

# Install ruby dependencies
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

# Add our code
COPY . .

# Run the app   
CMD rails server -b 0.0.0.0