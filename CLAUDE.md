# Development Partnership

We're building production-quality code together. Your role is to create maintainable, efficient solutions while catching potential issues early.

When you seem stuck or overly complex, I'll redirect you - my guidance helps you stay on track.

**BEFORE ANY COMMIT/PR: Check forbidden patterns (lines 190-200)**

## AUTOMATED CHECKS ARE MANDATORY

**ALL hook issues are BLOCKING - EVERYTHING must be GREEN!**  
No errors. No formatting issues. No linting problems. Zero tolerance.  
These are not suggestions. Fix ALL issues before continuing.

## PRE-COMMIT/PR MANDATORY CHECKLIST

**BEFORE any commit or PR creation, Claude Code MUST:**

☐ **Check CLAUDE.md forbidden patterns** - Re-read the forbidden patterns section (lines 190-200)
☐ **No emojis anywhere** - Code, comments, documentation, commit messages, PR descriptions
☐ **No Claude attribution** - Remove any "Generated with Claude Code" or similar
☐ **No TODOs in production code** - Clean up all temporary markers
☐ **No hardcoded secrets** - Verify no API keys or passwords
☐ **Professional language only** - Clean, clear, technical communication

**MANDATORY STATEMENT**: Before any commit/PR, say: "I have verified this follows all forbidden patterns in CLAUDE.md"

## CRITICAL WORKFLOW - ALWAYS FOLLOW THIS!

### Research → Plan → Implement

**NEVER JUMP STRAIGHT TO CODING!** Always follow this sequence:

1. **Research**: Explore the codebase, understand existing patterns
   - **External Interface Verification**: Before using any external module options (Home Manager, cloud APIs), verify they exist in official documentation
   - **Version-specific documentation**: Always check documentation for the EXACT version being used  
   - **Documentation checkpoint**: Research phase MUST include checking authoritative sources with version alignment
   - **No assumption-based development**: All external interfaces require version-specific verification
2. **Plan**: Create a detailed implementation plan and verify it with me
3. **Implement**: Execute the plan with validation checkpoints

When asked to implement any feature, you'll first say: "Let me research the codebase and create a plan before implementing."

For complex architectural decisions or challenging problems, use enhanced thinking tools to engage maximum reasoning capacity. Say: "Let me think deeply about this architecture before proposing a solution."

### USE TASK DELEGATION!

_Leverage Claude Code's capabilities strategically_ for better results:

- Break complex tasks into focused investigations
- Use systematic workflows for comprehensive analysis
- Delegate research tasks: "Let me investigate the database schema while analyzing the API structure"
- For complex refactors: Identify changes first, then implement systematically

Use the Task tool and systematic workflows whenever a problem has multiple independent parts.

### Enhanced Reality Checkpoints

**Stop and validate** at these moments:

- After implementing a complete feature
- Before starting a new major component
- When something feels wrong
- Before declaring "done"
- **WHEN HOOKS FAIL WITH ERRORS** (BLOCKING)
- **Before implementing external interfaces**: Verify all APIs/options exist in YOUR version
- **API assumption check**: "Did I verify this option exists in MY version's documentation?"
- **Version alignment check**: "Am I using docs for the same version as my flake?"
- **Before every commit**: Validate commit message contains NO emojis or Claude attribution

**Knowledge checkpoints:**
- After every major component: Explain the design choices made
- Before declaring "done": Can I implement this again without AI?
- Weekly: Review and explain recent patterns learned
- Monthly: Implement something similar from scratch to test retention

Run your project's quality checks (tests, linting, formatting)

> Why: You can lose track of what's actually working. These checkpoints prevent cascading failures and knowledge brownouts.

### CRITICAL: Hook Failures Are BLOCKING

**When hooks report ANY issues (exit code 2), you MUST:**

1. **STOP IMMEDIATELY** - Do not continue with other tasks
2. **FIX ALL ISSUES** - Address every issue until everything is GREEN
3. **VERIFY THE FIX** - Re-run the failed command to confirm it's fixed
4. **CONTINUE ORIGINAL TASK** - Return to what you were doing before the interrupt
5. **NEVER IGNORE** - There are NO warnings, only requirements

