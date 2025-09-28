# **Use case 6- Offers**

This section covers promotional offers and discounts that can be applied to EV charging sessions, including time-based promotions, loyalty discounts, and special pricing schemes.

> **Note**: For general Beckn message flow and error handling, please refer to the [Overview](./0_Overview.md#general-beckn-message-flow-and-error-handling) section.

## **Offer Types**

### **Time-Based Promotions**
- Happy Hour discounts (e.g., 20% off during off-peak hours)
- Weekend specials
- Holiday promotions
- Early bird discounts

### **Volume-Based Offers**
- Bulk charging discounts
- Monthly charging packages
- Prepaid charging credits
- Family charging plans

### **Loyalty-Based Offers**
- Member-exclusive discounts
- Tier-based pricing
- Referral bonuses
- Anniversary rewards

### **Location-Based Offers**
- New station launch discounts
- Highway charging specials
- Urban vs. rural pricing
- Regional promotions

## **User Journey**

**Promotional Discovery:**
Sarah, a regular EV user, opens her charging app and sees a banner: "Weekend Special: 25% off all charging sessions at CPO1 stations this Saturday and Sunday!" She taps to learn more and sees the offer details, validity period, and participating locations.

**Offer Application:**
During her weekend trip, Sarah searches for charging stations and notices that CPO1 stations show the discounted rates prominently. She selects a station and proceeds with booking, seeing the offer automatically applied in the pricing breakdown.

**Session Completion:**
After charging, Sarah receives a detailed receipt showing the original price, discount amount, and final amount paid. She also gets a notification about similar upcoming offers.

## **API Implementation**

### **Search with Offer Discovery**

The consumer searches for charging stations and can discover available offers through the search results.

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
        "name": "EV charger"
      },
      "item": {
        "descriptor": {
          "code": "CHARGER"
        }
      },
      "fulfillment": {
        "type": "CHARGING",
        "stops": [
          {
            "location": {
              "circle": {
                "gps": "12.423423,77.325647",
                "radius": {
                  "value": "5",
                  "unit": "km"
                }
              }
            },
            "type": "START-CHARGING",
            "time": {
              "range": {
                "start": "2025:09:24:10:00:00",
                "end": "2025:09:24:16:00:00"
              }
            }
          }
        ],
        "tags": [
          {
            "list": [
              {
                "descriptor": {
                  "code": "connector-type"
                },
                "value": "CCS2"
              }
            ]
          }
        ]
      }
    }
  }
}
```

### **on_search with Offers**

The BPP responds with charging stations that include available offers and promotional pricing.

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
              "id": "weekend-special",
              "descriptor": {
                "code": "promotional-offer",
                "name": "Weekend Special Offer"
              }
            }
          ],
          "items": [
            {
              "id": "pe-charging-01",
              "descriptor": {
                "name": "EV Charger #1 (AC Fast Charger)",
                "code": "ev-charger",
                "short_desc": "Fast charging with weekend discount"
              },
              "price": {
                "value": "18",
                "currency": "INR/kWh"
              },
              "category_ids": [
                "weekend-special"
              ],
              "offers": [
                {
                  "id": "weekend-discount-25",
                  "descriptor": {
                    "name": "Weekend Special - 25% Off",
                    "short_desc": "Get 25% off on all charging sessions this weekend"
                  },
                  "price": {
                    "value": "13.50",
                    "currency": "INR/kWh"
                  },
                  "tags": [
                    {
                      "descriptor": {
                        "code": "offer-details",
                        "name": "Offer Details"
                      },
                      "list": [
                        {
                          "descriptor": {
                            "code": "discount-type",
                            "name": "Discount Type"
                          },
                          "value": "PERCENTAGE"
                        },
                        {
                          "descriptor": {
                            "code": "discount-value",
                            "name": "Discount Value"
                          },
                          "value": "25"
                        },
                        {
                          "descriptor": {
                            "code": "valid-from",
                            "name": "Valid From"
                          },
                          "value": "2025-09-21T00:00:00Z"
                        },
                        {
                          "descriptor": {
                            "code": "valid-until",
                            "name": "Valid Until"
                          },
                          "value": "2025-09-22T23:59:59Z"
                        },
                        {
                          "descriptor": {
                            "code": "min-session-value",
                            "name": "Minimum Session Value"
                          },
                          "value": "50"
                        },
                        {
                          "descriptor": {
                            "code": "max-discount",
                            "name": "Maximum Discount"
                          },
                          "value": "100"
                        }
                      ]
                    }
                  ]
                }
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
            }
          ],
          "fulfillments": [
            {
              "id": "1",
              "type": "CHARGING",
              "stops": [
                {
                  "type": "START",
                  "time": {
                    "range": {
                      "start": "2025:09:24:10:00:00",
                      "end": "2025:09:24:16:00:00"
                    }
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

### **Select with Offer**

The consumer selects a charging station with a specific offer applied.

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
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2025:09:24:10:00:00",
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
                "timestamp": "2025:09:24:10:00:00"
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
      "offers": [
        {
          "id": "weekend-discount-25"
        }
      ]
    }
  }
}
```

