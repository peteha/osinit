#!/bin/bash
echo "### Init Process Starting ###"
echo "## Setting Up OS Build Directory ##"
# Create Base DIR
mkdir -p /opt/osbuild
cd /opt/osbuild
##
echo "## Installing Scripts ##"
curl -fs https://raw.githubusercontent.com/peteha/labosinit/main/osinit.sh --output osinit.sh
chmod +x osinit.sh
curl -fs https://raw.githubusercontent.com/peteha/labosinit/main/certbuild.sh --output certbuild.sh
chmod +x certbuild.sh
##
if [ ! -f hostbuild.env ]; then
    echo "## No hostbuild.env file available ##"
    curl -fs https://raw.githubusercontent.com/peteha/labosinit/main/hostbuild.env --output hostbuild.env
    nano hostbuild.env
fi
echo "## Scripts Installed - remove /opt/osbuild/hostbuild.env to reset ##"
echo "## Using hostbuild.env ##"
source hostbuild.env

echo "## Setting variable ##"
cur_tz=`cat /etc/timezone`
fullhn="$buildhostname.$domain"

echo "## Building For $fullhn ##"

if [[ $buildhostname == "" ]]; then
    echo "## No hostname set - check hostbuild.env ##"
    exit
fi
echo
echo "## Setting Up Environment ##"
echo "## Create new User $username ##"
if id "$username" &>/dev/null; then
    echo -n "Enter new password for $username (blank to leave the same): "
    read -s passwd
    newuser=""
else
    echo -n "Enter Password for $username: "
    read -s passwd
    newuser=True
fi
echo
echo "## Adding new User $username ##"
if [ ! -z ${newuser} ]; then
	echo "## Adding User '$username' ##"
	useradd $username --create-home --shell /bin/bash --groups sudo
	echo "$username:$passwd" | sudo chpasswd
fi
echo
echo "## Setting sudo for new user $username ##"
if [[ "$sudoers" == "True" ]]
    then
		# Set no sudo passwd
        if sudo grep -Fxq "$username ALL=(ALL) NOPASSWD: ALL" /etc/sudoers
            then
                echo "## Already SUDO ##"
                ##
            else
                echo "Set SUDO Happening for $username"
                sudo echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        fi
fi
echo
echo "## Setting up Packages ##"
if [[ $saltminion == "True" ]]; then
    inst_pkgs=$inst_pkgs" salt-minion"
fi

if [[ $inst_cockpit == "True" ]]; then
    inst_pkgs=$inst_pkgs" cockpit"
fi

if [[ $inst_ntp == "True" ]]; then
    inst_pkgs=$inst_pkgs" ntp"
fi

if [[ $raspi == "True" ]]; then
        sudo apt update
        if [[ $dietpi == "True" ]]; then
            sudo apt install $inst_pkgs -y
        fi
fi
echo
