package com.profitly.order;

import com.profitly.customer.Customer;
import com.profitly.business.Business;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;

@Data
@Entity
@Table(name = "orders")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(optional = false)
  @JoinColumn(name = "business_id")
  private Business business;

  @ManyToOne(optional = false)
  @JoinColumn(name = "customer_id")
  private Customer customer;

  @Column(name = "order_number", nullable = false, unique = true)
  private String orderNumber;

  @Column(name = "order_date", nullable = false)
  private LocalDate orderDate;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private OrderStatus status;

  @Column(name = "subtotal_amount", nullable = false, precision = 15, scale = 2)
  private BigDecimal subtotalAmount;

  @Column(name = "tax_amount", precision = 15, scale = 2)
  private BigDecimal taxAmount;

  @Column(name = "discount_amount", precision = 15, scale = 2)
  private BigDecimal discountAmount;

  @Column(name = "total_amount", nullable = false, precision = 15, scale = 2)
  private BigDecimal totalAmount;

  @Column(columnDefinition = "TEXT")
  private String notes;

  @Column(name = "created_at", nullable = false, updatable = false)
  private OffsetDateTime createdAt;

  @Column(name = "last_updated", nullable = false)
  private OffsetDateTime lastUpdated;

  /* ---------- Lifecycle hooks ---------- */

  @PrePersist
  protected void onCreate() {
    OffsetDateTime now = OffsetDateTime.now();
    this.createdAt = now;
    this.lastUpdated = now;
  }

  @PreUpdate
  protected void onUpdate() {
    this.lastUpdated = OffsetDateTime.now();
  }

  /* ---------- Getters & Setters ---------- */

  // Generate getters/setters (IntelliJ / Lombok optional)
}
