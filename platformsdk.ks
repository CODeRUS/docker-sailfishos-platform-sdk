user --name nemo --groups audio,input,video --password nemo
timezone --utc UTC
lang en_US.UTF-8
keyboard us

part / --fstype=ext4 --ondisk=sda --size=8192 --label=system

repo --name=adaptation0-jolla-@RELEASE@-@ARCH@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/jolla-hw/adaptation-jolla-x86-emul/@ARCH@/
repo --name=hotfixes-@RELEASE@-@ARCH@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/hotfixes/@ARCH@/
repo --name=jolla-@RELEASE@-@ARCH@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/jolla/@ARCH@/
repo --name=sdk-@RELEASE@-@ARCH@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/sdk/@ARCH@/

%packages
@Jolla Configuration Platform SDK Chroot
ssu-vendor-data-jolla
%end

%pre
touch $INSTALL_ROOT/.bootstrap
%end

%post
echo -n "@ARCH@-meego-linux" > /etc/rpm/platform
echo "arch = @ARCH@" >> /etc/zypp/zypp.conf
rm -f /var/lib/rpm/__db*
rpm --rebuilddb
rm -f /.bootstrap

export LANG=en_US.UTF-8
export LC_COLLATE=en_US.UTF-8
export GSETTINGS_BACKEND=gconf

UID_MIN=$(grep "^UID_MIN" /etc/login.defs |  tr -s " " | cut -d " " -f2)
DEVICEUSER=`getent passwd $UID_MIN | sed 's/:.*//'`

if [ -x /usr/bin/oneshot ]; then
   su -c "/usr/bin/oneshot --mic"
   su -c "/usr/bin/oneshot --mic" $DEVICEUSER
fi

ssu domain sailfish
ssu re @RELEASE@
ssu ur

chmod +w /etc/sudoers
echo "ALL ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
chmod -w /etc/sudoers

%end

%post --nochroot
if [ -n "$IMG_NAME" ]; then
    echo "BUILD: $IMG_NAME" >> $INSTALL_ROOT/etc/meego-release
fi
%end
