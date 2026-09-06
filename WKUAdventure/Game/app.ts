import {
	ButtonName, Color, Content, Director, DrawNode, KeyName, Label, Node, Path,
	Size, Sprite, TextAlign, TextureFilter, TypeName, Vec2, View, tolua
} from "Dora";
import {
	AccentKey, CAST, CastId, CastMember, EPISODES, Episode, EpisodeId,
	SIGNALS, SignalId, StorySignal
} from "Game/content";
import {MenuChoice, RenpyRuntime, RoleId, Statement, StoryStats} from "Game/renpy";

type SceneId = "title" | "profile" | "slots" | "hub" | "story" | "ending";

interface GameState {
	version: number;
	slot: number;
	playerId: CastId;
	playerName: string;
	completed: EpisodeId[];
	choices: string[];
	endings: string[];
	signals: SignalId[];
	stats: StoryStats;
	resumeEpisode: string;
	resumeCursor: number;
}

interface Motion {
	node: Node.Type;
	baseX: number;
	baseY: number;
	phase: number;
	amplitudeX: number;
	amplitudeY: number;
	speed: number;
}

interface ActorVisual { role: RoleId; node: Node.Type; }
interface ButtonVisual { node: Node.Type; label: Label.Type; face: Node.Type; }
type MiniGameStatement = Extract<Statement, {kind: "minigame"}>;
type SayStatement = Extract<Statement, {kind: "say"}>;
type MenuStatement = Extract<Statement, {kind: "menu"}>;
type EndingStatement = Extract<Statement, {kind: "end"}>;
type SignalStatement = Extract<Statement, {kind: "signal"}>;
type MiniGameHandler = (statement: MiniGameStatement, done: () => void) => void;

const LOGICAL_WIDTH = 960;
const LOGICAL_HEIGHT = 540;
const FONT = "sarasa-mono-sc-regular";
const PALETTE = {
	ink: Color(0xff111820), inkSoft: Color(0xff26313a), glass: Color(0xe61a232c),
	paper: Color(0xfff7f1e4), muted: Color(0xffb9c5c1), teal: Color(0xff58c7bb),
	gold: Color(0xffefc65d), brick: Color(0xffbd5c59), coral: Color(0xffed7772),
	blue: Color(0xff68a9d0), green: Color(0xff68b982), shadow: Color(0xaa070b10),
	transparent: Color(0x00000000), whiteGlow: Color(0x88ffffff), white: Color(0xffffffff)
};

const stage = Node();
const screenRoot = Node().addTo(stage);
Director.entry.addChild(stage);

let scene: SceneId = "title";
let state: GameState | undefined;
let profileCastId: CastId = "lin-cheng";
let profileName = "黄一澈";
let slotMode: "new" | "load" = "new";
let currentEpisode: Episode | undefined;
let runtime: RenpyRuntime | undefined;
let currentStatement: Statement | undefined;
let fullDialogueText = "";
let typedCharacters = 0;
let fullCharacterCount = 0;
let typeAccumulator = 0;
let autoTimer = 0;
let autoMode = false;
let skipMode = false;
let choosing = false;
let currentLineWasSeen = false;
let dialogueLabel: Label.Type | undefined;
let speakerLabel: Label.Type | undefined;
let nextLabel: Label.Type | undefined;
let episodeLabel: Label.Type | undefined;
let autoButtonLabel: Label.Type | undefined;
let skipButtonLabel: Label.Type | undefined;
let choiceLayer: Node.Type | undefined;
let overlayRoot: Node.Type | undefined;
let signalPromptOpen = false;
let toastRoot: Node.Type | undefined;
let toastTimer = 0;
let sceneFade: Node.Type | undefined;
let backgroundVisual: Node.Type | undefined;
let storyActors: ActorVisual[] = [];
let motions: Motion[] = [];
let backlog: string[] = [];
let seenLines: string[] = [];
let lastViewWidth = 0;
let lastViewHeight = 0;
let sceneTime = 0;

// Future mini-games register a handler here; unregistered hooks continue the dialogue path.
const MINI_GAME_HANDLERS: Record<string, MiniGameHandler | undefined> = {};

function contains<T extends {}>(items: T[], item: T): boolean {
	for (const value of items) if (value === item) return true;
	return false;
}

function pushUnique<T extends {}>(items: T[], item: T): void {
	if (!contains(items, item)) items.push(item);
}

function clamp(value: number, minimum: number, maximum: number): number {
	return math.max(minimum, math.min(maximum, value));
}

function truncateUtf8(text: string, maxChars: number): string {
	const [count] = utf8.len(text);
	if (count === undefined || count <= maxChars) return text;
	const nextByte = utf8.offset(text, maxChars + 1);
	return nextByte === undefined ? text : string.sub(text, 1, nextByte - 1);
}

function sanitizeName(text: string): string {
	const [clean] = string.gsub(text, "[\r\n=,|]", "");
	return truncateUtf8(clean, 8);
}

function accentColor(key: AccentKey): Color.Type {
	if (key === "gold") return PALETTE.gold;
	if (key === "coral") return PALETTE.coral;
	if (key === "blue") return PALETTE.blue;
	return PALETTE.teal;
}

function getCast(id: CastId): CastMember {
	for (const member of CAST) if (member.id === id) return member;
	error(`未知角色: ${id}`);
}

function getEpisode(id: string): Episode | undefined {
	for (const episode of EPISODES) if (episode.id === id) return episode;
	return undefined;
}

function getSignal(id: string): StorySignal | undefined {
	for (const signal of SIGNALS) if (signal.id === id) return signal;
	return undefined;
}

function selectedName(): string {
	return state === undefined ? profileName : state.playerName;
}

function resolveText(text: string): string {
	const [resolved] = string.gsub(text, "{name}", selectedName());
	return resolved;
}

function colorRect(parent: Node.Type, x: number, y: number, width: number, height: number, fill: Color.Type, borderWidth = 0, border = PALETTE.transparent): DrawNode.Type {
	const draw = DrawNode().addTo(parent);
	draw.position = Vec2(x, y);
	draw.drawPolygon([
		Vec2(-width / 2, -height / 2), Vec2(width / 2, -height / 2),
		Vec2(width / 2, height / 2), Vec2(-width / 2, height / 2)
	], fill, borderWidth, border);
	return draw;
}

