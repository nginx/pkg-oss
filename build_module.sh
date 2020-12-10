#!/bin/sh
#
# build_module.sh (c) NGINX, Inc., Liam Crilly <liam.crilly@nginx.com>
#
# This script supports apt(8) and yum(8) package managers. Installs the minimum
# necessary prerequisite packages to build 3rd party modules for NGINX Plus.
# Obtains source for module and NGINX OSS, prepares for pkg-oss tool. Inspects
# module configuration and attempts to rewrite for dynamic build if necessary.
# Obtains pkg-oss tool, creates packaging files and copies in module source.
#
# CHANGELOG
# v0.17 [11-Nov-2020] Fixed bashisms and made /bin/sh default interpreter
# v0.16 [09-Nov-2020] Added Alpine Linux packaging
# v0.15 [03-Nov-2020] use latest version tag if -v is specified
#                     use HTTPS while fetching sources
# v0.14 [02-Nov-2020] sudo is not mandatory anymore
#                     update repo caches prior to dependencies installs
#                     do not install suggested/recommended packages on debian-based distros
#                     xmllint/xsltproc are added to build dependencies
#                     exit with code 1 when module build failed
# v0.13 [12-Oct-2020] adjusted for refactored package tooling
#                     -o option made de-facto mandatory with preconfigured default
# v0.12 [30-Aug-2017] -o option to specify destination for package files
#                     -y (--non-interactive) option for automated builds
# v0.11 [20-Jun-2017] Enforces NGINX versions that support dynamic modules
# v0.10 [27-Apr-2017] Fixed postinstall banner, improved .so filename detection,
#                     -v option for specifying OSS build/version
# v0.9  [10-Apr-2017] @defan patch, improved postinstall banner, added disclaimer
# v0.8  [30-Mar-2017] Package version is now tied to base OSS version instead of 0.01
# v0.7  [29-Mar-2017] Added RPM packaging, flexible command line options with defaults
# v0.6  [16-Feb-2017] Using pkg-oss tool instead of only compiling .so files

OUTPUT_DIR="`pwd`/build-module-artifacts"

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
	echo " -y | --non-interactive         # Automatically install dependencies and overwrite files"
	echo " -f | --force-dynamic           # Attempt to convert static configuration to dynamic module"
	echo " -r <NGINX Plus release number> # Build against the corresponding OSS version for this release"
	echo " -v [NGINX OSS version number]  # Build against this OSS version [current mainline] (default)"
	echo " -o <package output directory>  # Create package(s) in this directory (default: $OUTPUT_DIR)"
	echo ""
        exit 1
fi

#
# Process command line options
#
CHECK_DEPENDS=1
SAY_YES=""
COPY_CMD="cp -i"
DO_DYNAMIC_CONVERT=0
MODULE_NAME=""
BUILD_PLATFORM=OSS
while [ $# -gt 1 ]; do
	case "$1" in
		"-s" | "--skip-depends")
			CHECK_DEPENDS=0
			shift
			;;
		"-y" | "--non-interactive")
			SAY_YES="-y"
			COPY_CMD="cp -f"
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
			elif [ "`echo "10^$2" | tr '^' '\n' | sort -nr | head -1`" = "10" ]; then
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
			if [ `echo "1.11.4^$OSS_VER" | tr '^' '\n' | tr '.' ',' | sort -nr | head -1` = "1,11,4" ]; then
				echo "$ME: ERROR: NGINX version must be at least 1.11.5 to support dynamic modules - quitting"
				exit 1
			fi
			shift
			;;
		"-o")
			OUTPUT_DIR=`realpath $2`
			if [ $? -ne 0 ]; then
				echo "$ME: ERROR: Could not access output directory $2 - quitting"
				exit 1
			fi
			shift; shift
			;;
		*)
			echo "$ME: ERROR: Invalid command line option ($1) - quitting"
			exit 1
			;;
	esac
done

#
# Create package output directory
#
if [ ! -d $OUTPUT_DIR ]; then
	mkdir -p $OUTPUT_DIR
	if [ $? -ne 0 ]; then
		echo "$ME: ERROR: Could not create output directory $OUTPUT_DIR - quitting"
		exit 1
	fi
fi

