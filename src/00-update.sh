#!/bin/bash

# location of "master"
directoryURL="https://raw.githubusercontent.com/freifunk/directory.api.freifunk.net/master/directory.json"

# go to "my" directory
cd "$( dirname "$0" )"

# load "master"
curl -k -o directory.json. "$directoryURL"  &&  mv directory.json. directory.json

# load state jsons
grep ':' directory.json | sed -e 's:" *,::' -e 's:"::g' -e 's+:+ +' | sort | while read id url; do

	echo "getting $id ..."

	if curl -k -o "$id.json." "$url"; then

		for n in $( seq 1 10 ); do
			if ! grep '<html' "$id.json."; then break; fi
			echo "received HTML file ... trying again '$id' ($n)"
			curl -k -o "$id.json." "$url"
		done

		! grep '<html' "$id.json."  &&  mv "$id.json." "$id.json"

	fi
done

