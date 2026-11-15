# irm 248167.xyz/full|iex  ->  same as irm 248167.xyz|iex, then picks the 'full' profile.
$RezArgs = @('full')
try { irm https://raw.githubusercontent.com/morelanj/rez-boot/main/boot.ps1 | iex } finally { Remove-Variable RezArgs -ErrorAction SilentlyContinue }
