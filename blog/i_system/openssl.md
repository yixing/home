# openssl 生成签名

## 准备CA环境

    mkdir newcerts
    touch index.txt
    echo '01' > serial

## 生成CA 私钥和证书

    openssl genrsa -out ca.key 2048
    openssl req -new -x509 -key ca.key -out ca.crt  -subj "/C=CN/ST=BJ/L=BJ/O=HD/OU=dev/CN=ca/emailAddress=ca@bytedance.com"

## 生成ca配置ca.conf
    # we use 'ca' as the default section because we're usign the ca command
    # we use 'ca' as the default section because we're usign the ca command
    [ ca ]
    default_ca = my_ca

    [ my_ca ]
    #  a text file containing the next serial number to use in hex. Mandatory.
    #  This file must be present and contain a valid serial number.
    serial = ./serial

    # the text database file to use. Mandatory. This file must be present though
    # initially it will be empty.
    database = ./index.txt

    # specifies the directory where new certificates will be placed. Mandatory.
    new_certs_dir = ./newcerts

    # the file containing the CA certificate. Mandatory
    certificate = ./ca.crt

    # the file contaning the CA private key. Mandatory
    private_key = ./ca.key

    # the message digest algorithm. Remember to not use MD5
    default_md = sha1

    # for how many days will the signed certificate be valid
    default_days = 365

    # a section with a set of variables corresponding to DN fields
    policy = my_policy

    [ my_policy ]
    # if the value is "match" then the field value must match the same field in the
    # CA certificate. If the value is "supplied" then it must be present.
    # Optional means it may be present. Any fields not mentioned are silently
    # deleted.
    countryName = match
    stateOrProvinceName = supplied
    organizationName = supplied
    commonName = supplied
    organizationalUnitName = optional
    commonName = supplied

    [ ca ]
    default_ca = my_ca

    [ my_ca ]
    #  a text file containing the next serial number to use in hex. Mandatory.
    #  This file must be present and contain a valid serial number.
    serial = ./serial

    # the text database file to use. Mandatory. This file must be present though
    # initially it will be empty.
    database = ./index.txt

    # specifies the directory where new certificates will be placed. Mandatory.
    new_certs_dir = ./newcerts

    # the file containing the CA certificate. Mandatory
    certificate = ./ca.crt

    # the file contaning the CA private key. Mandatory
    private_key = ./ca.key

    # the message digest algorithm. Remember to not use MD5
    default_md = sha1

    # for how many days will the signed certificate be valid
    default_days = 365

    # a section with a set of variables corresponding to DN fields
    policy = my_policy

    [ my_policy ]
    # if the value is "match" then the field value must match the same field in the
    # CA certificate. If the value is "supplied" then it must be present.
    # Optional means it may be present. Any fields not mentioned are silently
    # deleted.
    countryName = match
    stateOrProvinceName = supplied
    organizationName = supplied
    commonName = supplied
    organizationalUnitName = optional
    commonName = supplied

## 生成网站证书配置

    # The main section is named req because the command we are using is req
    # (openssl req ...)
    [ req ]
    # This specifies the default key size in bits. If not specified then 512 is
    # used. It is used if the -new option is used. It can be overridden by using
    # the -newkey option.
    default_bits = 2048

    # This is the default filename to write a private key to. If not specified the
    # key is written to standard output. This can be overridden by the -keyout
    # option.
    default_keyfile = server.key

    # If this is set to no then if a private key is generated it is not encrypted.
    # This is equivalent to the -nodes command line option. For compatibility
    # encrypt_rsa_key is an equivalent option.
    encrypt_key = no

    # This option specifies the digest algorithm to use. Possible values include
    # md5 sha1 mdc2. If not present then MD5 is used. This option can be overridden
    # on the command line.
    default_md = sha1

    # if set to the value no this disables prompting of certificate fields and just
    # takes values from the config file directly. It also changes the expected
    # format of the distinguished_name and attributes sections.
    prompt = no

    # if set to the value yes then field values to be interpreted as UTF8 strings,
    # by default they are interpreted as ASCII. This means that the field values,
    # whether prompted from a terminal or obtained from a configuration file, must
    # be valid UTF8 strings.
    utf8 = yes

    # This specifies the section containing the distinguished name fields to
    # prompt for when generating a certificate or certificate request.
    distinguished_name = my_req_distinguished_name


    # this specifies the configuration file section containing a list of extensions
    # to add to the certificate request. It can be overridden by the -reqexts
    # command line switch. See the x509v3_config(5) manual page for details of the
    # extension section format.
    req_extensions = my_extensions

    [ my_req_distinguished_name ]
    C = CN
    ST = Beijing
    L = Beijing
    O  = Bytedance
    CN = cdn.bytedance.com

    [ my_extensions ]
    basicConstraints=CA:FALSE
    subjectAltName=@my_subject_alt_names
    subjectKeyIdentifier = hash

    [ my_subject_alt_names ]
    DNS.1 = *.20200629.api.test.pstatp.com
    DNS.2 = *.subdomain.cdn-test.bytedance.com

## 生成证书请求

    openssl req -new -out server.csr -config conf/server.conf

## 签名证书

    openssl ca -config conf/ca.conf -out server.crt -extfile conf/server.conf -in server.csr -extensions my_extensions -batch
