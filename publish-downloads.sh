#!/bin/bash

set -eu -o pipefail

owner="apitrace"
repo="apitrace"
workflow=build
branch=master

# https://stackoverflow.com/questions/60789862/url-of-the-last-artifact-of-a-github-action-build

# https://stackoverflow.com/a/65163515

# Needs public_repo 
if [[ ! -v GITHUB_TOKEN ]]
then
    echo 'error: must set GITHUB_TOKEN to a https://github.com/settings/personal-access-tokens with "Public repositories"' 1>&2
    exit 1
fi

jq=$(which jq)

jq_ () {
	"$jq" "$@"
}

curl_ () {
    echo "Requesting $@" 1>&2
    tmp=$(mktemp)
    if curl -s --fail-with-body \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $GITHUB_TOKEN" \
        "$@" \
    | tee $tmp
    then
        rm -f $tmp
    else
        message=$(jq_ -r '.message' $tmp)
        echo "error: $message" 1>&2
        rm -f $tmp
        exit 1
    fi
}

# https://docs.github.com/en/rest/actions/workflow-runs#list-workflow-runs-for-a-repository
# NOTE: an unsorted and random sample of runs is returned
since=$(date -u -d '30 days ago' +%Y-%m-%d)
curl_ "https://api.github.com/repos/${owner}/${repo}/actions/workflows/${workflow}.yml/runs?branch=${branch}&event=push&status=success&created=>=${since}" > workflows.json

jq '.workflow_runs | sort_by(.run_number) | last' workflows.json > workflow.json

echo "Using $(jq_ -r '.html_url' workflow.json)"

curl_ "$(jq_ -r '.artifacts_url' workflow.json)" > artifact.json


mkdir -p _site/download

dl_ () {
    name=$1
    file=$2

    echo "Fetching artifact $name" 1>&2

    archive_download_url=$(jq_ -r ".artifacts[] | select(.name==\"${name}\") | .archive_download_url" artifact.json)

    echo "Downloading ${archive_download_url}" 1>&2
    # XXX: Use -H 'Accept: application/octet-stream' ?
    if ! curl -s --fail -L -H "Authorization: token $GITHUB_TOKEN" -z $name.zip -o .$name.zip ${archive_download_url}
    then
        echo "error: failed to download ${archive_download_url}" 1>&2
        exit 1
    fi

    echo "Extracting $file from artifact $name" 1>&2
    unzip -q -o .$name.zip $file -d _site/download

    mv .$name.zip $name.zip
}

dl_ apitrace-ubuntu-20.04 apitrace-latest-Linux.tar.bz2
dl_ apitrace-ubuntu-arm64 apitrace-latest-Linux-arm64.tar.bz2
dl_ apitrace-win32-x86 apitrace-latest-win32.7z
dl_ apitrace-win64-x86 apitrace-latest-win64.7z
dl_ apitrace-win64-arm apitrace-latest-win64-arm.7z


exit 0
