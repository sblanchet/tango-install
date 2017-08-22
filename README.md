# TANGO INSTALL

This project provides a Makefile to download, build and automatically setup TANGO and HDB++.

The project goals are:

* understand how to setup TANGO and HDB++ from scratch
* provide a reproducible TANGO environment for testing


## Prerequesites

- a fresh installation of a supported operating system
    - Debian 9
    - Ubuntu 17
- GNU make
- root privileges

## Download

Download or clone the project into a Debian 9 or Ubuntu 17 virtual machine.

> Note: it is very important to use `--recursive` otherwise the submodules are not downloaded.


```bash
git clone --recursive https://github.com/sblanchet/tango-install.git
```

## Compile & Install
Then run `make` with root privileges.
```bash
cd tango-install
make install
```

TANGO will be installed into the directory `/opt/tango`

### Tips
If the installation fails after tango compilation, and you wish to try a new
HDB++ compilation without recompiling Tango (it is very long), run:
```
make install_hdbpp
```

## Run
Run TANGO and its applications with the following command
```bash
make run

```



## Help
If you need help, just run
```bash
make help
```

## See also

- Official TANGO website: https://www.tango-controls.org
- Official HDB++ webpage: https://www.tango-controls.org/community/project-docs/hdbplusplus/
