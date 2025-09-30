# **Use case 5- B2B deal**

This section covers B2B (Business-to-Business) charging scenarios where fleet operators and corporate customers have pre-negotiated commercial agreements with Charge Point Operators for preferential pricing and terms.

> **Note**: For general Beckn message flow and error handling, please refer to the [Overview](./0_Overview.md) section.

## **B2B Deal Scenarios**

### **Fleet Operator Agreement**

**Scenario:** A logistics company has a corporate agreement with multiple CPOs for their delivery fleet. The agreement includes:
- 15% discount on all charging sessions
- Priority access to charging slots
- Monthly billing with net-30 payment terms
- Dedicated account manager support

### **Corporate Employee Program**

**Scenario:** A large corporation provides EV charging benefits to employees. The program includes:
- Company-subsidized charging rates
- Usage tracking and reporting
- Integration with HR systems
- Monthly expense allocation

## **User Journey**

### **Loyalty Program and Authorization Process**

The system handles two different scenarios for loyalty programs and authorization:

### **Example 1: Individual Customer Approach**

1. User provides their mobile number in the billing details
2. The BPP MAY check the user's registered mobile number to identify any active loyalty programs attached to it
3. If loyalty programs are found, the BPP SHOULD automatically adjust discounts in the quote based on the customer's loyalty status
4. This approach provides seamless discount application without requiring additional user input

### **Example 2: B2B Fleet Approach**

1. B2B deals typically happen offline, where fleet operators and CPOs (Charge Point Operators) establish commercial agreements outside of the Beckn protocol
2. Fleet drivers MAY choose an option indicating they have a B2B loyalty program
3. The fleet driver MUST provide an OTP received from the BPP on their registered mobile number
4. The BPP SHALL validate the OTP and adjust the final quote based on the B2B loyalty program benefits
5. This approach ensures fleet-specific pricing and discounts are applied correctly

> **Note:** These are example implementation approaches. Different networks MAY choose alternative methods for loyalty program integration, such as QR code scanning, app-based authentication, RFID cards, or other identification mechanisms depending on their technical infrastructure and business requirements.


## **API Implementation**

### **B2B Authentication in Init Call**

The B2B agreement is typically referenced during the init call through billing information. BAP sends user phone number in the billing details.

```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "init",
    "location": {
      "country": {
        "code": "IND"
      },
      "city": {
        "code": "std:080"
      }
    },
    "version": "1.1.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "15S"
  },
  "message": {
    "order": {
      "provider": {
        "id": "cpo1.com"
      },
      "items": [
        {
          "id": "pe-charging-01",
		      "quantity": {
              "selected": {
                  "measure": {
                     "type": "CONSTANT",
                     "value": "100",
                     "unit": "INR"
                  }
              }
          }
        }
      ],
      "billing": {
        "name": "Ravi Kumar",
        "organization": {
          "descriptor": {
            "name": "GreenCharge Pvt Ltd"
          }
        },
        "address": "Apartment 123, MG Road, Bengaluru, Karnataka, 560001, India",
        "state": {
          "name": "Karnataka"
        },
        "city": {
          "name": "Bengaluru"
        },
        "email": "ravi.kumar@greencharge.com",
        "phone": "+918765432100",
        "time": {
          "timestamp": "2025-07-30T12:02:00Z"
        },
        "tax_id": "GSTIN29ABCDE1234F1Z5"
      },
      "fulfillments": [
        {
          "id": "1",
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2025-09-16T10:00:00+05:30"
              }
            },
            {
              "type": "STOP",
              "time": {
                "timestamp": "2025-09-16T11:30:00+05:30"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          },
          "customer": {
            "person": {
              "name": "Ravi Kumar"
            },
            "contact": {
              "phone": "+91-9887766554"
            }
          }
        }
      ],
      "tags": [
        {
          "descriptor": {
            "code": "buyer-finder-fee"
          },
          "list": [
            {
              "descriptor": {
                "code": "type"
              },
              "value": "PERCENTAGE"
            },
            {
              "descriptor": {
                "code": "value"
              },
              "value": "2"
            }
          ]
        }
      ]
    }
  }
}

```