### **on_select with Offer Pricing**

The BPP responds with pricing that includes the applied offer discount.

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
    "timestamp": "2025:09:24:10:00:30"
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
      "offers": [
        {
          "id": "weekend-discount-25",
          "descriptor": {
            "name": "Weekend Special - 25% Off",
            "short_desc": "Get 25% off on all charging sessions this weekend"
          }
        }
      ],
      "quote": {
        "price": {
          "value": "88.50",
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
            "title": "Weekend Special Offer (25% off)",
            "price": {
              "currency": "INR",
              "value": "-22.50"
            }
          },
          {
            "title": "GST (18%)",
            "price": {
              "currency": "INR",
              "value": "11.50"
            }
          }
        ]
      }
    }
  }
}
```

### **Init with Offer**

The consumer initiates the charging session with the selected offer.

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
                "timestamp": "2025:09:24:10:00:00"
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
          },
          "customer": {
            "person": {
              "name": "Sarah Johnson"
            },
            "contact": {
              "phone": "+91-9876543210"
            }
          }
        }
      ],
      "offers": [
        {
          "id": "weekend-discount-25"
        }
      ],
      "billing": {
        "name": "Sarah Johnson",
        "address": "123 MG Road, Bangalore, Karnataka, 560001, India",
        "email": "sarah.johnson@email.com",
        "phone": "+91-9876543210",
        "time": {
          "timestamp": "2025:09:24:10:10:00Z"
        }
      }
    }
  }
}
```

### **on_init with Offer Confirmation**

