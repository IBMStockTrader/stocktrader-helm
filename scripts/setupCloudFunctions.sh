#!/bin/bash
# Copyright [2018] IBM Corp. All Rights Reserved.
# 
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
# 
#        http://www.apache.org/licenses/LICENSE-2.0
# 
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

if [ "$SLACK_HOOK_URL" = "" ]; then
  read -p "Enter slack incoming webhook hook URL: " SLACK_HOOK_URL
fi

if [ "$SLACK_CHANNEL" = "" ]; then
  read -p "Enter slack channel name: " SLACK_CHANNEL
fi

# Create package
echo "Creating stocktrader package"
ibmcloud fn package create stocktrader

# Create the action to put together the slack message (this assumes the js file is in current directory)
echo "Creating action"
ibmcloud fn action create stocktrader/prepareSlackMessage prepareSlackMessage.js --kind nodejs:8

# Create a package binding for the slack action.
echo "Binding slack system package"
ibmcloud fn package bind /whisk.system/slack stocktrader-slack \
          --param url "$SLACK_HOOK_URL" \
          --param channel "$SLACK_CHANNEL"

# Create a sequence.
echo "Creating action sequence"
ibmcloud fn action create stocktrader/PostLoyaltyLevelToSlack --sequence stocktrader/prepareSlackMessage,stocktrader-slack/post

# Test it.
echo "Testing action"
ibmcloud fn action invoke stocktrader/PostLoyaltyLevelToSlack --param owner "test" --param old "BASIC" --param new "BRONZE"

echo "Stocktrader cloud function created and test slack message posted.  Check your slack channel for test message."