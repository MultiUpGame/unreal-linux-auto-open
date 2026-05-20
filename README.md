# unreal-linux-auto-open

Автоматично відкриває `.uproject` правильною версією Unreal Engine на Linux.
При подвійному кліку на `.uproject` — сам визначає версію і запускає потрібний редактор.

![preview](unreal-auto-open.png)

---

## Встановлення

```bash
git clone https://github.com/MultiUpGame/unreal-linux-auto-open.git
cd unreal-linux-auto-open
bash install.sh
```

Після встановлення відредагуй конфіг:

```bash
nano ~/.config/ue-versions.conf
```

---

## Конфіг

Вкажи шляхи до своїх версій UE:

```ini
4.27 = /home/user/UE/UE4_27/UnrealEngine/Engine/Binaries/Linux/UE4Editor
5.4  = /home/user/UE/UE5_4/UnrealEngine/Engine/Binaries/Linux/UnrealEditor
```

**Custom builds** (зібрані з сорців) використовують GUID — його видно в `.uproject` файлі в полі `EngineAssociation`:

```ini
{0004A0B4-08DE-9DB4-BB53-F9B8850D3D35} = /home/user/UE/UE4_27/UnrealEngine/Engine/Binaries/Linux/UE4Editor
```

---

## Що робить install.sh

- Встановлює `zenity` якщо немає
- Копіює скрипт у `~/.local/bin/`
- Реєструє `.uproject` як тип файлу в системі
- Створює ярлики для кожної версії UE з лаунчера
- Встановлює дефолтну програму для `.uproject`

Після встановлення подвійний клік на `.uproject` одразу відкриває правильну версію UE.

---

## Залежності

- `zenity` — встановлюється автоматично
- `python3` — є на більшості Linux дистрибутивів
