FROM node:10.13.0-alpine AS  builder 
MAINTAINER johnxu-cn@hotmail.com

## Adjust the time_zone
RUN apk add -U tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apk del tzdata
   
FROM xwj0805/jenkins-jnlp-slave-base:latest

COPY --from=builder  /etc/localtime  /etc/localtime

WORKDIR /root
