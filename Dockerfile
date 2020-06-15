FROM alpine/helm:3.2.3

RUN apk --update add --no-cache \
  git \
  bash \
  curl \
  jq \
  && mkdir -p ~/.helm/plugins \
  # Install Helm push plugin (for pushing charts to repos).
  && helm plugin install https://github.com/chartmuseum/helm-push

ADD script.sh /bin/

RUN chmod +x /bin/script.sh

ENTRYPOINT /bin/script.sh