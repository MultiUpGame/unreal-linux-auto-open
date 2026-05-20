# unreal-linux-auto-open

Automatically opens `.uproject` files with the correct version of Unreal Engine on Linux.
Double-click on any `.uproject` — it detects the version and launches the right editor.

![preview](unreal-auto-open.png)

---

## Install

```bash
git clone https://github.com/MultiUpGame/unreal-linux-auto-open.git
cd unreal-linux-auto-open
bash install.sh
```

Then edit the config:

```bash
nano ~/.config/ue-versions.conf
```

---

## Config

Set paths to your installed UE versions:

```ini
4.27 = /home/user/UE/UE4_27/UnrealEngine/Engine/Binaries/Linux/UE4Editor
5.4  = /home/user/UE/UE5_4/UnrealEngine/Engine/Binaries/Linux/UnrealEditor
```

**Custom/source builds** use a GUID instead of a version number — find it in your `.uproject` file under `EngineAssociation`:

```ini
{0004A0B4-08DE-9DB4-BB53-F9B8850D3D35} = /home/user/UE/UE4_27/UnrealEngine/Engine/Binaries/Linux/UE4Editor
```

---

## What install.sh does

- Installs `zenity` if not present
- Copies the script to `~/.local/bin/`
- Registers `.uproject` as a file type in the system
- Creates launcher entries for each UE version in your config
- Sets the default app for `.uproject` files

After install, double-clicking a `.uproject` immediately opens it with the correct UE version.

---

## Dependencies

- `zenity` — installed automatically
- `python3` — available on most Linux distributions
