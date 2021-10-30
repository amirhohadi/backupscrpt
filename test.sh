#!/bin/bash

backupFilename='backup-'$(date +%Y-%m-%d-%H:%M)'.tar.bz2'
backupSaveDir=$HOME'/backup'
backupListFile='backup.list'

listOfPathes(){
	if [ $# -ne 2 ]
	then
		echo '[ERROR] listOfPathes function require two argument'
		exit 1
	fi
	local input=$1
	local -n arr=$2
	while read -r path
	do
		if [ -d $path ]
		then
			arr+=($path)
			echo '[INFO] '$path' has added to backup.'
		else
			echo '[ERROR] '$path' dosent exists.'
		fi

	done < $input
}

calcArgs(){
	if [ $# -ne 2 ]
	then
		echo '[ERROR] calcArgs function require two argument'
		exit 1
	fi
	local -n Pathes=$1
	local -n arr=$2
	for path in ${Pathes[@]}
	do
		local dirname=$(dirname $path)'/'
		local p=${path#"$dirname"}
		arr+=('-C' $dirname $p)
	done

}

archive(){
	if [ $# -ne 3 ]
	then
		echo '[ERROR] archive function take 3 arguements.'
		exit 1
	fi
	local filename=$1
	local savePath=$2
	local -n Args=$3
	if [ ${#Args[@]} -gt 0 ]
	then
		local file="$savePath/$filename"
		echo 'tar -cjvf '$file' '${Args[@]}
		tar -cjvf $file ${Args[@]}
		if [ $? -eq 0 ]
		then
			echo '[INFO] done.'
			echo "[INFO] filename:$file"
		else
			echo '[ERROR] something happend.'	
		fi
		
	else
		echo '[ERROR] backup canceled because no valid path was found.'
	fi
}

doBackup(){
	if [ ! -s $backupListFile ]
	then
		echo '[ERROR] backupListFile dosent exists.'
		exit 1
	fi

	if [ ! -d $backupSaveDir ]
	then
		echo '[INFO] Creating Backup Directory.'
		mkdir -p $backupSaveDir
		if [ $? -ne 0 ]
		then
			echo '[ERROR] Cannot Create Backup Directory.exiting...'
			exit 1
		fi
	fi

	local pathes=()
	listOfPathes $backupListFile pathes
	local args=()
	calcArgs pathes args

	archive $backupFilename $backupSaveDir args
}

doBackup
