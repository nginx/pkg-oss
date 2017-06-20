#!/usr/bin/env bash
#
# build_module.sh (c) NGINX, Inc. [v0.11 20-Jun-2017] Liam Crilly <liam.crilly@nginx.com>
#
# This script supports apt(8) and yum(8) package managers. Installs the minimum
# necessary prerequisite packages to build 3rd party modules for NGINX Plus.
# Obtains source for module and NGINX OSS, prepares for pkg-oss tool. Inspects
# module configuration and attempts to rewrite for dynamic build if necessary.
# Obtains pkg-oss tool, creates packaging files and copies in module source.
#
# CHANGELOG
# v0.11 [20-Jun-2017] Enforces NGINX versions that support dynamic modules
# v0.10 [27-Apr-2017] Fixed postinstall banner, improved .so filename detection,
#                     -v option for specifying OSS build/version
# v0.9  [10-Apr-2017] @defan patch, improved postinstall banner, added disclaimer
# v0.8  [30-Mar-2017] Package version is now tied to base OSS version instead of 0.01
# v0.7  [29-Mar-2017] Added RPM packaging, flexible command line options with defaults
# v0.6  [16-Feb-2017] Using pkg-oss tool instead of only compiling .so files

cat << __EOF__

DISCLAIMER DISCLAIMER DISCLAIMER DISCLAIMER DISCLAIMER DISCLAIMER DISCLAIMER

 This script is provided as a demonstration of how to use the NGINX pkg-oss
 tooling to compile and package a dynamic module for NGINX and NGINX Plus.
 It will produce an installable package with the correct dependency on the
 NGINX version used for the build so that upgrades will not lead to mismatch
 between NGINX and the module. When using this script please bear in mind:
  - It will not work for every module, check for module prerequisites.
  - The installable packages are not intended for redistribution.
  - Seamless upgrades with dependency matching require a yum/apt repository.

__EOF__

#
# Check command line parameters
#
ME=`basename $0`
if [ $# -eq 0 ]; then
	echo "USAGE: $ME [options] <URL | path to module source>"
	echo ""
	echo " URL may be Github clone or download link, otherwise 'tarball' is assumed."
	echo " Options:"
	echo " -n | --nickname <word>         # Used for packaging, lower case alphanumeric only"
	echo " -s | --skip-depends            # Skip dependecies check/install"
	echo " -f | --force-dynamic           # Attempt to convert static configuration to dynamic module"
	echo " -r <NGINX Plus release number> # Build against the corresponding OSS version for this release"
	echo " -v [NGINX OSS version number]  # Build against this OSS version [current mainline] (default)"
	echo ""
        exit 1
fi

#
# Process command line options
#
CHECK_DEPENDS=1
DO_DYNAMIC_CONVERT=0
MODULE_NAME=""
BUILD_PLATFORM=OSS
while [ $# -gt 1 ]; do
	case "$1" in
		"-s" | "--skip-depends")
			CHECK_DEPENDS=0
			shift
			;;
		"-f" | "--force-dynamic")
			DO_DYNAMIC_CONVERT=1
			shift
			;;
		"-n" | "--nickname" )
			MODULE_NAME=$2
			shift; shift
			;;
		"-r")
			BUILD_PLATFORM=Plus
			if [ `echo -n $2 | tr -d '[0-9p]' | wc -c` -gt 0 ]; then
				echo "$ME: ERROR: NGINX Plus release must be in the format NN[pN] - quitting"
				exit 1
			elif [ "`echo "10^$2" | tr '^' '\n' | sort -nr | head -1`" == "10" ]; then
				echo "$ME: ERROR: NGINX Plus release must be at least 11 to support dynamic modules - quitting"
				exit 1
			fi
			PLUS_REL=$2
			shift; shift
			;;
		"-v")
			BUILD_PLATFORM=OSS
			if [ `echo -n .$2 | tr -d '[0-9\.]' | wc -c` -eq 0 ]; then
				OSS_VER=$2
				shift
			fi
			if [ `echo "1.11.4^$OSS_VER" | tr '^' '\n' | tr '.' ',' | sort -nr | head -1` == "1,11,4" ]; then
				echo "$ME: ERROR: NGINX version must be at least 1.11.5 to support dynamic modules - quitting"
				exit 1
			fi
			shift
			;;
		*)
			echo "$ME: ERROR: Invalid command line option ($1) - quitting"
			exit 1
			;;
	esac
done

