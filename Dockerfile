FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install Apache2 + mod_perl2 + build deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    apache2-dev \
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
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install libapreq2 from source (CPAN fails without apache2-dev)
# Build Apache2::Request manually
RUN cd /tmp && \
    wget -q https://www.cpan.org/authors/id/S/SH/SHAY/libapreq2-2.17.tar.gz && \
    tar xzf libapreq2-2.17.tar.gz && \
    cd libapreq2-2.17 && \
    perl Makefile.PL --with-apache2-apxs=/usr/bin/apxs && \
    make && make install && \
    cd / && rm -rf /tmp/libapreq2-2.17*

# Install Crypt::PBKDF2 via CPAN
RUN cpanm -n Crypt::PBKDF2

# Enable Apache modules
RUN a2enmod perl && \
    echo "LoadModule apreq_module /usr/lib/apache2/modules/mod_apreq2.so" > /etc/apache2/mods-available/apreq2.load && \
    a2enmod apreq2 2>/dev/null; exit 0

# Disable default site (will fail on first install if already done)
RUN a2dissite 000-default.conf 2>/dev/null; exit 0

# Create app directories
RUN mkdir -p /home /var/www/qst

# Copy QST files
COPY qst_gpl/QST.pm /home/QST.pm
COPY qst_gpl/startup.pl /home/startup.pl
COPY qst_gpl/qst/ /var/www/qst/
COPY qst_gpl/schools/ /var/www/qst/schools/

# Copy Apache config
COPY qst-apache.conf /etc/apache2/sites-available/qst.conf

# Enable QST site
RUN a2ensite qst.conf

# Create required directories
RUN mkdir -p /var/www/qst/schools/qst_files/photos

# Fix permissions
RUN chown -R www-data:www-data /var/www/qst /home

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]
