---
allowed-tools: Read, TodoRead, Bash(git:log)
description: Analyze current session and suggest minimal documentation improvements
argument-hint: 
---

Analyze the current development session and suggest minimal documentation improvements:

1. **Read Current State:**
   - Review existing project documentation or notes for recent decisions
   - Read current TodoRead status
   - Check recent git commits with `git log --oneline -5`

2. **Identify Learning Opportunities:**
   - What architectural mistakes were made and corrected?
   - What TypeScript/framework-specific issues came up repeatedly?
   - What workflow inefficiencies occurred?

3. **Suggest Minimal Improvements:**
   - **Global CLAUDE.md**: Only add if it's a universal principle (not project-specific)
   - **Local CLAUDE.md**: Add project-specific patterns that would prevent future mistakes
   - **Team Notes/Docs**: Capture key decisions and lessons learned in shared documentation

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
   ### Team Notes/Docs: [Capture decisions for future reference]
   
   ## Why These Changes
   [Specific problems these would prevent]
   ```

Do not implement changes - only suggest them with clear reasoning.
