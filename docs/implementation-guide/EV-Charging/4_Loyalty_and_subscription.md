# **Use case 4- Loyalty program discovery and subscription**

This section covers the discovery and subscription process for loyalty programs offered by charging providers, enabling users to access preferential pricing and exclusive benefits.

> **Note**: For general Beckn message flow and error handling, please refer to the [Overview](./0_Overview.md#general-beckn-message-flow-and-error-handling) section.

## **User journey**

Kavya Nair, a 32-year-old consultant who charges 3- 4 times a week along Bengaluru corridors. She's price-sensitive and happy to pay for a loyalty that reliably reduces per-kWh costs at her usual CPOs.

**Subscribing to a loyalty program (as a catalog item)**

**Discovery:** While planning an early reservation for the day, Kavya sees a "CPO Gold Pass – ₹299/month" in her EV app's catalog.

**Order:**
* The app clearly separates the Charging vs Loyalty program using category codes. Kavya taps the LOY item, views benefits (-10% on weekdays, idle fee waiver 15 min, priority slots), and buys it standalone. (The app could also offer a bundle: "Book charger + add Gold Pass now".)  
* She is redirected to the loyalty details page (through a 'know more' link) where she completes the purchase. Thus loyalty is bound to her mobile number (primary identifier; email as secondary).  
* The BPP confirms activation and tier = Gold with validity dates. The app adds this program to her "My Loyalty Map" so she sees where it applies.

**Tip to BAPs (product hint)**
* Treat loyalty as a retail SKU with its own category code and lifecycle.  
* BPPs can bundle loyalty as a catalog response for every search or in selective cases. It may not always necessarily need a separate search call.

## **API Calls and Schema**

### **Search**

The consumer searches for available loyalty programs by specifying the loyalty program category. This targeted search allows users to discover subscription-based loyalty offerings from charging providers without mixing them with charging station results.

```json
{
  "context": {
    "ttl": "PT10M",
    "action": "search",
    "location": {
      "country": {
        "code": "IND"
      },
      "city": {
        "code": "std:080"
      }
    },
    "timestamp": "2024-08-05T09:21:12.618Z",
    "message_id": "e138f204-ec0b-415d-9c9a-7b5bafe10bfe",
    "transaction_id": "2ad735b9-e190-457f-98e5-9702fd895996",
    "domain": "deg:ev-charging",
    "version": "1.1.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1"
  },
  "message": {
    "intent": {
      "category": {
        "descriptor": {
          "code": "loyalty-program"
        }
      }
    }
  }
}
```

The consumer can also perform a free text search to discover loyalty programs by name or description. This flexible search method allows users to find specific loyalty programs using natural language queries, making program discovery more intuitive and accessible.

```json
{
  "context": {
    "ttl": "PT10M",
    "action": "search",
    "location": {
      "country": {
        "code": "IND"
      },
      "city": {
        "code": "std:080"
      }
    },
    "timestamp": "2024-08-05T09:21:12.618Z",
    "message_id": "e138f204-ec0b-415d-9c9a-7b5bafe10bfe",
    "transaction_id": "2ad735b9-e190-457f-98e5-9702fd895996",
    "domain": "deg:ev-charging",
    "version": "1.1.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1"
  },
  "message": {
    "intent": {
        "descriptor": {
          "name": "loyalty programs"
        }
    }
  }
}
```

### **on_search**

The BPP responds with a comprehensive catalog of available loyalty programs from the network. This response includes detailed program information, pricing, benefits, and subscription terms for each loyalty offering. The catalog can be delivered either as a direct response to consumer search requests or proactively as unsolicited recommendations based on user preferences and charging patterns.

```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "on_search",
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
    "timestamp": "2023-07-16T04:41:16Z"
  },
  "message": {
    "catalog": {
      "providers": [
        {
          "id": "cpo1.com",
          "descriptor": {
            "name": "CPO1 EV Charging Company",
            "short_desc": "Premium EV charging network across India",
            "images": [
              {
                "url": "https://cpo1.com/images/logo.png"
              }
            ]
          },
          "categories": [
            {
              "id": "loyalty-programs",
              "descriptor": {
                "code": "loyalty-program",
                "name": "Loyalty Programs"
              }
            }
          ],
          "items": [
            {
              "id": "loyalty-gold-pass",
              "descriptor": {
                "name": "CPO Gold Pass",
                "code": "loyalty-subscription",
                "short_desc": "Premium loyalty program with exclusive benefits",
                "long_desc": "Get 10% discount on weekday charging, idle fee waiver up to 15 minutes, priority access to charging slots, and dedicated customer support.",
                "additional_desc": {
                  "url": "https://example-bpp.com/gold-pass.html",
                  "content-type": "text/html"
                },
                "images": [
                  {
                    "url": "https://cpo1.com/images/gold-pass.png"
                  }
                ]
              },
              "price": {
                "value": "299",
                "currency": "INR"
              },
              "category_ids": [
                "loyalty-programs"
              ],
              "tags": [
                {
                  "descriptor": {
                    "code": "loyalty-benefits",
                    "name": "Program Benefits"
                  },
                  "list": [
                    {
                      "descriptor": {
                        "code": "weekday-discount",
                        "name": "Weekday Discount"
                      },
                      "value": "10%"
                    },
                    {
                      "descriptor": {
                        "code": "idle-fee-waiver",
                        "name": "Idle Fee Waiver"
                      },
                      "value": "15 minutes"
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
                    "code": "subscription-details",
                    "name": "Subscription Details"
                  },
                  "list": [
                    {
                      "descriptor": {
                        "code": "validity-period",
                        "name": "Validity Period"
                      },
                      "value": "30 days"
                    },
                    {
                      "descriptor": {
                        "code": "tier-level",
                        "name": "Tier Level"
                      },
                      "value": "Gold"
                    },
                    {
                      "descriptor": {
                        "code": "auto-renewal",
                        "name": "Auto Renewal"
                      },
                      "value": "optional"
                    }
                  ]
                }
              ]
            },
            {
              "id": "loyalty-platinum-pass",
              "descriptor": {
                "name": "CPO Platinum Pass",
                "code": "loyalty-subscription",
                "short_desc": "Ultimate loyalty program with maximum savings",
                "long_desc": "Enjoy 15% discount on all charging sessions, idle fee waiver up to 30 minutes, guaranteed slot availability, premium customer support, and exclusive access to new stations.",
                "additional_desc": {
                  "url": "https://example-bpp.com/platinum-pass.html",
                  "content-type": "text/html"
                },
                "images": [
                  {
                    "url": "https://cpo1.com/images/platinum-pass.png"
                  }
                ]
              },
              "price": {
                "value": "499",
                "currency": "INR"
              },
              "category_ids": [
                "loyalty-programs"
              ],
              "tags": [
                {
                  "descriptor": {
                    "code": "loyalty-benefits",
                    "name": "Program Benefits"
                  },
                  "list": [
                    {
                      "descriptor": {
                        "code": "all-time-discount",
                        "name": "All Time Discount"
                      },
                      "value": "15%"
                    },
                    {
                      "descriptor": {
                        "code": "idle-fee-waiver",
                        "name": "Idle Fee Waiver"
                      },
                      "value": "30 minutes"
                    },
                    {
                      "descriptor": {
                        "code": "guaranteed-availability",
                        "name": "Guaranteed Slot Availability"
                      },
                      "value": "true"
                    },
                    {
                      "descriptor": {
                        "code": "premium-support",
                        "name": "Premium Customer Support"
                      },
                      "value": "24/7"
                    }
                  ]
                },
                {
                  "descriptor": {
                    "code": "subscription-details",
                    "name": "Subscription Details"
                  },
                  "list": [
                    {
                      "descriptor": {
                        "code": "validity-period",
                        "name": "Validity Period"
                      },
                      "value": "30 days"
                    },
                    {
                      "descriptor": {
                        "code": "tier-level",
                        "name": "Tier Level"
                      },
                      "value": "Platinum"
                    },
                    {
                      "descriptor": {
                        "code": "auto-renewal",
                        "name": "Auto Renewal"
                      },
                      "value": "recommended"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  }
}
```

Loyalty program catalogs can be bundled together with charging station catalogs in a single response. This integrated approach allows consumers to discover both charging services and loyalty programs simultaneously, enabling cross-selling opportunities and providing a comprehensive view of available offerings from charging providers.

```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "on_search",
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
    "timestamp": "2023-07-16T04:41:16Z"
  },
  "message": {
    "catalog": {
      "providers": [
        {
          "id": "cpo1.com",
          "descriptor": {
            "name": "CPO1 EV charging Company",
            "short_desc": "CPO1 provides EV charging facility across India",
            "images": [
              {
                "url": "https://cpo1.com/images/logo.png"
              }
            ]
          },
          "categories": [
            {
              "id": "category-gt",
              "descriptor": {
                "code": "green-tariff",
                "name": "green tariff"
              }
            },
            {
              "id": "loyalty-programs",
              "descriptor": {
                "code": "loyalty-program",
                "name": "Loyalty Programs"
              }
            }
          ],
          "locations": [
            {
              "id": "LOC-DELHI-001",
              "gps": "28.345345,77.389754",
              "descriptor": {
                "name": "BlueCharge Connaught Place Station"
              },
              "address": "Connaught Place, New Delhi"
            }
          ],
          "fulfillments": [
            {
              "id": "fulfillment-001",
              "type": "CHARGING",
              "stops": [
                {
                  "location": {
                    "gps": "28.6304,77.2177",
                    "address": "Saket, New Delhi"
                  },
                  "time": {
                    "range": {
                      "start": "2025:09:24:10:00:00",
                      "end": "2025:09:24:11:00:00"
                    }
                  }
                }
              ]
            },
            {
              "id": "fulfillment-002",
              "type": "DIGITAL",
              "stops": [
                {
                  "type": "START",
                  "time": {
                    "timestamp": "2025:09:24:10:15:00"
                  }
                }
              ]
            }
          ],
          "items": [
            {
              "id": "pe-charging-01",
              "descriptor": {
                "name": "EV Charger #1 (AC Fast Charger)",
                "code": "CHARGER",
                "short_desc": "Book now"
              },
              "price": {
                "value": "18",
                "currency": "INR/kWh"
              },
              "fulfillment_ids": [
                "fulfillment-001"
              ],
              "category_ids": [
                "category-gt"
              ],
              "location_ids": [
                "LOC-DELHI-001"
              ],
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
            },
            {
              "id": "loyalty-gold-pass",
              "descriptor": {
                "name": "CPO Gold Pass",
                "code": "loyalty-subscription",
                "short_desc": "Premium loyalty program with exclusive benefits",
                "long_desc": "Get 10% discount on weekday charging, idle fee waiver up to 15 minutes, priority access to charging slots, and dedicated customer support.",
                "additional_desc": {
                  "url": "https://example-bpp.com/gold-pass.html",
                  "content-type": "text/html"
                }
              },
              "price": {
                "value": "299",
                "currency": "INR"
              },
              "fulfillment_ids": [
                "fulfillment-002"
              ],
              "category_ids": [
                "loyalty-programs"
              ],
              "tags": [
                {
                  "descriptor": {
                    "code": "loyalty-benefits",
                    "name": "Program Benefits"
                  },
                  "list": [
                    {
                      "descriptor": {
                        "code": "weekday-discount",
                        "name": "Weekday Discount"
                      },
                      "value": "10%"
                    },
                    {
                      "descriptor": {
                        "code": "idle-fee-waiver",
                        "name": "Idle Fee Waiver"
                      },
                      "value": "15 minutes"
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
                    "code": "subscription-details",
                    "name": "Subscription Details"
                  },
                  "list": [
                    {
                      "descriptor": {
                        "code": "validity-period",
                        "name": "Validity Period"
                      },
                      "value": "30 days"
                    },
                    {
                      "descriptor": {
                        "code": "tier-level",
                        "name": "Tier Level"
                      },
                      "value": "Gold"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  }
}
```

**Note:** These are just example catalogs. CPOs are encouraged to innovate on various catalog offerings that involve a wide set of features. More such examples will be added to this document in future releases.

The BPP may create a page with the details of the loyalty program including terms and conditions and transmit it via item.descriptor.additional_desc. The tags are optional and the BAP may display the same to the end user. They are not standardised and the BPP may transmit them as per their discretion and structure of the loyalty program.

### **Select**

The consumer selects a specific loyalty program from the available catalog to proceed with subscription. This call initiates the ordering process by specifying the chosen loyalty program item. The BAP sends this request to confirm the user's intent to purchase the loyalty subscription.

```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "select",
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
    "message_id": "select-loyalty-msg-001",
    "timestamp": "2025:09:24:10:05:00",
    "ttl": "15S"
  },
  "message": {
    "order": {
      "provider": {
        "id": "cpo1.com"
      },
      "items": [
        {
          "id": "loyalty-gold-pass"
        }
      ],
      "fulfillments": [
        {
          "id": "fulfillment-002",
          "type": "DIGITAL"
        }
      ]
    }
  }
}
```

### **on_select**

The BPP responds with a detailed quotation for the selected loyalty program, including pricing breakdown and subscription terms. This response provides all necessary information for the consumer to make an informed purchase decision. The fulfillment status indicates the program is ready for activation upon payment completion.

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
    "message_id": "on-select-loyalty-msg-001",
    "timestamp": "2025:09:24:10:05:30"
  },
  "message": {
    "order": {
      "provider": {
        "id": "cpo1.com",
        "descriptor": {
          "name": "CPO1 EV charging Company"
        }
      },
      "items": [
        {
          "id": "loyalty-gold-pass",
          "descriptor": {
            "name": "CPO Gold Pass",
            "code": "loyalty-subscription"
          },
          "price": {
            "value": "299",
            "currency": "INR"
          }
        }
      ],
      "fulfillments": [
        {
          "id": "fulfillment-002",
          "type": "DIGITAL"
        }
      ],
      "quote": {
        "price": {
          "value": "299",
          "currency": "INR"
        },
        "breakup": [
          {
            "item": {
              "id": "loyalty-gold-pass",
              "descriptor": {
                "name": "CPO Gold Pass"
              },
              "price": {
                "value": "299",
                "currency": "INR"
              }
            },
            "title": "Loyalty Subscription",
            "price": {
              "value": "299",
              "currency": "INR"
            }
          }
        ]
      }
    }
  }
}
```

### **Init**

The consumer initiates the loyalty program purchase by providing complete billing information. This call establishes the customer's identity and billing details required for subscription activation. The BAP includes customer contact information that will be used for loyalty program binding and future communications related to the subscription service.

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
    "message_id": "init-loyalty-msg-001",
    "timestamp": "2025:09:24:10:10:00",
    "ttl": "15S"
  },
  "message": {
    "order": {
      "provider": {
        "id": "cpo1.com"
      },
      "items": [
        {
          "id": "loyalty-gold-pass"
        }
      ],
      "fulfillments": [
        {
          "id": "fulfillment-002",
          "type": "DIGITAL",
          "customer": {
            "person": {
              "name": "Kavya Nair"
            },
            "contact": {
              "phone": "+91-9876543210",
              "email": "kavya.nair@email.com"
            }
          }
        }
      ],
      "billing": {
        "name": "Kavya Nair",
        "phone": "+91-9876543210",
        "email": "kavya.nair@email.com",
        "address": "123 MG Road, Indiranagar, Bengaluru, Karnataka 560038"
      }
    }
  }
}
```

