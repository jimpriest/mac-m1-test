FROM ortussolutions/commandbox:adobe2021 as workbench

# set environment for initial commandbox spinup
ENV BOX_SERVER_PROFILE development
ENV CFPM_INSTALL adminapi,administrator,mail,chart,image,pdf
ENV cfconfig_adminPassword password

# Generate the startup script only
ENV FINALIZE_STARTUP true
RUN $BUILD_DIR/run.sh

# For most apps, this should work to run your applications
FROM adoptopenjdk/openjdk11:debianslim-jre as app

# COPY our generated files
COPY --from=workbench /app /app
COPY --from=workbench /usr/local/lib/serverHome /usr/local/lib/serverHome

RUN mkdir -p /usr/local/lib/CommandBox/lib

COPY --from=workbench /usr/local/lib/CommandBox/lib/runwar-4.8.5.jar /usr/local/lib/CommandBox/lib/runwar-4.8.5.jar
COPY --from=workbench /usr/local/bin/startup-final.sh /usr/local/bin/run.sh

# Restore working directory environment
ENV APP_DIR /app

WORKDIR $APP_DIR

CMD /usr/local/bin/run.sh


