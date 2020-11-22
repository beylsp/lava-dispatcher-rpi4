#!/usr/bin/env python
"""
Simple tool that outputs hostname for given MAC address.

It takes as input a JSON-formatted file with MAC adress to 
hostname mappings:

    {
        "dc:a6:32:ac:b8:a3": "lwrpi01"
    }

"""
import argparse
import json
import subprocess
import sys


def _run(args, **kwargs):
    print("running: %s" % ' '.join(args))
    return subprocess.Popen(args, **kwargs)


def set_hostname(hostname):
    cmd = ['hostnamectl', 'set-hostname', hostname]
    p = _run(cmd, stdout=subprocess.PIPE)
    output, err = p.communicate()
    if err:
        raise ValueError(err)


def find_hostname(hostmap_file, mac):
    try:
        hostmap = json.load(open(hostmap_file, 'r'))
    except IOError as err:
        raise ValueError(err)
    if mac not in hostmap:
        raise ValueError(
            "Unable to find MAC address '%s' in '%s'." % (mac, hostmap_file))
    return hostmap[mac]


def query_mac():
    try:
        sys_class = "/sys/class/net/eth0/address"
        with open(sys_class) as fp:
            mac = fp.read().strip()
        return mac
    except IOError as err:
        raise ValueError(
            "Error querying MAC address: %s" % err)


def parse_args():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        "hostmap", metavar="HOSTMAP",
        help="file with MAC address to hostname mappings.")

    return parser.parse_args(sys.argv[1:])
    

def main():
    cli = parse_args()

    mac = query_mac()
    hostname = find_hostname(cli.hostmap, mac)

    print("Setting '%s' hostname for MAC address'%s'." % (hostname, mac))
    set_hostname(hostname)
    print("OK")        


if __name__ == "__main__":
    try:
        main()
    except ValueError as err:
        print("Can't set hostname.\n%s" % err)
        sys.exit(1)
