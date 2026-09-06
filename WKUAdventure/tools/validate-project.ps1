param(
	[switch]$SkipSignalImages
)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$entryPath = Join-Path $projectRoot 'init.ts'
$appPath = Join-Path $projectRoot 'Game\app.ts'
$contentPath = Join-Path $projectRoot 'Game\content.ts'
$runtimePath = Join-Path $projectRoot 'Game\renpy.ts'
$luaRuntimePath = Join-Path $projectRoot 'lualib_bundle.lua'
$fontPath = Join-Path $projectRoot 'Font\sarasa-mono-sc-regular.ttf'
$manifestPath = Join-Path $projectRoot 'Data\galgame-art-manifest.md'
$promptPath = Join-Path $projectRoot 'Data\signal-art-prompts.md'
$storyAssetsPath = Join-Path $projectRoot 'Data\story-assets.md'

function Assert-ProjectCondition {
	param([bool]$Condition, [string]$Message)
	if (-not $Condition) { throw "FAIL: $Message" }
	Write-Host "PASS: $Message"
}

Add-Type -AssemblyName System.Drawing

Assert-ProjectCondition (Test-Path -LiteralPath $fontPath -PathType Leaf) 'bundled Chinese UI font exists'
$fontHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $fontPath).Hash
Assert-ProjectCondition ($fontHash -eq 'D1C0911C6BA686C4FDC6EC2ECD4E7ABB7AA97FFD1BCF956A1447F7C51E1A2676') 'bundled Chinese UI font matches the Dora distribution copy'

$expectedScenes = @{
	'outdoor-garden-bridge.png' = @(1672, 941)
	'outdoor-lakeside-flowers.png' = @(1672, 941)
	'outdoor-lake-path.png' = @(1672, 941)
	'slac-interior.png' = @(1477, 1065)
	'ghk-interior.png' = @(1387, 1134)
	'gh-interior.png' = @(1536, 1024)
	'gymnasium-interior.png' = @(1536, 1024)
	'swimming-pool-interior.png' = @(1448, 1086)
	'library-interior.png' = @(1526, 1030)
}

foreach ($name in $expectedScenes.Keys) {
	$path = Join-Path $projectRoot "Image\Scenes\$name"
	Assert-ProjectCondition (Test-Path -LiteralPath $path -PathType Leaf) "$name exists"
	$image = [System.Drawing.Image]::FromFile($path)
	try {
		$expected = $expectedScenes[$name]
		Assert-ProjectCondition ($image.Width -eq $expected[0] -and $image.Height -eq $expected[1]) "$name preserves its source dimensions"
	}
	finally { $image.Dispose() }
}

$castFiles = @('lin-cheng.png', 'jiang-ran.png', 'tang-li.png', 'zhou-yuan.png')
foreach ($name in $castFiles) {
	$path = Join-Path $projectRoot "Image\Characters\$name"
	Assert-ProjectCondition (Test-Path -LiteralPath $path -PathType Leaf) "$name exists"
	$image = [System.Drawing.Image]::FromFile($path)
	try {
		Assert-ProjectCondition ($image.Width -eq 360 -and $image.Height -eq 500) "$name is 360x500"
		Assert-ProjectCondition (($image.PixelFormat -band [System.Drawing.Imaging.PixelFormat]::Alpha) -ne 0) "$name supports transparency"
	}
	finally { $image.Dispose() }
}

$signalFiles = @('wall-screenshot.png', 'mint-receipt.png', 'seat-card.png', 'paper-star.png')
if ($SkipSignalImages) {
	Write-Warning 'Signal image validation skipped; this is not a full project pass.'
}
else {
	foreach ($name in $signalFiles) {
		$path = Join-Path $projectRoot "Image\Signals\$name"
		Assert-ProjectCondition (Test-Path -LiteralPath $path -PathType Leaf) "$name exists"
		$image = [System.Drawing.Image]::FromFile($path)
		try {
			Assert-ProjectCondition ($image.Width -eq 1024 -and $image.Height -eq 1024) "$name is 1024x1024"
		}
		finally { $image.Dispose() }
	}
}

$entry = Get-Content -LiteralPath $entryPath -Raw -Encoding UTF8
$app = Get-Content -LiteralPath $appPath -Raw -Encoding UTF8
$content = Get-Content -LiteralPath $contentPath -Raw -Encoding UTF8
$runtime = Get-Content -LiteralPath $runtimePath -Raw -Encoding UTF8
$allCode = "$entry`n$app`n$content`n$runtime"

