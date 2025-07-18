################################################################################
#
# openvmtools
#
################################################################################

OPENVMTOOLS_VERSION_MAJOR = 12.3.0
OPENVMTOOLS_VERSION = $(OPENVMTOOLS_VERSION_MAJOR)-22234872
OPENVMTOOLS_SITE = https://github.com/vmware/open-vm-tools/releases/download/stable-$(OPENVMTOOLS_VERSION_MAJOR)
OPENVMTOOLS_SOURCE = open-vm-tools-$(OPENVMTOOLS_VERSION).tar.gz
OPENVMTOOLS_LICENSE = LGPL-2.1
OPENVMTOOLS_LICENSE_FILES = COPYING
OPENVMTOOLS_CPE_ID_VENDOR = vmware
OPENVMTOOLS_CPE_ID_PRODUCT = tools
OPENVMTOOLS_CPE_ID_VERSION = $(OPENVMTOOLS_VERSION_MAJOR)

# False positives: CVEs are for open-vm-tools predecessor vm-support 0.88
OPENVMTOOLS_IGNORE_CVES = CVE-2014-4199 CVE-2014-4200

# 0014-CVE-2025-22247-1100-1225-VGAuth-updates.patch
OPENVMTOOLS_IGNORE_CVES += CVE-2025-22247

# configure.ac is patched
OPENVMTOOLS_AUTORECONF = YES
OPENVMTOOLS_CONF_OPTS = --with-dnet \
	--without-icu --without-x --without-gtk2 \
	--without-gtkmm --without-kernel-modules \
	--disable-deploypkg --without-xerces \
	--disable-vgauth --disable-containerinfo
OPENVMTOOLS_CONF_ENV += \
	CUSTOM_DNET_CPPFLAGS=" " \
	LIBS=$(TARGET_NLS_LIBS)
OPENVMTOOLS_DEPENDENCIES = \
	host-nfs-utils \
	libglib2 \
	libdnet \
	$(TARGET_NLS_DEPENDENCIES)

ifeq ($(BR2_PACKAGE_LIBTIRPC),y)
OPENVMTOOLS_CONF_OPTS += --with-tirpc
OPENVMTOOLS_DEPENDENCIES += libtirpc
else
OPENVMTOOLS_CONF_OPTS += --without-tirpc
endif

ifeq ($(BR2_PACKAGE_LIBXCRYPT),y)
OPENVMTOOLS_DEPENDENCIES += libxcrypt
endif

# When libfuse is available, openvmtools can build vmblock-fuse, so
# make sure that libfuse gets built first
ifeq ($(BR2_PACKAGE_LIBFUSE3),y)
OPENVMTOOLS_CONF_OPTS += --with-fuse=fuse3
OPENVMTOOLS_DEPENDENCIES += libfuse3
else ifeq ($(BR2_PACKAGE_LIBFUSE),y)
OPENVMTOOLS_CONF_OPTS += --with-fuse=fuse
OPENVMTOOLS_DEPENDENCIES += libfuse
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
OPENVMTOOLS_CONF_OPTS += --with-ssl
OPENVMTOOLS_DEPENDENCIES += openssl
else
OPENVMTOOLS_CONF_OPTS += --without-ssl
endif

ifeq ($(BR2_PACKAGE_OPENVMTOOLS_PAM),y)
OPENVMTOOLS_CONF_OPTS += --with-pam
OPENVMTOOLS_DEPENDENCIES += linux-pam
else
OPENVMTOOLS_CONF_OPTS += --without-pam
endif

ifeq ($(BR2_PACKAGE_OPENVMTOOLS_RESOLUTIONKMS),y)
OPENVMTOOLS_CONF_OPTS += --enable-resolutionkms
OPENVMTOOLS_DEPENDENCIES += libdrm udev
else
OPENVMTOOLS_CONF_OPTS += --disable-resolutionkms
endif

# symlink needed by lib/system/systemLinux.c (or will cry in /var/log/messages)
# defined in lib/misc/hostinfoPosix.c
# /sbin/shutdown needed for Guest OS restart/shutdown from hypervisor
define OPENVMTOOLS_POST_INSTALL_TARGET_THINGIES
	ln -fs os-release $(TARGET_DIR)/etc/lfs-release
	if [ ! -e $(TARGET_DIR)/sbin/shutdown ]; then \
		$(INSTALL) -D -m 755 package/openvmtools/shutdown \
			$(TARGET_DIR)/sbin/shutdown; \
	fi
endef

OPENVMTOOLS_POST_INSTALL_TARGET_HOOKS += OPENVMTOOLS_POST_INSTALL_TARGET_THINGIES

define OPENVMTOOLS_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 755 package/openvmtools/S10vmtoolsd \
		$(TARGET_DIR)/etc/init.d/S10vmtoolsd
endef

define OPENVMTOOLS_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/openvmtools/vmtoolsd.service \
		$(TARGET_DIR)/usr/lib/systemd/system/vmtoolsd.service
endef

$(eval $(autotools-package))
