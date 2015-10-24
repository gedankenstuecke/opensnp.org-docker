FROM phusion/passenger-ruby22:0.9.17

ENV RAILS_ENV production

RUN apt-get -q update
RUN apt-get -qy upgrade
RUN apt-get install -qy libhiredis-dev
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD nginx.conf /etc/nginx/sites-enabled/opensnp.org.conf
RUN rm /etc/nginx/sites-enabled/default
RUN rm -f /etc/service/nginx/down

RUN git clone --depth=1 --branch=dockerize https://github.com/tsujigiri/snpr.git /home/app/snpr
WORKDIR /home/app/snpr
RUN rm -rf .git
RUN chown app:app -R /home/app

USER app

ADD database.yml config/database.yml
RUN bundle install --deployment --without test development
RUN cp .env.example .env
RUN bundle exec rake assets:precompile
RUN rm .env

USER root

RUN bin/extract_env_var_names_for_nginx > /etc/nginx/main.d/rails-env.conf

CMD ["/sbin/my_init"]
