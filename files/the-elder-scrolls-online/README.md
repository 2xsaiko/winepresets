# Certificates

There seems to be no way to script importing certificates into a wine prefix.
Therefore, since the final imported certificate is stored in the Registry, it
can be nonetheless imported by importing a .reg file.

To generate that .reg file yourself, follow these steps:

First, ensure that the wine prefix has been initialized by running

    wineboot

Then, back up the *.reg files in the root of the wine prefix directory (only
user.reg should actually be needed)

Get the root certificate from <https://www.thawte.com/roots/>. Convert them
using these commands:

    openssl x509 -outform der -in thawte_Primary_Root_CA.pem -out thawte_Primary_Root_CA.crt

Then, open up the Internet Settings dialog:

    wine control inetcpl.cpl

Go to Content -> Certificates... and import the three certificates. When
asked, select "Automatically select certificate store".

When the certificate has been imported, diff the registry files you backed up
against the current state of the files. A registry key inside of
Software\Microsoft\SystemCertificates\Root\Certificates should show up inside
the diff. Navigate to that key in the registry, inside of HKEY_CURRENT_USER and
export it into a .reg file.
