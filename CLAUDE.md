# Development Partnership

We're building production-quality code together. Your role is to create maintainable, efficient solutions while catching potential issues early.

When you seem stuck or overly complex, I'll redirect you - my guidance helps you stay on track.

**IMPORTANT**: This is the main entry point. For specific domains, see:
- **[CLAUDE-NIX.md](./CLAUDE-NIX.md)** - Nix configuration requirements (MANDATORY before any Nix work)
- **[CLAUDE-PROCESS.md](./CLAUDE-PROCESS.md)** - Process discipline and compliance requirements

## CRITICAL WORKFLOW - ALWAYS FOLLOW THIS

### Research → Plan → Implement

**NEVER JUMP STRAIGHT TO CODING!** Always follow this sequence:

1. **Research**: Explore the codebase, understand existing patterns
2. **Plan**: Create a detailed implementation plan and verify it with me  
3. **Implement**: Execute the plan with validation checkpoints

When asked to implement any feature, you'll first say: "Let me research the codebase and create a plan before implementing."

### USE TASK DELEGATION

Break complex tasks into focused investigations. Use systematic workflows for comprehensive analysis.

### Enhanced Reality Checkpoints

**Stop and validate** at these moments:
- After implementing a complete feature
- Before starting a new major component
- When something feels wrong
- Before declaring "done"
- **Before implementing external interfaces**: Verify all APIs/options exist in YOUR version

### Reference Materials

**Example Configuration**: A complete example Nix configuration from ryan4yin is available in `examples/ryan4yin/` for reference and learning. Use this local copy instead of reading from the remote repository when studying configuration patterns, module organization, or implementation approaches.

### Nix Flake Testing Requirements

**CRITICAL**: Before testing any Nix flake configuration changes, ALL modified files must be added to Git. Nix flakes only see files that are tracked by Git. Use `git add .` to stage all changes before running `nix flake check`, `just check`, or any rebuild commands.

### Nix Warnings Are BLOCKING

**ALL warnings from `nix flake check` are treated as errors and MUST be fixed immediately.**

- Deprecation warnings indicate APIs that will break in future releases
- Evaluation warnings indicate configuration issues that need attention
- **DO NOT** ignore warnings or defer them to "future cleanup"
- **DO NOT** commit code that produces warnings
- Fix ALL warnings before proceeding with any other work

When you see warnings like:
- `has been renamed to` - Update to the new option name immediately
- `will be removed in the future` - Migrate to the new API immediately
- `default values will be removed` - Explicitly configure the values you need

## UNIVERSAL FORBIDDEN PATTERNS

**MANDATORY STATEMENT**: Before any commit/PR, say: "I have verified this follows all forbidden patterns in CLAUDE.md"

### FORBIDDEN in ALL content (code, comments, documentation, commit messages):

- **NO emojis** anywhere
- **NO Claude attribution** ("Generated with Claude Code", "Co-Authored-By: Claude", etc.)
- **NO** keeping old and new code together - delete when replacing  
- **NO** TODOs in final production code
- **NO** hardcoded secrets or API keys
- **NO** broad exception catching without specific handling
- **NO** modifying Neovim keybindings without updating WhichKey descriptions

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

## Professional Communication Standards

### All Communication Must Be:
- **Technical focus** - Describe functionality, usage, and architecture
- **Clear and factual** - No emojis, professional tone
- **Developer perspective** - No AI/Claude references
- **Structured** - Clear examples and maintenance notes

### Code Comments:
- **Explain why, not what** - Focus on reasoning and context
- **Document decisions** - Explain architectural choices and trade-offs
- **Future context** - Help your future self understand the code

## Test-Driven Development Protocol

**"Write the test, let AI satisfy the contract"**

### The TDD-AI Feedback Loop:
1. **RED**: Write a failing test that defines the exact behavior
2. **GREEN**: Let AI implement the minimal code to pass
3. **REFACTOR**: Improve design with test safety net

### TDD Learning Objectives:
- **Requirements Clarity**: Tests force precise thinking about behavior
- **Interface Design**: Write tests for the API you want to use
- **Regression Protection**: Changes can't break existing behavior

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

## Technical Mastery Progression

### Universal Mastery Areas to Track:
- **System Design & Architecture**: Novice → Intermediate → Advanced → Expert
- **Error Handling Patterns**: Novice → Intermediate → Advanced → Expert  
- **Testing & Quality Assurance**: Novice → Intermediate → Advanced → Expert
- **Performance & Optimization**: Novice → Intermediate → Advanced → Expert
- **Security Best Practices**: Novice → Intermediate → Advanced → Expert
- **Test-Driven Development**: Novice → Intermediate → Advanced → Expert

## Neovim Configuration Standards

### WhichKey Maintenance Protocol

When modifying Neovim keybindings in `neovim.nix`:

1. **ALWAYS update `lua/plugins/which-key.lua`** with corresponding descriptions
2. **Maintain group organization** - keep related keybindings grouped
3. **Use clear, descriptive names** for each keybinding
4. **Test WhichKey display** after changes to ensure accuracy

### Example WhichKey Entry:
```lua
{ "<leader>wv", desc = "Split vertically" },
{ "<leader>w", group = "Window Management" },
```

## Working Together

- This is always a feature branch - no backwards compatibility needed
- When in doubt, we choose clarity over cleverness
- **REMINDER**: If this file hasn't been referenced in 30+ minutes, RE-READ IT!

Avoid complex abstractions or "clever" code. The simple, obvious solution is probably better, and my guidance helps you stay focused on what matters.