function textLabel(parent: Node.Type, text: string, size: number, x: number, y: number, color = PALETTE.paper, width = 0, align = TextAlign.Center): Label.Type {
	const label = Label(FONT, size, true);
	if (label === undefined) error("无法加载中文字体");
	label.text = text;
	const adjustedX = width > 0
		? align === TextAlign.Left ? x + width / 2 : align === TextAlign.Right ? x - width / 2 : x
		: x;
	label.position = Vec2(adjustedX, y);
	label.color = color;
	label.alignment = align;
	label.lineGap = math.max(2, math.floor(size * 0.3));
	if (width > 0) label.textWidth = width;
	label.addTo(parent);
	return label;
}

function panel(parent: Node.Type, x: number, y: number, width: number, height: number, fill = PALETTE.glass, accent = PALETTE.teal): Node.Type {
	const root = Node().addTo(parent);
	root.position = Vec2(x, y);
	colorRect(root, 5, -7, width, height, PALETTE.shadow);
	colorRect(root, 0, 0, width, height, fill, 2, Color(0xaae9e0ca));
	colorRect(root, 0, height / 2 - 4, width, 6, accent);
	return root;
}

function makeButton(parent: Node.Type, text: string, x: number, y: number, width: number, height: number, action: () => void, accent = PALETTE.teal, selected = false, disabled = false): ButtonVisual {
	const button = Node().addTo(parent);
	button.position = Vec2(x, y);
	button.size = Size(width, height);
	button.swallowTouches = true;
	colorRect(button, width / 2 + 3, height / 2 - 5, width - 4, height - 2, PALETTE.shadow);
	const face = Node().addTo(button);
	face.position = Vec2(width / 2, height / 2);
	const fill = disabled ? Color(0xee313940) : selected ? accent : Color(0xf024333c);
	const edge = disabled ? Color(0xff69747a) : selected ? PALETTE.paper : accent;
	colorRect(face, 0, 0, width, height, fill, 2, edge);
	colorRect(face, 0, height / 2 - 3, width - 8, 4, edge);
	const label = textLabel(face, text, height <= 34 ? 13 : height <= 46 ? 15 : 17, 0, -1, disabled ? Color(0xff879095) : PALETTE.paper, width - 16);
	if (!disabled) {
		button.onTapBegan(() => face.y = height / 2 - 3);
		button.onTapEnded(() => face.y = height / 2);
		button.onTapped(action);
	}
	return {node: button, label, face};
}

function addMotion(node: Node.Type, amplitudeX: number, amplitudeY: number, speed: number, phase: number): void {
	motions.push({node, baseX: node.x, baseY: node.y, amplitudeX, amplitudeY, speed, phase});
}

function addBackground(path: string, scale: number): Node.Type | undefined {
	const sprite = Sprite(path);
	if (sprite === undefined) return undefined;
	sprite.filter = TextureFilter.Point;
	sprite.scaleX = scale;
	sprite.scaleY = scale;
	sprite.position = Vec2.zero;
	sprite.addTo(screenRoot);
	backgroundVisual = sprite;
	return sprite;
}

function addCastActor(memberId: CastId, role: RoleId, x: number, scale = 0.8, y = 0, parent = screenRoot): Node.Type | undefined {
	const sprite = Sprite(getCast(memberId).sprite);
	if (sprite === undefined) return undefined;
	sprite.filter = TextureFilter.Point;
	sprite.scaleX = scale;
	sprite.scaleY = scale;
	sprite.position = Vec2(x, y);
	sprite.addTo(parent);
	storyActors.push({role, node: sprite});
	addMotion(sprite, 0, 2.3, 1.35, storyActors.length * 0.8);
	return sprite;
}

function finishScene(): void {
	const veil = Node().addTo(screenRoot);
	veil.passOpacity = true;
	veil.opacity = 1;
	colorRect(veil, 0, 0, LOGICAL_WIDTH, LOGICAL_HEIGHT, PALETTE.ink);
	sceneFade = veil;
}

function clearScreen(nextScene: SceneId): void {
	scene = nextScene;
	screenRoot.removeAllChildren();
	dialogueLabel = undefined;
	speakerLabel = undefined;
	nextLabel = undefined;
	episodeLabel = undefined;
	autoButtonLabel = undefined;
	skipButtonLabel = undefined;
	choiceLayer = undefined;
	overlayRoot = undefined;
	signalPromptOpen = false;
	toastRoot = undefined;
	toastTimer = 0;
	sceneFade = undefined;
	backgroundVisual = undefined;
	storyActors = [];
	motions = [];
	sceneTime = 0;
}

function showToast(message: string, accent = PALETTE.teal): void {
	if (toastRoot !== undefined) toastRoot.removeFromParent();
	toastRoot = panel(screenRoot, 0, 210, 310, 48, Color(0xf21a232c), accent);
	textLabel(toastRoot, message, 14, 0, -1, PALETTE.paper, 280);
	toastTimer = 2.1;
}

function saveDirectory(): string { return Path(Content.writablePath, "WKUAfterlightSaves"); }
function savePath(slot: number): string { return Path(saveDirectory(), `slot-${slot}.sav`); }

function saveGame(): boolean {
	if (state === undefined) return false;
	if (!Content.exist(saveDirectory())) Content.mkdir(saveDirectory());
	const lines = [
		`version=${state.version}`, `slot=${state.slot}`, `playerId=${state.playerId}`,
		`playerName=${sanitizeName(state.playerName)}`, `completed=${table.concat(state.completed, ",")}`,
		`choices=${table.concat(state.choices, ",")}`, `endings=${table.concat(state.endings, ",")}`,
		`signals=${table.concat(state.signals, ",")}`,
		`chaos=${state.stats.chaos}`, `order=${state.stats.order}`, `warmth=${state.stats.warmth}`, `wit=${state.stats.wit}`,
		`resumeEpisode=${state.resumeEpisode}`, `resumeCursor=${state.resumeCursor}`
	];
	return Content.save(savePath(state.slot), table.concat(lines, "\n"));
}

function valueFrom(content: string, key: string): string | undefined {
	const [value] = string.match(content, `${key}=([^\r\n]*)`);
	return value;
}

function numberFrom(content: string, key: string, fallback: number): number {
	return tonumber(valueFrom(content, key) ?? "") ?? fallback;
}

function listFrom(value: string | undefined): string[] {
	const result: string[] = [];
	if (value === undefined || value.length === 0) return result;
	for (const [item] of string.gmatch(value, "([^,]+)")) result.push(item);
	return result;
}

function castIdFrom(value: string | undefined): CastId {
	for (const member of CAST) if (member.id === value) return member.id;
	return "lin-cheng";
}

