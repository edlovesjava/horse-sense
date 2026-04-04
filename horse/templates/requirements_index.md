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

## 3. Functional Requirements — Story Index

> Individual stories are stored in `docs/requirements/stories/`.
> Each file follows the `user_story.md` template with YAML frontmatter.

### 3.1 [Feature Area 1]

| ID | Title | Priority | Points | Status |
|---|---|---|---|---|
| [US-001](stories/US-001-<title>-<status>.md) | [Title] | Must Have | [pts] | draft |
| [US-002](stories/US-002-<title>-<status>.md) | [Title] | Should Have | [pts] | draft |

### 3.2 [Feature Area 2]

| ID | Title | Priority | Points | Status |
|---|---|---|---|---|
| [US-010](stories/US-010-<title>-<status>.md) | [Title] | Must Have | [pts] | draft |

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
- Growth projection: [e.g., 2x per year]

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
| 1 | [Question] | [Name] | [Date] | Open |

---

## 8. Approval

| Stakeholder | Role | Date | Signature |
|---|---|---|---|
| [Name] | Product Owner | [Date] | Pending |
| [Name] | Tech Lead | [Date] | Pending |
