# ==============================================================================
# initial build - CommandBox / Adobe CF2021 / Adobe JDK
# ==============================================================================
FROM ortussolutions/commandbox as initialbuild

# Set environment for initial CommandBox spinup
ENV APP_DIR /virtual/local.com/www/htdocs
ENV BIN_DIR /usr/local/bin
# https://www.forgebox.io/view/adobe#versions
ENV BOX_SERVER_APP_CFENGINE adobe@2021.0.10+330161
# https://commandbox.ortusbooks.com/embedded-server/configuring-your-server/server-profiles
# development or production
ENV BOX_SERVER_PROFILE development
ENV JAVA_DIR /opt/jdk-11.0.19
ENV JAVA_EXECUTABLE="${JAVA_DIR}/bin/java"
ENV JAVA_HOME="${JAVA_DIR}"
ENV JAVA_LIBRARYPATH="${JAVA_DIR}/lib"
ENV LIB_DIR /usr/local/lib
ENV SALT_DIR saltstack/salt/files
ENV TMP_DIR /tmp
ENV WWW_DIR /virtual/local.com
ENV BOX_SERVER_WEB_WEBROOT ${WWW_DIR}/www/htdocs

# This doesn't work... docs say this won't work in non warmed up cf image
# Install required packages with ColdFusion Package Manager (CFPM)
# ENV CFPM_INSTALL  adminapi,administrator,ajax,caching,chart,document,feed,image,mail,mysql,spreadsheet,zip
#
ENV CFPM_INSTALL  adminapi,administrator,debugger


# Create required directories
RUN mkdir -p \
        ${WWW_DIR}/logs \
        ${WWW_DIR}/www/logs \
				${WWW_DIR}/www/htdocs

# Copy config files to image tmp directory
COPY ${SALT_DIR} ${TMP_DIR}

# Install Adobe Java JDK - Set JAVA_HOME for commandbox startup script
RUN wget -P ${TMP_DIR} https://cfdownload.adobe.com/pub/adobe/coldfusion/java/java11/java11019/jdk-11.0.19_linux-x64_bin.tar.gz \
		&& tar -xzf ${TMP_DIR}/jdk-11.0.19_linux-x64_bin.tar.gz -C /opt \
		&& rm ${TMP_DIR}/jdk-11.0.19_linux-x64_bin.tar.gz \
		&& ${BIN_DIR}/box server set jvm.java_home="${JAVA_DIR}"

# Generate the startup script only
ENV FINALIZE_STARTUP true
RUN ${LIB_DIR}/build/run.sh



# ===================================================
# final build - Debian based image for final build
# ===================================================

FROM debian:bullseye-slim

# Restore environment
ENV APP_DIR /virtual/local.com/www/htdocs
ENV BIN_DIR /usr/local/bin
ENV JAVA_DIR /opt/jdk-11.0.19
ENV JAVA_EXECUTABLE="${JAVA_DIR}/bin/java"
ENV JAVA_HOME="${JAVA_DIR}"
ENV JAVA_LIBRARYPATH="${JAVA_DIR}/lib"
ENV LIB_DIR /usr/local/lib
ENV TMP_DIR /tmp
ENV TZ='America/New_York'
ENV WWW_DIR /virtual/local.com
ENV BOX_SERVER_WEB_WEBROOT ${WWW_DIR}/www/htdocs

# Create required support directories
RUN mkdir -p \
		/var/cache/local \
		/var/www/logs \
		/etc/local


# Copy directories from commandbox image to this image
COPY --from=initialbuild ${APP_DIR} ${APP_DIR}
COPY --from=initialbuild ${BIN_DIR} ${BIN_DIR}
COPY --from=initialbuild ${LIB_DIR} ${LIB_DIR}
COPY --from=initialbuild ${JAVA_DIR} ${JAVA_DIR}
COPY --from=initialbuild ${TMP_DIR} ${TMP_DIR}
COPY --from=initialbuild ${WWW_DIR} ${WWW_DIR}

# Apt update  / install dependencies
RUN apt-get update \
    && apt-get install --assume-yes --no-install-recommends --quiet \
			apt-transport-https \
			bzip2 \
			curl \
			wget \
			procps \
			unzip \
		&& apt-get autoremove -y \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*

# Configure apache
# RUN set -ex \
#     && mkdir -p /etc/apache2/certs \
# 		# temp moved this to bind volume mounts so I can tweak on the fly
#     # && mv ${TMP_DIR}/etc/apache2/includes /etc/apache2/includes/ \
#     # && mv ${TMP_DIR}/etc/apache2/sites-available/* /etc/apache2/sites-available \
#     && a2enmod rewrite \
# 		&& a2enmod proxy \
# 		&& a2enmod proxy_http \
#     && a2enmod ssl \
#     && a2enmod authz_groupfile \
#     && a2ensite 000-default \
#     && echo 'ServerName 127.0.0.1' >> /etc/apache2/apache2.conf

# Install TestBox
# RUN $BIN_DIR/box install testbox

# Configure JAVA to use Adobe JDK
RUN ${BIN_DIR}/box server set jvm.javaHome="/opt/jdk-11.0.19"

COPY docker/docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR ${APP_DIR}
ENTRYPOINT ["/docker-entrypoint.sh"]
