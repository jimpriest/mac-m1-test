# ===================================================
# initial build - CommandBox / Adobe CF2021
# ===================================================
FROM ortussolutions/commandbox:adobe2021 as workbench

# set environment for initial commandbox spinup
ENV APP_DIR /app
# ENV BOX_SERVER_CFCONFIGFILE ${APP_DIR}/myconfig.json
ENV BOX_SERVER_PROFILE development
ENV cfconfig_adminPassword admin
ENV CFPM_INSTALL adminapi,administrator,mail


# Generate the startup script only
ENV FINALIZE_STARTUP true
RUN $BUILD_DIR/run.sh



# ===================================================
# final build - Debian based image for final build
# ===================================================
FROM adoptopenjdk/openjdk11:debianslim-jre as app

# Restore working directory environment
ENV APP_DIR /app

# Directory Mappings
ENV BIN_DIR /usr/local/bin
ENV LIB_DIR /usr/local/lib
ENV BUILD_DIR ${LIB_DIR}/build


# COMMANDBOX_HOME = Where CommmandBox Lives
# not sure we need this?? jp
# ENV COMMANDBOX_HOME=$LIB_DIR/CommandBox

# Copy App
COPY --from=workbench ${APP_DIR} ${APP_DIR}

# Copy CommandBox Binaries
COPY --from=workbench ${BIN_DIR} ${BIN_DIR}

# Copy CommandBox Root + Web Server + Build Scripts
COPY --from=workbench ${LIB_DIR} ${LIB_DIR}




# Install TestBox
RUN $BIN_DIR/box install testbox

WORKDIR $APP_DIR
CMD /usr/local/bin/startup-final.sh


