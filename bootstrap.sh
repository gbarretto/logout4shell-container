#!/bin/bash
yum update -y
amazon-linux-extras install -y docker
service docker start
system reboot
systemctl enable docker
yum install -y git
