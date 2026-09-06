$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$imageDir = Join-Path $projectRoot 'Image'
New-Item -ItemType Directory -Force -Path $imageDir | Out-Null

function New-Canvas {
    param([int]$Width, [int]$Height, [System.Drawing.Color]$Color)
    $bitmap = New-Object System.Drawing.Bitmap($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $graphics.Clear($Color)
    return @($bitmap, $graphics)
}

function Fill-Rect {
    param(
        [System.Drawing.Graphics]$Graphics,
        [System.Drawing.Color]$Color,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height
    )
    $brush = New-Object System.Drawing.SolidBrush($Color)
    try {
        $Graphics.FillRectangle($brush, $X, $Y, $Width, $Height)
    } finally {
        $brush.Dispose()
    }
}

function Fill-Polygon {
    param(
        [System.Drawing.Graphics]$Graphics,
        [System.Drawing.Color]$Color,
        [System.Drawing.Point[]]$Points
    )
    $brush = New-Object System.Drawing.SolidBrush($Color)
    try {
        $Graphics.FillPolygon($brush, $Points)
    } finally {
        $brush.Dispose()
    }
}

function Stroke-Rect {
    param(
        [System.Drawing.Graphics]$Graphics,
        [System.Drawing.Color]$Color,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [int]$Thickness = 2
    )
    Fill-Rect $Graphics $Color $X $Y $Width $Thickness
    Fill-Rect $Graphics $Color $X ($Y + $Height - $Thickness) $Width $Thickness
    Fill-Rect $Graphics $Color $X $Y $Thickness $Height
    Fill-Rect $Graphics $Color ($X + $Width - $Thickness) $Y $Thickness $Height
}

function Draw-Tree {
    param(
        [System.Drawing.Graphics]$Graphics,
        [int]$X,
        [int]$Y,
        [System.Drawing.Color]$Leaf = ([System.Drawing.Color]::FromArgb(255, 35, 91, 67))
    )
    $dark = [System.Drawing.Color]::FromArgb(255, 24, 62, 53)
    $light = [System.Drawing.Color]::FromArgb(255, 79, 137, 78)
    Fill-Rect $Graphics ([System.Drawing.Color]::FromArgb(255, 83, 58, 43)) ($X + 5) ($Y + 10) 3 9
    Fill-Rect $Graphics $dark ($X + 2) ($Y + 3) 10 11
    Fill-Rect $Graphics $Leaf $X ($Y + 5) 14 7
    Fill-Rect $Graphics $Leaf ($X + 3) $Y 9 14
    Fill-Rect $Graphics $light ($X + 3) ($Y + 3) 4 3
}

function Draw-WindowRow {
    param(
        [System.Drawing.Graphics]$Graphics,
        [int]$X,
        [int]$Y,
        [int]$Count,
        [System.Drawing.Color]$Glow
    )
    for ($i = 0; $i -lt $Count; $i++) {
        Fill-Rect $Graphics ([System.Drawing.Color]::FromArgb(255, 28, 48, 53)) ($X + $i * 11) $Y 8 8
        Fill-Rect $Graphics $Glow ($X + 2 + $i * 11) ($Y + 2) 5 4
    }
}

function Draw-PixelText {
    param(
        [System.Drawing.Graphics]$Graphics,
        [string]$Text,
        [System.Drawing.Color]$Color,
        [float]$X,
        [float]$Y,
        [float]$Size
    )
    $font = New-Object System.Drawing.Font('Consolas', $Size, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Object System.Drawing.SolidBrush($Color)
    $previousHint = $Graphics.TextRenderingHint
    try {
        $Graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::SingleBitPerPixelGridFit
        $Graphics.DrawString($Text, $font, $brush, $X, $Y)
    } finally {
        $Graphics.TextRenderingHint = $previousHint
        $brush.Dispose()
        $font.Dispose()
    }
}

function Save-Canvas {
    param(
        [System.Drawing.Bitmap]$Bitmap,
        [System.Drawing.Graphics]$Graphics,
        [string]$Name
    )
    try {
        $path = Join-Path $imageDir $Name
        $Bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $Graphics.Dispose()
        $Bitmap.Dispose()
    }
}

function New-CampusMap {
    $grass = [System.Drawing.Color]::FromArgb(255, 86, 132, 82)
    $grassDark = [System.Drawing.Color]::FromArgb(255, 62, 110, 72)
    $grassLight = [System.Drawing.Color]::FromArgb(255, 111, 151, 84)
    $path = [System.Drawing.Color]::FromArgb(255, 205, 191, 137)
    $pathLight = [System.Drawing.Color]::FromArgb(255, 231, 215, 158)
    $brick = [System.Drawing.Color]::FromArgb(255, 137, 58, 48)
    $brickLight = [System.Drawing.Color]::FromArgb(255, 187, 82, 55)
    $roof = [System.Drawing.Color]::FromArgb(255, 43, 59, 61)
    $gold = [System.Drawing.Color]::FromArgb(255, 238, 190, 73)
    $canvas = New-Canvas 480 270 $grass
    $bitmap, $g = $canvas

    # Dithered grass and mountain edge establish a readable world texture.
    for ($y = 8; $y -lt 268; $y += 12) {
        for ($x = 6 + (($y / 12) % 2) * 6; $x -lt 478; $x += 18) {
            Fill-Rect $g $grassLight $x $y 2 2
        }
    }
    Fill-Polygon $g ([System.Drawing.Color]::FromArgb(255, 48, 101, 79)) @(
        [System.Drawing.Point]::new(0, 0), [System.Drawing.Point]::new(480, 0),
        [System.Drawing.Point]::new(480, 28), [System.Drawing.Point]::new(430, 18),
        [System.Drawing.Point]::new(380, 31), [System.Drawing.Point]::new(318, 20),
        [System.Drawing.Point]::new(260, 34), [System.Drawing.Point]::new(200, 21),
        [System.Drawing.Point]::new(145, 30), [System.Drawing.Point]::new(90, 17),
        [System.Drawing.Point]::new(36, 29), [System.Drawing.Point]::new(0, 22)
    )
    Fill-Polygon $g ([System.Drawing.Color]::FromArgb(255, 28, 70, 64)) @(
        [System.Drawing.Point]::new(0, 0), [System.Drawing.Point]::new(480, 0),
        [System.Drawing.Point]::new(480, 11), [System.Drawing.Point]::new(430, 8),
        [System.Drawing.Point]::new(377, 17), [System.Drawing.Point]::new(314, 8),
        [System.Drawing.Point]::new(258, 20), [System.Drawing.Point]::new(194, 9),
        [System.Drawing.Point]::new(135, 17), [System.Drawing.Point]::new(72, 7),
        [System.Drawing.Point]::new(0, 15)
    )

    # Layered paths with curbs and small lamp studs.
    Fill-Rect $g $grassDark 10 231 460 23
    Fill-Rect $g $path 10 228 460 21
    Fill-Rect $g $pathLight 10 230 460 3
    Fill-Rect $g $grassDark 219 25 34 225
    Fill-Rect $g $path 222 25 28 225
    Fill-Rect $g $pathLight 225 25 4 225
    Fill-Rect $g $grassDark 27 118 426 26
    Fill-Rect $g $path 30 121 420 20
    Fill-Rect $g $pathLight 30 121 420 3
    for ($y = 37; $y -lt 224; $y += 26) {
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 74, 65, 45)) 232 $y 3 7
        Fill-Rect $g $gold 231 ($y - 2) 5 4
    }

    # Central lake with a stepped shoreline, water depth and animated-looking glints.
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 42, 91, 95)) 245 105 117 60
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 42, 91, 95)) 257 93 88 84
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 42, 133, 139)) 248 108 111 54
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 42, 133, 139)) 260 97 82 76
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 62, 163, 162)) 270 104 58 5
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 91, 192, 178)) 283 125 31 3
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 91, 192, 178)) 330 145 17 3
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 29, 105, 116)) 251 155 39 4
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 226, 210, 142)) 238 134 15 4

    # GEH: four red-brick academic wings and lit classroom strips.
    foreach ($rect in @(@(45,174,45,28), @(96,174,45,28), @(45,207,45,25), @(96,207,45,25))) {
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 49, 68, 61)) ($rect[0] + 4) ($rect[1] + 5) $rect[2] $rect[3]
        Fill-Rect $g $brick $rect[0] $rect[1] $rect[2] $rect[3]
        Fill-Rect $g $brickLight $rect[0] $rect[1] $rect[2] 4
        Draw-WindowRow $g ($rect[0] + 5) ($rect[1] + 8) 3 $gold
    }
    Fill-Rect $g $roof 40 169 106 7
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 226, 214, 174)) 74 192 36 8

    # CBPM and Athletics Center west of the lake.
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 50, 72, 65)) 82 96 64 38
    Fill-Rect $g $brickLight 77 91 64 38
    Fill-Rect $g $roof 74 87 70 7
    Draw-WindowRow $g 84 101 4 $gold
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 46, 72, 75)) 95 54 71 31
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 213, 223, 210)) 90 49 71 30
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 64, 126, 132)) 90 49 71 6
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 65, 100, 101)) 100 60 51 5
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 238, 239, 214)) 102 67 20 5

    # GHK on the central axis, with a deep entrance and stepped social lawn.
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 46, 68, 65)) 201 180 89 42
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 217, 211, 192)) 196 174 89 42
    Fill-Rect $g $brick 200 179 81 8
    Fill-Rect $g $brickLight 204 180 73 3
    Draw-WindowRow $g 207 192 6 ([System.Drawing.Color]::FromArgb(255, 119, 181, 178))
    Fill-Rect $g $roof 235 188 12 28
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 238, 192, 83)) 238 193 6 4
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 155, 183, 127)) 181 219 118 24
    Fill-Rect $g $grass 191 222 98 17
    Fill-Rect $g $grassLight 203 226 74 4

    # SLAC north of the lake: transparent beacon, layered roofs and warm activity.
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 40, 76, 79)) 207 53 94 41
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 60, 120, 128)) 201 47 94 41
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 149, 208, 194)) 207 53 82 27
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 47, 104, 111)) 207 75 82 5
    foreach ($x in @(213, 231, 249, 267)) {
        Fill-Rect $g $gold $x 59 9 13
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 255, 225, 129)) ($x + 2) 60 5 5
    }
    Fill-Rect $g $roof 197 43 102 7
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 231, 215, 159)) 236 35 25 8

    # Laboratory and residence/dining clusters to the east.
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 48, 75, 72)) 373 125 55 31
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 207, 218, 207)) 368 120 55 31
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 64, 126, 132)) 368 120 55 6
    Draw-WindowRow $g 375 132 4 ([System.Drawing.Color]::FromArgb(255, 149, 205, 195))
    foreach ($rect in @(@(355,42,38,43), @(401,42,38,43), @(378,91,50,28))) {
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 43, 67, 62)) ($rect[0] + 4) ($rect[1] + 5) $rect[2] $rect[3]
        Fill-Rect $g $brick $rect[0] $rect[1] $rect[2] $rect[3]
        Fill-Rect $g $brickLight $rect[0] $rect[1] $rect[2] 4
        Draw-WindowRow $g ($rect[0] + 5) ($rect[1] + 9) ([math]::Max(2, [math]::Floor(($rect[2] - 10) / 11))) $gold
    }

    # Tree rows, flower pixels and navigation signs provide small-scale rhythm.
    for ($x = 12; $x -lt 466; $x += 24) {
        if ($x -lt 224 -or $x -gt 248) { Draw-Tree $g $x 145 }
    }
    foreach ($tree in @(@(18,52), @(44,72), @(170,48), @(320,54), @(449,62), @(156,205), @(323,205), @(440,193))) {
        Draw-Tree $g $tree[0] $tree[1]
    }
    foreach ($flower in @(@(25,111), @(153,153), @(183,95), @(335,187), @(458,114), @(314,235))) {
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 246, 202, 82)) $flower[0] $flower[1] 3 3
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 225, 100, 88)) ($flower[0] + 3) ($flower[1] + 2) 2 2
    }
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 31, 55, 57)) 16 213 28 14
    Fill-Rect $g $gold 19 216 22 3
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 225, 230, 206)) 21 221 18 2

    Save-Canvas $bitmap $g 'campus-map.png'
}

