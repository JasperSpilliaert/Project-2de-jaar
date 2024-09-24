#!/bin/sh

#uit te voeren op CA server vm

if [ "$#" -ne 1 ]
then
  echo "Usage: Must supply a domain"
  exit 1
fi

DOMAIN=$1

cd ~/certs
mkdir ~/certs/$DOMAIN
cd ~/certs/$DOMAIN

openssl genrsa -out $DOMAIN.key 2048
openssl req -new -key $DOMAIN.key -out $DOMAIN.csr

cat > $DOMAIN.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $DOMAIN
EOF

openssl x509 -req -in g03-fft.internal.csr -CA ~/certs/ca/myCA.pem -CAkey ~/certs/ca/myCA.key -CAcreateserial \
-out g03-fft.internal.crt -days 825 -sha256 -extfile g03-fft.internal.ext