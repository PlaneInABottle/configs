import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type ThinkingLevel = "off" | "minimal" | "low" | "medium" | "high" | "xhigh";

const BUDGET_BY_LEVEL: Record<ThinkingLevel, number> = {
	off: 0,
	minimal: 64,
	low: 128,
	medium: 256,
	high: 512,
	xhigh: 1024,
};

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isLocalGemmaPayload(payload: Record<string, unknown>): boolean {
	return payload.model === "gemma";
}

export default function (pi: ExtensionAPI) {
	pi.on("before_provider_request", (event) => {
		if (!isRecord(event.payload) || !isLocalGemmaPayload(event.payload)) {
			return;
		}

		const level = pi.getThinkingLevel() as ThinkingLevel;
		const budget = BUDGET_BY_LEVEL[level] ?? BUDGET_BY_LEVEL.off;

		return {
			...event.payload,
			thinking_budget_tokens: budget,
		};
	});

	pi.registerCommand("llama-thinking", {
		description: "Set llama.cpp thinking budget level: off, minimal, low, medium, high, xhigh",
		async handler(args, ctx) {
			const level = args.trim() as ThinkingLevel;
			if (!(level in BUDGET_BY_LEVEL)) {
				ctx.ui.notify("Usage: /llama-thinking off|minimal|low|medium|high|xhigh", "warning");
				return;
			}

			pi.setThinkingLevel(level);
			ctx.ui.notify(`llama.cpp thinking budget: ${level} (${BUDGET_BY_LEVEL[level]} tokens)`, "info");
		},
	});
}
