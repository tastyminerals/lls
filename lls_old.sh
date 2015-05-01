#!/bin/sh

#lls v1.0.1
# "lls" is a sript that works as "ls" with additional info on files spiced with some fancy colors.
# You can config your own colors in ~/.llsrc

#color table
black="30;2"
dark_gray="30;1"
blue="34;2"
light_blue="34;1"
green="32;2"
light_green="32;1"
cyan="36;2"
light_cyan="36;1"
red="31;2"
light_red="31;1"
purple="35;2"
light_purple="35;1"
yellow="33;2"
light_yellow="33;1"
light_gray="37;2"
white="37;1"

#color config
if [ -f /home/$USER/.llsrc ]; then
	source /home/$USER/.llsrc
else 
	echo -e "
# lls colour config:
# 
# Avaliable colours:
# black, dark_gray
# blue, light_blue
# green, light_green
# cyan, light_cyan
# red, light_red
# purple, light_purple
# yellow, light_yellow
# light_gray, white
#
# The lls defaults are set already for convenience. 
# You can add the desired colour after \"=\$\"
# choose your lls mode: \"newbie\" or \"su\" (Note that there is no \"\$\" sign after \"=\")
lls_mode=newbie

#File additional info colour
all_prop=\$dark_gray

#Searchable(owned) directory colors
o_dir=\$light_blue
o_dir_tag=\$light_cyan

#Not searchable(owned) directory colors
c_dir=\$red
c_dir_tag=\$light_red

#Readable and(-a) writable file colors
fo_file=\$green
fo_tag=\$light_green

#Readable writable and(-a) executable file colors
fox_file=\$yellow
fox_tag=\$light_yellow

#Executable only file colors
fc_file=\$red
fc_tag=\$light_red

#Executable and(-a) read only file colors
fsx_file=\$red
fsx_tag=\$light_red

#Read only file colors
fso_file=\$red
fso_tag=\$light_red

#Executable and(-a) writable only file colors
fex_file=\$purple
fex_tag=\$light_purple

#Writable only file colors
feo_file=\$purple
feo_tag=\$light_purple

#Not writable readable and(-a) executable file colours
fz_file=\$dark_gray
fz_tag=\$dark_gray" > /home/$USER/.llsrc
	source /home/$USER/.llsrc
fi

if [ $lls_mode = "newbie" ]; then
	label1="DIR open"
	label2="DIR closed"
	label3="FILE open"
	label4="FILE open X"
	label5="FILE closed X"
	label6="FILE seen X"
	label7="FILE seen only"
	label8="FILE edit X"
	label9="FILE edit only"
	lable0="FILE zombie"
	
elif [ $lls_mode = "su" ]; then
	label1="DRWX"
	label2="D---"
	label3="-RW-"
	label4="-RWX"
	label5="---X"
	label6="-R-X"
	label7="-R--"
	label8="--WX"
	label9="--W-"
label0="----"
else 
	echo "please, provide a valid TAG mode in ~/.llsrc!"
exit 0
fi

colorize()
{
	color="$1"
	str="$2"
	echo -e "\033[${color};148m${str}\033[39m"
#	tput sgr0
}

filter_x () {
	if [ $SHOW_X -eq 1 -a $lls_mode  = "newbie" ]; then
		grep -E 'FILE (DRWX|-RWX|---X|-R-X|--WX|closed|seen|edit|open) X'
	elif [ $NO_X -eq 1 -a $lls_mode  = "newbie" ]; then
		grep -E -v 'FILE (DRWX|-RWX|---X|-R-X|--WX|closed|seen|edit|open) X'
	elif [ $SHOW_X -eq 1 -a $lls_mode  = "su" ]; then
		grep -E '(DRWX|-RWX|---X|-R-X|--WX|closed|seen|edit|open)'
	elif [ $NO_X -eq 1 -a $lls_mode  = "su" ]; then
		grep -E -v '(DRWX|-RWX|---X|-R-X|--WX|closed|seen|edit|open)'	
	else
		cat
	fi 	
}

######################################################################

