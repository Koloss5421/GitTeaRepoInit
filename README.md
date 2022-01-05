# GitTeaRepoInit

Uses Gitea's tea tool to create a repo and initialize it with a readme or your already created files.

### Requirements:
 - Gitea
 - [Gitea tea](https://gitea.com/gitea/tea)

I put this script into my path so it can be exectuted from anywhere.

Setup gitea tea with an access token. The script itself does not use the access token directly.

### Usage:

The script defaults to using the DEF_OWNER variable to create a repo of the current folder name, creates a readme and commits that readme. 

```
#######################################
########## Gitea Repo Init ############
#######################################
Uses gitea's tea application to create a repo and intialize the current directory as a repo

	-n|--name		Set the name of the repo. Defaults to the current folder name.
	-o|--owner		Set the org-owner of the repo. Defaults to the DEF_OWNER in the script.
	-d|--dir		Set the working directory. This will cd into that folder to complete the init.
	-a|--all		Commit all files in the folder into the repo.
	-di|--dont-init		Don't initialize the repo with git. Will just output the repo link.
	-dc|--dont-commit	Don't commit the repo with git. Will init and setup origin but won't commit.
```
