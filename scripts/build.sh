#!/bin/bash
#
# Simple script to build the RZ Edge AI Demo: https://github.com/renesas-rz/meta-rz-edge-ai-demo
# The script supports building for the following devices:
#   RZ/G2: hihope-rzg2m,  ek874
#   RZ/G2L: smarc-rzg2l, smarc-rzg2lc
#
# This script has been tested on Ubuntu 20.04 and Ubuntu 18.04.
#
# SPDX-License-Identifier: MIT
# Copyright (C) 2022 Renesas Electronics Corp.

set -e

################################################################################
# Global parameters
META_RZ_EDGE_AI_DEMO_URL="${CI_REPOSITORY_URL:-https://github.com/renesas-rz/meta-rz-edge-ai-demo.git}"
META_RZ_EDGE_AI_DEMO_VER="${CI_COMMIT_REF_NAME:-master}"
RZ_EDGE_AI_DEMO_REPO="${CI_DEMO_REPO:-github.com/renesas-rz/rz-edge-ai-demo.git}"
RZ_EDGE_AI_DEMO_REPO_BRANCH="${CI_DEMO_REPO_BRANCH:-master}"
RZ_EDGE_AI_DEMO_REPO_PROTOCOL="${CI_DEMO_REPO_PROTOCOL:-https}"
WORK_DIR="${PWD}"
COMMAND_NAME="$0"
INSTALL_DEPENDENCIES=false
PLATFORM=""
PROP_DIR=""
PROP_LIBS_EXTRACTED=false
BUILD=true
OUTPUT_DIR="${WORK_DIR}/output"
FAMILY=""
SKIP_LICENSE_WARNING=false
BUILD_SDK=false
YOCTO_DL_DIR=""
YOCTO_SSTATE_DIR=""

################################################################################
# Helpers

print_help () {
        cat<<-EOF

	 This script will build the RZ Edge AI Demo for the specified platform.
	 It will install all dependencies and download all source code,
	 apart from the proprietary GFX & multimedia libraries.

	 USAGE: ${COMMAND_NAME} -p <platform> -l <dir> [-c] [-d] [-e] \\
	                    [-j <dir>] [-k <dir> [-o <dir>] \\
	                    [-s] [-t] [-T] [-h]

	 OPTIONS:
	 -h                 Print this help and exit.
	 -c                 Only perform checkout, proprietary library
	                    extraction and configuration. Don't start the build.
	 -d                 Install OS dependencies before starting build.
	 -e                 Marks that proprietary libraries have already been
	                    extracted to the directory specified by -l.
	                    For the RZ/G2L BSP the directory should contain the
	                    contents of the meta-rz-features layer.
	 -j <dir>           Set directory to use for the Yocto DL_DIR variable.
	 -k <dir>           Set directory to use for the Yocto SSTATE_DIR
	                    variable.
	 -l <dir>           Location when proprietary libraries have been
	                    downloaded to.
	 -o <dir>           Location to copy binaries to when build is complete.
	                    By default ${OUTPUT_DIR} will be used.
	 -p <platform>      Platform to build for. Choose from:
	                    hihope-rzg2m, ek874, smarc-rzg2l, smarc-rzg2lc.
	 -s                 Skip the license warning prompt and automatically
	                    include the packages in LICENSE_FLAGS_WHITELIST.
	 -t                 Build toolchain/SDK once main build has completed.
	 -T                 Only build toolchain/SDK.

	EOF
}

################################################################################
# Options parsing

while getopts ":cdej:k:l:o:p:stTh" opt; do
        case $opt in
	c)
		BUILD=false
		;;
        d)
		INSTALL_DEPENDENCIES=true
                ;;
	e)
		PROP_LIBS_EXTRACTED=true
		;;
	j)
		YOCTO_DL_DIR="${OPTARG}"
		;;
	k)
		YOCTO_SSTATE_DIR="${OPTARG}"
		;;
        l)
                if [ ! -d "${OPTARG}" ]; then
                        echo " ERROR: -l \"${OPTARG}\" No such directory"
                        print_help
                        exit 1
                fi
                PROP_DIR="$(realpath "${OPTARG}")"
                ;;
        o)
                if [ ! -d "${OPTARG}" ]; then
                        echo " ERROR: -l \"${OPTARG}\" No such directory"
                        print_help
                        exit 1
                fi
                OUTPUT_DIR="$(realpath "${OPTARG}")"
                ;;
        p)
		case "${OPTARG}" in
		"hihope-rzg2m" | "ek874")
			PLATFORM="${OPTARG}"
			FAMILY="rzg2"
        	        ;;

		"smarc-rzg2l" | "smarc-rzg2lc")
			PLATFORM="${OPTARG}"
			FAMILY="rzg2l"
			;;
		*)
			echo " ERROR: -p \"${OPTARG}\" Not supported"
			print_help
			exit 1
			;;
		esac
		;;
	s)
		SKIP_LICENSE_WARNING=true
		;;
	t)
		BUILD_SDK=true
		;;
	T)
		BUILD_SDK="only"
		;;
	h)
		print_help
		exit 1
		;;
	\?)
		echo " ERROR: Invalid option: -$OPTARG"
		print_help
		exit 1
		;;
	:)
		echo " ERROR: Option -$OPTARG requires an argument"
		print_help
		exit 1
		;;
	esac
