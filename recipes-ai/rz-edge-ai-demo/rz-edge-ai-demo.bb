SUMMARY = "RZ Edge AI Demo"
DESCRIPTION = "Build and install the RZ/G Edge AI Demo application"

inherit populate_sdk_qt5
require recipes-qt/qt5/qt5.inc

LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/${LICENSE};md5=801f80980d171dd6425610833a22dbe6"

DEPENDS = "qtmultimedia opencv gstreamer1.0 tensorflow-lite armnn"
RDEPENDS_${PN} = "libopencv-core libopencv-videoio libopencv-imgcodecs libopencv-imgproc armnn-dev"

RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY ?= "/opt/rz-edge-ai-demo"

RZ_EDGE_AI_DEMO_REPO ?= "github.com/renesas-rz/rz-edge-ai-demo.git"
RZ_EDGE_AI_DEMO_REPO_PROTOCOL ?= "https"
RZ_EDGE_AI_DEMO_REPO_BRANCH ?= "master"

SRC_URI = " \
	git://${RZ_EDGE_AI_DEMO_REPO};protocol=${RZ_EDGE_AI_DEMO_REPO_PROTOCOL};branch=${RZ_EDGE_AI_DEMO_REPO_BRANCH};name=rz-edge-ai-demo \
	file://icons/ \
	file://logos/ \
	file://models/ \
	file://populate_scripts.sh \
"

SRCREV_rz-edge-ai-demo ?= "c6f8bfe01ecb701a86bf936b58c0ff078dd66380"

S = "${WORKDIR}/git"

do_configure_prepend () {
	export SDKTARGETSYSROOT="../recipe-sysroot"
}

do_install_append () {
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/icons
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/logos
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/models
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/scripts
	install -m 444 ${WORKDIR}/icons/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/icons
	install -m 444 ${WORKDIR}/logos/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/logos
	install -m 444 ${WORKDIR}/models/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/models
	install -m 555 ${B}/rz-edge-ai-demo ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}
	${WORKDIR}/populate_scripts.sh ${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}
	install -m 555 ${B}/scripts/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/scripts
}

FILES_${PN} = " \
	${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY} \
"

INSANE_SKIP_${PN} = "dev-deps dev-so"
