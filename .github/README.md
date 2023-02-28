# NixOS AwesomeWM configuration

![Dreams - a gif showing the aftermath of nuclear testing on Bikini Atoll that is emblematic of the process of configuring AwesomeWM](./assets/reams.gif)

> it sure is awesome alright...

## Table of Contents

- [Backgroun](#background)
- [Focus](#focus)
- [Install](#install)
- [Usage](#usage)
- [API](#api)
- [Contributing](#contributing)
- [License](#license)

## Background

At the core of my custom Linux environment is the configuration of AwesomeWM that I have written to provide for my entire **Desktop Environment** by leveraging the power of the `lua` programming language used to configure AwesomeWM and add in the features necessary to achieve a complete **Desktop Environment** (if a third party option wasn't available or optimal, life is too short to duplicate effort).

Due to the age of the Awesome Window Manager project and the efforts of the development team to maintain backwards compatibility for older configurations, there is a lot that can be done with Awesome's API and it enables a variety of different styles of programming that further enhance the

## Install

While this is included in my NixOS configuration, I don't blame you for not wanting to change distro and adjust to the NixOS way of doing things declaratively to test out my configuration, so I made it a submodule of that configuration for the interested public's usage and testing pleasure.

### The Safe Way

The safe way to test this configuration out is using [awmtt]() and targeting its `rc.lua` with it like so

```bash
git clone https://github.com/the-Electric-Tantra-Linux/awesomewm-nixos sanatana-awesome

awmtt -C sanatana-awesome/rc.lua

```

### Living Dangerously?

If you want to use it as is, follow the below

```bash
# back up your current configuration first
mv ~/.config/awesome ~/.config/awesome.bak

# pull in this one from GitHub
git clone https://github.com/the-Electric-Tantra-Linux/awesomewm-nixos

# restart awesome and it should work
```

### Any optional sections

## Usage

```

```

Note: The `license` badge image link at the top of this file should be updated with the correct `:user` and `:repo`.

### Any optional sections

## API

### Any optional sections

## More optional sections

## Contributing

See [the contributing file](CONTRIBUTING.md)!

PRs accepted.

Small note: If editing the Readme, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.


