FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/:"

SRC_URI_append_hihope-rzg2m = " file://usb_video_class.cfg"
SRC_URI_append_ek874 = " file://usb_video_class.cfg"

SRC_URI_append = " \
	file://0007-ov5645-Add-VGA-720x480-and-720p-resloutions.patch \
	file://0008-ov5645-Add-pixel-rate-support-for-each-mode.patch \
	file://0009-media-i2c-ov5645-Add-support-for-SVGA.patch \
	file://0010-media-i2c-ov5645-Add-AF-support.patch \
"
