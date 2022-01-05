#!/bin/bash

DEF_OWNER="<user>"

function print_help {
	if [[ $1 ]]; then
		echo -e "[!] Error: $1\n"
	fi
	echo "#######################################"
	echo "########## Gitea Repo Init ############"
	echo "#######################################"
	echo -e "Uses gitea's tea application to create a repo and intialize the current directory as a repo\n"
	echo -e "\t-n|--name\t\tSet the name of the repo. Defaults to the current folder name."
	echo -e "\t-o|--owner\t\tSet the org-owner of the repo. Defaults to the DEF_OWNER in the script."
	echo -e "\t-d|--dir\t\tSet the working directory. This will cd into that folder to complete the init."
	echo -e "\t-a|--all\t\tCommit all files in the folder into the repo."
	echo -e "\t-di|--dont-init\t\tDon't initialize the repo with git. Will just output the repo link."
	echo -e "\t-dc|--dont-commit\tDon't commit the repo with git. Will init and setup origin but won't commit."
}

function print_error {
	if [[ $1 ]]; then
		echo -e "[!] Error: $1"
	fi
}

while [[ $# -gt 0 ]]; do
	key="$1"

	case $key in
		-h|--help|--h)
			print_help
			exit
			;;
		-n|--name)
			REPO_NAME=$2
			shift
			shift
			;;
		-o|--owner)
			REPO_ASUSER=0
			REPO_OWNER=$2
			shift
			shift
			;;
		-d|--dir)
			REPO_DIRECTORY=$2
			shift
			shift
			;;
		-a|--all)
			ADD_ALL=1
			shift
			;;
		-di|--dont-init)
			DONT_INIT=1
			shift
			;;
		-dc|--dont-commit)
			DONT_COMMIT=1
			shift
			;;
	esac
done

if [[ ! -z $REPO_DIRECTORY ]]; then
	cd $REPO_DIRECTORY
fi

if [[ -d .git ]]; then
	print_error "A .git directory already exists within '$(pwd)'."
	exit
fi

if [[ -z $REPO_NAME ]]; then
	## Get the current folder name to set the repo name
	REPO_NAME=$(pwd | rev | cut -d '/' -f 1 | rev)
	echo -e "[+] Repo name not set. Using folder name: '$REPO_NAME'."
fi

if [[ -z $REPO_OWNER ]]; then
	## Set the defualt user
	REPO_OWNER="$DEF_OWNER"
	REPO_ASUSER=1
	echo -e "[+] Owner not set using default user: '$REPO_OWNER'"
fi

if [[ ! -z $REPO_ASUSER ]]; then
	echo "[-] Attempting to create repo as user..."	
	TEA_CMD="tea repos create --name $REPO_NAME"
else
	echo "[-] Attempting to create repo as org..."
	TEA_CMD="tea repos create --owner $REPO_OWNER --name $REPO_NAME"
fi
REPO_CREATED=$($TEA_CMD 2>&1 | grep Error)

if [[ ! -z $REPO_CREATED ]]; then
	print_error "Unable to create repo! ($(echo $REPO_CREATED | sed -E "s/Error\:\s//g"))."
	exit
fi

echo "[+] Repo created successfully!"
REPO_ORIGIN=$(tea repos search $REPO_NAME | grep $REPO_NAME | cut -d '|' -f 5 | sed -E "s/\s//g")

if [[ ! -z $DONT_INIT ]]; then
	echo "[+] Repo Origin: $REPO_ORIGIN"
	exit
fi

echo "[-] Initializing repo..."
git init
if [[ ! -f README.md ]]; then
	echo "# $REPO_NAME" > README.md
fi

echo "[-] Adding origin ($REPO_ORIGIN)"
git remote add origin $REPO_ORIGIN

if [[ -z $DONT_COMMIT ]]; then
	if [[ ! -z $ADD_ALL ]]; then
		echo "[-] Commiting Readme..."
		git add README.md
	else
		echo "[-] Commiting all files..."
		git add .
	fi
	git commit -m "Initial Commit"
	git push -u origin master
fi

