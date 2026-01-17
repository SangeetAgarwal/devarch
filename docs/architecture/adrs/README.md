# Architecture Decision Records

This folder contains Architecture Decision Records (ADRs) that document significant design decisions.

See the [ADR Guide](../../architecture-decision-records-guide.md) for how to write and use ADRs.

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [001](adr-001-database.md) | Use PostgreSQL for Primary Database | Accepted | 2025-01-15 |
| [007](adr-007-monetary-values.md) | Store Monetary Values as Integers | Accepted | 2025-02-01 |
| [012](adr-012-rest-api.md) | Use REST API for All Endpoints | Superseded | 2025-03-15 |

## By Category

### Data Storage
- [ADR-001](adr-001-database.md): Use PostgreSQL for Primary Database

### Data Modeling
- [ADR-007](adr-007-monetary-values.md): Store Monetary Values as Integers (Cents)

### API Design
- [ADR-012](adr-012-rest-api.md): Use REST API (Superseded by ADR-034)

---

## Adding New ADRs

### Using PowerShell Script (Recommended)

```powershell
.\scripts\New-ADR.ps1 -Title "decision-title"
```

This will:
- Auto-number the ADR (finds next available number)
- Generate comprehensive template
- Create Copilot prompt to help complete ADR
- Copy prompt to clipboard

### Manual Process

1. Copy the template from the [ADR Guide](../../architecture-decision-records-guide.md#adr-template)
2. Use the next available number (currently: ADR-013)
3. Add an entry to the index table above
4. Add to the appropriate category section

---

## ADR Workflow

### 1. Create ADR Before Implementation

```powershell
.\scripts\New-ADR.ps1 -Title "Use JWT for authentication"
```

### 2. Work with Copilot to Complete

The script generates a prompt that helps you:
- Define the context and problem
- State the decision clearly
- Document consequences
- List alternatives considered
- Add implementation notes

### 3. Update Index

Add the new ADR to this README:
- Add row to index table
- Add to appropriate category
- Include status and date

### 4. Reference in Code

Link to ADRs in:
- Implementation work summaries
- Code comments (for non-obvious decisions)
- Pull request descriptions
- Feature documentation

---

## Best Practices

1. **Write ADRs before implementing** - Document decisions, not implementations
2. **Focus on "why" not "what"** - Explain rationale, not just the choice
3. **Be honest about tradeoffs** - Document negative consequences too
4. **Include alternatives** - Show what else was considered
5. **Keep ADRs immutable** - Don't edit old decisions; supersede them
6. **Update status** - Mark as Superseded when decision changes

## Status Values

- **Proposed** - Decision under consideration
- **Accepted** - Decision approved and implemented
- **Deprecated** - No longer recommended but not replaced
- **Superseded** - Replaced by another ADR (reference the new one)

## Templates and Tools

- **PowerShell Script**: `scripts/New-ADR.ps1` - Automated ADR creation
- **Template**: See [ADR Guide](../../architecture-decision-records-guide.md#adr-template)
- **Examples**: Existing ADRs in this directory

---

## See Also

- [Architecture Decision Records Guide](../../architecture-decision-records-guide.md) - Detailed guide on writing ADRs
- [Copilot Workflow Guide](../../copilot-workflow-guide.md) - How to use ADRs in your workflow
- [Scripts README](../../../scripts/README.md) - Documentation for all PowerShell scripts