function New-Interior {
    param(
        [string]$Name,
        [System.Drawing.Color]$Wall,
        [System.Drawing.Color]$Floor,
        [System.Drawing.Color]$Accent,
        [string]$Code
    )
    $canvas = New-Canvas 480 270 $Wall
    $bitmap, $g = $canvas

    $ink = [System.Drawing.Color]::FromArgb(255, 22, 31, 36)
    $inkSoft = [System.Drawing.Color]::FromArgb(255, 38, 49, 53)
    $cream = [System.Drawing.Color]::FromArgb(255, 235, 224, 188)
    $gold = [System.Drawing.Color]::FromArgb(255, 239, 190, 73)

    # Floor tiles use alternating values and a strong rear-wall shadow.
    Fill-Rect $g $Floor 0 64 480 206
    for ($row = 0; $row -lt 9; $row++) {
        for ($col = 0; $col -lt 20; $col++) {
            if (($row + $col) % 2 -eq 0) {
                Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, $Floor.R - 7, $Floor.G - 7, $Floor.B - 7)) ($col * 24) (64 + $row * 24) 23 23
            }
        }
    }
    Fill-Rect $g $ink 0 0 480 64
    Fill-Rect $g $inkSoft 0 50 480 14
    Fill-Rect $g $Accent 0 58 480 6
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 12, 20, 24)) 0 64 480 5

    # Three destinations, each with depth, glass and a warm interaction light.
    foreach ($x in @(50, 195, 340)) {
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 10, 18, 21)) ($x + 5) 23 90 42
        Fill-Rect $g $ink ($x) 17 90 42
        Stroke-Rect $g $Accent $x 17 90 42 3
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 71, 103, 103)) ($x + 34) 28 22 31
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 177, 222, 204)) ($x + 38) 31 14 18
        Fill-Rect $g $gold ($x + 41) 52 8 4
        Fill-Rect $g $Accent ($x + 8) 23 18 5
        Fill-Rect $g $cream ($x + 63) 23 18 3
    }

    # Architecture-specific decoration makes each building immediately recognizable.
    if ($Code -eq 'GHK') {
        for ($step = 0; $step -lt 5; $step++) {
            Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 104 + $step * 7, 73 + $step * 5, 54)) (186 + $step * 8) (86 + $step * 8) (108 - $step * 16) 8
        }
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 72, 49, 39)) 73 137 52 18
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 186, 126, 70)) 77 138 44 6
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 72, 49, 39)) 355 137 52 18
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 186, 126, 70)) 359 138 44 6
        foreach ($x in @(25, 445)) { Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 45, 105, 68)) $x 91 19 29; Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 103, 68, 43)) ($x + 6) 116 8 7 }
    } elseif ($Code -eq 'GEH') {
        foreach ($x in @(70, 215, 360)) {
            Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 226, 215, 178)) $x 80 50 28
            Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 56, 72, 69)) ($x + 5) 85 40 18
            Fill-Rect $g $Accent ($x + 10) 89 30 3
        }
        foreach ($x in @(74, 356)) {
            Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 84, 59, 49)) $x 142 51 16
            Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 176, 113, 66)) ($x + 4) 142 43 5
        }
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 68, 89, 85)) 209 133 62 20
        Draw-PixelText $g 'IDEAS' $cream 216 136 10
    } elseif ($Code -eq 'SLAC') {
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 45, 113, 120)) 18 76 112 45
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 126, 193, 183)) 24 82 100 30
        for ($x = 29; $x -lt 120; $x += 18) { Fill-Rect $g $gold $x 88 9 13 }
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 72, 51, 42)) 74 144 52 17
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 190, 132, 72)) 78 145 44 5
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 72, 51, 42)) 355 144 52 17
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 190, 132, 72)) 359 145 44 5
        foreach ($poster in @(@(157,79,22,32), @(300,80,22,31))) {
            Fill-Rect $g $cream $poster[0] $poster[1] $poster[2] $poster[3]
            Fill-Rect $g $Accent ($poster[0] + 4) ($poster[1] + 4) ($poster[2] - 8) 7
            Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 75, 91, 86)) ($poster[0] + 4) ($poster[1] + 16) ($poster[2] - 8) 3
        }
    } else {
        # HOME combines a cozy lounge, shared kitchen board and dining details.
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 72, 52, 47)) 58 139 69 20
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 188, 116, 68)) 62 139 61 6
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 72, 52, 47)) 353 139 69 20
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 188, 116, 68)) 357 139 61 6
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 226, 217, 182)) 204 83 72 39
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 66, 121, 112)) 210 89 60 7
        foreach ($noteX in @(213, 228, 243, 258)) { Fill-Rect $g $gold $noteX 102 8 10 }
        foreach ($x in @(25, 442)) { Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 54, 112, 72)) $x 92 18 27; Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 108, 70, 45)) ($x + 6) 115 7 8 }
    }

    # Central waypoint and subtle navigation inlay.
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 91, 74, 53)) 224 166 32 17
    Fill-Rect $g $gold 228 168 24 5
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 240, 222, 166)) 236 186 8 8
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 65, 82, 79)) 238 194 4 39
    Fill-Rect $g $Accent 236 231 8 8
    Draw-PixelText $g $Code $cream 213 111 17

    Save-Canvas $bitmap $g $Name
}

