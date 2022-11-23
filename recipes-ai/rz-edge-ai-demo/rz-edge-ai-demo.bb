SUMMARY = "RZ Edge AI Demo"
DESCRIPTION = "Build and install the RZ/G Edge AI Demo application"

inherit populate_sdk_qt5 qmake5
require recipes-qt/qt5/qt5.inc

# GPL-2.0 license applies to the application, files/models/shoppingBasketDemo.tflite, files/labels/shoppingBasketDemo_labels.txt. and files/prices
# Apache-2.0 license applies to all models in files/models apart from shoppingBasketDemo.tflite and browserfft-speech-renesas.tflite
# CC-BY-2.0 license applies to the object detection image files sourced from Open Images Dataset V5
# Attribution-4.0 license applies to file/models/browserfft-speech-renesas.tflite, audioDemo_labels.txt and sample files under files/media/audio-command/
LICENSE = "GPL-2.0 & Apache-2.0 & CC-BY-2.0 & Attribution-4.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6 \
                    file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
		    file://${WORKDIR}/media/CC-BY-2.0;md5=a8e963175ca315520e460930e46cd907 \
		    file://${WORKDIR}/media/Attribution-4.0;md5=60f8103054954b2c75f1faa295ea3590 \
"

DEPENDS = "qtmultimedia opencv gstreamer1.0 tensorflow-lite armnn"
RDEPENDS_${PN} = "libopencv-core libopencv-videoio libopencv-imgcodecs libopencv-imgproc armnn-dev"

PV = "5.0+git${SRCPV}"

RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY ?= "/opt/rz-edge-ai-demo"

RZ_EDGE_AI_DEMO_REPO ?= "github.com/renesas-rz/rz-edge-ai-demo.git"
RZ_EDGE_AI_DEMO_REPO_PROTOCOL ?= "https"
RZ_EDGE_AI_DEMO_REPO_BRANCH ?= "master"

SRC_URI = " \
	git://${RZ_EDGE_AI_DEMO_REPO};protocol=${RZ_EDGE_AI_DEMO_REPO_PROTOCOL};branch=${RZ_EDGE_AI_DEMO_REPO_BRANCH};name=rz-edge-ai-demo \
	file://icons/ \
	file://labels/ \
	file://logos/ \
	file://media/ \
	file://models/ \
	file://prices/ \
	file://populate_scripts.sh \
"

# v5.0
SRCREV_rz-edge-ai-demo ?= "60ddfcbaf1a9e7b588ad0836067addcc3f5d1e2e"

S = "${WORKDIR}/git"

do_configure_prepend () {
	export SDKTARGETSYSROOT="../recipe-sysroot"
}

do_install_append () {
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/icons
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/labels
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/logos
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/models
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/face-detection
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/object-detection
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/pose-estimation
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/shopping-basket
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command/down
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command/go
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command/left
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command/off
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command/right
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command/stop
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command/up
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/prices
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/scripts
	install -m 444 ${WORKDIR}/icons/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/icons
	install -m 444 ${WORKDIR}/labels/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/labels
	install -m 444 ${WORKDIR}/logos/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/logos
	install -m 444 ${WORKDIR}/media/face-detection/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/face-detection
	install -m 444 ${WORKDIR}/media/object-detection/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/object-detection
	install -m 444 ${WORKDIR}/media/pose-estimation/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/pose-estimation
	install -m 444 ${WORKDIR}/media/shopping-basket/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/shopping-basket
	install -m 444 ${WORKDIR}/media/audio-command/down/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command/down
	install -m 444 ${WORKDIR}/media/audio-command/go/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command/go
	install -m 444 ${WORKDIR}/media/audio-command/left/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command/left
	install -m 444 ${WORKDIR}/media/audio-command/off/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command/off
	install -m 444 ${WORKDIR}/media/audio-command/right/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command/right
	install -m 444 ${WORKDIR}/media/audio-command/stop/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command/stop
	install -m 444 ${WORKDIR}/media/audio-command/up/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/media/audio-command/up
	install -m 444 ${WORKDIR}/models/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/models
	install -m 444 ${WORKDIR}/prices/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/prices
	install -m 555 ${B}/rz-edge-ai-demo ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}
	${WORKDIR}/populate_scripts.sh ${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}
	install -m 555 ${B}/scripts/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}/scripts
}

FILES_${PN} = " \
	${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY} \
"

INSANE_SKIP_${PN} = "dev-deps dev-so"
