FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-perl2 \
    libapache2-mod-apreq2 \
    libapache2-request-perl \
    libapache-dbi-perl \
    libdbd-mysql-perl \
    libdbi-perl \
    libarchive-zip-perl \
    libcrypt-pbkdf2-perl \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod perl && a2enmod apreq2

RUN mkdir -p /home /var/www/qst

# Copy QST files
COPY qst_gpl/QST.pm /home/QST.pm
COPY qst_gpl/startup.pl /home/startup.pl
COPY qst_gpl/qst.sql /home/qst.sql
COPY qst_gpl/qst/ /var/www/qst/
COPY qst_gpl/schools/ /var/www/qst/schools/
COPY qst-apache.conf /etc/apache2/sites-available/qst.conf

RUN a2dissite 000-default.conf && a2ensite qst.conf

RUN mkdir -p /var/www/qst/schools/qst_files/photos
RUN chown -R www-data:www-data /var/www/qst /home

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
