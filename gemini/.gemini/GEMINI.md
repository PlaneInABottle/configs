# Gemini CLI Global Configuration

*Universal standards for all projects - keep it focused and actionable*

---

## Core Workflow

### Implementation Gate
**Before substantial changes (architecture, schema, major features):**
1. **Analyze** - Research implications, identify 2-3 options  
2. **Present** - Show pros/cons, what will be created/modified
3. **Ask** - "Should I proceed with [specific option]?"
4. **Wait** - Get explicit approval before implementing

### Incremental Implementation Protocol
**ALL code changes must be done step-by-step:**
- **ONE change per iteration** - Fix one issue, write one test, implement one feature at a time
- **Make minimal changes** - Change only what's necessary for the current step
- **Test after each step** - Verify each change works before moving to next
- **Build incrementally** - Start simple, add complexity gradually

### TDD Workflow (Incremental)
1. **Write ONE test** - Single test case for current requirement
2. **Run test** - Verify it fails for the right reason
3. **Implement minimally** - Just enough code to pass THIS test
4. **Run test** - Verify it passes
5. **Refactor if needed** - Improve code while keeping test green
6. **Repeat** - Write next test, implement, refactor

### Code Verification (Per Step)
**After EACH incremental change:**
- **Search dependencies** for the specific change made using available search tools
- **Run tests** for the modified component only
- **Verify build** still works
- **Check one change at a time** - Don't batch multiple verifications

### Git Checkpoint Strategy
**Before starting work:**
```bash
git status    # Verify clean state
git pull      # Get latest changes
```

**Create checkpoints incrementally:**
- **After each working feature** - Commit with descriptive message
- **Before risky changes** - Create branch or stash
- **After passing tests** - Commit known-good state
- **Never commit broken code** - Fix or stash first

**Checkpoint commands:**
```bash
# Quick checkpoint
git add -p && git commit -m "checkpoint: [what works now]"

# Before risky change
git stash save "backup: before attempting [change]"

# Safety branch
git checkout -b safe/[current-feature]
```

### Error Recovery Patterns
**When tests fail:**
1. **Read the actual error** - Don't assume, investigate
2. **Run failing test in isolation** - Verify it's not environmental
3. **Check recent changes** - `git diff` to see what changed
4. **Revert if needed** - `git checkout -- [file]` to undo

**When builds break:**
```bash
# Check what changed
git diff HEAD~1

# Revert last change
git reset --hard HEAD~1

# Or revert specific file
git checkout HEAD -- [file]
```

**When edits go wrong:**
- **Bad string replacement** - Use ReadFileTool first, verify exact content
- **Wrong file edited** - Use git to revert: `git checkout -- [file]`
- **Multiple files affected** - `git status` then selective revert

**Recovery checklist:**
- [ ] Stop and assess - Don't make more changes
- [ ] Check git status - Understand what's modified
- [ ] Isolate the issue - One problem at a time
- [ ] Use git safety net - Revert to known-good state
- [ ] Fix incrementally - Small steps forward

### Session Management
**Before context compaction:**
1. **Commit all working code** - Create checkpoint: `git add -A && git commit -m "WIP: [current task]"`
2. **Update MemoryTool** - Document incomplete tasks and current progress
3. **Leave breadcrumbs** - Comment in code: `// TODO: Next step is...`
4. **Note key decisions** - Update project GEMINI.md with important context

**Starting new session:**
```bash
# Check where we left off
git log --oneline -5
git status
git diff

# Review todos and breadcrumbs
grep -r "TODO" . | head -20
```

**Progress documentation:**
- **Use meaningful commits** - Describe what works now
- **Update task tracking** - MemoryTool for progress
- **Document blockers** - What stopped progress and why
- **Leave context clues** - File paths, function names, next steps

**Session handoff template:**
```markdown
## Session Summary
- **Completed**: [What's done and working]
- **In Progress**: [Current task, how far along]
- **Blocked By**: [What's preventing progress]
- **Next Steps**: [Specific actions to continue]
- **Key Files**: [Files being modified]
```

## Quality Standards  

