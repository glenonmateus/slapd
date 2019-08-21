FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive
ENV TZ America/Sao_Paulo

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      slapd \
      ldap-utils && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    mkdir /etc/ldap/certs && mkdir /etc/ldap/private && \
    chown openldap: /etc/ldap/certs && chown openldap: /etc/ldap/private

COPY ["run", "/usr/local/bin/"]
COPY ["ldifs", "/etc/ldap/"]
COPY ["samba.schema", "/etc/ldap/schema/"]
COPY ["schema.conf", "/tmp/"] 
COPY --chown=openldap:openldap ["ldap.crt", "/etc/ldap/certs/"]
COPY --chown=openldap:openldap ["ldap.csr", "/etc/ldap/certs/"]
COPY --chown=openldap:openldap ["ldap.key", "/etc/ldap/private/"]

RUN mkdir /tmp/slapd.d/ && \
    slaptest -f /tmp/schema.conf -F /tmp/slapd.d/ && \
    cp /tmp/slapd.d/cn=config/cn=schema/cn={4}samba.ldif /etc/ldap/slapd.d/cn=config/cn=schema && \
    chown openldap: /etc/ldap/slapd.d/cn=config/cn=schema/cn={4}samba.ldif
    
EXPOSE 389 636
VOLUME ["/etc/ldap/slapd.d", "/var/lib/ldap"]

RUN chmod +x /usr/local/bin/run
ENTRYPOINT ["/usr/local/bin/run"]
