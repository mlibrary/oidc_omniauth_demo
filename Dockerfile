FROM ruby:3.1
ARG UNAME=app
ARG UID=1000
ARG GID=1000

LABEL maintainer="mrio@umich.edu"

RUN gem install bundler

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /gems && chown ${UID}:${GID} /gems

USER $UNAME

ENV BUNDLE_PATH /gems

WORKDIR /app

CMD ["bundle", "exec", "ruby", "oidc_demo.rb", "-o", "0.0.0.0"]
