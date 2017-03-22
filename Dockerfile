FROM affmobapp/u14:prod
ADD . /u14javAndroid

RUN sudo apt-get clean
RUN sudo mv /var/lib/apt/lists /tmp
RUN sudo mkdir -p /var/lib/apt/lists/partial
RUN sudo apt-get clean
RUN sudo apt-get update

RUN echo "================ Installing gradle ================="
RUN sudo wget https://services.gradle.org/distributions/gradle-2.3-all.zip
RUN unzip -qq gradle-2.3-all.zip -d /usr/local && rm -f gradle-2.3-all.zip
RUN ln -fs /usr/local/gradle-2.3/bin/gradle /usr/bin
RUN echo 'export PATH=$PATH:/usr/local/gradle-2.3/bin' >> $HOME/.bashrc

RUN echo "================ Installing oracle-java8-installer ================="
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update
RUN apt-get install -y oracle-java8-installer
RUN update-alternatives --set java /usr/lib/jvm/java-8-oracle/jre/bin/java
RUN update-alternatives --set javac /usr/lib/jvm/java-8-oracle/bin/javac
RUN update-alternatives --set javaws /usr/lib/jvm/java-8-oracle/jre/bin/javaws
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> $HOME/.bashrc
RUN echo 'export PATH=$PATH:/usr/lib/jvm/java-8-oracle/jre/bin' >> $HOME/.bashrc


ENV ANDROID_HOME /opt/android-sdk-linux


# ------------------------------------------------------
# --- Install required tools

RUN apt-get update -qq

# Base (non android specific) tools
# -> should be added to bitriseio/docker-bitrise-base

# Dependencies to execute Android builds
RUN dpkg --add-architecture i386
RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386


# ------------------------------------------------------
# --- Download Android SDK tools into $ANDROID_HOME

RUN cd /opt && wget -q https://dl.google.com/android/repository/tools_r25.2.5-linux.zip -O android-sdk-tools.zip
RUN cd /opt && unzip -q android-sdk-tools.zip
RUN mkdir -p ${ANDROID_HOME}
RUN cd /opt && mv tools/ ${ANDROID_HOME}/tools/
RUN cd /opt && rm -f android-sdk-tools.zip

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
#  sdkmanager --list

# Accept "android-sdk-license" before installing components, no need to echo y for each component
# License is valid for all the standard components in versions installed from this file
# Non-standard components: MIPS system images, preview versions, GDK (Google Glass) and Android Google TV require separate licenses, not accepted there
RUN mkdir -p ${ANDROID_HOME}/licenses
RUN echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > ${ANDROID_HOME}/licenses/android-sdk-license

# Platform tools
RUN sdkmanager "platform-tools"

# SDKs
# Please keep these in descending order!
RUN sdkmanager "platforms;android-25"
RUN sdkmanager "platforms;android-24"
RUN sdkmanager "platforms;android-23"
RUN sdkmanager "platforms;android-22"
RUN sdkmanager "platforms;android-21"
RUN sdkmanager "platforms;android-20"
RUN sdkmanager "platforms;android-19"
RUN sdkmanager "platforms;android-17"
RUN sdkmanager "platforms;android-15"
RUN sdkmanager "platforms;android-10"

# build tools
# Please keep these in descending order!
RUN sdkmanager "build-tools;25.0.2"
RUN sdkmanager "build-tools;24.0.3"
RUN sdkmanager "build-tools;23.0.3"
RUN sdkmanager "build-tools;22.0.1"
RUN sdkmanager "build-tools;21.1.2"
RUN sdkmanager "build-tools;20.0.0"
RUN sdkmanager "build-tools;19.1.0"
RUN sdkmanager "build-tools;17.0.0"

# Android System Images, for emulators
# Please keep these in descending order!
RUN sdkmanager "system-images;android-25;google_apis;armeabi-v7a"
RUN sdkmanager "system-images;android-24;default;armeabi-v7a"
RUN sdkmanager "system-images;android-22;default;armeabi-v7a"
RUN sdkmanager "system-images;android-21;default;armeabi-v7a"
RUN sdkmanager "system-images;android-19;default;armeabi-v7a"
RUN sdkmanager "system-images;android-17;default;armeabi-v7a"
RUN sdkmanager "system-images;android-15;default;armeabi-v7a"

# Extras
RUN sdkmanager "extras;android;m2repository"
RUN sdkmanager "extras;google;m2repository"
RUN sdkmanager "extras;google;google_play_services"

# Constraint Layout
# Please keep these in descending order!
RUN sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
RUN sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1"

# google apis
# Please keep these in descending order!
RUN sdkmanager "add-ons;addon-google_apis-google-23"
RUN sdkmanager "add-ons;addon-google_apis-google-22"
RUN sdkmanager "add-ons;addon-google_apis-google-21"

# ------------------------------------------------------
# --- Install Gradle from PPA

# Gradle PPA
RUN apt-get update
RUN apt-get -y install gradle
RUN gradle -v

# ------------------------------------------------------
# --- Install Maven 3 from PPA

RUN apt-get purge maven maven2
RUN apt-get update
RUN apt-get -y install maven
RUN mvn --version


# ------------------------------------------------------
# --- Pre-install Ionic and Cordova CLIs

RUN npm install -g ionic cordova


# ------------------------------------------------------
# --- Install additional packages

# Required for Android ARM Emulator
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libqt5widgets5
ENV QT_QPA_PLATFORM offscreen
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${ANDROID_HOME}/tools/lib64


# ------------------------------------------------------
# --- Cleanup and rev num

# Cleaning
RUN apt-get clean