This includes:

- Formatting issues (prettier, black, rustfmt, etc.)
- Linting violations (eslint, flake8, clippy, etc.) 
- Forbidden patterns (defined by your project)
- ALL other quality checks

Your code must be 100% clean. No exceptions.

### FORBIDDEN PATTERN VALIDATION

**Before EVERY commit/PR:**
1. **Re-read forbidden patterns** - CLAUDE.md lines 190-200 (or current location)
2. **Scan all content** - Code, comments, commit messages, PR descriptions
3. **Remove violations** - Fix immediately, no exceptions
4. **Verify compliance** - Double-check against each forbidden pattern

**This is MANDATORY - not optional**

**Recovery Protocol:**

- When interrupted by a hook failure, maintain awareness of your original task
- After fixing all issues and verifying the fix, continue where you left off
- Use the todo list to track both the fix and your original task

## Knowledge Preservation Protocol

### Before AI Assistance:
- State your hypothesis about the problem/approach
- Identify which concepts you want to understand deeply
- Set learning objectives: "I want to understand X pattern"

### During Implementation:
- Explain the "why" behind each architectural decision
- Connect new patterns to existing knowledge
- Document mental models and intuition being built

### After Completion:
- Summarize key insights gained
- Update personal knowledge base with new patterns
- Identify areas for deeper independent study

## Test-Driven Development Protocol

**"Write the test, let AI satisfy the contract" - TDD with AI reduces debugging by 90%**

### The TDD-AI Feedback Loop:

1. **RED**: Write a failing test that defines the exact behavior
   - Be specific about inputs, outputs, and edge cases
   - Test the interface you wish existed
   - Document assumptions and constraints in tests

2. **GREEN**: Let AI implement the minimal code to pass
   - Provide the failing test as context
   - Ask AI to implement ONLY what's needed to pass
   - Resist over-engineering at this stage

3. **REFACTOR**: Improve design with test safety net
   - Clean up implementation with AI assistance
   - Tests ensure behavior preservation
   - Extract patterns and improve architecture

### TDD Commands Integration:
- Use `/tdd <feature>` to start test-first development
- All `/next` commands should begin with test design
- `/check` validates both implementation AND test quality

### TDD Learning Objectives:
- **Requirements Clarity**: Tests force precise thinking about behavior
- **Interface Design**: Write tests for the API you want to use
- **Regression Protection**: Changes can't break existing behavior
- **Documentation**: Tests serve as executable specifications

### Senior-Level TDD Thinking:
- Tests reveal design problems before implementation
- Good tests enable fearless refactoring
- Test structure mirrors system architecture
- Edge cases in tests prevent production surprises

**Why This Works With AI:**
- Tests provide unambiguous specifications
- AI can't misinterpret test requirements
- Failing tests guide AI toward correct solutions
- Passing tests validate AI implementations

## Working Memory Management

### When context gets long:

- Re-read this CLAUDE.md file
- Summarize progress in a PROGRESS.md file
- Document current state before major changes

### Maintain TODO.md:

```
## Current Task
- [ ] What we're doing RIGHT NOW

## Completed
- [x] What's actually done and tested

## Next Steps
- [ ] What comes next
```

## Language-Specific Quality Rules

### UNIVERSAL FORBIDDEN PATTERNS:

- **NO emojis** in code, comments, documentation, commit messages, or any project files
- **NO Claude attribution** in commit messages ("Generated with Claude Code", "Co-Authored-By: Claude", etc.)
- **NO** keeping old and new code together - delete when replacing
- **NO** migration functions or compatibility layers
- **NO** versioned function names (processV2, handleNew, etc.)
- **NO** TODOs in final production code
- **NO** console.log/print statements in production
- **NO** hardcoded secrets or API keys
- **NO** broad exception catching without specific handling

### COMMIT MESSAGE VALIDATION (MANDATORY):

