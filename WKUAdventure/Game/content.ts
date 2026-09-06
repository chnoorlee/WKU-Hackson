import {Statement} from "Game/renpy";

export type CastId = "lin-cheng" | "jiang-ran" | "tang-li" | "zhou-yuan";
export type EpisodeId = "wall-post" | "mint-decoy" | "third-row" | "lake-meetup";
export type SignalId = "wall-screenshot" | "mint-receipt" | "seat-card" | "paper-star";
export type AccentKey = "gold" | "coral" | "teal" | "blue";

export interface CastMember {
	id: CastId;
	name: string;
	pronoun: "她" | "他";
	role: string;
	task: string;
	quip: string;
	sprite: string;
	accent: AccentKey;
}

export interface StorySignal {
	id: SignalId;
	title: string;
	source: string;
	description: string;
	clue: string;
	image: string;
}

export interface Episode {
	id: EpisodeId;
	number: string;
	title: string;
	location: string;
	logline: string;
	background: string;
	backgroundScale: number;
	path: "opening" | "chaos" | "order" | "finale";
	script: Statement[];
}

export const CAST: CastMember[] = [
	{
		id: "lin-cheng", name: "黄一澈", pronoun: "她", role: "校媒剪辑", task: "把误发解释成正常操作",
		quip: "越出事，越想现场剪个补丁。", sprite: "Image/Characters/lin-cheng.png", accent: "gold"
	},
	{
		id: "jiang-ran", name: "张开送", pronoun: "他", role: "匿名墙值班", task: "让系统和这群人都闭嘴",
		quip: "日志不撒谎，人会抢着替它撒。", sprite: "Image/Characters/jiang-ran.png", accent: "coral"
	},
	{
		id: "tang-li", name: "寒予水", pronoun: "她", role: "主持队队长", task: "阻止任何人念完那张稿",
		quip: "台上救过无数次场，今晚救不了自己。", sprite: "Image/Characters/tang-li.png", accent: "gold"
	},
	{
		id: "zhou-yuan", name: "李童牧", pronoun: "他", role: "活动执行", task: "送完物料，再把每句话听明白",
		quip: "什么暗示都接不到，所有东西都接得住。", sprite: "Image/Characters/zhou-yuan.png", accent: "teal"
	}
];

export const SIGNALS: StorySignal[] = [
	{
		id: "wall-screenshot", title: "撤回失败的置顶帖", source: "EP.01 · 中庭大屏",
		description: "雨伞招领还在草稿箱，匿名表白却被标成“紧急内容”挂上大屏。",
		clue: "截图留下定时标记和没发完的第三句；寒予水却提前知道第三句写了什么。",
		image: "Image/Signals/wall-screenshot.png"
	},
	{
		id: "mint-receipt", title: "六杯饮料的小票", source: "EP.02A · 公开认领",
		description: "四个人的柜台摆着六杯饮料，唯一一杯不加薄荷被围观者当成“收件人测试”。",
		clue: "叫号前，寒予水已经把那杯塞给李童牧；她的补救比小票更快暴露了答案。",
		image: "Image/Signals/mint-receipt.png"
	},
	{
		id: "seat-card", title: "被念上麦的 3C 卡", source: "EP.02B · 图书馆直播",
		description: "维修卡背面写着“周，包放里侧，空调滴水”，边角粘着主持队的荧光胶带。",
		clue: "黄一澈刚念出一个“李”，寒予水就接出了后半句；卡片当场从物证变成口供。",
		image: "Image/Signals/seat-card.png"
	},
	{
		id: "paper-star", title: "不肯再匿名的纸星", source: "FINALE · 八点整",
		description: "纸星由废主持稿折成，里面是六版被划掉的表白开场。",
		clue: "最后一行写着“给李童牧。别在墙上回，直接来。”落款是寒予水。",
		image: "Image/Signals/paper-star.png"
	}
];

