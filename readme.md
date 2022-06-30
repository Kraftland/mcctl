# minecraft-server-maintainer

---

minecraft-server-maintainer is a bash script that can automatically maintain your Minecraft server's core ( Spigot and Paper, currently) and some plug-ins.

# Usage

```bash
[Environment Variables] bash /Path/to/your/script.sh [Flags]
```

# Flags

## Update feature

***<u><mark>Notice: Type `update` flag to enable update feature.</mark></u>***

Examples:

```bash
version=1.19 serverPath=/mnt/main/Cache/Paper bash Main.sh update spigot sac geyser floodgate
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

## Start server feature (Experimental)

***<u><mark>Notice: Type <code>update</code> flag to enable start server feature.</mark></u>***

Examples:

```bash
version=1.19 serverPath=/mnt/main/Cache/Paper bash Main.sh start paper
```

| Flags  | Effects        |
| ------ | -------------- |
| paper  | Start PaperMC  |
| spigot | Start SpigotMC |

# Environment Variables

In order to achieve automated process, environment variables can be used.

| Variables  | Effects                               |
| ---------- | ------------------------------------- |
| version    | Define your Minecraft server version. |
| serverPath | Define your server path.              |
