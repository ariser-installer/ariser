#!/bin/bash
#set -e
##################################################################################################################
# Author 	: Erik Dubois
# Website   : https://www.erikdubois.be
# Website   : https://www.alci.online
# Website	: https://www.arcolinux.info
# Website	: https://www.arcolinux.com
# Website	: https://www.arcolinuxd.com
# Website	: https://www.arcolinuxb.com
# Website	: https://www.arcolinuxiso.com
# Website	: https://www.arcolinuxforum.com
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################
#tput setaf 0 = black 
#tput setaf 1 = red 
#tput setaf 2 = green
#tput setaf 3 = yellow 
#tput setaf 4 = dark blue 
#tput setaf 5 = purple
#tput setaf 6 = cyan 
#tput setaf 7 = gray 
#tput setaf 8 = light blue
##################################################################################################################

echo
echo "################################################################## "
tput setaf 2
echo "Phase 1 : "
echo "- Setting General parameters"
tput sgr0
echo "################################################################## "
echo

	isoLabel='archlinux-'$(date +%Y.%m.%d)'-x86_64.iso'

	# setting of the general parameters
	archisoRequiredVersion="archiso 73-1"
	buildFolder=$HOME"/Ariser-build"
	outFolder=$HOME"/Ariser-Out"
	archisoVersion=$(sudo pacman -Q archiso)

	echo "################################################################## "
	echo "Do you have the right archiso version? : "$archisoVersion
	echo "What is the required archiso version?  : "$archisoRequiredVersion
	echo "Build folder                           : "$buildFolder
	echo "Out folder                             : "$outFolder
	echo "################################################################## "

	if [ "$archisoVersion" == "$archisoRequiredVersion" ]; then
		tput setaf 2
		echo "##################################################################"
		echo "Archiso has the correct version. Continuing ..."
		echo "##################################################################"
		tput sgr0
	else
	tput setaf 1
	echo "###################################################################################################"
	echo "You need to install the correct version of Archiso"
	echo "Use 'sudo downgrade archiso' to do that"
	echo "or update your system"
	echo "###################################################################################################"
	tput sgr0
	#exit 1
	fi

echo
echo "################################################################## "
tput setaf 2
echo "Phase 2 :"
echo "- Checking if archiso is installed"
echo "- Making mkarchiso verbose"
tput sgr0
echo "################################################################## "
echo

	package="archiso"

	#----------------------------------------------------------------------------------

	#checking if application is already installed or else install with aur helpers
	if pacman -Qi $package &> /dev/null; then

			echo "Archiso is already installed"

	else

		#checking which helper is installed
		if pacman -Qi yay &> /dev/null; then

			echo "################################################################"
			echo "######### Installing with yay"
			echo "################################################################"
			yay -S --noconfirm $package

		elif pacman -Qi paru &> /dev/null; then

			echo "################################################################"
			echo "######### Installing with paru"
			echo "################################################################"
			paru -S --noconfirm --needed --noedit $package

		fi

		# Just checking if installation was successful
		if pacman -Qi $package &> /dev/null; then

			echo "################################################################"
			echo "#########  "$package" has been installed"
			echo "################################################################"

		else

			echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			echo "!!!!!!!!!  "$package" has NOT been installed"
			echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			exit 1
		fi

	fi

	echo
	echo "Making mkarchiso verbose"
	sudo sed -i 's/quiet="y"/quiet="n"/g' /usr/bin/mkarchiso

echo
echo "################################################################## "
tput setaf 2
echo "Phase 3 :"
echo "- Deleting the build folder if one exists"
echo "- Copying the Archiso folder to build folder"
echo "- Cloning ALIS"
tput sgr0
echo "################################################################## "
echo

	echo "Deleting the build folder if one exists - takes some time"
	[ -d $buildFolder ] && sudo rm -rf $buildFolder
	echo
	echo "Copying the Archiso folder to build work"
	echo
	mkdir $buildFolder
	cp -r /usr/share/archiso/configs/releng/ $buildFolder/archiso
	echo
	echo "Git clone ALIS"
	mkdir $buildFolder/archiso/airootfs/alis
	git clone https://github.com/ariser-installer/alis $buildFolder/archiso/airootfs/alis
	
	echo "Git clone ALIS-DEV"
	mkdir $buildFolder/archiso/airootfs/alis-dev
	git clone https://github.com/ariser-installer/alis-dev $buildFolder/archiso/airootfs/alis-dev

