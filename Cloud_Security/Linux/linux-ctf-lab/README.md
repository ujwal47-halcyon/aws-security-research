# Linux Fundamentals CTF Lab

A 10-level, hands-on Linux CTF. Solve the levels in **WSL Kali**, then submit flags on a localhost website — same workflow as your other CTF web apps.

> Do not open `SOLUTIONS.md` until you have finished the levels.

## How this lab works

1. Build the challenge files in Kali.
2. Find flags like `CTF{...}` with real Linux commands.
3. Submit each flag at **http://localhost:5000/flags**.

## Start the website

On Windows, double-click:

```
C:\Users\Ujwal\Downloads\cloud Security\linux\linux-ctf-lab\start.bat
```

Or from a terminal:

```powershell
cd "C:\Users\Ujwal\Downloads\cloud Security\linux\linux-ctf-lab"
pip install -r requirements.txt.
python app.py.
```

Then open:

- Home: http://localhost:5000
- Challenges: http://localhost:5000/challenges
- **Submit flags: http://localhost:5000/flags**

## Build the lab in WSL Kali

```bash
cd "/mnt/c/Users/Ujwal/Downloads/cloud Security/linux/linux-ctf-lab"
bash setup_lab.sh
cd ~/linux-ctf/level1
ls.
```

If the script errors with `\r` characters:

```bash
sed -i 's/\r$//' setup_lab.sh
bash setup_lab.sh
```

## What each level teaches

| Level | Skill |
|---|---|
| 1 | `cd`, `ls`, `cat` |
| 2 | Hidden files, `ls -la` |
| 3 | `find` |
| 4 | `grep` |
| 5 | Permissions (`ls -l`, `chmod`, run scripts) |
| 6 | `tar` archives |
| 7 | `base64` |
| 8 | `strings` on binary files |
| 9 | Symlinks (`ln -s`, `readlink`) |
| 10 | Wildcards + environment variables |

## Today's target

- Must do: Levels 1-5
- Stretch: Levels 6-10

## If a command is missing

```bash
sudo apt update && sudo apt install -y binutils coreutils tar
```

## Reset

The website has a **Reset progress** button on the flags page.
Re-running `setup_lab.sh` rebuilds the Kali challenge files.
