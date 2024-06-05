#!/bin/bash
##############################################################################
#
#	Copyright (c) 2017-2024, INTO-CPS Association,
#	c/o Professor Peter Gorm Larsen, Department of Engineering
#	Finlandsgade 22, 8200 Aarhus N.
#
#	This file is part of the INTO-CPS toolchain.
#
#	VDMCheck is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	VDMCheck is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with VDMCheck. If not, see <http://www.gnu.org/licenses/>.
#	SPDX-License-Identifier: GPL-3.0-or-later
#
##############################################################################

#
# Process a URDF file, and validate the XML structure using the VDM-SL model.
#

USAGE="Usage: URDFCheck.sh <file>.urdf"

if [ $# = 1 ]
then
	FILE=$(realpath "$1")
fi

if [ -z "$FILE" ]
then
	echo "$USAGE"
	exit 1
fi

if [ ! -e "$FILE" ]
then
	echo "File not found: $FILE"
	exit 1
fi

if [[ "$FILE" != *.urdf ]]
then
	echo "File must be named *.urdf"
	exit 1
fi

SCRIPT=$0

# Subshell cd, so we can set the classpath
(
	path=$(which "$SCRIPT")
	dir=$(dirname "$path")
	cd "$dir"
	
	MODEL="rule-model rule-model/XML2VDM"
	VARNAME=$(basename "$FILE" | sed -e "s/\./_/g")
	
	# Fix Class Path Separator - Default to colon for Unix-like systems, semicolon for msys
	CLASSPATH_SEPARATOR=":"
	
	if [ $OSTYPE == "msys" ]
	then
		CLASSPATH_SEPARATOR=";"
	fi
	
	java -Xmx1g \
		-Dxmlreader.schema=schema/urdf.xsd \
		-Dvdmj.parser.merge_comments=true \
		-Dvdmj.readers=.urdf=xmlreader.XMLReader \
		-cp vdmj.jar${CLASSPATH_SEPARATOR}annotations.jar${CLASSPATH_SEPARATOR}xsd2vdm.jar${CLASSPATH_SEPARATOR}xmlReader.jar com.fujitsu.vdmj.VDMJ \
		-vdmsl -q -annotations -e "validateURDF(convertRobot($VARNAME))" $MODEL "$FILE" |
		awk '/^true$/{ print "No errors found."; exit 0 };/^false$/{ print "Errors found."; exit 1 };{ print }'
)

EXIT=$?		# From subshell above
	
exit $EXIT

