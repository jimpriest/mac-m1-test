# This will build a ColdFusion 2021 container
# This will first spin up default CommandBox image (which uses Ubuntu and OpenJDK)
# The server will be configured and then this information
# will be copied to another image which will use Debian / Adobe JDK / Apache
#
# ==============================================================================
# initial build - CommandBox / Adobe CF2021 / Adobe JDK
# ==============================================================================
FROM ortussolutions/commandbox:adobe2021 as workbench

# set environment for initial commandbox spinup
ENV APP_DIR /app
ENV BIN_DIR /usr/local/bin
ENV BOX_SERVER_PROFILE development
ENV JAVA_DIR /opt/jdk-11.0.19

# install required packages with ColdFusion Package Manager (CFPM)
ENV CFPM_INSTALL adminapi,administrator,mail

# configure server with cfconfig
COPY myconfig.json ${APP_DIR}

# Install Adobe Java 11
COPY jdk-11.0.19_linux-x64_bin.tar.gz /tmp
RUN tar -xzf /tmp/jdk-11.0.19_linux-x64_bin.tar.gz -C /opt \
    # && chown -R cfusion:root /opt/jdk-11.0.19 \
    && chmod -R 777 ${JAVA_DIR}
    # && mv /tmp/mysql-connector-java-8.0.22.jar /usr/share/java/mysql-connector-java-8.0.22.jar \
    # && mv /tmp/jvm.config /opt/ColdFusion/cfusion/bin \
    # && sed -i 's/RUNTIME_USER=$/RUNTIME_USER=cfusion/' /opt/ColdFusion/cfusion/bin/coldfusion \
    # && sed -i '/security.provider.12=SunPKCS11/a security.provider.13=org.bouncycastle.jce.provider.BouncyCastleProvider' /opt/jdk-11.0.19/conf/security/java.security


# Set JAVA_HOME in CommandBox - we'll install Adobe JDK below
# Check JAVA_HOME path in Adobe CFAdmin info screen
RUN ${BIN_DIR}/box server set jvm.javaHome="/opt/jdk-11.0.19"




# Generate the startup script only
ENV FINALIZE_STARTUP true
RUN ${BUILD_DIR}/run.sh





# ===================================================
# final build - Debian based image for final build
# ===================================================
#FROM adoptopenjdk/openjdk11:debianslim-jre as app

FROM debian:buster-slim

RUN apt-get update \
    && apt-get install --assume-yes --no-install-recommends --quiet \
			apache2-suexec-custom \
			apache2-utils \
			apache2 \
			apachetop \
			apt-transport-https \
			bzip2 \
			curl \
			libadns1 \
			libalgorithm-diff-perl \
			libalgorithm-diff-xs-perl \
			libalgorithm-merge-perl \
			libappindicator-dev \
			libbit-vector-perl \
			libcarp-clan-perl \
			libcurl3-gnutls \
			libcurl4 \
			libdate-calc-perl \
			libdatrie1 \
			libdbi-perl \
			libdbi-dev \
			libdigest-hmac-perl \
			libdigest-sha-perl \
			libdpkg-perl \
			liberror-perl \
			libhtml-format-perl \
			libhtml-parser-perl \
			libhtml-tagset-perl \
			libhtml-template-perl \
			libhtml-tree-perl \
			libio-socket-ssl-perl \
			libmailtools-perl \
			libnet-daemon-perl \
			libnet-libidn-perl \
			libnet-netmask-perl \
			libnet-ssleay-perl \
			libpdf-reuse-perl \
			librrd8 \
			librrds-perl \
			libtext-pdf-perl \
			libtimedate-perl \
			libtokyocabinet9 \
			liburi-perl \
			libwww-perl \
			libxrender1 \
			libyaml-tiny-perl \
			shared-mime-info \
			s-nail \
			ssl-cert \
			strace \
			sysstat \
			unzip \
			python-pip \
			libapr1 \
			libaprutil1-dbd-sqlite3 \
			libaprutil1-ldap \
			libaprutil1 \
			vim \
			wget \
		&& apt-get autoremove -y \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/* \
    && pip install supervisor \
		&& apache2ctl stop

# # Configure apache
# RUN set -ex \
#     && mkdir -p /etc/apache2/certs \
#     # && mv /tmp/etc/apache2/certs/* /etc/apache2/certs/ \
#     && mv /tmp/etc/apache2/includes /etc/apache2/includes/ \
#     && mv /tmp/etc/apache2/sites-available/* /etc/apache2/sites-available \
#     && mv /tmp/etc/apache2/suexec /etc/apache2/suexec \
#     && a2enmod rewrite \
#     && a2enmod ssl \
#     && a2enmod authz_groupfile \
#     && a2enmod suexec \
#     && a2ensite 000-default \
#     && a2ensite api.lindev.local \
#     && a2ensite manager.lindev.local \
#     && /opt/ColdFusion/cfusion/runtime/bin/wsconfig -ws apache -dir /etc/apache2/ \
#     && echo 'ServerName 127.0.0.1' >> /etc/apache2/apache2.conf

# # Configure custom coldfusion settings
# RUN set -ex \
#     # Add suds and bapi config
#     && mv /tmp/suds.json /etc/project/suds.json \
#     && mv /tmp/bapi.json /etc/project/bapi.json \
#     # Litle Sandbox config
#     && mkdir /home/cfusion/ \
#     && mv /tmp/.litle_SDK_config.properties /home/cfusion/.litle_SDK_config.properties \
#     && chown cfusion:cfusion /home/cfusion/.litle_SDK_config.properties \
#     && usermod -d /home/cfusion cfusion \
#     # Add BC as trusted security provider
#     && sed -i '/security.provider.12=SunPKCS11/a security.provider.13=org.bouncycastle.jce.provider.BouncyCastleProvider' /opt/ColdFusion/jre/conf/security/java.security \
#     && mv /tmp/bcprov-jdk15on-153.jar /opt/ColdFusion/cfusion/runtime/lib/bcprov-jdk15on-153.jar \
#     && chmod 0755 /opt/ColdFusion/jre/bin/java \
#     && chmod -R 0755 /opt/ColdFusion/cfusion/bin



ENV JAVA_HOME="/opt/jdk-11.0.19"
ENV JAVA_EXECUTABLE="/opt/jdk-11.0.19/bin/java"
ENV JAVA_LIBRARYPATH="/opt/jdk-11.0.19/lib"
ENV TZ='America/New_York'
ENV PYTHONBUFFERED=1




# ===================================================
# Restore working directory environment
ENV APP_DIR /app

# Directory Mappings
# box binary lives in BIN_DIR/box
# CommandBox folder lives in LIB_DIR/CommandBox
ENV BIN_DIR /usr/local/bin
ENV LIB_DIR /usr/local/lib
ENV BUILD_DIR ${LIB_DIR}/build
ENV JAVA_DIR /opt/jdk-11.0.19

# Copy App
COPY --from=workbench ${APP_DIR} ${APP_DIR}
# Copy CommandBox Binaries
COPY --from=workbench ${BIN_DIR} ${BIN_DIR}
# Copy CommandBox Root + Web Server + Build Scripts
COPY --from=workbench ${LIB_DIR} ${LIB_DIR}
# Copy JDK
COPY --from=workbench ${JAVA_DIR} ${JAVA_DIR}

# Install TestBox
# RUN $BIN_DIR/box install testbox

# configure server using cfconfig
RUN ${BIN_DIR}/box cfconfig import from=${APP_DIR}/myconfig.json toFormat=adobe@2021


WORKDIR ${APP_DIR}
CMD ${BIN_DIR}/startup-final.sh