### **B2B Response in on_init**

BPP uses the user provided mobile number in from the billing details to look for any customer loyalty program and apply that in the charging session quotation.

The BPP responds with pricing and terms, including corporate billing arrangements and negotiated discounts.

If authorization is required for confirming the order, the BPP will share message.order.fulfillments[].stops[].authorization.type with the type of authorization that would be required. The BAP will get the authorization data from the user and transmit the same in confirm API.

```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "on_init",
    "location": {
      "country": {
        "code": "IND"
      },
      "city": {
        "code": "std:080"
      }
    },
    "version": "1.1.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "15S"
  },
  "message": {
    "order": {
      "provider": {
        "id": "cpo1.com",
        "descriptor": {
          "name": "CPO1 EV charging Company",
          "short_desc": "CPO1 provides EV charging facility across India",
          "images": [
            {
              "url": "https://cpo1.com/images/logo.png"
            }
          ]
        }
      },
      "items": [
        {
          "id": "pe-charging-01",
          "descriptor": {
            "name": "EV Charger #1 (AC Fast Charger)",
            "code": "ev-charger"
          },
          "price": {
            "value": "18",
            "currency": "INR/kWh"
          },
	    "quantity": {
              "selected": {
                  "measure": {
                     "type": "CONSTANT",
                     "value": "100",
                     "unit": "INR"
                  }
              }
          },
          "tags": [
            {
              "descriptor": {
                "code": "connector-specifications",
                "name": "Connector Specifications"
              },
              "list": [
                {
                  "descriptor": {
                    "name": "connector Id",
                    "code": "connector-id"
                  },
                  "value": "1"
                },
                {
                  "descriptor": {
                    "name": "Power Type",
                    "code": "power-type"
                  },
                  "value": "AC_3_PHASE"
                },
                {
                  "descriptor": {
                    "name": "Connector Type",
                    "code": "connector-type"
                  },
                  "value": "CCS2"
                },
                {
                  "descriptor": {
                    "name": "Connector Format",
                    "code": "connector-format"
                  },
                  "value": "SOCKET"
                },
                {
                  "descriptor": {
                    "name": "Charging Speed",
                    "code": "charging-speed"
                  },
                  "value": "FAST"
                },
                {
                  "descriptor": {
                    "name": "Power Rating",
                    "code": "power-rating"
                  },
                  "value": "30kW"
                },
                {
                  "descriptor": {
                    "name": "Status",
                    "code": "status"
                  },
                  "value": "Available"
                }
              ]
            }
          ]
        }
      ],
      "fulfillments": [
        {
          "id": "fulfillment-001",
          "type": "CHARGING",
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2023-07-16T10:00:00+05:30"
              },
              "location": {
                "gps": "28.345345,77.389754",
                "descriptor": {
                  "name": "BlueCharge Connaught Place Station"
                },
                "address": "Connaught Place, New Delhi"
              },
              "instructions": {
                "short_desc": "OTP will be shared to the user's registered number to confirm order"
              }
              "authorization": {
                "type": "OTP"
              },
            },
            {
              "type": "STOP",
              "time": {
                "timestamp": "2025:09:24:11:00:00"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          },
          "customer": {
            "person": {
              "name": "Ravi Kumar"
            },
            "contact": {
              "phone": "+91-9887766554"
            }
          }
        }
      ],
      "quote": {
        "price": {
          "value": "90",
          "currency": "INR"
        },
        "breakup": [
          {
            "title": "Charging session cost (5 kWh @ ₹18.00/kWh)",
            "item": {
              "id": "pe-charging-01"
            },
            "price": {
              "value": "90",
              "currency": "INR"
            }
          },
          {
            "title": "Service fee",
            "price": {
              "currency": "INR",
              "value": "10"
            }
          },
          {
            "title": "loyalty program discount",
            "price": {
              "currency": "INR",
              "value": "10"
            }
          }
        ]
      },
      "billing": {
        "name": "Ravi Kumar",
        "organization": {
          "descriptor": {
            "name": "GreenCharge Pvt Ltd"
          }
        },
        "address": "Apartment 123, MG Road, Bengaluru, Karnataka, 560001, India",
        "state": {
          "name": "Karnataka"
        },
        "city": {
          "name": "Bengaluru"
        },
        "email": "ravi.kumar@greencharge.com",
        "phone": "+918765432100",
        "time": {
          "timestamp": "2025-07-30T12:02:00Z"
        },
        "tax_id": "GSTIN29ABCDE1234F1Z5"
      },
      "payments": [
        {
          "id": "payment-123e4567-e89b-12d3-a456-426614174000",
          "collected_by": "BPP",
          "url": "https://payments.bluechargenet-aggregator.io/pay?transaction_id=$transaction_id&amount=$amount",
          "params": {
            "amount": "90.00",
            "currency": "INR",
            "bank_code": "HDFC000123",
            "bank_account_number": "1131324242424"
          },
          "type": "PRE-FULFILLMENT",
          "status": "NOT-PAID",
          "time": {
            "timestamp": "2025-07-30T14:59:00Z"
          },
          "tags": [
            {
              "descriptor": {
                "code": "payment-methods"
              },
              "list": [
                {
                  "descriptor": {
                    "code": "BANK-TRANSFER",
                    "short_desc": "Pay by transferring to a bank account"
                  }
                },
                {
                  "descriptor": {
                    "code": "PAYMENT-LINK",
                    "short_desc": "Pay through a bank link received"
                  }
                },
                {
                  "descriptor": {
                    "code": "UPI-TRANSFER",
                    "short_desc": "Pay by setting a UPI mandate"
                  }
                }
              ]
            }
          ]
        }
      ],
      "refund_terms": [
        {
          "fulfillment_state": {
            "descriptor": {
              "name": "Order Confirmed",
              "code": "CONFIRMED",
              "long_desc": "85% refund available if cancelled at least 4 hours before the scheduled charging time"
            }
          },
          "refund_eligible": true,
          "refund_within": {
            "duration": "PT2H"
          },
          "refund_amount": {
            "currency": "INR",
            "value": "85"
          }
        },
        {
          "fulfillment_state": {
            "descriptor": {
              "name": "Charging Active",
              "code": "ACTIVE"
            }
          },
          "refund_eligible": false
        }
      ]
    }
  }
}
```

