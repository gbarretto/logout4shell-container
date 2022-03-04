FROM ubuntu:18.04

# Install dependencies
RUN apt-get update && apt-get install -y \
 maven \
 python3 \
 git

# Install and run Cybereason Webserver
RUN git clone https://github.com/cybereason/Logout4Shell.git /root/new
WORKDIR /root/new
RUN mvn package
WORKDIR /root/new/target/classes
CMD python3 -m http.server 8888

EXPOSE 8888
