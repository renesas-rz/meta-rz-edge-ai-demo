FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY ?= "/opt/rz-edge-ai-demo"

SRC_URI_append += " \
	file://populate_weston.sh \
	file://images/ \
	file://scripts/ \
"

do_install_append() {
	${WORKDIR}/populate_weston.sh ${D}/${sysconfdir}/xdg/weston/weston.ini ${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}
	install -d ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}
	install -m 444 ${WORKDIR}/images/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}
	install -m 555 ${WORKDIR}/scripts/* ${D}${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}
}

FILES_${PN} += "${RZ_EDGE_AI_DEMO_INSTALL_DIRECTORY}"
