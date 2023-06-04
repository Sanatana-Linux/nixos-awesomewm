<!-- vscode-markdown-toc -->
* [Current State:](#CurrentState:)
* [Background](#Background)
* [Install](#Install)
	* [The Safe Way](#TheSafeWay)
	* [Living Dangerously?](#LivingDangerously)
* [Looking for Widgets, Modules or Libraries Composed of Them?](#LookingforWidgetsModulesorLibrariesComposedofThem)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc --># NixOS AwesomeWM configuration


## <a name='CurrentState:'></a>Current State:


<img src="./assets/dreams.gif" width="100%" alt="Dreams - a gif showing the aftermath of nuclear testing on Bikini Atoll that is emblematic of the process of configuring AwesomeWM"/>

**Work In Progress**

----
## <a name='Background'></a>Background

At the core of my custom Linux environment is the configuration of AwesomeWM that I have written to provide for my entire Desktop Environment by leveraging the power of the lua programming language used to configure AwesomeWM and add in the features necessary to achieve a complete Desktop Environment (if a third party option wasn't available or optimal, life is too short to duplicate effort).

Due to the age of the Awesome Window Manager project and the efforts of the development team to maintain backwards compatibility for older configurations, there is a lot that can be done with Awesome's API and it enables a variety of different styles of programming that further enhance the
## <a name='Install'></a>Install

While this is included in my NixOS configuration, I don't blame you for not wanting to change distro and adjust to the NixOS way of doing things declaratively to test out my configuration, so I made it a submodule of that configuration for the interested public's usage and testing pleasure.

### <a name='TheSafeWay'></a>The Safe Way

The safe way to test this configuration out is using awmtt and targeting its rc.lua with it like so

```bash

git clone https://github.com/the-Electric-Tantra-Linux/awesomewm-nixos sanatana-awesome

awmtt -C sanatana-awesome/rc.lua

```

### <a name='LivingDangerously'></a>Living Dangerously?

If you want to use it as is, follow the below
```bash
# back up your current configuration first
mv ~/.config/awesome ~/.config/awesome.bak

# pull in this one from GitHub
git clone https://github.com/the-Electric-Tantra-Linux/awesomewm-nixos

# restart awesome and it should work
```


## <a name='LookingforWidgetsModulesorLibrariesComposedofThem'></a>Looking for Widgets, Modules or Libraries Composed of Them?

I have an obsessive list of them, related to AwesomeWM of course, I maintain on Github [check it out here](https://github.com/Thomashighbaugh/Awesome-AwesomeWM-Modules-Widgets-And-Libraries) and don't forget to star the repo while you are there :wink:

For the innumerable configurations that have inspired me and other AwesomeWM related goodness, check out [my GitHub starlist dedicated to AwesomeWM](https://github.com/stars/Thomashighbaugh/lists/awesomewm)
