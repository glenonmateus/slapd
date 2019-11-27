FROM debian:buster-slim
LABEL maintainer="Glenon Mateus <glenonmateus@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Sao_Paulo

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      slapd \
      ldap-utils && \
    rm -rf /var/lib/apt/lists/*

COPY ["schema", "/etc/ldap/schema/"]
COPY ["schema.conf", "/tmp/"]

RUN mkdir /tmp/slapd.d/ && \
    slaptest -f /tmp/schema.conf -F /tmp/slapd.d/ && \
    cp -R /tmp/slapd.d/cn=config/cn=schema/* /etc/ldap/slapd.d/cn=config/cn=schema && \
    chown openldap: /etc/ldap/slapd.d/cn=config/cn=schema/* && \
    rm -rf /tmp/slapd.d/ /tmp/schema.conf

EXPOSE 389 636
VOLUME ["/etc/ldap/", "/var/lib/ldap"]

COPY ["docker-entrypoint", "."]
RUN chmod +x docker-entrypoint
ENTRYPOINT ["/docker-entrypoint"]
