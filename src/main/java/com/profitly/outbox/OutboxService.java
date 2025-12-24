package com.profitly.outbox;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@Transactional
public class OutboxService {
  private final OutboxRepository outboxRepository;

  public OutboxService(OutboxRepository outboxRepository) {
    this.outboxRepository = outboxRepository;
  }

  /**
   * Create and persist an Outbox entry.
   * The Outbox UUID is generated inside this method.
   *
   * @param aggregateType type/name of the aggregate (e.g. "order")
   * @param aggregateId id of the aggregate
   * @param eventType event type/name (e.g. "ORDER_CREATED")
   * @param payload JSON payload for the event
   * @return persisted Outbox
   */
  @Transactional
  public Outbox createOutboxEvent(String aggregateType, String aggregateId, String eventType, String payload) {
    Outbox outbox = Outbox.builder()
        .id(UUID.randomUUID())
        .aggregateType(aggregateType)
        .aggregateId(aggregateId)
        .type(eventType)
        .payload(payload)
        .build();

    return outboxRepository.save(outbox);
  }

}
