package com.profitly.business;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class BusinessService {

  private final BusinessRepository repository;

  public BusinessService(BusinessRepository repository) {
    this.repository = repository;
  }

  public Business getById(Long id) {
    return repository.findById(id)
        .orElseThrow(() -> new IllegalArgumentException("Business not found: " + id));
  }
}
