#!/bin/sh

WESTON_FILE=${1}
RZ_EDGE_AI_INSTALL_DIR=${2}

cat >> "${WESTON_FILE}" <<-EOF

[shell]
background-type=scale
background-color=0xff002200
background-image=${RZ_EDGE_AI_INSTALL_DIR}/Renesas-Screen.jpg

[launcher]
icon=${RZ_EDGE_AI_INSTALL_DIR}/reboot.png
path=${RZ_EDGE_AI_INSTALL_DIR}/reboot.sh

[launcher]
icon=${RZ_EDGE_AI_INSTALL_DIR}/icons/rz-edge-ai-demo.png
path=${RZ_EDGE_AI_INSTALL_DIR}/scripts/rz-edge-ai-demo.sh

[output]
name=HDMI-A-1
mode=1280x720@60.0
EOF
