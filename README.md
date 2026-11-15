# rez-boot

Public loader for my private machine-setup tool. On a fresh Windows machine, in PowerShell (no admin needed):

```powershell
irm rez.248167.xyz|iex        # asks which profile
irm rez.248167.xyz/ai|iex     # straight to a profile: lite, ai, video, full
```

rez.248167.xyz redirects here: `/` to `boot.ps1`, `/<profile>` to `<profile>.ps1`.

It installs Scoop, Git and the GitHub CLI if missing, signs in to GitHub in the browser, then clones the private repo and runs its setup. This repo holds no secrets.

`boot.ps1` is copied from `public/boot.ps1` in the private repo; edit it there.
