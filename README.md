This is an attempt to set up a virtual machine in Vagrant containing Shibboleth Service Provider and Identity Provider.

Currently, fully automated IDP installation has strandend on two issues:
* The IDP install script cannot read password when run as a bash script (console is null).
* The IDP install script does not seem to find the policy files, which are installed ("Cannot locate policy or framework files")