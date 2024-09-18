# Configure base Tomcat image
ARG BASE_IMAGE_VERSION
FROM tomcat:${BASE_IMAGE_VERSION}

# Upgrade base OS packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set locale environment variables
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_CTYPE="en_US.UTF-8" \
    LC_NUMERIC="en_US.UTF-8" \
    LC_TIME="en_US.UTF-8" \
    LC_COLLATE="en_US.UTF-8" \
    LC_MONETARY="en_US.UTF-8" \
    LC_MESSAGES="en_US.UTF-8" \
    LC_PAPER="en_US.UTF-8" \
    LC_NAME="en_US.UTF-8" \
    LC_ADDRESS="en_US.UTF-8" \
    LC_TELEPHONE="en_US.UTF-8" \
    LC_MEASUREMENT="en_US.UTF-8" \
    LC_IDENTIFICATION="en_US.UTF-8" \
    LC_ALL=en_US.UTF-8

# Install Gomplate
RUN curl -L -o /usr/bin/gomplate https://github.com/hairyhenderson/gomplate/releases/download/v3.8.0/gomplate_linux-amd64 &&\
    chmod +x /usr/bin/gomplate

# Generate self-signed cert for end-to-end TLS
RUN mkdir -p $CATALINA_HOME/ssl &&\
    openssl req -x509 -nodes -newkey rsa:4096 \
    -keyout $CATALINA_HOME/ssl/localhost-rsa-key.pem -out $CATALINA_HOME/ssl/localhost-rsa-cert.pem \
    -days 7300 -subj '/C=US/ST=California/L=Visalia/O=QA/OU=Technology Services/CN=localhost' 

# Add non-privileged user
RUN groupadd -g 900 docker_tomcat &&\
    useradd -u 900 -g 900 docker_tomcat

# Set BASH_ENV to point to the profile script in /etc/profile.d/
RUN echo 'export BASH_ENV=/etc/profile.d/.bash_profile' >> /etc/bash.bashrc
RUN echo 'source $BASH_ENV' >> /etc/bash.bashrc

# Set permissions
RUN chown 900:900 -R $CATALINA_HOME
USER 900:900

# Set default container run command
CMD ["catalina.sh", "run"]