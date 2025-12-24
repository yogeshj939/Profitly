package com.profitly.customer;

import com.profitly.business.Business;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Entity
@Table(name = "customer")
@Getter
@Setter
public class Customer {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "business_id")
  private Business business;

  private String name;
  private String mobile;
  private String email;

  @Column(name = "billing_address")
  private String billingAddress;

  private String gstin;

  @Column(name = "opening_balance")
  private BigDecimal openingBalance;

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
