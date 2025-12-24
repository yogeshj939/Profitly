package com.profitly.order;

import com.profitly.business.Business;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Long> {

  Optional<Order> findByOrderNumber(String orderNumber);

  List<Order> findByBusiness(Business business);

  boolean existsByOrderNumber(String orderNumber);
}
