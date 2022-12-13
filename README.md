# RZ Edge AI Demo Yocto Layer
This OpenEmbedded/Yocto layer adds support for the Renesas FOSS (Free Open
Source Software) RZ Edge AI Demo to the RZ/G2 and RZ/G2L families of reference
platforms.

This meta-layer adds all dependencies and installs the Qt based demo application
into the final RFS. The demo itself can be compiled seperately using qmake. The
source code for the demo application can be found here:
**https://github.com/renesas-rz/rz-edge-ai-demo.git**


The demo is based on the Renesas RZ/G AI BSP which is published on GitHub:
**https://github.com/renesas-rz/meta-renesas-ai**


Supported Platforms:
- Renesas RZ/G2E ek874
- Renesas RZ/G2M hihope-rzg2m
- Renesas RZ/G2L smarc-rzg2l
- Renesas RZ/G2LC smarc-rzg2lc

## Build Instructions
**Build machine dependencies**
- Ubuntu 20.04 LTS
- Installed packages: gawk wget git-core diffstat unzip texinfo gcc-multilib
build-essential chrpath socat cpio python3 python3-pip python3-pexpect
xz-utils debianutils iputils-ping python3-git python3-jinja2
libegl1-mesa libsdl1.2-dev pylint3 xterm

1. Clone required repositories
```
export WORK=<path-to-your-build-directory>
mkdir -p $WORK
cd $WORK
git clone git://git.yoctoproject.org/poky.git
git clone git://git.openembedded.org/meta-openembedded.git
git clone git://git.yoctoproject.org/meta-gplv2.git
git clone https://github.com/meta-qt5/meta-qt5.git
git clone https://github.com/renesas-rz/meta-renesas.git
git clone https://github.com/renesas-rz/meta-renesas-ai.git
git clone https://github.com/renesas-rz/meta-rz-edge-ai-demo.git
```

2. Checkout specific versions

```
cd $WORK/poky
git checkout -b tmp bba323389749ec3e306509f8fb12649f031be152
cd $WORK/meta-openembedded
git checkout -b tmp ec978232732edbdd875ac367b5a9c04b881f2e19
cd $WORK/meta-gplv2
git checkout -b tmp 60b251c25ba87e946a0ca4cdc8d17b1cb09292ac
cd $WORK/meta-qt5
git checkout -b tmp c1b0c9f546289b1592d7a895640de103723a0305
cd $WORK/meta-renesas
git checkout -b tmp BSP-3.0.1
cd $WORK/meta-renesas-ai
git checkout -b tmp 3babcf6279e1d63c224f9f5956df493c1c69b6f8
```

3. Define machine to build for
```
export PLATFORM=<machine>
```

Replace `<machine>` with `ek874`, `hihope-rzg2m`, `smarc-rzg2l` or `smarc-rzg2lc`.

4. Download proprietary software packages from RZ/G website
```
America: https://www.renesas.com/us/en/products/microcontrollers-microprocessors/rz-mpus/rzg-linux-platform/rzg-marketplace/verified-linux-package/rzg-verified-linux-package
Europe: https://www.renesas.com/eu/en/products/microcontrollers-microprocessors/rz-mpus/rzg-linux-platform/rzg-marketplace/verified-linux-package/rzg-verified-linux-package
Asia: https://www.renesas.com/sg/en/products/microcontrollers-microprocessors/rz-mpus/rzg-linux-platform/rzg-marketplace/verified-linux-package/rzg-verified-linux-package
Japan: https://www.renesas.com/jp/en/products/microcontrollers-microprocessors/rz-mpus/rzg-linux-platform/rzg-marketplace/verified-linux-package/rzg-verified-linux-package
```

5. Add the proprietary libraries

RZ/G2L:
```
cd $WORK
unzip RTK0EF0045Z15001ZJ-v0.56_EN.zip
unzip RTK0EF0045Z13001ZJ-v1.0_EN.zip
tar -xf RTK0EF0045Z15001ZJ-v0.56_EN.zip/meta-rz-features.tar.gz
tar -xf RTK0EF0045Z13001ZJ-v1.0_EN.zip/meta-rz-features.tar.gz
```

RZ/G2LC:
```
cd $WORK
unzip RTK0EF0045Z13001ZJ-v1.0_EN.zip
tar -xf RTK0EF0045Z13001ZJ-v1.0_EN.zip/meta-rz-features.tar.gz
```

RZ/G2E and RZ/G2M
```
cd $WORK
unzip  RTK0EF0045Z0022AZJ-v1.0_EN.zip
tar -xf RTK0EF0045Z0022AZJ-v1.0_EN.zip/meta-rz-features.tar.gz
```



6. Execute source command
```
cd $WORK
source poky/oe-init-build-env
```

7. Copy build configuration files