### **B2B Confirmation and Session Management**

#### **Authorization Token Requirement**

* Users MUST provide the required authorization token in the confirm call to facilitate the B2B deal discounts
* Users MAY receive these authorization tokens through various off-network channels including:
  - SMS notifications
  - Email communications
  - Mobile application notifications
  - Other designated communication channels
* The BAP SHALL include the authorization token in the `fulfillments[].stops[].authorization.token` field
* The BPP MUST validate the authorization token before processing the B2B discount

The confirm and subsequent API calls work similarly to regular charging sessions, but with B2B-specific billing and reporting features.

```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "confirm",
    "location": {
      "country": {
        "code": "IND"
      },
      "city": {
        "code": "std:080"
      }
    },
    "version": "1.1.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "15S"
  },
  "message": {
    "order": {
      "provider": {
        "id": "cpo1.com"
      },
      "items": [
        {
          "id": "pe-charging-01",
		      "quantity": {
              "selected": {
                  "measure": {
                     "type": "CONSTANT",
                     "value": "100",
                     "unit": "INR"
                  }
              }
          }
        }
      ],
      "billing": {
        "name": "Ravi Kumar",
        "organization": {
          "descriptor": {
            "name": "GreenCharge Pvt Ltd"
          }
        },
        "address": "Apartment 123, MG Road, Bengaluru, Karnataka, 560001, India",
        "state": {
          "name": "Karnataka"
        },
        "city": {
          "name": "Bengaluru"
        },
        "email": "ravi.kumar@greencharge.com",
        "phone": "+918765432100",
        "time": {
          "timestamp": "2025-07-30T12:02:00Z"
        },
        "tax_id": "GSTIN29ABCDE1234F1Z5"
      },
      "fulfillments": [
        {
          "id": "fulfillment-001",
          "stops": [
            {
              "type": "START",
              "authorization": {
                "type": "OTP",
                "token": "2442"
              },
              "time": {
                "timestamp": "2023-07-16T10:00:00+05:30"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          },
          "customer": {
            "person": {
              "name": "Ravi kumar"
            },
            "contact": {
              "phone": "+91-9887766554"
            }
          }
        }
      ],
      "payments": [
        {
          "id": "payment-123e4567-e89b-12d3-a456-426614174000",
          "collected_by": "BPP",
          "url": "https://payments.bluechargenet-aggregator.io/pay?transaction_id=$transaction_id&amount=$amount",
          "params": {
            "amount": "90.00",
            "currency": "INR",
            "source_virtual_payment_address": "ravi@ptsbi"
          },
          "type": "PRE-FULFILLMENT",
          "status": "NOT-PAID",
          "time": {
            "timestamp": "2025-07-30T14:59:00Z"
          },
          "tags": [
            {
              "descriptor": {
                "code": "Payment-methods"
              },
              "list": [
                {
                  "descriptor": {
                    "code": "UPI-TRANFER"
                  }
                }
              ]
            }
          ]
        }
      ],
      "tags": [d
        {
          "descriptor": {
            "code": "buyer-finder-fee"
          },
          "list": [
            {
              "descriptor": {
                "code": "type"
              },
              "value": "PERCENTAGE"
            },
            {
              "descriptor": {
                "code": "value"
              },
              "value": "2"
            }
          ]
        }
      ]
    }
  }
}

```

