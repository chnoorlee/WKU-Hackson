$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$outputDir = Join-Path $projectRoot 'Image\Characters'
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

function New-Color {
	param([string]$Hex)
	return [System.Drawing.ColorTranslator]::FromHtml($Hex)
}

$ink = New-Color '#202433'
$skin = New-Color '#FFD1B8'
$skinShadow = New-Color '#E8A78F'
$white = New-Color '#F4F1E9'
$blush = New-Color '#E98F91'

function New-Brush {
	param([System.Drawing.Color]$Color)
	return [System.Drawing.SolidBrush]::new($Color)
}

function Fill-Rect {
	param($Graphics, [System.Drawing.Color]$Color, [int]$X, [int]$Y, [int]$Width, [int]$Height)
	$brush = New-Brush $Color
	try { $Graphics.FillRectangle($brush, $X, $Y, $Width, $Height) } finally { $brush.Dispose() }
}

function Fill-Ellipse {
	param($Graphics, [System.Drawing.Color]$Color, [int]$X, [int]$Y, [int]$Width, [int]$Height)
	$brush = New-Brush $Color
	try { $Graphics.FillEllipse($brush, $X, $Y, $Width, $Height) } finally { $brush.Dispose() }
}

function Fill-Poly {
	param($Graphics, [System.Drawing.Color]$Color, [System.Drawing.Point[]]$Points)
	$brush = New-Brush $Color
	try { $Graphics.FillPolygon($brush, $Points) } finally { $brush.Dispose() }
}

function Draw-Line {
	param($Graphics, [System.Drawing.Color]$Color, [int]$Width, [int]$X1, [int]$Y1, [int]$X2, [int]$Y2)
	$pen = [System.Drawing.Pen]::new($Color, $Width)
	try { $Graphics.DrawLine($pen, $X1, $Y1, $X2, $Y2) } finally { $pen.Dispose() }
}

function Draw-Accessory {
	param($Graphics, [string]$Kind, [System.Drawing.Color]$Accent, [System.Drawing.Color]$Hair)
	if ($Kind -eq 'camera') {
		Draw-Line $Graphics $ink 4 58 146 122 200
		Fill-Rect $Graphics $ink 69 184 43 31
		Fill-Rect $Graphics $Accent 73 188 35 23
		Fill-Ellipse $Graphics $ink 82 191 18 18
		Fill-Ellipse $Graphics (New-Color '#78C9D2') 86 195 10 10
	} elseif ($Kind -eq 'glasses') {
		Draw-Line $Graphics $ink 2 63 78 84 78
		Draw-Line $Graphics $ink 2 96 78 117 78
		Draw-Line $Graphics $ink 2 84 78 96 78
		Draw-Line $Graphics $ink 2 63 78 63 88
		Draw-Line $Graphics $ink 2 117 78 117 88
	} elseif ($Kind -eq 'headphones') {
		Draw-Line $Graphics $Accent 5 54 64 59 42
		Draw-Line $Graphics $Accent 5 121 64 116 42
		Draw-Line $Graphics $Accent 4 59 42 116 42
		Fill-Rect $Graphics $ink 49 67 10 25
		Fill-Rect $Graphics $ink 121 67 10 25
	} elseif ($Kind -eq 'clipboard') {
		Fill-Rect $Graphics $ink 103 172 45 60
		Fill-Rect $Graphics (New-Color '#E9E4D5') 107 177 37 50
		Fill-Rect $Graphics $Accent 117 171 17 8
		Fill-Rect $Graphics $ink 112 188 27 2
		Fill-Rect $Graphics $ink 112 197 22 2
		Fill-Rect $Graphics $ink 112 206 25 2
	} elseif ($Kind -eq 'scarf') {
		Fill-Poly $Graphics $Accent @(
			[System.Drawing.Point]::new(61, 126), [System.Drawing.Point]::new(120, 126),
			[System.Drawing.Point]::new(113, 148), [System.Drawing.Point]::new(70, 148)
		)
		Fill-Poly $Graphics $Accent @(
			[System.Drawing.Point]::new(100, 143), [System.Drawing.Point]::new(119, 143),
			[System.Drawing.Point]::new(131, 209), [System.Drawing.Point]::new(112, 202)
		)
	} elseif ($Kind -eq 'earring') {
		Fill-Ellipse $Graphics $Accent 123 99 6 6
		Fill-Rect $Graphics $Accent 125 103 2 11
		Fill-Ellipse $Graphics $Accent 122 112 8 8
	} elseif ($Kind -eq 'cap') {
		Fill-Poly $Graphics $Accent @(
			[System.Drawing.Point]::new(51, 45), [System.Drawing.Point]::new(62, 25),
			[System.Drawing.Point]::new(113, 25), [System.Drawing.Point]::new(129, 47)
		)
		Fill-Rect $Graphics $ink 48 44 88 7
		Fill-Rect $Graphics $Accent 52 44 84 4
	} elseif ($Kind -eq 'sketchbook') {
		Fill-Poly $Graphics $ink @(
			[System.Drawing.Point]::new(31, 181), [System.Drawing.Point]::new(82, 167),
			[System.Drawing.Point]::new(94, 222), [System.Drawing.Point]::new(42, 236)
		)
		Fill-Poly $Graphics (New-Color '#EFE7D1') @(
			[System.Drawing.Point]::new(36, 183), [System.Drawing.Point]::new(78, 172),
			[System.Drawing.Point]::new(88, 218), [System.Drawing.Point]::new(45, 230)
		)
		Draw-Line $Graphics $Accent 2 48 195 73 188
		Draw-Line $Graphics $Accent 2 51 205 78 198
	} elseif ($Kind -eq 'badge') {
		Fill-Rect $Graphics $white 111 151 24 31
		Fill-Rect $Graphics $Accent 114 154 18 9
		Fill-Rect $Graphics $ink 116 168 14 2
		Fill-Rect $Graphics $ink 116 173 10 2
	}
}

