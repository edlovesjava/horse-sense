# Requirements Document: [Feature / Project Name]

> **Document version**: 1.0  
> **Created**: [Date]  
> **Last updated**: [Date]  
> **Owner**: [Name]  
> **Status**: Draft | In Review | Approved | Baselined

---

## 1. Background & Motivation

_Why are we building this? What problem does it solve for users?_

---

## 2. Stakeholders & User Roles

| Role | Description | Key Goals |
|---|---|---|
| [Role 1] | [Who they are] | [What they need] |
| [Role 2] | [Who they are] | [What they need] |

---

## 3. Functional Requirements

### 3.1 [Feature Area 1]

#### User Story: US-001
> As a **[role]**, I want to **[action]** so that **[benefit]**.

**Acceptance Criteria:**
```gherkin
Given [initial context]
When  [action is performed]
Then  [expected outcome]
And   [additional assertion]
```

**Priority**: Must Have | Should Have | Could Have | Won't Have  
**Story Points**: [1 / 2 / 3 / 5 / 8 / 13]  
**Notes**: [Any additional context or constraints]

---

#### User Story: US-002
> As a **[role]**, I want to **[action]** so that **[benefit]**.

**Acceptance Criteria:**
```gherkin
Given [initial context]
When  [action is performed]
Then  [expected outcome]
```

**Priority**: Must Have | Should Have | Could Have | Won't Have  
**Story Points**: [1 / 2 / 3 / 5 / 8 / 13]

---

### 3.2 [Feature Area 2]

#### User Story: US-010
> As a **[role]**, I want to **[action]** so that **[benefit]**.

**Acceptance Criteria:**
```gherkin
Given [initial context]
When  [action is performed]
Then  [expected outcome]
```

**Priority**: Must Have  
**Story Points**: [estimate]

---

## 4. Non-Functional Requirements

### 4.1 Performance
| Requirement | Metric | Target |
|---|---|---|
| API response time | p99 latency | < 200ms |
| Throughput | Requests/second | ≥ 500 rps |
| Page load | Time to interactive | < 2 seconds |

### 4.2 Availability & Reliability
| Requirement | Target |
|---|---|
| Uptime SLA | 99.9% (< 8.7 hours downtime/year) |
| Recovery Time Objective (RTO) | < 30 minutes |
| Recovery Point Objective (RPO) | < 1 hour |

### 4.3 Security
- Authentication: [e.g., OAuth 2.0 / JWT]
- Authorization: [e.g., role-based access control]
- Data encryption: [e.g., TLS in transit, AES-256 at rest]
- Compliance requirements: [e.g., GDPR, HIPAA, SOC 2]

### 4.4 Scalability
- Expected initial load: [N users / M requests/day]
- Expected peak load: [N users / M requests/day]
- Growth projection: [e.g., 2× per year]

### 4.5 Maintainability
- Code coverage minimum: 80%
- Linter compliance: zero warnings
- Dependency update policy: [e.g., monthly patch updates]

---

## 5. Constraints & Assumptions

### Constraints
- [Budget, timeline, technology, regulatory constraints]

### Assumptions
- [Things assumed to be true that have not been validated]

---

## 6. Out of Scope

The following are **explicitly excluded** from this requirements document:
- [Out-of-scope item 1]
- [Out-of-scope item 2]

---

## 7. Open Questions

| # | Question | Owner | Due Date | Resolution |
|---|---|---|---|---|
| 1 | [Question] | [Name] | [Date] | ⬜ Open |

---

## 8. Approval

| Stakeholder | Role | Date | Signature |
|---|---|---|---|
| [Name] | Product Owner | [Date] | ⬜ Pending |
| [Name] | Tech Lead | [Date] | ⬜ Pending |
