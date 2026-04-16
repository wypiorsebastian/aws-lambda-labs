# Lab Authoring Standards

When generating labs, runbooks, or implementation guides:

- Verify every provider-specific claim in official documentation before stating it as fact.
- Do not present project decisions or simplifications as platform requirements.
- Choose one exact implementation variant per lab and keep text, code, IaC, commands, and validation fully consistent with it.
- Make all critical defaults explicit: region, runtime, architecture, payload format, stage model, deployment mechanism, naming, and ownership of auto-created resources.
- Every lab must include:
  - goal
  - assumptions
  - architectural decisions
  - step-by-step execution
  - validation
  - failure modes
  - cleanup
  - official sources
- Auto-created cloud resources must have explicit ownership: platform-managed or Terraform-managed.
- Final runbooks must be runnable end-to-end or explicitly marked as draft/spec.