**Before every commit, validate the message contains ZERO:**
- Emojis (🤖, ✅, 🔧, etc.)
- Claude attribution phrases
- "Generated with Claude Code"
- "Co-Authored-By: Claude"
- Robot/AI references

**REQUIRED commit message format:**
```
type: brief description

Optional longer explanation of what and why.
```

**Valid types:** feat, fix, docs, style, refactor, test, chore

### Language-Specific Additions:

**Rust:** No unwrap(), expect(), panic!() - use Result<T, E>
**JavaScript/TypeScript:** No any types, use strict mode
**Python:** No bare except clauses, use type hints
**Go:** No empty error checks, handle all errors

**AUTOMATED ENFORCEMENT**: Quality hooks will BLOCK commits that violate these rules.  
When you see "FORBIDDEN PATTERN", you MUST fix it immediately!

### Universal Quality Standards:

- **Delete** old code when replacing it
- **Meaningful names**: `user_id` not `id`, `process_payment` not `do_stuff`
- **Early returns** to reduce nesting depth
- **Proper error handling** for your language (exceptions, Result types, etc.)
- **Comprehensive tests** for complex logic
- **Consistent code style** following project/language conventions
- **Clear separation of concerns** - single responsibility principle

### Version-Specific Validation Requirements:

- **Nix module options**: Must be verified against module documentation for your nixpkgs version
- **Home Manager options**: Must exist in your Home Manager version's documentation  
- **External APIs**: Must be verified against version-specific official documentation
- **No cross-version assumptions**: Options may not exist in all versions
- **Version documentation**: Always comment the version/branch used for verification
- **Documentation reference requirement**: Include links with version/branch information

### Example Patterns:

**JavaScript/TypeScript:**
```javascript
// GOOD: Proper error handling
async function fetchUserData(id: string): Promise<User | null> {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) return null;
    return await response.json();
  } catch (error) {
    console.error('Failed to fetch user:', error);
    return null;
  }
}

// BAD: No error handling
async function fetchUserData(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  return await response.json(); // Can throw!
}
```

**Python:**
```python
# GOOD: Proper error handling
def parse_config(path: Path) -> Optional[Config]:
    try:
        with open(path) as f:
            return Config.from_json(f.read())
    except (FileNotFoundError, json.JSONDecodeError) as e:
        logger.error(f"Config parse failed: {e}")
        return None

# BAD: Bare except
def parse_config(path: Path) -> Config:
    try:
        with open(path) as f:
            return Config.from_json(f.read())
    except:  # Too broad!
        return Config()
```

## Implementation Standards

### Our code is complete when:

- All linters pass with zero issues
- All tests pass
- Feature works end-to-end
- Old code is deleted
- Documentation on all public items

### Testing Strategy

- **Complex business logic** → Write tests first (TDD)
- **Red → Green → Refactor** cycle for new features
- **Simple operations** → Write tests after implementation
- **Critical paths** → Add performance/integration tests
- **Skip testing** trivial getters/setters and framework boilerplate

### Project Structure Examples

**Node.js/TypeScript:**
```
src/
├── index.ts      # Application entrypoint
├── lib/          # Core modules
├── types/        # Type definitions
├── utils/        # Utility functions
└── config/       # Configuration
tests/            # Test files
docs/             # Documentation
```

**Python:**
```
src/package_name/
├── __init__.py   # Package entrypoint
├── core/         # Core modules
├── utils/        # Utility modules
└── config.py     # Configuration
tests/            # Test files
docs/             # Documentation
```

## Problem-Solving Together

When you're stuck or confused:

1. **Stop** - Don't spiral into complex solutions
2. **Break it down** - Use systematic investigation tools
3. **Think deeply** - For complex problems, engage enhanced reasoning
4. **Step back** - Re-read the requirements
5. **Simplify** - The simple solution is usually correct
6. **Ask** - "I see two approaches: [A] vs [B]. Which do you prefer?"

My insights on better approaches are valued - please ask for them!

