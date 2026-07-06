#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
    echo "🛑   $(basename "$0") requires root. elevating..."
    exec sudo "$0" "$@"
fi

echo "🗑️    removing old uxplay rules"

ufw app update uxplay > /dev/null
ufw reload > /dev/null

for num in $(sudo ufw status numbered | grep -i "uxplay" | awk -F'[][]' '{print $2}' | sort -rn); do sudo ufw delete $num; done

ufw status numbered | grep -i "uxplay" |

echo "🖥️    finding local network IP"

PREFIX=$(ip a | awk '/inet / { count++; if (count == 2) { print $2; exit } }' | cut -d/ -f1 | awk -F. '{print $1"."$2"."$3}')

#echo "$PREFIX"

LOCAL_IP="${PREFIX}.0/24"

#echo "$LOCAL_IP"

echo "🖥️    modifying ufw rules"

ufw allow from "$LOCAL_IP" to any app uxplay > /dev/null

ufw app update uxplay > /dev/null

#echo "ufw firewall rules added to uxplay app"

ufw reload > /dev/null

echo "✅   ufw rules updated and firewall reloaded"