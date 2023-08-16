FROM ortussolutions/commandbox as workbench

# set environment for initial commandbox spinup
ENV APP_DIR /app
ENV BIN_DIR /usr/local/bin
ENV BOX_SERVER_PROFILE development
ENV JAVA_DIR /opt/jdk-11.0.19
ENV BOX_SERVER_APP_CFENGINE adobe@2021.0.9+330148

ENV PORT 8080


# install required packages with ColdFusion Package Manager (CFPM)
# this seems to throw an error when installing packages - but when the server spins up they are installed?
#
# 12 out of 12 packages downloaded.
# => => # Packages have been downloaded. Now they will get installed.
# => => # caching package cannot be installed by the server. Please check the server logs and try installing aga
#
ENV CFPM_INSTALL adminapi,administrator,ajax,caching,chart,document,feed,image,mail,mysql,spreadsheet,zip

# configure server with cfconfig
COPY myconfig.json ${APP_DIR}

# Install Adobe Java 11
COPY jdk-11.0.19_linux-x64_bin.tar.gz /tmp
RUN tar -xzf /tmp/jdk-11.0.19_linux-x64_bin.tar.gz -C /opt

# set java
RUN ${BIN_DIR}/box server set jvm.javaHome="/opt/jdk-11.0.19" \
	&& ${BIN_DIR}/box server set jvm.args="-Xms256m -Xmx4024m"

# Generate the startup script only
ENV FINALIZE_STARTUP true
RUN ${BUILD_DIR}/run.sh





# # ===================================================
# # final build - Debian based image for final build
# # ===================================================
# FROM debian:buster-slim

# RUN apt-get update \
#     && apt-get install --assume-yes --no-install-recommends --quiet \
# 			unzip \
# 		&& apt-get autoremove -y \
# 		&& apt-get clean \
# 		&& rm -rf /var/lib/apt/lists/*

# ENV JAVA_HOME="/opt/jdk-11.0.19"
# ENV JAVA_EXECUTABLE="/opt/jdk-11.0.19/bin/java"
# ENV JAVA_LIBRARYPATH="/opt/jdk-11.0.19/lib"
# ENV TZ='America/New_York'
# ENV PYTHONBUFFERED=1




# # ===================================================
# # Restore working directory environment

# RUN mkdir -p /jim

# ENV APP_DIR /jim

# # Directory Mappings
# # box binary lives in BIN_DIR/box
# # CommandBox folder lives in LIB_DIR/CommandBox
# ENV BIN_DIR /usr/local/bin
# ENV LIB_DIR /usr/local/lib
# ENV BUILD_DIR ${LIB_DIR}/build
# ENV JAVA_DIR /opt/jdk-11.0.19

# # Copy App
# COPY --from=workbench ${APP_DIR} ${APP_DIR}
# # Copy CommandBox Binaries
# COPY --from=workbench ${BIN_DIR} ${BIN_DIR}
# # Copy CommandBox Root + Web Server + Build Scripts
# COPY --from=workbench ${LIB_DIR} ${LIB_DIR}
# # Copy JDK
# COPY --from=workbench ${JAVA_DIR} ${JAVA_DIR}

# # configure server using cfconfig
# RUN ${BIN_DIR}/box cfconfig import from=${APP_DIR}/myconfig.json toFormat=adobe@2021


# WORKDIR ${APP_DIR}
# CMD ${BIN_DIR}/startup-final.sh

