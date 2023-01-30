<h1> Awesome Window Manager Configuration </h1>

<div>
<img src="null" alt="placeholder"/>
</div>


<p>This is the configuration of AwesomeWM that I have included within my NixOS configuration and represents my personal configuration that I use as my sole daily driver and is the product and central portion of my customized and personally optimized OS environment I have tailored to my wants and needs to streamline my work as a developer among other things I use the <i>Graphical User Interface</i> of my system to do.</p>


<h3>Why Not a Submodule?</h3>

<p>In theory this would be great as a submodule, but only if I wanted to detatch it at a specific commit for use in my overall configuration but that would imply that I would not need to work on it anymore or if I did work on it, would do so elsewhere then update my NixOS submodules before running the `nixos rebuild switch --impure --flake '#blah'` command, which is two extra steps to do before restarting awesome to test if I broke it or not.</p>

<h4><b>Thanks, but no thanks</b></h4>

<p>Instead, the NixOS is turning into a monorepo and I am symlinking this and some other elements of my dotfiles to the user's home directory with home-manager to enable me to not even need to rebuild nixos in order to test Awesome with a restart. Sure it is a bit hacky, but so are nix flakes and NixOS in general and frankly, so am I.</p>

<small>to be fair, I could have a separate repo located at my user configuration which would invalidate the test I run in the Nix configuration to symlink the configuration during the rebuild/install process and then include it in the NixOS configuration as a submodule.</small>

<h2>I Want This But I Don't Use NixOS</h2>
<p>I am working on creating some means of automatically extracting and then uploading this configuration to a separate repo, which I am imagining will be something I will use git hooks to do, but this is on the back burner for now.</p>
<br/>
<p>To do this on your own, download this repo as a zip or tar archive, unpack it and pull the configuration from <span background="#000" color="white">users/tlh/cfg/awesome</span>, copying it to your <span background="black" color="white">~/.config/awesome</span> directory.</p>

