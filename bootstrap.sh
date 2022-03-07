#!/bin/bash
#Update the installed packages and package cache on your instance
yum update -y
#Install the most recent Docker Engine package for Amazon Linux 2
amazon-linux-extras install -y docker
#Start the Docker service
service docker start
#On Amazon Linux 2, to ensure that the Docker daemon starts after each system reboot
systemctl enable docker
#Add the ec2-user to the docker group so you can execute Docker commands without using sudo
sudo usermod -a -G docker ec2-user
#Install git
yum install -y git