## **B2B Reporting and Analytics**

### **Session Completion with B2B Reporting**

```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "on_confirm",
    "location": {
      "country": {
        "code": "IND"
      },
      "city": {
        "code": "std:080"
      }
    },
    "version": "1.1.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "15S"
  },
  "message": {
    "order": {
      "provider": {
        "id": "cpo1.com",
        "descriptor": {
          "name": "CPO1 EV charging Company",
          "short_desc": "CPO1 provides EV charging facility across India",
          "images": [
            {
              "url": "https://cpo1.com/images/logo.png"
            }
          ]
        }
      },
      "items": [
        {
          "id": "pe-charging-01",
          "descriptor": {
            "name": "EV Charger #1 (AC Fast Charger)",
            "code": "ev-charger"
          },
          "price": {
            "value": "18",
            "currency": "INR/kWh"
          },
	        "quantity": {
              "selected": {
                  "measure": {
                     "type": "CONSTANT",
                     "value": "100",
                     "unit": "INR"
                  }
              }
          },
          "tags": [
            {
              "descriptor": {
                "code": "connector-specifications",
                "name": "Connector Specifications"
              },
              "list": [
                {
                  "descriptor": {
                    "name": "connector Id",
                    "code": "connector-id"
                  },
                  "value": "1"
                },
                {
                  "descriptor": {
                    "name": "Power Type",
                    "code": "power-type"
                  },
                  "value": "AC_3_PHASE"
                },
                {
                  "descriptor": {
                    "name": "Connector Type",
                    "code": "connector-type"
                  },
                  "value": "CCS2"
                },
                {
                  "descriptor": {
                    "name": "Connector Format",
                    "code": "connector-format"
                  },
                  "value": "SOCKET"
                },
                {
                  "descriptor": {
                    "name": "Charging Speed",
                    "code": "charging-speed"
                  },
                  "value": "FAST"
                },
                {
                  "descriptor": {
                    "name": "Power Rating",
                    "code": "power-rating"
                  },
                  "value": "30kW"
                },
                {
                  "descriptor": {
                    "name": "Status",
                    "code": "status"
                  },
                  "value": "Available"
                }
              ]
            }
          ]
        }
      ],
      "fulfillments": [
        {
          "id": "fulfillment-001",
          "type": "CHARGING",
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2023-07-16T10:00:00+05:30"
              },
              "location": {
                "gps": "28.345345,77.389754",
                "descriptor": {
                  "name": "BlueCharge Connaught Place Station"
                },
                "address": "Connaught Place, New Delhi"
              },
              "instructions": {
                "short_desc": "OTP will be shared to the user's registered number to confirm order"
              }
              "authorization": {
                "type": "OTP"
              },
            },
            {
              "type": "STOP",
              "time": {
                "timestamp": "2025:09:24:11:00:00"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          },
          "customer": {
            "person": {
              "name": "Ravi Kumar"
            },
            "contact": {
              "phone": "+91-9887766554"
            }
          }
        }
      ],
      "quote": {
        "price": {
          "value": "90",
          "currency": "INR"
        },
        "breakup": [
          {
            "title": "Charging session cost (5 kWh @ ₹18.00/kWh)",
            "item": {
              "id": "pe-charging-01"
            },
            "price": {
              "value": "90",
              "currency": "INR"
            }
          },
          {
            "title": "Service fee",
            "price": {
              "currency": "INR",
              "value": "10"
            }
          },
          {
            "title": "loyalty program discount",
            "price": {
              "currency": "INR",
              "value": "10"
            }
          }
        ]
      },
      "billing": {
        "name": "Ravi Kumar",
        "organization": {
          "descriptor": {
            "name": "GreenCharge Pvt Ltd"
          }
        },
        "address": "Apartment 123, MG Road, Bengaluru, Karnataka, 560001, India",
        "state": {
          "name": "Karnataka"
        },
        "city": {
          "name": "Bengaluru"
        },
        "email": "ravi.kumar@greencharge.com",
        "phone": "+918765432100",
        "time": {
          "timestamp": "2025-07-30T12:02:00Z"
        },
        "tax_id": "GSTIN29ABCDE1234F1Z5"
      },
      "payments": [
        {
          "id": "payment-123e4567-e89b-12d3-a456-426614174000",
          "collected_by": "BPP",
          "url": "https://payments.bluechargenet-aggregator.io/pay?transaction_id=$transaction_id&amount=$amount",
          "params": {
            "transaction_id": "123e4567-e89b-12d3-a456-426614174000",
            "amount": "90.00",
            "currency": "INR",
            "bank_code": "HDFC000123",
            "bank_account_number": "1131324242424"
          },
          "type": "PRE-FULFILLMENT",
          "status": "PAID",
          "time": {
            "timestamp": "2025-07-30T14:59:00Z"
          }
        }
      ],
      "refund_terms": [
        {
          "fulfillment_state": {
            "descriptor": {
              "name": "Order Confirmed",
              "code": "CONFIRMED",
              "long_desc": "85% refund available if cancelled at least 4 hours before the scheduled charging time"
            }
          },
          "refund_eligible": true,
          "refund_within": {
            "duration": "PT2H"
          },
          "refund_amount": {
            "currency": "INR",
            "value": "85"
          }
        },
        {
          "fulfillment_state": {
            "descriptor": {
              "name": "Charging Active",
              "code": "ACTIVE"
            }
          },
          "refund_eligible": false
        }
      ]
    }
  }
}
```

## **Implementation Guidelines**

### **For BAPs (Fleet Management Apps):**
1. **Authentication**: Implement corporate user authentication

### **For BPPs (Service Providers):**
1. **Corporate Billing**: Implement corporate billing cycles
2. **Reporting APIs**: Provide detailed usage analytics
3. **Account Management**: Manage corporate accounts and contacts

### **For CPOs (Charge Point Operators):**
1. **Corporate Sales**: Develop B2B sales processes
2. **Agreement Management**: Create and manage corporate agreements
3. **Priority Access**: Implement priority charging for corporate customers
4. **Analytics**: Provide comprehensive usage analytics for corporate clients