function loadGame(slot: number): GameState | undefined {
	const path = savePath(slot);
	if (!Content.exist(path)) return undefined;
	const content = Content.load(path);
	if (content.length === 0) return undefined;
	const version = numberFrom(content, "version", 0);
	if (version !== 3 && version !== 4 && version !== 5 && version !== 6) return undefined;
	const isLegacyStory = version !== 6;
	const playerId = castIdFrom(valueFrom(content, "playerId"));
	const completed: EpisodeId[] = [];
	for (const value of isLegacyStory ? [] : listFrom(valueFrom(content, "completed"))) {
		const episode = getEpisode(value);
		if (episode !== undefined) pushUnique(completed, episode.id);
	}
	const signals: SignalId[] = [];
	for (const value of isLegacyStory ? [] : listFrom(valueFrom(content, "signals"))) {
		const signal = getSignal(value);
		if (signal !== undefined) pushUnique(signals, signal.id);
	}
	return {
		version: 6, slot,
		playerId,
		playerName: getCast(playerId).name,
		completed,
		choices: isLegacyStory ? [] : listFrom(valueFrom(content, "choices")),
		endings: isLegacyStory ? [] : listFrom(valueFrom(content, "endings")),
		signals,
		stats: {
			chaos: isLegacyStory ? 0 : math.max(0, numberFrom(content, "chaos", 0)),
			order: isLegacyStory ? 0 : math.max(0, numberFrom(content, "order", 0)),
			warmth: isLegacyStory ? 0 : math.max(0, numberFrom(content, "warmth", 0)),
			wit: isLegacyStory ? 0 : math.max(0, numberFrom(content, "wit", 0))
		},
		resumeEpisode: isLegacyStory ? "" : valueFrom(content, "resumeEpisode") ?? "",
		resumeCursor: isLegacyStory ? 0 : math.max(0, numberFrom(content, "resumeCursor", 0))
	};
}

function newState(slot: number): GameState {
	return {
		version: 6, slot, playerId: profileCastId,
		playerName: getCast(profileCastId).name,
		completed: [], choices: [], endings: [], signals: [], stats: {chaos: 0, order: 0, warmth: 0, wit: 0},
		resumeEpisode: "", resumeCursor: 0
	};
}

function completedBeatCount(gameState: GameState): number {
	let count = contains(gameState.completed, "wall-post") ? 1 : 0;
	if (contains(gameState.completed, "mint-decoy") || contains(gameState.completed, "third-row")) count++;
	if (contains(gameState.completed, "lake-meetup")) count++;
	return count;
}

function slotSummary(slot: number): string {
	const loaded = loadGame(slot);
	if (loaded === undefined) return "空档案 · 等待开拍";
	return `${loaded.playerName} 饰 ${getCast(loaded.playerId).name} · ${completedBeatCount(loaded)}/3 集`;
}

function showTitle(): void {
	clearScreen("title");
	addBackground("Image/Scenes/outdoor-garden-bridge.png", 0.574);
	colorRect(screenRoot, 0, 0, 960, 540, Color(0x6f080d14));
	colorRect(screenRoot, -256, 0, 448, 540, Color(0xe1111820));
	colorRect(screenRoot, -30, 0, 5, 540, PALETTE.coral);
	textLabel(screenRoot, "WKU SITCOM / SEASON 01", 12, -438, 214, PALETTE.gold, 260, TextAlign.Left);
	textLabel(screenRoot, "温肯：这条表白全校已读", 32, -438, 133, PALETTE.paper, 400, TextAlign.Left);
	textLabel(screenRoot, "一条误发，一次撤回，五次越描越黑。", 15, -438, 79, PALETTE.muted, 390, TextAlign.Left);
	colorRect(screenRoot, -291, 43, 272, 2, PALETTE.teal);
	textLabel(screenRoot, "他们只想删帖，结果把秘密做成了直播。", 14, -438, 5, PALETTE.paper, 370, TextAlign.Left);
	makeButton(screenRoot, "开始选角", -360, -137, 238, 52, showProfile, PALETTE.teal, true);
	makeButton(screenRoot, "读取档案", -360, -202, 238, 46, () => showSlots("load"), PALETTE.gold);
	addCastActor("jiang-ran", "jiang-ran", 94, 0.55, 0);
	addCastActor("lin-cheng", "lin-cheng", 210, 0.61, 2);
	addCastActor("tang-li", "tang-li", 324, 0.56, 0);
	addCastActor("zhou-yuan", "zhou-yuan", 426, 0.53, 0);
	finishScene();
}

function selectProfile(memberId: CastId): void {
	profileCastId = memberId;
	profileName = getCast(memberId).name;
	showProfile();
}

function drawCastCard(member: CastMember, index: number): void {
	const selected = member.id === profileCastId;
	const cardWidth = 198;
	const cardHeight = 326;
	const centerX = -330 + index * 220;
	const centerY = 12;
	const root = Node().addTo(screenRoot);
	root.position = Vec2(centerX, centerY);
	if (selected) {
		colorRect(root, 0, 0, cardWidth + 12, cardHeight + 12, PALETTE.transparent, 7, PALETTE.whiteGlow);
		colorRect(root, 0, 0, cardWidth + 4, cardHeight + 4, PALETTE.transparent, 3, PALETTE.white);
	}
	colorRect(root, 3, -6, cardWidth, cardHeight, PALETTE.shadow);
	colorRect(root, 0, 0, cardWidth, cardHeight, selected ? Color(0xf02c3a43) : Color(0xea182129), 2, selected ? PALETTE.white : accentColor(member.accent));
	colorRect(root, 0, cardHeight / 2 - 4, cardWidth - 8, 5, accentColor(member.accent));
	const portrait = Sprite(member.sprite);
	if (portrait !== undefined) {
		portrait.filter = TextureFilter.Point;
		portrait.scaleX = 0.36;
		portrait.scaleY = 0.36;
		portrait.position = Vec2(0, 51);
		portrait.addTo(root);
	}
	textLabel(root, member.name, 20, 0, -58, PALETTE.paper, 170);
	textLabel(root, member.role, 12, 0, -88, selected ? PALETTE.white : PALETTE.muted, 170);
	textLabel(root, `今晚：${member.task}`, 10, 0, -117, PALETTE.blue, 172);
	textLabel(root, member.quip, 10, 0, -145, PALETTE.paper, 170);
	textLabel(root, member.pronoun, 10, 0, 141, accentColor(member.accent), 24);
	const tap = Node().addTo(root);
	tap.position = Vec2(-cardWidth / 2, -cardHeight / 2);
	tap.size = Size(cardWidth, cardHeight);
	tap.swallowTouches = true;
	tap.onTapped(() => selectProfile(member.id));
}

