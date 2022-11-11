# FROM beevelop/android-nodejs
# FROM mingc/android-build-box:latest
FROM ubuntu:16.04

ENV CORDOVA_VERSION 11.0.0

WORKDIR "/tmp"

RUN apt update && apt install -y curl git openjdk-8-jdk ant gradle software-properties-common nodejs npm && \
    java -version && \
    apt update && \
    apt-add-repository ppa:maarten-fonville/android-studio && \
    apt update && \
    apt install -y android-studio && \
    npm i -g coffeescript && \
    npm i -g --unsafe-perm cordova@${CORDOVA_VERSION} && \
    cordova -v
    # cd /tmp && \
    # cordova create myApp com.myCompany.myApp myApp && \
    # cd myApp && \
    # cordova plugin add cordova-plugin-camera --save && \
    # cordova platform add android --save && \
    # cordova requirements android && \
    # cordova build android --verbose && \
    # rm -rf /tmp/myApp
