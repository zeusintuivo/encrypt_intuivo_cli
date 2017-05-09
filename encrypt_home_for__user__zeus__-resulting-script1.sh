#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
dato=$(date) ; echo "time start script:$dato " > time.log
    _notify() {
        local MSG="${@}"
        echo -e " "
        echo -e "\033[38;5;208m ${MSG} \e[0m"
        echo -e " "
        zenity --info --title="Mr.Encrypter" --text="${MSG}" 2> /dev/null  # Remove Gtk-Message: GtkDialog mapped without a transient parent. This is discouraged

    }
    _mininfo() {
        echo -e "\033[38;5;23m • \033[38;5;30m ${@}  \e[0m "
    }
    _miniwarning() {
        echo -e " "
        echo -e " \033[38;5;214m WARNING! ${@} \e[0m"
        echo -e " "
    }
    _info() {
        local MSG="${@}"
        _mininfo """${MSG}"""
        zenity --info --title="Mr.Encrypter" --text "${MSG}" 2> /dev/null   # Remove Gtk-Message: GtkDialog mapped without a transient parent. This is discouraged
    }
    _subinfo() {>> time.log
        echo -e " "
        echo -e "\033[38;5;93m+---\033[38;5;227m  ${@}  \e[0m "
        echo -e " "
    }
    _error_kill() {
        local MSG="${@}"
        echo -e " "
        echo -e " \033[38;5;1m ERROR! \e[0m ${MSG} \033[38;5;1m! \e[0m"
        echo -e " \033[38;5;208m Killing the script \e[0m"
        echo -e " "
        zenity --error  --title="Mr.Encrypter"  --text=" ${MSG} ...Killing the script " 2> /dev/null  # Remove Gtk-Message: GtkDialog mapped without a transient parent. This is discouraged
        exit 130
    }



_notify This script will encrypt home folder for zeus

check_params() {

    _mininfo Checking for Elevated Root Permisions
    [ "$EUID" -ne 0 ] &&  _error_kill Please run as root

    _mininfo Checking if you are root
    WHOWHO=$(whoami)
    [[ "${WHOWHO}" != "root" ]] && _error_kill Please     run as root: Whoami says you are: $WHOWHO


} # end function check_params
check_params $*
dato=$(date) ; echo " +-- time start zip:$dato " >> time.log

backup_zeus() {
    _info Backup home directory for zeus
    sudo mkdir -p /_/user-backups
    sudo chown -R zeus:zeus /_/user-backups
    #sudo tar jcvf /_/user-backups/zeus-home-directory-backup.tar.bz2 /home/zeus | split -b 670MB - /_/user-backups/
    sudo zip -vy -s 670m /_/user-backups/zeus-home-directory-backup.zip -r /home/zeus
    dato=$(date) ; echo " +-- time end zip:$dato " >> time.log
    wait
    (( $? != 0 )) && _error_kill Back homedir for zeus did not complete correctly
}
backup_zeus



encrypt_homedir_and_swap_for_zeus_now() {
    # REF: https://www.howtogeek.com/116032/how-to-encrypt-your-home-folder-after-installing-ubuntu/
    _info Killing all processes for zeus.
    sudo pkill -9 -u zeus
    wait
    dato=$(date) ; echo " +-- time start encrypt:$dato " >> time.log
    _info Encrypting home folder for: zeus ...This might take a while
    sudo ecryptfs-migrate-home -u zeus
    (( $? != 0 )) && _error_kill Encrypting homedir for zeus did not complete correctly
    dato=$(date) ; echo " +-- time end encrypt:$dato " >> time.log
    _info Encrypting home swap folder ...This might take a while
    sudo ecryptfs-setup-swap
    (( $? != 0 )) && _error_kill Encrypting swap did not complete correctly

}
encrypt_homedir_and_swap_for_zeus_now

check_if_home_for_zeus_is_encrypted() {
    # REF: http://askubuntu.com/questions/146511/how-to-check-if-your-home-folder-and-swap-partition-are-encrypted-using-terminal
    _info Checking if home folder for  zeus is encrypted
    [ ! -d /home/zeus/.ecryptfs/ ] && _error_kill Encrypted folder was not found
}
check_if_home_for_zeus_is_encrypted

check_if_swap_is_encrypted() {
    # REF: http://askubuntu.com/questions/146511/how-to-check-if-your-home-folder-and-swap-partition-are-encrypted-using-terminal
    _info Checking if swap is encrypted
    ( ! sudo blkid | grep swap | grep cryptswap ) && _error_kill Encrypted swap failed
}
check_if_swap_is_encrypted

