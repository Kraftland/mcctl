# minecraft-server-updater

---

minecraft-server-updater is a script that can automatically update your minecraft server and its components.

# Usage

```bash
[Environment Variables] bash /Path/to/your/script.sh -[options]
```

# Options

| Options      | Effects                                     |
| ------------ | ------------------------------------------- |
| spigot       | Update spigot.                              |
| paper        | Update paper.                               |
| sac          | Update sac (Beta support)                   |
| floodgate    | Update floodgate.                           |
| geyser       | Update geyser.                              |
| systemupdate | Fully update your system. (Run under root!) |
| nocheck      | Disable default protecting.                 |

# Environment Variables

In order to achieve automated process, environment variables can be used.

| Variables  | Effects                               |
| ---------- | ------------------------------------- |
| version    | Define your Minecraft server version. |
| serverPath | Define your server path.              |
