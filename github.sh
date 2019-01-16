#!/bin/bash

set +x

GITHUB="https://api.github.com"

# Exit the script with an error
function die() {
	echo >&2 "$@"
	exit 1
}

# Check if we have curl available
function check_dependencies() {
	[ -e "/usr/bin/curl" ] || die "No curl binary was installed to /usr/bin/curl, please install using your package manager"
}

# Build repo url
function build_repo_base_url() {
	OWNER="${1}"
	REPO="${2}"
	echo "${GITHUB}/repos/${OWNER}/${REPO}"
}

# Build label url
function build_repo_label_url() {
	OWNER="${1}"
	REPO="${2}"
	LABEL="${3}"
	REPO_BASE_URL=$(build_repo_base_url ${OWNER} ${REPO})
	echo "${REPO_BASE_URL}/labels/${LABEL}"
}

# Ensure labels are correctly set up
function ensure_label_exists() {
	OWNER="${1}"
	REPO="${2}"
	LABEL="${3}"
	DESCRIPTION="${4}"
	COLOR="${5}"
	LABEL_URL=$(build_repo_label_url ${OWNER} ${REPO} ${LABEL})
	DATA="{ \"name\": \"${LABEL}\", \"description\": \"${DESCRIPTION}\", \"color\": \"${COLOR}\" }"
	echo "Ensuring label is correctly set up ${LABEL_URL}"
	curl --user "${USERNAME}:${PASSWORD}" -f -s "${LABEL_URL}" > /dev/null
	if [ $? -eq 0 ] ; then
		echo -n "Label does exist, updating ... "
		REPO_BASE_URL=$(build_repo_base_url ${OWNER} ${REPO})
		curl --user "${USERNAME}:${PASSWORD}" -s -X PATCH --data "${DATA}" "${LABEL_URL}" > /dev/null
	else
		echo -n "Label does not exist, creating ... "
		REPO_BASE_URL=$(build_repo_base_url ${OWNER} ${REPO})
		curl --user "${USERNAME}:${PASSWORD}" -s -X POST --data "${DATA}" "${REPO_BASE_URL}/labels" > /dev/null
	fi 
	echo "OK"
}

# Build blob url
function build_repo_contents_url() {
	OWNER="${1}"
	REPO="${2}"
	FILE="${3}"
	REPO_BASE_URL=$(build_repo_base_url ${OWNER} ${REPO})
	echo "${REPO_BASE_URL}/contents/${FILE}"
}

# Ensure that an ISSUE_TEMPLATE.md file exists in .github
function ensure_issue_template_exists() {
	OWNER="${1}"
	REPO="${2}"
	FILE=".github/ISSUE_TEMPLATE.md"
	CONTENTS_URL=$(build_repo_contents_url ${OWNER} ${REPO} ${FILE})
	curl --user "${USERNAME}:${PASSWORD}" -f -s "${CONTENTS_URL}" > /dev/null
	if [ $? -eq 0 ] ; then
		echo "Project already has ${FILE}, not updating"
	else
		echo -n "Importing ${FILE} to project ... "
		FILE_PATH="${BASH_SOURCE%/*}/ISSUE_TEMPLATE.md"
		CONTENT=$(cat ${FILE_PATH}; printf x); CONTENT=${CONTENT%x}
		ENCODED_CONTENT=$(echo "${CONTENT}" | base64)
		DATA="{ \"message\": \"Default ISSUE_TEMPLATE.md file\", \"content\": \"${ENCODED_CONTENT}\", \"branch\": \"master\" }"
		echo "${DATA}" | curl --user "${USERNAME}:${PASSWORD}" -s -X PUT -d @- "${CONTENTS_URL}" > /dev/null
		echo "OK"
	fi
}

check_dependencies

[ $# -eq 2 ] || die "usage ${0} <username> <repo-name>"

read -p "Username: " USERNAME
read -s -p "Password: " PASSWORD
echo ""

OWNER="${1}"
REPO="${2}"

echo "Ensuring ${OWNER}/${REPO} is correctly set up"

ensure_label_exists "${OWNER}" "${REPO}" improve-story "The story is not complete and requires further improvement." e53bb8
ensure_issue_template_exists "${OWNER}" "${REPO}"

PASSWORD=""