## Performance & Security

### **Measure First**:

- No premature optimization
- Benchmark before claiming something is faster
- Use appropriate profiling tools for your language
- Focus on algorithmic improvements over micro-optimizations

### **Security Always**:

- Validate all inputs at boundaries
- Use established crypto libraries (never roll your own)
- Parameterized queries for SQL (never concatenate!)
- Sanitize user input and escape outputs
- Follow OWASP guidelines for your stack

## Communication Protocol

### Progress Updates:

```
- Implemented authentication (all tests passing)
- Added rate limiting
- Found issue with token expiration - investigating
```

### Suggesting Improvements:

"The current approach works, but I notice [observation].
Would you like me to [specific improvement]?"

## Professional Communication Standards

### Commit Messages
- **NO emojis** - Use clear, descriptive text only
- **NO Claude attribution** - Professional commits don't mention AI assistance
- **Follow conventional commits** - feat:, fix:, docs:, etc.
- **Focus on impact** - What changed and why
- **Clear structure** - Brief summary, detailed explanation if needed
- **Professional tone** - Clear, concise, factual

### Code Comments
- **NO emojis** - Professional documentation only
- **Explain why, not what** - Focus on reasoning and context
- **NO Claude references** - Comments should be from developer perspective
- **Document decisions** - Explain architectural choices and trade-offs
- **Future context** - Help your future self understand the code

### Pull Request Descriptions
- **Technical focus** - Describe changes, impact, testing
- **NO emojis** - Professional technical communication
- **NO Claude attribution** - Credit goes to the developer
- **Clear structure** - Summary, changes, test plan
- **Professional tone** - Clear, concise, factual

### Documentation
- **Technical focus** - Describe functionality, usage, and architecture
- **NO emojis** - Professional technical communication
- **Clear examples** - Provide concrete usage examples
- **Maintenance notes** - Document known issues and future improvements

## Technical Mastery Progression

### Current Focus: [Update weekly]
- Target concept: Core patterns for your tech stack
- Learning method: Implement features from scratch with understanding
- Knowledge gap: [Identify specific areas needing improvement]

### Depth Markers:
- **Novice**: Can use with AI guidance
- **Intermediate**: Can explain to others
- **Advanced**: Can implement from first principles
- **Expert**: Can teach and extend the concept

### Universal Mastery Areas to Track:
- **System Design & Architecture**: Novice → Intermediate → Advanced → Expert
- **Error Handling Patterns**: Novice → Intermediate → Advanced → Expert
- **Testing & Quality Assurance**: Novice → Intermediate → Advanced → Expert
- **Performance & Optimization**: Novice → Intermediate → Advanced → Expert
- **Security Best Practices**: Novice → Intermediate → Advanced → Expert
- **Test-Driven Development**: Novice → Intermediate → Advanced → Expert

### TDD Mastery Progression:
- **Novice**: Can write basic tests with guidance - Following examples and patterns
- **Intermediate**: Can design test suites independently - Understanding when and what to test
- **Advanced**: Can use TDD to drive architecture - Tests reveal design decisions
- **Expert**: Can teach TDD patterns to others - Mentor others in test-first thinking

# NIX CONFIGURATION DEVELOPMENT STANDARDS

## Architecture Overview

This is a **Nix flake-based configuration** managing macOS systems with nix-darwin and Home Manager integration.

### System Architecture:
```
flake.nix → mkDarwinHost() → system modules → Home Manager → user profiles/roles
```

**Configuration Layers (applied bottom-to-top):**
1. **Base Layer** (`modules/base.nix`): Core packages, fonts, Nix settings
2. **Platform Layer** (`modules/darwin/`): macOS-specific system configuration  
3. **Host Layer** (`hosts/<hostname>/system.nix`): Machine-specific overrides
4. **Profile Layer** (`home/profiles/`): User environments (base, tui, gui, darwin)
5. **Role Layer** (`home/roles/`): Purpose-based packages (dev, personal, work, security)

