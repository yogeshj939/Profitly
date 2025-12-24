package com.profitly.outbox;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Entity
@Table(name = "outbox")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Outbox {
  @Id
  private UUID id;
  private String aggregateType;
  private String aggregateId;
  private String type;

  // We store the payload as a String for now (Hibernate maps JSONB to String easily)
  // In a real app, you might use a custom JSON type converter.
  @Column(columnDefinition = "jsonb")
  private String payload;
}
