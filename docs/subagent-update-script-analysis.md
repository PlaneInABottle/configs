# Subagent Update Script - Analysis & Options

## Current Situation

### What We Have
1. **Standardized Subagents** (5 files × 2 systems = 10 files)
   - Debugger, Planner, Reviewer, Implementer, Refactor
   - Copilot: Simple 4-line header format
   - Opencode: Extended YAML header format (44-46 lines)
   - Content: 100% identical after headers

2. **Existing Script Pattern** (`generate-project-agents.sh`)
   - Creates project-specific instructions
   - Uses template with placeholders
   - Handles multiple output formats (Claude, Gemini, Qwen, AGENTS.md)
   - Supports `--update` and `--force` modes

### Current Header Differences

**Copilot Format:**
```markdown
---
name: debugger
description: "..."
---
```

**Opencode Format:**
```yaml
---
description: "..."
mode: subagent
examples:
  - "..."
tools:
  write: true
  edit: true
  bash: true
  # ... more tools
permission:
  webfetch: allow
  bash:
    "git diff": allow
    # ... more permissions
---
```

### Content Structure Differences

Different subagents have different section structures:

**Example - Debugger has:**
- Core Responsibilities
- Comprehensive Debugging Framework (4 phases)
- Design Principles in Debugging
- Specialized Debugging Scenarios
- Common Bug Categories
- Root Cause Analysis
- etc.

**Example - Planner has:**
- Core Responsibilities  
- Design Principles FIRST
- Breaking Changes Planning
- Complete Reviewer Document Reading
- Design Principles & Patterns Integration
- etc.

## Options for Update Script

### Option 1: Template-Based Approach (Like generate-project-agents.sh)

**Structure:**
```
templates/
  subagents/
    DEBUGGER.template.md      - Content only (no headers)
    PLANNER.template.md
    REVIEWER.template.md
    IMPLEMENTER.template.md
    REFACTOR.template.md
  headers/
    copilot-header.template
    opencode-header.template
```

**Pros:**
- Single source of truth for content
- Easy to update all instances at once
- Header management separated from content
- Similar pattern to existing script

**Cons:**
- Requires maintaining templates separately
- Initial migration effort to create templates
- May need placeholder system for subagent-specific customization

**Implementation:**
```bash
update-subagents.sh --agent=debugger [--system=copilot|opencode|all]
update-subagents.sh --all --system=all
```

### Option 2: Content Extraction & Injection

**Approach:**
- Keep current files as source
- Script extracts content after headers
- Injects into target files with appropriate headers
- No template files needed

**Pros:**
- No template maintenance
- Works with existing files directly
- Simpler initial implementation

**Cons:**
- Harder to track "canonical" version
- Need to pick which file is source (copilot or opencode)
- Risk of circular updates if not careful

**Implementation:**
```bash
sync-subagents.sh --source=copilot --target=opencode --agent=debugger
sync-subagents.sh --source=opencode --target=copilot --all
```

### Option 3: Hybrid - Master Templates + Auto-Sync

**Structure:**
```
templates/
  subagents/
    master/
      debugger.md          - Master content (no headers)
      planner.md
      etc.
copilot/.copilot/agents/   - Auto-generated from master + copilot headers
opencode/.config/opencode/agent/ - Auto-generated from master + opencode headers
```

**Pros:**
- Clear single source of truth (master/)
- Auto-generation prevents drift
- Easy to see what changed (diff master/)
- Can regenerate anytime

**Cons:**
- Cannot edit generated files directly
- Need discipline to edit master only
- More complex workflow

### Option 4: Keep Manual + Validation Script

**Approach:**
- Keep current manual editing approach
- Add validation script to ensure content stays in sync
- Script checks content identity (excluding headers)
- Alerts if drift detected

**Pros:**
- Flexibility to edit either file
- No workflow changes
- Easy to implement

**Cons:**
- Doesn't prevent drift, only detects it
- Still manual work to fix drift
- Requires running validation regularly

**Implementation:**
```bash
validate-subagents.sh --check-all
# Exit code 0 if all synced, 1 if drift detected
```

## Header Standardization Question

