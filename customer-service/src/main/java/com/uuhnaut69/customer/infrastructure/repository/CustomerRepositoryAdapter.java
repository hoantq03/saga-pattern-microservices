package com.uuhnaut69.customer.infrastructure.repository;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.uuhnaut69.customer.domain.entity.Customer;
import com.uuhnaut69.customer.domain.port.CustomerRepositoryPort;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@Repository
@RequiredArgsConstructor
public class CustomerRepositoryAdapter implements CustomerRepositoryPort {

  private final ObjectMapper mapper;

  private final CustomerJpaRepository customerJpaRepository;

  @Override
  public Optional<Customer> findCustomerById(UUID customerId) {
    var entity = customerJpaRepository.findById(customerId);
    return entity.map(customerEntity -> mapper.convertValue(customerEntity, Customer.class));
  }

  @Override
  public Customer saveCustomer(Customer customer) {
    var entity = mapper.convertValue(customer, CustomerEntity.class);
    customerJpaRepository.save(entity);
    return customer;
  }

  @Override
  public List<Customer> find() {
    return customerJpaRepository.findAll()
            .stream()
            .map(customerEntity -> mapper.convertValue(customerEntity, Customer.class))
            .collect(Collectors.toList());
  }

  @Override
  public Long countAll() {
    return customerJpaRepository.count();
  }

  @Override
  public void removeAll() {
    customerJpaRepository.deleteAll();
  }

  @Override
  public Page<Customer> findAll(Pageable pageable) {
      // 1. Gọi JpaRepository, nó sẽ tự động tạo câu lệnh SQL với LIMIT và OFFSET
      Page<CustomerEntity> customerEntityPage = customerJpaRepository.findAll(pageable);

      // 2. Chuyển đổi (map) từ Page<CustomerEntity> sang Page<Customer> (domain model)
      // Spring's Page object có sẵn hàm map rất tiện lợi
      return customerEntityPage.map(customerEntity -> mapper.convertValue(customerEntity, Customer.class));
  }
}