The BPP confirms the offer application and provides payment details.

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
          },
          "customer": {
            "person": {
              "name": "Sarah Johnson"
            },
            "contact": {
              "phone": "+91-9876543210"
            }
          }
        }
      ],
      "offers": [
        {
          "id": "weekend-discount-25",
          "descriptor": {
            "name": "Weekend Special - 25% Off",
            "short_desc": "Get 25% off on all charging sessions this weekend"
          },
          "tags": [
            {
              "descriptor": {
                "code": "offer-validation",
                "name": "Offer Validation"
              },
              "list": [
                {
                  "descriptor": {
                    "code": "validated",
                    "name": "Offer Validated"
                  },
                  "value": "true"
                },
                {
                  "descriptor": {
                    "code": "discount-applied",
                    "name": "Discount Applied"
                  },
                  "value": "22.50"
                },
                {
                  "descriptor": {
                    "code": "offer-code",
                    "name": "Offer Code"
                  },
                  "value": "WEEKEND25"
                }
              ]
            }
          ]
        }
      ],
      "billing": {
        "name": "Sarah Johnson",
        "address": "123 MG Road, Bangalore, Karnataka, 560001, India",
        "email": "sarah.johnson@email.com",
        "phone": "+91-9876543210",
        "time": {
          "timestamp": "2025:09:24:10:10:00Z"
        }
      },
      "quote": {
        "price": {
          "value": "88.50",
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
            "title": "Weekend Special Offer (25% off)",
            "price": {
              "currency": "INR",
              "value": "-22.50"
            }
          },
          {
            "title": "GST (18%)",
            "price": {
              "currency": "INR",
              "value": "11.50"
            }
          }
        ]
      },
      "payments": [
        {
          "id": "payment-001",
          "collected_by": "BPP",
          "url": "https://payments.cpo1.com/pay?transaction_id=$transaction_id&amount=$amount",
          "params": {
            "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
            "amount": "88.50",
            "currency": "INR"
          },
          "type": "PRE-FULFILLMENT",
          "status": "NOT-PAID"
        }
      ]
    }
  }
}
```

### **Session Completion with Offer Details**

The final session update includes detailed offer application and savings information.

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
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2025:09:24:11:05:00",
    "ttl": "15S"
  },
  "message": {
    "order": {
      "id": "order-001",
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
          "id": "1",
          "type": "CHARGING",
          "state": {
            "descriptor": {
              "code": "COMPLETED",
              "name": "Charging completed"
            },
            "updated_at": "2025:09:24:11:05:00Z",
            "updated_by": "charging-system"
          },
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2025:09:24:10:00:00+05:30"
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
                "timestamp": "2025:09:24:11:00:00+05:30"
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
            "model": "Nexon EV"
          },
          "customer": {
            "person": {
              "name": "Sarah Johnson"
            },
            "contact": {
              "phone": "+91-9876543210"
            }
          }
        }
      ],
      "offers": [
        {
          "id": "weekend-discount-25",
          "descriptor": {
            "name": "Weekend Special - 25% Off",
            "short_desc": "Get 25% off on all charging sessions this weekend"
          },
          "tags": [
            {
              "descriptor": {
                "code": "offer-usage",
                "name": "Offer Usage Details"
              },
              "list": [
                {
                  "descriptor": {
                    "code": "offer-applied",
                    "name": "Offer Applied"
                  },
                  "value": "true"
                },
                {
                  "descriptor": {
                    "code": "discount-amount",
                    "name": "Discount Amount"
                  },
                  "value": "23.40"
                },
                {
                  "descriptor": {
                    "code": "savings-percentage",
                    "name": "Savings Percentage"
                  },
                  "value": "25"
                },
                {
                  "descriptor": {
                    "code": "offer-code-used",
                    "name": "Offer Code Used"
                  },
                  "value": "WEEKEND25"
                }
              ]
            }
          ]
        }
      ],
      "billing": {
        "name": "Sarah Johnson",
        "address": "123 MG Road, Bangalore, Karnataka, 560001, India",
        "email": "sarah.johnson@email.com",
        "phone": "+91-9876543210",
        "time": {
          "timestamp": "2025:09:24:10:10:00Z"
        }
      },
      "quote": {
        "price": {
          "value": "91.80",
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
            "title": "Weekend Special Offer (25% off)",
            "price": {
              "currency": "INR",
              "value": "-23.40"
            }
          },
          {
            "title": "GST (18%)",
            "price": {
              "currency": "INR",
              "value": "11.60"
            }
          }
        ]
      },
      "payments": [
        {
          "id": "payment-001",
          "collected_by": "BPP",
          "type": "PRE-FULFILLMENT",
          "status": "PAID",
          "params": {
            "transaction_id": "txn-001",
            "amount": "91.80",
            "currency": "INR"
          }
        }
      ],
      "tags": [
        {
          "descriptor": {
            "code": "offer-summary",
            "name": "Offer Summary"
          },
          "list": [
            {
              "descriptor": {
                "code": "total-savings",
                "name": "Total Savings"
              },
              "value": "₹23.40"
            },
            {
              "descriptor": {
                "code": "offer-type",
                "name": "Offer Type"
              },
              "value": "WEEKEND_SPECIAL"
            },
            {
              "descriptor": {
                "code": "next-offer",
                "name": "Next Available Offer"
              },
              "value": "Holiday Special - 30% off (Dec 25-31)"
            }
          ]
        }
      ]
    }
  }
}
```

## **Implementation Guidelines**

### **For BAPs (Consumer Apps):**
1. **Offer Discovery**: Display available offers prominently in search results
2. **Offer Application**: Automatically apply eligible offers during booking
3. **Savings Display**: Show clear savings breakdown in pricing
4. **Offer Notifications**: Notify users about new and expiring offers

### **For BPPs (Service Providers):**
1. **Offer Management**: Create and manage promotional offers
2. **Validation Logic**: Implement offer validation and application rules
3. **Analytics**: Track offer performance and redemption rates
4. **Dynamic Pricing**: Adjust offers based on demand and inventory

### **For CPOs (Charge Point Operators):**
1. **Promotional Strategy**: Develop targeted promotional campaigns
2. **Offer Integration**: Integrate offers with charging infrastructure
3. **Customer Segmentation**: Create offers for different customer segments
4. **Performance Tracking**: Monitor offer effectiveness and ROI

## **Key Offer Features**

### **Offer Types**
- Percentage discounts
- Fixed amount discounts
- Buy-one-get-one offers
- Volume-based pricing
- Time-limited promotions

### **Validation Rules**
- Minimum session value requirements
- Maximum discount limits
- Validity periods
- Usage limits per customer
- Geographic restrictions

### **Dynamic Application**
- Automatic offer detection
- Best offer selection
- Stackable offers (where applicable)
- Real-time validation
- Expiration handling
