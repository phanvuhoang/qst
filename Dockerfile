FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install Apache2 + mod_perl2 + system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-perl2 \
    libapache-dbi-perl \
    libdbd-mysql-perl \
    libdbi-perl \
    libarchive-zip-perl \
    libmime-base64-perl \
    cpanminus \
    make \
    gcc \
    libssl-dev \
    libexpat1-dev \
    perl \
    && rm -rf /var/lib/apt/lists/*

# Install libapreq2 (Apache2::Request) via CPAN — Debian package is broken on Bookworm
RUN cpanm -n Apache2::Request

# Install Crypt::PBKDF2 via CPAN (not in Debian repo)
RUN cpanm -n Crypt::PBKDF2

# Enable Apache modules
RUN a2enmod perl

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
