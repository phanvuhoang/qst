FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install ONLY Apache2 (no Perl!)
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    default-mysql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Disable ALL optional modules — keep only essential ones
RUN a2dismod autoindex deflate status negotiation mime_magic alias auth_basic authn_anon authn_dbm authn_socache authnz_fcgi authnz_ldap authz_dbm authz_groupfile authz_owner authz_user access_compat authz_core authz_host authn_core authn_file setenvif reqtimeout filter env headers version socache_shmcb ssl 2>/dev/null || true

# Create app directories
RUN mkdir -p /home /var/www/qst

# Copy QST files
COPY qst_gpl/qst.sql /home/qst.sql
COPY qst_gpl/qst/ /var/www/qst/
COPY qst_gpl/schools/ /var/www/qst/schools/

# DEBUG: List .htm files to verify and break cache
RUN echo "=== DEBUG: /var/www/qst/ files ===" && ls -la /var/www/qst/*.htm /var/www/qst/*.html 2>&1 && echo "=== DEBUG: /var/www/qst/schools/ .htm files ===" && ls /var/www/qst/schools/*.htm 2>&1 | head -10

# DEBUG: Create a guaranteed test
RUN echo "<h1>OK</h1>" > /var/www/qst/ok.htm && echo "<h1>OKHTML</h1>" > /var/www/qst/ok.html

# Copy Apache config
COPY qst-apache.conf /etc/apache2/sites-available/qst.conf

# Disable default site, enable QST
RUN a2dissite 000-default.conf && a2ensite qst.conf

# Create required directories
RUN mkdir -p /var/www/qst/schools/qst_files/photos

# Fix permissions
RUN chown -R www-data:www-data /var/www/qst /home

# Entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