### **on_init**

The BPP responds with comprehensive payment information and loyalty program activation details. This response includes payment gateway links, subscription validity periods, tier level confirmation, and activation timeline. The BPP confirms all billing information and provides the consumer with clear expectations about program benefits and activation process upon successful payment completion.

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
    "message_id": "on-init-loyalty-msg-001",
    "timestamp": "2025:09:24:10:10:30"
  },
  "message": {
    "order": {
      "provider": {
        "id": "cpo1.com",
        "descriptor": {
          "name": "CPO1 EV charging Company"
        }
      },
      "items": [
        {
          "id": "loyalty-gold-pass",
          "descriptor": {
            "name": "CPO Gold Pass",
            "code": "loyalty-subscription"
          },
          "price": {
            "value": "299",
            "currency": "INR"
          },
          "tags": [
            {
              "descriptor": {
                "code": "loyalty-activation",
                "name": "Loyalty Program Activation"
              },
              "list": [
                {
                  "descriptor": {
                    "code": "activation-time",
                    "name": "Activation Time"
                  },
                  "value": "immediate"
                },
                {
                  "descriptor": {
                    "code": "validity-start",
                    "name": "Validity Start"
                  },
                  "value": "2025:09:24:10:15:00"
                },
                {
                  "descriptor": {
                    "code": "validity-end",
                    "name": "Validity End"
                  },
                  "value": "2025:10:24:10:15:00"
                },
                {
                  "descriptor": {
                    "code": "tier-level",
                    "name": "Tier Level"
                  },
                  "value": "Gold"
                }
              ]
            }
          ]
        }
      ],
      "fulfillments": [
        {
          "id": "fulfillment-002",
          "type": "DIGITAL",
          "customer": {
            "person": {
              "name": "Kavya Nair"
            },
            "contact": {
              "phone": "+91-9876543210",
              "email": "kavya.nair@email.com"
            }
          }
        }
      ],
      "billing": {
        "name": "Kavya Nair",
        "phone": "+91-9876543210",
        "email": "kavya.nair@email.com",
        "address": "123 MG Road, Indiranagar, Bengaluru, Karnataka 560038"
      },
      "quote": {
        "price": {
          "value": "299",
          "currency": "INR"
        },
        "breakup": [
          {
            "item": {
              "id": "loyalty-gold-pass",
              "descriptor": {
                "name": "CPO Gold Pass"
              }
            },
            "title": "Loyalty Subscription",
            "price": {
              "value": "299",
              "currency": "INR"
            }
          }
        ]
      },
      "payments": [
        {
          "id": "payment-001",
          "type": "PRE-ORDER",
          "status": "NOT-PAID",
          "params": {
            "amount": "299",
            "currency": "INR",
            "payment_link": "https://payments.cpo1.com/pay/loyalty-gold-pass-001"
          }
        }
      ],
      "cancellation_terms": [
        {
          "fulfillment_state": {
            "descriptor": {
              "name": "Subscription Active",
              "code": "ACTIVE"
            }
          },
          "cancellation_eligible": true,
          "cancellation_fee": {
            "amount": {
              "value": "0",
              "currency": "INR"
            }
          },
          "applicable_within": {
            "duration": "P30D"
          }
        }
      ]
    }
  }
}
```

### **confirm**

The consumer confirms the loyalty program purchase after successful payment completion. This call includes payment transaction details and serves as final confirmation of the subscription order. The BAP sends this request with updated payment status to trigger the loyalty program activation process and establish the customer's membership in the selected tier.

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
    "message_id": "confirm-loyalty-msg-001",
    "timestamp": "2025:09:24:10:15:00",
    "ttl": "15S"
  },
  "message": {
    "order": {
      "provider": {
        "id": "cpo1.com"
      },
      "items": [
        {
          "id": "loyalty-gold-pass"
        }
      ],
      "fulfillments": [
        {
          "id": "fulfillment-002",
          "type": "DIGITAL",
          "customer": {
            "person": {
              "name": "Kavya Nair"
            },
            "contact": {
              "phone": "+91-9876543210",
              "email": "kavya.nair@email.com"
            }
          }
        }
      ],
      "billing": {
        "name": "Kavya Nair",
        "phone": "+91-9876543210",
        "email": "kavya.nair@email.com",
        "address": "123 MG Road, Indiranagar, Bengaluru, Karnataka 560038"
      },
      "payments": [
        {
          "id": "payment-001",
          "type": "PRE-ORDER",
          "status": "PAID",
          "params": {
            "amount": "299",
            "currency": "INR",
            "transaction_id": "txn-loyalty-001"
          }
        }
      ]
    }
  }
}
```

