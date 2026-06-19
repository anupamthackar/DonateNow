# Save Token Protocol — DonateNow v2.0

> Purpose: Optimize AI-agent communication to minimize token usage.
> Version: 2.0
> Previous: [v1.0 Save_Token](../../v1.0/Save_Token.mdc)
> Reference: [Project_Boundaries.mdc](./Project_Boundaries.mdc)

---

## Vibe Coding Protocol

1. **Use short-form responses.**
   - No lengthy explanations unless asked.
   - Get to the point.

2. **Avoid conversational filler.**
   - No "Sure!", "Great question!", "Let me help you with that."
   - Start with the answer or action.

3. **Return only diffs or modified functions.**
   - Don't return entire files when editing one method.
   - Show only changed code blocks.

4. **Do not update unrelated files.**
   - Scope to requested changes only.
   - If fixing `CampaignRepository.swift`, don't touch `MarketplaceView.swift`.

5. **Use compact code style.**
   - Minimal but readable Swift/TypeScript.
   - No excessive comments.
   - Comments only for non-obvious logic.

6. **Minimize token usage.**
   - Tables over paragraphs.
   - Bullet points over prose.
   - Code blocks over descriptions.

7. **Focus only on requested changes.**
   - Don't refactor unless asked.
   - Don't suggest improvements unless asked.
   - Don't add features beyond the request.

8. **Reference context files instead of repeating content.**
   - Say "per PRD v2.0 Section 4" instead of re-explaining Edge Function contracts.
   - Say "per KPI-2-014" instead of re-describing receipt generation targets.
   - Say "per Database_Changes.mdc → donation_profiles" instead of repeating schema.

9. **Ask before refactoring.**
   - Never refactor existing code without explicit request.
   - Refactoring is a separate task.

10. **Generate diffs whenever possible.**
    - For small edits, show diff format.
    - For new files, show full content.

11. **Reference v2.0 context first.**
    - Always check v2.0 documents before v1.0.
    - v2.0 overrides v1.0 where conflicts exist.

---

## Response Format Guidelines

### For Code Changes
```
File: DonateNow/Services/CampaignRepository.swift
Change: Added campaign search with filter support

+ func searchCampaigns(query: String, category: String?) async throws -> [DonationProfile] {
+     var request = supabase.from("donation_profiles").select()
+     // ... implementation
+ }
```

### For Questions
```
Question: How should campaign progress update?
Answer: Auto-update via DB trigger on donations table — per Database_Changes.mdc Section 7
```

### For Feature Implementation
```
Feature: F2-07 — Donation Marketplace
KPIs: KPI-2-006, KPI-2-007, KPI-2-008, KPI-2-009
TDD: TC-2-019 through TC-2-025
Files:
  - DonateNow/Views/Marketplace/MarketplaceView.swift (new)
  - DonateNow/ViewModels/MarketplaceViewModel.swift (new)
  - DonateNow/Services/CampaignSearchService.swift (new)
```

---

## Token Budget Awareness

| Action Type | Expected Tokens | Approach |
|---|---|---|
| Bug fix | < 200 tokens | Diff only |
| New View / ViewModel | < 600 tokens | Full file |
| New Edge Function | < 500 tokens | Full file |
| New Repository/Service | < 400 tokens | Full file |
| Architecture question | < 100 tokens | Reference context file |
| Multi-file change | < 1000 tokens | Diffs per file |
| Migration script | < 300 tokens | Full SQL |
| Test case implementation | < 400 tokens | Full test file |