export const EPISODES: Episode[] = [
	{
		id: "wall-post", number: "EP.01", title: "撤回以后，置顶了", location: "SLAC · 湖景中庭",
		logline: "黄一澈发错帖，张开送按错撤回；寒予水只说了七个字，就从旁观者变成头号嫌疑人。",
		background: "Image/Scenes/slac-interior.png", backgroundScale: 0.650, path: "opening",
		script: [
			{kind: "label", name: "start"},
			{kind: "say", speaker: "narrator", text: "开放日结束，家长直播还没关。黄一澈坐在校媒电脑前，准备发最后一条雨伞招领。"},
			{kind: "say", speaker: "lin-cheng", text: "失物：黑伞一把。地点：中庭。很好，今天终于有件事不需要剪辑。"},
			{kind: "say", speaker: "narrator", text: "她按下发布。中庭大屏亮起的不是伞，是一段定时表白。"},
			{kind: "say", speaker: "tang-li", text: "“谢谢总替我占第三排靠窗座位的人。今晚八点，湖边长椅见。还有，别带薄荷。”"},
			{kind: "say", speaker: "zhou-yuan", text: "为什么家长直播在拍这个？"},
			{kind: "say", speaker: "lin-cheng", text: "因为摄像头有职业道德。我没有。张开送，撤。"},
			{kind: "say", speaker: "jiang-ran", text: "已撤。"},
			{kind: "say", speaker: "narrator", text: "帖子从手机端消失，又以红框“紧急内容”占满大屏。评论数开始往上跳。"},
			{kind: "say", speaker: "jiang-ran", text: "我点的是紧急下架。大屏只认了“紧急”两个字。"},
			{kind: "say", speaker: "lin-cheng", text: "恭喜。普通表白现在有了消防通道待遇。"},
			{kind: "signal", signalId: "wall-screenshot"},
			{kind: "say", speaker: "zhou-yuan", text: "截图里第三句后面还有省略号。是不是没发完？"},
			{kind: "say", speaker: "tang-li", text: "没发完也别念第三句。"},
			{kind: "say", speaker: "jiang-ran", text: "没人说第三句是表白。"},
			{kind: "say", speaker: "lin-cheng", text: "唐队，你刚才抢答了。"},
			{kind: "say", speaker: "tang-li", text: "我是主持人。冷场时抢话，天塌了也控场。"},
			{kind: "say", speaker: "jiang-ran", text: "目前天没塌。你塌得比较明显。"},
			{kind: "menu", prompt: "评论区开始认领“不要薄荷的人”，用什么挡住？", choices: [
				{id: "leave-up", text: "顺势办饮料认领，把表白说成开放日互动", effects: [{key: "chaos", amount: 2}, {key: "wit", amount: 1}], jump: "leave-up"},
				{id: "trace", text: "发失物更正，把“第三排”说成雨伞位置", effects: [{key: "order", amount: 2}, {key: "warmth", amount: 1}], jump: "trace"}
			]},
			{kind: "label", name: "leave-up"},
			{kind: "say", speaker: "lin-cheng", text: "我发更正：七点饮料柜台，认出无薄荷那杯就送。"},
			{kind: "say", speaker: "jiang-ran", text: "你用一场表白事故，招募了下一场事故的观众。"},
			{kind: "say", speaker: "lin-cheng", text: "叫观众总比叫家长好听。"},
			{kind: "say", speaker: "zhou-yuan", text: "那我去取饮料。我正好订了六杯。"},
			{kind: "say", speaker: "tang-li", text: "我们只有四个人。"},
			{kind: "say", speaker: "jiang-ran", text: "很好，事故已经超额两杯。"},
			{kind: "end", id: "wall-crowd", title: "撤回失败，活动立项", summary: "为了掩盖匿名表白，黄一澈临时办了一场“无薄荷认领”。七点，评论区整队去了饮料柜台。"},
			{kind: "label", name: "trace"},
			{kind: "say", speaker: "lin-cheng", text: "更正发了：第三排靠窗是雨伞遗失位置，请勿对号入座。"},
			{kind: "say", speaker: "zhou-yuan", text: "图书馆三楼第三排，3C靠窗。我每周三都坐。"},
			{kind: "say", speaker: "tang-li", text: "学校有九栋楼，你为什么报得像快递地址？"},
			{kind: "say", speaker: "zhou-yuan", text: "因为你每次都把包放在3C，说空调滴水，没人抢。"},
			{kind: "say", speaker: "lin-cheng", text: "更正下面已经有人问：哪位失主姓李。"},
			{kind: "say", speaker: "jiang-ran", text: "三分钟，七个姓李的去图书馆找伞。"},
			{kind: "say", speaker: "tang-li", text: "走。趁第八个还没出发。"},
			{kind: "end", id: "wall-archive", title: "表白下架，七个老周上楼", summary: "帖子没了，失物更正却把围观者引向3C。四个人只好赶在他们前面去图书馆。"}
		]
	},
	{
		id: "mint-decoy", number: "EP.02A", title: "对象是临时工", location: "湖边 · 饮料柜台",
		logline: "寒予水一秒认出李童牧的杯子，只好用一句更大的谎，遮住一个已经很明显的真话。",
		background: "Image/Scenes/outdoor-lakeside-flowers.png", backgroundScale: 0.574, path: "chaos",
		script: [
			{kind: "label", name: "start"},
			{kind: "say", speaker: "narrator", text: "七点十二分，饮料柜台外站满了假装买水的人。店员摆出六杯，十几部手机同时抬起来。"},
			{kind: "say", speaker: "lin-cheng", text: "规则很简单：找出不加薄荷的那杯。找错了，自己买单。"},
			{kind: "say", speaker: "jiang-ran", text: "这不是规则，是你刚想出来的赔付条款。"},
			{kind: "say", speaker: "zhou-yuan", text: "两杯给收展架的老师，四杯是我们的。数量没错。"},
			{kind: "say", speaker: "narrator", text: "店员还没叫号，寒予水抽走最右边一杯，转身塞进李童牧手里。围观的手机又近了半步。"},
			{kind: "signal", signalId: "mint-receipt"},
			{kind: "say", speaker: "lin-cheng", text: "唐队，题面刚念完，你把答案递出去了。"},
			{kind: "say", speaker: "tang-li", text: "杯壁写着周。"},
			{kind: "say", speaker: "jiang-ran", text: "写的是取单号，六十二。"},
			{kind: "say", speaker: "zhou-yuan", text: "她记得我不吃薄荷。"},
			{kind: "say", speaker: "tang-li", text: "你现在可以少说一句。"},
			{kind: "say", speaker: "zhou-yuan", text: "哪一句？"},
			{kind: "say", speaker: "lin-cheng", text: "晚了，这句也很好用。评论区已经在投票。"},
			{kind: "menu", prompt: "围观者要寒予水解释，她拿什么堵住镜头？", choices: [
				{id: "tease", text: "借主持人的台，让她宣布这是情侣默契测试", effects: [{key: "chaos", amount: 2}, {key: "wit", amount: 1}], jump: "tease"},
				{id: "ask", text: "让李童牧说清楚，她为什么记得这杯", effects: [{key: "warmth", amount: 2}], jump: "ask"}
			]},
			{kind: "label", name: "tease"},
			{kind: "say", speaker: "lin-cheng", text: "各位，这是主持队情侣默契测试。唐队，请公布搭档。"},
			{kind: "say", speaker: "tang-li", text: "黄一澈，你明天的讣告我来主持。"},
			{kind: "say", speaker: "lin-cheng", text: "先活过这个镜头。三、二——"},
			{kind: "say", speaker: "tang-li", text: "别猜了。李童牧，我对象。临时的。"},
			{kind: "say", speaker: "zhou-yuan", text: "从几点到几点？我八点还要去湖边。"},
			{kind: "say", speaker: "tang-li", text: "从现在到你学会闭嘴。"},
			{kind: "say", speaker: "jiang-ran", text: "已记录。结束时间未知。"},
			{kind: "end", id: "mint-two", title: "假对象当场续约", summary: "一句“临时对象”压住了杯子，却坐实了八成传闻。李童牧认真把这项临时任务排到了八点以后。"},
			{kind: "label", name: "ask"},
			{kind: "say", speaker: "lin-cheng", text: "李童牧，她为什么记得你的口味？对镜头说。"},
			{kind: "say", speaker: "zhou-yuan", text: "上次彩排，寒予水喝到薄荷咳了半场。从那以后我都点两杯不加。"},
			{kind: "say", speaker: "tang-li", text: "问你，没让你交代我。"},
			{kind: "say", speaker: "jiang-ran", text: "一人记口味，一人改订单。双向证词，无法撤回。"},
			{kind: "say", speaker: "zhou-yuan", text: "那我说错了吗？"},
			{kind: "say", speaker: "tang-li", text: "没有。才麻烦。"},
			{kind: "end", id: "mint-almost", title: "两杯都不要薄荷", summary: "没人认领匿名帖，但所有镜头都认出了两个人。七点四十，围观队伍开始往湖边移动。"}
		]
	},
	{
		id: "third-row", number: "EP.02B", title: "请失主不要抢麦", location: "图书馆 · 三楼阅览区",
		logline: "黄一澈把3C卡念上直播，寒予水为阻止她读完，亲口补出了只有作者才知道的后半句。",
		background: "Image/Scenes/library-interior.png", backgroundScale: 0.629, path: "order",
		script: [
			{kind: "label", name: "start"},
			{kind: "say", speaker: "narrator", text: "七点二十，3C旁边站着七个姓李的围观者。管理员把失物台的小麦克风递给黄一澈，要她把更正念清楚。"},
			{kind: "say", speaker: "lin-cheng", text: "各位，这里没有表白，只有一把至今没出现的黑伞。请不要——"},
			{kind: "say", speaker: "jiang-ran", text: "先关直播。"},
			{kind: "say", speaker: "lin-cheng", text: "我没开。"},
			{kind: "say", speaker: "jiang-ran", text: "管理员开了。匿名墙正在转播你的否认。"},
			{kind: "say", speaker: "zhou-yuan", text: "3C椅背有张卡。可能是伞的。"},
			{kind: "signal", signalId: "seat-card"},
			{kind: "say", speaker: "lin-cheng", text: "卡背写着：“周，包放里侧——”"},
			{kind: "say", speaker: "tang-li", text: "“空调滴水。”到此为止。"},
			{kind: "say", speaker: "jiang-ran", text: "她只念了前半句。"},
			{kind: "say", speaker: "zhou-yuan", text: "后半句是寒予水写的。她每周三都贴一张。"},
			{kind: "say", speaker: "tang-li", text: "你今天一定要把每个细节都交代给全校？"},
			{kind: "say", speaker: "zhou-yuan", text: "你不是让我说实话吗？"},
			{kind: "say", speaker: "lin-cheng", text: "别教他。他一学会，今晚没人下得了台。"},
			{kind: "menu", prompt: "直播没关，怎么把这张卡从寒予水手里救出来？", choices: [
				{id: "compare", text: "请寒予水用主持稿示范“正确的失物播报”", effects: [{key: "order", amount: 2}, {key: "wit", amount: 1}], jump: "compare"},
				{id: "wait", text: "让李童牧拿麦，替她说明这只是占座留言", effects: [{key: "warmth", amount: 2}], jump: "wait"}
			]},
			{kind: "label", name: "compare"},
			{kind: "say", speaker: "lin-cheng", text: "唐队，请按主持稿示范。只念和卡片无关的。"},
			{kind: "say", speaker: "tang-li", text: "“请失主今晚八点到湖边长椅——”"},
			{kind: "say", speaker: "jiang-ran", text: "主持稿为什么也写湖边？"},
			{kind: "say", speaker: "tang-li", text: "因为黄一澈把表白帖当失物更正，我被她带跑了。"},
			{kind: "say", speaker: "lin-cheng", text: "可以。现在七个老周和一条直播都要去湖边领伞。"},
			{kind: "say", speaker: "zhou-yuan", text: "我帮你维持队伍。"},
			{kind: "say", speaker: "tang-li", text: "你站着就是队伍的问题。"},
			{kind: "end", id: "row-handwriting", title: "正确示范，错误地点", summary: "寒予水想用主持腔压住卡片，却把八点湖边念进了直播。围观队伍有了正式集合地点。"},
			{kind: "label", name: "wait"},
			{kind: "say", speaker: "zhou-yuan", text: "卡是寒予水写给我的。座也是她替我留的。和其他人没关系。"},
			{kind: "say", speaker: "narrator", text: "七个姓李的人一起退后，直播评论一起往前冲。"},
			{kind: "say", speaker: "tang-li", text: "你这句话听起来，比原帖还像认领。"},
			{kind: "say", speaker: "zhou-yuan", text: "那我重说。寒予水和我有关系。"},
			{kind: "say", speaker: "jiang-ran", text: "不要重说。第一版还能解释，第二版已经存档。"},
			{kind: "say", speaker: "lin-cheng", text: "评论区问，八点是不是官宣。"},
			{kind: "say", speaker: "tang-li", text: "八点之前，谁再给他麦，我跟谁绝交。"},
			{kind: "end", id: "row-wait", title: "解释一次，关系确认", summary: "李童牧替寒予水挡下卡片，也把两人的“关系”送进了直播存档。八点湖边，已成全校默认的下一场。"}
		]
	},
	{
		id: "lake-meetup", number: "FINALE", title: "八点整，全校已读", location: "湖边 · 那张长椅",
		logline: "他们准备拿雨伞招领结束闹剧；一颗纸星落地后，寒予水决定抢在全校前面把真话说完。",
		background: "Image/Scenes/outdoor-lake-path.png", backgroundScale: 0.574, path: "finale",
		script: [
			{kind: "label", name: "start"},
			{kind: "say", speaker: "narrator", text: "七点五十八，湖边长椅被手机灯围出一圈。无论大家追的是无薄荷饮料还是3C黑伞，最后都认准了这里。"},
			{kind: "say", speaker: "lin-cheng", text: "最终方案：寒予水念雨伞招领，张开送删帖，李童牧举伞。我关镜头。四个人各做一件会的事。"},
			{kind: "say", speaker: "jiang-ran", text: "你今天第一次提出像方案的东西。"},
			{kind: "say", speaker: "tang-li", text: "稿给我。八点一到，我念完就走。"},
			{kind: "say", speaker: "zhou-yuan", text: "你的稿里掉东西了。"},
			{kind: "say", speaker: "narrator", text: "一颗压扁的纸星滚到长椅下。李童牧捡起来，折缝里露出自己的名字。寒予水伸手，晚了一秒。"},
			{kind: "signal", signalId: "paper-star"},
			{kind: "say", speaker: "zhou-yuan", text: "“给李童牧。别在墙上回，直接来。”我来了。"},
			{kind: "say", speaker: "jiang-ran", text: "八点整。后台定时任务又开始了。"},
			{kind: "say", speaker: "lin-cheng", text: "我没碰。大家都看着，我两只手在这。"},
			{kind: "say", speaker: "jiang-ran", text: "这次不是事故。原帖剩下的第三句正在自动发布。"},
			{kind: "say", speaker: "tang-li", text: "别发。麦给我。"},
			{kind: "say", speaker: "narrator", text: "寒予水拿过麦克风，没有看主持稿。"},
			{kind: "say", speaker: "tang-li", text: "帖子也是我写的。我喜欢你。本来想匿名留点退路，现在退路上全是直播。李童牧，你听懂了吗？"},
			{kind: "say", speaker: "lin-cheng", text: "误发是我。上传雨伞招领时点中上一行。这个锅不用匿名。"},
			{kind: "say", speaker: "jiang-ran", text: "日志确认：写帖寒予水，误发黄一澈，收件人李童牧。证据闭环，请当事人回答。"},
			{kind: "say", speaker: "zhou-yuan", text: "我每周三早点到，不是替你占座，是想坐你旁边。饮料点两杯不加薄荷，也是怕你拿错。"},
			{kind: "say", speaker: "tang-li", text: "所以你不是听不懂？"},
			{kind: "say", speaker: "zhou-yuan", text: "前面没听懂。现在懂了。还有，我答应。"},
			{kind: "say", speaker: "tang-li", text: "答应什么？说全。今天最不缺的就是证人。"},
			{kind: "say", speaker: "zhou-yuan", text: "答应和你谈恋爱。不是临时任务。"},
			{kind: "menu", prompt: "真话已经上麦，最后怎么收掉全校的镜头？", choices: [
				{id: "give-space", text: "拔掉直播线，把那把黑伞留给他们", effects: [{key: "warmth", amount: 2}], jump: "resolve"},
				{id: "post-fix", text: "让李童牧实名回复，正式认领这条帖子", effects: [{key: "chaos", amount: 1}, {key: "wit", amount: 2}], jump: "resolve"}
			]},
			{kind: "label", name: "resolve"},
			{kind: "condition", key: "warmth", minimum: 4, pass: "warm-ending", fail: "style-check"},
			{kind: "label", name: "style-check"},
			{kind: "condition", key: "chaos", minimum: 4, pass: "chaos-ending", fail: "order-ending"},
			{kind: "label", name: "warm-ending"},
			{kind: "say", speaker: "lin-cheng", text: "线拔了。走吧，再待下去就要收门票。"},
			{kind: "say", speaker: "jiang-ran", text: "我去关评论。你去把那条雨伞招领发了。"},
			{kind: "say", speaker: "narrator", text: "雨落下来。李童牧撑开那把找了一晚的黑伞，伞柄上挂着寒予水的名字。"},
			{kind: "say", speaker: "tang-li", text: "原来失主是我。"},
			{kind: "say", speaker: "zhou-yuan", text: "不用找了，在我这。"},
			{kind: "say", speaker: "lin-cheng", text: "这句很好。放心，我没录。"},
			{kind: "say", speaker: "jiang-ran", text: "她录了。相机红灯还亮着。"},
			{kind: "end", id: "meetup-warm", title: "伞找到了，人也是", summary: "直播在八点零一分断开。寒予水和李童牧共撑一把伞离开，黄一澈交出存储卡后才被允许跟上。", reveal: "写帖：寒予水  ·  误发：黄一澈  ·  收件：李童牧"},
			{kind: "label", name: "chaos-ending"},
			{kind: "say", speaker: "zhou-yuan", text: "我实名回复：本人已到，愿意长期认领。"},
			{kind: "say", speaker: "jiang-ran", text: "系统把“认领”识别成失物流程。帖子标题自动改成：已由本人领走。"},
			{kind: "say", speaker: "tang-li", text: "谁被领走？"},
			{kind: "say", speaker: "lin-cheng", text: "从评论看，你们一人一半。三百个赞，撤不回了。"},
			{kind: "say", speaker: "zhou-yuan", text: "那就不撤。"},
			{kind: "end", id: "meetup-chaos", title: "匿名墙完成实名认领", summary: "李童牧的实名答复被系统当成失物认领。标题虽然离谱，寒予水没有要求修改。", reveal: "写帖：寒予水  ·  误发：黄一澈  ·  收件：李童牧"},
			{kind: "label", name: "order-ending"},
			{kind: "say", speaker: "jiang-ran", text: "结案。事故报告最后一栏：处理结果。"},
			{kind: "say", speaker: "zhou-yuan", text: "写“已答应”。"},
			{kind: "say", speaker: "tang-li", text: "写全。谁答应谁，别又让全校做阅读理解。"},
			{kind: "say", speaker: "lin-cheng", text: "你们这是事故报告，还是恋爱登记？"},
			{kind: "say", speaker: "jiang-ran", text: "系统没有恋爱登记。按事故报告归档。"},
			{kind: "say", speaker: "tang-li", text: "行。附件里的纸星还我。"},
			{kind: "end", id: "meetup-order", title: "恋爱关系，按事故归档", summary: "张开送补上二次确认流程，也把“双方已答应”写进结案记录。帖子下架了，纸星被寒予水带走。", reveal: "写帖：寒予水  ·  误发：黄一澈  ·  收件：李童牧"}
		]
	}
];
