FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends apache2 curl && rm -rf /var/lib/apt/lists/*

# Create test files
RUN echo "<h1>HELLO FROM HTM</h1>" > /var/www/html/index.htm
RUN echo "<h1>HELLO FROM HTML</h1>" > /var/www/html/index.html
RUN echo "PLAIN TEXT" > /var/www/html/test.txt
RUN chmod 644 /var/www/html/*

EXPOSE 80

# Simple entrypoint - no MySQL dependency for this test
RUN echo '#!/bin/bash\necho "Starting Apache..."\nexec apache2ctl -D FOREGROUND' > /entrypoint.sh && chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
