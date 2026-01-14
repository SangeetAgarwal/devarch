# DevArch

Software development and architecture guidance for the modern era — where AI is your pair programming partner.

## About

This repository contains practical guidance for software developers and architects, with a particular focus on effective workflows when collaborating with generative AI tools like Claude Code, GitHub Copilot, and similar assistants.

The patterns here emerged from real-world project experience, not theory. They address the actual challenges developers face when integrating AI into their daily workflow.

## Why This Exists

AI-assisted development is powerful but introduces new challenges:

- **Context limitations** — AI tools have finite memory and lose context
- **Session continuity** — Work spans multiple sessions; AI doesn't remember
- **Decision traceability** — "Why did we do it this way?" gets lost
- **Knowledge transfer** — Onboarding AI to your codebase takes effort

Traditional development practices don't fully address these issues. This repo provides patterns that do.

## Contents

### Guides

| Guide | Description |
|-------|-------------|
| [Claude Code Workflow Guide](docs/claude-code-workflow-guide.md) | Productive AI-assisted development sessions, context management, documentation patterns |
| [AWS Serverless Backend Guide](docs/aws-serverless-backend-guide.md) | Let Claude build your API: Lambda, API Gateway, DynamoDB, custom domains, hardening |
| [Architecture Decision Records](docs/architecture-decision-records-guide.md) | When and how to document design decisions with ADRs |

### Key Topics Covered

- **Context management** — Strategies for working within AI context limits
- **Session summaries** — Maintaining continuity across sessions
- **Work documentation** — Patterns for preserving decisions and progress
- **Project organization** — Folder structures that work with AI tools
- **Hooks and automation** — Reducing manual overhead

## Philosophy

1. **Documentation is memory** — What you write down survives; what stays in AI context doesn't
2. **Progressive capture** — Document as you go, not at the end
3. **Branch = Work folder** — Keep related artifacts together
4. **Explicit over implicit** — AI works better with clear structure and instructions

## Contributing

Found a pattern that works well? Have improvements to suggest? Contributions are welcome.

## License

MIT

---

*These patterns evolved from building [Sharpee](https://github.com/ChicagoDave/sharpee), a parser-based interactive fiction engine, using AI-assisted development.*
