FROM coderus/sailfishos-platform-sdk-base
MAINTAINER Andrey Kozhevnikov <coderusinbox@gmail.com>

ARG RELEASE

COPY build/tooling-i486.tar /tooling-i486.tar
COPY build/target-i486.tar /target-i486.tar
COPY build/target-armv7hl.tar /target-armv7hl.tar

USER nemo
WORKDIR /home/nemo

RUN set -ex ;\
 sudo mkdir /host_targets ;\
 sudo zypper ref ;\
 sudo zypper -qn in tar ;\
 sdk-assistant -y create SailfishOS-$RELEASE /tooling-i486.tar ;\
 sudo rm -f /tooling-i486.tar ;\
 sdk-assistant -y create SailfishOS-$RELEASE-i486 /target-i486.tar ;\
 sudo rm -f /target-i486.tar ;\
 sdk-assistant -y create SailfishOS-$RELEASE-armv7hl /target-armv7hl.tar ;\
 sudo rm -f /target-armv7hl.tar ;\
 sudo rm -rf /var/cache/zypp/* ;\
 sudo rm -rf /srv/mer/targets/SailfishOS-$RELEASE-armv7hl/var/cache/zypp/* ;\
 sudo rm -rf /srv/mer/targets/SailfishOS-$RELEASE-i486/var/cache/zypp/*