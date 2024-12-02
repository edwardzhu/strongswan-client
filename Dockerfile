FROM alpine:latest

# Install required packages
RUN apk add --no-cache \
    strongswan \
    curl \
    ip6tables \
    iptables \
    openssl \
    bind-tools \
    ca-certificates

# Create necessary directories
RUN mkdir -p /etc/swanctl/x509ca \
    /etc/swanctl/conf.d \
    /var/run/charon

# Configure strongswan
RUN echo 'charon {' > /etc/strongswan.conf && \
    echo '    load_modular = yes' >> /etc/strongswan.conf && \
    echo '    plugins {' >> /etc/strongswan.conf && \
    echo '        include strongswan.d/charon/*.conf' >> /etc/strongswan.conf && \
    echo '    }' >> /etc/strongswan.conf && \
    echo '    filelog {' >> /etc/strongswan.conf && \
    echo '        stderr {' >> /etc/strongswan.conf && \
    echo '            default = 3' >> /etc/strongswan.conf && \
    echo '            ike = 3' >> /etc/strongswan.conf && \
    echo '            job = 3' >> /etc/strongswan.conf && \
    echo '            cfg = 3' >> /etc/strongswan.conf && \
    echo '            knl = 3' >> /etc/strongswan.conf && \
    echo '            net = 3' >> /etc/strongswan.conf && \
    echo '            enc = 3' >> /etc/strongswan.conf && \
    echo '            lib = 3' >> /etc/strongswan.conf && \
    echo '            esp = 3' >> /etc/strongswan.conf && \
    echo '            dmn = 3' >> /etc/strongswan.conf && \
    echo '            mgr = 3' >> /etc/strongswan.conf && \
    echo '            ike_name = 3' >> /etc/strongswan.conf && \
    echo '            flush_line = yes' >> /etc/strongswan.conf && \
    echo '        }' >> /etc/strongswan.conf && \
    echo '    }' >> /etc/strongswan.conf && \
    echo '}' >> /etc/strongswan.conf

# Create entrypoint script
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo 'mkdir -p /var/run/charon' >> /entrypoint.sh && \
    echo 'chmod 755 /var/run/charon' >> /entrypoint.sh && \
    echo 'echo "Starting strongSwan..."' >> /entrypoint.sh && \
    echo 'ipsec start --nofork' >> /entrypoint.sh

# Make entrypoint script executable
RUN chmod +x /entrypoint.sh

# Expose IKE and NAT-T ports
EXPOSE 500/udp 4500/udp

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]