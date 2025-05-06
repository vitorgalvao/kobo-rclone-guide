# Sync Files to the Kobo with Rclone

This guide documents how to install Rclone on a Kobo device and how to run it to download files from [any sync service it supports](https://rclone.org/#providers). Steps should be followed in order.

> [!CAUTION]
> Some technical knowledge is required. You should at a minimum not be afraid of the terminal.

> [!NOTE]
> Though this method has served me well, I no longer use it and won’t offer support if you get stuck. But I will consider fixes and improvements like correcting outdated links.

## Install NickelMenu and NickelDBus

1. Install [NickelDBus](https://shermp.github.io/NickelDBus/).
2. Install [NickelMenu](https://pgaskin.net/NickelMenu/).
3. After reboot, move the [accompanying NickelMenu configuration](./files/config) to `/mnt/onboard/.adds/nm/config`.

> [!TIP]
> `/mnt/onboard` is the Kobo root folder when mounted as a volume on your computer. In other words, after connecting the Kobo to your computer, the top folder you have access to is `/mnt/onboard`.

## Install Rclone

### On Your Computer

1. Install [Rclone](https://rclone.org/) and configure it. Set aside the resulting `~/.config/rclone/rclone.conf`.
2. [Download](https://rclone.org/downloads/) and unpack the ARMv7 - 32 Bit Linux version of Rclone. Set aside the `rclone` binary.
3. Download the most recent [CA certificate](https://curl.se/docs/caextract.html). Set aside the `cacert.pem`.
4. Make the [accompanying Sync Script](./files/sync.sh) executable. Edit the top section as needed. Set it aside.

### On the Kobo

Create a `/mnt/onboard/.adds/onlinepull` directory. Copy into it the assests you set aside before:

1. `rclone.conf`
2. `rclone`
3. `cacert.pem`
4. `sync.sh`

## Automatically Sync When Connecting to Wi-Fi

> [!WARNING]
> This step is **optional**. It requires fiddling with system files on the Kobo and can make the script trigger more often than intended.

To trigger the sync script automatically whenever the Kobo connects to Wi-Fi, move the [accompanying Udev Rules](./files/97-rcloud.rules) to `/etc/udev/rules.d/97-rcloud.rules`.

> [!NOTE]
> `/etc/udev/rules.d` is inaccessible when connecting the Kobo to a computer; you’ll need to connect in a way that gives you access to its full file system. Telnet is recommended as the simplest way, but instructions on that fall outside the scope of this guide.

## Usage

You’re now ready to download files to your Kobo with Rclone. Use the Nickel Menu on the bottom right to either Pull (download everything which is not on the Kobo) or Sync (same as Pull, then also deletes from the Kobo anything which has been deleted from the file provider).