done

if [ -z "$PLATFORM" ]; then
	echo " ERROR: Platform (-p) must be set"
	print_help
	exit 1
fi

if [ -z "$PROP_DIR" ]; then
	echo " ERROR: Proprietary library directory (-l) must be set"
	print_help
	exit 1
fi

################################################################################
# Functions

install_dependencies () {
	echo "#################################################################"
	echo "Installing dependencies..."

	local beroot=""
	if [ $(id -u) -ne 0 ];then
		beroot="sudo"
	fi

	$beroot apt update
	$beroot apt install -y gawk wget git-core diffstat unzip texinfo \
			gcc-multilib build-essential chrpath socat cpio python3 \
			python3-pip python3-pexpect xz-utils debianutils \
			iputils-ping python3-git python3-jinja2 libegl1-mesa \
			libsdl1.2-dev pylint3 xterm
}

# $1 project/directory name
# $2 repo url
# $3 version
update_git_repo () {
	# Check if repo is already checked out
	if [ ! -d "$1" ]; then
		git clone $2 $1
	fi

	pushd ${WORK_DIR}/$1
	git fetch origin
	git checkout $3
	popd
}

download_source () {
	echo "#################################################################"
	echo "Downloading source..."

	if [ ${FAMILY} == "rzg2" ]; then
		update_git_repo \
			poky \
			git://git.yoctoproject.org/poky \
			7e7ee662f5dea4d090293045f7498093322802cc

		cd poky; git cherry-pick 0810ac6b92; cd -

		update_git_repo \
			meta-linaro \
			git://git.linaro.org/openembedded/meta-linaro.git \
			75dfb67bbb14a70cd47afda9726e2e1c76731885

		update_git_repo \
			meta-openembedded \
			git://git.openembedded.org/meta-openembedded \
			352531015014d1957d6444d114f4451e241c4d23

		update_git_repo \
			meta-gplv2 \
			https://git.yoctoproject.org/meta-gplv2 \
			f875c60ecd6f30793b80a431a2423c4b98e51548

		update_git_repo \
			meta-qt5 \
			https://github.com/meta-qt5/meta-qt5.git \
			c1b0c9f546289b1592d7a895640de103723a0305

		update_git_repo \
			meta-virtualization \
			https://git.yoctoproject.org/git/meta-virtualization \
			b704c689b67639214b9568a3d62e82df27e9434f

		update_git_repo \
			meta-rzg2 \
			https://github.com/renesas-rz/meta-rzg2.git \
			BSP-1.0.10-update1

		update_git_repo \
			meta-renesas-ai \
			https://github.com/renesas-rz/meta-renesas-ai.git \
			v4.7.0

		update_git_repo \
			meta-rz-edge-ai-demo \
			${META_RZ_EDGE_AI_DEMO_URL} \
			${META_RZ_EDGE_AI_DEMO_VER}
	elif [ ${FAMILY} == "rzg2l" ]; then
		update_git_repo \
			poky \
			git://git.yoctoproject.org/poky \
			dunfell-23.0.13

		cd poky; git cherry-pick e256885889

		# We need to cherry-pick the following commit to prevent SDK basehash issue
		git cherry-pick cfd897e213d; cd -

		update_git_repo \
			meta-openembedded \
			git://git.openembedded.org/meta-openembedded \
			ab9fca485e13f6f2f9761e1d2810f87c2e4f060a

		update_git_repo \
			meta-gplv2 \
			https://git.yoctoproject.org/meta-gplv2 \
			60b251c25ba87e946a0ca4cdc8d17b1cb09292ac

		update_git_repo \
			meta-qt5 \
			https://github.com/meta-qt5/meta-qt5.git \
			c1b0c9f546289b1592d7a895640de103723a0305

		update_git_repo \
			meta-virtualization \
			https://git.yoctoproject.org/git/meta-virtualization \
			9e9868ef3d6e5da7f0ecd0680fcd69324593842b

		update_git_repo \
			meta-rzg2 \
			https://github.com/renesas-rz/meta-rzg2.git \
			rzg2l_bsp_v1.4

		update_git_repo \
			meta-renesas-ai \
			https://github.com/renesas-rz/meta-renesas-ai.git \
			v4.7.0

		update_git_repo \
			meta-rz-edge-ai-demo \
			${META_RZ_EDGE_AI_DEMO_URL} \
			${META_RZ_EDGE_AI_DEMO_VER}
	fi
}

