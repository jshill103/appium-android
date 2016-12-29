# appium-android

**Appium Android** is a image for the purpose of quickly registering Android emulators with Selenium Grid running on the same machine. 

# EXAMPLE
```html
docker run --net host -di -e INDEX=0 --name android jshillingburg/appium-android
```

In order for this image to register to your grid you **MUST PASS AN UNUSED INDEX** 

# Credits
This image is based off of the image Christopherdcb created over at [His repo](https://hub.docker.com/r/cristopherdcb/appium-android/)