### Dual Package System:
- **nixpkgs**: Stable packages for reliability
- **nixpkgs-unstable**: Bleeding-edge packages for development tools
- Both available via `specialArgs` throughout the configuration

## Nix Development Workflow

### 1. Development Environment Setup
```bash
nix develop  # Enter development shell with quality tools
```

**Available Tools in Dev Shell:**
- `alejandra` - Nix code formatter (MANDATORY)
- `statix` - Nix linter (MANDATORY) 
- `deadnix` - Dead code detection (MANDATORY)
- `pre-commit` - Pre-commit automation
- `nil` - Nix language server (for editor integration)

### 2. Quality Enforcement Pipeline
**Pre-commit hooks are MANDATORY and BLOCKING:**

```bash
# These run automatically on commit:
alejandra .          # Format all .nix files
statix check .       # Lint all .nix files  
deadnix --fail .     # Check for dead code
```

**Manual Quality Checks:**
```bash
# Only run these for .nix file changes
nix flake check      # Validate flake structure
nix build .#darwinConfigurations.<SYSTEM>.system  # Test build (replace <SYSTEM> with actual system)
```

## File Type → Tool Mapping

**CRITICAL**: Always match tools to correct file types. Never apply language-specific tools to other file types.

| File Type | Extensions | Formatter | Linter | Validation | When to Validate | Notes |
|-----------|------------|-----------|---------|------------|------------------|--------|
| **Nix** | `*.nix` | `alejandra` | `statix` | `deadnix`, `nix flake check`, `sudo darwin-rebuild check --flake .#<SYSTEM>` | **Always** | Affects system configuration |
| **Markdown** | `*.md` | *(manual)* | *(none)* | generic hooks | **Never** | Documentation only |
| **YAML** | `*.yaml`, `*.yml` | *(none)* | *(none)* | `check-yaml` | **If system config** | Only if affects Nix configuration |
| **TOML** | `*.toml` | *(none)* | *(none)* | `check-toml` | **If system config** | Only if affects Nix configuration |
| **All Files** | `*` | *(none)* | *(none)* | `trailing-whitespace`, `end-of-file-fixer` | **Always** | Generic cleanup |

### Tool Selection Protocol

**ALWAYS Follow This Process:**

1. **Check file extension** before applying any formatter or linter
2. **Match tool to file type** using the table above
3. **Never apply language-specific tools** to other file types
4. **Use generic hooks** for basic cleanup across all files

### Validation Decision Tree

**Step 1: What files changed?**
- `.nix` files included? → **YES** → Run full Nix validation
- `.nix` files included? → **NO** → Skip Nix validation

**Step 2: Run appropriate validation**
- **Nix files changed**: `alejandra`, `statix`, `deadnix`, `nix flake check`, `sudo darwin-rebuild check --flake .#<SYSTEM>`
- **Documentation only**: Generic hooks only (automatic)
- **Mixed changes**: Run validation for each file type

**Step 3: Always run**
- Pre-commit hooks (automatically scoped to file types)
- Generic quality checks (trailing whitespace, etc.)

**Never run for documentation-only changes:**
- `nix flake check`
- `sudo darwin-rebuild check --flake .#<SYSTEM>`
- `alejandra` (Nix-specific)
- `statix` (Nix-specific)

### Common Mistakes to Avoid

❌ **WRONG**: `alejandra CLAUDE.md` (Nix tool on Markdown)
❌ **WRONG**: `statix check README.md` (Nix linter on Markdown)  
❌ **WRONG**: `deadnix notes.md` (Nix analyzer on Markdown)

✅ **CORRECT**: `alejandra *.nix` (Nix tool on Nix files)
✅ **CORRECT**: Manual review for Markdown files
✅ **CORRECT**: `sudo darwin-rebuild check --flake .#<SYSTEM>` for system validation

### Context-Specific Validation

**For Nix Configuration Changes (`.nix` files):**
```bash
# MANDATORY after any .nix file changes
alejandra *.nix     # Format Nix files
statix check .      # Lint Nix files
deadnix .          # Check for dead code
nix flake check     # Validate flake structure only
sudo darwin-rebuild check --flake .#<SYSTEM>  # Test actual system build (CRITICAL)
```

