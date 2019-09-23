# Search

This is a (very powerfull) BASH script for doing searches with the internet browser of your choice, throw the command line or terminal.

## Why?  

Because I want to be more productive with my computer usage. This was my motivation.  
But it didn't take long to do a script that would suit any power user (Yes, being a power user is good).

## Dependencies

* Internet Browser (by default the `BROWSER_COMMAND` is set to `xdg-open`, which in Linux makes a call to system's default internet browser)

The rest of the dependencies you may already have on your Linux OS, which are:

* `mkdir`
* `sed`
* `basename`
* `grep`

* the rest are built-in bash shell commands such as `echo`, `exit`, `return`, `test`/`[`, `printf`, `local`, `eval`, `declare`, `export` and control flow bash constructs (if, then. else, fi, ... - well check the damn source code if you want to know more :smile: ! :sunrise_over_mountains: )

## Installation

### Easy way

Open a terminal window (optionally `cd` to a `$PATH` directory) and do:
```
wget https://raw.githubusercontent.com/alexandre1985/commandline-search-browser/master/search && chmod +x search
```

### Complete explanation

Just download the `search` script. You may want to put the script in a `$PATH` directory (for running `search` without needing `search`'s full path for its execution).

After you have made the download, don't forget to give `search` executable permissions. You can give those by using the command `chmod +x search`.

## Usage

```
search [search engine alias] any search term
```

for example:
```
search why my desire of freedom has not reach your knowleadge?
```

will do a "why my desire of freedom has not reach your knowleadge?" internet search on the alias `default` search engine.  

While:

```
search google why my desire of freedom has not reach your knowleadge?
``` 

will do a "why my desire of freedom has not reach your knowleadge?" internet search with the search engine alias `google`.  
As you may see on the configuration file (`var-and-aliases.conf`) the alias `google` points to the alias `g`, which in turn has a search engine URL. So, in this case, the search URL the script will use will be the url of the `g` alias.


## Configurations

### Configuration Directory

If `XDG_CONFIG_HOME` variable is set, `$XDG_CONFIG_HOME/commandline-search-browser/` will be the configuration directory. Or else will be `$HOME/.config/commandline-search-browser/`.

### Configuration File

There is one configuration file for this script, that live inside the [Configuration Directory](#configuration-directory) (which probably is located on `$HOME/.config/commandline-search-browser/`). It's name is `var-and-aliases.conf`.  

#### var-and-aliases.conf

This configuration file is generated automatically by running this script (`search`) for the first time.  
If `search` is not working, you may modify some variables of `var-and-aliases.conf` to match your OS.  
It is somewhat well documented. You can modify and configure it with ease.  

`var-and-aliases.conf` has search engine aliases for your `search` script usage. If no alias is detected, it will use the `default` alias.  

#### Add an search URL alias

To add a search engine alias you can add the following line to the configuration file

```
example=https://www.example.com/search?abc=%MYSEARCHTERM
```

With this line on the configuration file, doing `search example hey you` will do a search on the internet browser using the URL `https://www.example.com/search?abc=hey%20you` .

I said this is a powerfull script, so I will show you why.  
I'm gonna open up an advanced section, only for the purpose of configuring alias to do pretty advanced searches :wink:

## Advanced search engine alias configuration

Advanced search configuration are powered by bash parameter expansion (references: [Parameter Expansions - Bash Hackers Wiki](http://wiki.bash-hackers.org/syntax/pe) , [10.2. Parameter Substitution](http://www.tldp.org/LDP/abs/html/parameter-substitution.html) and [Bash Parameter Expansions](http://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html) ).  
You can use paramenter expansion within the configuration file.

### Simple example

You want to do a search using your system Linux username. You may (or may not) know that you can get your username by invoking the `whoami` command.

So, with to fullfill this purpose, you can add a search alias (to the configuration file) such as this:

```
me=https://www.google.com/search?q=${FUNC:-`whoami`}
```

The `${FUNC:-`whoami`}` is putting the output of the `whoami` command into the search url. It is giving dynamic behaviour to the configured search url.

### Simple example of adding an argument

You may want a `search` argument to be passed to the search url. For example, everytime the use the `smile` alias, we want the 3rd argument of our command to be passed to the search url. Here it is:

```
smile=https://www.example.com/beautiful-day/${3}/%MYSEARCHTERM
```

Invoking this script as `search smile "daniel is" standing in the shoulders of giants` will produce the following search url:

```
https://www.example.com/beautiful-day/daniel%20is/standing%20in%20the%20shoulders%20of%20giants
```

Nit.  

### Script built-in functions for the configuration file that you may find useful

Any function used within this script, can be used. I have made a special place in this script code with the purpose of writing functions to be used within the configuration file.

#### `show_if_else`

Function to show one or another word.  
  

Using this line
```
${FUNC:-`show_if_else ${2} auto pt en es`}
```

within the configuration file; it will fetch the second argument (because of ${2}) of the `search` script (for example, with `search smiling you are good` the second argument is the word "you"). Put this second argument in "${2}"'s place.  
Then if this second argument is the same word as "pt", "en" or "es" (which it is not, in the example that I gave) would give the output of that word ("pt", "en" or "es"). Since it is not, it will output the word "auto" ( "${2}" is the if, "auto" it is the else ).

#### `remove_first_word_if_it_belongs`

Function to remove the first word if match other words.  
  

Using this line
```
${FUNC:-`remove_first_word_if_belongs_to '%MYSEARCHTERM' pt en es fr it`}
```
within the configuration file; it will first fetch the search term we want to search for. Then it will replace %MYSEARCHTERM with this search term.  
If the first argument of this function ( which is %MYSEARCHTERM and corresponds to this script search term argument(s) ) begins with any of this words "pt en es fr it", these words will be removed; returning the remaining words. 

## Conclusion

I believe that is everything. I want you to be able to learn/edit/share this code with anyone, so I dedicate this script to the public domain with the chosen license.

If you want to give me some gift for creating this code, or just want to say something to me, go to [my personal page](https://alexandre1985.github.io/) and you can contact me throw there (using the personal page contact form).

## Final Message
Enjoy! ... Always  
:fireworks: :full_moon_with_face: :earth_africa:
