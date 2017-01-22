#!/bin/sh

OPTIND=1

function killemall {
  for i in `ps -a -x -j |grep -i [m]cafee|awk '{print $2}'`; do echo "[+] Giving an awful and painful death to pid $i"; kill -9 $i || true; done
}

function removeFromLaunchd {
  launchctl unload -w /Library/LaunchDaemons/com.mcafee.virusscan.fmpd.plist
  launchctl unload -w /Library/LaunchDaemons/com.mcafee.ssm.ScanManager.plist
  launchctl unload -w /Library/LaunchDaemons/com.mcafee.ssm.ScanFactory.plist
  launchctl unload -w /Library/LaunchDaemons/com.mcafee.ssm.Eupdate.plist
}

function disableAV {
  removeFromLaunchd
  killemall
}

function enableAV {
  launchctl load -w /Library/LaunchDaemons/com.mcafee.virusscan.fmpd.plist
  launchctl load -w /Library/LaunchDaemons/com.mcafee.ssm.ScanManager.plist
  launchctl load -w /Library/LaunchDaemons/com.mcafee.ssm.ScanFactory.plist
  launchctl load -w /Library/LaunchDaemons/com.mcafee.ssm.Eupdate.plist
}

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

while getopts "ed" opt; do
  case $opt in
    e)
      # enable
      enableAV
      echo "[+] Enabling McAfee AntiVirus!" >&2
      ;;
    d)
      # disable
      disableAV
      echo "[+] Disabling McAfee!" >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

echo "[!] Aye, Sir! Done!"
