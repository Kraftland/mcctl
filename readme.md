# minecraft-server-updater

---

minecraft-server-updater is a script that can automatically update your minecraft server and its components.

# Usage

```bash
[Environment Variables] bash /Path/to/your/script.sh -[options]
```

Examples:

```bash
version=1.19 serverPath=/mnt/main/Cache/Paper bash Update.sh -spigot -sac -geyser -floodgate
```

# Options

| Options | Effects |
| --- | --- |
| spigot | Update spigot. |
| paper | Update paper. |
| sac | Update sac (Beta support) |
| floodgate | Update floodgate. |
| geyser | Update geyser. |
| systemupdate | Fully update your system. (Run under root!) |
| unsafe | Disable default protecting. |

# Environment Variables

In order to achieve automated process, environment variables can be used.

| Variables | Effects |
| --- | --- |
| version | Define your Minecraft server version. |
| serverPath | Define your server path. |