add_file_props()
{
	if [ $ADD_FILE_PROPS -eq 1 ]; then
		echo -ne "$1"
	fi
	echo ""
	tput sgr0
}

######################################################################
file_cnt ()
{
	files=$(find "$fname" -maxdepth 1 -type f | wc -l)
	dirs=$(find "$fname" -maxdepth 1 -type d | wc -l)
	tab=$tab$customtab
	echo -e "($((dirs-1)) dirs, $files files)"
	
}

findfunc ()
{
	shift
	
	tab=${tab#:}$customtab
	for fname in $@; do
		echo -e "$tab\___\033[34;1;148m${fname##*/}\033[39m \033[30;1;148m`file_cnt`\033[39m"
		
		if [ -d "$fname" ]; then
			findfunc $(find "$fname" -maxdepth 1 -type d \( ! -iname ".*" \) | sort )
		
		fi
		
	done
	tab=${tab%"$customtab"}
}

tree_loop ()
{
	for fname in $cmd_filt_dirs; do
		
		fname=${fname##${PWD}/}
		echo -e "\033[34;1;148m$fname\033[39m \033[30;6;148m`file_cnt`\033[39m" 
#	tput sgr0
		if [ -d $fname -a $fname != $curdir ]; then
			findfunc $(find "$fname" -maxdepth 1 -type d \( ! -iname ".*" \) | sort)
			
		fi
	
	unset dir singletab tab
	done

}
######################################################################
filter_types ()
{
	eval $cmd_list_files | 
	while read files; do
		file=$(file $files | awk "/$type_c$type_pic$type_m$type_doc$type_au/")
		if [ ! -z $file ]; then
			file=${file%%:*}
			file_info $file
		fi
	done
	exit 0
}
######################################################################

file_info ( )
{
	file=$1
	
	# dont bother computing stuff we will not use
	if [ $ADD_FILE_PROPS -eq 1 ]; then
		file_prop=$(file -b "$file")
		file_size=$(ls -lh "$file" | awk '{print " "$5}')
	fi
	
	fname=${file##$PWD/}
	
	# about directories
	if [ -d "$file" ]; then
		if [ -x "$file" ]; then
			echo -n `colorize "$o_dir" "$fname"`
			echo -n `colorize "$o_dir_tag" " > $label1"`
			tput sgr0
			add_file_props " `colorize "$all_prop" "{$file_prop}"`"
		else
			echo -n `colorize "$c_dir" "$fname"`
			echo -n `colorize "$c_dir_tag" " > $label2"`
			tput sgr0
			add_file_props " `colorize "$all_prop" "{$file_prop}"`"
		fi
	fi

	# about files
	if [ -f "$file" ]; then
		
		if [ -r "$file" -a -w "$file" -a ! -x "$file" ]; then
			echo -n `colorize "$fo_file" "$fname"`
			echo -n `colorize "$fo_tag" " > $label3"`
			tput sgr0
			add_file_props " `colorize "$all_prop" "{$file_prop}$file_size"`"
	
		elif [ ! -w "$file" -a ! -r "$file" -a -x "$file" ]; then
#			echo -ne "\033[31;2;148m${fname}\033[39m \033[31;1;148m> ${label}\033[39m"
#			add_file_props " \033[30;5;148m{$file_prop}$file_size\033[39m"
			echo -n `colorize "$fc_file" "$fname"`
			echo -n `colorize "$fc_tag" " > $label5"`
			tput sgr0
			add_file_props " `colorize "$all_prop" "{$file_prop}$file_size"`"

		elif [ -w "$file" -a -r "$file" -a -x "$file" ]; then
#			echo -ne "\033[33;2;148m${fname}\033[39m \033[33;1;148m> ${label}\033[39m"
#			add_file_props " \033[30;5;148m{$file_prop}$file_size\033[39m"
			echo -n `colorize "$fox_file" "$fname"`
			echo -n `colorize "$fox_tag" " > $label4"`
			tput sgr0
			add_file_props " `colorize "$all_prop" "{$file_prop}$file_size"`"

		elif [ ! -w "$file" -a -r "$file" -a -x "$file" ]; then
#			echo -ne "\033[31;2;148m${fname}\033[39m \033[31;1;148m> ${label}\033[39m"
#			add_file_props " \033[30;5;148m{$file_prop}$file_size\033[39m"
			echo -n `colorize "$fsx_file" "$fname"`
			echo -n `colorize "$fsx_tag" " > $label6"`
			tput sgr0
			add_file_props " `colorize "$all_prop" "{$file_prop}$file_size"`"

		elif [ -w "$file" -a ! -r "$file" -a -x "$file" ]; then
#			echo -ne "\033[35;2;148m${fname}\033[39m \033[35;1;148m> ${label}\033[39m"
#			add_file_props " \033[30;5;148m{$file_prop}$file_size\033[39m"
			echo -n `colorize "$fex_file" "$fname"`
			echo -n `colorize "$fex_tag" " > $label8"`
			tput sgr0
			add_file_props " `colorize "$all_prop" "{$file_prop}$file_size"`"

		elif [ -w "$file" -a ! -r "$file" -a ! -x "$file" ]; then
#			echo -ne "\033[35;2;148m${fname}\033[39m \033[35;1;148m> ${label}\033[39m"
#			add_file_props " \033[30;5;148m{$file_prop}$file_size\033[39m"
			echo -n `colorize "$feo_file" "$fname"`
			echo -n `colorize "$feo_tag" " > $label9"`
			tput sgr0
			add_file_props " `colorize "$all_prop" "{$file_prop}$file_size"`"

		elif [ ! -w "$file" -a -r "$file" -a ! -x "$file" ]; then
#			echo -ne "\033[31;2;148m${fname}\033[39m \033[31;1;148m> ${label}\033[39m"
#			add_file_props " \033[30;5;148m{$fil     m e_prop}$file_size\033[39m"
			echo -n `colorize "$fso_file" "$fname"`
			echo -n `colorize "$fso_tag" " > $label7"`
			tput sgr0
			add_file_props " `colorize "$all_prop" "{$file_prop}$file_size"`"

		elif [ ! -w "$file" -a ! -r "$file" -a ! -x "$file" ]; then
#			echo -ne "\033[30;2;148m${fname}\033[39m \033[30;1;148m> ${label}\033[39m"
#			add_file_props " \033[30;5;148m{$file_prop}$file_size\033[39m"
			echo -n `colorize "$fz_file" "$fname"` 
			echo -n `colorize "$fz_tag" " > $label0"`
			tput sgr0
			add_file_props " `colorize "$all_prop" "{$file_prop}$file_size"`"
		fi
	fi
}

######################################################################

usage() {
	tput sgr0

	echo -e "
 Usage: lls [OPTION] PATH
 \"lls\" is a sript that works as \"ls\" with additional info on files spiced with some fancy colors.
 You can config your own colors in ~/.llsrc

 OPTIONS: 
   -h, --help, -help shows this help
   -e, list extra file information
   
   -a, list all files and directories
   -f, list files only
   -d, list directories only
   -x, list executable files only
   -X, list all except executable and hidden files
   -c, list all compressed (archived) files
   -p, list all images only
   -v, list all video files only
   -t, list all text files or documents only
   -u, list all audio files only
   --tree, make a pretty tree of folders
      
 SCRIPT TAGS:
  `colorize "34;2" "DIR open"` -- means that user can search into this directory.
  `colorize "31;2" "DIR closed"` -- means that user can't search into this directory.
  `colorize "32;2" "FILE open"` -- means that this file is writable and readable.
  `colorize "33;2" "FILE open X"` -- means that this file is writable, readable and executable.
  `colorize "31;2" "FILE closed X"` -- means that this file is executable only.
  `colorize "31;2" "FILE seen X"` -- means that this file is readable and executable, but not writable.
  `colorize "35;2" "FILE edit X"` -- means that this file is writable and executable, but not readable.
  `colorize "35;2" "FILE edit only"` -- means that this file is writable only.
  `colorize "31;2" "FILE seen only"` -- means that this file is readable only.
  `colorize "30;1" "FILE zombie"` -- means that this file is not writable, readable or executable.
"
	tput sgr0
}


######################################################################

ADD_FILE_PROPS=0
LIST_ALL=0
LIST_FILES=0
LIST_DIRS=0
SHOW_X=0
NO_X=0
TREE=0
LIST_PIC=0
LIST_ARC=0
LIST_M=0
LIST_DOC=0
LIST_AU=0
FILT=0

customtab=":\t"
IFS="
"

# TODO: does not work for combined short options: -ab
while [ $# -ne 0 ]; do
	case $1 in
	-a)
		LIST_ALL=1
		;;
	-e) 
		ADD_FILE_PROPS=1
		;;
	-f)
		LIST_FILES=1
		;;
	-d)
		LIST_DIRS=1
		;;
	-x)
		SHOW_X=1
		;;
	-X)
		NO_X=1
		;;
	-h|--help|-help)
		usage
		exit 0
		;;
	--tree)
		TREE=1
		;;
	-c)
		LIST_ARC=1
		FILT=1
		;;
	-p)
		LIST_PIC=1
		FILT=1
		;;
	-v)
		LIST_M=1
		FILT=1
		;;
	-t)
		LIST_DOC=1
		FILT=1
		;;
	-u)
		LIST_AU=1
		FILT=1
		;;
	*)
		break
		;;
	esac
	shift
