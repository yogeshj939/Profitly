package com.profitly.outbox;

import jakarta.persistence.EntityManager;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Repository
public class OutboxRepository {

  private final EntityManager entityManager;

  public OutboxRepository(EntityManager entityManager) {
    this.entityManager = entityManager;
  }

  @Transactional
  public Outbox save(Outbox outbox) {
    if (outbox == null) {
      throw new IllegalArgumentException("outbox must not be null");
    }
    if (outbox.getId() == null) {
      outbox.setId(UUID.randomUUID());
    }
    return entityManager.merge(outbox);
  }
}
