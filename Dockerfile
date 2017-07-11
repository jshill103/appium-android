FROM ubuntu:14.04

ENV ROOTPASSWORD android

EXPOSE 22 5037 5554 5555 5900 4723

ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections \
&& echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections \
&& apt-get update \
&& apt-get install -y wget \
lib32z1 \
lib32ncurses5 \
lib32bz2-1.0 \
g++-multilib \
python-software-properties \
bzip2 \
ssh \
net-tools \
openssh-server \
socat \
build-essential \
gettext \
mono-complete \
xorg \
xvfb \
xfonts-100dpi \
xfonts-75dpi \
xfonts-scalable \
xfonts-cyrillic \
&& apt-get clean \
&& apt-get -y install software-properties-common \
&& add-apt-repository ppa:webupd8team/java \
&& apt-get update \
&& apt-get -y install oracle-java8-installer \
&& apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

RUN wget http://dl.google.com/android/android-sdk_r23-linux.tgz \
&& tar -xvzf android-sdk_r23-linux.tgz -C /usr/local/ \
&& rm android-sdk_r23-linux.tgz \
&& wget "https://www.dropbox.com/s/rppl8pqwus6ou0i/nexus9.tar.gz?dl=1" \
&& tar -zxvf "nexus9.tar.gz?dl=1"

ENV ANDROID_HOME=/usr/local/android-sdk-linux 
ENV PATH=$PATH:$ANDROID_HOME/tools 
ENV PATH=$PATH:$ANDROID_HOME/platform-tools 

RUN chown -R root:root /usr/local/android-sdk-linux/ \
&& ( while [ 1 ]; do sleep 5; echo y; done ) | android update sdk --all --filter platform-tool --no-ui --force \
&& ( while [ 1 ]; do sleep 5; echo y; done ) | android update sdk --filter android-23 --no-ui --force \
&& ( while [ 1 ]; do sleep 5; echo y; done ) | android update sdk --filter build-tools-23.0.1 --no-ui -a \
&& ( while [ 1 ]; do sleep 5; echo y; done ) | android update sdk --filter sys-img-x86-android-23 --no-ui -a \
&& ( while [ 1 ]; do sleep 5; echo y; done ) | android update sdk --filter sys-img-x86-google_apis-23 --no-ui -a \
&& ( while [ 1 ]; do sleep 5; echo y; done ) | android update adb \
&& mkdir /usr/local/android-sdk-linux/tools/keymaps \
&& touch /usr/local/android-sdk-linux/tools/keymaps/en-us \
&& mksdcard -l qasdcard 20M qasdcard.img \
&& mkdir /var/run/sshd \
&& echo "root:$ROOTPASSWORD" | chpasswd \
&& sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
&& sed 's@session\srequired\spam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
&& mv nexus9/Nexus9* ~/.android/avd \
&& echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list \
&& apt-get update \
&& apt-get install -y x11vnc xvfb firefox \
&& mkdir ~/.vnc \
&& x11vnc -storepasswd 1234 ~/.vnc/passwd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

ADD launch-emulator.sh /launch-emulator.sh
ADD runTests.sh /runTests.sh
RUN chmod +x /launch-emulator.sh \
&& chmod +x /runTests.sh
ENTRYPOINT ["/launch-emulator.sh"]