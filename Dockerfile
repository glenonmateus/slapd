FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive
ENV TZ America/Sao_Paulo

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      slapd \
      ldap-utils \ 
      gnutls-bin \ 
      ssl-cert && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    usermod -aG ssl-cert openldap && \
    mkdir /etc/ldap/certs/ && mkdir -m 0710 /etc/ldap/private/ && \
    chown :ssl-cert /etc/ldap/private/

COPY ["run", "/usr/local/bin/"]
COPY ["samba.schema", "/etc/ldap/schema/"]
COPY ["sudo.schema", "/etc/ldap/schema/"]
COPY ["schema.conf", "/tmp/"] 

RUN mkdir /tmp/slapd.d/ && \
    slaptest -f /tmp/schema.conf -F /tmp/slapd.d/ && \
    cp -R /tmp/slapd.d/cn=config/cn=schema/* /etc/ldap/slapd.d/cn=config/cn=schema && \
    chown openldap: /etc/ldap/slapd.d/cn=config/cn=schema/* && \
    rm -rf /tmp/slapd.d/ /tmp/schema.conf

EXPOSE 389 636
VOLUME ["/etc/ldap/slapd.d", "/var/lib/ldap"]

RUN chmod +x /usr/local/bin/run
ENTRYPOINT ["/usr/local/bin/run"]
