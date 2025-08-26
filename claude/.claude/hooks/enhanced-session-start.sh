#!/bin/bash
# Enhanced SessionStart Hook - Rich Context and Metacognitive Initialization

HOOK_DATA=$(cat)

echo "🚀 ENHANCED SESSION INITIALIZATION:"

if command -v jq >/dev/null 2>&1; then
  SESSION_TYPE=$(echo "$HOOK_DATA" | jq -r '.source // "unknown"')

  case "$SESSION_TYPE" in
  "startup")
    echo "  🆕 Fresh session started"
    echo "  📚 RECOMMENDED STARTUP CHECKLIST:"
    echo "     □ Activate Serena for code projects"
    echo "     □ Read memory-navigation-index for organized knowledge access"
    echo "     □ Review project CLAUDE.md for patterns"
    echo "     □ Use Context7 for library documentation"
    ;;
  "resume")
    echo "  🔄 Session resumed from summary"
    echo "  🎯 RESUMPTION CHECKLIST:"
    echo "     □ Read memory-navigation-index for organized knowledge access"
    echo "     □ Check TODO list for pending tasks"
    echo "     □ Review recent git status for changes"
    echo "     □ Continue with specialized tools/subagents"
    echo "     □ Validate previous decisions still apply"
    ;;
  "clear")
    echo "  🧹 Context cleared - starting fresh"
    echo "  🗂️ FRESH START CHECKLIST:"
    echo "     □ Previous session context has been reset"
    echo "     □ Re-establish project context if needed"
    echo "     □ Check for any pending tasks or issues"
    echo "     □ Read memory-navigation-index for organized knowledge access"
    ;;
  esac
fi

echo ""
echo "🧠 PROACTIVE INTELLIGENCE REMINDERS:"
echo "  🎯 SYSTEMATIC APPROACH:"
echo "     □ Ask clarifying questions before assuming"
echo "     □ Use specialized tools for complex tasks"
echo "     □ Engage expert subagents proactively"
echo "     □ Research with Context7/WebSearch when needed"
echo ""

echo "  🛠️ TOOL SELECTION PRIORITIES:"
echo "     □ Serena first for code exploration"
echo "     □ Zen MCP for systematic analysis"
echo "     □ Context7 for library research"
echo "     □ Subagents for specialized expertise"
echo ""

echo "  📋 QUALITY ASSURANCE:"
echo "     □ Provide multiple options with trade-offs"
echo "     □ Validate assumptions with questions"
echo "     □ Use appropriate complexity tools"
echo "     □ Document decisions in memories"
echo ""

# Git context if in a git repository
if git rev-parse --git-dir >/dev/null 2>&1; then
  echo "📍 GIT CONTEXT:"
  echo "  Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
  echo "  Status: $(git status --porcelain 2>/dev/null | wc -l) modified files"
  echo "  Last commit: $(git log -1 --oneline 2>/dev/null || echo 'No commits')"
  echo ""
fi

# Always exit successfully to allow operation to proceed
exit 0
