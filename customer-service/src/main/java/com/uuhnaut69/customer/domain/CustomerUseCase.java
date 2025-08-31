package com.uuhnaut69.customer.domain;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.uuhnaut69.customer.domain.entity.Customer;
import com.uuhnaut69.customer.domain.exception.NotFoundException;
import com.uuhnaut69.customer.domain.port.CustomerRepositoryPort;
import com.uuhnaut69.customer.domain.port.CustomerUseCasePort;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;

import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@Service
@Transactional
@RequiredArgsConstructor
public class CustomerUseCase implements CustomerUseCasePort {

  private final ObjectMapper mapper;

  private final CustomerRepositoryPort customerRepository;

  @Override
  public Customer findById(UUID customerId) {
    return customerRepository.findCustomerById(customerId).orElseThrow(NotFoundException::new);
  }

  @Override
  public Customer create(CustomerRequest customerRequest) {
    var customer = mapper.convertValue(customerRequest, Customer.class);
    customer.setId(UUID.randomUUID());
    return customerRepository.saveCustomer(customer);
  }

  @Override
  public boolean reserveBalance(PlacedOrderEvent orderEvent) {
    var customer = findById(orderEvent.customerId());
    if (customer
        .getBalance()
        .subtract(orderEvent.price().multiply(BigDecimal.valueOf(orderEvent.quantity())))
        .compareTo(BigDecimal.ZERO)
        < 0) {
      return false;
    }
    customer.setBalance(
        customer
            .getBalance()
            .subtract(orderEvent.price().multiply(BigDecimal.valueOf(orderEvent.quantity()))));
    customerRepository.saveCustomer(customer);
    return true;
  }

  @Override
  public void compensateBalance(PlacedOrderEvent orderEvent) {
    var customer = findById(orderEvent.customerId());
    customer.setBalance(
        customer
            .getBalance()
            .add(orderEvent.price().multiply(BigDecimal.valueOf(orderEvent.quantity()))));
    customerRepository.saveCustomer(customer);
  }

  @Override
  public Long countAll() {
    return customerRepository.countAll();
  }

  @Override
  public void deleteAll() {
      customerRepository.removeAll();
  }


  @Override
  public List<Customer> find() {
    return customerRepository.find();
  }

  @Override
    public Page<Customer> findAll(int page, int size) {
        // Tạo một đối tượng Pageable từ thông tin trang và kích thước
        Pageable pageable = PageRequest.of(page, size);
        
        // Gọi đến port để lấy dữ liệu. Lớp UseCase không cần biết việc
        // phân trang được thực hiện bằng JpaRepository hay một công nghệ nào khác.
        return customerRepository.findAll(pageable);
    }
}