function showProfile(): void {
	clearScreen("profile");
	addBackground("Image/Scenes/outdoor-lake-path.png", 0.574);
	colorRect(screenRoot, 0, 0, 960, 540, Color(0xd410171f));
	textLabel(screenRoot, "从谁的视角看这场误发", 28, 0, 230, PALETTE.paper, 560);
	textLabel(screenRoot, "四个人都在现场；白框角色是你的视角人物", 12, 0, 198, PALETTE.muted, 620);
	for (let index = 0; index < CAST.length; index++) drawCastCard(CAST[index], index);
	makeButton(screenRoot, "返回", -405, -257, 136, 40, showTitle, PALETTE.brick);
	textLabel(screenRoot, `${getCast(profileCastId).name} · ${getCast(profileCastId).role}`, 13, -90, -245, PALETTE.muted, 300);
	makeButton(screenRoot, "确认视角", 290, -257, 190, 40, () => showSlots("new"), PALETTE.teal, true);
	finishScene();
}

function showSlots(mode: "new" | "load"): void {
	clearScreen("slots");
	slotMode = mode;
	addBackground("Image/Scenes/outdoor-lakeside-flowers.png", 0.574);
	colorRect(screenRoot, 0, 0, 960, 540, Color(0xc90b1118));
	textLabel(screenRoot, mode === "new" ? "选择拍摄档案" : "读取拍摄档案", 29, 0, 220, PALETTE.paper, 650);
	textLabel(screenRoot, mode === "new" ? "已有档案会被新一季覆盖" : "读取后会回到上次中断的台词", 12, 0, 184, PALETTE.muted, 620);
	for (let slot = 1; slot <= 3; slot++) {
		const selectedSlot = slot;
		const loaded = loadGame(slot);
		const disabled = mode === "load" && loaded === undefined;
		const accent = slot === 1 ? PALETTE.teal : slot === 2 ? PALETTE.gold : PALETTE.coral;
		const card = panel(screenRoot, 0, 102 - (slot - 1) * 114, 650, 88, Color(0xee1a232c), accent);
		textLabel(card, `0${slot}`, 24, -286, 7, PALETTE.paper, 55, TextAlign.Left);
		textLabel(card, slotSummary(slot), 15, -205, 9, disabled ? Color(0xff7b8589) : PALETTE.paper, 370, TextAlign.Left);
		textLabel(card, loaded === undefined ? "NEW" : mode === "new" ? "覆盖" : "LOAD", 11, 185, 8, disabled ? Color(0xff687278) : PALETTE.muted, 60);
		makeButton(card, mode === "new" ? "选择" : "读取", 218, -21, 96, 42, () => chooseSlot(selectedSlot), accent, false, disabled);
	}
	makeButton(screenRoot, "返回", -405, -257, 136, 40, mode === "new" ? showProfile : showTitle, PALETTE.brick);
	textLabel(screenRoot, "数字键 1 / 2 / 3", 11, 290, -236, PALETTE.muted, 190, TextAlign.Right);
	finishScene();
}

function chooseSlot(slot: number): void {
	if (slotMode === "new") {
		state = newState(slot);
		saveGame();
		showHub();
		return;
	}
	const loaded = loadGame(slot);
	if (loaded === undefined) return;
	state = loaded;
	const resume = getEpisode(state.resumeEpisode);
	if (resume !== undefined) startEpisode(resume, true);
	else showHub();
}

function episodeUnlocked(episode: Episode): boolean {
	if (state === undefined) return false;
	if (episode.path === "opening") return true;
	if (episode.path === "chaos") return contains(state.choices, "wall-post:leave-up");
	if (episode.path === "order") return contains(state.choices, "wall-post:trace");
	return contains(state.completed, "wall-post")
		&& (contains(state.completed, "mint-decoy") || contains(state.completed, "third-row"));
}

function episodeStatus(episode: Episode): string {
	if (state === undefined) return "";
	if (contains(state.completed, episode.id)) return "已收录";
	return episodeUnlocked(episode) ? "待开拍" : "未解锁";
}

function drawEpisodeCard(episode: Episode, index: number): void {
	if (state === undefined) return;
	const unlocked = episodeUnlocked(episode);
	const completed = contains(state.completed, episode.id);
	const centersX = [-224, 224, -224, 224];
	const centersY = [103, 103, -84, -84];
	const root = panel(screenRoot, centersX[index], centersY[index], 408, 158, Color(0xef182129), completed ? PALETTE.green : unlocked ? PALETTE.teal : Color(0xff596269));
	textLabel(root, episode.number, 11, -184, 55, completed ? PALETTE.green : unlocked ? PALETTE.gold : PALETTE.muted, 90, TextAlign.Left);
	textLabel(root, episodeStatus(episode), 11, 96, 55, completed ? PALETTE.green : PALETTE.muted, 90, TextAlign.Right);
	textLabel(root, episode.title, 21, -184, 17, unlocked ? PALETTE.paper : Color(0xff879095), 355, TextAlign.Left);
	textLabel(root, episode.location, 11, -184, -14, PALETTE.muted, 355, TextAlign.Left);
	textLabel(root, episode.logline, 12, -184, -48, unlocked ? PALETTE.paper : Color(0xff727d82), 350, TextAlign.Left);
	if (unlocked) {
		const tap = Node().addTo(root);
		tap.position = Vec2(-204, -79);
		tap.size = Size(408, 158);
		tap.swallowTouches = true;
		tap.onTapped(() => startEpisode(episode, false));
	}
}

