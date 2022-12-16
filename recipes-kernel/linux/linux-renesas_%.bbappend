FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/:"

SRC_URI_append = " \
	file://0007-ov5645-Add-VGA-720x480-and-720p-resloutions.patch \
	file://0001-ov5645-Add-pixel-rate-support-for-each-mode.patch \
	file://0002-media-i2c-ov5645-Add-support-for-SVGA.patch \
	file://microphone.cfg \
"

SRC_URI_append = "${@oe.utils.conditional("DISABLE_OV5645_AF", "1", "", " file://0003-media-i2c-ov5645-Add-AF-support.patch",d)}"
