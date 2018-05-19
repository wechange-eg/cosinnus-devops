#!/bin/bash
#
# Generate pypi modules

modules=(
		cosinnus-core
		cosinnus-etherpad
		cosinnus-event
		cosinnus-message
		cosinnus-file
		cosinnus-note
		cosinnus-notifications
		cosinnus-marketplace
		cosinnus-poll
		cosinnus-stream
		cosinnus-todo
	)

for module in ${modules[@]}; do
	echo $module
	cd $module
	python setup.py bdist_wheel
	python setup.py sdist
	twine upload dist/*
	cd ..
done
	
