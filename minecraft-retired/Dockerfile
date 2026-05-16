FROM centos:centos7
MAINTAINER "Jon Byrum, jtbyrum@gmail.com"

ENV MINECRAFT_VER=1.11.2

RUN \
  yum install -y java-1.6.0-openjdk && \
  yum update -y && \

  mkdir minecraft && \
  cd minecraft && \
  wget -O minecraft_server.jar https://s3.amazonaws.com/Minecraft.Download/versions/${MINECRAFT_VER}/minecraft_server.${MINECRAFT_VER}.jar && \
  chmod +x minecraft_server.jar && \
  echo "eula=true" > eula.txt && \

  firewall-cmd --zone=public --permanent --add-port=25565/tcp && \
  firewall-cmd --reload && \

EXPOSE 25565:25565

ENTRYPOINT ["java -Xmx1024M -Xms1024M -jar minecraft_server.jar nogui"]
