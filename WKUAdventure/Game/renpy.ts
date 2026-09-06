export type RoleId = "narrator" | "lin-cheng" | "jiang-ran" | "tang-li" | "zhou-yuan";
export type StatKey = "chaos" | "order" | "warmth" | "wit";

export interface Effect {
	key: StatKey;
	amount: number;
}

export interface MenuChoice {
	id: string;
	text: string;
	effects: Effect[];
	jump: string;
}

export type Statement =
	| {kind: "label"; name: string}
	| {kind: "say"; speaker: RoleId; text: string}
	| {kind: "signal"; signalId: string}
	| {kind: "menu"; prompt: string; choices: [MenuChoice, MenuChoice]}
	| {kind: "jump"; target: string}
	| {kind: "condition"; key: StatKey; minimum: number; pass: string; fail: string}
	| {kind: "minigame"; gameId: string; fallback: string}
	| {kind: "end"; id: string; title: string; summary: string; reveal?: string};

export interface StoryStats {
	chaos: number;
	order: number;
	warmth: number;
	wit: number;
}

export class RenpyRuntime {
	private cursor = 0;
	private readonly labels: Record<string, number> = {};

	constructor(private readonly script: Statement[], private readonly stats: StoryStats) {
		for (let index = 0; index < script.length; index++) {
			const statement = script[index];
			if (statement.kind === "label") this.labels[statement.name] = index + 1;
		}
	}

	public start(label = "start"): Statement | undefined {
		this.jump(label);
		return this.nextVisible();
	}

	public resume(cursor: number): Statement | undefined {
		this.cursor = math.max(0, math.min(cursor, this.script.length));
		return this.nextVisible();
	}

	public advance(): Statement | undefined {
		return this.nextVisible();
	}

	public choose(choice: MenuChoice): Statement | undefined {
		for (const effect of choice.effects) this.stats[effect.key] += effect.amount;
		this.jump(choice.jump);
		return this.nextVisible();
	}

	public completeMiniGame(statement: Extract<Statement, {kind: "minigame"}>): Statement | undefined {
		this.jump(statement.fallback);
		return this.nextVisible();
	}

	public getCursor(): number {
		return this.cursor;
	}

	private jump(label: string): void {
		const target = this.labels[label];
		if (target === undefined) error(`剧情标签不存在: ${label}`);
		this.cursor = target;
	}

	private nextVisible(): Statement | undefined {
		while (this.cursor < this.script.length) {
			const statement = this.script[this.cursor];
			this.cursor += 1;
			if (statement.kind === "label") continue;
			if (statement.kind === "jump") {
				this.jump(statement.target);
				continue;
			}
			if (statement.kind === "condition") {
				this.jump(this.stats[statement.key] >= statement.minimum ? statement.pass : statement.fail);
				continue;
			}
			return statement;
		}
		return undefined;
	}
}
