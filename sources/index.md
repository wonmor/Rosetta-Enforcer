---
title: Welcome to Rosetta Enforcer
layout: base.njk
---

<img width="100" alt="Icon-MacOS-512x512@1x" src="https://user-images.githubusercontent.com/35755386/167236771-f03b224f-0d6a-4e92-8556-510a62ceb56a.png">

# Rosetta Enforcer
**Rosetta Enforcer** is a macOS utility that allows developers convert **Universal Binary** application to **Single Architecture**, saving hundreds of megabytes of space and resolving a possible compatibility issue.

---

Developed and Designed by **John Seong**. Served under the **BSD-2-Clause License**.

[Download for **macOS**](https://github.com/wonmor/Rosetta-Enforcer/raw/main/Installers/Install_Rosetta_Enforcer.dmg)

[Official **Documentation** for Both **Users** and **Developers**](https://github.com/wonmor/Rosetta-Enforcer/wiki/Official-Documentation)

---

<img width="1000" alt="Screen Shot 2022-05-02 at 7 25 38 PM" src="https://user-images.githubusercontent.com/35755386/166342011-0adf3649-a007-4410-ac48-83dba0020573.png">

---

### You might ask...
What is the **general use case** for it? Why would anyone prefer **Rosetta** instead of running the app natively on ARM macs?

---

### Short Answer
It can **save** hundreds of megabytes of **storage** by simply **removing unnecessary binaries** from the app files. Not only that, it can also **resolve** the **compatibility issue** present in macOS apps that are **not compiled directly through Xcode**.

---

### Long Answer
I made a game that uses PyGame, and when I try to compile it using PyInstaller to .app file, it automatically generates a Universal Binary app without giving developers a choice to select either Intel or ARM. Just as a side note, PyGame library does not support ARM macs yet, so if I run it normally without turning on the “Open using Rosetta” option in the default macOS “Show properties” menu when you right-click the app, it literally crashes immediately upon launch. When distributing an app that is NOT compiled using Xcode directly to users, I can’t just write in big red letters to go to properties and turn on the ‘Open using Rosetta’ option all the time; that’s too much work for users in most of the cases, and if they skip that stage ARM mac users will think the app simply crashes every time after launch. Using Rosetta Enforcer, developers can permanently remove one of the so-called “mis-compiled” binaries without going through a hassle of going to Terminal and typing commands.

---

## Possible Conversions

1. **Universal Binary** to **Intel-only**
2. **Universal Binary** to **ARM-only**

---

<img width="1119" alt="Screen Shot 2022-04-27 at 4 55 26 PM" src="https://user-images.githubusercontent.com/35755386/165629451-8a387c61-5d78-45e9-aef5-ecb53af24aab.png">

<img width="845" alt="Screen Shot 2022-05-06 at 3 09 25 PM" src="https://user-images.githubusercontent.com/35755386/167202509-5b9ce685-c280-4c84-9cd6-7dbb368140b6.png">

---

## Dependencies

- **SwiftUI**: User Interface Toolkit
- ```lipo``` command (**native** on most Macs)

---

Please note that the app is **not sandboxed** due to it nature of **modifying** other apps in the ```~/Applications``` folder. Therefore, it cannot be distributed on the Mac App Store.