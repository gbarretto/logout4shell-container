# Logout4Shell Container

## Description

Since the disclosure of the Apache Log4j vulnerability affecting versions 2.0 through 2.14.1 in December of 2021, enterprises and small businesses have made it a priority to mitigate this risk. This vulnerability was given the highest possible severity rating of 10 when the CVE-2021-44228 was published on December 9, 2021 which allows remote code execution on vulnerable servers. 

With the guidance from the Apache software foundation, the best mitigation against this vulnerability is to patch log4j to 2.17.0 and above. In response to this 
vulnerability organizations like Cybereason and FullHunt have developed tools to scan for the vulnerability and mitigate this risk without the need to patch 
or restart the server.

Logout4Shell Container is not intended to take any credit for the research and development of these tools, but was developed for ease of deployment

More information regarding these tools can be found on [Cybereason Logout4Shell](https://github.com/Cybereason/Logout4Shell/blob/main/README.md) and 
[FullHunt log4j-scan](https://github.com/fullhunt/log4j-scan/blob/master/README.md)


## How Logout4Shell Container works

The Logout4Shell Container is multi-container application consisting of the Cybereason webserver which hosts the Transient and Persistent payloads and the ldap 
server which enables communication to the webserver through the lookup. Once the Logout4shell container is deployed either locally or externally and inbound 
connections are whitelisted between the Logout4shell container and vulnerable server on ports 1389 and 8888, you can then SSH into the container and execute 
a curl command to the vulnerable server with an appropriate HTTP header. This command initiates the lookup to the ldap server which will then redirect to the 
webserver to deliver the payload.

## POC Test Environment

1.	Vulnerable app deployed via a Docker container on an Amazon Linux 2, t2.micro, EC2 instance. More information regarding this vulnerable app can be found 
on [Log4Shell sample vulnerable application]( https://github.com/christophetd/log4shell-vulnerable-app/blob/main/README.md).
3.	FullHunt log4j scan deployed as a Docker container on an Amazon Linux 2, t2.micro, EC2 instance.
4.	Logout4Shell Container deployed on an Amazon Linux 2, t2.micro, EC2 instance.

## Test Environment Setup

### Logout4Shell Container

1. Launch an EC2 instance with the user data script below. This will run an OS update, install and start the Docker engine, ensure that the Docker daemon starts after each system reboot, and install git.
```
#!/bin/bash
yum update -y
amazon-linux-extras install -y docker
service docker start
system reboot
systemctl enable docker
yum install -y git
```
2. SSH into your instance and run the command below. This will download and install latest version of Docker Compose.
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose![image](https://user-images.githubusercontent.com/100946415/156798022-3e844434-6edb-4c14-aec7-9b7ceb94e456.png)
```
3. Adjust permissions.
```
sudo chmod +x /usr/local/bin/docker-compose
```
4. Clone repository.
```
sudo git clone https://github.com/gbarretto/logout4shell-container.git
```
5. Change directory to logout4shell-container.
```
cd logout4shell-container
```
6. Open var.env in GNU nano to edit.
```
sudo nano var.env
```
7. Replace ```<host_ip>``` with the public IP address of the EC2 instance making sure to keep quotation marks.  
8. Replace ```<mode_type>``` with Transient or Persistent making sure to keep quotation marks. 
9. Press Control + X to bring you to Save modified buffer question. Then press Y. Then press Enter to write changes to var.env file.
10. Build Docker images using command below.
```
sudo docker-compose build
```
11. Launch the containers in detached mode.
```
sudo docker-compose up -d
```
### Vulnerable app
1. Launch an EC2 instance with same the user data script from above. 
2. SSH into your instance and run the command below to run the vulnerable app via Docker.
```
docker run --name vulnerable-app --rm -p 443:8080 ghcr.io/christophetd/log4shell-vulnerable-app
```
### FullHunt log4j scan
1. Launch an EC2 instance with the user data script below. This will run an OS update, install and start the Docker engine, ensure that the Docker daemon starts after each system reboot, and install git.
```
#!/bin/bash
yum update -y
amazon-linux-extras install -y docker
service docker start
system reboot
systemctl enable docker
yum install -y git
```
2. SSH into your instance and run the commands below to run FullHunt log4j scan.
```
git clone https://github.com/fullhunt/log4j-scan.git
cd log4j-scan
sudo docker build -t log4j-scan .
sudo docker run -it --rm log4j-scan
```



