---
allowed-tools: Read, TodoRead, Bash(git:log)
description: Analyze current session and suggest minimal documentation improvements
argument-hint: 
---

Analyze the current development session and suggest minimal documentation improvements:

1. **Read Current State:**
   - Check Serena memories with `mcp__serena__list_memories` and read relevant ones
   - Read current TodoRead status
   - Check recent git commits with `git log --oneline -5`

2. **Identify Learning Opportunities:**
   - What architectural mistakes were made and corrected?
   - What TypeScript/framework-specific issues came up repeatedly?
   - What workflow inefficiencies occurred?

3. **Suggest Minimal Improvements:**
   - **Global CLAUDE.md**: Only add if it's a universal principle (not project-specific)
   - **Local CLAUDE.md**: Add project-specific patterns that would prevent future mistakes
   - **Serena Memories**: Write memories for key decisions and lessons learned

4. **Anti-Overengineering Rules:**
   - Skip suggestions if similar guidance already exists
   - Focus on 1-2 high-impact additions maximum
   - Prefer updating existing sections over creating new ones
   - Only suggest what would have prevented actual problems in THIS session

5. **Output Format:**
   ```
   ## Analysis
   [What happened in this session]
   
   ## Suggested Improvements
   ### Global CLAUDE.md: [None needed] OR [1 universal principle]
   ### Local CLAUDE.md: [None needed] OR [1-2 project patterns]
   ### Serena Memories: [Write memories for decisions made]
   
   ## Why These Changes
   [Specific problems these would prevent]
   ```

Do not implement changes - only suggest them with clear reasoning.