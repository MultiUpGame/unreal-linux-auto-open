# unreal-linux-auto-open

Автоматично відкриває `.uproject` правильною версією Unreal Engine на Linux.
При подвійному кліку на `.uproject` — сам визначає версію і запускає потрібний редактор.

---

## Встановлення

```bash
bash install.sh
```

install.sh:
- Встановлює `zenity` якщо немає (підтримує pacman / apt / dnf)
- Копіює скрипт у `~/.local/bin/unreal-auto-open`
- Створює конфіг `~/.config/ue-versions.conf` (тільки якщо не існує)

Після встановлення відредагуй конфіг і додай свої версії UE.

Якщо змінив шляхи в конфігу — просто запусти `install.sh` знову, конфіг не перезапишеться.  
Щоб скинути конфіг до початкового: видали `~/.config/ue-versions.conf` і запусти знову.

---

## Конфіг — `~/.config/ue-versions.conf`

```ini
4.27 = /home/user/UE/UE4_27/Engine/Binaries/Linux/UE4Editor
5.4  = /home/user/UE/UE5_4/Engine/Binaries/Linux/UnrealEditor
```

Версія береться з поля `EngineAssociation` у `.uproject` файлі.

**Custom builds (зібрані з сорців)** використовують GUID замість версії:
```ini
{0004A0B4-08DE-9DB4-BB53-F9B8850D3D35} = /home/user/UE/UE4_27/Engine/Binaries/Linux/UE4Editor
```
GUID дивись у своєму `.uproject` файлі — поле `EngineAssociation`.

---

## Реєстрація в системі

Після встановлення скрипту — додай в налаштуваннях Quickshell:  
**Settings → Apps → Custom Apps → + Add**

```
Display Name   →  Unreal Engine
Executable     →  ~/.local/bin/unreal-auto-open %F
File extensions → .uproject
☑ Встановити як дефолтну
```

Один запис — працює для всіх версій UE.

---

## Що відбувається при помилці

| Ситуація | Вікно |
|---|---|
| Версія не знайдена в конфігу | Повідомлення з підказкою який рядок додати |
| Бінарник не існує за вказаним шляхом | Повідомлення з шляхом для перевірки |
| Конфіг не знайдено | Повідомлення де створити файл |

---

## Залежності

| Пакет | Навіщо |
|---|---|
| `zenity` | Вікна з помилками |
| `python3` | Читання JSON з `.uproject` |

Обидва є на більшості Linux дистрибутивів.
