#!/bin/bash

set -eu

owner="apitrace"
repo="apitrace"
workflow=build
branch=master

# https://stackoverflow.com/questions/60789862/url-of-the-last-artifact-of-a-github-action-build

# https://stackoverflow.com/a/65163515

# Needs public_repo 
token="$GITHUB_TOKEN"

jq=$(which jq)

jq_ () {
	"$jq" "$@"
}

curl_ () {
    echo "Requesting $@" 1>&2
    curl -s \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $token" \
        "$@"
}

curl_ "https://api.github.com/repos/${owner}/${repo}/actions/workflows/${workflow}.yml/runs?per_page=1&branch=${branch}&event=push&status=success" > workflow.json

# https://docs.github.com/en/rest/reference/actions#list-artifacts-for-a-repository
curl_ "https://api.github.com/repos/${owner}/${repo}/actions/artifacts" > artifacts.json

artifacts_url=$(jq_ -r '.workflow_runs[0].artifacts_url' workflow.json)

curl_ "${artifacts_url}" > artifact.json


mkdir -p _site/download

dl_ () {
    name=$1
    file=$2

    echo "Fetching artifact $name" 1>&2

    archive_download_url=$(jq_ -r ".artifacts[] | select(.name==\"${name}\") | .archive_download_url" artifact.json)

    echo "Downloading ${archive_download_url}" 1>&2
    # XXX: Use -H 'Accept: application/octet-stream' ?
    curl -s -L -H "Authorization: token $token" -z $name.zip -o .$name.zip ${archive_download_url}

    echo "Extracting $file from artifact $name" 1>&2
    unzip -q -o .$name.zip $file -d _site/download

    mv .$name.zip $name.zip
}

dl_ apitrace-ubuntu-18.04 apitrace-latest-Linux.tar.bz2
dl_ apitrace-ubuntu-arm64 apitrace-latest-Linux-arm64.tar.bz2
dl_ apitrace-win32-x86 apitrace-latest-win32.7z
dl_ apitrace-win64-x86 apitrace-latest-win64.7z
dl_ apitrace-win64-arm apitrace-latest-win64-arm.7z


exit 0
