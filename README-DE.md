# SML Path Tracer
*A simple path tracer written in SML*

![linux-recommendet](https://img.shields.io/badge/linux-empfohlen-brightgreen)
![works-on](https://img.shields.io/badge/works%20on-my%20mashine%E2%84%A2-orange)
![no-sosml](https://img.shields.io/badge/SOSML%20compatible-NEIN!!%20:\(-red)
![the-king](https://img.shields.io/badge/lang%20lebe-Holger%20Hermanns-yellow)

[English](README.md)

Was du hier sießt ist ein physik-basierter Path Tracer, der vollständig in Standard ML geschrieben ist. In kurz versucht ein Path Tracer ein Bild zu generieren, indem er einzelne Lichtstrahlen von der Kamera zu der Lichtquelle zurückverfolgte. Dieser Prozess ist in der Lage nahezu fotorealistische Bilder mit nur sehr wenig Code zu erzeugen. Der Nachteil dieser Methode ist der enormer Rechenaufwand der gebraucht wird ein klares Bild zu generieren. Wenn wir nur einen Lichtstrahl berechnen, ist das Bild nichts als Rauschen, aber mit jedem Lichtstrahl den wir berechnen, konvergiert das Ergebnis zu einem klaren Bild.

## Ergebnisse nach 10 Minuten

![preview-image](https://github.com/slerpyyy/sml-path-tracer/blob/master/preview.png?raw=true)

# Wie bringt man das Programm zum laufen?

Falls du auf deinem PC noch keinen SML Interpreter installiert hast, solltest du zuerst einen installieren. (Nein, dieses Programm funktioniert nicht in [SOSML](https://sosml.org/).) Ich empfehle dazu SML/NJ, da es am einfachsten zu installieren ist.
```
apt-get install smlnj
```

Jetzt kannst du mit dem folgenden Befehlen den Source Code herunterladen:
```
git clone https://github.com/slerpyyy/sml-path-tracer.git
cd sml-path-tracer
```

Sobald alles installiert und heruntergeladen ist, kannst du das Skript mit dem folgenden Befehl ausführen:
```
cat pathtracer.sml | sml
```

**Achtung:** Der SML/NJ Interpreter schließt sich nicht wenn man `Strg-C` drückt, sondern nur wenn er ein EOF Signal ließt. Falls du jemals im Interpreter stecken bleiben solltest, `Strg-D` sendet in dem meinsten Terminals ein EOF Signal.

# Motivation

Dieses Projekt ist eine Demonstration der Fähigkeiten von Standard ML. An der Uni höre ich immer nur Studenten jammern, wie nutzlos SML ist und dass man damit nichts anfangen kann. Ich bin selbst nicht der größte Fan von SML, aber so schrecklich diese Sprache auch sein mag, ich habe einen funktionierenden Pfadfinder darin geschrieben.

# Credits

Der gesamte Code wurde von [Aaron Bies](https://github.com/slerpyyy), einem Studenten der Universität des Saarlandes, geschrieben.