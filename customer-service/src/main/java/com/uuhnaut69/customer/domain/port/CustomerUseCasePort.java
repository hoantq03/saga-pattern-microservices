package com.uuhnaut69.customer.domain.port;

import com.uuhnaut69.customer.domain.CustomerRequest;
import com.uuhnaut69.customer.domain.PlacedOrderEvent;
import com.uuhnaut69.customer.domain.entity.Customer;

import java.util.List;
import java.util.UUID;

import org.springframework.data.domain.Page;

public interface CustomerUseCasePort {

  Customer findById(UUID customerId);

  Customer create(CustomerRequest customerRequest);

  boolean reserveBalance(PlacedOrderEvent orderEvent);

  void compensateBalance(PlacedOrderEvent orderEvent);

  List<Customer> find();

  Long countAll();

  void deleteAll();

  Page<Customer> findAll(int page, int size);

}
