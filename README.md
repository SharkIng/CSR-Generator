# CSR Generator - Domain SSL Sign Request .csr generator


## FIRSTLY

### What is this:
This is a Domain SSL Certificate Sign Request ".csr" file generator.
 
This script using openssl to generate a 2048 RSA Key and CSR for a domain that need apply/buy a SSL Certificate.

### Dependency:
- OPENSSL Library (May beed install first)
- LESS && CHMOD Library (Build in library for Unix-like system)

### Supported type:
1. RSA 2048/4096
2. ECC / P-256
3. DSA (From Mr. Espinosa's Script)
4. Extra: SHA256 Encrypt Key (From Mr. Espinosa's Script)

## How to use this

1. Get this script from github
`git clone https://github.com/SharkIng/csr-generator.git`
2. Copy example.conf and rename it to `.conf`
3. Edit `.conf` file for all necessary information.
4. run `./csr DOMAIN` command (Change DOMAIN to any domain name you want to get SSL)


## Thanks
- CSR Script by Mr. Espinosa
- DigiCert [OpenSSL CSR Creation](https://www.digicert.com/easy-csr/openssl.htm)

## License

GNU GENERAL PUBLIC LICENSE | Version 3, 29 June 200
 
