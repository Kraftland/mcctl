# minecraft-server-control

---

mcctl (aka minecraft-server-control) is a bash script that can automatically maintain your Minecraft server.# Usage

```bash
[Environment Variables] zsh /Path/to/your/script.sh [Flags]
```

# Flags

## Install script as a command `mcctl` (Recommended)

- Type `install` flag.

## Update

***<u><mark>Notice: Type `update` flag to enable update feature.</mark></u>***

Examples:

```bash
version=1.19 serverPath=/mnt/main/Cache/Paper zsh mcctl.sh update spigot sac geyser floodgate
```

| Flags        | Effects                                                                     |
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

## Uninstall script and service

- Type `mcctl remove` to uninstall

## Start server (Experimental)

***<u><mark>Notice: Type <code>start</code> flag to enable start server feature.</mark></u>***

Examples:

```bash
version=1.19 serverPath=/mnt/main/Cache/Paper bash mcctl.sh start paper d
```

| Flags  | Effects                                                     |
| ------ | ----------------------------------------------------------- |
| paper  | Start PaperMC                                               |
| spigot | Start SpigotMC                                              |
| d      | Run Minecraft in screen sockets. (Require screen installed) |

## Load Minecraft server on startup

First type `autostart` flag.

**Notice: Require script installed at`/usr/bin/mcctl`**

Example:

```bash
version=1.19 serverPath=/mnt/main/Cache/Paper bash mcctl.sh autostart start paper d
```

Equals to

```systemd
[Unit]
Description=minecraft-server-maintainer's start module
[Service]
ExecStart=env version=1.19 serverPath=/mnt/main/Cache/Paper mcctl start paper d
[Install]
WantedBy=multi-user.target
```

## Install requirements

| Flags   | Effects              |
| ------- | -------------------- |
| instreq | Install requirements |

# Environment Variables

| Variables  | Effects                               |
| ---------- | ------------------------------------- |
| version    | Define your Minecraft server version. |
| serverPath | Define your server path.              |

# Tips and tricks

## How to set environment variables permanently?

Edit your `/etc/environment`

type your environment variables as KEY=PAL

Examples:

```bash
version=1.19
serverPath=/mnt/main/Cache/Paper
```

## How to update my `mcmt` command?

Just type `mcmt install` again, script will handle it automatically

## Script throws an error code

Script have a built-in debug system, it will automatically detect error code and give possible solutions. Don't panic and follow instructions
