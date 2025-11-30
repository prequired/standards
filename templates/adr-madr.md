---
id: "ADR-{SEQUENCE}"
title: "{Decision title (e.g., Selection of Message Queue Technology)}"
status: "{proposed | accepted | rejected | deprecated | superseded}"
date: YYYY-MM-DD
implements_requirement: "REQ-{DOMAIN}-{SEQUENCE}"
decision_makers: "{Names or roles}"
consulted: "{Names or teams consulted}"
informed: "{Stakeholders notified}"
supersedes: "{ADR-XXXX (if applicable)}"
superseded_by: "{ADR-YYYY (if applicable)}"
---

# ADR-{SEQUENCE}: {Decision Title}

## Context and Problem Statement

Describe the context and the specific problem or opportunity that necessitates this decision. Reference the requirement that drives this decision.

**Example:**
"[REQ-DATA-042](../docs/01-requirements/req-data-042.md) mandates real-time inventory updates across distributed warehouses. The current polling-based approach introduces 5-10 second delays, violating the requirement's fit criterion (<1 second latency)."

## Decision Drivers

List the forces, constraints, and priorities influencing this decision.

**Example:**
- **Performance:** Must support 10,000 messages/second at peak load.
- **Reliability:** Message delivery must be guaranteed (at-least-once semantics).
- **Cost:** Infrastructure budget capped at $500/month for messaging layer.
- **Developer Experience:** Team has existing expertise with RabbitMQ but no Kafka experience.
- **Compliance:** Must support message retention for audit purposes (90 days minimum).

## Considered Options

List all viable alternatives evaluated. Do not limit to two options; include all seriously considered approaches.

**Example:**
1. **Option A:** RabbitMQ (AMQP broker)
2. **Option B:** Apache Kafka (distributed event log)
3. **Option C:** AWS SQS + SNS (managed queue service)
4. **Option D:** Redis Pub/Sub (in-memory message bus)

## Decision Outcome

State the chosen option and the primary justification.

**Example:**
"**Chosen Option:** Option C (AWS SQS + SNS)

**Justification:** Managed service eliminates operational overhead (no cluster management). Meets performance requirements (14,000 msg/sec per queue) and cost constraints ($300/month projected). Lacks team expertise with RabbitMQ/Kafka, making managed service lower-risk. SQS provides at-least-once delivery and 14-day message retention (exceeds 90-day requirement when combined with archival to S3)."

### Consequences

#### Positive

List benefits and advantages of the chosen option.

**Example:**
- No infrastructure maintenance (AWS manages scaling, patching, availability).
- Native integration with existing AWS services (Lambda, S3, CloudWatch).
- Automatic scaling eliminates capacity planning.
- Cost predictable based on message volume (pay-per-use).

#### Negative

List drawbacks, trade-offs, and technical debt introduced.

**Example:**
- Vendor lock-in to AWS (migration to on-premises broker requires significant rework).
- Maximum message size limited to 256 KB (requires chunking for large payloads).
- Lack of message ordering guarantees in standard queues (FIFO queues have throughput limits).
- Team must learn AWS SDK and IAM permission model.

#### Risks

Identify potential failure modes and mitigation strategies.

**Example:**
- **Risk:** AWS region outage could halt all message processing.
  - **Mitigation:** Implement multi-region failover using SQS cross-region replication (ADR-0089).
- **Risk:** Message explosion during flash sales could exceed budget.
  - **Mitigation:** Configure CloudWatch billing alarms at $400/month threshold.

## Validation

Define how the success of this decision will be measured.

**Example:**
- **Metric 1:** 95th percentile message latency under 500ms (measured via CloudWatch metrics).
- **Metric 2:** Zero message loss during chaos engineering tests (quarterly).
- **Metric 3:** Infrastructure cost remains under $500/month for 6 months post-launch.

## Pros and Cons of the Options

### Option A: RabbitMQ

**Pros:**
- Team has 3 years production experience with RabbitMQ.
- Rich plugin ecosystem (federation, shovel, delayed exchange).
- Fine-grained control over routing and exchange topology.

**Cons:**
- Requires cluster management (Kubernetes StatefulSets, persistent volumes).
- Scaling requires manual intervention (adding nodes, rebalancing queues).
- On-call burden for monitoring and incident response.

### Option B: Apache Kafka

**Pros:**
- Horizontal scalability (proven at multi-petabyte scale).
- Strong ordering guarantees within partitions.
- Rich stream processing ecosystem (Kafka Streams, ksqlDB).

**Cons:**
- Operational complexity (ZooKeeper coordination, partition rebalancing).
- Steep learning curve (team has zero Kafka experience).
- Overkill for current scale (10,000 msg/sec achievable with simpler solutions).

### Option C: AWS SQS + SNS

*(See Decision Outcome section above for detailed analysis)*

### Option D: Redis Pub/Sub

**Pros:**
- Extremely low latency (sub-millisecond).
- Team already uses Redis for caching (operational familiarity).
- Simple API (PUBLISH/SUBSCRIBE commands).

**Cons:**
- No message persistence (messages lost if subscriber offline).
- No delivery guarantees (fire-and-forget semantics).
- Does not satisfy REQ-DATA-042 reliability requirement.

## Implementation Notes

Provide guidance for implementation teams.

**Example:**
- Use SQS FIFO queues for inventory deduction operations (strict ordering required).
- Configure Dead Letter Queue (DLQ) with 3 retry attempts before message quarantine.
- Implement exponential backoff in consumers (AWS SDK default retry policy).
- Document SQS IAM policies in `terraform/modules/messaging/policies.tf`.

## Links

Reference related documentation and external resources.

**Example:**
- [REQ-DATA-042](../docs/01-requirements/req-data-042.md) - Real-Time Inventory Sync Requirement
- [ARCH-INVENTORY-SERVICE](../docs/02-architecture/arch-inventory-service.md) - Section 5.3 (Messaging Layer)
- [AWS SQS Documentation](https://docs.aws.amazon.com/sqs/)
- [SOP-000: Golden Thread](../docs/00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| YYYY-MM-DD | {Author}     | Initial draft                          |
| YYYY-MM-DD | {Reviewer}   | Added validation metrics               |
| YYYY-MM-DD | {Architect}  | Status changed to accepted             |