function New-Player {
    param([string]$Name, [System.Drawing.Color]$Jacket, [System.Drawing.Color]$Hair)
    $canvas = New-Canvas 32 48 ([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
    $bitmap, $g = $canvas

    $outline = [System.Drawing.Color]::FromArgb(255, 24, 29, 33)
    $skin = [System.Drawing.Color]::FromArgb(255, 239, 187, 143)
    $skinLight = [System.Drawing.Color]::FromArgb(255, 255, 211, 164)
    $shoe = [System.Drawing.Color]::FromArgb(255, 32, 38, 43)

    # Strong silhouette, separated feet and a small campus backpack.
    Fill-Rect $g $outline 7 42 8 6
    Fill-Rect $g $outline 18 42 8 6
    Fill-Rect $g $shoe 8 43 6 4
    Fill-Rect $g $shoe 19 43 6 4
    Fill-Rect $g $outline 8 29 8 15
    Fill-Rect $g $outline 17 29 8 15
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 47, 66, 82)) 10 30 5 13
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 47, 66, 82)) 18 30 5 13
    Fill-Rect $g $outline 5 16 23 18
    Fill-Rect $g $Jacket 7 18 19 14
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 239, 193, 75)) 15 19 3 12
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 225, 232, 218)) 11 19 4 7
    Fill-Rect $g $outline 8 6 18 16
    Fill-Rect $g $skin 10 8 14 12
    Fill-Rect $g $skinLight 12 9 9 3
    Fill-Rect $g $Hair 8 4 18 8
    Fill-Rect $g $Hair 7 7 4 10
    Fill-Rect $g $outline 13 14 2 2
    Fill-Rect $g $outline 20 14 2 2
    Fill-Rect $g $outline 25 19 4 12
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 64, 113, 115)) 26 21 3 8

    Save-Canvas $bitmap $g $Name
}

