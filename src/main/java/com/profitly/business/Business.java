package com.profitly.business;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.OffsetDateTime;

@Entity
@Table(name = "business")
@Getter
@Setter
public class Business {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  private String name;
  private String address;
  private String gstin;
  private String currency;
  private String timezone;

  @Column(name = "created_at", updatable = false)
  private OffsetDateTime createdAt;

  @Column(name = "last_updated")
  private OffsetDateTime lastUpdated;

  @PrePersist
  void onCreate() {
    createdAt = lastUpdated = OffsetDateTime.now();
  }

  @PreUpdate
  void onUpdate() {
    lastUpdated = OffsetDateTime.now();
  }
}
