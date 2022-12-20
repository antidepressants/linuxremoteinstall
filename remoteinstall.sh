#!/bin/bash

install(){
	if [ -x "/usr/bin/yum" ]
	then
		yum install $@
	elif [ -x "/usr/bin/apt" ]
	then
		apt install $@
	elif [ -x "/usr/bin/pacman" ]
	then
		pacman -S $@
	elif [ -x "/usr/bin/emerge" ]
	then
		emerge -a $@
	else
		echo "Couldn't detect package manager"
	fi
}

copy(){
	sshpass -p "$4" scp -o "StrictHostKeyChecking=no" $1 $3@$2:/tmp
	sshpass -p "$4" ssh -o "StrictHostKeyChecking=no" $3@$2 "chmod +x /tmp/$1"
}

run(){
	locali=6
	packages=""
	while (( $locali <= $# ))
	do
		packages="$packages ${!locali}"
		locali=$((locali+1))
	done
	sshpass -p "$5" ssh -o "StrictHostKeyChecking=no" $4@$3 "/tmp/$1 --local $packages"
}

case $1 in
	--help)
		echo "Usage: $0 [Option] [IP] [Username] [Password] [Package]...
    Options:
      --remote: Install packages on remote server, requires IP address, username, and password
      --local: Install packages on this machine
      --help: Show this"
		;;
	--remote)
		copy $0 $2 $3 $4
		run $0 $@
		;;
	--local)
		i=2
		args=""
		while (( $i <= $# ))
		do
			args="$args ${!i}"
			i=$((i+1))
		done
		install $args
		;;
  *)
    echo "Unrecognized option '$1'"
    echo "Try '$0 --help' for more information"
    ;;
esac