function New-Portrait {
    param(
        [string]$Name,
        [string]$Initials,
        [System.Drawing.Color]$Background,
        [System.Drawing.Color]$Jacket,
        [System.Drawing.Color]$Hair
    )
    $canvas = New-Canvas 64 64 $Background
    $bitmap, $g = $canvas

    $outline = [System.Drawing.Color]::FromArgb(255, 25, 31, 35)
    $skin = [System.Drawing.Color]::FromArgb(255, 238, 184, 140)
    $skinLight = [System.Drawing.Color]::FromArgb(255, 255, 211, 166)
    $gold = [System.Drawing.Color]::FromArgb(255, 241, 195, 78)

    # Graphic corner blocks keep portraits legible at 2x and 3x scales.
    Fill-Rect $g $outline 0 0 64 5
    Fill-Rect $g $outline 0 59 64 5
    Fill-Rect $g $outline 0 0 5 64
    Fill-Rect $g $outline 59 0 5 64
    Fill-Rect $g $gold 5 5 12 3
    Fill-Rect $g $gold 47 56 12 3
    Fill-Rect $g $outline 6 47 52 12
    Fill-Rect $g $Jacket 9 36 46 19
    Fill-Rect $g $outline 15 13 35 32
    Fill-Rect $g $skin 18 16 28 26
    Fill-Rect $g $skinLight 21 18 20 5
    Fill-Rect $g $Hair 14 9 36 13
    Fill-Rect $g $Hair 14 17 7 19
    Fill-Rect $g $outline 24 28 3 3
    Fill-Rect $g $outline 37 28 3 3
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 180, 91, 73)) 29 37 7 2
    Draw-PixelText $g $Initials $gold 17 48 10

    Save-Canvas $bitmap $g $Name
}

