<span class="badge-buymeacoffee"><a href="https://ko-fi.com/dennislwm" title="Donate to this project using Buy Me A Coffee"><img src="https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg" alt="Buy Me A Coffee donate button" /></a></span>
<span class="badge-patreon"><a href="https://patreon.com/dennislwm" title="Donate to this project using Patreon"><img src="https://img.shields.io/badge/patreon-donate-yellow.svg" alt="Patreon donate button" /></a></span>

# Why upgrade to FX-Git-Pro?

1. My [FX-Git](https://github.com/dennislwm/FX-Git) repository has not been updated for more than 7 years.
1. Some of the source code does not work with the latest Metatrader build.
1. The updates and new files are available in my private repository only.
2. Documentation and articles on how to use the scripts, including strategies.

I have been writing source code for 20+ years and started trading 8+ years ago. My indie tradreprenuer has led me to write scripts that focus on sole traders to give them a financial edge in the markets.

# Table of Contents
- [Why upgrade to FX-Git-Pro?](#why-upgrade-to-fx-git-pro)
- [Table of Contents](#table-of-contents)
- [Benefits](#benefits)
- [Fx-Git-Pro](#fx-git-pro)
  - [Project Structure](#project-structure)
  - [Metatrader Modules](#metatrader-modules)
    - [1. Ghost-Mql](#1-ghost-mql)
    - [2. Python-Mql](#2-python-mql)
  - [Docker](#docker)
    - [1. Wine](#1-wine)
  - [Terraform](#terraform)
    - [1. DigitalOcean](#1-digitalocean)
- [Python, R and Metatrader for Trading](#python-r-and-metatrader-for-trading)

# Benefits

1. Metatrader blog posts that I write and publish [here](https://fxgit.work).
1. Updates, bug fixes, enhancements or new files.
1. Access to my private repository FX-Git-Pro.
1. Telegram chat community.
1. 1.5 hours of custom support.

# Fx-Git-Pro

1. As my collection of Metatrader 4 ["MT4"] and R scripts have grown considerable, this repository serves to remove clutter.
1. This repository has latest updates to MT4 packages and new resources, such as Python scripts.
1. This repository is available to members of [dennislwm's Patreon](https://www.patreon.com/dennislwm?fan_landing=true) only.
1. Each module or package, within its own subfolder, can be used as a standalone and has a README file.

## Project Structure

     FX-Git-Pro/              <-- Root of this project
       +- docker/             <-- Root of Docker images
       +- ghost/              <-- Metatrader Ghost
       +- mt4/                <-- Root of MT4 scripts
       +- python/             <-- Root of Python scripts
       +- python-mql/         <-- Python-Mql connector
       +- R/                  <-- Root of R scripts
       +- R-mql/              <-- R-Mql connector
       +- tf/                 <-- Root of Terraform modules

## Metatrader Modules 

My purpose is to write modular codes that can be used as plug-and-play. You can mix them or use them as standalones.

### 1. Ghost-Mql

Updated SqLite-MT4 wrapper to 3.8.2 that works with MT4 Build 600+.

[Ghost](https://gist.github.com/dennislwm/b153a1c8183f6e93864e348eca6601d6) - Paper trading module in Metatrader 4.

### 2. Python-Mql

Python-Mql - A Python to MQL connector using ZeroMQ

## Docker

A docker image is a self-contained environment that doesn't require any dependencies. It can run both locally or remotely.

Note: You need to check if your computer can run Docker before using it.

### 1. Wine

Wine - Docker image to run WINE on Ubuntu Linux system. Supports latest MT4 and MT5.

## Terraform

Terraform is a application that performs "infrastructure as a code". No more messy cloud interface.

### 1. DigitalOcean

Wine - Create, update and destroy a DigitalOcean droplet with Wine automatically.

# Python, R and Metatrader for Trading

Check back here for more updates, or you can read my articles in my [blog](https://fxgit.work).