```
cp $WORK/meta-rz-edge-ai-demo/templates/$PLATFORM/* $WORK/build/conf/
```

Enable the `LICENSE_FLAGS_WHITELIST` line in local.conf.


8. (optional) Use the following commands in `$WORK/build/conf/local.conf` to edit the demo source version:
```
RZ_EDGE_AI_DEMO_REPO = "github.com/renesas-rz/rz-edge-ai-demo.git"
RZ_EDGE_AI_DEMO_REPO_PROTOCOL = "https"
RZ_EDGE_AI_DEMO_REPO_BRANCH = "<branch_name>"
SRCREV_rz-edge-ai-demo = "<specific_commit_sha>" # Can be set to "${AUTOREV}" for the latest version.
```

9. Start build
```
bitbake core-image-qt
```

Once the build is completed, the Kernel, device tree and RFS are located in:

```
$WORK/build/tmp/deploy/images/$PLATFORM/
```

10. SDK build

```
bitbake core-image-qt -c populate_sdk
```

Once the build is completed, the SDK is located in:

```
$WORK/build/tmp/deploy/sdk/
```

### Build Script ###
A simple build script has been created to manage the build process automatically.\
Before running the script you will need to download the relevant proprietary
libraries from the Renesas website. See the Renesas RZ/G2 and RZ/G2L BSP readme
files for details on how to do this.

Run `./scripts/build.sh -h` to get an overview on how to use the script.

## Flashing instructions
### Partition and Format the SD
The SD card should be formatted to EXT4. Parted provides a terminal utility
to do this, alternatively Gnome Disks can be used from the Ubuntu GUI.

1. Install the tool
```
sudo apt update
sudo apt install parted
```

2. Identify the block device name for the SD Card, for example "/dev/sdc"
```
sudo fdisk -l
```

3. Create the partition table with an EXT4 partition
```
sudo parted /dev/sdc --script -- mklabel gpt
sudo parted /dev/sdc --script -- mkpart primary ext4 0% 100%
```

4. Format the partition to EXT4
```
sudo mkfs.ext4 -F /dev/sdc1
```

5. Confirm the partition table is set as expected
```
sudo parted /dev/sdc --script print
```

### Extract the Filesystem
Mount the root file system and extract it to the SD card
```
mount -t ext4 /dev/sdc1 /mnt/SD
sudo tar -xf core-image-qt-$PLATFORM.tar.gz -C /mnt/SD
```

### Using Wic Images
An alternative to the steps above is to use the Wic images yocto builds. A Wic
image provides a way to flash a bootable image with all the needed files.

From the host machine, flash the yocto generated Wic image with:
```
sudo bmaptool copy core-image-qt-$PLATFORM.wic.gz /dev/sdc --nobmap
```

Alernatively Windows GUI tools such as balenaEtcher can be used to flash
the SD card.

## Configuring the Platform
### Boot the Board
Make the following connections to the host machine:
* Serial

