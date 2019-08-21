FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive
ENV TZ America/Sao_Paulo

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      slapd \
      ldap-utils

EXPOSE 389 636
VOLUME ["/etc/ldap/slapd.d", "/var/lib/ldap"]
COPY ["run", "/usr/local/bin/"]
COPY ["ldifs", "/etc/ldap/"]
RUN chmod +x /usr/local/bin/run

ENTRYPOINT ["/usr/local/bin/run"]
#CMD ["slapd", "-u", "openldap", "-g", "openldap", "-h", "ldapi:/// ldaps:/// ldap:///", "-d", "1", "-F", "/etc/ldap/slapd.d/"]
#CMD ["bash"]