function showHub(): void {
	if (state === undefined) { showTitle(); return; }
	state.resumeEpisode = "";
	state.resumeCursor = 0;
	saveGame();
	clearScreen("hub");
	addBackground("Image/Scenes/outdoor-lake-path.png", 0.574);
	colorRect(screenRoot, 0, 0, 960, 540, Color(0xd40b1118));
	colorRect(screenRoot, 0, 232, 960, 76, Color(0xf2111820));
	textLabel(screenRoot, "本季剧集", 25, -444, 242, PALETTE.paper, 180, TextAlign.Left);
	textLabel(screenRoot, `第一视角 · ${getCast(state.playerId).name}`, 12, -444, 212, PALETTE.muted, 300, TextAlign.Left);
	textLabel(screenRoot, `本线 ${completedBeatCount(state)}/3`, 13, 164, 236, PALETTE.gold, 150, TextAlign.Right);
	makeButton(screenRoot, "人物", 77, 214, 94, 34, showCastAlbum, PALETTE.teal);
	makeButton(screenRoot, `信号 ${state.signals.length}/${SIGNALS.length}`, 183, 214, 94, 34, showSignalAlbum, PALETTE.blue);
	makeButton(screenRoot, "保存", 289, 214, 82, 34, () => showToast(saveGame() ? "档案已保存" : "保存失败", PALETTE.gold), PALETTE.gold);
	makeButton(screenRoot, "标题", 384, 214, 82, 34, showTitle, PALETTE.brick);
	for (let index = 0; index < EPISODES.length; index++) drawEpisodeCard(EPISODES[index], index);
	textLabel(screenRoot, `现场倾向  即兴 ${state.stats.chaos}  ·  秩序 ${state.stats.order}  ·  默契 ${state.stats.warmth}`, 11, -444, -247, PALETTE.muted, 620, TextAlign.Left);
	finishScene();
}

function roleCastId(role: RoleId): CastId | undefined {
	return role === "narrator" ? undefined : role;
}

function roleName(role: RoleId): string {
	if (role === "narrator") return "旁白";
	const name = getCast(role).name;
	return state !== undefined && role === state.playerId ? `${name}（你）` : name;
}

function roleAccent(role: RoleId): Color.Type {
	if (role === "narrator") return PALETTE.gold;
	const id = roleCastId(role);
	return id === undefined ? PALETTE.teal : accentColor(getCast(id).accent);
}

function updateActorFocus(role: RoleId): void {
	for (const actor of storyActors) actor.node.opacity = role === "narrator" ? 0.88 : actor.role === role ? 1 : 0.58;
}

function appendBacklog(speaker: string, text: string): void {
	const entry = `${speaker}｜${text}`;
	if (backlog.length === 0 || backlog[backlog.length - 1] !== entry) backlog.push(entry);
}

function snapshotStory(): void {
	if (state === undefined || currentEpisode === undefined || runtime === undefined) return;
	state.resumeEpisode = currentEpisode.id;
	state.resumeCursor = math.max(0, runtime.getCursor() - 1);
	saveGame();
}

function buildToolbar(): void {
	if (currentEpisode === undefined) return;
	colorRect(screenRoot, 0, 246, 960, 48, Color(0xe8111820));
	colorRect(screenRoot, 0, 221, 960, 2, PALETTE.teal);
	episodeLabel = textLabel(screenRoot, `${currentEpisode.number} · ${currentEpisode.title}`, 12, -446, 246, PALETTE.paper, 360, TextAlign.Left);
	makeButton(screenRoot, "回看", 414, 231, 60, 30, showBacklog, PALETTE.blue);
	makeButton(screenRoot, "保存", 340, 231, 68, 30, () => { snapshotStory(); showToast("剧情进度已保存", PALETTE.gold); }, PALETTE.gold);
	const skip = makeButton(screenRoot, skipMode ? "跳过·开" : "跳过", 262, 231, 72, 30, () => {
		skipMode = !skipMode;
		if (skipButtonLabel !== undefined) skipButtonLabel.text = skipMode ? "跳过·开" : "跳过";
	}, PALETTE.coral, skipMode);
	skipButtonLabel = skip.label;
	const auto = makeButton(screenRoot, autoMode ? "自动·开" : "自动", 184, 231, 72, 30, () => {
		autoMode = !autoMode;
		if (autoButtonLabel !== undefined) autoButtonLabel.text = autoMode ? "自动·开" : "自动";
	}, PALETTE.teal, autoMode);
	autoButtonLabel = auto.label;
	makeButton(screenRoot, "信号", 112, 231, 66, 30, showSignalAlbum, PALETTE.blue);
	makeButton(screenRoot, "人物", 40, 231, 66, 30, showCastAlbum, PALETTE.teal);
	makeButton(screenRoot, "剧集", -32, 231, 66, 30, showHub, PALETTE.brick);
}

function buildDialogueBox(): void {
	const clickArea = Node().addTo(screenRoot);
	clickArea.position = Vec2(0, -176);
	clickArea.size = Size(960, 188);
	clickArea.swallowTouches = true;
	clickArea.onTapped(advanceDialogue);
	colorRect(clickArea, 480, 94, 936, 170, Color(0xee111820), 2, Color(0xffdfd6c5));
	colorRect(clickArea, 480, 176, 928, 6, PALETTE.teal);
	colorRect(clickArea, 159, 166, 246, 39, Color(0xff25323b), 2, PALETTE.teal);
	speakerLabel = textLabel(clickArea, "", 18, 54, 164, PALETTE.teal, 214, TextAlign.Left);
	dialogueLabel = textLabel(clickArea, "", 18, 52, 115, PALETTE.paper, 856, TextAlign.Left);
	nextLabel = textLabel(clickArea, "▼", 14, 903, 25, PALETTE.gold, 24);
	textLabel(clickArea, "ENTER / CLICK", 10, 777, 24, PALETTE.muted, 100, TextAlign.Right);
}

function buildStoryScene(episode: Episode): void {
	if (state === undefined) return;
	clearScreen("story");
	addBackground(episode.background, episode.backgroundScale);
	colorRect(screenRoot, 0, 20, 960, 500, Color(0x37070b10));
	const actorX = [-330, -110, 110, 330];
	for (let index = 0; index < CAST.length; index++) {
		const member = CAST[index];
		addCastActor(member.id, member.id, actorX[index], 0.56, 8);
		const tag = panel(screenRoot, actorX[index], 177, 190, 42, Color(0xe61a232c), accentColor(member.accent));
		textLabel(tag, `${member.id === state.playerId ? "你 · " : ""}${member.name} / ${member.role}`, 11, 0, -2, PALETTE.paper, 174);
	}
	buildToolbar();
	buildDialogueBox();
}

function showDialogue(statement: SayStatement): void {
	if (dialogueLabel === undefined || speakerLabel === undefined || runtime === undefined || currentEpisode === undefined) return;
	fullDialogueText = resolveText(statement.text);
	const [count] = utf8.len(fullDialogueText);
	fullCharacterCount = count ?? fullDialogueText.length;
	const key = `${currentEpisode.id}:${runtime.getCursor() - 1}`;
	currentLineWasSeen = contains(seenLines, key);
	pushUnique(seenLines, key);
	typedCharacters = skipMode && currentLineWasSeen ? fullCharacterCount : 0;
	typeAccumulator = 0;
	autoTimer = 0;
	dialogueLabel.text = typedCharacters >= fullCharacterCount ? fullDialogueText : "";
	speakerLabel.text = roleName(statement.speaker);
	speakerLabel.color = roleAccent(statement.speaker);
	if (nextLabel !== undefined) nextLabel.opacity = typedCharacters >= fullCharacterCount ? 1 : 0;
	updateActorFocus(statement.speaker);
	appendBacklog(roleName(statement.speaker), fullDialogueText);
	snapshotStory();
}