### Current State
- Copilot: Minimal (4 lines)
- Opencode: Extended with metadata (44-46 lines)

### Should We Standardize Headers?

**Option A: Keep Different Headers**
- Copilot uses what it needs (minimal)
- Opencode uses what it needs (detailed permissions)
- Only content stays identical

**Option B: Standardize to Common Format**
- Both use same header structure
- May include unused fields for some tools
- Perfect 100% file identity

**Recommendation:** Keep different headers (Option A)
- Tools have different requirements
- Copilot doesn't need permission blocks
- Opencode needs detailed tool permissions
- Content identity is what matters

## Section Structure Standardization

### Current State
Different subagents have different sections tailored to their purpose:
- Debugger: 4-phase debugging framework
- Planner: Comprehensive planning process with SOLID principles
- Implementer: Technology-specific guides
- etc.

### Should We Standardize Sections?

**Option A: Keep Custom Sections per Subagent**
- Each subagent has sections relevant to its role
- Maximum clarity and usability
- Content organized for specific tasks

**Option B: Force Common Section Structure**
```markdown
## Core Responsibilities
## Design Principles
## Process Framework
## Best Practices
## Quality Standards
## Commit Requirements
```

**Recommendation:** Keep custom sections (Option A)
- Each subagent serves different purpose
- Debugger needs debugging-specific framework
- Planner needs planning-specific structure
- Forcing common structure would reduce clarity
- As long as content is identical, section structure can vary

## Recommended Approach

**Hybrid Option 3 with Validation (3 + 4 Combined)**

### Implementation Plan

```
1. Create Master Templates
   templates/subagents/master/
     ├── debugger.md
     ├── planner.md
     ├── reviewer.md
     ├── implementer.md
     └── refactor.md

2. Create Header Templates
   templates/subagents/headers/
     ├── copilot.template
     └── opencode.template

3. Create Generation Script
   scripts/update-subagents.sh
     - Reads master template
     - Applies appropriate header
     - Generates final files
     - Validates output

4. Create Validation Script
   scripts/validate-subagents.sh
     - Checks content identity
     - Ignores header differences
     - Reports any drift
     - Can be run in CI/CD

5. Git Hook (Optional)
   .git/hooks/pre-commit
     - Runs validation
     - Prevents commits with drift
```

### Usage Examples

```bash
# Update single subagent for all systems
./scripts/update-subagents.sh --agent=debugger

# Update all subagents for copilot only
./scripts/update-subagents.sh --all --system=copilot

# Update from master and force overwrite
./scripts/update-subagents.sh --all --force

# Validate all subagents are in sync
./scripts/validate-subagents.sh

# Extract current content to master (migration helper)
./scripts/extract-to-master.sh --agent=debugger
```

### Migration Process

```bash
# Step 1: Extract current content to master templates
./scripts/extract-to-master.sh --all

# Step 2: Verify extraction
./scripts/validate-subagents.sh

# Step 3: Test regeneration
./scripts/update-subagents.sh --all --dry-run

# Step 4: Commit master templates
git add templates/subagents/master/
git commit -m "Add master subagent templates"

# Step 5: Regenerate all
./scripts/update-subagents.sh --all --force

# Step 6: Verify
./scripts/validate-subagents.sh
```

## Conclusion

**Recommended Solution:**
- **Master Templates**: Single source of truth in `templates/subagents/master/`
- **Different Headers**: Keep copilot and opencode headers different (tool requirements)
- **Custom Sections**: Keep different section structures per subagent (role-specific)
- **Auto-Generation**: Script to regenerate from master + headers
- **Validation**: Script to check sync status
- **Git Hook**: Optional pre-commit validation

**Why This Works:**
1. Clear source of truth (master templates)
2. Respects tool differences (headers)
3. Respects role differences (sections)
4. Prevents drift (auto-generation)
5. Easy to maintain (one place to update)
6. Safe (validation catches issues)

**Next Steps:**
1. Create master template extraction script
2. Create update-subagents.sh generation script
3. Create validate-subagents.sh validation script
4. Test with one subagent (debugger)
5. Roll out to all subagents