#
# Locate/select package manager and configure
#
if [ `whereis yum | grep -c "^yum: /"` -eq 1 ]; then
        PKG_MGR=yum
	NGINX_PACKAGES="pcre-devel zlib-devel openssl-devel"
	DEVEL_PACKAGES="rpm-build"
	PACKAGING_DIR=rpm/SPECS
	PACKAGE_SOURCES_DIR=../SOURCES
	FIND_PKGS_CMD="find ${HOME}/rpmbuild/RPMS/ -maxdepth 2 -type f -name "*.rpm" -print"
	FIND_SO_CMD="find ${HOME}/rpmbuild/BUILD/ -type f -name "*.so" -print"
elif [ `whereis apt-get | grep -c "^apt-get: /"` -eq 1 ]; then
        PKG_MGR=apt-get
	NGINX_PACKAGES="libpcre3-dev zlib1g-dev libssl-dev"
	DEVEL_PACKAGES="devscripts debhelper dpkg-dev quilt lsb-release"
	PACKAGING_DIR=debian
	PACKAGE_SOURCES_DIR=extra
	FIND_PKGS_CMD="find ${HOME}/debuild/ -maxdepth 1 -type f -name "*.deb" -print"
	FIND_SO_CMD="find ${HOME}/debuild/ -maxdepth 9 -type f -name "*.so" -print"
else
        echo "$ME: ERROR: Could not locate a supported package manager - quitting"
        exit 1
fi

if [ $CHECK_DEPENDS = 1 ]; then
	echo "$ME: INFO: testing sudo"
	sudo pwd > /dev/null
	if [ $? -ne 0 ]; then
	        echo "ERROR: sudo failed. If you do not have sudo credentials then try using the '--skip-depends' option. Quitting."
	        exit 1
	fi

	echo "$ME: INFO: checking for dependent packages"
	CORE_PACKAGES="gcc make unzip"
	if [ "$BUILD_PLATFORM" = "OSS" ]; then
		CORE_PACKAGES="$CORE_PACKAGES mercurial"
	fi
	if [ "${1##*.}" == "git" ]; then
		CORE_PACKAGES="$CORE_PACKAGES git"
	fi
	sudo $PKG_MGR install $CORE_PACKAGES $NGINX_PACKAGES $DEVEL_PACKAGES
fi

#
# Ask for a nickname if we did't get one on the command line
#
if [ "$MODULE_NAME" = "" ]; then
	#
	# Construct a reasonable nickname from the module source location
	#
	MODULE_NAME=`basename $1 | tr '[:blank:][:punct:]' '\n' | tr '[A-Z]' '[a-z]' | grep -ve nginx -e ngx -e http -e stream -e module -e plus -e tar -e zip -e gz -e git | tr -d '\n'`
	read -p "$ME: INPUT: Enter module nickname [$MODULE_NAME]: "
	if [ "$REPLY" != "" ]; then
		MODULE_NAME=$REPLY
	fi
fi

#
# Sanitize module nickname (this is a debbuild requirement, probably needs to check for more characters)
#
MODULE_NAME_CLEAN=`echo $MODULE_NAME | tr '[A-Z]' '[a-z]' | tr -d '[_\-\.\t ]'`
if [ $MODULE_NAME_CLEAN != $MODULE_NAME ]; then
	echo "$ME: WARNING: Removed illegal characters from module nickname - using $MODULE_NAME_CLEAN"
	read -p "$ME: INPUT: Confirm module nickname [$MODULE_NAME_CLEAN]: " MODULE_NAME
	if [ "$MODULE_NAME" = "" ]; then
		MODULE_NAME=$MODULE_NAME_CLEAN
	fi
fi

#
# Create temporary build area, with working copy of module source
#
BUILD_DIR=/tmp/$ME.$$
MODULE_DIR=$BUILD_DIR/$MODULE_NAME
echo "$ME: INFO: Creating $BUILD_DIR build area"
mkdir $BUILD_DIR