**Important**: 
- `nix flake check` only validates flake syntax and structure 
- `sudo darwin-rebuild check --flake .#<SYSTEM>` tests the actual system configuration that will be deployed
- Replace `<SYSTEM>` with your actual system name (e.g., `a2251`)

**For Documentation Changes (`.md` files):**
```bash
# No additional validation needed
# Generic hooks handle basic formatting automatically
```

**For Mixed Changes:**
```bash
# Run validation based on file types changed
# Only run nix commands if .nix files were modified
pre-commit run --all-files  # Run all configured hooks
```

**Always Run (regardless of file types):**
```bash
# Generic quality checks apply to all files
# Pre-commit hooks automatically scope to relevant file types
```

### 3. System Rebuild Process
```bash
# Standard rebuild for active development
sudo darwin-rebuild switch --flake .#<SYSTEM>  # Replace <SYSTEM> with actual system

# Safe rebuild (build without switching)
sudo darwin-rebuild build --flake .#<SYSTEM>  # Replace <SYSTEM> with actual system

# Rollback if issues occur
sudo darwin-rebuild rollback
```

### 4. Dependency Management
```bash
nix flake update     # Update all inputs (nixpkgs, home-manager, etc.)
nix flake lock       # Generate lockfile without updating
```

## Home Manager Option Verification (MANDATORY)

**CRITICAL**: Always verify options against the EXACT version you're using.

### Version Identification:
1. **Check flake.lock**: Identify Home Manager commit/version
2. **Identify nixpkgs branch**: Currently using 25.05 stable (may change)
3. **Match documentation version**: Use docs for the same version/branch

### Option Verification Process:
1. **Check version-specific docs**: 
   - https://mynixos.com/home-manager/options/ (latest)
   - https://nix-community.github.io/home-manager/options.html (specific releases)
   - GitHub: https://github.com/nix-community/home-manager (for exact commits)
2. **Search for exact option**: Use browser search for `programs.neovim.extraFiles`
3. **Version compatibility check**: Verify option exists in YOUR version
4. **If not found**: Identify correct alternative for your version
5. **Document source & version**: Comment the documentation URL and version in code

**FORBIDDEN**: 
- Using Home Manager options without version-specific verification
- Assuming options exist across all versions
- Using documentation from different versions

**REQUIRED**: 
- Every option verified against YOUR EXACT version
- Version documentation URL in comments
- Branch/version awareness (currently 25.05 stable)

### Version Identification Commands:
```bash
# Check nixpkgs version in flake
nix flake metadata | grep nixpkgs

# Check Home Manager version
nix flake metadata | grep home-manager

# Check current branch/version in use
cat flake.lock | jq '.nodes.nixpkgs.locked'
```

## System-Specific Testing Requirements

**CRITICAL**: Always test the actual system configuration, not just flake structure.

**IMPORTANT**: Throughout this documentation, `<SYSTEM>` is a placeholder that must be replaced with the actual system name:
- Current primary system: `a2251`
- Find available systems: `ls hosts/` 
- Examples: `sudo darwin-rebuild check --flake .#a2251`, `sudo darwin-rebuild check --flake .#macbook-pro`, etc.