function New-TitleCampus {
    $sky = [System.Drawing.Color]::FromArgb(255, 19, 30, 43)
    $canvas = New-Canvas 480 270 $sky
    $bitmap, $g = $canvas

    # Dusk bands and sparse square stars.
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 28, 50, 65)) 0 62 480 58
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 46, 76, 81)) 0 120 480 50
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 199, 105, 70)) 0 170 480 17
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 236, 165, 80)) 0 180 480 10
    foreach ($star in @(@(28,26), @(76,48), @(132,22), @(188,39), @(251,18), @(301,52), @(347,27), @(412,43), @(454,19))) {
        Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 238, 220, 153)) $star[0] $star[1] 2 2
    }
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 247, 221, 139)) 395 31 22 22
    Fill-Rect $g $sky 389 25 22 22

    # Mountain layers frame the campus without turning it into a flat silhouette.
    Fill-Polygon $g ([System.Drawing.Color]::FromArgb(255, 36, 77, 69)) @(
        [System.Drawing.Point]::new(0,150), [System.Drawing.Point]::new(55,113), [System.Drawing.Point]::new(99,144),
        [System.Drawing.Point]::new(157,103), [System.Drawing.Point]::new(220,148), [System.Drawing.Point]::new(286,109),
        [System.Drawing.Point]::new(342,143), [System.Drawing.Point]::new(410,99), [System.Drawing.Point]::new(480,151),
        [System.Drawing.Point]::new(480,205), [System.Drawing.Point]::new(0,205)
    )
    Fill-Polygon $g ([System.Drawing.Color]::FromArgb(255, 25, 57, 57)) @(
        [System.Drawing.Point]::new(0,170), [System.Drawing.Point]::new(76,135), [System.Drawing.Point]::new(141,174),
        [System.Drawing.Point]::new(221,128), [System.Drawing.Point]::new(298,172), [System.Drawing.Point]::new(379,132),
        [System.Drawing.Point]::new(480,170), [System.Drawing.Point]::new(480,216), [System.Drawing.Point]::new(0,216)
    )

    # Original campus beacon: glass center, brick wings, warm windows and lake reflection.
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 22, 39, 43)) 150 173 220 59
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 120, 51, 45)) 143 164 82 65
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 171, 68, 50)) 143 164 82 7
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 120, 51, 45)) 275 164 82 65
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 171, 68, 50)) 275 164 82 7
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 53, 119, 124)) 220 145 60 84
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 135, 198, 187)) 226 151 48 70
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 239, 190, 73)) 241 134 18 11
    Draw-WindowRow $g 153 181 6 ([System.Drawing.Color]::FromArgb(255, 242, 194, 78))
    Draw-WindowRow $g 285 181 6 ([System.Drawing.Color]::FromArgb(255, 242, 194, 78))
    for ($x = 231; $x -lt 271; $x += 12) { Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 247, 210, 107)) $x 164 7 13 }
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 16, 42, 48)) 0 229 480 41
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 35, 102, 111)) 0 235 480 35
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 62, 142, 139)) 173 242 154 4
    Fill-Rect $g ([System.Drawing.Color]::FromArgb(255, 226, 157, 68)) 220 252 60 3

    foreach ($tree in @(@(17,203), @(42,211), @(88,199), @(371,201), @(417,210), @(452,198))) {
        Draw-Tree $g $tree[0] $tree[1] ([System.Drawing.Color]::FromArgb(255, 29, 76, 61))
    }

    Save-Canvas $bitmap $g 'title-campus.png'
}