### **on_confirm**

The BPP confirms successful loyalty program activation and provides comprehensive membership details. This response establishes the active subscription with unique membership ID, tier benefits, validity periods, and auto-renewal settings. The digital fulfillment is marked as active with customer binding, confirming that the loyalty program benefits are immediately available for use in future charging sessions.

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
    "message_id": "on-confirm-loyalty-msg-001",
    "timestamp": "2025:09:24:10:15:30"
  },
  "message": {
    "order": {
      "id": "loyalty-order-001",
      "status": "ACTIVE",
      "provider": {
        "id": "cpo1.com",
        "descriptor": {
          "name": "CPO1 EV charging Company"
        }
      },
      "items": [
        {
          "id": "loyalty-gold-pass",
          "descriptor": {
            "name": "CPO Gold Pass",
            "code": "loyalty-subscription"
          },
          "price": {
            "value": "299",
            "currency": "INR"
          },
          "tags": [
              {
                "descriptor": {
                  "code": "loyalty-membership",
                  "name": "Loyalty Membership Details"
                },
                "list": [
                  {
                    "descriptor": {
                      "code": "membership-id",
                      "name": "Membership ID"
                    },
                    "value": "GOLD-MEMBER-001"
                  },
                  {
                    "descriptor": {
                      "code": "tier-level",
                      "name": "Tier Level"
                    },
                    "value": "Gold"
                  },
                  {
                    "descriptor": {
                      "code": "validity-start",
                      "name": "Validity Start"
                    },
                    "value": "2025:09:24:10:15:00"
                  },
                  {
                    "descriptor": {
                      "code": "validity-end",
                      "name": "Validity End"
                    },
                    "value": "2025:10:24:10:15:00"
                  },
                  {
                    "descriptor": {
                      "code": "auto-renewal",
                      "name": "Auto Renewal"
                    },
                    "value": "enabled"
                  }
                ]
              },
              {
                "descriptor": {
                  "code": "loyalty-benefits",
                  "name": "Active Benefits"
                },
                "list": [
                  {
                    "descriptor": {
                      "code": "weekday-discount",
                      "name": "Weekday Discount"
                    },
                    "value": "10%"
                  },
                  {
                    "descriptor": {
                      "code": "idle-fee-waiver",
                      "name": "Idle Fee Waiver"
                    },
                    "value": "15 minutes"
                  },
                  {
                    "descriptor": {
                      "code": "priority-access",
                      "name": "Priority Access"
                    },
                    "value": "enabled"
                  }
                ]
              }
            ]
        }
      ],
      "fulfillments": [
        {
          "id": "fulfillment-002",
          "type": "DIGITAL",
          "state": {
            "descriptor": {
              "code": "ACTIVE",
              "name": "Loyalty Program Active"
            }
          },
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2025:09:24:10:15:30"
              }
            }
          ],
          "customer": {
            "person": {
              "name": "Kavya Nair"
            },
            "contact": {
              "phone": "+91-9876543210",
              "email": "kavya.nair@email.com"
            }
          }
        }
      ],
      "billing": {
        "name": "Kavya Nair",
        "phone": "+91-9876543210",
        "email": "kavya.nair@email.com",
        "address": "123 MG Road, Indiranagar, Bengaluru, Karnataka 560038"
      },
      "quote": {
        "price": {
          "value": "299",
          "currency": "INR"
        },
        "breakup": [
          {
            "item": {
              "id": "loyalty-gold-pass"
            },
            "title": "Loyalty Subscription",
            "price": {
              "value": "299",
              "currency": "INR"
            }
          }
        ]
      },
      "payments": [
        {
          "id": "payment-001",
          "type": "PRE-ORDER",
          "status": "PAID",
          "params": {
            "amount": "299",
            "currency": "INR",
            "transaction_id": "txn-loyalty-001"
          }
        }
      ],
      "cancellation_terms": [
        {
          "fulfillment_state": {
            "descriptor": {
              "name": "Subscription Active",
              "code": "ACTIVE"
            }
          },
          "cancellation_eligible": true,
          "cancellation_fee": {
            "amount": {
              "value": "0",
              "currency": "INR"
            }
          },
          "applicable_within": {
            "duration": "P30D"
          }
        }
      ]
    }
  }
}
```

### **on_status**

BPP provides the current status of the loyalty program subscription, including membership details, and tier progression information.

```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "on_status",
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
    "message_id": "on-status-loyalty-msg-001",
    "timestamp": "2025:09:30:14:20:00"
  },
  "message": {
    "order": {
      "id": "loyalty-order-001",
      "status": "ACTIVE",
      "provider": {
        "id": "cpo1.com",
        "descriptor": {
          "name": "CPO1 EV charging Company"
        }
      },
      "items": [
        {
          "id": "loyalty-gold-pass",
          "descriptor": {
            "name": "CPO Gold Pass",
            "code": "loyalty-subscription"
          },
          "price": {
            "value": "299",
            "currency": "INR"
          },
          "tags": [
            {
                "descriptor": {
                    "code": "loyalty-membership",
                    "name": "Loyalty Membership Details"
                },
                "list": [
                    {
                        "descriptor": {
                            "code": "membership-id",
                            "name": "Membership ID"
                        },
                        "value": "GOLD-MEMBER-001"
                    },
                    {
                        "descriptor": {
                            "code": "tier-level",
                            "name": "Current Tier"
                        },
                        "value": "Gold"
                    },
                    {
                        "descriptor": {
                            "code": "validity-remaining",
                            "name": "Days Remaining"
                        },
                        "value": "24"
                    },
                    {
                        "descriptor": {
                            "code": "next-renewal",
                            "name": "Next Renewal Date"
                        },
                        "value": "2025:10:24:10:15:00"
                    }
                ]
            },
            {
                "descriptor": {
                    "code": "usage-statistics",
                    "name": "Usage Statistics"
                },
                "list": [
                    {
                        "descriptor": {
                            "code": "charging-sessions",
                            "name": "Charging Sessions This Month"
                        },
                        "value": "5"
                    },
                    {
                        "descriptor": {
                            "code": "total-savings",
                            "name": "Total Savings This Month"
                        },
                        "value": "₹85"
                    },
                    {
                        "descriptor": {
                            "code": "idle-fee-waivers-used",
                            "name": "Idle Fee Waivers Used"
                        },
                        "value": "3"
                    },
                    {
                        "descriptor": {
                            "code": "priority-slots-used",
                            "name": "Priority Slots Used"
                        },
                        "value": "2"
                    }
                ]
            },
            {
                "descriptor": {
                    "code": "tier-progress",
                    "name": "Tier Upgrade Progress"
                },
                "list": [
                    {
                        "descriptor": {
                            "code": "current-spend",
                            "name": "Current Month Spend"
                        },
                        "value": "₹450"
                    },
                    {
                        "descriptor": {
                            "code": "platinum-threshold",
                            "name": "Spend for Platinum Upgrade"
                        },
                        "value": "₹550"
                    },
                    {
                        "descriptor": {
                            "code": "progress-percentage",
                            "name": "Progress to Next Tier"
                        },
                        "value": "82%"
                    }
                ]
            }
          ]
        }
      ],
      "fulfillments": [
        {
          "id": "fulfillment-002",
          "type": "DIGITAL",
          "state": {
            "descriptor": {
              "code": "ACTIVE",
              "name": "Loyalty Program Active"
            }
          },
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2025:09:24:10:15:30"
              }
            }
          ],
          "customer": {
            "person": {
              "name": "Kavya Nair"
            },
            "contact": {
              "phone": "+91-9876543210",
              "email": "kavya.nair@email.com"
            }
          }
        }
      ],
      "billing": {
        "name": "Kavya Nair",
        "phone": "+91-9876543210",
        "email": "kavya.nair@email.com",
        "address": "123 MG Road, Indiranagar, Bengaluru, Karnataka 560038"
      },
      "quote": {
        "price": {
          "value": "299",
          "currency": "INR"
        },
        "breakup": [
          {
            "item": {
              "id": "loyalty-gold-pass"
            },
            "title": "Loyalty Subscription",
            "price": {
              "value": "299",
              "currency": "INR"
            }
          }
        ]
      },
      "payments": [
        {
          "id": "payment-001",
          "type": "PRE-ORDER",
          "status": "PAID",
          "params": {
            "amount": "299",
            "currency": "INR",
            "transaction_id": "txn-loyalty-001"
          }
        }
      ],
      "cancellation_terms": [
        {
          "fulfillment_state": {
            "descriptor": {
              "name": "Subscription Active",
              "code": "ACTIVE"
            }
          },
          "cancellation_eligible": true,
          "cancellation_fee": {
            "amount": {
              "value": "0",
              "currency": "INR"
            }
          },
          "applicable_within": {
            "duration": "P30D"
          }
        }
      ]
  }
}
```

## **Using the Loyalty Program in a Charging Session**

Next day, Kavya searches for a fast charger near Indiranagar.

**Discovery**
* Her BAP sends the init call and pushes the billing information (consisting of the loyalty mobile number);  
* BPP/CPO CMS checks identifiers (mobile/email) and detects an active Gold program.  
* The quote returned includes a loyalty line item (e.g., "Gold discount –10%"), clearly separated from energy and fees.

**Order**
* The app presents a revised quote showing base tariff, loyalty discount, and net payable.  
* Kavya accepts and proceeds (UPI or direct-to-CPO, per terms).

**Fulfilment**
* Charging runs as usual. Mid-session status shows kWh, base ₹, loyalty ₹ saved, and ETA.

**Post-Fulfilment**
* Invoice itemizes:  
* Energy (kWh x rate)  
* Loyalty Discount (Gold)  
* Idle Fee (waived up to 15 min)

If her monthly spend crosses the next threshold, the on_status event upgrades her to Platinum, with a push note: "You've been upgraded to Platinum- new benefits apply from next session."

## **Implementation Guidelines**

### **For BAPs (Consumer Apps):**
1. **Loyalty Discovery**: Implement search functionality for loyalty programs
2. **Membership Management**: Display active memberships and benefits
3. **Automatic Application**: Apply loyalty discounts during charging sessions
4. **Progress Tracking**: Show tier progression and usage statistics

### **For BPPs (Service Providers):**
1. **Program Management**: Create and manage loyalty program catalogs
2. **Member Validation**: Verify loyalty status during charging sessions
3. **Benefit Application**: Automatically apply discounts and benefits
4. **Tier Management**: Handle tier upgrades and renewals

### **For CPOs (Charge Point Operators):**
1. **Program Design**: Create attractive loyalty programs with clear benefits
2. **Integration**: Connect loyalty systems with charging infrastructure
3. **Data Analytics**: Track usage patterns for program optimization
4. **Customer Retention**: Use loyalty programs to increase customer retention
