FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Apache2 + mod_perl2 + all dependencies via apt
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
    cpanminus \
    make \
    gcc \
    libssl-dev \
    perl \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod perl && a2enmod apreq

# Create app directories
RUN mkdir -p /home /var/www/qst

# Copy QST files
COPY qst_gpl/QST.pm /home/QST.pm
COPY qst_gpl/startup.pl /home/startup.pl
COPY qst_gpl/qst/ /var/www/qst/
COPY qst_gpl/schools/ /var/www/qst/schools/

# Copy Apache config
COPY qst-apache.conf /etc/apache2/sites-available/qst.conf

# Disable default site, enable QST
RUN a2dissite 000-default.conf && a2ensite qst.conf

# Create required directories
RUN mkdir -p /var/www/qst/schools/qst_files/photos

# Fix permissions
RUN chown -R www-data:www-data /var/www/qst /home

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]
