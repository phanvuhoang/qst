FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install ONLY Apache2 (no Perl!)
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    default-mysql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app directories
RUN mkdir -p /home /var/www/qst

# Copy QST files
COPY qst_gpl/qst.sql /home/qst.sql
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

# Entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