create_self_executing_script_to_delete_mrencrypter() {
    sudo mkdir -p /home/zeus/.config/autostart/
    sudo touch /home/zeus/.config/autostart/remove_mrencrypter.desktop
    sudo chown -R zeus:zeus /home/zeus/.config/autostart/remove_mrencrypter.desktop


    sudo echo "[Desktop Entry]
Type=Application
Exec=gksudo -k -u root /home/zeus/remove_mrencrypter.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Remove user mrencrypter
Name=Remove user mrencrypter
Comment[en_US]=Remove user mrencrypter
Comment=Remove user mrencrypter
    " > /home/zeus/.config/autostart/remove_mrencrypter.desktop


    # Create remove mrencrypter script
    sudo touch /home/zeus/remove_mrencrypter.sh
    sudo chmod +x /home/zeus/remove_mrencrypter.sh
    sudo chown -R zeus:zeus /home/zeus/remove_mrencrypter.sh
    sudo echo "#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#

    _notify() {
        local MSG=\"\${@}\"
        echo -e \" \"
        echo -e \"\\033[38;5;208m \${MSG} \\e[0m\"
        echo -e \" \"
        zenity --info --title=\"Mr.Encrypter\" --text=\"\${MSG}\" 2> /dev/null  # Remove Gtk-Message: GtkDialog mapped without a transient parent. This is discouraged

    }
    _mininfo() {
        echo -e \"\\033[38;5;23m • \\033[38;5;30m \${@}  \\e[0m \"
    }
    _miniwarning() {
        echo -e \" \"
        echo -e \" \\033[38;5;214m WARNING! \${@} \\e[0m\"
        echo -e \" \"
    }
    _info() {
        local MSG=\"\${@}\"
        _mininfo \"\"\"\${MSG}\"\"\"
        zenity --info --title=\"Mr.Encrypter\" --text \"\${MSG}\" 2> /dev/null   # Remove Gtk-Message: GtkDialog mapped without a transient parent. This is discouraged
    }
    _subinfo() {
        echo -e \" \"
        echo -e \"\\033[38;5;93m+---\\033[38;5;227m  \${@}  \\e[0m \"
        echo -e \" \"
    }
    _error_kill() {
        local MSG=\"\${@}\"
        echo -e \" \"
        echo -e \" \\033[38;5;1m ERROR! \\e[0m \${MSG} \\033[38;5;1m! \\e[0m\"
        echo -e \" \\033[38;5;208m Killing the script \\e[0m\"
        echo -e \" \"
        zenity --error  --title=\"Mr.Encrypter\"  --text=\" \${MSG} ...Killing the script \" 2> /dev/null  # Remove Gtk-Message: GtkDialog mapped without a transient parent. This is discouraged
        exit 130
    }

_notify This script destroy the created user Mr.Encrypter out of your system

_info Logout new user mrencrypter
sudo pkill -9 -u mrencrypter
wait
! pkill -9 -u mrencrypter && _mininfo nothing
(( \$? != 0 )) && _error_kill Failed logging mrencrypter. You will have to delete it manually... Sorry!!

_info Deleting user mrencrypter with its home folder
# REF: http://askubuntu.com/questions/12180/logging-out-other-users-from-the-command-line
# REF: http://www.tecmint.com/delete-remove-a-user-account-with-home-directory-in-linux/
( command -v deluser >/dev/null 2>&1; ) && [ -d  /home/mrencrypter/ ] && deluser --remove-home mrencrypter
( command -v userdel >/dev/null 2>&1; ) && [ -d  /home/mrencrypter/ ] && userdel --remove mrencrypter
[ ! -d  /home/mrencrypter/ ] && _mininfo Folder and user mrencrypter removed
(( \$? != 0 )) && _error_kill Failed to remove mrencrypter user and home folder


_notify Self remove these scripts
nohup rm /home/mrencrypter/.config/autostart/encrypt_home_for_zeus.desktop
nohup rm /home/zeus/remove_mrencrypter.sh


" > /home/zeus/remove_mrencrypter.sh

}
create_self_executing_script_to_delete_mrencrypter
dato=$(date) ; echo "time end script:$dato " >> time.log
logout_current_user_mrencrypter() {
    _notify You will be log out of this user. Then DO NOT TURN OFF YOUR BOX, Login to your user zeus for encryption to finish
    nohup gnome-session-save --force-logout
    wait
    #sudo pkill -9 -u zeus
    wait
}
logout_current_user_mrencrypter

exit
##LOG
➜  encrypt_intuivo_cli git:(master) ✗ date
Fr 5. Mai 09:15:25 CEST 2017

## LOG
 This script will encrypt home folder for zeus

 •  Checking for Elevated Root Permisions
 •  Checking if you are root
 •  Backup home directory for zeus
  adding: home/zeus/    (in=0) (out=0) (stored 0%)
  adding: home/zeus/.profile    (in=655) (out=378) (deflated 42%)
  adding: home/zeus/.bash_logout    (in=220) (out=158) (deflated 28%)
  adding: home/zeus/.bashrc (in=3771) (out=1740) (deflated 54%)
total bytes=4646, compressed=2276 -> 51% savings
 •  Killing all processes for zeus.
 •  Encrypting home folder for: zeus ...This might take a while
INFO:  Checking disk space, this may take a few moments.  Please be patient.
INFO:  Checking for open files in /home/zeus
lsof: WARNING: can't stat() fuse.gvfsd-fuse file system /run/user/1000/gvfs
      Output information may be incomplete.
