#!/bin/bash

# How to install
# enter the following:
#    curl -s -L http://use.sh/tox/simple_gpg.sh > simple_gpg.sh
# and then do
#    sudo chmod +x simple_gpg.sh

# options
# -c: create new key pair
# -l: list all keys on your computer
# -s [KEYID]: submit your current public key to pgp.mit.edu server so others can find you
# -v [KEYID]: export public key

echo 'Simple GPG tools for basic functioning by @kevinkassimo'

# dependency checks

UNAME_INFO=`uname -a`
UNAME_UBUNTU=$(echo $UNAME_INFO | grep "Ubuntu")
UNAME_MAC=$(echo $UNAME_INFO | grep "Darwin")

if ! [[ -z $UNAME_MAC ]]; then

if ! type "brew" &> /dev/null; then
    echo '!!! Brew is not installed yet !!!'
    echo '>> Installing brew:'
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
if ! type "gpg" &> /dev/null; then
    echo '!!! Warning: GPG is NOT installed yet !!!'
    echo '>> Installing gpg:'
    brew update
    brew install gpg
fi

elif ! [[ -z $UNAME_UBUNTU ]]; then

if ! type "gpg" &> /dev/null; then
    echo '!!! Warning: GPG is NOT installed yet !!!'
    echo '>> Installing gpg:'
    sudo apt install pari-gp
fi

else
    echo "unsupported OS!"
fi

PGP_SERVER='keyserver.ubuntu.com'

# parse options
while getopts "clv:s:a:e:d:" opt; do
    case "$opt" in
    "c")
        # create a gpg keypair
        echo '>> Generating key pair, please follow the following instructions:'
        gpg --gen-key

        echo 'All your OWN current key info:'
        gpg --list-secret-keys --keyid-format LONG
        exit 0
        ;;
    "l")
        # list current saved keys
        echo '>> Listing all saved keys (including pub key of others):'
        gpg --list-key
        exit 0
        ;;
    "v")
        # show public key detail
        echo '>> Showing public key details'
        gpg --armor --export "$OPTARG"
        exit 0
        ;;
    "s")
        # submit key to pgp.mit.edu keyserver
        echo ">> Submitting public key $OPTARG to $PGP_SERVER key server: "
        gpg --keyserver $PGP_SERVER --send-keys "$OPTARG" || { echo 'Error exit'; exit 1; }
        exit 0
        ;;
    "a")
        # fetch someone from the pgp.mit.edu server
        echo ">> Fetching public key $OPTARG from $PGP_SERVER key server: "
        gpg --keyserver $PGP_SERVER --recv-keys "$OPTARG" || { echo 'Error exit'; exit 1; }
        exit 0
        ;;
    "e")
        # get encrypted file
        echo ">> Encrypting file $OPTARG with public key"
        read -p "Please specify the public key ID you want to encrypt your file with: " PUBKEY
        echo ">> Encrypting with $PUBKEY"
        gpg --encrypt --recipient "$PUBKEY" $OPTARG || { echo 'Some error occurred'; exit 1; }
        echo ">> Success! The encrypted file is named as $OPTARG.gpg in this directory."
        echo "Now you can safely transmit this encrypted file on any platform you like, with only the receiver can decrypt it."
        exit 0
        ;;
    "d")
        echo ">> Decrypting file $OPTARG"
        gpg --decrypt "$OPTARG" || { echo 'Some error occurred'; exit 1; }
        echo ">> Success!"
        exit 0
        ;;
    esac
done
