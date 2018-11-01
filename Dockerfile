FROM jenkinsci/slave:alpine
MAINTAINER johnxu-cn@hotmail.com

USER root:root
RUN apk add --no-cache curl tar bash

## Install JDK1.8
RUN mkdir /usr/local/jdk \
    &&  wget --no-check-certificate   --header "Cookie: oraclelicense=accept-securebackup-cookie"  -P /usr/local/jdk http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.tar.gz \
    && tar zxvf /usr/local/jdk/jdk-8u181-linux-x64.tar.gz \
    && rm -f /usr/local/jdk/jdk-8u181-linux-x64.tar.gz

ENV JAVA_HOME=/usr/local/jdk1.8.0_181
ENV  CLASSPATH=$JAVA_HOME/bin
ENV  PATH="$JAVA_HOME/bin:$PATH"

## Install Maven 
ARG MAVEN_VERSION=3.5.4
ARG USER_HOME_DIR="/root"
ARG SHA=2a803f578f341e164f6753e410413d16ab60fabe31dc491d1fe35c984a5cce696bc71f57757d4538fe7738be04065a216f3ebad4ef7e0ce1bb4c51bc36d6be86
ARG BASE_URL=http://mirrors.hust.edu.cn/apache/maven/maven-3/${MAVEN_VERSION}/binaries

RUN  sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
  && apk --no-cache add ca-certificates wget \
  && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
  && wget  https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk \
  && apk add glibc-2.28-r0.apk \
  && apk update \
  && apk add docker \
  && apk add libltdl \
  && apk add openrc --no-cache \
  && rc-update add docker boot \
  && mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \
  && apk --update add git openssh \
  && rm -rf /var/lib/apt/lists/* \
  && rm /var/cache/apk/* \
  && mkdir /src /target 

ENV  MAVEN_HOME=/usr/share/maven 
ENV  MAVEN_CONFIG="$USER_HOME_DIR/.m2"

# install kubectl & jenkins-slave
####################################

ADD bin/kubectl /usr/local/bin/kubectl 
ADD bin/jenkins-slave /usr/local/bin/jenkins-slave 

RUN wget --no-check-certificate  -P /root https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-4.0.tgz \
    && wget -P /root http://mirrors.shu.edu.cn/apache//ant/binaries/apache-ant-1.10.5-bin.tar.gz \
    && tar zxvf /root/apache-jmeter-4.0.tgz -C /root \
    && tar zxvf /root/apache-ant-1.10.5-bin.tar.gz -C /root \
    && cp /root/apache-jmeter-4.0/extras/ant-jmeter-1.1.1.jar  /root/apache-ant-1.10.5/lib/ant-jmeter-1.1.1.jar \
    && rm -f /root/apache-jmeter-4.0.tgz /root/apache-ant-1.10.5-bin.tar.gz 

ENV JMETER_HOME=/root/apache-jmeter-4.0
ENV ANT_HOME=/root/apache-ant-1.10.5
ENV PATH=${JAVA_HOME}/bin:${PATH}:$ANT_HOME/bin:$PATH
ENV PATH=${JAVA_HOME}/bin:${PATH}:$JMETER_HOME/bin:$PATH
ENV CLASSPATH=$JMETER_HOME/lib/ext/ApacheJMeter_core.jar:$JMETER_HOME/lib/jorphan.jar:$JMETER_HOME/lib/logkit-2.0.jar:$CLASSPATH
ENV CLASSPATH=.:${JAVA_HOME}/lib:/root/apache-ant-1.10.5/lib/ant-launcher.jar

## install nodejs
ARG NODEJS_VERSION=v10.13.0

RUN wget -P /root  https://npm.taobao.org/mirrors/node/${NODEJS_VERSION}/node-${NODEJS_VERSION}-linux-x64.tar.gz \
    && tar zxvf /root/node-${NODEJS_VERSION}-linux-x64.tar.gz  -C /root \
    && rm -f /root/node-${NODEJS_VERSION}-linux-x64.tar.gz \
    && apk del curl wget tar

ENV NODEJS_HOME=/root/node-${NODEJS_VERSION}-linux-x64
ENV PATH=${NODEJS_HOME}/bin:${PATH}:$NODEJS_HOME/bin:$PATH
