# PROCESS DISCIPLINE REQUIREMENTS

## Overview

This document defines **mandatory process checkpoints** to ensure consistent quality and prevent systematic failures. These are not suggestions - they are **blocking requirements**.

## Mandatory CLAUDE.md Checkpoints

**BEFORE ANY external dependency addition:**
1. State: "Checking CLAUDE-NIX.md requirements for package verification"
2. Run verification command: `nix search nixpkgs <package-name>`
3. Confirm package exists before proceeding
4. Only add verified packages

**BEFORE ANY commit:**
1. State: "Verifying CLAUDE.md forbidden patterns compliance"
2. Check all content for forbidden patterns
3. Verify professional communication standards
4. Confirm no emojis or Claude attribution

**BEFORE ANY Nix configuration change:**
1. State: "Following CLAUDE-NIX.md requirements"
2. Verify git state is committed
3. Run quality tools (alejandra, statix, deadnix)
4. Test with `sudo darwin-rebuild check --flake .#a2251`

## Context-Specific CLAUDE.md Re-reading

**Trigger points requiring documentation review:**

| Situation | Action Required |
|-----------|----------------|
| Adding external packages | Re-read CLAUDE-NIX.md package verification section |
| Making commits | Re-read CLAUDE.md forbidden patterns section |
| Working with Nix files | Re-read CLAUDE-NIX.md quality rules |
| Working with Home Manager | Re-read CLAUDE-NIX.md option verification requirements |

**Implementation:**
- Explicitly state: "Re-reading CLAUDE-NIX.md section X for this task"
- Quote relevant requirements before proceeding
- Treat as mandatory, not optional

## Verification Documentation Requirements

**For every external package:**
- State the verification method used
- Include the exact command run (e.g., "nix search nixpkgs selene")
- Confirm result shows package exists
- Document any version considerations

**For version-specific features:**
- State which documentation version was checked
- Include the URL/source referenced
- Confirm compatibility with current setup (nixpkgs 25.05 stable)

## Pre-Commit Validation Checklist

**Must be explicitly completed and stated before any commit:**

```
☐ Re-read CLAUDE.md forbidden patterns section
☐ All external packages verified via nix search
☐ No emojis in any content (code, comments, commit messages)
☐ No Claude attribution in commit messages
☐ All version-specific options verified against documentation
☐ Professional language throughout
☐ Nix files formatted with alejandra
☐ Nix files pass statix linting
☐ Git state committed before testing
```

**Enforcement**: State completion of each relevant item before proceeding with commit.

## Failure Recovery Protocol

**When requirements are missed:**

1. **Immediate acknowledgment**: "CLAUDE.md requirement X was not followed"
2. **Root cause analysis**: Why was the requirement skipped?
3. **Process improvement**: What checkpoint would have prevented this?
4. **Implementation**: Add that checkpoint to future workflows
5. **Fix and verify**: Correct the issue and verify compliance

**Example (luacheck incident):**
- Missed: Package verification requirement
- Root cause: Skipped CLAUDE-NIX.md consultation
- Prevention: Mandatory package verification statement
- Fix: Remove invalid package, add verified alternative

## Systematic Compliance Validation

**Self-monitoring questions (ask before each action):**
- "What CLAUDE.md requirements apply to this task?"
- "Have I consulted the relevant documentation?"
- "Am I following the documented process?"
- "Have I verified all external dependencies?"

**Accountability mechanism:**
- When requirements are missed, analyze WHY
- Update process to prevent the same failure mode
- Treat requirement violations as **system bugs** requiring fixes

## Enhanced Requirement Visibility

**Problem**: Critical requirements buried in long documentation
**Solution**: Extract into visible, actionable checkpoints

**Core requirements that must ALWAYS be checked:**
1. **Package verification** before adding any external dependency
2. **Version-specific documentation alignment** for all options
3. **Forbidden pattern compliance** in all content
4. **Professional communication standards** throughout

## Process Discipline Enforcement

**Mandatory statements (must be visible to user):**
- "Verifying package exists in nixpkgs before adding"
- "Checking CLAUDE.md forbidden patterns before commit"
- "Following CLAUDE-NIX.md testing requirements"
- "Confirming professional communication standards"

**Blocking nature**: Cannot proceed without completing verification steps.

**Success criteria**: All requirements systematically followed, failures prevented through process adherence.

## Continuous Improvement

**After each significant task:**
- Review process adherence
- Identify any missed checkpoints
- Update procedures to prevent future failures
- Strengthen systematic compliance

**Monthly review:**
- Analyze any requirement failures
- Strengthen weak points in the process
- Update documentation based on lessons learned