Make the following peripheral connections:
* [Coral OV5645 MIPI-CSI Camera](https://coral.ai/products/camera/) or USB webcam (RZ/G2L and RZ/G2LC)
* OmniVision OV5645 Mipi-CSI Camera or USB webcam (RZ/G2M and RZ/G2E)
* Mouse or USB touch
* HDMI
* Power

Then apply power to the board and enter U-Boot.

### Set U-Boot configuration environment
The U-Boot environment can be set from the U-boot terminal.

RZ/G2E:
```
setenv bootargs 'rw root=/dev/mmcblk0p1 rootwait'
setenv bootcmd 'ext4load mmc 0 0x48080000 boot/Image; ext4load mmc 0 0x48000000 boot/r8a774c0-ek874-mipi-2.1.dtb; booti 0x48080000 - 0x48000000'
```

RZ/G2M:
```
setenv bootargs 'rw root=/dev/mmcblk0p1 rootwait'
setenv bootcmd 'ext4load mmc 0 0x48080000 boot/Image; ext4load mmc 0 0x48000000 boot/r8a774a1-hihope-rzg2m-ex-mipi-2.1.dtb; booti 0x48080000 - 0x48000000'
```

RZ/G2L:
```
setenv bootargs 'rw root=/dev/mmcblk1p1 rootwait'
setenv bootcmd 'ext4load mmc 0 0x48080000 boot/Image; ext4load mmc 0 0x48000000 boot/r9a07g044l2-smarc.dtb; booti 0x48080000 - 0x48000000'
```

RZ/G2LC:
```
setenv bootargs 'rw root=/dev/mmcblk1p1 rootwait'
setenv bootcmd 'ext4load mmc 0 0x48080000 boot/Image; ext4load mmc 0 0x48000000 boot/r9a07g044c2-smarc.dtb; booti 0x48080000 - 0x48000000'
```

Finally, save the environment and boot:
```
saveenv
boot
```

Once Linux has booted, launch the demo from the terminal
```
/opt/rz-edge-ai-demo/rz-edge-ai-demo
```

Alternatively, use the GUI buttons on the top left to start the demo.


## How to use the demo
### Selecting Demo Mode
* Click "Demo Mode->Shopping Basket" to select the shopping basket mode.
* Click "Demo Mode->Object Detection" to select the object detection mode.
* Click "Demo Mode->Pose Estimation" to select the pose estimation mode.
* Click "Demo Mode->Face Detection" to select the face detection mode.
* Click "Demo Mode->Audio Command" to select the audio command mode.

### Object Detection Mode
* Click "Start Inference/Stop Inference" to run inference continuously.
    * Stop Inference clears the inference and FPS results and resumes live camera feed.
* Click "Load AI Model" to load a different model and label file.
* Click "Input->Load Image/Video" to load a static image or video file.

Expected results:
* Boxes are drawn around the detected objects.
* Names of detected items are shown in the top left-hand corner of each box.
* Percentage confidence is shown for each object.
* Names and count for each object are shown in an alphabetical list on the
right-hand side of the application.
* Total FPS and inference time is shown in the top right-hand corner of
the application.

### Shopping Basket Mode
* Click "Load AI Model" to load a different model, label file and prices file.
* Click "Process Basket" to capture an image from the webcam stream.
    * Inference is automatically run on the image and the results are displayed.
* Click "Next Basket" to clear inference results and resume live camera feed.
* Click "Input->Load Image" to load a static image file.

Expected results:
* Boxes are drawn around the detected items.
* Names of detected items are shown in the top left-hand corner of each box.
* Percentage confidence is shown for each item.
* Names and prices for each item are shown in an alphabetical list on the
right-hand side of the application.
* Total cost is shown in the bottom right hand-side.
* Total items and inference time is shown in the top right-hand corner of
the application.

### Pose Estimation Mode (Default)
* Click "Load AI Model" to load a different pose model. Currently supported: MoveNet,
BlazePose, HandPose.
* Click "Start Inference/Stop Inference" to run inference continuously.
* Click "Input->Load Image/Video" to load a static image or video file.

Expected results:
* BlazePose, MoveNet: Lines are drawn which connect the joints and facial features
of the detected person.
* HandPose: Lines are drawn which connect the hand-knuckle points of the detected hand.
* Total FPS and inference time is shown in the top right-hand corner of
the application.
* 2-D Point Projection of the identified pose is shown in the right-hand side of the
application.

### Face Detection Mode
* Click "Detect Face" to detect the face of the identified person.
* Click "Detect Iris" to detect the irises of the identified person.
* Click "Start Inference/Stop Inference" to run inference continuously.
* Click "Input->Load Image/Video" to load a static image or video file.

Expected results:
* Face Detection: Lines are drawn around the facial regions of the detected face.
* Iris Detection: Lines are drawn around the irises of the detected face.
* Total FPS is shown in the top right-hand corner of
the application.
* Inference time for all models used in the pipeline are shown separately
in the top right-hand corner of the application.
* Face Detection: 2-D Point Projection of the identified face mesh is shown in the
right-hand side of the application.
* Iris Detection: Diagram showing the inference pipeline from detecting the face to
identifying the iris is shown in the right-hand side of the application.

### Audio Command Mode
* Click "Talk" to run inference on the currently selected audio source.
* Click "Input->Load Audio File" to load a .wav file to run inference on.

Expected results:
* Listens to audio based direction commands (Left, Right, Up, Down) to move an arrow across a grid on screen.
* The Go command moves the arrow one position in the direction it is facing.
* The Off command reset arrow position, command history and count.
* The Stop command halts recording from the audio source.
* Inference time, command history and command count are shown on the right of the screen.

### Common Mode Settings
* Click "Input->Load Camera Feed" to return to live camera feed.
* Click "Inference Engine->TensorFlow Lite + ArmNN delegate" to run inference
using TensorFlow Lite with ArmNN delegate enabled.
* Click "Inference Engine->TensorFlow Lite + XNNPack delegate" to run inference
using TensorFlow Lite with XNNPack delegate enabled (RZ/G2L and RZ/G2LC only).
* Click "Inference Engine->TensorFlow Lite" to run inference using TensorFlow
Lite.
* Click "About->Hardware" to read the board information.
* Click "About->License" to read the GPLv2 license that this app is licensed
under.
* Click "About->Exit" to close the application.


## Notes
### OV5645 camera sensor
The CMOS camera sensor (OV5645) is no longer available, and should not be used
for mass production.\
Any software support provided is for evaluation purposes only.

This demo adds and enables auto focus for the OV5645 sensor by default.\
If you would like to diable this support, please add `DISABLE_OV5645_AF="1"` to
local.conf.
