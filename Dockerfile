ARG ARCH=x86_64
ARG DOCKERSRC=alpine-glibc
ARG USERNAME=fr3akyphantom
#
FROM woahbase/alpine-glibc:x86_64
#
LABEL maintainer="fr3akyphantom <rokibhasansagar2014@outlook.com>"
LABEL Description="This image is used to start the Android API-27 Development Works Only under Circle CI"
#
ARG PUID=3434
ARG PGID=3434
ENV LANG=C.UTF-8
#
ARG SDK_TOOLS_VERSION="4333796"
ARG GRADLE_VERSION="4.7"
ARG NPM_VERSION="latest"
#
ARG SDK_TARGET="27"
ARG SDK_API_VERSION="27.0.3"
#
RUN addgroup -g ${PGID} -S circleci && \
    adduser -u ${PUID} -G circleci -h /home/circleci -D circleci
RUN set -xe \
    && apk add -uU --no-cache --perge -uU \
        bash alpine-sdk sudo \
        curl ca-certificates openjdk8 \
        openssl git make libc-dev gcc libstdc++ \
        nodejs nodejs-npm \
        unzip tar wput \
    && mkdir -p \
        ${ANDROID_HOME} \
        ${GRADLE_HOME} \
    && curl -o /tmp/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip \
        -jkSL https://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip \
    && unzip -q -d ${ANDROID_HOME} \
        /tmp/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip \
    && npm install -g \
        npm@${NPM_VERSION} \
    && rm -rf /var/cache/apk/* /tmp/* /root/.npm /root/.node-gyp

ENV \
    JAVA_OPTS=" -Djava.net.useSystemProxies=true -Dhttp.noProxyHosts=${no_proxy} " \
    JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk \
    ANDROID_HOME=/opt/android/sdk \
    GRADLE_HOME=/opt/gradle-$GRADLE_VERSION
#
ENV \
    PATH=$PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${GRADLE_HOME}/bin
#
USER circleci
#
RUN set -xe \
    && mkdir -p ~/.android ~/.gradle \
    && touch ~/.android/repositories.cfg \
    && echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties
RUN yes | sdkmanager --licenses 1>/dev/null && yes | sdkmanager --update \
    && sdkmanager \
        "platforms;android-${SDK_TARGET}" \
        "build-tools;${SDK_API_VERSION}" \
        "platform-tools" \
        "tools" 1>/dev/null
#
VOLUME /home/circleci/
WORKDIR /home/circleci/project/
#
EXPOSE 5037 8100
#
ENTRYPOINT ["/bin/bash"]
