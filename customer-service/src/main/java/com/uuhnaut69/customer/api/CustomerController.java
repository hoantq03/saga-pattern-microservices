package com.uuhnaut69.customer.api;

import com.uuhnaut69.customer.domain.CustomerRequest;
import com.uuhnaut69.customer.domain.entity.Customer;
import com.uuhnaut69.customer.domain.port.CustomerUseCasePort;
import jakarta.validation.Valid;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.domain.Page;

@RestController
@RequiredArgsConstructor
@RequestMapping("/customers")
public class CustomerController {

  private final CustomerUseCasePort customerUseCase;

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public Customer create(@RequestBody @Valid CustomerRequest customerRequest) {
    return customerUseCase.create(customerRequest);
  }

  @GetMapping("/count-all")
  public Long countAll() {
    return customerUseCase.countAll();
  }

  @GetMapping("/{customerId}")
  public Customer findById(@PathVariable UUID customerId) {
    return customerUseCase.findById(customerId);
  }


    @GetMapping
    public ResponseEntity<Page<Customer>> getAllCustomers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        Page<Customer> customersPage = customerUseCase.findAll(page, size);
        return ResponseEntity.ok(customersPage);
    }

  @DeleteMapping()
  public void deleteAllCustomers() {
    customerUseCase.deleteAll();
  }
}
