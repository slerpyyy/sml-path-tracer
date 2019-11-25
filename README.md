# SML Path Tracer
*A simple path tracer written in SML*

![linux-recommendet](https://img.shields.io/badge/linux-recommendet-brightgreen)
![works-on](https://img.shields.io/badge/works%20on-my%20mashine%E2%84%A2-orange)
![no-sosml](https://img.shields.io/badge/SOSML%20compatible-no%20:\(-red)
![the-king](https://img.shields.io/badge/long%20live-Holger%20Hermanns-yellow)

What you're looking at is a physics based path tracer fully written in Standard ML. This project is a demonstration of the capibilities of SML, because as horrible as that language may be, I wrote a working path tracer in it. 

## Results from 2 minutes of rendering

![preview-image](https://github.com/slerpyyy/sml-path-tracer/blob/master/preview.png?raw=true)

# How to run this thing
You can install SML and download the repo using the following commands:
```
apt-get install smlnj
git clone https://github.com/slerpyyy/sml-path-tracer.git
cd sml-path-tracer
```

Once everything is downloaded and installed, you should be able to run the script using this command:
```
cat pathtracer.sml | sml
```

The result should be in your working directory under `result.ppm`.

**Note:** The sml interpreter only exits if it reads an EOF signal (mashing `Ctrl + C` doesn't work). In case you ever get stuck in the interpreter, hit `Ctrl + D` instead.

# Motivation
Fellow students crying around that SML is useless and you can't do anything fun with it