install_prop_libs () {
	echo "#################################################################"
	echo "Installing proprietary libraries..."

	if [ ${FAMILY} == "rzg2" ]; then
		if ! $PROP_LIBS_EXTRACTED; then
			pushd ${PROP_DIR}
			tar -zxf RZG2_Group_*_Software_Package_for_Linux_*.tar.gz
			PROP_DIR=${PROP_DIR}/proprietary
			popd
		fi

		pushd ${WORK_DIR}/meta-rzg2
		sh docs/sample/copyscript/copy_proprietary_softwares.sh \
			-f ${PROP_DIR}
		popd
	elif [ ${FAMILY} == "rzg2l" ]; then
		if $PROP_LIBS_EXTRACTED; then
			rm -rf ${WORK_DIR}/meta-rz-features
			cp -r ${PROP_DIR} ${WORK_DIR}/meta-rz-features
		else
			pushd ${PROP_DIR}
			unzip RTK0EF0045Z13001ZJ-v0.81_EN.zip
			tar -xf RTK0EF0045Z13001ZJ-v0.81_EN/meta-rz-features.tar.gz -C ${WORK_DIR}
			unzip RTK0EF0045Z15001ZJ-v0.55_EN.zip
			tar -xf RTK0EF0045Z15001ZJ-v0.55_EN/meta-rz-features.tar.gz -C ${WORK_DIR}
			popd
		fi
	fi
}

