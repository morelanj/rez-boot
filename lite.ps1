# irm 248167.xyz/lite|iex  ->  same as irm 248167.xyz|iex, then picks the 'lite' profile.
$RezArgs = @('lite')
try { irm https://raw.githubusercontent.com/morelanj/rez-boot/main/boot.ps1 | iex } finally { Remove-Variable RezArgs -ErrorAction SilentlyContinue }
