#!/bin/sh

if [ -z $HOST_NAME ];then
    echo "[!] Host name not set"
    exit 1
else
    echo "[+] Host Name set to $HOST_NAME"
fi

if [ -z $CERT_DIR ];then
    echo "[!] Cert dir not set"
    exit 1
else
    echo "[+] Cert dir set to $CERT_DIR"
fi

if [ -z $TS_AUTHKEY ];then
    echo "[!] TS_AUTHKEY not set"
    exit 1
else
    echo "[+] TS_AUTHKEY set to ********"
fi

echo "[+] Requirement check passed, start service now..."
echo "[+] Remapping socket /tmp/tailscaled.sock to /var/run/tailscale/tailscaled.sock."
if [ ! -d "/var/run/tailscale/" ];then
    mkdir /var/run/tailscale/
fi
if [ ! -f "/var/run/tailscale/tailscaled.sock" ];then
    ln -s /tmp/tailscaled.sock /var/run/tailscale/tailscaled.sock
fi
/app/derper -hostname $HOST_NAME -certmode manual -certdir $CERT_DIR -verify-clients &
/usr/local/bin/containerboot &
echo "[+] Service started, health check service started..."
sleep 4s
while true
do
    sleep 4s
    PID_DERPER=`ps -elf | grep derper | grep -v grep | wc -l`
    PID_TAILSCALED=`ps -elf | grep tailscaled | grep -v grep | wc -l`
    if [ $PID_DERPER -eq 0 ];then
        echo "[!] Derp service exited, container would stopped now."
	exit 1
    fi
    if [ $PID_TAILSCALED -eq 0 ];then
        echo "[!] Tailscale service exited, container would stopped now."
	exit 1
    fi
done
