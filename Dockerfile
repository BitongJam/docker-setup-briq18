FROM odoo:18.0

USER root

# Install only necessary build tools (no libpq-dev)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        gcc python3-dev python3-pip \
        ca-certificates curl dirmngr gnupg node-less npm \
        fonts-noto-cjk python3-magic python3-num2words \
        python3-odf python3-pdfminer python3-phonenumbers \
        python3-pyldap python3-qrcode python3-renderpm \
        python3-setuptools python3-slugify python3-vobject \
        python3-watchdog python3-xlrd python3-xlwt && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages system-wide
RUN pip install --break-system-packages \
        psycopg2-binary \
        qifparse

USER odoo
