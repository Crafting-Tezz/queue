# ActiveMQ broker for Fleetman.
# Based on the author's release2 Dockerfile, updated:
#  - eclipse-temurin:17-jre instead of the Amazon Linux 2022 *preview* image
#  - ActiveMQ 5.17.7 instead of 5.17.3 (5.17.3 has the critical RCE CVE-2023-46604)
#  - ADD downloads the archive directly, so no package manager is needed
FROM eclipse-temurin:17-jre

ARG ACTIVEMQ_VERSION=5.17.7

ADD https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz /tmp/activemq.tar.gz

RUN tar -xzf /tmp/activemq.tar.gz -C /opt \
 && mv /opt/apache-activemq-${ACTIVEMQ_VERSION} /opt/activemq \
 && rm /tmp/activemq.tar.gz \
 && sed -i 's/127\.0\.0\.1/0.0.0.0/g' /opt/activemq/conf/jetty.xml

# 8161 = web admin console, 61616 = OpenWire (the port the microservices use)
EXPOSE 8161 61616

CMD ["/opt/activemq/bin/activemq", "console"]
