import re

TAG_RULES: dict[str, list[str]] = {
    "#adoption": ["adoption", "internal product", "rollout", "onboarding"],
    "#ai-process": ["claude", "ai", "prompt", "llm", "automation"],
    "#design-decisions": ["design", "ux", "ui", "prototype", "wireframe"],
    "#0-to-1": ["mvp", "build", "launch", "new product", "from scratch"],
    "#data-insights": ["dashboard", "analytics", "metrics", "data", "insights"],
    "#tools": ["tool", "library", "framework", "setup"],
    "#automation": ["workflow", "automate", "script"],
    "#full-stack": ["frontend", "backend", "full-stack", "api"],
}


def auto_tag(text: str) -> list[str]:
    """Scan text for keywords and return matching tag names."""
    lower = text.lower()
    matched: list[str] = []
    for tag, keywords in TAG_RULES.items():
        for kw in keywords:
            # Use word-boundary matching so "data" doesn't match "update"
            if re.search(rf"\b{re.escape(kw)}\b", lower):
                matched.append(tag)
                break
    return matched


def generate_title(question_1: str, max_words: int = 6) -> str:
    """Generate a short title from the first question's content."""
    words = question_1.strip().split()
    title = " ".join(words[:max_words])
    if len(words) > max_words:
        title += "…"
    return title
