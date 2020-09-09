<span class="badge-patreon"><a href="https://patreon.com/densoload" title="Donate to this project using Patreon"><img src="https://img.shields.io/badge/patreon-donate-yellow.svg" alt="Patreon donate button" /></a></span>

# Why upgrade to Happi Cookie?

1. Learning to script isn't easy for beginners, especially if you are doing it alone.
2. Roblox Studio has a client-server architecture, which is an extra layer of difficulty.
3. There is no central repository for Lua scripts and documentation.
4. There is no community support for beginners, who may become frustrated.
5. There is no progress indicator on how fast you are learning.
6. There is no mentor to help you with best practices and guidelines.
7. There is no buddy to review your code and give tips.

I have been writing source code for 20+ years and started Roblox Studio this year. I specialized in client-server architecture, which makes me a natural fit for Roblox game programming.

# Table of Contents
- [Why upgrade to Happi Cookie?](#why-upgrade-to-happi-cookie)
- [Table of Contents](#table-of-contents)
- [Benefits](#benefits)
- [Robloxcode](#robloxcode)
  - [Project Structure](#project-structure)
  - [Roblox Games](#roblox-games)
    - [1. ObbyMaster 2020](#1-obbymaster-2020)
  - [Lua Modules](#lua-modules)
    - [2. AutoBuild BETA](#2-autobuild-beta)
    - [3. Pathfinder](#3-pathfinder)
  - [Todo](#todo)

# Benefits

1. All Roblox game creations. Sample work (see below): [ObbotMaster 2020](#1-obbymaster-2020)
2. Lua scripts and documentation.
3. Updates (bug fixes, enhancements)
4. The updates and new files are available in my private repository only.
5. Documentation and articles on how to use the scripts, including game design.
6. Telegram group chat
7. Access to Beta development code
8. Personalized Chat support
9. Commercial or Personal License

# Robloxcode

1. This repository has latest updates to Roblox files, Lua scripts and new resources.
1. This repository is available to members of [densoload's Patreon](https://www.patreon.com/densoload?fan_landing=true) only.
1. Each module or package, within its own subfolder, can be used as a standalone and has a README file.

## Project Structure

     Robloxcode/              <-- Root of this project
       +- ObbyMaster2020/     <-- Obby starter project
       +- AutoBuild/          <-- AutoBuild plugin BETA
       +- Pathfinder/         <-- Pathfinder plugin


## Roblox Games

My purpose is to write modular codes that can be used as plug-and-play. You can mix them or use them as standalones.

### 1. ObbyMaster 2020

This game wasn't built from scratch as I took the Obby starter game from Roblox and modified it.

This is what I built on top of it:
* Timer round, where participants get ranked on Leaderboard at the end.
* You can set a minimum number of participants before each round begins (For demo purposes I have set this to 1).
* I was lazy to create a Wizard from a random player, so I gave Fireball ability to all players instead.
* Obbys are random each round, and a Lumberjack Zombie (free NPC model) spawns 30 seconds after participants are teleported into the Castle.
* Participants can spectate each other even while inside castle (I was lazy to make a spectate for only participants outside castle).

**Screenshots**
* [Screenshot 1](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/1/9/1/191146f6a92d88d964c2c59f331ae871de9444f1.png)
* [Screenshot 2](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/9/7/b/97b397638c2d42651b97c21511b09b9e440b0f2f.jpeg)
* [Screenshot 3](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/a/3/f/a3fdae0346979e85d994e668ba80436a740d1487.jpeg)

That’s pretty much the whole game. There is room for future development. You can play it below:

[ObbotMaster 2020 Alpha](https://yourls.fxgit.work/b002)

## Lua Modules

### 2. AutoBuild BETA

The idea of this plugin is to automate a static model using a blueprint from script.
For example, this plugin will convert a code such as “gl1001” to a block with property Glass (“gl”) and White (1001) color.

The blueprint is a script file that consists of Data3d = {};

* Step 1. IsGeoEmpty()
The first step is to specify the size (X,Y,Z) of the building.

* Step 2. Add3dScript()
The second step is to create a Data3d script, that contains values for each layer of the model.
Note: This step is manual, however there is a possibility to create a GUI blueprint editor outside of Roblox Studio.

* Step 3. Build3d()
The third step is to build and render the static model from the Data3d script.

* Step 4, 5, 6. ReduceX(), ReduceY(), ReduceZ()
The final step is to reduce the number of parts along the X, Y and Z axes.

Note: This plugin works with part of stud size 1x1x1, 2x2x2, but I have not tested it with irregular shapes.

BETA: I have converted ReduceX, ReduceY and ReduceZ to RaycastX, RaycastY and RaycastZ, which speeds up the optimization of parts considerably. However, there is a minor bug which I am trying to resolve.

### 3. Pathfinder

The idea of this plugin is to automate NPC walking from a source to destination. Why would I need this when there is already a pathfinder service in Roblox? The reason is that I would like the NPC to stick to a road or path, and not take shortcuts through non-paths.

* Step 1. NewPathfinder
The first step is to specify the NPC, which will create a pathfinder folder that is associated with this NPC.

* Step 2. CloneWaypoint
The second step is to clone the waypoint from Step 1. Each way point has its own detector and script that will instruct where the NPC must go next.
Note: I’ve used the service Pathfinderservice to navigate from each waypoint.

So far, there doesn’t appear to be any bugs.

## Todo

Currently, I’m working on a game that utilizes some of my plugins above.