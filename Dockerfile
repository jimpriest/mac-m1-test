# This will build a ColdFusion 2021 container
# This will first spin up default CommandBox image (which uses Ubuntu and OpenJDK)
# The server will be configured and then this information
# will be copied to another image which uses Debian / Adobe JDK
#
# ===================================================
# initial build - CommandBox / Adobe CF2021
# ===================================================
FROM ortussolutions/commandbox:adobe2021 as workbench

# set environment for initial commandbox spinup
ENV APP_DIR /app
ENV BIN_DIR /usr/local/bin
ENV BOX_SERVER_PROFILE development

# install required packages with ColdFusion Package Manager (CFPM)
ENV CFPM_INSTALL adminapi,administrator,mail

# configure server with cfconfig
COPY myconfig.json ${APP_DIR}

# Generate the startup script only
ENV FINALIZE_STARTUP true
RUN ${BUILD_DIR}/run.sh





# ===================================================
# final build - Debian based image for final build
# ===================================================
FROM adoptopenjdk/openjdk11:debianslim-jre as app

# Restore working directory environment
ENV APP_DIR /app

# Directory Mappings
# box binary lives in BIN_DIR/box
# CommandBox folder lives in LIB_DIR/CommandBox
ENV BIN_DIR /usr/local/bin
ENV LIB_DIR /usr/local/lib
ENV BUILD_DIR ${LIB_DIR}/build

# Copy App
COPY --from=workbench ${APP_DIR} ${APP_DIR}

# Copy CommandBox Binaries
COPY --from=workbench ${BIN_DIR} ${BIN_DIR}

# Copy CommandBox Root + Web Server + Build Scripts
COPY --from=workbench ${LIB_DIR} ${LIB_DIR}


# Install TestBox
# RUN $BIN_DIR/box install testbox

# configure server using cfconfig
RUN ${BIN_DIR}/box cfconfig import from=${APP_DIR}/myconfig.json toFormat=adobe@2021


WORKDIR ${APP_DIR}
CMD ${BIN_DIR}/startup-final.sh