echo
echo "################################################################## "
tput setaf 2
echo "Phase 4 :"
echo "- Adding packages to the pgklist"
tput sgr0
echo "################################################################## "
echo

	echo
	echo "Adding more packages to the list"
	echo "git" | tee -a $buildFolder/archiso/packages.x86_64

echo
echo "################################################################## "
tput setaf 2
echo "Phase 5 : "
echo "- Adding time to /etc/dev-rel"
echo "- profile.def"
echo "- nanorc for syntax"
echo "- alis script"
tput sgr0
echo "################################################################## "
echo

	echo "Adding time to /etc/dev-rel"
	date_build=$(date -d now)
	touch $buildFolder/archiso/airootfs/etc/dev-rel
	echo "Arch Linux iso build on : "$date_build | tee -a $buildFolder/archiso/airootfs/etc/dev-rel

	FIND='livecd-sound'
	REPLACE='  ["/alis/start.sh"]="0:0:755"'
	find $buildFolder/archiso/profiledef.sh -type f -exec sed -i "/$FIND/a $REPLACE" {} \;

	FIND='livecd-sound'
	REPLACE='  ["/alis-dev/start.sh"]="0:0:755"'
	find $buildFolder/archiso/profiledef.sh -type f -exec sed -i "/$FIND/a $REPLACE" {} \;

	echo "copy nanorc"
	cp nanorc $buildFolder/archiso/airootfs/etc/nanorc

	echo "copy alis"
	mkdir -p $buildFolder/archiso/airootfs/usr/bin
	cp alis $buildFolder/archiso/airootfs/usr/bin/alis

	FIND='livecd-sound'
	REPLACE='  ["/usr/bin/alis"]="0:0:755"'
	find $buildFolder/archiso/profiledef.sh -type f -exec sed -i "/$FIND/a $REPLACE" {} \;

	echo "copy alis-dev"
	mkdir -p $buildFolder/archiso/airootfs/usr/bin
	cp alis-dev 	$buildFolder/archiso/airootfs/usr/bin	

	FIND='livecd-sound'
	REPLACE='  ["/usr/bin/alis-dev"]="0:0:755"'
	find $buildFolder/archiso/profiledef.sh -type f -exec sed -i "/$FIND/a $REPLACE" {} \;

#echo
#echo "################################################################## "
#tput setaf 2
#echo "Phase 6 :"
#echo "- Cleaning the cache from /var/cache/pacman/pkg/"
#tput sgr0
#echo "################################################################## "
#echo

	#echo "Cleaning the cache from /var/cache/pacman/pkg/"
	#yes | sudo pacman -Scc

echo
echo "################################################################## "
tput setaf 2
echo "Phase 7 :"
echo "- Building the iso - this can take a while - be patient"
tput sgr0
echo "################################################################## "
echo

	[ -d $outFolder ] || mkdir $outFolder
	cd $buildFolder/archiso/
	sudo mkarchiso -v -w $buildFolder -o $outFolder $buildFolder/archiso/

echo
echo "###################################################################"
tput setaf 2
echo "Phase 8 :"
echo "- Creating checksums"
echo "- Copying pgklist"
tput sgr0
echo "###################################################################"
echo

	cd $outFolder

	echo "Creating checksums for : "$isoLabel
	echo "##################################################################"
	echo
	echo "Building sha1sum"
	echo "########################"
	sha1sum $isoLabel | tee $isoLabel.sha1
	echo "Building sha256sum"
	echo "########################"
	sha256sum $isoLabel | tee $isoLabel.sha256
	echo "Building md5sum"
	echo "########################"
	md5sum $isoLabel | tee $isoLabel.md5
	echo
	echo "Moving pkglist.x86_64.txt"
	echo "########################"
	cp $buildFolder/iso/arch/pkglist.x86_64.txt  $outFolder/$isoLabel".pkglist.txt"

echo
echo "##################################################################"
tput setaf 2
echo "DONE"
echo "- Check your out folder :"$outFolder
tput sgr0
echo "################################################################## "
echo
