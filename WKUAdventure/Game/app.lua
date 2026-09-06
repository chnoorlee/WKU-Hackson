local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local contains, pushUnique, truncateUtf8, sanitizeName, accentColor, getCast, getEpisode, getSignal, selectedName, resolveText, colorRect, textLabel, panel, makeButton, addMotion, addBackground, addCastActor, finishScene, clearScreen, showToast, saveDirectory, savePath, saveGame, valueFrom, numberFrom, listFrom, castIdFrom, loadGame, newState, completedBeatCount, slotSummary, showTitle, selectProfile, drawCastCard, showProfile, showSlots, chooseSlot, episodeUnlocked, episodeStatus, drawEpisodeCard, showHub, roleCastId, roleName, roleAccent, updateActorFocus, appendBacklog, snapshotStory, buildToolbar, buildDialogueBox, buildStoryScene, showDialogue, dispatchMiniGame, drawSignalImage, continueAfterSignal, showSignal, presentStatement, startEpisode, revealDialogue, advanceDialogue, showChoices, chooseStoryChoice, showEpisodeEnding, startNextEpisode, showBacklog, showCastAlbum, showSignalAlbum, closeOverlay, LOGICAL_WIDTH, LOGICAL_HEIGHT, FONT, PALETTE, screenRoot, scene, state, profileCastId, profileName, slotMode, currentEpisode, runtime, currentStatement, fullDialogueText, typedCharacters, fullCharacterCount, typeAccumulator, autoTimer, autoMode, skipMode, choosing, currentLineWasSeen, dialogueLabel, speakerLabel, nextLabel, episodeLabel, autoButtonLabel, skipButtonLabel, choiceLayer, overlayRoot, signalPromptOpen, toastRoot, toastTimer, sceneFade, backgroundVisual, storyActors, motions, backlog, seenLines, sceneTime, MINI_GAME_HANDLERS
local ____Dora = require("Dora")
local Color = ____Dora.Color
local Content = ____Dora.Content
local Director = ____Dora.Director
local DrawNode = ____Dora.DrawNode
local Label = ____Dora.Label
local Node = ____Dora.Node
local Path = ____Dora.Path
local Size = ____Dora.Size
local Sprite = ____Dora.Sprite
local Vec2 = ____Dora.Vec2
local View = ____Dora.View
local tolua = ____Dora.tolua
local ____content = require("Game.content")
local CAST = ____content.CAST
local EPISODES = ____content.EPISODES
local SIGNALS = ____content.SIGNALS
local ____renpy = require("Game.renpy")
local RenpyRuntime = ____renpy.RenpyRuntime
function contains(self, items, item)
    for ____, value in ipairs(items) do
        if value == item then
            return true
        end
    end
    return false
