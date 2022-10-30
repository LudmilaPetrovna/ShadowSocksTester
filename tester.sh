TESTURL="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.5.0-amd64-netinst.iso"
TESTURL="https://releases.ubuntu.com/22.04.1/ubuntu-22.04.1-desktop-amd64.iso"
TESTURL="https://cdimage.kali.org/kali-2022.3/kali-linux-2022.3-installer-amd64.iso"
TESTURL="https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-pages-articles.xml.bz2"
TESTURL="https://geo.mirror.pkgbuild.com/iso/2022.10.01/archlinux-2022.10.01-x86_64.iso"

while read aaa; do

DEC=`echo "$aaa" | base64 -id 2> /dev/null | tr '@' ':'`
ENC=`echo "$DEC" | cut -d: -f1`
PASS=`echo "$DEC" | cut -d: -f2`
HOST=`echo "$DEC" | cut -d: -f3`
PORT=`echo "$DEC" | cut -d: -f4`
IP=`dig A "$HOST" | grep IN | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"`;

echo "ip route add $IP/32 via 192.168.1.1"

echo "### TESTING $IP:$PORT ($HOST:$PORT), password: $PASS, enctype: $ENC"

LOCALTESTPORT=$(($RANDOM%2000+10805))

echo "Command: ss-local -v -k \"$PASS\" -s \"$IP\" -p \"$PORT\" -l 1080 -m \"$ENC\""

ss-local -v -k "$PASS" -s "$IP" -p "$PORT" -l $LOCALTESTPORT -m "$ENC" 2> /dev/null > /dev/null &
SSPID=$!
sleep 1
SHADOWIP=`curl -ks -m 10 --preproxy "socks5h://127.0.0.1:$LOCALTESTPORT" "https://ifconfig.me/"`
echo "IP: we tested \"$IP\", we got \"$SHADOWIP\""

curl -Lm60 --speed-time 30 --speed-limit 90000 "$TESTURL" -o /dev/null 2>&1 | grep "Operation timed out after"

kill -9 "$SSPID"

done

