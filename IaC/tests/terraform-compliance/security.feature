Feature: Security Compliance
  In order to ensure security best practices
  As a security engineer
  I want to verify the infrastructure configuration

  Scenario: Ensure Key Vault has soft delete enabled
    Given I have resource that supports soft delete
    When it has soft delete enabled
    Then it must have purge protection enabled

  Scenario: Ensure storage account has minimum TLS version
    Given I have resource that supports TLS
    When it has TLS configuration
    Then it must have minimum TLS version of 1.2

  Scenario: Ensure network security groups have restricted access
    Given I have resource that supports network security rules
    When it has inbound rules
    Then it must not have port 22 open
    And it must not have port 3389 open

  Scenario: Ensure private endpoints are used for sensitive services
    Given I have resource that supports private endpoints
    When it has network configuration
    Then it must have private endpoint enabled

  Scenario: Ensure diagnostic settings are enabled
    Given I have resource that supports diagnostic settings
    When it has monitoring configuration
    Then it must have diagnostic settings enabled
    And it must have log retention period of at least 30 days

  Scenario: Ensure tags are present
    Given I have resource that supports tags
    When it has tags
    Then it must have tag Environment
    And it must have tag Project
    And it must have tag Owner
    And it must have tag CostCenter 