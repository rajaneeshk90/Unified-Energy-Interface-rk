# **Use case 5- B2B deal**

This section covers B2B (Business-to-Business) charging scenarios where fleet operators and corporate customers have pre-negotiated commercial agreements with Charge Point Operators for preferential pricing and terms.

> **Note**: For general Beckn message flow and error handling, please refer to the [Overview](./0_Overview.md#general-beckn-message-flow-and-error-handling) section.

## **B2B Deal Scenarios**

### **Fleet Operator Agreement**

**Scenario:** A logistics company has a corporate agreement with multiple CPOs for their delivery fleet. The agreement includes:
- 15% discount on all charging sessions
- Priority access to charging slots
- Monthly billing with net-30 payment terms
- Dedicated account manager support

**Implementation:** The fleet driver uses a company-issued app that automatically applies the B2B agreement during charging sessions.

### **Corporate Employee Program**

**Scenario:** A large corporation provides EV charging benefits to employees. The program includes:
- Company-subsidized charging rates
- Usage tracking and reporting
- Integration with HR systems
- Monthly expense allocation

## **User Journey**

**Fleet Driver Experience:**
Rajesh, a delivery driver for GreenLogistics, arrives at a charging station. He opens the company's fleet management app and scans the QR code at the charger. The app automatically:

1. **Authentication**: Validates his employee credentials and fleet vehicle registration
2. **Agreement Lookup**: Identifies the active B2B agreement with the CPO
3. **Pricing Application**: Applies the negotiated 15% discount automatically
4. **Session Initiation**: Starts charging with company billing terms
5. **Reporting**: Logs the session for company expense tracking

**Corporate Employee Experience:**
Priya, a sales executive, needs to charge her company car during a client visit. She uses the corporate charging app which:

1. **Employee Verification**: Confirms her employment status and vehicle assignment
2. **Benefit Application**: Applies the corporate charging subsidy
3. **Usage Tracking**: Records the session for departmental cost allocation
4. **Receipt Generation**: Provides detailed billing for expense reporting

## **API Implementation**

### **B2B Authentication in Init Call**

The B2B agreement is typically referenced during the init call through billing information and special tags that identify the corporate relationship.

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
    "bap_id": "fleet-management-app.com",
    "bap_uri": "https://api.fleet-management-app.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "b2b-6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "b2b-init-msg-001",
    "timestamp": "2025-09-24T10:10:00",
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
      "fulfillments": [
        {
          "id": "1",
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2025-09-24T10:00:00+05:30"
              }
            },
            {
              "type": "STOP",
              "time": {
                "timestamp": "2025-09-24T11:30:00+05:30"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Ace EV",
            "registration": "KA01AB1234"
          },
          "customer": {
            "person": {
              "name": "Rajesh Kumar"
            },
            "contact": {
              "phone": "+91-9876543210"
            }
          }
        }
      ],
      "billing": {
        "name": "GreenLogistics Pvt Ltd",
        "organization": {
          "descriptor": {
            "name": "GreenLogistics Pvt Ltd",
            "code": "GREENLOG001"
          }
        },
        "address": "123 Industrial Area, Bangalore, Karnataka, 560001, India",
        "email": "fleet@greenlogistics.com",
        "phone": "+91-80-12345678",
        "time": {
          "timestamp": "2025-09-24T10:10:00Z"
        },
        "tax_id": "GSTIN29GREENLOG001Z5"
      },
      "tags": [
        {
          "descriptor": {
            "code": "b2b-agreement",
            "name": "B2B Agreement Details"
          },
          "list": [
            {
              "descriptor": {
                "code": "agreement-id",
                "name": "Agreement ID"
              },
              "value": "B2B-AGREEMENT-001"
            },
            {
              "descriptor": {
                "code": "agreement-type",
                "name": "Agreement Type"
              },
              "value": "FLEET_CHARGING"
            },
            {
              "descriptor": {
                "code": "discount-percentage",
                "name": "Discount Percentage"
              },
              "value": "15"
            },
            {
              "descriptor": {
                "code": "payment-terms",
                "name": "Payment Terms"
              },
              "value": "NET_30"
            },
            {
              "descriptor": {
                "code": "priority-access",
                "name": "Priority Access"
              },
              "value": "true"
            }
          ]
        },
        {
          "descriptor": {
            "code": "fleet-details",
            "name": "Fleet Information"
          },
          "list": [
            {
              "descriptor": {
                "code": "fleet-id",
                "name": "Fleet ID"
              },
              "value": "FLEET-001"
            },
            {
              "descriptor": {
                "code": "driver-id",
                "name": "Driver ID"
              },
              "value": "DRIVER-12345"
            },
            {
              "descriptor": {
                "code": "vehicle-category",
                "name": "Vehicle Category"
              },
              "value": "COMMERCIAL"
            }
          ]
        }
      ]
    }
  }
}
```

### **B2B Response in on_init**

The BPP responds with B2B-specific pricing and terms, including corporate billing arrangements and negotiated discounts.

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
    "bap_id": "fleet-management-app.com",
    "bap_uri": "https://api.fleet-management-app.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "b2b-6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "b2b-on-init-msg-001",
    "timestamp": "2025-09-24T10:10:30"
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
                "timestamp": "2025-09-24T10:00:00+05:30"
              },
              "location": {
                "gps": "28.345345,77.389754",
                "descriptor": {
                  "name": "BlueCharge Connaught Place Station"
                },
                "address": "Connaught Place, New Delhi"
              },
              "instructions": {
                "short_desc": "Ground floor, Pillar Number 4"
              },
              "authorization": {
                "type": "B2B_AGREEMENT",
                "agreement_id": "B2B-AGREEMENT-001"
              }
            },
            {
              "type": "STOP",
              "time": {
                "timestamp": "2025-09-24T11:30:00+05:30"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Ace EV",
            "registration": "KA01AB1234"
          },
          "customer": {
            "person": {
              "name": "Rajesh Kumar"
            },
            "contact": {
              "phone": "+91-9876543210"
            }
          }
        }
      ],
      "quote": {
        "price": {
          "value": "100.30",
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
            "title": "Service Fee",
            "price": {
              "currency": "INR",
              "value": "10"
            }
          },
          {
            "title": "B2B Agreement Discount (15%)",
            "price": {
              "currency": "INR",
              "value": "-15"
            }
          },
          {
            "title": "Priority Access Fee Waiver",
            "price": {
              "currency": "INR",
              "value": "-5"
            }
          },
          {
            "title": "Corporate Service Fee",
            "price": {
              "currency": "INR",
              "value": "20.30"
            }
          }
        ]
      },
      "billing": {
        "name": "GreenLogistics Pvt Ltd",
        "organization": {
          "descriptor": {
            "name": "GreenLogistics Pvt Ltd",
            "code": "GREENLOG001"
          }
        },
        "address": "123 Industrial Area, Bangalore, Karnataka, 560001, India",
        "email": "fleet@greenlogistics.com",
        "phone": "+91-80-12345678",
        "time": {
          "timestamp": "2025-09-24T10:10:00Z"
        },
        "tax_id": "GSTIN29GREENLOG001Z5"
      },
      "payments": [
        {
          "id": "payment-b2b-001",
          "collected_by": "BPP",
          "type": "POST-FULFILLMENT",
          "status": "NOT-PAID",
          "params": {
            "amount": "100.30",
            "currency": "INR",
            "billing_cycle": "MONTHLY",
            "invoice_number": "INV-2025-09-001",
            "due_date": "2025-10-24"
          },
          "tags": [
            {
              "descriptor": {
                "code": "b2b-payment-terms",
                "name": "B2B Payment Terms"
              },
              "list": [
                {
                  "descriptor": {
                    "code": "payment-method",
                    "name": "Payment Method"
                  },
                  "value": "CORPORATE_BILLING"
                },
                {
                  "descriptor": {
                    "code": "payment-terms",
                    "name": "Payment Terms"
                  },
                  "value": "NET_30"
                },
                {
                  "descriptor": {
                    "code": "billing-contact",
                    "name": "Billing Contact"
                  },
                  "value": "accounts@greenlogistics.com"
                }
              ]
            }
          ]
        }
      ],
      "tags": [
        {
          "descriptor": {
            "code": "b2b-agreement",
            "name": "B2B Agreement Details"
          },
          "list": [
            {
              "descriptor": {
                "code": "agreement-id",
                "name": "Agreement ID"
              },
              "value": "B2B-AGREEMENT-001"
            },
            {
              "descriptor": {
                "code": "agreement-type",
                "name": "Agreement Type"
              },
              "value": "FLEET_CHARGING"
            },
            {
              "descriptor": {
                "code": "discount-percentage",
                "name": "Discount Percentage"
              },
              "value": "15"
            },
            {
              "descriptor": {
                "code": "payment-terms",
                "name": "Payment Terms"
              },
              "value": "NET_30"
            },
            {
              "descriptor": {
                "code": "priority-access",
                "name": "Priority Access"
              },
              "value": "true"
            }
          ]
        }
      ]
    }
  }
}
```