Assert-ProjectCondition ($entry -match 'import\s+"Game/app"') 'init.ts loads the modular game entry'
$femalePronoun = [char]0x5979
$malePronoun = [char]0x4ED6
Assert-ProjectCondition ([regex]::Matches($content, "(?m)^\s*(?:\{|\s*)id:.*pronoun:\s*`"$femalePronoun`"").Count -eq 2) 'cast includes exactly two women'
Assert-ProjectCondition ([regex]::Matches($content, "(?m)^\s*(?:\{|\s*)id:.*pronoun:\s*`"$malePronoun`"").Count -eq 2) 'cast includes exactly two men'
foreach ($name in $castFiles) {
	Assert-ProjectCondition ($content.Contains("Image/Characters/$name")) "$name is wired into the cast"
}
Assert-ProjectCondition (-not $content.Contains('song-zhixia') -and -not $content.Contains('han-xu')) 'legacy fifth and sixth characters are not wired into the story'
Assert-ProjectCondition ([regex]::Matches($content, 'task:\s*"').Count -eq 4) 'all four cast members have a visible current task'

$episodeIds = @('wall-post', 'mint-decoy', 'third-row', 'lake-meetup')
foreach ($episodeId in $episodeIds) {
	Assert-ProjectCondition ($content.Contains("id: `"$episodeId`"")) "episode $episodeId is authored"
}
Assert-ProjectCondition ([regex]::Matches($content, 'kind:\s*"menu"').Count -eq 4) 'four authored decision menus are present'
Assert-ProjectCondition ([regex]::Matches($content, 'kind:\s*"end"').Count -eq 9) 'nine authored scene endings are present'
Assert-ProjectCondition ([regex]::Matches($content, 'kind:\s*"condition"').Count -eq 2) 'finale has three conditional outcomes'
Assert-ProjectCondition ([regex]::Matches($content, 'kind:\s*"signal"').Count -eq 4) 'four one-time plot signals are authored'
Assert-ProjectCondition ([regex]::Matches($content, 'clue:\s*"').Count -eq 4) 'all four plot signals explain what the evidence means'
Assert-ProjectCondition ([regex]::Matches($content, 'kind:\s*"minigame"').Count -eq 0) 'the rewritten story has no placeholder minigame interruptions'
Assert-ProjectCondition ($content -match '紧急下架' -and $content -match '我对象。临时的' -and $content -match '请失主今晚八点到湖边长椅' -and $content -match '实名回复') 'farce escalates through pinning, fake dating, public reading, and a real-name reply'
Assert-ProjectCondition ($content -match '不用找了，在我这' -and $content -match '伞柄上挂着寒予水的名字') 'the opening umbrella setup receives a finale payoff'
foreach ($name in $signalFiles) {
	Assert-ProjectCondition ($content.Contains("Image/Signals/$name")) "$name is wired into the signal catalog"
}
$signalIds = @('wall-screenshot', 'mint-receipt', 'seat-card', 'paper-star')
foreach ($signalId in $signalIds) {
	Assert-ProjectCondition ([regex]::Matches($content, "signalId:\s*`"$signalId`"").Count -eq 1) "signal $signalId appears exactly once in the story"
}
$labelNames = @{}
foreach ($match in [regex]::Matches($content, 'kind:\s*"label",\s*name:\s*"([^"]+)"')) {
	$labelNames[$match.Groups[1].Value] = $true
}
$branchTargets = @()
foreach ($match in [regex]::Matches($content, '(?:jump|pass|fail):\s*"([^"]+)"')) {
	$branchTargets += $match.Groups[1].Value
}
foreach ($target in $branchTargets) {
	Assert-ProjectCondition ($labelNames.ContainsKey($target)) "branch target $target resolves to a story label"
}

foreach ($kind in @('label', 'say', 'signal', 'menu', 'jump', 'condition', 'minigame', 'end')) {
	Assert-ProjectCondition ($runtime -match "kind:\s*`"$kind`"") "runtime supports $kind statements"
}
Assert-ProjectCondition ($runtime -match 'class\s+RenpyRuntime' -and $runtime -match 'choose\(') 'RenPy-style interpreter and menu execution are present'
Assert-ProjectCondition ($runtime -match '"lin-cheng"\s*\|\s*"jiang-ran"\s*\|\s*"tang-li"\s*\|\s*"zhou-yuan"') 'dialogue speakers use fixed four-character IDs'
foreach ($castId in @('lin-cheng', 'jiang-ran', 'tang-li', 'zhou-yuan')) {
	Assert-ProjectCondition ([regex]::Matches($content, "speaker:\s*`"$castId`"").Count -gt 0) "$castId has authored dialogue"
}
Assert-ProjectCondition (-not $app.Contains('resolvePartners') -and -not $app.Contains('currentPartners')) 'dynamic speaker reassignment has been removed'
Assert-ProjectCondition ($app -match 'addCastActor\(member\.id, member\.id' -and $app -match 'actorX\[index\]') 'story stage renders all four fixed actors'
Assert-ProjectCondition ($app -match 'whiteGlow' -and $app -match 'if \(selected\)' -and $app -match 'PALETTE\.white') 'selected cast uses a white glow outline'
Assert-ProjectCondition (-not $app.Contains('attachIME') -and -not $app.Contains('onTextInput')) 'canonical cast names cannot drift from authored dialogue'
Assert-ProjectCondition ($app -match 'version:\s*6' -and $app -match 'resumeEpisode' -and $app -match 'resumeCursor') 'save version 6 supports script checkpoint resume'
Assert-ProjectCondition ($app -match 'version !== 3 && version !== 4 && version !== 5 && version !== 6' -and $app -match 'isLegacyStory') 'save loader resets incompatible earlier story progress'
Assert-ProjectCondition ($app -match 'signals=\$\{table\.concat\(state\.signals' -and $app -match 'contains\(state\.signals, signal\.id\)') 'collected signals persist and suppress duplicate reveals'
Assert-ProjectCondition ($app -match 'showSignalAlbum' -and $app -match 'signalPromptOpen') 'signal reveal and album interfaces are present'
Assert-ProjectCondition ($app -match 'showCastAlbum' -and $app -match '人物关系') 'character album remains available from hub and story'
Assert-ProjectCondition ([regex]::Matches($content, 'reveal:\s*"写帖：寒予水\s+·\s+误发：黄一澈\s+·\s+收件：李童牧"').Count -eq 3) 'every final outcome states writer, accidental publisher, and recipient'
Assert-ProjectCondition ($content -match '帖子也是我写的。我喜欢你' -and $content -match '还有，我答应') 'finale includes a direct confession and an explicit answer'
Assert-ProjectCondition ($app -match 'isFinale \? "重看真相" : "继续下一集"' -and $app -match '本集已完成 · 真相仍在推进') 'chapter summaries and final truth use distinct completion actions'
Assert-ProjectCondition ($app -match 'MINI_GAME_HANDLERS' -and $runtime -match 'statement\.fallback') 'minigames have a registered handler and fallback contract'
Assert-ProjectCondition ($app -match 'stage\.schedule') 'global presentation scheduler is present'
Assert-ProjectCondition ($app -match 'Content\.writablePath') 'save data uses the Dora writable path'
Assert-ProjectCondition ($app -match 'autoMode' -and $app -match 'skipMode' -and $app -match 'showBacklog') 'visual-novel playback controls are present'
Assert-ProjectCondition ($app -match 'camera\.zoom\s*=\s*scale' -and $app -match 'TypeName\.Camera2D') 'responsive Camera2D fitting is present'
Assert-ProjectCondition ([regex]::Matches($allCode, '\b(window|document|localStorage|sessionStorage|XMLHttpRequest|fetch)\b').Count -eq 0) 'game has no browser-only runtime APIs'
Assert-ProjectCondition (Test-Path -LiteralPath $storyAssetsPath -PathType Leaf) 'screenwriting asset registry exists'

$sourceFiles = @($entryPath, $appPath, $contentPath, $runtimePath)
$luaFiles = @(
	(Join-Path $projectRoot 'init.lua'),
	(Join-Path $projectRoot 'Game\app.lua'),
	(Join-Path $projectRoot 'Game\content.lua'),
	(Join-Path $projectRoot 'Game\renpy.lua')
)
for ($index = 0; $index -lt $sourceFiles.Count; $index++) {
	Assert-ProjectCondition (Test-Path -LiteralPath $luaFiles[$index] -PathType Leaf) "compiled $([IO.Path]::GetFileName($luaFiles[$index])) exists"
	Assert-ProjectCondition ((Get-Item -LiteralPath $luaFiles[$index]).LastWriteTime -ge (Get-Item -LiteralPath $sourceFiles[$index]).LastWriteTime) "$([IO.Path]::GetFileName($luaFiles[$index])) is not stale"
}
Assert-ProjectCondition (Test-Path -LiteralPath $luaRuntimePath -PathType Leaf) 'lualib_bundle.lua exists for standalone execution'
$luaRuntime = Get-Content -LiteralPath $luaRuntimePath -Raw -Encoding UTF8
Assert-ProjectCondition ($luaRuntime -match '__TS__New' -and $luaRuntime -match '__TS__Class') 'lualib_bundle.lua provides required TypeScript runtime helpers'
Assert-ProjectCondition (Test-Path -LiteralPath $manifestPath -PathType Leaf) 'art provenance manifest exists'
Assert-ProjectCondition (Test-Path -LiteralPath $promptPath -PathType Leaf) 'signal generation prompt record exists'

if ($SkipSignalImages) {
	Write-Host 'PARTIAL PROJECT VALIDATION COMPLETE (signal images skipped)'
}
else {
	Write-Host 'PROJECT VALIDATION COMPLETE'
}