#
# Locate/select package manager and configure
#
if [ `whereis yum 2>/dev/null | grep -c "^yum: /"` -eq 1 ]; then
	PKG_MGR_INSTALL="yum install $SAY_YES"
	PKG_MGR_UPDATE="yum makecache"
	PKG_FMT=rpm
	NGINX_PACKAGES="pcre-devel zlib-devel openssl-devel"
	DEVEL_PACKAGES="rpm-build libxml2 libxslt"
	PACKAGING_ROOT=pkg-oss/rpm/
	PACKAGING_DIR=rpm/SPECS
	PACKAGE_SOURCES_DIR=../SOURCES
	PACKAGE_OUTPUT_DIR=RPMS
elif [ `whereis apt-get 2>/dev/null | grep -c "^apt-get: /"` -eq 1 ]; then
	PKG_MGR_INSTALL="apt-get --no-install-suggests --no-install-recommends install $SAY_YES"
	PKG_MGR_UPDATE="apt-get update"
	PKG_FMT=deb
	NGINX_PACKAGES="libpcre3-dev zlib1g-dev libssl-dev"
	DEVEL_PACKAGES="devscripts fakeroot debhelper dpkg-dev quilt lsb-release build-essential libxml2-utils xsltproc"
	PACKAGING_ROOT=pkg-oss/debian/
	PACKAGING_DIR=debian
	PACKAGE_SOURCES_DIR=extra
	PACKAGE_OUTPUT_DIR="debuild-module-*/"
elif [ `apk --version | grep -c "^apk-tools"` -eq 1 ]; then
	PKG_MGR_INSTALL="apk add"
	PKG_MGR_UPDATE="apk update"
	PKG_FMT=apk
	NGINX_PACKAGES="linux-headers openssl-dev pcre-dev zlib-dev"
	DEVEL_PACKAGES="openssl abuild musl-dev"
	PACKAGING_ROOT=pkg-oss/alpine/
	PACKAGING_DIR=alpine
	PACKAGE_SOURCES_DIR=src
else
        echo "$ME: ERROR: Could not locate a supported package manager - quitting"
        exit 1
fi

if [ $CHECK_DEPENDS = 1 ]; then
	if [ `id -u` -ne 0 ]; then
		echo "$ME: INFO: testing sudo"
		sudo pwd > /dev/null
		if [ $? -ne 0 ]; then
			echo "ERROR: sudo failed. If you do not have sudo credentials then try using the '--skip-depends' option. Quitting."
			exit 1
		else
			SUDO=sudo
		fi
	fi

	echo "$ME: INFO: checking for dependent packages"
	CORE_PACKAGES="gcc make unzip wget"
	if [ "$BUILD_PLATFORM" = "OSS" ]; then
		CORE_PACKAGES="$CORE_PACKAGES mercurial"
	fi
	if [ "${1##*.}" = "git" ]; then
		CORE_PACKAGES="$CORE_PACKAGES git"
	fi
	$SUDO $PKG_MGR_UPDATE
	$SUDO $PKG_MGR_INSTALL $CORE_PACKAGES $NGINX_PACKAGES $DEVEL_PACKAGES
fi

#
# Ask for a nickname if we did't get one on the command line
#
if [ "$MODULE_NAME" = "" ]; then
	#
	# Construct a reasonable nickname from the module source location
	#
	MODULE_NAME=`basename $1 | tr '[:blank:][:punct:]' '\n' | tr '[A-Z]' '[a-z]' | grep -ve nginx -e ngx -e http -e stream -e module -e plus -e tar -e zip -e gz -e git | tr -d '\n'`
	if [ -z "$SAY_YES" ]; then
		echo -n "$ME: INPUT: Enter module nickname [$MODULE_NAME]: "
		read -r REPLY
		if [ "$REPLY" != "" ]; then
			MODULE_NAME=$REPLY
		fi
	else
		echo "$ME: INFO: using \"$MODULE_NAME\" as module nickname"
	fi
fi