if [ -d $1 ]; then
	mkdir -v $MODULE_DIR
	echo "$ME: INFO: Building $MODULE_NAME from $MODULE_DIR"
	cp -a $1/* $MODULE_DIR
else
        #
        # Module sources string is not a local directory so assume it is a URL.
        # Obtain the sources in the best way for the suffix provided.
        #
	case "${1##*.}" in
		"git")
			echo "$ME: INFO: Cloning module source"
			git clone --recursive $1 $MODULE_DIR
			;;
		"zip")
			echo "$ME: INFO Downloading module source"
			wget -O $BUILD_DIR/module.zip $1
			ARCHIVE_DIR=`zipinfo -1 $BUILD_DIR/module.zip | head --lines=1 | cut -f1 -d/`
			unzip $BUILD_DIR/module.zip -d $BUILD_DIR
			mv $BUILD_DIR/$ARCHIVE_DIR $MODULE_DIR
			;;
		*)
			echo "$ME: INFO Downloading module source"
			# Assume tarball of some kind
			wget -O $BUILD_DIR/module.tgz $1
			ARCHIVE_DIR=`tar tfz $BUILD_DIR/module.tgz | head --lines=1 | cut -f1 -d/`
			cd $BUILD_DIR
			tar xfz module.tgz
			mv $ARCHIVE_DIR $MODULE_DIR
			cd -
			;;
	esac
fi

#
# Check the module sources look OK
#
if [ ! -f $MODULE_DIR/config ]; then
	echo "$ME: ERROR: Cannot locate module config file - quitting"
	exit 1
fi

#
# Check/convert module config
#
if [ `grep -c "\.[[:space:]]auto/module" $MODULE_DIR/config` -eq 0 ]; then
	if [ $DO_DYNAMIC_CONVERT = 1 ]; then
		echo "$ME: WARNING: This is a static module, attempting to convert to dynamic (experimental)"
		grep -ve HTTP_MODULES -e STREAM_MODULES -e NGX_ADDON_SRCS $MODULE_DIR/config > $MODULE_DIR/config.dynamic
		echo "ngx_module_name=`grep ngx_addon_name= $MODULE_DIR/config | cut -f2 -d=`" >> $MODULE_DIR/config.dynamic
		if [ `grep -c "HTTP_AUX_FILTER_MODULES=" $MODULE_DIR/config` -gt 0 ]; then
			echo "ngx_module_type=HTTP_AUX_FILTER" >> $MODULE_DIR/config.dynamic
		elif [ `grep -c "STREAM_MODULES=" $MODULE_DIR/config` -gt 0 ]; then
			echo "ngx_module_type=Stream" >> $MODULE_DIR/config.dynamic
		else
			echo "ngx_module_type=HTTP" >> $MODULE_DIR/config.dynamic
		fi
		echo "ngx_module_srcs=\"`grep NGX_ADDON_SRCS= $MODULE_DIR/config | cut -f2 -d\\" | sed -e 's/^\$NGX_ADDON_SRCS \(\$ngx_addon_dir\/.*$\)/\1/'`\"" >> $MODULE_DIR/config.dynamic
		echo ". auto/module" >> $MODULE_DIR/config.dynamic
		mv $MODULE_DIR/config $MODULE_DIR/config.static
		cp $MODULE_DIR/config.dynamic $MODULE_DIR/config
	else
		echo "$ME: ERROR: This is a static module and should be updated to dynamic configuration. To attempt automatic conversion to dynamic module configuration use the '--force-dynamic' option. This will not modify the original configuration. Quitting."
		exit 1
	fi
fi

#
# Get the internal module name(s) from the module config so we can write
# the .so files into the postinstall banner.
#
touch $BUILD_DIR/postinstall.txt
for MODULE_SO_NAME in $(grep ngx_module_name= $MODULE_DIR/config | cut -f2 -d= | cut -f2 -d\"); do
	if [ "`echo $MODULE_SO_NAME | cut -c1`" = "$" ]; then
		# Dereference variable
		SOURCE_VAR=`echo $MODULE_SO_NAME | cut -f2 -d\$`
		MODULE_SO_NAME=`grep $SOURCE_VAR= $MODULE_DIR/config | cut -f2 -d= | cut -f2 -d\"`
	fi
	# Only write load_module line when no backslash present (can't cope with multi-line values)
	echo $MODULE_SO_NAME | grep -c '\\' > /dev/null
	if [ $? -eq 1 ]; then
		echo "    load_module modules/$MODULE_SO_NAME.so;" >> $BUILD_DIR/postinstall.txt
	fi
done
if [ ! -s $BUILD_DIR/postinstall.txt ]; then
	# Didn't find any .so names so this is a final attempt to extract from config file
	MODULE_SO_NAME=`grep ngx_addon_name= $MODULE_DIR/config | cut -f2 -d= | cut -f2 -d\"`
	echo "    load_module modules/$MODULE_SO_NAME.so;" >> $BUILD_DIR/postinstall.txt
fi

#
# Get NGINX OSS packaging tool
#
echo "$ME: INFO: Downloading NGINX packaging tool"
cd $BUILD_DIR
if [ "$BUILD_PLATFORM" = "OSS" ]; then
	if [ "$OSS_VER" != "" ]; then
		MERCURIAL_TAG="-r $OSS_VER-1"
	fi
	hg clone $MERCURIAL_TAG http://hg.nginx.org/pkg-oss
	cd pkg-oss/$PACKAGING_DIR
else
	wget -O - http://hg.nginx.org/pkg-oss/archive/target-plus-r$PLUS_REL.tar.gz  | tar xfz -
	cd pkg-oss-target-plus-r$PLUS_REL/$PACKAGING_DIR
fi
if [ $? -ne 0 ]; then
	echo "$ME: ERROR: Unable to obtain NGINX packaging tool - quitting"
	exit 1
fi

#
# Archive the module source for use with packaging tool using the base OSS version
#
VERSION=`grep "^BASE_VERSION=" Makefile | cut -f2 -d= | tr -d "[:blank:]"`
echo "$ME: INFO: Archiving module source for $VERSION"
cd $BUILD_DIR
mv $MODULE_NAME $MODULE_NAME-$VERSION
tar cf - $MODULE_NAME-$VERSION | gzip -1 > $OLDPWD/$PACKAGE_SOURCES_DIR/$MODULE_NAME-$VERSION.tar.gz
cd -

echo "$ME: INFO: Creating changelog"
if [ "$PKG_MGR" = "yum" ]; then
	echo "* `date '+%a %b %d %Y'` Build Script <build.script@example.com>" > nginx-module-$MODULE_NAME.changelog.in
	echo "- initial version of $MODULE_NAME module" >> nginx-module-$MODULE_NAME.changelog.in
else
	cat << __EOF__ > nginx-module-$MODULE_NAME.changelog.in
nginx-module-$MODULE_NAME (${VERSION}) %%CODENAME%%; urgency=low

  * initial release of $MODULE_NAME module for nginx

 -- Build Script <build.script@example.com>  `date -R`
__EOF__
fi

echo "$ME: INFO: Creating module Makefile"
cat << __EOF__ > Makefile.module-$MODULE_NAME
MODULES=$MODULE_NAME

MODULE_PACKAGE_VENDOR=	Build Script <build.script@example.com>
MODULE_PACKAGE_URL=	https://www.nginx.com/blog/compiling-dynamic-modules-nginx-plus/

MODULE_SUMMARY_$MODULE_NAME=		$MODULE_NAME dynamic module
MODULE_VERSION_$MODULE_NAME=		$VERSION
MODULE_RELEASE_$MODULE_NAME=		1
MODULE_CONFARGS_$MODULE_NAME=		--add-dynamic-module=\$(MODSRC_PREFIX)$MODULE_NAME-$VERSION
MODULE_SOURCES_$MODULE_NAME=		$MODULE_NAME-$VERSION.tar.gz

define MODULE_POST_$MODULE_NAME
cat <<BANNER
----------------------------------------------------------------------

The \$(MODULE_SUMMARY_$MODULE_NAME) for nginx has been installed.
To enable this module, add the following to /etc/nginx/nginx.conf
and reload nginx:

`uniq $BUILD_DIR/postinstall.txt`

----------------------------------------------------------------------
BANNER
endef
export MODULE_POST_$MODULE_NAME
__EOF__

#
# Build!
#
echo "$ME: INFO: Building"
make prepare-build-env
if [ $? -ne 0 ]; then
	echo "$ME: ERROR: Unable to prepare build environment - quitting"
	exit 1
fi

if [ "$PKG_MGR" = "yum" ]; then
	cd ~/rpmbuild/SPECS
else
	cd ~/debuild/nginx-$VERSION/debian
fi

if [ "$BUILD_PLATFORM" = "Plus" ]; then
	MODULE_TARGET=plus make module-$MODULE_NAME
else
	make module-$MODULE_NAME
fi
if [ $? -ne 0 ]; then
	echo "$ME: ERROR: Build failed"
else
	echo "$ME: INFO: Module binaries created"
	$FIND_SO_CMD
	echo "$ME: INFO: Module packages created"
	$FIND_PKGS_CMD
	echo "$ME: INFO: Removing $BUILD_DIR"
	rm -fr $BUILD_DIR
fi
