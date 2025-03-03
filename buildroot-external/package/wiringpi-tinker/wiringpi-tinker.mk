################################################################################
#
# wiringpi for ASUS Tinkerboard (https://github.com/TinkerBoard/gpio_lib_c)
#
################################################################################

WIRINGPI_TINKER_VERSION = 57d4c4be7157414bed397a5cf655299bb74b2535
WIRINGPI_TINKER_SITE = $(call github,TinkerBoard,gpio_lib_c,$(WIRINGPI_TINKER_VERSION))

WIRINGPI_TINKER_LICENSE = LGPL-3.0+
WIRINGPI_TINKER_LICENSE_FILES = COPYING.LESSER
WIRINGPI_TINKER_INSTALL_STAGING = YES

ifeq ($(BR2_STATIC_LIBS),y)
WIRINGPI_TINKER_LIB_BUILD_TARGETS = static
WIRINGPI_TINKER_LIB_INSTALL_TARGETS = install-static
WIRINGPI_TINKER_BIN_BUILD_TARGETS = gpio-static
else ifeq ($(BR2_SHARED_LIBS),y)
WIRINGPI_TINKER_LIB_BUILD_TARGETS = all
WIRINGPI_TINKER_LIB_INSTALL_TARGETS = install
WIRINGPI_TINKER_BIN_BUILD_TARGETS = all
else
WIRINGPI_TINKER_LIB_BUILD_TARGETS = all static
WIRINGPI_TINKER_LIB_INSTALL_TARGETS = install install-static
WIRINGPI_TINKER_BIN_BUILD_TARGETS = all
endif

define WIRINGPI_TINKER_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/wiringPi DEFS='-D_GNU_SOURCE -DTINKER_BOARD' $(WIRINGPI_TINKER_LIB_BUILD_TARGETS)
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/devLib DEFS='-D_GNU_SOURCE -DTINKER_BOARD' $(WIRINGPI_TINKER_LIB_BUILD_TARGETS)
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/gpio DEFS='-D_GNU_SOURCE -DTINKER_BOARD' $(WIRINGPI_TINKER_BIN_BUILD_TARGETS)
endef

define WIRINGPI_TINKER_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/wiringPi $(WIRINGPI_TINKER_LIB_INSTALL_TARGETS) DESTDIR=$(STAGING_DIR) PREFIX=/usr LDCONFIG=true
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/devLib $(WIRINGPI_TINKER_LIB_INSTALL_TARGETS) DESTDIR=$(STAGING_DIR) PREFIX=/usr LDCONFIG=true
endef

define WIRINGPI_TINKER_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/wiringPi $(WIRINGPI_TINKER_LIB_INSTALL_TARGETS) DESTDIR=$(TARGET_DIR) PREFIX=/usr LDCONFIG=true
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/devLib $(WIRINGPI_TINKER_LIB_INSTALL_TARGETS) DESTDIR=$(TARGET_DIR) PREFIX=/usr LDCONFIG=true
	$(INSTALL) -D -m 0755 $(@D)/gpio/gpio $(TARGET_DIR)/usr/bin/gpio
	$(INSTALL) -D -m 0755 $(@D)/gpio/pintest $(TARGET_DIR)/usr/bin/pintest
endef

$(eval $(generic-package))
