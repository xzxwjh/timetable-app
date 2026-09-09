Add-Type -AssemblyName System.Drawing

$outDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ($outDir -eq '') { $outDir = (Get-Location).Path }

$indigo      = [System.Drawing.Color]::FromArgb(255, 99, 102, 241)   # #6366f1
$indigoLight = [System.Drawing.Color]::FromArgb(255, 129, 140, 248) # #818cf8
$white       = [System.Drawing.Color]::White

function New-Icon([int]$size) {
  $bmp = New-Object System.Drawing.Bitmap($size, $size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear($indigo)

  $m = [int]($size * 0.1875)   # margin ~96 at 512
  $cw = $size - 2 * $m
  $cell = $cw / 3.0

  # white card
  $wb = New-Object System.Drawing.SolidBrush($white)
  $g.FillRectangle($wb, $m, $m, $cw, $cw)

  # highlighted top-left cell (当前课程)
  $ilb = New-Object System.Drawing.SolidBrush($indigoLight)
  $g.FillRectangle($ilb, $m, $m, [int]$cell, [int]$cell)

  # grid lines
  $th = [Math]::Max(1, [int]($size * 0.03))
  $ib = New-Object System.Drawing.SolidBrush($indigo)
  for ($i = 1; $i -le 2; $i++) {
    $pos = $m + [int]($cell * $i)
    $g.FillRectangle($ib, $pos - [int]($th/2), $m, $th, $cw)   # vertical
    $g.FillRectangle($ib, $m, $pos - [int]($th/2), $cw, $th)   # horizontal
  }

  $ib.Dispose(); $ilb.Dispose(); $wb.Dispose(); $g.Dispose()
  return $bmp
}

$full = New-Icon 512
$full.Save((Join-Path $outDir 'icon-512.png'), [System.Drawing.Imaging.ImageFormat]::Png)

function Save-Scaled($src, [int]$size, $name) {
  $dst = New-Object System.Drawing.Bitmap($size, $size)
  $g2 = [System.Drawing.Graphics]::FromImage($dst)
  $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g2.DrawImage($src, 0, 0, $size, $size)
  $g2.Dispose()
  $dst.Save((Join-Path $outDir $name), [System.Drawing.Imaging.ImageFormat]::Png)
  $dst.Dispose()
}

Save-Scaled $full 192 'icon-192.png'
Save-Scaled $full 180 'apple-touch-icon.png'
$full.Dispose()

Write-Output 'icons generated OK'
