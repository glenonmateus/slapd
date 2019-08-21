FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive
ENV TZ America/Sao_Paulo

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      slapd \
      ldap-utils

COPY ["run", "/usr/local/bin/"]
COPY ["ldifs", "/etc/ldap/"]
COPY ["samba.schema", "/etc/ldap/schema/"]
COPY ["samba.conf", "/tmp/"] 

RUN mkdir /tmp/slapd.d/ && \
    slaptest -f /tmp/schema.conf -F /tmp/slapd.d/ && \
    cp /tmp/slapd.d/cn=config/cn=schema/cn={4}samba.ldif /etc/ldap/slapd.d/cn=config/cn=schema && \
    chown openldap: /etc/ldap/slapd.d/cn=config/cn=schema/cn={4}samba.ldif
    
EXPOSE 389 636
VOLUME ["/etc/ldap/slapd.d", "/var/lib/ldap"]

RUN chmod +x /usr/local/bin/run
ENTRYPOINT ["/usr/local/bin/run"]