end
function pushUnique(self, items, item)
    if not contains(nil, items, item) then
        items[#items + 1] = item
    end
end
function truncateUtf8(self, text, maxChars)
    local count = utf8.len(text)
    if count == nil or count <= maxChars then
        return text
    end
    local nextByte = utf8.offset(text, maxChars + 1)
    return nextByte == nil and text or string.sub(text, 1, nextByte - 1)
end
function sanitizeName(self, text)
    local clean = string.gsub(text, "[\r\n=,|]", "")
    return truncateUtf8(nil, clean, 8)
end
function accentColor(self, key)
    if key == "gold" then
        return PALETTE.gold
    end
    if key == "coral" then
        return PALETTE.coral
    end
    if key == "blue" then
        return PALETTE.blue
    end
    return PALETTE.teal
end
function getCast(self, id)
    for ____, member in ipairs(CAST) do
        if member.id == id then
            return member
        end
    end
    error("未知角色: " .. id)
end
function getEpisode(self, id)
    for ____, episode in ipairs(EPISODES) do
        if episode.id == id then
            return episode
        end
    end
    return nil
end
function getSignal(self, id)
    for ____, signal in ipairs(SIGNALS) do
        if signal.id == id then
            return signal
        end
    end
    return nil
end
function selectedName(self)
    return state == nil and profileName or state.playerName
end
function resolveText(self, text)
    local resolved = string.gsub(
        text,
        "{name}",
        selectedName(nil)
    )
    return resolved
end
function colorRect(self, parent, x, y, width, height, fill, borderWidth, border)
    if borderWidth == nil then
        borderWidth = 0
    end
    if border == nil then
        border = PALETTE.transparent
    end
    local draw = DrawNode():addTo(parent)
    draw.position = Vec2(x, y)
    draw:drawPolygon(
        {
            Vec2(-width / 2, -height / 2),
            Vec2(width / 2, -height / 2),
            Vec2(width / 2, height / 2),
            Vec2(-width / 2, height / 2)
        },
        fill,
        borderWidth,
        border
    )
    return draw
end
function textLabel(self, parent, text, size, x, y, color, width, align)
    if color == nil then
        color = PALETTE.paper
    end
    if width == nil then
        width = 0
    end
    if align == nil then
        align = "Center"
    end
    local label = Label(FONT, size, true)
    if label == nil then
        error("无法加载中文字体")
    end
    label.text = text
    local adjustedX = width > 0 and (align == "Left" and x + width / 2 or (align == "Right" and x - width / 2 or x)) or x
    label.position = Vec2(adjustedX, y)
    label.color = color
    label.alignment = align
    label.lineGap = math.max(
        2,
        math.floor(size * 0.3)
    )
    if width > 0 then
        label.textWidth = width
    end
    label:addTo(parent)
    return label
end
function panel(self, parent, x, y, width, height, fill, accent)
    if fill == nil then
        fill = PALETTE.glass
    end
    if accent == nil then
        accent = PALETTE.teal
    end
    local root = Node():addTo(parent)
    root.position = Vec2(x, y)
    colorRect(
        nil,
        root,
        5,
        -7,
        width,
        height,
        PALETTE.shadow
    )
    colorRect(
        nil,
        root,
        0,
        0,
        width,
        height,
        fill,
        2,
        Color(2867454154)
    )
    colorRect(
        nil,
        root,
        0,
        height / 2 - 4,
        width,
        6,
        accent
    )
    return root
end
function makeButton(self, parent, text, x, y, width, height, action, accent, selected, disabled)
    if accent == nil then
        accent = PALETTE.teal
    end
    if selected == nil then
        selected = false
    end
    if disabled == nil then
        disabled = false
    end
    local button = Node():addTo(parent)
    button.position = Vec2(x, y)
    button.size = Size(width, height)
    button.swallowTouches = true
    colorRect(
        nil,
        button,
        width / 2 + 3,
        height / 2 - 5,
        width - 4,
        height - 2,
        PALETTE.shadow
    )
    local face = Node():addTo(button)
    face.position = Vec2(width / 2, height / 2)
    local fill = disabled and Color(3996203328) or (selected and accent or Color(4028904252))
    local edge = disabled and Color(4285101178) or (selected and PALETTE.paper or accent)
    colorRect(
        nil,
        face,
        0,
        0,
        width,
        height,
        fill,
        2,
        edge
    )
    colorRect(
        nil,
        face,
        0,
        height / 2 - 3,
        width - 8,
        4,
        edge
    )
    local label = textLabel(
        nil,
        face,
        text,
        height <= 34 and 13 or (height <= 46 and 15 or 17),
        0,
        -1,
        disabled and Color(4287074453) or PALETTE.paper,
        width - 16
    )
    if not disabled then
        button:onTapBegan(function()
            local ____temp_0 = height / 2 - 3
            face.y = ____temp_0
            return ____temp_0
        end)
        button:onTapEnded(function()
            local ____temp_1 = height / 2
            face.y = ____temp_1
            return ____temp_1
        end)
        button:onTapped(action)
    end
    return {node = button, label = label, face = face}
end
function addMotion(self, node, amplitudeX, amplitudeY, speed, phase)
    motions[#motions + 1] = {
        node = node,
        baseX = node.x,
        baseY = node.y,
        amplitudeX = amplitudeX,
        amplitudeY = amplitudeY,
        speed = speed,
        phase = phase
    }
end
function addBackground(self, path, scale)
    local sprite = Sprite(path)
    if sprite == nil then
        return nil
    end
    sprite.filter = "Point"
    sprite.scaleX = scale
    sprite.scaleY = scale
    sprite.position = Vec2.zero
    sprite:addTo(screenRoot)
    backgroundVisual = sprite
    return sprite
end
function addCastActor(self, memberId, role, x, scale, y, parent)
    if scale == nil then
        scale = 0.8
    end
    if y == nil then
        y = 0
    end
    if parent == nil then
        parent = screenRoot
    end
    local sprite = Sprite(getCast(nil, memberId).sprite)
    if sprite == nil then
        return nil
    end
    sprite.filter = "Point"
    sprite.scaleX = scale
    sprite.scaleY = scale
    sprite.position = Vec2(x, y)
    sprite:addTo(parent)
    storyActors[#storyActors + 1] = {role = role, node = sprite}
    addMotion(
        nil,
        sprite,
        0,
        2.3,
        1.35,
        #storyActors * 0.8
    )
    return sprite
end
function finishScene(self)
    local veil = Node():addTo(screenRoot)
    veil.passOpacity = true
    veil.opacity = 1
    colorRect(
        nil,
        veil,
        0,
        0,
        LOGICAL_WIDTH,
        LOGICAL_HEIGHT,
        PALETTE.ink
    )
    sceneFade = veil
end
function clearScreen(self, nextScene)
    scene = nextScene
    screenRoot:removeAllChildren()
    dialogueLabel = nil
    speakerLabel = nil
    nextLabel = nil
    episodeLabel = nil
    autoButtonLabel = nil
    skipButtonLabel = nil
    choiceLayer = nil
    overlayRoot = nil
    signalPromptOpen = false
    toastRoot = nil
    toastTimer = 0
    sceneFade = nil
    backgroundVisual = nil
    storyActors = {}
    motions = {}
    sceneTime = 0
end
function showToast(self, message, accent)
    if accent == nil then
        accent = PALETTE.teal
    end
    if toastRoot ~= nil then
        toastRoot:removeFromParent()
    end
    toastRoot = panel(
        nil,
        screenRoot,
        0,
        210,
        310,
        48,
        Color(4061799212),
        accent
    )
    textLabel(
        nil,
        toastRoot,
        message,
        14,
        0,
        -1,
        PALETTE.paper,
        280
    )
    toastTimer = 2.1
end
function saveDirectory(self)
    return Path(Content.writablePath, "WKUAfterlightSaves")
end
function savePath(self, slot)
    return Path(
        saveDirectory(nil),
        ("slot-" .. tostring(slot)) .. ".sav"
    )
end
function saveGame(self)
    if state == nil then
        return false
    end
    if not Content:exist(saveDirectory(nil)) then
        Content:mkdir(saveDirectory(nil))
    end
    local lines = {
        "version=" .. tostring(state.version),
        "slot=" .. tostring(state.slot),
        "playerId=" .. state.playerId,
        "playerName=" .. sanitizeName(nil, state.playerName),
        "completed=" .. table.concat(state.completed, ","),
        "choices=" .. table.concat(state.choices, ","),
        "endings=" .. table.concat(state.endings, ","),
        "signals=" .. table.concat(state.signals, ","),
        "chaos=" .. tostring(state.stats.chaos),
        "order=" .. tostring(state.stats.order),
        "warmth=" .. tostring(state.stats.warmth),
        "wit=" .. tostring(state.stats.wit),
        "resumeEpisode=" .. state.resumeEpisode,
        "resumeCursor=" .. tostring(state.resumeCursor)
    }
    return Content:save(
        savePath(nil, state.slot),
        table.concat(lines, "\n")
    )
end
function valueFrom(self, content, key)
    local value = string.match(content, key .. "=([^\r\n]*)")
    return value
end
function numberFrom(self, content, key, fallback)
    return tonumber(valueFrom(nil, content, key) or "") or fallback
end
function listFrom(self, value)
    local result = {}
    if value == nil or #value == 0 then
        return result
    end
    for item in string.gmatch(value, "([^,]+)") do
        result[#result + 1] = item
    end
    return result
end
function castIdFrom(self, value)
    for ____, member in ipairs(CAST) do
        if member.id == value then
            return member.id
        end
    end
    return "lin-cheng"
end
function loadGame(self, slot)
    local path = savePath(nil, slot)
    if not Content:exist(path) then
        return nil
    end
    local content = Content:load(path)
    if #content == 0 then
        return nil
    end
    local version = numberFrom(nil, content, "version", 0)
    if version ~= 3 and version ~= 4 and version ~= 5 and version ~= 6 then
        return nil
    end
    local isLegacyStory = version ~= 6
    local playerId = castIdFrom(
        nil,
        valueFrom(nil, content, "playerId")
    )
    local completed = {}
    for ____, value in ipairs(isLegacyStory and ({}) or listFrom(
        nil,
        valueFrom(nil, content, "completed")
    )) do
        local episode = getEpisode(nil, value)
        if episode ~= nil then
            pushUnique(nil, completed, episode.id)
        end
    end
    local signals = {}
    for ____, value in ipairs(isLegacyStory and ({}) or listFrom(
        nil,
        valueFrom(nil, content, "signals")
    )) do
        local signal = getSignal(nil, value)
        if signal ~= nil then
            pushUnique(nil, signals, signal.id)
        end
    end
    return {
        version = 6,
        slot = slot,
        playerId = playerId,
        playerName = getCast(nil, playerId).name,
        completed = completed,
        choices = isLegacyStory and ({}) or listFrom(
            nil,
            valueFrom(nil, content, "choices")
        ),
        endings = isLegacyStory and ({}) or listFrom(
            nil,
            valueFrom(nil, content, "endings")
        ),
        signals = signals,
        stats = {
            chaos = isLegacyStory and 0 or math.max(
                0,
                numberFrom(nil, content, "chaos", 0)
            ),
            order = isLegacyStory and 0 or math.max(
                0,
                numberFrom(nil, content, "order", 0)
            ),
            warmth = isLegacyStory and 0 or math.max(
                0,
                numberFrom(nil, content, "warmth", 0)
            ),
            wit = isLegacyStory and 0 or math.max(
                0,
                numberFrom(nil, content, "wit", 0)
            )
        },
        resumeEpisode = isLegacyStory and "" or (valueFrom(nil, content, "resumeEpisode") or ""),
        resumeCursor = isLegacyStory and 0 or math.max(
            0,
            numberFrom(nil, content, "resumeCursor", 0)
        )
    }
end
function newState(self, slot)
    return {
        version = 6,
        slot = slot,
        playerId = profileCastId,
        playerName = getCast(nil, profileCastId).name,
        completed = {},
        choices = {},
        endings = {},
        signals = {},
        stats = {chaos = 0, order = 0, warmth = 0, wit = 0},
        resumeEpisode = "",
        resumeCursor = 0
    }
end
function completedBeatCount(self, gameState)
    local count = contains(nil, gameState.completed, "wall-post") and 1 or 0
    if contains(nil, gameState.completed, "mint-decoy") or contains(nil, gameState.completed, "third-row") then
        count = count + 1
    end
    if contains(nil, gameState.completed, "lake-meetup") then
        count = count + 1
    end
    return count
end
function slotSummary(self, slot)
    local loaded = loadGame(nil, slot)
    if loaded == nil then
        return "空档案 · 等待开拍"
    end
    return ((((loaded.playerName .. " 饰 ") .. getCast(nil, loaded.playerId).name) .. " · ") .. tostring(completedBeatCount(nil, loaded))) .. "/3 集"
end
function showTitle(self)
    clearScreen(nil, "title")
    addBackground(nil, "Image/Scenes/outdoor-garden-bridge.png", 0.574)
    colorRect(
        nil,
        screenRoot,
        0,
        0,
        960,
        540,
        Color(1862798612)
    )
    colorRect(
        nil,
        screenRoot,
        -256,
        0,
        448,
        540,
        Color(3775993888)
    )
    colorRect(
        nil,
        screenRoot,
        -30,
        0,
        5,
        540,
        PALETTE.coral
    )
    textLabel(
        nil,
        screenRoot,
        "WKU SITCOM / SEASON 01",
        12,
        -438,
        214,
        PALETTE.gold,
        260,
        "Left"
    )
    textLabel(
        nil,
        screenRoot,
        "温肯：这条表白全校已读",
        32,
        -438,
        133,
        PALETTE.paper,
        400,
        "Left"
    )
    textLabel(
        nil,
        screenRoot,
        "一条误发，一次撤回，五次越描越黑。",
        15,
        -438,
        79,
        PALETTE.muted,
        390,
        "Left"
    )
    colorRect(
        nil,
        screenRoot,
        -291,
        43,
        272,
        2,
        PALETTE.teal
    )
    textLabel(
        nil,
        screenRoot,
        "他们只想删帖，结果把秘密做成了直播。",
        14,
        -438,
        5,
        PALETTE.paper,
        370,
        "Left"
    )
    makeButton(
        nil,
        screenRoot,
        "开始选角",
        -360,
        -137,
        238,
        52,
        showProfile,
        PALETTE.teal,
        true
    )
    makeButton(
        nil,
        screenRoot,
        "读取档案",
        -360,
        -202,
        238,
        46,
        function() return showSlots(nil, "load") end,
        PALETTE.gold
    )
    addCastActor(
        nil,
        "jiang-ran",
        "jiang-ran",
        94,
        0.55,
        0
    )
    addCastActor(
        nil,
        "lin-cheng",
        "lin-cheng",
        210,
        0.61,
        2
    )
    addCastActor(
        nil,
        "tang-li",
        "tang-li",
        324,
        0.56,
        0
    )
    addCastActor(
        nil,
        "zhou-yuan",
        "zhou-yuan",
        426,
        0.53,
        0
    )
    finishScene(nil)
end
function selectProfile(self, memberId)
    profileCastId = memberId
    profileName = getCast(nil, memberId).name
    showProfile(nil)
end
function drawCastCard(self, member, index)
    local selected = member.id == profileCastId
    local cardWidth = 198
    local cardHeight = 326
    local centerX = -330 + index * 220
    local centerY = 12
    local root = Node():addTo(screenRoot)
    root.position = Vec2(centerX, centerY)
    if selected then
        colorRect(
            nil,
            root,
            0,
            0,
            cardWidth + 12,
            cardHeight + 12,
            PALETTE.transparent,
            7,
            PALETTE.whiteGlow
        )
        colorRect(
            nil,
            root,
            0,
            0,
            cardWidth + 4,
            cardHeight + 4,
            PALETTE.transparent,
            3,
            PALETTE.white
        )
    end
    colorRect(
        nil,
        root,
        3,
        -6,
        cardWidth,
        cardHeight,
        PALETTE.shadow
    )
    colorRect(
        nil,
        root,
        0,
        0,
        cardWidth,
        cardHeight,
        selected and Color(4029430339) or Color(3927449897),
        2,
        selected and PALETTE.white or accentColor(nil, member.accent)
    )
    colorRect(
        nil,
        root,
        0,
        cardHeight / 2 - 4,
        cardWidth - 8,
        5,
        accentColor(nil, member.accent)
    )
    local portrait = Sprite(member.sprite)
    if portrait ~= nil then
        portrait.filter = "Point"
        portrait.scaleX = 0.36
        portrait.scaleY = 0.36
        portrait.position = Vec2(0, 51)
        portrait:addTo(root)
    end
    textLabel(
        nil,
        root,
        member.name,
        20,
        0,
        -58,
        PALETTE.paper,
        170
    )
    textLabel(
        nil,
        root,
        member.role,
        12,
        0,
        -88,
        selected and PALETTE.white or PALETTE.muted,
        170
    )
    textLabel(
        nil,
        root,
        "今晚：" .. member.task,
        10,
        0,
        -117,
        PALETTE.blue,
        172
    )
    textLabel(
        nil,
        root,
        member.quip,
        10,
        0,
        -145,
        PALETTE.paper,
        170
    )
    textLabel(
        nil,
        root,
        member.pronoun,
        10,
        0,
        141,
        accentColor(nil, member.accent),
        24
    )
    local tap = Node():addTo(root)
    tap.position = Vec2(-cardWidth / 2, -cardHeight / 2)
    tap.size = Size(cardWidth, cardHeight)
    tap.swallowTouches = true
    tap:onTapped(function() return selectProfile(nil, member.id) end)
end
function showProfile(self)
    clearScreen(nil, "profile")
    addBackground(nil, "Image/Scenes/outdoor-lake-path.png", 0.574)
    colorRect(
        nil,
        screenRoot,
        0,
        0,
        960,
        540,
        Color(3557824287)
    )
    textLabel(
        nil,
        screenRoot,
        "从谁的视角看这场误发",
        28,
        0,
        230,
        PALETTE.paper,
        560
    )
    textLabel(
        nil,
        screenRoot,
        "四个人都在现场；白框角色是你的视角人物",
        12,
        0,
        198,
        PALETTE.muted,
        620
    )
    do
        local index = 0
        while index < #CAST do
            drawCastCard(nil, CAST[index + 1], index)
            index = index + 1
        end
    end
    makeButton(
        nil,
        screenRoot,
        "返回",
        -405,
        -257,
        136,
        40,
        showTitle,
        PALETTE.brick
    )
    textLabel(
        nil,
        screenRoot,
        (getCast(nil, profileCastId).name .. " · ") .. getCast(nil, profileCastId).role,
        13,
        -90,
        -245,
        PALETTE.muted,
        300
    )
    makeButton(
        nil,
        screenRoot,
        "确认视角",
        290,
        -257,
        190,
        40,
        function() return showSlots(nil, "new") end,
        PALETTE.teal,
        true
    )
    finishScene(nil)
end
function showSlots(self, mode)
    clearScreen(nil, "slots")
    slotMode = mode
    addBackground(nil, "Image/Scenes/outdoor-lakeside-flowers.png", 0.574)
    colorRect(
        nil,
        screenRoot,
        0,
        0,
        960,
        540,
        Color(3372945688)
    )
    textLabel(
        nil,
        screenRoot,
        mode == "new" and "选择拍摄档案" or "读取拍摄档案",
        29,
        0,
        220,
        PALETTE.paper,
        650
    )
    textLabel(
        nil,
        screenRoot,
        mode == "new" and "已有档案会被新一季覆盖" or "读取后会回到上次中断的台词",
        12,
        0,
        184,
        PALETTE.muted,
        620
    )
    do
        local slot = 1
        while slot <= 3 do
            local selectedSlot = slot
            local loaded = loadGame(nil, slot)
            local disabled = mode == "load" and loaded == nil
            local accent = slot == 1 and PALETTE.teal or (slot == 2 and PALETTE.gold or PALETTE.coral)
            local card = panel(
                nil,
                screenRoot,
                0,
                102 - (slot - 1) * 114,
                650,
                88,
                Color(3994690348),
                accent
            )
            textLabel(
                nil,
                card,
                "0" .. tostring(slot),
                24,
                -286,
                7,
                PALETTE.paper,
                55,
                "Left"
            )
            textLabel(
                nil,
                card,
                slotSummary(nil, slot),
                15,
                -205,
                9,
                disabled and Color(4286285193) or PALETTE.paper,
                370,
                "Left"
            )
            textLabel(
                nil,
                card,
                loaded == nil and "NEW" or (mode == "new" and "覆盖" or "LOAD"),
                11,
                185,
                8,
                disabled and Color(4285035128) or PALETTE.muted,
                60
            )
            makeButton(
                nil,
                card,
                mode == "new" and "选择" or "读取",
                218,
                -21,
                96,
                42,
                function() return chooseSlot(nil, selectedSlot) end,
                accent,
                false,
                disabled
            )
            slot = slot + 1
        end
    end
    makeButton(
        nil,
        screenRoot,
        "返回",
        -405,
        -257,
        136,
        40,
        mode == "new" and showProfile or showTitle,
        PALETTE.brick
    )
    textLabel(
        nil,
        screenRoot,
        "数字键 1 / 2 / 3",
        11,
        290,
        -236,
        PALETTE.muted,
        190,
        "Right"
    )
    finishScene(nil)
end
function chooseSlot(self, slot)
    if slotMode == "new" then
        state = newState(nil, slot)
        saveGame(nil)
        showHub(nil)
        return
    end
    local loaded = loadGame(nil, slot)
    if loaded == nil then
        return
    end
    state = loaded
    local resume = getEpisode(nil, state.resumeEpisode)
    if resume ~= nil then
        startEpisode(nil, resume, true)
    else
        showHub(nil)
    end
end
function episodeUnlocked(self, episode)
    if state == nil then
        return false
    end
    if episode.path == "opening" then
        return true
    end
    if episode.path == "chaos" then
        return contains(nil, state.choices, "wall-post:leave-up")
    end
    if episode.path == "order" then
        return contains(nil, state.choices, "wall-post:trace")
    end
    return contains(nil, state.completed, "wall-post") and (contains(nil, state.completed, "mint-decoy") or contains(nil, state.completed, "third-row"))
end
function episodeStatus(self, episode)
    if state == nil then
        return ""
    end
    if contains(nil, state.completed, episode.id) then
        return "已收录"
    end
    return episodeUnlocked(nil, episode) and "待开拍" or "未解锁"
end
function drawEpisodeCard(self, episode, index)
    if state == nil then
        return
    end
    local unlocked = episodeUnlocked(nil, episode)
    local completed = contains(nil, state.completed, episode.id)
    local centersX = {-224, 224, -224, 224}
    local centersY = {103, 103, -84, -84}
    local root = panel(
        nil,
        screenRoot,
        centersX[index + 1],
        centersY[index + 1],
        408,
        158,
        Color(4011335977),
        completed and PALETTE.green or (unlocked and PALETTE.teal or Color(4284047977))
    )
    textLabel(
        nil,
        root,
        episode.number,
        11,
        -184,
        55,
        completed and PALETTE.green or (unlocked and PALETTE.gold or PALETTE.muted),
        90,
        "Left"
    )
    textLabel(
        nil,
        root,
        episodeStatus(nil, episode),
        11,
        96,
        55,
        completed and PALETTE.green or PALETTE.muted,
        90,
        "Right"
    )
    textLabel(
        nil,
        root,
        episode.title,
        21,
        -184,
        17,
        unlocked and PALETTE.paper or Color(4287074453),
        355,
        "Left"
    )
    textLabel(
        nil,
        root,
        episode.location,
        11,
        -184,
        -14,
        PALETTE.muted,
        355,
        "Left"
    )
    textLabel(
        nil,
        root,
        episode.logline,
        12,
        -184,
        -48,
        unlocked and PALETTE.paper or Color(4285693314),
        350,
        "Left"
    )
    if unlocked then
        local tap = Node():addTo(root)
        tap.position = Vec2(-204, -79)
        tap.size = Size(408, 158)
        tap.swallowTouches = true
        tap:onTapped(function() return startEpisode(nil, episode, false) end)
    end
end
function showHub(self)
    if state == nil then
        showTitle(nil)
        return
    end
    state.resumeEpisode = ""
    state.resumeCursor = 0
    saveGame(nil)
    clearScreen(nil, "hub")
    addBackground(nil, "Image/Scenes/outdoor-lake-path.png", 0.574)
    colorRect(
        nil,
        screenRoot,
        0,
        0,
        960,
        540,
        Color(3557495064)
    )
    colorRect(
        nil,
        screenRoot,
        0,
        232,
        960,
        76,
        Color(4061206560)
    )
    textLabel(
        nil,
        screenRoot,
        "本季剧集",
        25,
        -444,
        242,
        PALETTE.paper,
        180,
        "Left"
    )
    textLabel(
        nil,
        screenRoot,
        "第一视角 · " .. getCast(nil, state.playerId).name,
        12,
        -444,
        212,
        PALETTE.muted,
        300,
        "Left"
    )
    textLabel(
        nil,
        screenRoot,
        ("本线 " .. tostring(completedBeatCount(nil, state))) .. "/3",
        13,
        164,
        236,
        PALETTE.gold,
        150,
        "Right"
    )
    makeButton(
        nil,
        screenRoot,
        "人物",
        77,
        214,
        94,
        34,
        showCastAlbum,
        PALETTE.teal
    )
    makeButton(
        nil,
        screenRoot,
        (("信号 " .. tostring(#state.signals)) .. "/") .. tostring(#SIGNALS),
        183,
        214,
        94,
        34,
        showSignalAlbum,
        PALETTE.blue
    )
    makeButton(
        nil,
        screenRoot,
        "保存",
        289,
        214,
        82,
        34,
        function() return showToast(
            nil,
            saveGame(nil) and "档案已保存" or "保存失败",
            PALETTE.gold
        ) end,
        PALETTE.gold
    )
    makeButton(
        nil,
        screenRoot,
        "标题",
        384,
        214,
        82,
        34,
        showTitle,
        PALETTE.brick
    )
    do
        local index = 0
        while index < #EPISODES do
            drawEpisodeCard(nil, EPISODES[index + 1], index)
            index = index + 1
        end
    end
    textLabel(
        nil,
        screenRoot,
        (((("现场倾向  即兴 " .. tostring(state.stats.chaos)) .. "  ·  秩序 ") .. tostring(state.stats.order)) .. "  ·  默契 ") .. tostring(state.stats.warmth),
        11,
        -444,
        -247,
        PALETTE.muted,
        620,
        "Left"
    )
    finishScene(nil)
end
function roleCastId(self, role)
    local ____temp_2
    if role == "narrator" then
        ____temp_2 = nil
    else
        ____temp_2 = role
    end
    return ____temp_2
end
function roleName(self, role)
    if role == "narrator" then
        return "旁白"
    end
    local name = getCast(nil, role).name
    return state ~= nil and role == state.playerId and name .. "（你）" or name
end
function roleAccent(self, role)
    if role == "narrator" then
        return PALETTE.gold
    end
    local id = roleCastId(nil, role)
    return id == nil and PALETTE.teal or accentColor(
        nil,
        getCast(nil, id).accent
    )
end
function updateActorFocus(self, role)
    for ____, actor in ipairs(storyActors) do
        actor.node.opacity = role == "narrator" and 0.88 or (actor.role == role and 1 or 0.58)
    end
end
function appendBacklog(self, speaker, text)
    local entry = (speaker .. "｜") .. text
    if #backlog == 0 or backlog[#backlog] ~= entry then
        backlog[#backlog + 1] = entry
    end
end
function snapshotStory(self)
    if state == nil or currentEpisode == nil or runtime == nil then
        return
    end
    state.resumeEpisode = currentEpisode.id
    state.resumeCursor = math.max(
        0,
        runtime:getCursor() - 1
    )
    saveGame(nil)
end
function buildToolbar(self)
    if currentEpisode == nil then
        return
    end
    colorRect(
        nil,
        screenRoot,
        0,
        246,
        960,
        48,
        Color(3893434400)
    )
    colorRect(
        nil,
        screenRoot,
        0,
        221,
        960,
        2,
        PALETTE.teal
    )
    episodeLabel = textLabel(
        nil,
        screenRoot,
        (currentEpisode.number .. " · ") .. currentEpisode.title,
        12,
        -446,
        246,
        PALETTE.paper,
        360,
        "Left"
    )
    makeButton(
        nil,
        screenRoot,
        "回看",
        414,
        231,
        60,
        30,
        showBacklog,
        PALETTE.blue
    )
    makeButton(
        nil,
        screenRoot,
        "保存",
        340,
        231,
        68,
        30,
        function()
            snapshotStory(nil)
            showToast(nil, "剧情进度已保存", PALETTE.gold)
        end,
        PALETTE.gold
    )
    local skip = makeButton(
        nil,
        screenRoot,
        skipMode and "跳过·开" or "跳过",
        262,
        231,
        72,
        30,
        function()
            skipMode = not skipMode
            if skipButtonLabel ~= nil then
                skipButtonLabel.text = skipMode and "跳过·开" or "跳过"
            end
        end,
        PALETTE.coral,
        skipMode
    )
    skipButtonLabel = skip.label
    local auto = makeButton(
        nil,
        screenRoot,
        autoMode and "自动·开" or "自动",
        184,
        231,
        72,
        30,
        function()
            autoMode = not autoMode
            if autoButtonLabel ~= nil then
                autoButtonLabel.text = autoMode and "自动·开" or "自动"
            end
        end,
        PALETTE.teal,
        autoMode
    )
    autoButtonLabel = auto.label
    makeButton(
        nil,
        screenRoot,
        "信号",
        112,
        231,
        66,
        30,
        showSignalAlbum,
        PALETTE.blue
    )
    makeButton(
        nil,
        screenRoot,
        "人物",
        40,
        231,
        66,
        30,
        showCastAlbum,
        PALETTE.teal
    )
    makeButton(
        nil,
        screenRoot,
        "剧集",
        -32,
        231,
        66,
        30,
        showHub,
        PALETTE.brick
    )
end
function buildDialogueBox(self)
    local clickArea = Node():addTo(screenRoot)
    clickArea.position = Vec2(0, -176)
    clickArea.size = Size(960, 188)
    clickArea.swallowTouches = true
    clickArea:onTapped(advanceDialogue)
    colorRect(
        nil,
        clickArea,
        480,
        94,
        936,
        170,
        Color(3994097696),
        2,
        Color(4292859589)
    )
    colorRect(
        nil,
        clickArea,
        480,
        176,
        928,
        6,
        PALETTE.teal
    )
    colorRect(
        nil,
        clickArea,
        159,
        166,
        246,
        39,
        Color(4280627771),
        2,
        PALETTE.teal
    )
    speakerLabel = textLabel(
        nil,
        clickArea,
        "",
        18,
        54,
        164,
        PALETTE.teal,
        214,
        "Left"
    )
    dialogueLabel = textLabel(
        nil,
        clickArea,
        "",
        18,
        52,
        115,
        PALETTE.paper,
        856,
        "Left"
    )
    nextLabel = textLabel(
        nil,
        clickArea,
        "▼",
        14,
        903,
        25,
        PALETTE.gold,
        24
    )
    textLabel(
        nil,
        clickArea,
        "ENTER / CLICK",
        10,
        777,
        24,
        PALETTE.muted,
        100,
        "Right"
    )
end
function buildStoryScene(self, episode)
    if state == nil then
        return
    end
    clearScreen(nil, "story")
    addBackground(nil, episode.background, episode.backgroundScale)
    colorRect(
        nil,
        screenRoot,
        0,
        20,
        960,
        500,
        Color(923208464)
    )
    local actorX = {-330, -110, 110, 330}
    do
        local index = 0
        while index < #CAST do
            local member = CAST[index + 1]
            addCastActor(
                nil,
                member.id,
                member.id,
                actorX[index + 1],
                0.56,
                8
            )
            local tag = panel(
                nil,
                screenRoot,
                actorX[index + 1],
                177,
                190,
                42,
                Color(3860472620),
                accentColor(nil, member.accent)
            )
            textLabel(
                nil,
                tag,
                (((member.id == state.playerId and "你 · " or "") .. member.name) .. " / ") .. member.role,
                11,
                0,
                -2,
                PALETTE.paper,
                174
            )
            index = index + 1
        end
    end
    buildToolbar(nil)
    buildDialogueBox(nil)
end
function showDialogue(self, statement)
    if dialogueLabel == nil or speakerLabel == nil or runtime == nil or currentEpisode == nil then
        return
    end
    fullDialogueText = resolveText(nil, statement.text)
    local count = utf8.len(fullDialogueText)
    fullCharacterCount = count or #fullDialogueText
    local key = (currentEpisode.id .. ":") .. tostring(runtime:getCursor() - 1)
    currentLineWasSeen = contains(nil, seenLines, key)
    pushUnique(nil, seenLines, key)
    typedCharacters = skipMode and currentLineWasSeen and fullCharacterCount or 0
    typeAccumulator = 0
    autoTimer = 0
    dialogueLabel.text = typedCharacters >= fullCharacterCount and fullDialogueText or ""
    speakerLabel.text = roleName(nil, statement.speaker)
    speakerLabel.color = roleAccent(nil, statement.speaker)
    if nextLabel ~= nil then
        nextLabel.opacity = typedCharacters >= fullCharacterCount and 1 or 0
    end
    updateActorFocus(nil, statement.speaker)
    appendBacklog(
        nil,
        roleName(nil, statement.speaker),
        fullDialogueText
    )
    snapshotStory(nil)
end
function dispatchMiniGame(self, statement)
    local handler = MINI_GAME_HANDLERS[statement.gameId]
    local function done()
        if runtime == nil then
            return
        end
        currentStatement = runtime:completeMiniGame(statement)
        presentStatement(nil)
    end
    if handler ~= nil then
        handler(nil, statement, done)
    else
        done(nil)
    end
end
function drawSignalImage(self, parent, signal, x, y, scale)
    local art = Sprite(signal.image)
    if art ~= nil then
        art.filter = "Anisotropic"
        art.scaleX = scale
        art.scaleY = scale
        art.position = Vec2(x, y)
        art:addTo(parent)
        return
    end
    colorRect(
        nil,
        parent,
        x,
        y,
        220,
        220,
        Color(4280298291),
        2,
        PALETTE.blue
    )
    textLabel(
        nil,
        parent,
        "图像待生成",
        15,
        x,
        y,
        PALETTE.muted,
        180
    )
end
function continueAfterSignal(self)
    closeOverlay(nil)
    if runtime == nil then
        return
    end
    currentStatement = runtime:advance()
    presentStatement(nil)
end
function showSignal(self, statement)
    if state == nil or currentEpisode == nil or runtime == nil then
        return
    end
    local signal = getSignal(nil, statement.signalId)
    if signal == nil or contains(nil, state.signals, signal.id) then
        currentStatement = runtime:advance()
        presentStatement(nil)
        return
    end
    pushUnique(nil, state.signals, signal.id)
    state.resumeEpisode = currentEpisode.id
    state.resumeCursor = runtime:getCursor()
    saveGame(nil)
    signalPromptOpen = true
    overlayRoot = Node():addTo(screenRoot)
    local blocker = Node():addTo(overlayRoot)
    blocker.position = Vec2.zero
    blocker.size = Size(960, 540)
    blocker.swallowTouches = true
    colorRect(
        nil,
        blocker,
        480,
        270,
        960,
        540,
        Color(3641183508)
    )
    local reveal = panel(
        nil,
        overlayRoot,
        0,
        0,
        760,
        430,
        Color(4212662569),
        PALETTE.gold
    )
    colorRect(
        nil,
        reveal,
        -207,
        0,
        286,
        286,
        Color(4279244573),
        2,
        PALETTE.blue
    )
    drawSignalImage(
        nil,
        reveal,
        signal,
        -207,
        0,
        0.26
    )
    textLabel(
        nil,
        reveal,
        "剧情信号",
        12,
        -20,
        159,
        PALETTE.gold,
        290,
        "Left"
    )
    textLabel(
        nil,
        reveal,
        signal.title,
        29,
        -20,
        111,
        PALETTE.paper,
        330,
        "Left"
    )
    textLabel(
        nil,
        reveal,
        signal.source,
        12,
        -20,
        70,
        PALETTE.blue,
        320,
        "Left"
    )
    colorRect(
        nil,
        reveal,
        145,
        41,
        330,
        2,
        PALETTE.coral
    )
    textLabel(
        nil,
        reveal,
        signal.description,
        14,
        -20,
        3,
        PALETTE.paper,
        330,
        "Left"
    )
    textLabel(
        nil,
        reveal,
        "线索指向",
        11,
        -20,
        -50,
        PALETTE.gold,
        120,
        "Left"
    )
    textLabel(
        nil,
        reveal,
        signal.clue,
        13,
        -20,
        -82,
        PALETTE.paper,
        330,
        "Left"
    )
    textLabel(
        nil,
        reveal,
        (("已收录 · " .. tostring(#state.signals)) .. "/") .. tostring(#SIGNALS),
        12,
        -20,
        -139,
        PALETTE.green,
        230,
        "Left"
    )
    makeButton(
        nil,
        reveal,
        "收下信号",
        -20,
        -189,
        330,
        46,
        continueAfterSignal,
        PALETTE.teal,
        true
    )
end
function presentStatement(self)
    if currentStatement == nil then
        showHub(nil)
        return
    end
    if currentStatement.kind == "say" then
        showDialogue(nil, currentStatement)
    elseif currentStatement.kind == "signal" then
        showSignal(nil, currentStatement)
    elseif currentStatement.kind == "menu" then
        showChoices(nil, currentStatement)
    elseif currentStatement.kind == "minigame" then
        dispatchMiniGame(nil, currentStatement)
    elseif currentStatement.kind == "end" then
        showEpisodeEnding(nil, currentStatement)
    end
end
function startEpisode(self, episode, resume)
    if state == nil or not episodeUnlocked(nil, episode) then
        return
    end
    currentEpisode = episode
    runtime = __TS__New(RenpyRuntime, episode.script, state.stats)
    choosing = false
    choiceLayer = nil
    buildStoryScene(nil, episode)
    local ____resume_3
    if resume then
        ____resume_3 = runtime:resume(state.resumeCursor)
    else
        ____resume_3 = runtime:start()
    end
    currentStatement = ____resume_3
    presentStatement(nil)
    finishScene(nil)
end
function revealDialogue(self)
    typedCharacters = fullCharacterCount
    if dialogueLabel ~= nil then
        dialogueLabel.text = fullDialogueText
    end
    if nextLabel ~= nil then
        nextLabel.opacity = 1
    end
    autoTimer = 0
end
function advanceDialogue(self)
    if scene ~= "story" or choosing or overlayRoot ~= nil or currentStatement == nil then
        return
    end
    if currentStatement.kind ~= "say" then
        return
    end
    if typedCharacters < fullCharacterCount then
        revealDialogue(nil)
        return
    end
    if runtime == nil then
        return
    end
    currentStatement = runtime:advance()
    presentStatement(nil)
end
function showChoices(self, statement)
    if choosing then
        return
    end
    choosing = true
    autoTimer = 0
    snapshotStory(nil)
    choiceLayer = Node():addTo(screenRoot)
    local blocker = Node():addTo(choiceLayer)
    blocker.position = Vec2.zero
    blocker.size = Size(960, 540)
    blocker.swallowTouches = true
    colorRect(
        nil,
        blocker,
        480,
        270,
        960,
        540,
        Color(1980239124)
    )
    local choicePanel = panel(
        nil,
        choiceLayer,
        0,
        38,
        820,
        300,
        Color(4061667883),
        PALETTE.teal
    )
    textLabel(
        nil,
        choicePanel,
        "轮到你接这句",
        12,
        0,
        115,
        PALETTE.gold,
        180
    )
    textLabel(
        nil,
        choicePanel,
        statement.prompt,
        20,
        0,
        77,
        PALETTE.paper,
        720
    )
    do
        local index = 0
        while index < #statement.choices do
            local selectedChoice = statement.choices[index + 1]
            makeButton(
                nil,
                choicePanel,
                (tostring(index + 1) .. "  ") .. selectedChoice.text,
                0,
                index == 0 and -10 or -86,
                720,
                58,
                function() return chooseStoryChoice(nil, selectedChoice) end,
                index == 0 and PALETTE.teal or PALETTE.gold
            )
            index = index + 1
        end
    end
    textLabel(
        nil,
        choicePanel,
        "1 / 2",
        10,
        0,
        -127,
        PALETTE.muted,
        100
    )
end
function chooseStoryChoice(self, choice)
    if runtime == nil or state == nil or currentEpisode == nil then
        return
    end
    if choiceLayer ~= nil then
        choiceLayer:removeFromParent()
    end
    choiceLayer = nil
    choosing = false
    pushUnique(nil, state.choices, (currentEpisode.id .. ":") .. choice.id)
    currentStatement = runtime:choose(choice)
    saveGame(nil)
    presentStatement(nil)
end
function showEpisodeEnding(self, statement)
    if state == nil or currentEpisode == nil then
        return
    end
    local episode = currentEpisode
    local isFinale = episode.path == "finale"
    pushUnique(nil, state.completed, episode.id)
    if isFinale then
        pushUnique(nil, state.endings, statement.id)
    end
    state.resumeEpisode = ""
    state.resumeCursor = 0
    saveGame(nil)
    clearScreen(nil, "ending")
    addBackground(nil, episode.background, episode.backgroundScale)
    colorRect(
        nil,
        screenRoot,
        0,
        0,
        960,
        540,
        Color(3070955800)
    )
    if isFinale then
        addCastActor(
            nil,
            "tang-li",
            "tang-li",
            296,
            0.7,
            0
        )
        addCastActor(
            nil,
            "zhou-yuan",
            "zhou-yuan",
            410,
            0.62,
            -8
        )
    else
        addCastActor(
            nil,
            state.playerId,
            state.playerId,
            348,
            0.75,
            0
        )
    end
    local card = panel(
        nil,
        screenRoot,
        -170,
        4,
        550,
        410,
        Color(4061799212),
        isFinale and PALETTE.gold or PALETTE.teal
    )
    textLabel(
        nil,
        card,
        (episode.number .. " / ") .. (isFinale and "真相" or "本集小结"),
        12,
        -240,
        170,
        PALETTE.gold,
        330,
        "Left"
    )
    textLabel(
        nil,
        card,
        statement.title,
        30,
        -240,
        119,
        PALETTE.paper,
        460,
        "Left"
    )
    if isFinale and statement.reveal ~= nil then
        textLabel(
            nil,
            card,
            statement.reveal,
            14,
            -240,
            72,
            PALETTE.coral,
            460,
            "Left"
        )
    end
    colorRect(
        nil,
        card,
        -5,
        isFinale and 47 or 69,
        440,
        2,
        PALETTE.coral
    )
    textLabel(
        nil,
        card,
        statement.summary,
        15,
        -240,
        isFinale and 3 or 26,
        PALETTE.paper,
        460,
        "Left"
    )
    textLabel(
        nil,
        card,
        isFinale and ("结局已收录 · " .. tostring(#state.endings)) .. " 个" or "本集已完成 · 真相仍在推进",
        13,
        -240,
        -91,
        PALETTE.green,
        350,
        "Left"
    )
    makeButton(
        nil,
        card,
        "返回剧集",
        -190,
        -177,
        210,
        44,
        showHub,
        PALETTE.teal,
        true
    )
    makeButton(
        nil,
        card,
        isFinale and "重看真相" or "继续下一集",
        12,
        -177,
        210,
        44,
        isFinale and (function() return startEpisode(nil, episode, false) end) or startNextEpisode,
        PALETTE.gold
    )
    finishScene(nil)
end
function startNextEpisode(self)
    if state == nil then
        return
    end
    for ____, episode in ipairs(EPISODES) do
        if episodeUnlocked(nil, episode) and not contains(nil, state.completed, episode.id) then
            startEpisode(nil, episode, false)
            return
        end
    end
    showHub(nil)
end
function showBacklog(self)
    if scene ~= "story" or overlayRoot ~= nil then
        return
    end
    overlayRoot = Node():addTo(screenRoot)
    local blocker = Node():addTo(overlayRoot)
    blocker.position = Vec2.zero
    blocker.size = Size(960, 540)
    blocker.swallowTouches = true
    colorRect(
        nil,
        blocker,
        480,
        270,
        960,
        540,
        Color(4061206560)
    )
    textLabel(
        nil,
        overlayRoot,
        "对话回看",
        28,
        -420,
        231,
        PALETTE.paper,
        300,
        "Left"
    )
    textLabel(
        nil,
        overlayRoot,
        "本次拍摄最近记录",
        12,
        -420,
        198,
        PALETTE.muted,
        300,
        "Left"
    )
    makeButton(
        nil,
        overlayRoot,
        "关闭",
        342,
        207,
        110,
        38,
        closeOverlay,
        PALETTE.brick
    )
    colorRect(
        nil,
        overlayRoot,
        0,
        174,
        840,
        2,
        PALETTE.gold
    )
    local start = math.max(0, #backlog - 7)
    do
        local index = start
        while index < #backlog do
            local row = index - start
            local speaker, content = string.match(backlog[index + 1], "([^｜]+)｜(.+)")
            textLabel(
                nil,
                overlayRoot,
                speaker or "",
                13,
                -416,
                139 - row * 55,
                PALETTE.teal,
                120,
                "Left"
            )
            textLabel(
                nil,
                overlayRoot,
                content or backlog[index + 1],
                13,
                -278,
                139 - row * 55,
                PALETTE.paper,
                690,
                "Left"
            )
            index = index + 1
        end
    end
    if #backlog == 0 then
        textLabel(
            nil,
            overlayRoot,
            "还没有对话记录。",
            15,
            0,
            0,
            PALETTE.muted,
            400
        )
    end
end
function showCastAlbum(self)
    if state == nil or overlayRoot ~= nil then
        return
    end
    overlayRoot = Node():addTo(screenRoot)
    local blocker = Node():addTo(overlayRoot)
    blocker.position = Vec2.zero
    blocker.size = Size(960, 540)
    blocker.swallowTouches = true
    colorRect(
        nil,
        blocker,
        480,
        270,
        960,
        540,
        Color(4145092640)
    )
    textLabel(
        nil,
        overlayRoot,
        "人物关系",
        28,
        -420,
        231,
        PALETTE.paper,
        220,
        "Left"
    )
    textLabel(
        nil,
        overlayRoot,
        "开放日收尾组：黄一澈发稿，张开送管墙，寒予水主持，李童牧执行",
        12,
        -420,
        198,
        PALETTE.muted,
        650,
        "Left"
    )
    makeButton(
        nil,
        overlayRoot,
        "关闭",
        342,
        207,
        110,
        38,
        closeOverlay,
        PALETTE.brick
    )
    colorRect(
        nil,
        overlayRoot,
        0,
        174,
        840,
        2,
        PALETTE.gold
    )
    do
        local index = 0
        while index < #CAST do
            local member = CAST[index + 1]
            local selected = member.id == state.playerId
            local x = -342 + index * 228
            local card = panel(
                nil,
                overlayRoot,
                x,
                -19,
                204,
                350,
                Color(4061799212),
                selected and PALETTE.white or accentColor(nil, member.accent)
            )
            local portrait = Sprite(member.sprite)
            if portrait ~= nil then
                portrait.filter = "Point"
                portrait.scaleX = 0.31
                portrait.scaleY = 0.31
                portrait.position = Vec2(0, 68)
                portrait:addTo(card)
            end
            textLabel(
                nil,
                card,
                (selected and "你 · " or "") .. member.name,
                18,
                0,
                -28,
                PALETTE.paper,
                174
            )
            textLabel(
                nil,
                card,
                member.role,
                11,
                0,
                -56,
                accentColor(nil, member.accent),
                174
            )
            textLabel(
                nil,
                card,
                member.task,
                11,
                0,
                -88,
                PALETTE.blue,
                174
            )
            textLabel(
                nil,
                card,
                member.quip,
                11,
                0,
                -130,
                PALETTE.paper,
                168
            )
            index = index + 1
        end
    end
end
function showSignalAlbum(self)
    if state == nil or overlayRoot ~= nil then
        return
    end
    signalPromptOpen = false
    overlayRoot = Node():addTo(screenRoot)
    local blocker = Node():addTo(overlayRoot)
    blocker.position = Vec2.zero
    blocker.size = Size(960, 540)
    blocker.swallowTouches = true
    colorRect(
        nil,
        blocker,
        480,
        270,
        960,
        540,
        Color(4145092640)
    )
    textLabel(
        nil,
        overlayRoot,
        "剧情信号",
        28,
        -420,
        231,
        PALETTE.paper,
        260,
        "Left"
    )
    textLabel(
        nil,
        overlayRoot,
        (("已收录 " .. tostring(#state.signals)) .. "/") .. tostring(#SIGNALS),
        12,
        -420,
        198,
        PALETTE.muted,
        260,
        "Left"
    )
    makeButton(
        nil,
        overlayRoot,
        "关闭",
        342,
        207,
        110,
        38,
        closeOverlay,
        PALETTE.brick
    )
    colorRect(
        nil,
        overlayRoot,
        0,
        174,
        840,
        2,
        PALETTE.gold
    )
    do
        local index = 0
        while index < #SIGNALS do
            local signal = SIGNALS[index + 1]
            local collected = contains(nil, state.signals, signal.id)
            local x = -342 + index * 228
            local card = panel(
                nil,
                overlayRoot,
                x,
                -19,
                204,
                350,
                Color(4061799212),
                collected and PALETTE.blue or Color(4284047977)
            )
            colorRect(
                nil,
                card,
                0,
                66,
                166,
                166,
                Color(4279244573),
                2,
                collected and PALETTE.blue or Color(4284047977)
            )
            if collected then
                drawSignalImage(
                    nil,
                    card,
                    signal,
                    0,
                    66,
                    0.14
                )
            else
                textLabel(
                    nil,
                    card,
                    "?",
                    48,
                    0,
                    66,
                    Color(4285101178),
                    80
                )
            end
            textLabel(
                nil,
                card,
                collected and signal.title or "尚未收录",
                16,
                0,
                -38,
                collected and PALETTE.paper or PALETTE.muted,
                174
            )
            textLabel(
                nil,
                card,
                collected and signal.source or "继续推进剧情",
                10,
                0,
                -65,
                collected and PALETTE.blue or Color(4285101178),
                174
            )
            textLabel(
                nil,
                card,
                collected and signal.description or "",
                10,
                0,
                -98,
                PALETTE.paper,
                168
            )
            textLabel(
                nil,
                card,
                collected and "线索：" .. signal.clue or "",
                10,
                0,
                -145,
                PALETTE.gold,
                168
            )
            index = index + 1
        end
    end
end
function closeOverlay(self)
    if overlayRoot ~= nil then
        overlayRoot:removeFromParent()
    end
    overlayRoot = nil
    signalPromptOpen = false
end
LOGICAL_WIDTH = 960
LOGICAL_HEIGHT = 540
FONT = "sarasa-mono-sc-regular"
PALETTE = {
    ink = Color(4279310368),
    inkSoft = Color(4280693050),
    glass = Color(3860472620),
    paper = Color(4294439396),
    muted = Color(4290364865),
    teal = Color(4284008379),
    gold = Color(4293903965),
    brick = Color(4290600025),
    coral = Color(4293752690),
    blue = Color(4285049296),
    green = Color(4285053314),
    shadow = Color(2852588304),
    transparent = Color(0),
    whiteGlow = Color(2298478591),
    white = Color(4294967295)
}
local stage = Node()
screenRoot = Node():addTo(stage)
Director.entry:addChild(stage)
scene = "title"
profileCastId = "lin-cheng"
profileName = "黄一澈"
slotMode = "new"
fullDialogueText = ""
typedCharacters = 0
fullCharacterCount = 0
typeAccumulator = 0
autoTimer = 0
autoMode = false
skipMode = false
choosing = false
currentLineWasSeen = false
signalPromptOpen = false
toastTimer = 0
storyActors = {}
motions = {}
backlog = {}
seenLines = {}
local lastViewWidth = 0
local lastViewHeight = 0
sceneTime = 0
MINI_GAME_HANDLERS = {}
local function clamp(self, value, minimum, maximum)
    return math.max(
        minimum,
        math.min(maximum, value)
    )
end
local function updateViewport(self)
    local viewSize = View.size
    if viewSize.width == lastViewWidth and viewSize.height == lastViewHeight then
        return
    end
    lastViewWidth = viewSize.width
    lastViewHeight = viewSize.height
    local scale = math.min(viewSize.width / LOGICAL_WIDTH, viewSize.height / LOGICAL_HEIGHT)
    local camera = tolua.cast(Director.currentCamera, "Camera2D")
    if camera then
        camera.zoom = scale
        camera.position = Vec2.zero
        camera.rotation = 0
    end
    stage.scaleX = 1
    stage.scaleY = 1
    stage.position = Vec2.zero
end
local function updatePresentation(self, deltaTime)
    sceneTime = sceneTime + deltaTime
    for ____, motion in ipairs(motions) do
        motion.node.x = motion.baseX + math.sin(sceneTime * motion.speed + motion.phase) * motion.amplitudeX
        motion.node.y = motion.baseY + math.sin(sceneTime * motion.speed + motion.phase) * motion.amplitudeY
    end
    if sceneFade ~= nil then
        sceneFade.opacity = math.max(0, sceneFade.opacity - deltaTime * 4.8)
        if sceneFade.opacity <= 0 then
            sceneFade:removeFromParent()
            sceneFade = nil
        end
    end
    if toastRoot ~= nil then
        toastTimer = toastTimer - deltaTime
        if toastTimer <= 0 then
            toastRoot:removeFromParent()
            toastRoot = nil
        end
    end
    if scene ~= "story" or choosing or overlayRoot ~= nil or dialogueLabel == nil or currentStatement == nil or currentStatement.kind ~= "say" then
        return
    end
    if typedCharacters < fullCharacterCount then
        typeAccumulator = typeAccumulator + deltaTime * 32
        local amount = math.floor(typeAccumulator)
        if amount > 0 then
            typeAccumulator = typeAccumulator - amount
            typedCharacters = math.min(fullCharacterCount, typedCharacters + amount)
            dialogueLabel.text = truncateUtf8(nil, fullDialogueText, typedCharacters)
            if typedCharacters >= fullCharacterCount and nextLabel ~= nil then
                nextLabel.opacity = 1
            end
        end
        return
    end
    if skipMode and currentLineWasSeen then
        autoTimer = autoTimer + deltaTime
        if autoTimer >= 0.09 then
            advanceDialogue(nil)
        end
        return
    end
    if autoMode then
        autoTimer = autoTimer + deltaTime
        if autoTimer >= 1.45 then
            advanceDialogue(nil)
        end
    end
end
local function activatePrimary(self)
    if scene == "title" then
        showProfile(nil)
    elseif scene == "profile" then
        showSlots(nil, "new")
    elseif scene == "story" then
        advanceDialogue(nil)
    elseif scene == "ending" then
        if currentEpisode ~= nil and currentEpisode.path == "finale" then
            showHub(nil)
        else
            startNextEpisode(nil)
        end
    end
end
stage:onKeyDown(function(key)
    if scene == "slots" and key == "1" then
        chooseSlot(nil, 1)
    elseif scene == "slots" and key == "2" then
        chooseSlot(nil, 2)
    elseif scene == "slots" and key == "3" then
        chooseSlot(nil, 3)
    elseif scene == "story" and choosing and key == "1" and currentStatement ~= nil and currentStatement.kind == "menu" then
        chooseStoryChoice(nil, currentStatement.choices[1])
    elseif scene == "story" and choosing and key == "2" and currentStatement ~= nil and currentStatement.kind == "menu" then
        chooseStoryChoice(nil, currentStatement.choices[2])
    elseif key == "Return" or key == "Space" or key == "E" then
        activatePrimary(nil)
    elseif key == "Escape" then
        if signalPromptOpen then
            continueAfterSignal(nil)
        elseif overlayRoot ~= nil then
            closeOverlay(nil)
        elseif scene == "story" or scene == "ending" then
            showHub(nil)
        elseif scene ~= "title" then
            showTitle(nil)
        end
    end
end)
stage:onButtonDown(function(_controllerId, button)
    if button == "a" then
        activatePrimary(nil)
    elseif button == "b" or button == "back" then
        if signalPromptOpen then
            continueAfterSignal(nil)
        elseif overlayRoot ~= nil then
            closeOverlay(nil)
        elseif scene == "story" or scene == "ending" then
            showHub(nil)
        elseif scene ~= "title" then
            showTitle(nil)
        end
    end
end)
stage:schedule(function(deltaTime)
    updateViewport(nil)
    updatePresentation(nil, deltaTime)
    return false
end)
updateViewport(nil)
showTitle(nil)
return ____exports
