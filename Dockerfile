FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Apache + Perl + MySQL client
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-perl2 \
    libapache2-mod-apreq2 \
    libapache2-request-perl \
    libapache-dbi-perl \
    libdbd-mysql-perl \
    libdbi-perl \
    libarchive-zip-perl \
    libmime-base64-perl \
    libcrypt-pbkdf2-perl \
    default-mysql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Remove ALL default Apache config — start from scratch
RUN rm -rf /etc/apache2/sites-enabled/* /etc/apache2/conf-enabled/* && \
    a2enmod perl && a2enmod apreq2 && \
    a2enmod mime && a2enmod dir && a2enmod authz_core && a2enmod authz_host

# Create directories
RUN mkdir -p /home /var/www/qst

# Copy QST files
COPY qst_gpl/QST.pm /home/QST.pm
COPY qst_gpl/startup.pl /home/startup.pl
COPY qst_gpl/qst.sql /home/qst.sql
COPY qst_gpl/qst/ /var/www/qst/
COPY qst_gpl/schools/ /var/www/qst/schools/
COPY qst-apache.conf /etc/apache2/apache2.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create required directories
RUN mkdir -p /var/www/qst/schools/qst_files/photos

# Fix permissions
RUN chown -R www-data:www-data /var/www/qst /home

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