configure_build () {
	echo "#################################################################"
	echo "Configuring build..."

	# This will create and take us to the $WORK_DIR/build directory
	source poky/oe-init-build-env

	cp $WORK_DIR/meta-rz-edge-ai-demo/templates/$PLATFORM/* ./conf/

	if [ ! -z ${YOCTO_DL_DIR} ]; then
		echo "DL_DIR = \"${YOCTO_DL_DIR}\"" >> ./conf/local.conf
	fi

	if [ ! -z ${YOCTO_SSTATE_DIR} ]; then
		echo "SSTATE_DIR = \"${YOCTO_SSTATE_DIR}\"" >> ./conf/local.conf
	fi

	if $SKIP_LICENSE_WARNING; then
		sed -i 's/#LICENSE_FLAGS_WHITELIST/LICENSE_FLAGS_WHITELIST/g' ./conf/local.conf
	fi

        echo RZ_EDGE_AI_DEMO_REPO = \"${RZ_EDGE_AI_DEMO_REPO}\" >> ./conf/local.conf
        echo RZ_EDGE_AI_DEMO_REPO_BRANCH = \"${RZ_EDGE_AI_DEMO_REPO_BRANCH}\" >> ./conf/local.conf
        echo RZ_EDGE_AI_DEMO_REPO_PROTOCOL = \"${RZ_EDGE_AI_DEMO_REPO_PROTOCOL}\" >> ./conf/local.conf
	if [ ! -z ${CI_DEMO_REPO_REV+x} ]; then
		if [ ${CI_DEMO_REPO_REV} = "AUTOREV" ]; then
			echo SRCREV_rz-edge-ai-demo = \"\${AUTOREV}\" >> ./conf/local.conf
		else
			echo SRCREV_rz-edge-ai-demo = \"${CI_DEMO_REPO_REV}\" >> ./conf/local.conf
		fi
	fi
}

do_build () {
	echo "#################################################################"
	echo "Starting build..."
	bitbake core-image-qt
}

do_sdk_build () {
	echo "#################################################################"
	echo "Starting SDK build..."

	if [ ${FAMILY} == "rzg2" ]; then
		bitbake core-image-qt-sdk -c populate_sdk
	elif [ ${FAMILY} == "rzg2l" ]; then
		bitbake core-image-qt -c populate_sdk
	fi
}

# $1..$n: File (including path) to copy to output directory
copy_file () {
	for file in "$@"; do
		echo "Copying ${file}..."
		cp ${file} ${OUTPUT_DIR}/${PLATFORM} || echo "${file} not found!"
	done
}

copy_output () {
	echo "#################################################################"
	echo "Copying output..."
	mkdir -p ${OUTPUT_DIR}/${PLATFORM}
	local bin_dir=$WORK_DIR/build/tmp/deploy/images/${PLATFORM}

	if [ $BUILD_SDK != "only" ]; then
		echo "Contents of images directory..."
		ls -la ${bin_dir}

		# RFS / Wic
		copy_file "${bin_dir}/core-image-qt-${PLATFORM}.tar.gz"
		copy_file "${bin_dir}/core-image-qt-${PLATFORM}.wic.gz"
		# Kernel / modules
		copy_file "${bin_dir}/Image-${PLATFORM}.bin"
		copy_file "${bin_dir}/modules-${PLATFORM}.tgz"
		# Manifest
		copy_file "${bin_dir}/core-image-qt-${PLATFORM}.manifest"
		# License information
		pushd "$WORK_DIR/build/tmp/deploy/" > /dev/null
		tar czf licenses-${PLATFORM}.tar.gz licenses
		copy_file licenses-${PLATFORM}.tar.gz
		popd > /dev/null

		if [ ${FAMILY} == "rzg2" ]; then
			# DTB
			copy_file $(find "${bin_dir}" -type l -iname "*image-*.dtb")
			# Bootloaders
			copy_file "${bin_dir}/bootparam_sa0.srec"
			copy_file "${bin_dir}/bl2-${PLATFORM}.srec"
			copy_file "${bin_dir}/cert_header_sa6.srec"
			copy_file "${bin_dir}/bl31-${PLATFORM}.srec"
			copy_file "${bin_dir}/tee-${PLATFORM}.srec"
			copy_file "${bin_dir}/u-boot-elf-${PLATFORM}.srec"
			copy_file "${bin_dir}/*Flash_writer*.mot"
		elif [ ${FAMILY} == "rzg2l" ]; then
			# DTB
			copy_file $(find "${bin_dir}" -type l -iname "*${PLATFORM}*.dtb")
			# Bootloaders
			copy_file "${bin_dir}/bl2_bp-${PLATFORM}.srec"
			copy_file "${bin_dir}/fip-${PLATFORM}.srec"
			copy_file "${bin_dir}/Flash_Writer*.mot"
			if [ ${PLATFORM} == "smarc-rzg2l" ]; then
				copy_file "${bin_dir}/bl2_bp-${PLATFORM}_pmic.srec"
				copy_file "${bin_dir}/fip-${PLATFORM}_pmic.srec"
			fi
		fi
	fi

	if [ $BUILD_SDK != "false" ]; then
		echo "Contents of SDK directory..."
		ls -la $WORK_DIR/build/tmp/deploy/sdk/
		# SDK
		echo "Copying SDK..."
		cp $WORK_DIR/build/tmp/deploy/sdk/*.sh ${OUTPUT_DIR}/${PLATFORM}/rz-edge-ai-demo-sdk_${PLATFORM}.sh
	fi

	echo "Contents of output directory..."
	ls -l ${OUTPUT_DIR}/${PLATFORM}
}

################################################################################
# Main


echo "#################################################################"
echo "RZ Edge AI Demo version: ${META_RZ_EDGE_AI_DEMO_VER}"
echo "RZ/G AI BSP version: ${RZG_AI_BSP_VER}"
echo "RZ/G BSP version: ${RZG_BSP_VER}"
echo "Working Directory: ${WORK_DIR}"
echo "Platform: ${PLATFORM}"
echo "Proprietary Library Directory: ${PROP_DIR}"
echo "Output Directory: ${OUTPUT_DIR}"

if $INSTALL_DEPENDENCIES; then
	install_dependencies
fi
download_source
install_prop_libs
configure_build

if $BUILD; then
	if [ $SKIP_LICENSE_WARNING != "true" ]; then
		echo -ne "\nHave licensing options been updated in the local.conf file? "; read
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			echo "Please uncomment the LICENSE_FLAGS_WHITELIST to build the BSP and restart"
			exit 1
		fi
	fi

	if [ $BUILD_SDK == "true" ]; then
		do_build && do_sdk_build
	elif [ $BUILD_SDK == "only" ]; then
		do_sdk_build
	else
		do_build
	fi

	copy_output
fi

echo "#################################################################"
echo "Done!"
echo "#################################################################"
