# rez-boot

Public loader for my private machine-setup tool. On a fresh Windows machine, in PowerShell (no admin needed):

```powershell
iex "& { $(irm https://raw.githubusercontent.com/morelanj/rez-boot/main/boot.ps1) } lite"
```

It installs Scoop, Git and the GitHub CLI if missing, signs in to GitHub in the browser, then clones the private repo and runs its setup. This repo holds no secrets.

`boot.ps1` is copied from `public/boot.ps1` in the private repo; edit it there.
