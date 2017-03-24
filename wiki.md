The following guide will help you install Linux on the ZYBO board from Digilent.

It is based upon the workflow of [Xilinx Linux getting started guide](http://www.wiki.xilinx.com/Getting+Started).

***
# Building the Boot Files
### Prerequisites
- Working installation of Xilinx Vivado and SDK.
- ZYBO board files installed: [Installation guide](https://reference.digilentinc.com/reference/software/vivado/board-files?redirect=1)

### Fetching Sources
Start by creating a directory for all the files that will be used.
Then fetch the relevant sources:

- U-Boot: [SDU-Embedded/u-boot-xlnx](https://github.com/SDU-Embedded/u-boot-xlnx)
- Xilinx Linux Kernel 4.10 release: [zynmp-dt-fixes-for-4.10](https://github.com/SDU-Embedded/linux-xlnx/releases/tag/zynmp-dt-fixes-for-4.10)
- Device Tree generator plugin for SDK: [SDU-Embedded/device-tree-xlnx](https://github.com/SDU-Embedded/device-tree-xlnx)
- Device Tree compiler: [dtc](https://git.kernel.org/pub/scm/utils/dtc/dtc.git)

### Install and Setup of Tools
In the process of installing Linux on the ZYBO board on a fresh installation of Ubuntu 16.04, it was found necessary to install the following packages.

```bash
apt install libncurses5-dev libncursesw5-dev u-boot-tools device-tree-compiler flex libssl-dev 
```

To be able to cross compile for the ZYBO the `CROSS_COMPILE` variable has to be set for the Zynq-7000 (CodeSourcery - soft float).  The `$PATH` environment variable also has to be set correctly by exporting Xilinx `settings64.sh` file.

```bash
export CROSS_COMPILE=arm-xilinx-linux-gnueabi-
source <Xilinx installation directory>/Vivado/<version>/settings64.sh
``` 

### Build Device Tree Compiler
Navigate to the DTC source directory.
Build the device tree compiler by running `make`:

```bash
make
```
Xilinx recommends adding this directory to the `$PATH` variable:

```bash
export PATH=`pwd`:$PATH
```

### Build U-Boot
Navigate to the U-Boot source directory.
To build U-Boot for the ZYBO run the following commands:
```bash
make zynq_zybo_config
make
```
When completed the a u-boot file is created in the source directory and the `mkimage` utility is created in the `tools` directory.
The `mkimage` needs to be available when building the kernel and therefore the `tools`  directory needs to be added to the `$PATH` variable:
```bash
cd tools
export PATH=`pwd`:$PATH
```
Later the u-boot file needs to be used in Xilinx SDK and because SDK only lists files with an extension, we need to give it one. 
```bash
cp u-boot u-boot.elf
```

### Build Linux Kernel
Navigate to the Linux kernel source directory.

To build the Linux kernel correctly for the ZYBO it needs to be configured by running the following commands:

```bash
make ARCH=arm xilinx_zynq_defconfig
make ARCH=arm menuconfig
```
Exit the kernel configuration menu without doing any changes if you do not want to configure the kernel further.

Then to build the kernel image run:
```bash
make ARCH=arm UIMAGE_LOADADDR=0x8000 uImage
```
At this point you may want to fetch a cup of coffee as it may take a couple of minutes to complete.
In the process of making the `uImage` file, the U-Boot header will be added to the file.

### Create FSBL and Boot Image
Launch Vivado and create a new project with the ZYBO as board.

Create a new block design, add the `ZYNQ7 Processing System` and let Vivado do `Run block automation`.
Then add the `Processor System Reset` and do not `Run Connection Automation`.
Connect the two IP cores as shown below. Hereafter you can add all the IP cores you need
![alt text]( https://github.com/SDU-Embedded/linux_zynq/raw/master/linux_zybo/zybo_fsbl.png "ZYBO block design")

Create HDL wrapper and generate bitstream.
Export hardware including bitstream and launch SDK.
Create a new application project, give it a name, click next and choose `Zynq FSBL`.
In the project explorer pane right-click on the project folder and choose `Create Boot Image`. In the Boot image partitions section click `Add`, navigate to the U-Boot source directory and click on the `u-boot.elf` file.

The window should now look similar to the one shown below:
![alt text](https://github.com/SDU-Embedded/linux_zynq/raw/master/linux_zybo/boot_image_window.png "Create Boot Image window")

Click Create Image and after a short wait the `BOOT.bin` file is created at the specified output path.

### Build Device Tree Blob
#### Creating Device Tree Source files
Building the device tree blob can be done with the same hardware as defined in the previous section. It needs to be done in SDK with hardware and bitstream exported.

Start by downloading the `devicetree.dts` file [here](https://github.com/SDU-Embedded/linux_zynq/blob/master/linux_zybo/devicetree.dts) if you have not already cloned the [SDU-Embedded/linux_zynq](https://github.com/SDU-Embedded/linux_zynq) repository.

Click on `Xilinx Tools` -> `Repositories`. In the Local Repositories area click `New`, navigate to the `device-tree-xlnx` directory and press `OK`.
This makes the device tree generator directory available for SDK. 

Now click on `File` -> `New` -> `Board Support Package`. In the `Board Support Package OS` area click on `device_tree`. A `Board Support Package Settings` window will appear, just click `OK`.

In the project explorer pane right-click on the project directory and click on `Import`. Click `General`->`File system`, navigate to the directory of the downloaded `devicetree.dts`, click `OK`, tick the file and press `Finish`.

The `devicetree.dts` imports the Xilinx generated `system-top.dts` and sets the correct boot arguments.

#### Compiling a Device Tree Blob file
The previously built utility, device tree compiler, needs to be used to compile a device tree blob file.

Navigate to the following directory:
```bash
<project>/<project>.sdk/device_tree_bsp_0/ 
```
Compile the `devicetree.dtb` file using the `dtc` utility by running the following command:
```bash
dtc -I dts -O dtb -o devicetree.dtb devicetree.dts
```
# Creating a Bootable SD card
### Formatting the SD card
A SD card can be formatted using different tools. The command line utility [fdisk](https://wiki.archlinux.org/index.php/Fdisk) or the GUI [GParted](http://gparted.org/) are the most popular.

The SD card needs to be formatted to:
- First 4 MB unallocated
- fat16 or fat32 formatted area of at least 16 MBs, labeled BOOT
- ext4 formatted area of at least 1 GB, preferably a lot more, labeled ROOT_FS

Using GParted the SD cards partitions should look like below:
![alt text]( https://github.com/SDU-Embedded/linux_zynq/raw/master/linux_zybo/gparted.png "GParted window")

### Writing the SD card
The following files should be placed in the `BOOT` partition of the SD card:
- BOOT.bin
- devicetree.dtb
- uImage

The `ROOT_FS` partition needs to contain a Linux user space. Linaro can be used. The newest version can be found here: [latest linaro](http://releases.linaro.org/debian/images/developer-armhf/latest/).
Download the `.tar.gz` file, decompress and copy to the `ROOT_FS` partition.

# Booting the ZYBO
Put the SD card in the ZYBO, be sure to set the Programming Mode jumper to SD, connect the ZYBO to your computer with a USB cable and start a serial port communications program such as `minicom` or `socat`.
Now you can view the output of the boot process on the ZYBO.

***

Maintainers: Thomas Søndergaard Christensen <thomc12@student.sdu.dk> 
and Mikkel Skaarup Jaedicke <mijae12@student.sdu.dk>