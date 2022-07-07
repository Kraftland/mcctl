# mcctl

---

`mcctl` (aka minecraft-server-sontrol) is a bash script which can automatically run and update your minecraft server.

# Usage

```bash
[Environment Variables] mcctl [Options]
```

Examples:

```bash
version=1.19 serverPath=/mnt/main/Cache/Paper zsh mcctl.sh update spigot paper sac geyser floodgate
```

## Install mcctl as a system command (Not required)

Note: If you haven't installed mcctl to your system, just replace `mcctl` with `./mcctl.sh`

```bash
git clone https://github.com/Kimiblock/mcctl.git && cd mcctl && ./mcctl.sh -install
```

## Uninstall mcctl command

```bash
mcctl -remove
```

## Update your Minecraft server and plugins

```bash
mcctl -update [options]
```

| Options      | Effects                                                                     |
| ------------ | --------------------------------------------------------------------------- |
| spigot       | Update spigot.                                                              |
| paper        | Update paper.                                                               |
| sac          | Update sac (Beta support)                                                   |
| floodgate    | Update floodgate.                                                           |
| geyser       | Update geyser.                                                              |
| systemupdate | Fully update your system. ( Run with `sudo` when `-unattended` activated! ) |
| unsafe       | Disable default protecting.                                                 |
| outtolog     | Redirect output to several log files.                                       |
| newserver    | Automatically create server folder.                                         |
| nosudo       | Do not use sudo for system update.                                          |
| clean        | Clean leftovers.                                                            |

## Load server at startup

```bash
[Environment Variables] mcctl -start -[server name] -d
```

| Server name | Effects        |
| ----------- | -------------- |
| paper       | Start PaperMC  |
| spigot      | Start SpigotMC |

Note: Install `screen` if you add -d, you can go back to your server session by `screen -r mc`.

## Install requirements (Currently in beta, only pacman recives full support)

| Options | Effects              |
| ------- | -------------------- |
| instreq | Install requirements |



# Tips and tricks

## Delete Spigot BuildTools' cache and script's logs

```bash
mcctl -clean
```

## Bypass entering environment variables

Edit `/etc/environment`, add those lines:

```/etc/environment
version=Your version
serverPath=Your path to server
```

Then reboot or re-login

## Update `mcmt` command?

Just type `mcmt install` again, script will download the latest version of itself and perform updates.



## Update server everyday?

Get the cronie package and enable `cronie.service`.

Type `crontab -e` and enter those line:

```
0 0 * * * mcctl [Options]
```

Check if you have environment variables set, either in `/etc/environment` or before `mcctl`

Don't forget to add a `-unattended` option or you won't be able to inspect any output from script

***<u><mark>Warning: you have to manually restart the server, otherwise some plugins WON'T use new features.</mark></u>***

## How to create a entirely new server?

Just add a `newserver` option, script will automatically handle it.

# To-dos

1. ~~Save configurations to `~/.config`.~~

2. Automatically detect what plugins you installed.

# Known bugs

- Spigot's own build tools may occationally crash, `mcctl -clean` might fix it.

- Do not use `manjaro-zsh-config-git` in aur or you might experience screen problems.
