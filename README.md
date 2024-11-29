# TwoTrees SK1 Upgrade guide
The Twotrees SK1 is a good printer but it really lacks user-friendlyness. However, it's a great base to make a super fast 3D printer thanks to its hardware.
This repository aims to help you to make upgrades and improvements on your Twotrees SK1.

Beware, it still needs you to have the required skills in Klipper and requires some soldering skills.
**Please note that this guide requires knowledge of Linux systems, and that you should be comfortable modifying machines. I decline all responsibility if you break your machine. I won't be able to help you either, as I no longer own the SK1.**

This guide is based upon SK1 v2.02 firmware and is brought to you by [Tom's Basement](https://www.youtube.com/@TomsBasement/), my YouTube channel. So if you find it useful, consider supporting my work by subscribing to it !

- [TwoTrees SK1 Upgrade guide](#twotrees-sk1-upgrade-guide)
- [Revert to stock firmware](#revert-to-stock-firmware)
- [Upgrade Klipper](#upgrade-klipper)
- [Upgrade the mainboard](#upgrade-the-mainboard)
- [Upgrade the TH board](#upgrade-the-th-board)
- [Fans relocation](#fans-relocation)
- [Armbian 12](#armbian-12)
- [Change system timezone](#change-system-timezone)
- [Update WiFi settings without screen](#update-wifi-settings-without-screen)
- [Simple hardware upgrades](#simple-hardware-upgrades)
  - [Put a high-flow nozzle](#put-a-high-flow-nozzle)
  - [Change the PSU](#change-the-psu)

# Revert to stock firmware
If you encounter any issue during upgrade process, you can revert back to TwoTrees stock firmware : https://wiki.twotrees3d.com/en/3DPrinterSeries/SK1#%E6%89%93%E5%8D%B0%E8%AE%BE%E7%BD%AE-3
Then flash Klipper on your mainboard (with the old version provided by TwoTrees you have to put in the microSD card) and your toolhead board without upgrading Klipper before.
Note : No help will be provided here if you crash your printer, you are 100% responsible of your actions.

# Upgrade Klipper
If you want to upgrade Klipper on the SK1 to the latest release, you will need to be able to flash the toolhead board (TH board) first.
So don't go any further if you aren't able to do it (read the next section to know how to do it).

KIAUH is pre-installed on the board, so everything you need to do is login to the printer with SSH using the following credentials :
```
User : mks
Password : makerbase
```

First, we will save Twotrees modifications on Moonraker and Klipper and update them :
```
sudo sed -i 's|deb http://deb.debian.org/debian buster-backports|deb http://archive.debian.org/debian buster-backports|' /etc/apt/sources.list
sudo sed -i 's|deb-src http://deb.debian.org/debian buster-backports|deb-src http://archive.debian.org/debian buster-backports|' /etc/apt/sources.list
cd ~/klipper
git stash
cd ~/moonraker
git stash
./scripts/install-moonraker.sh -r -f -c /home/pi/klipper_config/moonraker.conf
sudo sed -i 's|MOONRAKER_CONFIG_PATH="/home/mks/klipper_config/moonraker.conf"|MOONRAKER_CONFIG_PATH="/home/mks/printer_data/config/moonraker.conf"|' printer_data/systemd/moonraker.env
cp ~/klipper_config/* ~/printer_data/config/
sudo service moonraker restart
sudo chown -R mks:mks ~/klipper_config
```

In the console, launch KIAUH :
```
./kiauh/kiauh.sh
```

Upgrade it when you are asked to, relaunch it and select Upgrade to upgrade your installation.

You can finish by rebooting the system :
```
sudo reboot
```

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
The TH board is communicating by UART with the mainboard. It isn't supplied with a USB connector so in order to update it, you will have to solder a header on it.
I have chosen a JST-XH 2.54 (4 pins) connector that I soldered directly on the "USB" header.
Once done, I salvaged a USB cable in order to crimp a male JST connector on it.

USB cables are repecting a color scheme so respect it and everything will be OK. If it doesn't work, reverse your JST connector because some USB cables are inverted (mine was).

![USB color scheme](https://github.com/tomsbasement/twotrees-sk1/blob/main/images/usb-color-scheme.jpg?raw=true)

![USB header](https://github.com/tomsbasement/twotrees-sk1/blob/main/images/usb-header.jpg?raw=true)

![USB plug](https://github.com/tomsbasement/twotrees-sk1/blob/main/images/jst-xh-usb.jpg?raw=true)

Disconnect the main cable on top of the board. The printer will beep (it's annoying but normal).

![Flash the board, step 1](https://github.com/tomsbasement/twotrees-sk1/blob/main/images/flash-step-1.jpg?raw=true)

Boot the board in flash mode by pressing the boot button and then plugging the USB cable to the board and to the printer.

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
sudo make flash FLASH_DEVICE=2e8a:0003
sudo service klipper start
```

Unplug the TH board and restart the printer. Everything should be up to date !

# Fans relocation
I relocated the board and exhaust fans that are always on to controllable fan ports.
Those ports are used for side fan and for the enclosure fan.
As I don't use the enclosure, I decided to lower the noise of that printer.

Crimp a JST-XH 2.54 (2 pins) connector to the mainboard fans.

Plug it to fan0 port.
Plug exhaust fan to fan1 port.

![Fans plugs](https://github.com/tomsbasement/twotrees-sk1/blob/main/images/fans-relocation.jpg?raw=true)

In your printer.cfg, comment everything related to PC9 and PC12 pins :

```
#[fan_generic fan2]
#pin: PC9

#[fan_generic fan3]
#pin: PC12
```

Put this configuration instead :

```
[controller_fan controller_fan]
pin: PC9
kick_start_time: 0.5
heater: heater_bed
stepper: stepper_x,stepper_y,stepper_z,stepper_z1,stepper_z2,extruder

[heater_fan exhaust_fan]
pin: PC12
max_power: 0.8
shutdown_speed: 0.0
kick_start_time: 5.0
heater: heater_bed
heater_temp: 65
fan_speed: 1.0
```

# Armbian 12
TwoTrees SK1 is provided with a fairly outdated firmware and OS : Armbian 10 with Klipper v0.10.
A lot of improvements have been made since then and that printer can benefit from those progresses.
If you successfuly upgraded your Klipper installation, you can test Armbian 12.
I share with you my raw image you can use to upgrade your system.
Note that due to incompatibilities, the screen is not working, you will have to use an additional remote screen like [BTT K-Touch](https://shrsl.com/4m9iq).
Please read carefully the release notes : https://github.com/tomsbasement/twotrees-sk1/releases/tag/v0.1

This image is based on the wonderful [Armbian MKSPI project](https://github.com/redrathnure/armbian-mkspi), thanks for making it possible!

# Change system timezone
By default, system time is set in Asia. You can change your timezone by setting it like this :

```
sudo timedatectl set-timezone Europe/Brussels
```

Adapt "Europe/Brussels" by your local timezone. You can obtain the list of available timezones with the following command :

```
timedatectl list-timezones
```

# Update WiFi settings without screen
If for any reason you lost the ability to use the screen and need to connect to a WiFi network, follow this :

First, connect the printer using an ethernet cable to your network. Once it is done and you got a connection (check your router to get the IP), connect to it in SSH.

Then edit the wpa_supplicant file :

```
sudo nano /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
```

It should contain the following information :

```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=BE

network={
        ssid="your-network-ssid"
        psk="your-network-password"
        key_mgmt=WPA-PSK
}
```

Change "country" by your country ISO.
Change ssid by your network ssid
Change psk by your netork password.

Then reboot the machine :

```
sudo reboot
```

# Simple hardware upgrades
The SK1 is capable of really fast printing but it needs some help in order to reach its full potential. Some simple hardware upgrades can be done :

## Put a high-flow nozzle
The nozzle is only able to reach 21mm3/s with a 0.4 nozzle. Which is correct but not enough to use the maximum acceleration of the printer when trying to break 3D Benchy speed records 😁
So I decided to swap it to a "cht clone" you can find here : [CHT clone for Bambu Lab hotend](https://s.click.aliexpress.com/e/_DEY6PtD)

![Meanwell PSU](https://github.com/tomsbasement/twotrees-sk1/blob/main/images/high-flow-nozzle.png?raw=true)

Thanks to that nozzle, you will be able to reach 26mm3/s with a 0.4 nozzle !

## Change the PSU
The PSU shipped with the printer is loud. Once the fan kicks in, it never stops.
I decided to change it by an original Meanwell PSU, not a clone.
Now the fan stops when the PSU cools down !

The reference you can buy is Meanwell LRS-350 : [Meanwell LRS-350](https://s.click.aliexpress.com/e/_DkntJw3)

![Meanwell PSU](https://github.com/tomsbasement/twotrees-sk1/blob/main/images/meanwell-lrs-350-psu.jpg?raw=true)
