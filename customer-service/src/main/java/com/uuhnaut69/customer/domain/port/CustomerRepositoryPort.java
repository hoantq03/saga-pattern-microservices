package com.uuhnaut69.customer.domain.port;

import com.uuhnaut69.customer.domain.entity.Customer;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface CustomerRepositoryPort {

  Optional<Customer> findCustomerById(UUID customerId);

  Customer saveCustomer(Customer customer);

  List<Customer> find();

  Long countAll();

  void removeAll();

  Page<Customer> findAll(Pageable pageable);

}