#
# Sanitize module nickname (this is a debbuild requirement, probably needs to check for more characters)
#
while true; do
	MODULE_NAME_CLEAN=`echo $MODULE_NAME | tr '[A-Z]' '[a-z]' | tr -d '[/_\-\.\t ]'`
	if [ "$MODULE_NAME_CLEAN" != "$MODULE_NAME" ] || [ -z $MODULE_NAME ]; then
		echo "$ME: WARNING: Removed illegal characters from module nickname - using \"$MODULE_NAME_CLEAN\""
		if [ -z $SAY_YES ]; then
			echo -n "$ME: INPUT: Confirm module nickname [$MODULE_NAME_CLEAN]: "
			read -r MODULE_NAME
			if [ "$MODULE_NAME" = "" ]; then
				MODULE_NAME=$MODULE_NAME_CLEAN
			fi
		else
			MODULE_NAME=$MODULE_NAME_CLEAN
			break
		fi
	else
		break
	fi
done

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
			ARCHIVE_DIR=`zipinfo -1 $BUILD_DIR/module.zip | head -n 1 | cut -f1 -d/`
			unzip $BUILD_DIR/module.zip -d $BUILD_DIR
			mv $BUILD_DIR/$ARCHIVE_DIR $MODULE_DIR
			;;
		*)
			echo "$ME: INFO Downloading module source"
			# Assume tarball of some kind
			wget -O $BUILD_DIR/module.tgz $1
			ARCHIVE_DIR=`tar tfz $BUILD_DIR/module.tgz | head -n 1 | cut -f1 -d/`
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
	hg clone https://hg.nginx.org/pkg-oss
	if [ "$OSS_VER" != "" ]; then
		( cd pkg-oss && hg update `hg tags | grep "^$OSS_VER" | head -1 | awk '{print $1}'` )
	fi
	cd pkg-oss/$PACKAGING_DIR
else
	wget -O - https://hg.nginx.org/pkg-oss/archive/target-plus-r$PLUS_REL.tar.gz | tar xfz -
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
cd $BUILD_DIR
cat << __EOF__ >pkg-oss/docs/nginx-module-$MODULE_NAME.xml
<?xml version="1.0" ?>
<!DOCTYPE change_log SYSTEM "changes.dtd" >


<change_log title="nginx_module_$MODULE_NAME">


<changes apply="nginx-module-$MODULE_NAME" ver="$VERSION" rev="1"
         date="`date '+%Y-%m-%d'`" time="`date '+%H:%M:%S %z'`"
         packager="Build Script &lt;build.script@example.com&gt;">

<change>
<para>
initial release of $MODULE_NAME module for nginx
</para>
</change>

</changes>


</change_log>
__EOF__

cat << __EOF__ >pkg-oss/docs/nginx-module-$MODULE_NAME.copyright
placeholder for nginx-module-$MODULE_NAME license / copyrights
__EOF__

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

cp Makefile.module-$MODULE_NAME $BUILD_DIR/pkg-oss/rpm/SPECS/
cp Makefile.module-$MODULE_NAME $BUILD_DIR/pkg-oss/debian/
cp Makefile.module-$MODULE_NAME $BUILD_DIR/pkg-oss/alpine/

#
# Build!
#
echo "$ME: INFO: Building"

if [ "$PKG_FMT" = "rpm" ]; then
	cd $BUILD_DIR/pkg-oss/rpm/SPECS
elif [ "$PKG_FMT" = "deb" ]; then
	cd $BUILD_DIR/pkg-oss/debian
else
	cd $BUILD_DIR/pkg-oss/alpine
fi

if [ "$BUILD_PLATFORM" = "Plus" ]; then
	MODULE_TARGET=plus make module-$MODULE_NAME
else
	make module-$MODULE_NAME
fi
if [ $? -ne 0 ]; then
	echo "$ME: ERROR: Build failed"
	exit 1
else
	echo ""
	echo "$ME: INFO: Module binaries created"
	find $BUILD_DIR/$PACKAGING_ROOT -type f -name "*.so" -print

	echo "$ME: INFO: Module packages created"
	if [ "$PKG_FMT" = "apk" ]; then
		find ~/packages -type f -name "*.$PKG_FMT" -exec $COPY_CMD -v {} $OUTPUT_DIR/ \;
	else
		find $BUILD_DIR/$PACKAGING_ROOT$PACKAGE_OUTPUT_DIR -type f -name "*.$PKG_FMT" -exec $COPY_CMD -v {} $OUTPUT_DIR/ \;
	fi
	echo "$ME: INFO: Removing $BUILD_DIR"
	rm -fr $BUILD_DIR
fi
