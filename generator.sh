#!/bin/sh
# @Author: Antonio Espinosa
# @Date:   2015-12-19 15:12:48
# @Last Modified by:   David Jiang
# @Last Modified time: 2015-12-19 18:36:20


# Default application location that need to be used
OPENSSL=/usr/bin/openssl
CHMOD=/bin/chmod
LESS=/usr/bin/less

# configuration file location
CONFIG_FILE='.conf'

# Error handling
if [ ! -x $OPENSSL ]; then
   echo "ERROR : OpenSSL not installed or not found at $OPENSSL"
   exit;
fi

if [ ! $# -eq 1 ]; then
   echo "Usage: '$0 <subdomain.domain.com>' - This script take exect ONE parameter."
   exit;
fi

if [ -f "$CONFIG_FILE" ]; then
   . "$CONFIG_FILE"
else
   echo "ERROR : No $CONFIG_FILE file found, please copy '$CONFIG_FILE.example' to '$CONFIG_FILE' and configure your data"
   exit;
fi

if [ -z "$COUNTRY" ]; then echo "ERROR : Country not set"; exit; fi
if [ -z "$STATE" ]; then echo "ERROR : State not set"; exit; fi
if [ -z "$LOCATION" ]; then echo "ERROR : Location not set"; exit; fi
if [ -z "$ORG" ]; then echo "ERROR : Organization not set"; exit; fi
if [ -z "$ORGUNIT" ]; then echo "ERROR : Organization unit not set"; exit; fi

# Start CSR Generate Process
DOMAIN=$1

if [ "$SIGNALG" != 'sha256' ] && [ "$SIGNALG" != 'sha384' ]; then
    echo "NOTICE : Bad signature algorithm, using default sha256"
    SIGNALG='sha256'
fi

if [ "$KEYALG" != 'dsa' ] && [ "$KEYALG" != 'rsa' ] && [ "$KEYALG" != 'ecc' ]; then
    echo "NOTICE : Bad key algorithm, using default rsa"
    KEYALG='rsa'
fi

if [ "$BITS" != '2048' ] && [ "$BITS" != '4096' ]; then
    echo "NOTICE : Bad key lenght, using default 2048"
    BITS='2048'
fi

if [ "$ECCTYPE" != 'prime256v1' ] && [ "$ECCTYPE" != 'secp384r1' ]; then
    echo "NOTICE : Bad ECC Type, using default prime256v1"
    ECCTYPE='prime256v1'
fi

if [ "$KEYALG" == 'dsa' ]; then
   if [ ! -f $DOMAIN.dsaparam.pem ]; then
      echo "Creating DSA Param file for $DOMAIN..."
      if ! $OPENSSL dsaparam -out $DOMAIN.dsaparam.pem $BITS; then
         echo "ERROR : Generating DSA param file failed."
         exit;
      fi
   fi
   echo "Creating DSA Key..."
   if ! $OPENSSL gendsa -out $DOMAIN.key $DOMAIN.dsaparam.pem; then
      echo "ERROR : Generating key failed."
      exit;
   fi

elif [ "$KEYALG" == 'rsa' ]; then

   echo "Creating RSA Key..."
   if ! $OPENSSL genrsa -out $DOMAIN.key $BITS; then
      echo "ERROR : Generating key failed."
      exit;
   fi

elif [ "$KEYALG" == 'ecc' ]; then

   echo "Creating RSA Key..."
   if ! $OPENSSL ecparam -genkey -name $ECCTYPE -out $DOMAIN.ecc.key; then
      echo "ERROR : Generating key failed."
      exit;
   fi

fi


# Generate CSR
if [ "$KEYALG" == 'rsa' ]; then
    
   echo "Creating CSR..."
   if ! $OPENSSL req -new -key $DOMAIN.key -out $DOMAIN.csr -${SIGNALG} -subj "/C=$COUNTRY/ST=$STATE/L=$LOCATION/O=$ORG/OU=$ORGUNIT/CN=$DOMAIN"; then
      echo "ERROR : Generating csr failed."
      exit;
   fi

elif [ "$KEYALG" == 'ecc' ]; then
   
   echo "Creating CSR..."
   if ! $OPENSSL req -new -key $DOMAIN.ecc.key -out $DOMAIN.csr -${SIGNALG} -subj "/C=$COUNTRY/ST=$STATE/L=$LOCATION/O=$ORG/OU=$ORGUNIT/CN=$DOMAIN"; then
      echo "ERROR : Generating csr failed."
      exit;
   fi

fi

echo "OK - Certificate CSR created successfully"
$CHMOD 600 $DOMAIN.key $DOMAIN.csr
$OPENSSL req -text -noout -verify -in $DOMAIN.csr | $LESS > $DOMAIN.verify.log
echo "Please see DOMAIN.verify.log for detail verification information."

echo "Clean up...."
mkdir $DOMAIN
mv $DOMAIN.csr $DOMAIN/
if [ "$KEYALG" == 'rsa' ]; then
   mv $DOMAIN.key $DOMAIN/

elif [ "$KEYALG" == 'ecc' ]; then
   mv $DOMAIN.ecc.key $DOMAIN/
fi

mkdir $DOMAIN/logs
mv $DOMAIN.verify.log $DOMAIN/logs/

echo "Successfully!!"