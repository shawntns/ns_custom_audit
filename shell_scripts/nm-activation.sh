#!/bin/bash
# Author: xxu@tenable.com

###########################################################################
# Please replace your NM's actual
# 1) IP Address (NM)
# 2) accessKey (ACCESS)
# 3) secretKey (SECRET)
# at the following lines. But how to get the NM accessKey and secretKey?
# Goes to [Settings] --> [My account] --> [API Keys], and then click [Generate].
NM="192.168.0.51"
ACCESS="29c172f6ad4dac9510241a470ecbdfa4cbf6c3c305c250e4ca41ffb3c177021a"
SECRET="0b312251c6567fab6ffc59fc76d6a862cc0b37f99f252ea57ca9c714a0b83316"
###########################################################################

# Ask user's input for the Activation Code
echo "Input the NM Activation Code at below..."
echo "(The Code would be a 20-digit serial number, such likes EVAL-NVFJ-AS2T-2M3F-YJQ2)"
read var_code
CODE=$var_code

if curl --insecure "https://$NM:8834/server/register" \
-H "X-ApiKeys: accessKey=$ACCESS; secretKey=$SECRET" \
-H "Content-Type: application/json" \
-d "{\"code\": \"$CODE\"}" 2>&1 | grep "error"; then
	echo "Activation Error, probably an invalid Code..."
	exit 1
else
	echo "Nessus Manager has been successfully activated!"
	exit 0
fi
