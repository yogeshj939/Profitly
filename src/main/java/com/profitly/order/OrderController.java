package com.profitly.order;

import com.profitly.order.dto.CreateOrderRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

  private final OrderService orderService;

  public OrderController(OrderService orderService) {
    this.orderService = orderService;
  }

  @PostMapping(path = "/create", consumes = "application/json"
  )
  public ResponseEntity<Order> createOrder(
      @RequestBody CreateOrderRequest request
  ) {
    Order order = orderService.createOrder(request);
    return ResponseEntity.ok(order);
  }
}

