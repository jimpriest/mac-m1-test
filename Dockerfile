# ==============================================================================
# initial build - CommandBox / Adobe CF2021 / Adobe JDK
# ==============================================================================
FROM ortussolutions/commandbox:adobe2021 as workbench

RUN mkdir -p /jim

# set environment for initial commandbox spinup
ENV APP_DIR /jim
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

# Check JAVA_HOME path in Adobe CFAdmin info screen
RUN ${BIN_DIR}/box server set jvm.javaHome="/opt/jdk-11.0.19"

# Generate the startup script only
ENV FINALIZE_STARTUP true
RUN ${BUILD_DIR}/run.sh





# ===================================================
# final build - Debian based image for final build
# ===================================================
FROM debian:buster-slim

RUN apt-get update \
    && apt-get install --assume-yes --no-install-recommends --quiet \
			unzip \
		&& apt-get autoremove -y \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME="/opt/jdk-11.0.19"
ENV JAVA_EXECUTABLE="/opt/jdk-11.0.19/bin/java"
ENV JAVA_LIBRARYPATH="/opt/jdk-11.0.19/lib"
ENV TZ='America/New_York'
ENV PYTHONBUFFERED=1




# ===================================================
# Restore working directory environment

RUN mkdir -p /jim

ENV APP_DIR /jim

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

# configure server using cfconfig
RUN ${BIN_DIR}/box cfconfig import from=${APP_DIR}/myconfig.json toFormat=adobe@2021


WORKDIR ${APP_DIR}
CMD ${BIN_DIR}/startup-final.sh

