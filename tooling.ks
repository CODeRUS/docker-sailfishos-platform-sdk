timezone --utc UTC

### Commands from /tmp/sandbox/usr/share/ssu/kickstart/part/default
part / --size 500 --ondisk sda --fstype=ext4

## No suitable configuration found in /tmp/sandbox/usr/share/ssu/kickstart/bootloader

repo --name=adaptation0-jolla-@RELEASE@-@ARCH@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/jolla-hw/adaptation-jolla-x86-emul/@ARCH@/
repo --name=hotfixes-@RELEASE@-@ARCH@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/hotfixes/@ARCH@/
repo --name=jolla-@RELEASE@-@ARCH@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/jolla/@ARCH@/
repo --name=sdk-@RELEASE@-@ARCH@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/sdk/@ARCH@/

%packages
patterns-sailfish-device-configuration-Sailfish-SDK-Tooling
%end

%attachment
## No suitable configuration found in /tmp/sandbox/usr/share/ssu/kickstart/attachment
%end

%pre
export SSU_RELEASE_TYPE=release
touch $INSTALL_ROOT/.bootstrap
%end

%post
export SSU_RELEASE_TYPE=release
### begin 01_arch-hack
if [ "@ARCH@" == armv7hl ] || [ "@ARCH@" == armv7tnhl ] || [ "@ARCH@" == aarch64 ]; then
    # Without this line the rpm does not get the architecture right.
    echo -n "@ARCH@-meego-linux" > /etc/rpm/platform

    # Also libzypp has problems in autodetecting the architecture so we force tha as well.
    # https://bugs.meego.com/show_bug.cgi?id=11484
    echo "arch = @ARCH@" >> /etc/zypp/zypp.conf
fi
### end 01_arch-hack
### begin 01_rpm-rebuilddb
# Rebuild db using target's rpm
echo -n "Rebuilding db using target rpm.."
rm -f /var/lib/rpm/__db*
rpm --rebuilddb
echo "done"
### end 01_rpm-rebuilddb
### begin 50_oneshot
# exit boostrap mode
rm -f /.bootstrap

# export some important variables until there's a better solution
export LANG=en_US.UTF-8
export LC_COLLATE=en_US.UTF-8
export GSETTINGS_BACKEND=gconf

# run the oneshot triggers for root and first user uid
UID_MIN=$(grep "^UID_MIN" /etc/login.defs |  tr -s " " | cut -d " " -f2)
DEVICEUSER=`getent passwd $UID_MIN | sed 's/:.*//'`

if [ -x /usr/bin/oneshot ]; then
   /usr/bin/oneshot --mic
   su -c "/usr/bin/oneshot --mic" $DEVICEUSER
fi
### end 50_oneshot
### begin 60_ssu
[ -n "@RELEASE@" ] && ssu release @RELEASE@
ssu mode 4
### end 60_ssu
### begin 90_accept_unsigned_packages
sed -i /etc/zypp/zypp.conf \
    -e '/^# pkg_gpgcheck =/ c \
# Modified by kickstart. See sdk-configs sources\
pkg_gpgcheck = off
'
### end 90_accept_unsigned_packages
### begin 90_zypper_skip_check_access_deleted
sed -i /etc/zypp/zypper.conf \
    -e '/^# *psCheckAccessDeleted =/ c \
# Modified by kickstart. See sdk-configs sources\
psCheckAccessDeleted = no
'
### end 90_zypper_skip_check_access_deleted
%end

%post --nochroot
export SSU_RELEASE_TYPE=release
### begin 50_os-release
(
CUSTOMERS=$(find $INSTALL_ROOT/usr/share/ssu/features.d -name 'customer-*.ini' \
    |xargs --no-run-if-empty sed -n 's/^name[[:space:]]*=[[:space:]]*//p')

cat $INSTALL_ROOT/etc/os-release
echo "SAILFISH_CUSTOMER=\"${CUSTOMERS//$'\n'/ }\""
) > $IMG_OUT_DIR/os-release

cp -f /share/mer-tooling-chroot $INSTALL_ROOT/
%end