### Critical Analysis Framework
**When user suggests approaches, always:**
- Challenge assumptions and identify risks
- Present 2-3 alternatives with trade-offs  
- Use structured format:
  ```
  ✅ Strengths: [specific benefits with reasoning]
  ⚠️ Risks: [concrete issues with impact]
  🤔 Alternatives: [other options with trade-offs]
  💡 Recommendation: [clear choice with justification]
  ```

### Communication Standards
- Be specific: "Memory leak in event listeners" not "might have issues"
- Show reasoning: Always explain WHY
- Quantify impact: "30% slower" not "performance issues"
- Keep responses concise (< 4 lines unless detail requested)

## Tool Integration

### Session Initialization
- Always read project docs first using ReadFileTool (README.md, docs/, package.json)
- Check existing patterns and conventions before coding
- Use Context7 for latest library documentation before implementation

### Search & Discovery
- Use GlobTool to find files matching patterns
- Use available search tools for finding code references
- Always use ReadFileTool before editing with EditTool

### Sub-Agent Workflow
**When to use specialized agents:**
- **Code Review**: Security analysis, performance review, quality checks
- **Testing**: TDD specialist for writing focused tests
- **Code Fixing**: Incremental improvements, one issue at a time

**Usage Pattern:**
```bash
# For comprehensive analysis (no token limits in Gemini)
echo "Review ONLY [filename] for [specific scope]" |
  cat .claude/agents/[agent-name].md [target-file] - | gemini -m gemini-2.5-flash
```

**Agent Guidelines:**
- **Targeted scope** - Only analyze/fix specific files requested
- **Comprehensive within scope** - Cover all aspects of the target code
- **Incremental execution** - One change per iteration
- **Test after each change** - Verify before moving to next

### Library Documentation (Context7)
```bash
# 1. Resolve library ID
mcp__context7__resolve-library-id(libraryName: "react")

# 2. Get specific docs  
mcp__context7__get-library-docs(
  context7CompatibleLibraryID: "/facebook/react",
  topic: "hooks useState useEffect",
  tokens: 15000
)
```

### Built-in Tools Reference
```bash
# File operations
LSTool - List directory contents
ReadFileTool - Read file content (absolute paths)
WriteFileTool - Write content to files
EditTool - In-place file modifications
GlobTool - Find files matching patterns

# Search and analysis
Code Search - Search for patterns in files
ReadManyFilesTool - Read multiple files at once

# Execution and web
Command Execution - Execute shell commands (with confirmation)
WebFetchTool - Retrieve content from URLs
WebSearchTool - Perform web searches
MemoryTool - Interact with AI memory
```

## Quick Reference

### Before Coding
- [ ] Verify git clean state (`git status`)
- [ ] Pull latest changes (`git pull`)
- [ ] Check previous session summary (`git log -5`)
- [ ] Review any TODO comments (`grep -r TODO .`)
- [ ] Use ReadFileTool on project README and docs
- [ ] Check existing patterns and conventions
- [ ] Get Context7 docs for new libraries

### For Major Changes  
- [ ] Analyze implications and alternatives
- [ ] Present options with pros/cons  
- [ ] Get explicit approval before implementing
- [ ] Break into small incremental steps
- [ ] Implement one step at a time

### After Each Incremental Change
- [ ] Use search tools to find dependencies for this specific change
- [ ] Update/run tests for modified component only
- [ ] Verify build succeeds
- [ ] Commit checkpoint if tests pass
- [ ] Confirm change works before next step

### Code Quality (Incremental)
- [ ] Write ONE test first, implement, repeat
- [ ] Make ONE improvement at a time
- [ ] Be specific in analysis and communication
- [ ] Challenge user assumptions when appropriate
- [ ] Reference file:line_number in discussions

### Before Ending Session
- [ ] Commit all working changes with descriptive message
- [ ] Update MemoryTool with current progress
- [ ] Add TODO comments for next steps
- [ ] Document any blockers or decisions
- [ ] Create session summary if needed

---
*Built following Anthropic team patterns, adapted for Gemini CLI*