New-CampusMap
New-TitleCampus
New-Interior 'interior-ghk.png' ([System.Drawing.Color]::FromArgb(255, 40, 50, 55)) ([System.Drawing.Color]::FromArgb(255, 185, 161, 116)) ([System.Drawing.Color]::FromArgb(255, 154, 71, 58)) 'GHK'
New-Interior 'interior-geh.png' ([System.Drawing.Color]::FromArgb(255, 57, 51, 48)) ([System.Drawing.Color]::FromArgb(255, 178, 151, 121)) ([System.Drawing.Color]::FromArgb(255, 135, 57, 50)) 'GEH'
New-Interior 'interior-slac.png' ([System.Drawing.Color]::FromArgb(255, 31, 55, 59)) ([System.Drawing.Color]::FromArgb(255, 128, 171, 161)) ([System.Drawing.Color]::FromArgb(255, 228, 188, 91)) 'SLAC'
New-Interior 'interior-dorm.png' ([System.Drawing.Color]::FromArgb(255, 55, 48, 48)) ([System.Drawing.Color]::FromArgb(255, 175, 142, 112)) ([System.Drawing.Color]::FromArgb(255, 58, 132, 129)) 'HOME'

New-Player 'player-male.png' ([System.Drawing.Color]::FromArgb(255, 42, 143, 159)) ([System.Drawing.Color]::FromArgb(255, 52, 39, 34))
New-Player 'player-female.png' ([System.Drawing.Color]::FromArgb(255, 183, 72, 88)) ([System.Drawing.Color]::FromArgb(255, 55, 35, 34))

New-Portrait 'portrait-al.png' 'A.L.' ([System.Drawing.Color]::FromArgb(255, 61, 112, 113)) ([System.Drawing.Color]::FromArgb(255, 141, 65, 56)) ([System.Drawing.Color]::FromArgb(255, 47, 39, 36))
New-Portrait 'portrait-jr.png' 'J.R.' ([System.Drawing.Color]::FromArgb(255, 115, 74, 83)) ([System.Drawing.Color]::FromArgb(255, 45, 110, 131)) ([System.Drawing.Color]::FromArgb(255, 63, 48, 39))
New-Portrait 'portrait-sy.png' 'S.Y.' ([System.Drawing.Color]::FromArgb(255, 54, 104, 83)) ([System.Drawing.Color]::FromArgb(255, 203, 151, 63)) ([System.Drawing.Color]::FromArgb(255, 41, 38, 39))
New-Portrait 'portrait-mc.png' 'M.C.' ([System.Drawing.Color]::FromArgb(255, 99, 92, 123)) ([System.Drawing.Color]::FromArgb(255, 61, 127, 113)) ([System.Drawing.Color]::FromArgb(255, 50, 36, 31))

Write-Host "Generated pixel assets in $imageDir"
