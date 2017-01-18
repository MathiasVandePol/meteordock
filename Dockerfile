FROM debian:jessie
MAINTAINER Mathias Van de Pol

RUN groupadd -r node && useradd -m -g node node

ENV NODE_VERSION 4.7.0
ENV GOSU_VERSION 1.10

# install MongoDB
ENV INSTALL_MONGO false
ENV MONGO_VERSION 3.4.0
ENV MONGO_MAJOR 3.4
ENV MONGO_PACKAGE mongodb-org

# default values for Meteor environment variables
ENV ROOT_URL http://localhost
ENV MONGO_URL mongodb://127.0.0.1:27017/meteor
ENV PORT 3000

# Optionally Install PhantomJS
ENV INSTALL_PHANTOMJS false
ENV PHANTOM_VERSION 2.1.1

# Optionally Install Graphicsmagick
ENV INSTALL_GRAPHICSMAGICK false

# build directories
ENV APP_SOURCE_DIR /opt/meteor/src
ENV APP_BUNDLE_DIR /opt/meteor/dist
ENV BUILD_SCRIPTS_DIR /opt/build_scripts

# add entrypoint and build scripts
COPY .docker $BUILD_SCRIPTS_DIR
RUN chmod -R 770 $BUILD_SCRIPTS_DIR

# copy the app to the container
COPY . $APP_SOURCE_DIR

# install base dependencies, build app, cleanup
RUN cd $BUILD_SCRIPTS_DIR && \
		bash $BUILD_SCRIPTS_DIR/install-deps.sh && \
		bash $BUILD_SCRIPTS_DIR/install-node.sh && \
		bash $BUILD_SCRIPTS_DIR/post-install-cleanup.sh

# install Meteor, build app, clean up
RUN cd $APP_SOURCE_DIR && \
            bash $BUILD_SCRIPTS_DIR/install-meteor.sh && \
            bash $BUILD_SCRIPTS_DIR/build-meteor.sh && \
            bash $BUILD_SCRIPTS_DIR/post-build-cleanup.sh

# fix tunnel-ssh npm missing module
RUN cp -R $APP_BUNDLE_DIR/bundle/programs/server/npm/node_modules/tunnel-ssh $APP_BUNDLE_DIR/bundle/programs/server/npm/node_modules/meteor/modules-runtime/node_modules/

EXPOSE 3000

WORKDIR $APP_BUNDLE_DIR/bundle

# start the app
ENTRYPOINT ["./entrypoint.sh"]
CMD ["node", "main.js"]
