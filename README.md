# Automatic Docker CA-Certificate Injector
Running a legacy server on-prem? Security ppl want you to use the corps CA?
This repo might help you making docker images accept your own CA!

## How It Works
 - Build your app-image as usual
 - Build the final image using this repo + your app-image as base
 - The build script will ...
   - Automatically detect the base-/app-containers package manager
   - Install the packages needed (eg. ca-certificates)
   - Inject & install your certs from ./certs
   - Cleanup cache, remove the injector script and /magiccerts from patched app-image 
 - Profit!

## Supported Base-images
The "domagic.sh" script auto-detects the containers package manager.
Tested:
 - debian (dpkg/apt-get)
 - alpine (apk)
 - opensuse/leap (zypper)
 - centos (yum)

## Building Your Image
### Copy You CA-Cert(s) To ./certs/
### Build Your App-Image
### Build CA-Injected Image
```
BASE_IMAGE=myappimage:latest
FINAL_TAG=ca-patched
docker build --no-cache --build-arg BASE_IMAGE=${BASE_IMAGE} -t ${BASE_IMAGE}:${FINAL_TAG} .
```

Now you should have a new image labeled 'myappimage:ca-patched'. 

*Happy Containering!*
