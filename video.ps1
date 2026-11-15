# irm rez.248167.xyz/video|iex  ->  same as irm rez.248167.xyz|iex, then picks the 'video' profile.
$RezArgs = @('video')
try { irm https://raw.githubusercontent.com/morelanj/rez-boot/main/boot.ps1 | iex } finally { Remove-Variable RezArgs -ErrorAction SilentlyContinue }
