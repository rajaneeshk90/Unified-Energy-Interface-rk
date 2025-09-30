# **Use case 7- surge charge**

This section covers surge charge scenarios where additional fees are applied to EV charging sessions based on various factors such as peak demand, location, time of day, or special circumstances.

> **Note**: For general Beckn message flow and error handling, please refer to the [Overview](./0_Overview.md#general-beckn-message-flow-and-error-handling) section.

A surge price is an additional fee applied on top of the base charging tariff under specific conditions-such as time of use or location.

## **surge charge Types**

### **Peak Demand surge charge**
- High demand periods (e.g., evening rush hours)
- Grid stress conditions
- Weather-related demand spikes
- Holiday or event-driven demand

### **Location-Based surge charge**
- Premium locations (airports, malls, city centers)
- High-cost areas (prime real estate)
- Remote locations with higher infrastructure costs
- Special zones (highway rest stops, tourist areas)

### **Time-Based surge charge**
- Peak hours (6-9 AM, 6-9 PM)
- Weekend surge charges
- Holiday surge charges
- Night-time surge charges (for 24/7 operations)

### **Service-Based surge charge**
- Fast charging premium
- Priority access fees
- Additional services (valet charging, cleaning)
- Emergency charging services

### **Environmental surge charge**
- Carbon offset fees
- Renewable energy premium
- Environmental impact charges
- Sustainability initiatives

## **User Journey**

### **Discovery**

While searching for a charger around 6:15 PM, Srilekha sees a warning icon and note:

> "Congestion Fee: ₹1/kWh between 6 PM – 9 PM"

The app highlights this surcharge in:

* The station list view (via badge or icon)
* The charger details page
* A "Know More" section that explains:
  - What the surcharge is
  - When and where it applies
  - How it's calculated

### **Session Preview**

Before starting, the app shows the full estimated cost:

* Base rate: ₹16/kWh
* Congestion fee: ₹1/kWh
* Estimated total for 5 kWh: ₹85

### **Charging**

Srilekha starts the session at 6:25 PM. During the session:

* She sees kWh delivered
* Total cost is incrementally calculated including the surcharge
* Example calculation: 
  > 3.4 kWh → ₹58.00 = ₹54.4 base + ₹3.4 congestion fee

### **Post-Charging**

Once the session ends, Srilekha receives an itemized receipt:

**Session Summary:**
* Energy Delivered: 5.2 kWh
* Base Energy Cost: ₹83.20
* Congestion Fee (₹1 x 5.2): ₹5.20
* Total Payable: ₹88.40


## **API Implementation**

### **on_select with surge charge Pricing**

BPP applies a surge charge if applicable, the surge charge is reflected in the order.quote object. 
The BPP responds with pricing that includes the applied surge charge.

```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "on_select",
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
            "short_desc": "Book now"
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
                "timestamp": "2025:09:24:10:00:00"
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
              }
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
          }
        }
      ],
      "quote": {
        "price": {
          "value": "118",
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
            "title": "service fee",
            "price": {
              "currency": "INR",
              "value": "10"
            }
          },
          {
            "title": "surge price(20%)",
            "price": {
              "currency": "INR",
              "value": "18"
            }
          }
        ]
      }
    }
  }
}
```

### **Init with surge charge**

The consumer initiates the charging session with surge charge applied.

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
          },
        }
      ],
      "offers": [
        {
          "id": "offer-001"
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

### **on_init with surge charge Confirmation**

The BPP confirms the surge charge application and provides payment details.

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
          "value": "118",
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
            "title": "surge price(20%)",
            "price": {
              "currency": "INR",
              "value": "18"
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
            "amount": "118.00",
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

Rest of the flow would be the same as other use cases.

## **Implementation Guidelines**

### **For BAPs (Consumer Apps):**
1. **surge charge Display**: Clearly show surge charge information in on_select results
2. **Transparent Pricing**: Display surge charge breakdown in pricing details
3. **User Consent**: Obtain user acknowledgment for surge charge application
4. **Real-time Updates**: Update surge charge information based on time and conditions

### **For BPPs (Service Providers):**
1. **surge charge Logic**: Implement dynamic surge charge calculation algorithms
2. **Condition Monitoring**: Monitor conditions that trigger surge charges
3. **Pricing Transparency**: Provide clear surge charge explanations
4. **Analytics**: Track surge charge impact on usage patterns

### **For CPOs (Charge Point Operators):**
1. **surge charge Strategy**: Develop surge charge policies for different scenarios
2. **Infrastructure Integration**: Connect surge charge systems with charging infrastructure
3. **Customer Communication**: Clearly communicate surge charge policies
4. **Performance Monitoring**: Monitor surge charge effectiveness and customer impact

## **Key surge charge Features**

### **Dynamic Application**
- Real-time surge charge calculation
- Time-based surge charge triggers
- Location-based surge charge application
- Demand-based surge charge adjustment

### **Transparency Requirements**
- Clear surge charge explanations
- Detailed pricing breakdowns
- Advance notice of surge charge changes
- User acknowledgment of surge charge acceptance

### **Flexibility Options**
- Multiple surge charge types
- Stackable surge charges
- Conditional surge charge application
- surge charge exemptions for certain users

### **Monitoring and Analytics**
- surge charge impact on usage
- Customer behavior analysis
- Revenue optimization
- Demand management effectiveness