function dispatchMiniGame(statement: MiniGameStatement): void {
	const handler = MINI_GAME_HANDLERS[statement.gameId];
	const done = () => {
		if (runtime === undefined) return;
		currentStatement = runtime.completeMiniGame(statement);
		presentStatement();
	};
	if (handler !== undefined) handler(statement, done);
	else done();
}

function drawSignalImage(parent: Node.Type, signal: StorySignal, x: number, y: number, scale: number): void {
	const art = Sprite(signal.image);
	if (art !== undefined) {
		art.filter = TextureFilter.Anisotropic;
		art.scaleX = scale;
		art.scaleY = scale;
		art.position = Vec2(x, y);
		art.addTo(parent);
		return;
	}
	colorRect(parent, x, y, 220, 220, Color(0xff202b33), 2, PALETTE.blue);
	textLabel(parent, "图像待生成", 15, x, y, PALETTE.muted, 180);
}

function continueAfterSignal(): void {
	closeOverlay();
	if (runtime === undefined) return;
	currentStatement = runtime.advance();
	presentStatement();
}

function showSignal(statement: SignalStatement): void {
	if (state === undefined || currentEpisode === undefined || runtime === undefined) return;
	const signal = getSignal(statement.signalId);
	if (signal === undefined || contains(state.signals, signal.id)) {
		currentStatement = runtime.advance();
		presentStatement();
		return;
	}
	pushUnique(state.signals, signal.id);
	state.resumeEpisode = currentEpisode.id;
	state.resumeCursor = runtime.getCursor();
	saveGame();
	signalPromptOpen = true;
	overlayRoot = Node().addTo(screenRoot);
	const blocker = Node().addTo(overlayRoot);
	blocker.position = Vec2.zero;
	blocker.size = Size(960, 540);
	blocker.swallowTouches = true;
	colorRect(blocker, 480, 270, 960, 540, Color(0xd9080d14));
	const reveal = panel(overlayRoot, 0, 0, 760, 430, Color(0xfb182129), PALETTE.gold);
	colorRect(reveal, -207, 0, 286, 286, Color(0xff10171d), 2, PALETTE.blue);
	drawSignalImage(reveal, signal, -207, 0, 0.26);
	textLabel(reveal, "剧情信号", 12, -20, 159, PALETTE.gold, 290, TextAlign.Left);
	textLabel(reveal, signal.title, 29, -20, 111, PALETTE.paper, 330, TextAlign.Left);
	textLabel(reveal, signal.source, 12, -20, 70, PALETTE.blue, 320, TextAlign.Left);
	colorRect(reveal, 145, 41, 330, 2, PALETTE.coral);
	textLabel(reveal, signal.description, 14, -20, 3, PALETTE.paper, 330, TextAlign.Left);
	textLabel(reveal, "线索指向", 11, -20, -50, PALETTE.gold, 120, TextAlign.Left);
	textLabel(reveal, signal.clue, 13, -20, -82, PALETTE.paper, 330, TextAlign.Left);
	textLabel(reveal, `已收录 · ${state.signals.length}/${SIGNALS.length}`, 12, -20, -139, PALETTE.green, 230, TextAlign.Left);
	makeButton(reveal, "收下信号", -20, -189, 330, 46, continueAfterSignal, PALETTE.teal, true);
}

function presentStatement(): void {
	if (currentStatement === undefined) { showHub(); return; }
	if (currentStatement.kind === "say") showDialogue(currentStatement);
	else if (currentStatement.kind === "signal") showSignal(currentStatement);
	else if (currentStatement.kind === "menu") showChoices(currentStatement);
	else if (currentStatement.kind === "minigame") dispatchMiniGame(currentStatement);
	else if (currentStatement.kind === "end") showEpisodeEnding(currentStatement);
}

function startEpisode(episode: Episode, resume: boolean): void {
	if (state === undefined || !episodeUnlocked(episode)) return;
	currentEpisode = episode;
	runtime = new RenpyRuntime(episode.script, state.stats);
	choosing = false;
	choiceLayer = undefined;
	buildStoryScene(episode);
	currentStatement = resume ? runtime.resume(state.resumeCursor) : runtime.start();
	presentStatement();
	finishScene();
}

function revealDialogue(): void {
	typedCharacters = fullCharacterCount;
	if (dialogueLabel !== undefined) dialogueLabel.text = fullDialogueText;
	if (nextLabel !== undefined) nextLabel.opacity = 1;
	autoTimer = 0;
}

function advanceDialogue(): void {
	if (scene !== "story" || choosing || overlayRoot !== undefined || currentStatement === undefined) return;
	if (currentStatement.kind !== "say") return;
	if (typedCharacters < fullCharacterCount) { revealDialogue(); return; }
	if (runtime === undefined) return;
	currentStatement = runtime.advance();
	presentStatement();
}

function showChoices(statement: MenuStatement): void {
	if (choosing) return;
	choosing = true;
	autoTimer = 0;
	snapshotStory();
	choiceLayer = Node().addTo(screenRoot);
	const blocker = Node().addTo(choiceLayer);
	blocker.position = Vec2.zero;
	blocker.size = Size(960, 540);
	blocker.swallowTouches = true;
	colorRect(blocker, 480, 270, 960, 540, Color(0x76080d14));
	const choicePanel = panel(choiceLayer, 0, 38, 820, 300, Color(0xf218222b), PALETTE.teal);
	textLabel(choicePanel, "轮到你接这句", 12, 0, 115, PALETTE.gold, 180);
	textLabel(choicePanel, statement.prompt, 20, 0, 77, PALETTE.paper, 720);
	for (let index = 0; index < statement.choices.length; index++) {
		const selectedChoice = statement.choices[index];
		makeButton(choicePanel, `${index + 1}  ${selectedChoice.text}`, 0, index === 0 ? -10 : -86, 720, 58, () => chooseStoryChoice(selectedChoice), index === 0 ? PALETTE.teal : PALETTE.gold);
	}
	textLabel(choicePanel, "1 / 2", 10, 0, -127, PALETTE.muted, 100);
}

