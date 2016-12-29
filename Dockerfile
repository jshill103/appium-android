FROM ubuntu:14.04

ENV ROOTPASSWORD android


EXPOSE 22
EXPOSE 5037
EXPOSE 5554
EXPOSE 5555
EXPOSE 5900
EXPOSE 4723

ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections
RUN apt-get update


RUN apt-get install -y wget \
lib32z1 \
lib32ncurses5 \
lib32bz2-1.0 \
g++-multilib \
python-software-properties \
bzip2 \
ssh \
net-tools \
openssh-server \
socat

RUN apt-get clean
RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:webupd8team/java

RUN apt-get update

RUN apt-get -y install oracle-java7-installer
RUN apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

RUN wget http://dl.google.com/android/android-sdk_r23-linux.tgz
RUN tar -xvzf android-sdk_r23-linux.tgz -C /usr/local/
RUN rm android-sdk_r23-linux.tgz

RUN wget http://archive.apache.org/dist/ant/binaries/apache-ant-1.8.4-bin.tar.gz
RUN tar -xvzf apache-ant-1.8.4-bin.tar.gz -C /usr/local/
RUN rm apache-ant-1.8.4-bin.tar.gz

ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools


ENV ANT_HOME /usr/local/apache-ant-1.8.4
ENV PATH $PATH:$ANT_HOME/bin

RUN chown -R root:root /usr/local/android-sdk-linux/

RUN ( while [ 1 ]; do sleep 5; echo y; done ) | android update sdk --all --filter platform-tool --no-ui --force
RUN ( while [ 1 ]; do sleep 5; echo y; done ) | android update sdk --filter platform --no-ui --force
RUN ( while [ 1 ]; do sleep 5; echo y; done ) | android update sdk --filter build-tools-22.0.1 --no-ui -a
RUN ( while [ 1 ]; do sleep 5; echo y; done ) | android update sdk --filter sys-img-x86-android-19 --no-ui -a
RUN ( while [ 1 ]; do sleep 5; echo y; done ) | android update sdk --filter sys-img-x86-android-21 --no-ui -a
RUN ( while [ 1 ]; do sleep 5; echo y; done ) | android update sdk --filter sys-img-x86-android-22 --no-ui -a

RUN ( while [ 1 ]; do sleep 5; echo y; done ) | android update adb

RUN mkdir /usr/local/android-sdk-linux/tools/keymaps
RUN touch /usr/local/android-sdk-linux/tools/keymaps/en-us

RUN mksdcard -l qasdcard 20M qasdcard.img

RUN mkdir /var/run/sshd
RUN echo "root:$ROOTPASSWORD" | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN sed 's@session\srequired\spam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN wget https://nodejs.org/download/release/v6.2.0/node-v6.2.0-linux-x64.tar.gz
RUN tar -xvzf node-v6.2.0-linux-x64.tar.gz -C /usr/local/
RUN rm node-v6.2.0-linux-x64.tar.gz
ENV NODE_HOME /usr/local/node-v6.2.0-linux-x64
ENV PATH $PATH:$NODE_HOME/bin

RUN mkdir /usr/local/appium
RUN cd /usr/local/appium && npm install -g appium

RUN mkdir /apk

ADD launch-emulator.sh /launch-emulator.sh
ADD nodeconfig.json /nodeconfig.json
RUN chmod +x /launch-emulator.sh
ENTRYPOINT ["/launch-emulator.sh"]