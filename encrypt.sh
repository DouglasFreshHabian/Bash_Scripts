#!/bin/bash

# A Simple Bash script to encrypt files

echo "This is a simple file encrypter/decrypter"
echo "Please choose to encrypt or decrypt"

choice="Encrypt Decrypt"

select option in $choice; do
	if [ $REPLY = 1 ];
then
	echo "You have selected Encryption"
	echo "Please enter the file name"
	read file;
	gpg -c $file
	echo "The file has been encrypted"
else
	echo "You have selected Decryption"
	echo "Please enter the file name"
	read file2;
	gpg -d $file2
	echo "The file has been decrypted"
fi
done
