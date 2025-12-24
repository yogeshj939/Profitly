package com.profitly.order;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.profitly.business.Business;
import com.profitly.business.BusinessService;
import com.profitly.customer.CustomerService;
import com.profitly.order.dto.CreateOrderRequest;
import com.profitly.outbox.OutboxService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Service
@Transactional
public class OrderService {

  private final OrderRepository orderRepository;
  private final OutboxService outboxService;
  private final BusinessService businessService;
  private final CustomerService customerService;

  public OrderService(OrderRepository orderRepository, OutboxService outboxService, BusinessService businessService, CustomerService customerService) {
    this.outboxService = outboxService;
    this.orderRepository = orderRepository;
    this.businessService = businessService;
    this.customerService = customerService;
  }

  /* ---------------- Create ---------------- */

  public Order createOrder(CreateOrderRequest createOrderRequest) {

    if (orderRepository.existsByOrderNumber(createOrderRequest.orderNumber())) {
      throw new IllegalArgumentException("Order number already exists: " + createOrderRequest.orderNumber());
    }

    final var order = Order.builder()
        .business(businessService.getById(createOrderRequest.businessId()))
        .customer(customerService.getById(createOrderRequest.customerId()))
        .orderNumber(createOrderRequest.orderNumber())
        .orderDate(LocalDate.now())
        .status(OrderStatus.DRAFT)
        .subtotalAmount(createOrderRequest.subtotal())
        .taxAmount(createOrderRequest.tax())
        .discountAmount(createOrderRequest.discount())
        .totalAmount(createOrderRequest.subtotal()
            .add((createOrderRequest.tax() != null ? createOrderRequest.tax() : BigDecimal.ZERO)
            .subtract(createOrderRequest.discount() != null ? createOrderRequest.discount() : BigDecimal.ZERO)))
        .notes(createOrderRequest.notes())
        .build();

    final var savedOrder = orderRepository.save(order);

    ObjectMapper objectMapper = new ObjectMapper();
    String outboxPayload = "";
    try {
      outboxPayload = objectMapper.writeValueAsString(createOrderRequest);
    } catch (JsonProcessingException e) {
      throw new RuntimeException(e);
    }

    outboxService.createOutboxEvent(
        "order",
        savedOrder.getId().toString(),
        "ORDER_CREATED",
        outboxPayload
    );

    return savedOrder;
  }

  /* ---------------- Read ---------------- */

  @Transactional(readOnly = true)
  public Order getById(Long id) {
    return orderRepository.findById(id)
        .orElseThrow(() -> new IllegalArgumentException("Order not found: " + id));
  }

  @Transactional(readOnly = true)
  public Order getByOrderNumber(String orderNumber) {
    return orderRepository.findByOrderNumber(orderNumber)
        .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderNumber));
  }

  @Transactional(readOnly = true)
  public List<Order> getOrdersForBusiness(Business business) {
    return orderRepository.findByBusiness(business);
  }

  /* ---------------- State Transitions ---------------- */

  public Order confirmOrder(Order order) {
    validateStatus(order, OrderStatus.DRAFT);
    order.setStatus(OrderStatus.CONFIRMED);
    return orderRepository.save(order);
  }

  public Order cancelOrder(Order order) {
    validateStatus(order, OrderStatus.DRAFT);
    order.setStatus(OrderStatus.CANCELLED);
    return orderRepository.save(order);
  }

  public Order completeOrder(Order order) {
    validateStatus(order, OrderStatus.CONFIRMED);
    order.setStatus(OrderStatus.COMPLETED);
    return orderRepository.save(order);
  }

  /* ---------------- Helpers ---------------- */

  private void validateStatus(Order order, OrderStatus expected) {
    if (order.getStatus() != expected) {
      throw new IllegalStateException(
          "Invalid state transition. Expected " + expected +
              " but was " + order.getStatus()
      );
    }
  }
}