### **B2B Confirmation and Session Management**

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
    "bap_id": "fleet-management-app.com",
    "bap_uri": "https://api.fleet-management-app.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "b2b-6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "b2b-confirm-msg-001",
    "timestamp": "2025-09-24T10:15:00",
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
      "fulfillments": [
        {
          "id": "fulfillment-001",
          "type": "CHARGING",
          "stops": [
            {
              "type": "START",
              "authorization": {
                "type": "B2B_AGREEMENT",
                "agreement_id": "B2B-AGREEMENT-001",
                "driver_id": "DRIVER-12345"
              },
              "time": {
                "timestamp": "2025-09-24T10:00:00+05:30"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Ace EV",
            "registration": "KA01AB1234"
          },
          "customer": {
            "person": {
              "name": "Rajesh Kumar"
            },
            "contact": {
              "phone": "+91-9876543210"
            }
          }
        }
      ],
      "billing": {
        "name": "GreenLogistics Pvt Ltd",
        "organization": {
          "descriptor": {
            "name": "GreenLogistics Pvt Ltd",
            "code": "GREENLOG001"
          }
        },
        "address": "123 Industrial Area, Bangalore, Karnataka, 560001, India",
        "email": "fleet@greenlogistics.com",
        "phone": "+91-80-12345678",
        "time": {
          "timestamp": "2025-09-24T10:10:00Z"
        },
        "tax_id": "GSTIN29GREENLOG001Z5"
      },
      "payments": [
        {
          "id": "payment-b2b-001",
          "collected_by": "BPP",
          "type": "POST-FULFILLMENT",
          "status": "NOT-PAID",
          "params": {
            "amount": "100.30",
            "currency": "INR",
            "billing_cycle": "MONTHLY",
            "invoice_number": "INV-2025-09-001",
            "due_date": "2025-10-24"
          }
        }
      ],
      "tags": [
        {
          "descriptor": {
            "code": "b2b-agreement",
            "name": "B2B Agreement Details"
          },
          "list": [
            {
              "descriptor": {
                "code": "agreement-id",
                "name": "Agreement ID"
              },
              "value": "B2B-AGREEMENT-001"
            },
            {
              "descriptor": {
                "code": "fleet-id",
                "name": "Fleet ID"
              },
              "value": "FLEET-001"
            },
            {
              "descriptor": {
                "code": "driver-id",
                "name": "Driver ID"
              },
              "value": "DRIVER-12345"
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
    "action": "on_update",
    "location": {
      "country": {
        "code": "IND"
      },
      "city": {
        "code": "std:080"
      }
    },
    "version": "1.1.0",
    "bap_id": "fleet-management-app.com",
    "bap_uri": "https://api.fleet-management-app.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "b2b-6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "b2b-on-update-msg-001",
    "timestamp": "2025-09-24T11:35:00",
    "ttl": "15S"
  },
  "message": {
    "order": {
      "id": "b2b-order-001",
      "provider": {
        "id": "cpo1.com",
        "descriptor": {
          "name": "CPO1 EV charging Company"
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
            },
            "allocated": {
              "measure": {
                "type": "CONSTANT",
                "value": "5.2",
                "unit": "kWh"
              }
            }
          }
        }
      ],
      "fulfillments": [
        {
          "id": "fulfillment-001",
          "type": "CHARGING",
          "state": {
            "descriptor": {
              "code": "COMPLETED",
              "name": "Charging completed"
            },
            "updated_at": "2025-09-24T11:35:00Z",
            "updated_by": "b2b-charging-system"
          },
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2025-09-24T10:00:00+05:30"
              },
              "location": {
                "gps": "28.345345,77.389754",
                "descriptor": {
                  "name": "BlueCharge Connaught Place Station"
                },
                "address": "Connaught Place, New Delhi"
              }
            },
            {
              "type": "END",
              "time": {
                "timestamp": "2025-09-24T11:30:00+05:30"
              },
              "location": {
                "gps": "28.345345,77.389754",
                "descriptor": {
                  "name": "BlueCharge Connaught Place Station"
                },
                "address": "Connaught Place, New Delhi"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Ace EV",
            "registration": "KA01AB1234"
          },
          "customer": {
            "person": {
              "name": "Rajesh Kumar"
            },
            "contact": {
              "phone": "+91-9876543210"
            }
          }
        }
      ],
      "quote": {
        "price": {
          "value": "100.30",
          "currency": "INR"
        },
        "breakup": [
          {
            "title": "Charging session cost (5.2 kWh @ ₹18.00/kWh)",
            "item": {
              "id": "pe-charging-01"
            },
            "price": {
              "value": "93.60",
              "currency": "INR"
            }
          },
          {
            "title": "Service Fee",
            "price": {
              "currency": "INR",
              "value": "10"
            }
          },
          {
            "title": "B2B Agreement Discount (15%)",
            "price": {
              "currency": "INR",
              "value": "-15.54"
            }
          },
          {
            "title": "Priority Access Fee Waiver",
            "price": {
              "currency": "INR",
              "value": "-5"
            }
          },
          {
            "title": "Corporate Service Fee",
            "price": {
              "currency": "INR",
              "value": "17.24"
            }
          }
        ]
      },
      "billing": {
        "name": "GreenLogistics Pvt Ltd",
        "organization": {
          "descriptor": {
            "name": "GreenLogistics Pvt Ltd",
            "code": "GREENLOG001"
          }
        },
        "address": "123 Industrial Area, Bangalore, Karnataka, 560001, India",
        "email": "fleet@greenlogistics.com",
        "phone": "+91-80-12345678",
        "time": {
          "timestamp": "2025-09-24T10:10:00Z"
        },
        "tax_id": "GSTIN29GREENLOG001Z5"
      },
      "payments": [
        {
          "id": "payment-b2b-001",
          "collected_by": "BPP",
          "type": "POST-FULFILLMENT",
          "status": "NOT-PAID",
          "params": {
            "amount": "100.30",
            "currency": "INR",
            "billing_cycle": "MONTHLY",
            "invoice_number": "INV-2025-09-001",
            "due_date": "2025-10-24"
          }
        }
      ],
      "tags": [
        {
          "descriptor": {
            "code": "b2b-reporting",
            "name": "B2B Reporting Data"
          },
          "list": [
            {
              "descriptor": {
                "code": "session-id",
                "name": "Session ID"
              },
              "value": "SESSION-B2B-001"
            },
            {
              "descriptor": {
                "code": "fleet-route",
                "name": "Fleet Route"
              },
              "value": "BANGALORE-DELHI"
            },
            {
              "descriptor": {
                "code": "cost-center",
                "name": "Cost Center"
              },
              "value": "LOGISTICS-001"
            },
            {
              "descriptor": {
                "code": "department",
                "name": "Department"
              },
              "value": "DELIVERY"
            },
            {
              "descriptor": {
                "code": "fuel-savings",
                "name": "Fuel Savings"
              },
              "value": "₹45.50"
            }
          ]
        }
      ]
    }
  }
}
```

## **Implementation Guidelines**

### **For BAPs (Fleet Management Apps):**
1. **Agreement Management**: Store and manage B2B agreements
2. **Authentication**: Implement corporate user authentication
3. **Reporting**: Generate detailed usage and cost reports
4. **Integration**: Connect with corporate systems (HR, Finance, etc.)

### **For BPPs (Service Providers):**
1. **Agreement Processing**: Handle B2B agreement validation
2. **Corporate Billing**: Implement corporate billing cycles
3. **Reporting APIs**: Provide detailed usage analytics
4. **Account Management**: Manage corporate accounts and contacts

### **For CPOs (Charge Point Operators):**
1. **Corporate Sales**: Develop B2B sales processes
2. **Agreement Management**: Create and manage corporate agreements
3. **Priority Access**: Implement priority charging for corporate customers
4. **Analytics**: Provide comprehensive usage analytics for corporate clients

## **Key B2B Features**

### **Corporate Billing**
- Monthly billing cycles
- Net payment terms (e.g., Net 30)
- Consolidated invoicing
- Multi-location charging

### **Priority Access**
- Reserved charging slots
- Queue priority
- Guaranteed availability
- Dedicated support

### **Reporting and Analytics**
- Usage tracking by department/vehicle
- Cost allocation
- Carbon footprint reporting
- Performance metrics

### **Integration Capabilities**
- ERP system integration
- Fleet management system integration
- HR system integration
- Financial system integration