done

curdir=$1
if [ -z "$curdir" ]; then
	curdir=$PWD
elif [ -f "$curdir" ]; then
	file_info "$curdir"
exit 0
elif [ ! -n "$curdir" ]; then
	echo "Can't see it here"
fi

cmd_filt_dirs='find "$curdir" -maxdepth 1 -type d \( ! -iname ".*" \) | sort '
cmd_filt_files='find "$curdir" -maxdepth 1 -type f \( ! -iname ".*" \) | sort '

cmd_unfilt_dirs='find "$curdir" -maxdepth 1 -type d | sort '
cmd_unfilt_files='find "$curdir" -maxdepth 1 -type f | sort '

cmd_list_dirs=$cmd_filt_dirs
cmd_list_files=$cmd_filt_files

if [ $LIST_ALL -eq 1 ]; then
	cmd_list_dirs=$cmd_unfilt_dirs
	cmd_list_files=$cmd_unfilt_files
fi

if [ $TREE = 1 ]; then
	cmd_filt_dirs=$(find "$curdir" -maxdepth 1 -type d \( ! -iname ".*" \) | sort)
	tree_loop
	exit 0
fi

if [ $LIST_FILES -eq 0 -a $LIST_DIRS -eq 0 ]; then
true
elif [ $LIST_FILES -eq 0 ]; then
	cmd_list_files=""
elif [ $LIST_DIRS -eq 0 ]; then
	cmd_list_dirs=""
fi
if [ $LIST_ARC -eq 1 ]; then
	type_c="Archive|archive|compressed"
fi
if [ $LIST_PIC -eq 1 ]; then
	type_pic="Image|image"
fi
if [ $LIST_M -eq 1 ]; then
	type_m="Video|video|Matroska|matroska|3GPP|3GPP2|AVC|movie|MPEG sequence|RealMedia"
fi
if [ $LIST_DOC -eq 1 ]; then
	type_doc="Document|document|Text|text|ASCII"
fi
if [ $LIST_AU -eq 1 ]; then
	type_au="Audio|AAC|FLAC"
fi

if [ $FILT -eq 1 -a $SHOW_X -ne 1 -a $NO_X -ne 1 ]; then
	filter_types
	eval $cmd_list_dirs | 
	while read files; do
		file_info "$files" 
	done
	exit 0
elif [ $SHOW_X -ne 1 -a $NO_X -ne 1 ]; then
	eval $cmd_list_dirs | 
	while read files; do
		file_info "$files" 
	done
fi
	eval $cmd_list_files |
	while read files; do
	file_info "$files"
done | filter_x

