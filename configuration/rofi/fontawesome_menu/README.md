# Font Awesome Icon Selection Menu

`fontawesome-menu` - Display all FontAwesome icons in a rofi menu

## SYNOPSIS

`fontawesome-menu` [`-v`|`-h`][-f *listfile*] [-p PROMPT][output]

## DESCRIPTION

If `fontawesome-menu` is executed without options
or arguments, a list of all FontAwesome 5 Free
icons is displayed in a rofi menu. The selected icon
will be put into the clipboard.


> Note: This is mostly used internally without using 
> the terminal, but called from the keybinding `mod4+F4`,
>  the inclusion of the terminal options are a hold 
> over from the upstream source but retained to make 
> this potentially more useful to others interested 
> in this but not in the rest of the configuration
>  this is nested within.

## OPTIONS

`-v`  
 Show version and exit.

`-h`  
 Show help and exit.

`-f` _LISTfile_  
 file containing objects to display in the menu.
Defaults to _fa5-icon-list.txt_. More lists can
be found here:  
 <https://raw.githubusercontent.com/wstam88/rofi-fontawesome/>

`-p` PROMPT  
 PROMPT to display in the menu. Defaults to nothing.

`-o` _ROFI-OPTIONS_  
 Additional options to pass to `rofi`. Put the all options
in one quoted string. Example:
`fontawesome-menu -o '-i -columns 6 -width 100 -lines 20 -bw 2 -yoffset -2 -location 1'`

OUTPUT  
 Can be one of: icon|name|unicode  
 icon - Puts the icon in the clipboard (default)  
 name - Puts the name in the clipboard  
 unicode - Puts the unicode in the clipboard

EXAMPLES

---

```text
$ fontawesome-menu \
    -o "-columns 6 -width 100 -location 1 -lines 20 -i" \
    -p "Select icon: " \
    name
```

## DEPENDENCIES

rofi  
fontawesome  
xclip
