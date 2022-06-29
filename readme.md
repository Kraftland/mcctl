# minecraft-server-updater

---

minecraft-server-updater is a bash script that can automatically update your Minecraft server's core ( Spigot and Paper, currently) and some plug-ins.

# Usage

```bash
[Environment Variables] bash /Path/to/your/script.sh -[Flags]
```

Examples:

```bash
version=1.19 serverPath=/mnt/main/Cache/Paper bash Update.sh -spigot -sac -geyser -floodgate
```

# Flags

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

# Environment Variables

In order to achieve automated process, environment variables can be used.

| Variables  | Effects                               |
| ---------- | ------------------------------------- |
| version    | Define your Minecraft server version. |
| serverPath | Define your server path.              |