Enter your login passphrase [zeus]:

************************************************************************
YOU SHOULD RECORD YOUR MOUNT PASSPHRASE AND STORE IT IN A SAFE LOCATION.
  ecryptfs-unwrap-passphrase ~/.ecryptfs/wrapped-passphrase
THIS WILL BE REQUIRED IF YOU NEED TO RECOVER YOUR DATA AT A LATER TIME.
************************************************************************


Done configuring.

chown: cannot access '/dev/shm/.ecryptfs-zeus': No such file or directory
INFO:  Encrypted home has been set up, encrypting files now...this may take a while.
sending incremental file list
./
.bash_logout
            220 100%    0.00kB/s    0:00:00 (xfr#1, to-chk=2/4)
.bashrc
          3,771 100%    3.60MB/s    0:00:00 (xfr#2, to-chk=1/4)
.profile
            655 100%  639.65kB/s    0:00:00 (xfr#3, to-chk=0/4)
Could not unlink the key(s) from your keying. Please use `keyctl unlink` if you wish to remove the key(s). Proceeding with umount.

========================================================================
Some Important Notes!

 1. The file encryption appears to have completed successfully, however,
    zeus MUST LOGIN IMMEDIATELY, _BEFORE_THE_NEXT_REBOOT_,
    TO COMPLETE THE MIGRATION!!!

 2. If zeus can log in and read and write their files, then the migration is complete,
    and you should remove /home/zeus.s0yGJZ9c.
    Otherwise, restore /home/zeus.s0yGJZ9c back to /home/zeus.

 3. zeus should also run 'ecryptfs-unwrap-passphrase' and record
    their randomly generated mount passphrase as soon as possible.

 4. To ensure the integrity of all encrypted data on this system, you
    should also encrypt swap space with 'ecryptfs-setup-swap'.
========================================================================

 •  Encrypting home swap folder ...This might take a while

WARNING:
An encrypted swap is required to help ensure that encrypted files are not leaked to disk in an unencrypted format.

HOWEVER, THE SWAP ENCRYPTION CONFIGURATION PRODUCED BY THIS PROGRAM WILL BREAK HIBERNATE/RESUME ON THIS SYSTEM!

NOTE: Your suspend/resume capabilities will not be affected.

Do you want to proceed with encrypting your swap? [y/N]: y

INFO: Setting up swap: [/dev/dm-1]
WARNING: Commented out your unencrypted swap from /etc/fstab
swapon: stat of /dev/mapper/cryptswap1 failed: No such file or directory

  ERROR!  Encrypting swap did not complete correctly !
  Killing the script

➜  encrypt_intuivo_cli git:(master) ✗ cat /etc/crypttab
# <target name> <source device>     <key file>  <options>
cryptswap1 UUID=d7b74486-fd93-4d74-870f-4261a4826b5d /dev/urandom swap,offset=1024,cipher=aes-xts-plain64
➜  encrypt_intuivo_cli git:(master) ✗ ls -l /dev/disk/by-uuid/
total 0
lrwxrwxrwx 1 root root 10 Mai  2 14:28 08391481-64df-45b0-bbf0-90ccf3ca1bb7 -> ../../sda1
lrwxrwxrwx 1 root root 10 Mai  2 14:28 3a67710c-2733-4345-8c62-bc512e988556 -> ../../dm-0
lrwxrwxrwx 1 root root 10 Mai  5 09:12 d7b74486-fd93-4d74-870f-4261a4826b5d -> ../../dm-1
➜  encrypt_intuivo_cli git:(master) ✗ cat /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
/dev/mapper/ubuntu--gnome--vg-root /               ext4    errors=remount-ro 0       1
# /boot was on /dev/sda1 during installation
UUID=08391481-64df-45b0-bbf0-90ccf3ca1bb7 /boot           ext2    defaults        0       2
#/dev/mapper/ubuntu--gnome--vg-swap_1 none            swap    sw              0       0
/dev/mapper/cryptswap1 none swap sw 0 0
➜  encrypt_intuivo_cli git:(master) ✗



CHROME PAGES:

https://github.com/webpack/webpack/issues/1736
https://github.com/webpack/webpack/issues/2771
https://github.com/bestander/uglify-loader
file:///_/journals/weise/DGT-99_minimal_form_2/v3_form_work_on_chrome_files/public/index.html
https://github.com/babel/babel-loader/issues/299
http://mimosa.io/configuration.html#watch
http://underscorejs.org/#template
https://bootstrapbay.com/blog/bootstrap-button-styles/
http://codepen.io/anon/pen/MmvdwL
https://css2sass.herokuapp.com/
http://edgeguides.rubyonrails.org/asset_pipeline.html
https://cdnjs.com/libraries/jquery
https://tympanus.net/Development/TextInputEffects/index2.html
https://carbonads.net/
https://tympanus.net/codrops/adpacks/demoadpacks.css
https://tympanus.net/Tutorials/CustomDropDownListStyling/index.html
https://askubuntu.com/questions/462775/swap-not-working-on-clean-14-04-install-using-encrypted-home