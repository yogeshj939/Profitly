package com.profitly.order.dto;

import java.math.BigDecimal;

public record CreateOrderRequest(Long businessId, Long customerId, String orderNumber, BigDecimal subtotal,
                                 BigDecimal tax, BigDecimal discount, String notes) {
}