function chooseStoryChoice(choice: MenuChoice): void {
	if (runtime === undefined || state === undefined || currentEpisode === undefined) return;
	if (choiceLayer !== undefined) choiceLayer.removeFromParent();
	choiceLayer = undefined;
	choosing = false;
	pushUnique(state.choices, `${currentEpisode.id}:${choice.id}`);
	currentStatement = runtime.choose(choice);
	saveGame();
	presentStatement();
}

function showEpisodeEnding(statement: EndingStatement): void {
	if (state === undefined || currentEpisode === undefined) return;
	const episode = currentEpisode;
	const isFinale = episode.path === "finale";
	pushUnique(state.completed, episode.id);
	if (isFinale) pushUnique(state.endings, statement.id);
	state.resumeEpisode = "";
	state.resumeCursor = 0;
	saveGame();
	clearScreen("ending");
	addBackground(episode.background, episode.backgroundScale);
	colorRect(screenRoot, 0, 0, 960, 540, Color(0xb70b1118));
	if (isFinale) {
		addCastActor("tang-li", "tang-li", 296, 0.70, 0);
		addCastActor("zhou-yuan", "zhou-yuan", 410, 0.62, -8);
	} else addCastActor(state.playerId, state.playerId, 348, 0.75, 0);
	const card = panel(screenRoot, -170, 4, 550, 410, Color(0xf21a232c), isFinale ? PALETTE.gold : PALETTE.teal);
	textLabel(card, `${episode.number} / ${isFinale ? "真相" : "本集小结"}`, 12, -240, 170, PALETTE.gold, 330, TextAlign.Left);
	textLabel(card, statement.title, 30, -240, 119, PALETTE.paper, 460, TextAlign.Left);
	if (isFinale && statement.reveal !== undefined) textLabel(card, statement.reveal, 14, -240, 72, PALETTE.coral, 460, TextAlign.Left);
	colorRect(card, -5, isFinale ? 47 : 69, 440, 2, PALETTE.coral);
	textLabel(card, statement.summary, 15, -240, isFinale ? 3 : 26, PALETTE.paper, 460, TextAlign.Left);
	textLabel(card, isFinale ? `结局已收录 · ${state.endings.length} 个` : "本集已完成 · 真相仍在推进", 13, -240, -91, PALETTE.green, 350, TextAlign.Left);
	makeButton(card, "返回剧集", -190, -177, 210, 44, showHub, PALETTE.teal, true);
	makeButton(card, isFinale ? "重看真相" : "继续下一集", 12, -177, 210, 44, isFinale ? () => startEpisode(episode, false) : startNextEpisode, PALETTE.gold);
	finishScene();
}

function startNextEpisode(): void {
	if (state === undefined) return;
	for (const episode of EPISODES) {
		if (episodeUnlocked(episode) && !contains(state.completed, episode.id)) {
			startEpisode(episode, false);
			return;
		}
	}
	showHub();
}

function showBacklog(): void {
	if (scene !== "story" || overlayRoot !== undefined) return;
	overlayRoot = Node().addTo(screenRoot);
	const blocker = Node().addTo(overlayRoot);
	blocker.position = Vec2.zero;
	blocker.size = Size(960, 540);
	blocker.swallowTouches = true;
	colorRect(blocker, 480, 270, 960, 540, Color(0xf2111820));
	textLabel(overlayRoot, "对话回看", 28, -420, 231, PALETTE.paper, 300, TextAlign.Left);
	textLabel(overlayRoot, "本次拍摄最近记录", 12, -420, 198, PALETTE.muted, 300, TextAlign.Left);
	makeButton(overlayRoot, "关闭", 342, 207, 110, 38, closeOverlay, PALETTE.brick);
	colorRect(overlayRoot, 0, 174, 840, 2, PALETTE.gold);
	const start = math.max(0, backlog.length - 7);
	for (let index = start; index < backlog.length; index++) {
		const row = index - start;
		const [speaker, content] = string.match(backlog[index], "([^｜]+)｜(.+)");
		textLabel(overlayRoot, speaker ?? "", 13, -416, 139 - row * 55, PALETTE.teal, 120, TextAlign.Left);
		textLabel(overlayRoot, content ?? backlog[index], 13, -278, 139 - row * 55, PALETTE.paper, 690, TextAlign.Left);
	}
	if (backlog.length === 0) textLabel(overlayRoot, "还没有对话记录。", 15, 0, 0, PALETTE.muted, 400);
}

function showCastAlbum(): void {
	if (state === undefined || overlayRoot !== undefined) return;
	overlayRoot = Node().addTo(screenRoot);
	const blocker = Node().addTo(overlayRoot);
	blocker.position = Vec2.zero;
	blocker.size = Size(960, 540);
	blocker.swallowTouches = true;
	colorRect(blocker, 480, 270, 960, 540, Color(0xf7111820));
	textLabel(overlayRoot, "人物关系", 28, -420, 231, PALETTE.paper, 220, TextAlign.Left);
	textLabel(overlayRoot, "开放日收尾组：黄一澈发稿，张开送管墙，寒予水主持，李童牧执行", 12, -420, 198, PALETTE.muted, 650, TextAlign.Left);
	makeButton(overlayRoot, "关闭", 342, 207, 110, 38, closeOverlay, PALETTE.brick);
	colorRect(overlayRoot, 0, 174, 840, 2, PALETTE.gold);
	for (let index = 0; index < CAST.length; index++) {
		const member = CAST[index];
		const selected = member.id === state.playerId;
		const x = -342 + index * 228;
		const card = panel(overlayRoot, x, -19, 204, 350, Color(0xf21a232c), selected ? PALETTE.white : accentColor(member.accent));
		const portrait = Sprite(member.sprite);
		if (portrait !== undefined) {
			portrait.filter = TextureFilter.Point;
			portrait.scaleX = 0.31;
			portrait.scaleY = 0.31;
			portrait.position = Vec2(0, 68);
			portrait.addTo(card);
		}
		textLabel(card, `${selected ? "你 · " : ""}${member.name}`, 18, 0, -28, PALETTE.paper, 174);
		textLabel(card, member.role, 11, 0, -56, accentColor(member.accent), 174);
		textLabel(card, member.task, 11, 0, -88, PALETTE.blue, 174);
		textLabel(card, member.quip, 11, 0, -130, PALETTE.paper, 168);
	}
}

