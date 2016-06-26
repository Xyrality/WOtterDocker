FROM httpd:2.4

# based on the work in https://github.com/alextu/wodocker

COPY wonder-adaptor.tar.gz /tmp/wonder-master.tar.gz
COPY JavaMonitor.tar.gz /tmp/JavaMonitor.tar.gz
COPY wotaskd.tar.gz /tmp/wotaskd.tar.gz

ENV buildDeps gcc make libc6-dev libpcre++-dev apache2-dev

RUN  set -x \
  && apt-get update \
  && apt-get install --yes --no-install-recommends curl unzip $buildDeps \
  && rm -r /var/lib/apt/lists/*

RUN cd /tmp \
  && tar xfz wonder-master.tar.gz \
  && cd /tmp/wonder-master/Utilities/Adaptors \
  && sed -ri 's/ADAPTOR_OS = MACOS/ADAPTOR_OS = LINUX/g' make.config \
  && sed -ri 's/ADAPTORS = CGI Apache2.2/ADAPTORS = Apache2.4/g' make.config \
  && make \
  && cd /tmp/wonder-master/Utilities/Adaptors/Apache2.4 \
  && mv mod_WebObjects.so /usr/local/apache2/modules/. \
  && mkdir /usr/local/apache2/htdocs/WebObjects \
  && sed -ri 's#WebObjectsAlias /cgi-bin/WebObjects#WebObjectsAlias /WOTesting/WebObjects#g' apache.conf \
  && sed -ri 's#WebObjectsDocumentRoot LOCAL_LIBRARY_DIR/WebServer/Documents#WebObjectsDocumentRoot /usr/local/apache2/htdocs/WebObjects#g' apache.conf \
  && echo "<Location /WOTesting/WebObjects> \n\
    Require all granted \n \
</Location>\n \
<Location /WebObjects>\n \
    Require all granted\n \
</Location>" >> apache.conf \
  && mv apache.conf /usr/local/apache2/conf/webobjects.conf \
  && echo "Include /usr/local/apache2/conf/webobjects.conf" >> /usr/local/apache2/conf/httpd.conf \
  && rm /tmp/wonder-master.tar.gz && rm -Rf /tmp/wonder-master \
  && apt-get purge -y --auto-remove $buildDeps

# Installation of java
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 91
ENV JAVA_PACKAGE       jdk

RUN \
    echo "===> add webupd8 repository..."  && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886  && \
    apt-get update
RUN echo "===> install Java"  && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default
RUN echo "===> clean up..."  && \
    rm -rf /var/cache/oracle-jdk8-installer  && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*

# Installation of wotaskd and javamonitor
ENV NEXT_ROOT /opt
RUN  mkdir -p /woapps \
  && cd /woapps \
  && tar xzf /tmp/JavaMonitor.tar.gz && rm /tmp/JavaMonitor.tar.gz  \
  && tar xzf /tmp/wotaskd.tar.gz && rm /tmp/wotaskd.tar.gz  \
  && mkdir /var/log/webobjects

COPY launchwo.sh /woapps/launchwo.sh
RUN chmod +x /woapps/launchwo.sh

COPY apps/WOtter.woa /woapps/WOtter.woa

# Config
VOLUME ["/var/log/webobjects", "/opt/Local/Library/WebObjects/Configuration", "/woapps", "/usr/local/apache2/htdocs/WebObjects"]

EXPOSE 80 1085 56789

COPY SiteConfig.xml /opt/Local/Library/WebObjects/Configuration/SiteConfig.xml

CMD ["/woapps/launchwo.sh"]
