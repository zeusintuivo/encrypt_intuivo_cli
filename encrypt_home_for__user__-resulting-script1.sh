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



