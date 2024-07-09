# TwoTrees SK1 Upgrade guide
The Twotrees SK1 is a good printer but it really lacks user-friendlyness. However, it's a great base to make a super fast 3D printer thanks to its hardware.
This repository aims to help you to make upgrades and improvements on your Twotrees SK1.

Beware, it still needs you to have the required skills in Klipper and requires some soldering skills.

This guide is based upon SK1 v2.02 firmware.

# Upgrade Klipper
If you want to upgrade Klipper on the SK1 to the latest release, you will need to be able to flash the toolhead board (TH board) first.
So don't go any further if you aren't able to do it (read the next section to know how to do it).

KIAUH is pre-installed on the board, so everything you need to do is login to the printer with SSH using the following credentials :
```
User : mks
Password : makerbase
```

First, we will save Twotrees modifications on Moonraker and Klipper :
```
cd ~/klipper
git stash
cd ~/moonraker
git stash
sudo chown -R mks:mks ~/klipper_config
```

In the console, launch KIAUH :
```
./kiauh/kiauh.sh
```

Upgrade it when you are asked to, relaunch it and select Upgrade to upgrade your installation.

# Upgrade the mainboard
Now that Klipper is up to date, we can flash the mainboard with it.
Type the following commands :

```
cd ~/klipper
make menuconfig
```

Select the options as the following screenshot :

![Mainboard config](https://github.com/tomsbasement/twotrees-sk1/blob/main/images/mb-klipper-config.png?raw=true)

Then type :
```
make
mv ~/klipper/out/klipper.bin ~/printer_data/
```

![USB header](https://github.com/tomsbasement/twotrees-sk1/blob/main/images/usb-header.jpg?raw=true)

You will have to migrate your configuration to new config folders :

```
cp ~/klipper_config/* ../printer_data/config/
```

Move the bin file to configuration :

```
cp ~/klipper/out/klipper.bin ~/printer_data/config/
```

Download the klipper.bin file using Fluidd, move it to a microSD card and rename it to mks_skipr_mini.bin
Switch the printer off.
Put the microSD card to the mainboard.
Switch the printer on and wait for it to boot, then remove the microSD card.

# Upgrade the TH board
The TH board is communicating by USB with the mainboard. It isn't supplied with a USB connector so in order to update it, you will have to solder a header on it.
I have chosen a JST connector that I soldered directly on the "USB" header.
Once done, I salvaged a USB cable in order to crimp a male JST connector on it.

USB cables are repecting a color scheme so respect it and everything will be OK. If it doesn't work, reverse your JST connector because some USB cables are inverted (mine was).

![USB color scheme](https://github.com/tomsbasement/twotrees-sk1/blob/main/images/usb-color-scheme.jpg?raw=true)

![USB header](https://github.com/tomsbasement/twotrees-sk1/blob/main/images/usb-header.jpg?raw=true)

Disconnect the main cable on top of the board. The printer will beep (it's annoying but normal).

![Flash the board, step 1](https://github.com/tomsbasement/twotrees-sk1/blob/main/images/flash-step-1.jpg?raw=true)

Boot the board in flash mode by pressing the boot button and then plugging the USB cable :

![Flash the board, step 2](https://github.com/tomsbasement/twotrees-sk1/blob/main/images/flash-step-2.jpg?raw=true)

Compile Klipper for the THB :
```
cd ~/klipper
make menuconfig
```

Choose the following configuration :
![THB config](https://github.com/tomsbasement/twotrees-sk1/blob/main/images/thb-klipper-config.png?raw=true)

Flash the board :
```
make
sudo service klipper stop
make flash FLASH_DEVICE=/dev/serial/by-id/usb-Klipper_stm32f401xc_500021001451313430333633-if00
sudo service klipper start
```

Restart the printer and everything should be up to date !