### Testing Command Hierarchy:
1. **Flake structure validation**: `nix flake check` (fast, validates flake syntax)
2. **System configuration test**: `sudo darwin-rebuild check --flake .#<SYSTEM>` (comprehensive)
3. **Build verification**: `sudo darwin-rebuild build --flake .#<SYSTEM>` (creates but doesn't apply)

### System Identification:
- **Current system**: `a2251` (primary development machine)
- **Command pattern**: `sudo darwin-rebuild check --flake .#<SYSTEM>`
- **Replace `<SYSTEM>` with**: Actual system name from `hosts/` directory (e.g., `a2251`)
- **System determination**: `ls hosts/` to see available system configurations

### Testing Protocol:
```bash
# 1. Quick flake validation (structure only)
nix flake check

# 2. Full system validation (REQUIRED for .nix changes)
sudo darwin-rebuild check --flake .#<SYSTEM>  # Replace <SYSTEM> with actual system name

# 3. Build test without applying (optional verification)
sudo darwin-rebuild build --flake .#<SYSTEM>  # Replace <SYSTEM> with actual system name

# Example for a2251 system:
sudo darwin-rebuild check --flake .#a2251
```

**NEVER rely solely on `nix flake check` for system configuration changes!**

## Nix-Specific Quality Rules

### FORBIDDEN PATTERNS IN NIX:

- **NO** `lib.mkForce` unless absolutely necessary - use `lib.mkDefault` first
- **NO** hardcoded store paths - use `${pkgs.package}` references
- **NO** `fetchTarball` without hash - use flake inputs instead
- **NO** `builtins.fetchurl` - use proper fetchers (fetchFromGitHub, etc.)
- **NO** `with pkgs;` in large scopes - prefer explicit package references
- **NO** recursive attribute sets without clear necessity
- **NO** `import <nixpkgs> {}` in modules - use function arguments
- **NO** mixing tabs and spaces - use consistent indentation (2 spaces)
- **NO** `.override` without understanding - prefer `.overrideAttrs`
- **NO** `callPackage` without proper package structure

### REQUIRED PATTERNS:

- **USE** `lib.mkDefault` for host-overridable defaults
- **USE** `lib.mkIf` for conditional configuration
- **USE** `lib.mkMerge` for combining attribute sets
- **USE** proper function signatures: `{pkgs, lib, ...}:`
- **USE** `inherit` for variable passing: `inherit (vars.git) userName;`
- **USE** `let ... in` for local variable scoping
- **USE** string interpolation: `"${vars.user.username}"`
- **USE** proper list formatting (one item per line for readability)

### Module Development Standards:

**1. Module Structure:**
```nix
# modules/example.nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Other modules
  ];
  
  # Configuration options
  options = {
    # Define options if creating reusable modules
  };
  
  # Configuration implementation
  config = {
    # Implementation
  };
}
```

**2. Home Manager Module Structure:**
```nix
# home/modules/example.nix
{
  config,
  lib,
  pkgs,
  pkgs-unstable,  # Available via specialArgs
  ...
}: {
  home.packages = with pkgs; [
    # Stable packages
  ] ++ [
    # Unstable packages
    pkgs-unstable.claude-code
  ];
  
  programs.example = {
    enable = true;
    # Configuration
  };
}
```

### Package Selection Strategy:

**Use Stable Packages For:**
- Core system tools (editors, shells, essential utilities)
- Well-established development tools
- Packages where stability is crucial

**Use Unstable Packages For:**
- Rapidly evolving development tools
- Latest language versions (Node.js, Python, Go)
- Cutting-edge CLI tools
- Packages where newest features matter

**Example:**
```nix
home.packages = with pkgs; [
  # Stable - core tools
  git
  vim
  curl
] ++ [
  # Unstable - latest features
  pkgs-unstable.nodejs_latest
  pkgs-unstable.claude-code
];
```

## File Organization Patterns

### Configuration Location Rules:
- **System-level**: `modules/` and `hosts/<hostname>/system.nix`
- **User-level**: `home/profiles/` and `home/roles/`
- **Variables**: `variables/default.nix` (centralized configuration)
- **Host-specific**: `hosts/<hostname>/` (both system and user config)

### Import Patterns:
```nix
# Good - explicit imports
imports = [
  ./modules/base.nix
  ./modules/darwin
  ../../variables  # Relative paths OK for variables
];

# Bad - implicit or unclear imports
imports = [ ./default.nix ];
```

### Variable Usage:
```nix
# Good - use centralized variables
let
  vars = import ../../variables;
in {
  home.homeDirectory = "/Users/${vars.user.username}";
  programs.git.inherit (vars.git) userName userEmail;
}

# Bad - hardcoded values
home.homeDirectory = "/Users/balisong";
```

## Development Integration

### Editor Setup (Neovim + nixd):
- **LSP**: `nixd` provides intelligent Nix language support
- **Formatting**: `alejandra` integration for automatic formatting
- **Linting**: `statix` integration for real-time feedback

### VS Code Integration:
- **Extension**: Nix IDE extension with nixd language server
- **Formatting**: Configure alejandra as default formatter
- **Linting**: Enable statix for real-time error detection

### Git Integration:
```bash
# Standard development workflow
git add .
git commit -m "feat: description"  # Triggers pre-commit hooks
sudo darwin-rebuild switch --flake .#<SYSTEM>  # Replace <SYSTEM> with actual system
```

## Version Change Protocol

### When Changing Versions (nixpkgs/Home Manager)

1. **Re-verify all external options**: Options may be added/removed/changed between versions
2. **Update documentation references**: Change comments to reference new version docs
3. **Test configuration**: Some options may have different behavior or requirements
4. **Update CLAUDE.md**: If switching from 25.05 stable, update version references throughout
5. **Version validation check**: Run version identification commands to confirm alignment

### Version Change Checklist:
- [ ] Identify all external module options in use (Home Manager, etc.)
- [ ] Re-verify each option exists in the new version's documentation
- [ ] Update inline documentation comments with new version URLs
- [ ] Test build: `nix flake check` (structure) and `sudo darwin-rebuild check --flake .#<SYSTEM>` (system)
- [ ] Update CLAUDE.md version references if changing major versions

## Troubleshooting & Recovery

### Common Issues:
1. **Build failures**: Check `sudo darwin-rebuild check --flake .#<SYSTEM>` output
2. **Hook failures**: Run quality tools manually and fix issues
3. **System issues**: Use `sudo darwin-rebuild rollback`
4. **Dependency conflicts**: Update with `nix flake update`

### Recovery Commands:
```bash
# Reset to working state
sudo darwin-rebuild rollback

# Clean rebuild
sudo darwin-rebuild switch --flake .#<SYSTEM>  # Replace <SYSTEM> with actual system --recreate-lock-file

# Force rebuild ignoring cache
sudo darwin-rebuild switch --flake .#<SYSTEM>  # Replace <SYSTEM> with actual system --refresh
```

### Debug Mode:
```bash
# Verbose output for debugging
sudo darwin-rebuild switch --flake .#<SYSTEM>  # Replace <SYSTEM> with actual system --show-trace --verbose

# Build only (no activation)
sudo darwin-rebuild build --flake .#<SYSTEM>  # Replace <SYSTEM> with actual system
```

## Testing & Validation

### Configuration Testing:
```bash
# Validate flake structure
nix flake check

# Test build without switching
sudo darwin-rebuild build --flake .#<SYSTEM>  # Replace <SYSTEM> with actual system

# Evaluate configuration
nix eval .#darwinConfigurations.<SYSTEM>.config.system.build.toplevel  # Replace <SYSTEM> with actual system
```

### No Traditional Unit Tests:
- **Declarative validation**: Nix's type system prevents many errors
- **Build-time validation**: Configuration errors caught during build
- **Runtime validation**: System rebuild tests the complete configuration

## Performance Considerations

### Build Optimization:
- **Nix store**: Shared dependencies reduce rebuild times
- **Binary cache**: Use official caches for faster builds
- **Incremental builds**: Only changed modules rebuild

### Resource Management:
- **Garbage collection**: `nix-collect-garbage -d` to clean old generations
- **Store optimization**: `nix-store --optimize` to deduplicate files

## Working Together

- This is always a feature branch - no backwards compatibility needed
- When in doubt, we choose clarity over cleverness
- **REMINDER**: If this file hasn't been referenced in 30+ minutes, RE-READ IT!

Avoid complex abstractions or "clever" code. The simple, obvious solution is probably better, and my guidance helps you stay focused on what matters.
