FROM xwj0805/jenkins-jnlp-slave-base:latest
MAINTAINER johnxu-cn@hotmail.com

## Adjust the time_zone
RUN apk add -U tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apk del tzdata
   
## install nodejs
ARG NODEJS_VERSION=v10.13.0

RUN wget -P /root  https://npm.taobao.org/mirrors/node/${NODEJS_VERSION}/node-${NODEJS_VERSION}-linux-x64.tar.gz \
    && tar zxvf /root/node-${NODEJS_VERSION}-linux-x64.tar.gz  -C /root \
    && rm -f /root/node-${NODEJS_VERSION}-linux-x64.tar.gz \
    && apk del curl wget tar

ENV NODEJS_HOME=/root/node-${NODEJS_VERSION}-linux-x64
ENV PATH=${NODEJS_HOME}/bin:${PATH}:$NODEJS_HOME/bin:$PATH
