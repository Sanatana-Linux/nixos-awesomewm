# Installation of This Configuration

While this is included in my NixOS configuration, I don't blame you for not wanting to change distro and adjust to the NixOS way of doing things declaratively to test out my configuration, so I made it a submodule of that configuration for the interested public's usage and testing pleasure.

## The Safe Way

The safe way to test this configuration out is using awmtt and targeting its rc.lua with it like so

```bash

git clone https://github.com/the-Electric-Tantra-Linux/awesomewm-nixos sanatana-awesome

awmtt -C sanatana-awesome/rc.lua

```

## Living Dangerously?

If you want to use it as is, follow the below

```bash
# back up your current configuration first
mv ~/.config/awesome ~/.config/awesome.bak

# pull in this one from GitHub
git clone https://github.com/the-Electric-Tantra-Linux/awesomewm-nixos

# restart awesome and it should work
```
