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

echo "## Setting Up Environment ##"
echo
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