function showSignalAlbum(): void {
	if (state === undefined || overlayRoot !== undefined) return;
	signalPromptOpen = false;
	overlayRoot = Node().addTo(screenRoot);
	const blocker = Node().addTo(overlayRoot);
	blocker.position = Vec2.zero;
	blocker.size = Size(960, 540);
	blocker.swallowTouches = true;
	colorRect(blocker, 480, 270, 960, 540, Color(0xf7111820));
	textLabel(overlayRoot, "剧情信号", 28, -420, 231, PALETTE.paper, 260, TextAlign.Left);
	textLabel(overlayRoot, `已收录 ${state.signals.length}/${SIGNALS.length}`, 12, -420, 198, PALETTE.muted, 260, TextAlign.Left);
	makeButton(overlayRoot, "关闭", 342, 207, 110, 38, closeOverlay, PALETTE.brick);
	colorRect(overlayRoot, 0, 174, 840, 2, PALETTE.gold);
	for (let index = 0; index < SIGNALS.length; index++) {
		const signal = SIGNALS[index];
		const collected = contains(state.signals, signal.id);
		const x = -342 + index * 228;
		const card = panel(overlayRoot, x, -19, 204, 350, Color(0xf21a232c), collected ? PALETTE.blue : Color(0xff596269));
		colorRect(card, 0, 66, 166, 166, Color(0xff10171d), 2, collected ? PALETTE.blue : Color(0xff596269));
		if (collected) drawSignalImage(card, signal, 0, 66, 0.14);
		else textLabel(card, "?", 48, 0, 66, Color(0xff69747a), 80);
		textLabel(card, collected ? signal.title : "尚未收录", 16, 0, -38, collected ? PALETTE.paper : PALETTE.muted, 174);
		textLabel(card, collected ? signal.source : "继续推进剧情", 10, 0, -65, collected ? PALETTE.blue : Color(0xff69747a), 174);
		textLabel(card, collected ? signal.description : "", 10, 0, -98, PALETTE.paper, 168);
		textLabel(card, collected ? `线索：${signal.clue}` : "", 10, 0, -145, PALETTE.gold, 168);
	}
}

function closeOverlay(): void {
	if (overlayRoot !== undefined) overlayRoot.removeFromParent();
	overlayRoot = undefined;
	signalPromptOpen = false;
}

function updateViewport(): void {
	const viewSize = View.size;
	if (viewSize.width === lastViewWidth && viewSize.height === lastViewHeight) return;
	lastViewWidth = viewSize.width;
	lastViewHeight = viewSize.height;
	const scale = math.min(viewSize.width / LOGICAL_WIDTH, viewSize.height / LOGICAL_HEIGHT);
	const camera = tolua.cast(Director.currentCamera, TypeName.Camera2D);
	if (camera) {
		camera.zoom = scale;
		camera.position = Vec2.zero;
		camera.rotation = 0;
	}
	stage.scaleX = 1;
	stage.scaleY = 1;
	stage.position = Vec2.zero;
}

function updatePresentation(deltaTime: number): void {
	sceneTime += deltaTime;
	for (const motion of motions) {
		motion.node.x = motion.baseX + math.sin(sceneTime * motion.speed + motion.phase) * motion.amplitudeX;
		motion.node.y = motion.baseY + math.sin(sceneTime * motion.speed + motion.phase) * motion.amplitudeY;
	}
	if (sceneFade !== undefined) {
		sceneFade.opacity = math.max(0, sceneFade.opacity - deltaTime * 4.8);
		if (sceneFade.opacity <= 0) { sceneFade.removeFromParent(); sceneFade = undefined; }
	}
	if (toastRoot !== undefined) {
		toastTimer -= deltaTime;
		if (toastTimer <= 0) { toastRoot.removeFromParent(); toastRoot = undefined; }
	}
	if (scene !== "story" || choosing || overlayRoot !== undefined || dialogueLabel === undefined || currentStatement === undefined || currentStatement.kind !== "say") return;
	if (typedCharacters < fullCharacterCount) {
		typeAccumulator += deltaTime * 32;
		const amount = math.floor(typeAccumulator);
		if (amount > 0) {
			typeAccumulator -= amount;
			typedCharacters = math.min(fullCharacterCount, typedCharacters + amount);
			dialogueLabel.text = truncateUtf8(fullDialogueText, typedCharacters);
			if (typedCharacters >= fullCharacterCount && nextLabel !== undefined) nextLabel.opacity = 1;
		}
		return;
	}
	if (skipMode && currentLineWasSeen) {
		autoTimer += deltaTime;
		if (autoTimer >= 0.09) advanceDialogue();
		return;
	}
	if (autoMode) {
		autoTimer += deltaTime;
		if (autoTimer >= 1.45) advanceDialogue();
	}
}

function activatePrimary(): void {
	if (scene === "title") showProfile();
	else if (scene === "profile") showSlots("new");
	else if (scene === "story") advanceDialogue();
	else if (scene === "ending") {
		if (currentEpisode !== undefined && currentEpisode.path === "finale") showHub();
		else startNextEpisode();
	}
}

stage.onKeyDown((key) => {
	if (scene === "slots" && key === KeyName.Num1) chooseSlot(1);
	else if (scene === "slots" && key === KeyName.Num2) chooseSlot(2);
	else if (scene === "slots" && key === KeyName.Num3) chooseSlot(3);
	else if (scene === "story" && choosing && key === KeyName.Num1 && currentStatement !== undefined && currentStatement.kind === "menu") chooseStoryChoice(currentStatement.choices[0]);
	else if (scene === "story" && choosing && key === KeyName.Num2 && currentStatement !== undefined && currentStatement.kind === "menu") chooseStoryChoice(currentStatement.choices[1]);
	else if (key === KeyName.Return || key === KeyName.Space || key === KeyName.E) activatePrimary();
	else if (key === KeyName.Escape) {
		if (signalPromptOpen) continueAfterSignal();
		else if (overlayRoot !== undefined) closeOverlay();
		else if (scene === "story" || scene === "ending") showHub();
		else if (scene !== "title") showTitle();
	}
});

stage.onButtonDown((_controllerId, button) => {
	if (button === ButtonName.A) activatePrimary();
	else if (button === ButtonName.B || button === ButtonName.Back) {
		if (signalPromptOpen) continueAfterSignal();
		else if (overlayRoot !== undefined) closeOverlay();
		else if (scene === "story" || scene === "ending") showHub();
		else if (scene !== "title") showTitle();
	}
});

stage.schedule((deltaTime) => {
	updateViewport();
	updatePresentation(deltaTime);
	return false;
});

updateViewport();
showTitle();
