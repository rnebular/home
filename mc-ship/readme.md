# Stuff for the mc-ship instance
This instance is simply an Amazon Linux EC2 instance, that runs docker containers for Minecraft.

- The instance has an elastic IP, bound to a DNS name in Route53: `mc.8dot3.net`

## User Data
```
#!/bin/bash
yum update -y
yum install -y docker
mkdir /dockervols
aws s3 cp --recursive s3://rnebular-shared/minecraft/dockervolumes /dockervols
aws s3 cp s3://rnebular-shared/minecraft/dockerbackup /etc/cron.d/*
service docker start
docker run -d -p 25568:25565 -v /dockervols/SurvivalBigVillage:/data --name SurvivalBigVillage itzg/minecraft-server
docker run -d -p 25569:25565 -v /dockervols/AdventureRNebular:/data --name AdventureRNebular itzg/minecraft-server
docker run -d -p 25570:25565 -v /dockervols/Hardcore:/data --name Hardcore itzg/minecraft-server
```

## dockervols
These are scripted on the running instance in two bash scripts;
 `backup-dockervols.sh` and `restore-dockervols.sh`
(These are located at the root `/` folder)

copy from s3 to instance:
aws s3 cp --recursive s3://rnebular-shared/minecraft/dockervolumes /dockervols

copy from instance to s3:
aws s3 cp --recursive /dockervols s3://rnebular-shared/minecraft/dockervolumes

## Docker executable information
- 8BIT:
`docker run -dit -e VERSION=1.12.2 --restart always -p 25565:25565 -v /dockervols/8BIT:/data --name 8BIT itzg/minecraft-server:latest`

- SurvivalBigVillage:
`docker run -dit --restart always -p 25568:25565 -v /dockervols/SurvivalBigVillage:/data --name SurvivalBigVillage itzg/minecraft-server:latest`