function New-Character {
	param(
		[string]$Name,
		[string]$HairHex,
		[string]$HairLightHex,
		[string]$OutfitHex,
		[string]$AccentHex,
		[string]$EyeHex,
		[ValidateSet('long', 'short', 'bob', 'ponytail')][string]$HairStyle,
		[string]$Accessory,
		[ValidateSet('feminine', 'masculine')][string]$Frame
	)

	$hair = New-Color $HairHex
	$hairLight = New-Color $HairLightHex
	$outfit = New-Color $OutfitHex
	$accent = New-Color $AccentHex
	$eye = New-Color $EyeHex
	$bitmap = [System.Drawing.Bitmap]::new(180, 250, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
	$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
	$graphics.Clear([System.Drawing.Color]::Transparent)
	$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
	$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
	$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
	$graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver

	try {
		# Back hair and silhouette.
		if ($HairStyle -eq 'long' -or $HairStyle -eq 'ponytail') {
			Fill-Ellipse $graphics $ink 43 19 94 151
			Fill-Ellipse $graphics $hair 47 23 86 147
			Fill-Poly $graphics $hair @(
				[System.Drawing.Point]::new(49, 79), [System.Drawing.Point]::new(58, 172),
				[System.Drawing.Point]::new(76, 164), [System.Drawing.Point]::new(70, 75)
			)
			Fill-Poly $graphics $hair @(
				[System.Drawing.Point]::new(111, 73), [System.Drawing.Point]::new(107, 168),
				[System.Drawing.Point]::new(128, 174), [System.Drawing.Point]::new(131, 80)
			)
		}
		if ($HairStyle -eq 'ponytail') {
			Fill-Ellipse $graphics $ink 119 50 42 92
			Fill-Ellipse $graphics $hair 123 54 34 84
			Fill-Rect $graphics $accent 119 59 14 10
		}

		# Torso outline, jacket and shoulders.
		$shoulderLeft = if ($Frame -eq 'masculine') { 15 } else { 22 }
		$shoulderRight = if ($Frame -eq 'masculine') { 165 } else { 158 }
		Fill-Poly $graphics $ink @(
			[System.Drawing.Point]::new(29, 250), [System.Drawing.Point]::new($shoulderLeft, 174),
			[System.Drawing.Point]::new(47, 137), [System.Drawing.Point]::new(67, 127),
			[System.Drawing.Point]::new(113, 127), [System.Drawing.Point]::new(133, 137),
			[System.Drawing.Point]::new($shoulderRight, 174), [System.Drawing.Point]::new(151, 250)
		)
		Fill-Poly $graphics $outfit @(
			[System.Drawing.Point]::new(35, 250), [System.Drawing.Point]::new($shoulderLeft + 8, 176),
			[System.Drawing.Point]::new(51, 143), [System.Drawing.Point]::new(70, 133),
			[System.Drawing.Point]::new(110, 133), [System.Drawing.Point]::new(129, 143),
			[System.Drawing.Point]::new($shoulderRight - 8, 176), [System.Drawing.Point]::new(145, 250)
		)
		Fill-Rect $graphics $skinShadow 75 116 31 30
		Fill-Rect $graphics $skin 79 116 23 31
		Fill-Poly $graphics $white @(
			[System.Drawing.Point]::new(60, 137), [System.Drawing.Point]::new(80, 130),
			[System.Drawing.Point]::new(90, 158), [System.Drawing.Point]::new(101, 130),
			[System.Drawing.Point]::new(121, 138), [System.Drawing.Point]::new(108, 174),
			[System.Drawing.Point]::new(72, 174)
		)
		Fill-Poly $graphics $accent @(
			[System.Drawing.Point]::new(87, 153), [System.Drawing.Point]::new(94, 153),
			[System.Drawing.Point]::new(99, 207), [System.Drawing.Point]::new(90, 220),
			[System.Drawing.Point]::new(81, 207)
		)
		Draw-Line $graphics $hairLight 3 45 173 34 235
		Draw-Line $graphics $hairLight 3 135 173 146 235

		# Ears, face and jaw.
		Fill-Ellipse $graphics $ink 47 35 86 100
		Fill-Ellipse $graphics $skin 51 39 78 92
		Fill-Ellipse $graphics $skinShadow 45 76 14 25
		Fill-Ellipse $graphics $skinShadow 121 76 14 25
		Fill-Ellipse $graphics $skin 49 78 9 19
		Fill-Ellipse $graphics $skin 122 78 9 19

		# Hair cap, fringe and highlights.
		Fill-Ellipse $graphics $hair 48 22 84 65
		if ($HairStyle -eq 'short') {
			Fill-Poly $graphics $hair @(
				[System.Drawing.Point]::new(47, 61), [System.Drawing.Point]::new(52, 36),
				[System.Drawing.Point]::new(63, 19), [System.Drawing.Point]::new(70, 30),
				[System.Drawing.Point]::new(84, 14), [System.Drawing.Point]::new(91, 28),
				[System.Drawing.Point]::new(108, 17), [System.Drawing.Point]::new(111, 32),
				[System.Drawing.Point]::new(132, 30), [System.Drawing.Point]::new(126, 71)
			)
		} elseif ($HairStyle -eq 'bob') {
			Fill-Rect $graphics $hair 48 55 14 63
			Fill-Rect $graphics $hair 119 55 13 63
		}
		Fill-Poly $graphics $hair @(
			[System.Drawing.Point]::new(51, 58), [System.Drawing.Point]::new(62, 31),
			[System.Drawing.Point]::new(74, 71), [System.Drawing.Point]::new(84, 34),
			[System.Drawing.Point]::new(94, 70), [System.Drawing.Point]::new(109, 34),
			[System.Drawing.Point]::new(126, 61), [System.Drawing.Point]::new(124, 42),
			[System.Drawing.Point]::new(57, 35)
		)
		Fill-Rect $graphics $hairLight 66 30 27 5
		Fill-Rect $graphics $hairLight 61 36 11 4

		# Anime eyes, brows, blush and mouth.
		Fill-Rect $graphics $ink 63 77 23 4
		Fill-Rect $graphics $ink 96 77 23 4
		Fill-Rect $graphics $eye 67 81 15 14
		Fill-Rect $graphics $eye 100 81 15 14
		Fill-Rect $graphics $ink 70 85 10 12
		Fill-Rect $graphics $ink 102 85 10 12
		Fill-Rect $graphics $white 72 83 4 4
		Fill-Rect $graphics $white 104 83 4 4
		Fill-Rect $graphics $blush 58 101 14 3
		Fill-Rect $graphics $blush 110 101 14 3
		Fill-Rect $graphics $skinShadow 89 94 4 7
		Fill-Rect $graphics $ink 84 111 15 2
		Fill-Rect $graphics $blush 89 113 7 2

		Draw-Accessory $graphics $Accessory $accent $hair

		# Pixel rim lights and small signature pins.
		Fill-Rect $graphics $hairLight 50 64 3 27
		Fill-Rect $graphics $accent 48 149 7 7
		Fill-Rect $graphics $white 50 151 3 3

		$scaled = [System.Drawing.Bitmap]::new(360, 500, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
		$scaledGraphics = [System.Drawing.Graphics]::FromImage($scaled)
		try {
			$scaledGraphics.Clear([System.Drawing.Color]::Transparent)
			$scaledGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
			$scaledGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
			$scaledGraphics.DrawImage($bitmap, [System.Drawing.Rectangle]::new(0, 0, 360, 500), 0, 0, 180, 250, [System.Drawing.GraphicsUnit]::Pixel)
			$scaled.Save((Join-Path $outputDir "$Name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
		} finally {
			$scaledGraphics.Dispose()
			$scaled.Dispose()
		}
	} finally {
		$graphics.Dispose()
		$bitmap.Dispose()
	}
}

$characters = @(
	@{ Name='protagonist-female'; HairHex='#27324B'; HairLightHex='#536E9C'; OutfitHex='#7B3151'; AccentHex='#62C6BA'; EyeHex='#3E8B87'; HairStyle='ponytail'; Accessory='earring'; Frame='feminine' },
	@{ Name='protagonist-male'; HairHex='#27303E'; HairLightHex='#56657B'; OutfitHex='#253E61'; AccentHex='#E9BD55'; EyeHex='#3F7185'; HairStyle='short'; Accessory='badge'; Frame='masculine' },
	@{ Name='lin-cheng'; HairHex='#503143'; HairLightHex='#A55F72'; OutfitHex='#2E5266'; AccentHex='#E8B94E'; EyeHex='#4C8E82'; HairStyle='bob'; Accessory='camera'; Frame='feminine' },
	@{ Name='jiang-ran'; HairHex='#3A2C2D'; HairLightHex='#8F5A47'; OutfitHex='#305A52'; AccentHex='#EF8B4A'; EyeHex='#5C8F9C'; HairStyle='short'; Accessory='headphones'; Frame='masculine' },
	@{ Name='tang-li'; HairHex='#8A4E35'; HairLightHex='#D68C55'; OutfitHex='#7D3442'; AccentHex='#F0C95B'; EyeHex='#497F7C'; HairStyle='ponytail'; Accessory='badge'; Frame='feminine' },
	@{ Name='zhou-yuan'; HairHex='#39384C'; HairLightHex='#7777A5'; OutfitHex='#4B5E77'; AccentHex='#78C5B5'; EyeHex='#4C728A'; HairStyle='short'; Accessory='sketchbook'; Frame='masculine' },
	@{ Name='song-zhixia'; HairHex='#243C44'; HairLightHex='#4E8291'; OutfitHex='#D9E4E4'; AccentHex='#E66D6D'; EyeHex='#3B8990'; HairStyle='long'; Accessory='clipboard'; Frame='feminine' },
	@{ Name='han-xu'; HairHex='#4A3B35'; HairLightHex='#8A7060'; OutfitHex='#4E3E55'; AccentHex='#DDBA6A'; EyeHex='#5D7483'; HairStyle='short'; Accessory='glasses'; Frame='masculine' },
	@{ Name='mia'; HairHex='#C98450'; HairLightHex='#F3B76D'; OutfitHex='#2F5B70'; AccentHex='#EC6E77'; EyeHex='#518CB1'; HairStyle='long'; Accessory='cap'; Frame='feminine' },
	@{ Name='ye-qing'; HairHex='#43355D'; HairLightHex='#8B66AC'; OutfitHex='#573B72'; AccentHex='#65C7BB'; EyeHex='#755C9B'; HairStyle='bob'; Accessory='scarf'; Frame='feminine' }
)

foreach ($character in $characters) {
	New-Character @character
}

# A contact sheet makes visual QA quick without affecting the game runtime.
$sheet = [System.Drawing.Bitmap]::new(1000, 620, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$sheetGraphics = [System.Drawing.Graphics]::FromImage($sheet)
try {
	$sheetGraphics.Clear((New-Color '#172027'))
	$sheetGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
	$font = [System.Drawing.Font]::new('Consolas', 15, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
	$brush = New-Brush $white
	try {
		for ($index = 0; $index -lt $characters.Count; $index++) {
			$column = $index % 5
			$row = [Math]::Floor($index / 5)
			$x = 5 + $column * 198
			$y = 8 + $row * 305
			$image = [System.Drawing.Image]::FromFile((Join-Path $outputDir "$($characters[$index].Name).png"))
			try {
				$sheetGraphics.DrawImage($image, [System.Drawing.Rectangle]::new($x + 13, $y, 172, 239), 0, 0, 360, 500, [System.Drawing.GraphicsUnit]::Pixel)
			} finally { $image.Dispose() }
			$sheetGraphics.DrawString($characters[$index].Name, $font, $brush, $x + 10, $y + 250)
		}
	} finally {
		$brush.Dispose()
		$font.Dispose()
	}
	$sheet.Save((Join-Path $outputDir 'contact-sheet.png'), [System.Drawing.Imaging.ImageFormat]::Png)
} finally {
	$sheetGraphics.Dispose()
	$sheet.Dispose()
}

Write-Host "Generated $($characters.Count) character sprites in $outputDir"
