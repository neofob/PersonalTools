# Classify a git commit
# classify_git_commit commit_name
# print out
# 	Branch:	origin/commit_name
#	Tag:	commit_name
#	Commit:	commit_name
function classify_git_commit()
{
	# Check if commit_name is a branch name
	git branch -a | grep $1 >&1 >/dev/null
	RESULT=$?
	if [ $RESULT = 0 ]; then
		echo "origin/$1"
	else
		echo $1
	fi
}
