# :penguin: Elementary OS Install utility

Easy-to-use utility that installs [Elementary OS][] on your Mac and
helps you boot it. This documentation is for beta 6.0.1

![][]

## Instructions:

### I make a number of assumptions about your Mac

1.  I assume it’s fairly recent, with a core-i3/i5/i7 processor (64-bit
    EFI only) - hackintosh not officially supported

2.  I assume you do not have Filevault or Bootcamp turned on. If you do,
    this app will work but you’ll probably be unable to boot without
    repairs.

3.  I assume your Mac’s low-level partition setup is relatively
    standard. If you haven’t gone far out of your way to change it, it
    is. I assume your ESP is at /dev/disk0s1, and you have at least one
    Mac partition.

#### Installation:

1.  [Download][] the app and open it

2.  Click “Full install” and click OK to get started, then enter an
    admin name and password

3.  Choose how much space to give Elementary OS in GB (Gigabytes) -
    slightly more than this much will be lost from your Mac and given to
    Elementary OS

## App Guide:

Elementary OS Install Utility is divided into four main functions. These
four functions will prepare your Mac for Elementary OS. The "Full
install” button partitions your computer with space for Elementary and
the installer, installs the boot picker, adds the Elementary installer,
and offers to print these instructions.

#### Partition

Before installing Elementary OS, you’ll need to give it a place to
install to. This step shrinks your Mac partition, and adds an empty
partition for Elementary OS and an empty partition for the Elementary OS
Installer. You should not perform this step multiple times; if your Mac
is partitioned already and you’d like to remove the partitions, you
should use Disk Utility.

#### Install Boot picker

When you turn on your Mac, the boot picker will ask you whether you want
to boot Elementary OS or OS X. If you’ve already installed the boot
picker, it’ll upgrade it to the latest version. If you stop seeing the
boot picker (for example, after updating your Mac) hold the option key
while booting, boot into OS X, open this app and run this step again.

#### Add installer

You’ll need an Elementary OS ISO file downloaded from the [Elementary
OS][] website. The ISO file must be at least version Freya (0.3). This
step must be run after partitioning; it will put the installer onto the
Elementary OS installer partition.

#### Erase installer

This step will remove the installer created in the “Add installer” step
and format the partition so you don’t see the option to install
Elementary OS every time you turn on your Mac.

## Building from source:

Should support OOTB building from source using Xcode ≥6

## Credits:

See HUMANS.md

## Technical Details:

Elementary OS Install Utility is a Cocoa-Applescript App created using
Xcode. It uses mostly shell scripts to perform its tasks.

## Boring stuff:

This tool is licensed under the file contained in LICENSE.md. The
following non-legalese does not represent a contract and LICENSE.md
takes priority:

I will not prosecute, sue, or send grumpy emails to anyone using any
part of this project for a fully open-source project. I ask that you
mention me in credits, or your README, or somewhere like that if you do
use this. If you make money with this, it's cool as long as you've made
some changes. You absolutely may not sell this on its own. By using this
project you surrender your immortal souls, now and forevermore, to Me
and Me alone. They shall be claimable within one week of notification by
Me or any divine or mortal representative of Me.

  [Elementary OS]: http://elementaryos.org
  []: http://cl.ly/image/0c3Q2a2u2Y1y/Screen%20Shot%202014-08-26%20at%2012.15.19%20PM.png
  [Download]: http://cl.ly/3Y022Q1b3E2m/download/Elementary%20OS%20Install%20utility.app.zip
