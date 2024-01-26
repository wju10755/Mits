# Set the wallpaper style to 'fit'
$key = 'HKCU:Control Panel\Desktop'
Set-ItemProperty -Path $key -Name 'WallpaperStyle' -Value 6
Set-ItemProperty -Path $key -Name 'TileWallpaper' -Value 0

# Re-start windows Explorer
Stop-Process -ProcessName explorer
