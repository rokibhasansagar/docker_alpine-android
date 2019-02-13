ARG ARCH=x86_64
ARG DOCKERSRC=alpine-glibc
ARG USERNAME=fr3akyphantom
#
FROM woahbase/alpine-glibc:x86_64
#
LABEL maintainer="fr3akyphantom <rokibhasansagar2014@outlook.com>"
LABEL Description="This Alpine image is used to start the Android API-27 Development Works locally"
#
ARG PUID=1000
ARG PGID=1000
ENV LANG=C.UTF-8
#
ARG SDK_TOOLS_VERSION="4333796"
ARG GRADLE_VERSION="4.7"
ARG NPM_VERSION="latest"
#
ARG SDK_TARGET="27"
ARG SDK_API_VERSION="27.0.3"
#
ENV \
    JAVA_OPTS=" -Xmx3200m " \
    JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk \
    ANDROID_HOME=/opt/android/sdk/ \
    GRADLE_HOME=/opt/gradle-$GRADLE_VERSION
#
RUN set -xe \
    && apk add -uU --no-cache --purge -uU \
        bash alpine-sdk sudo shadow \
        curl ca-certificates openjdk8 \
        openssl git make libc-dev gcc libstdc++ \
        nodejs nodejs-npm \
        unzip tar
#
RUN set -xe \
    && groupadd --gid ${PGID} alpine \
    && useradd --uid ${PUID} --gid alpine --shell /bin/bash --create-home alpine \
    && echo 'alpine ALL=NOPASSWD: ALL' >> /etc/shadow
#
RUN set -xe \
    && mkdir -p \
        ${ANDROID_HOME} \
        ${GRADLE_HOME} \
    && curl -o /tmp/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip \
        -jkSL https://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip \
    && unzip -q -d ${ANDROID_HOME} \
        /tmp/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip \
    && chown -Rh alpine:alpine ${ANDROID_HOME} \
    && curl -o /tmp/gradle-${GRADLE_VERSION}-bin.zip \
        -jkSL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    && unzip -q -d /opt \
        /tmp/gradle-${GRADLE_VERSION}-bin.zip \
    && chown -Rh alpine:alpine ${GRADLE_HOME} \
    && npm install -g \
        npm@${NPM_VERSION} \
    && rm -rf /var/cache/apk/* /tmp/* /root/.npm /root/.node-gyp
#
ENV \
    PATH=$PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${GRADLE_HOME}/bin
#
USER alpine
#
RUN set -xe \
    && mkdir -p ~/.android ~/.gradle \
    && touch ~/.android/repositories.cfg \
    && echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties
RUN yes | sdkmanager --licenses 1>/dev/null \
    && sdkmanager --update \
    && sdkmanager \
        "platforms;android-${SDK_TARGET}" \
        "build-tools;${SDK_API_VERSION}" \
        "platform-tools" \
        "tools" 1>/dev/null
#
VOLUME /home/alpine/
WORKDIR /home/alpine/project/
#
ENTRYPOINT ["/bin/bash"]
