# **Use case 7- Surcharge**

This section covers surcharge scenarios where additional fees are applied to EV charging sessions based on various factors such as peak demand, location, time of day, or special circumstances.

> **Note**: For general Beckn message flow and error handling, please refer to the [Overview](./0_Overview.md#general-beckn-message-flow-and-error-handling) section.

## **Surcharge Types**

### **Peak Demand Surcharge**
- High demand periods (e.g., evening rush hours)
- Grid stress conditions
- Weather-related demand spikes
- Holiday or event-driven demand

### **Location-Based Surcharge**
- Premium locations (airports, malls, city centers)
- High-cost areas (prime real estate)
- Remote locations with higher infrastructure costs
- Special zones (highway rest stops, tourist areas)

### **Time-Based Surcharge**
- Peak hours (6-9 AM, 6-9 PM)
- Weekend surcharges
- Holiday surcharges
- Night-time surcharges (for 24/7 operations)

### **Service-Based Surcharge**
- Fast charging premium
- Priority access fees
- Additional services (valet charging, cleaning)
- Emergency charging services

### **Environmental Surcharge**
- Carbon offset fees
- Renewable energy premium
- Environmental impact charges
- Sustainability initiatives

## **User Journey**

**Peak Hour Charging:**
David, a commuter, arrives at a charging station during evening rush hour (6:30 PM). The app shows the base rate of ₹18/kWh but also displays a "Peak Hour Surcharge: +20%" notice. The total rate becomes ₹21.60/kWh, and David can see the breakdown clearly before confirming his session.

**Airport Charging:**
Sarah needs to charge her EV at the airport before a business trip. The app shows a "Location Surcharge: +₹5/kWh" for the premium airport location, making the total rate ₹23/kWh. She understands this is due to the premium location and higher operational costs.

**Emergency Charging:**
Mike's EV is running low on battery and he needs immediate charging. The app offers an "Emergency Service" option with a 50% surcharge for immediate priority access, bringing the rate to ₹27/kWh.

## **API Implementation**

### **Search with Surcharge Information**

The consumer searches for charging stations and can see surcharge information in the search results.

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
                "start": "2025:09:24:18:00:00",
                "end": "2025:09:24:20:00:00"
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

### **on_search with Surcharge Details**

The BPP responds with charging stations that include surcharge information and pricing details.

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
          "items": [
            {
              "id": "pe-charging-01",
              "descriptor": {
                "name": "EV Charger #1 (AC Fast Charger)",
                "code": "ev-charger",
                "short_desc": "Fast charging with peak hour surcharge"
              },
              "price": {
                "value": "18",
                "currency": "INR/kWh"
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
                },
                {
                  "descriptor": {
                    "code": "surcharge-details",
                    "name": "Surcharge Information"
                  },
                  "list": [
                    {
                      "descriptor": {
                        "code": "peak-hour-surcharge",
                        "name": "Peak Hour Surcharge"
                      },
                      "value": "20%"
                    },
                    {
                      "descriptor": {
                        "code": "peak-hours",
                        "name": "Peak Hours"
                      },
                      "value": "18:00-20:00"
                    },
                    {
                      "descriptor": {
                        "code": "location-surcharge",
                        "name": "Location Surcharge"
                      },
                      "value": "₹2/kWh"
                    },
                    {
                      "descriptor": {
                        "code": "surcharge-reason",
                        "name": "Surcharge Reason"
                      },
                      "value": "Premium location + Peak demand"
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
                      "start": "2025:09:24:18:00:00",
                      "end": "2025:09:24:20:00:00"
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

### **Select with Surcharge**

The consumer selects a charging station with surcharge applied.

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
    "timestamp": "2025:09:24:18:30:00",
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
                "timestamp": "2025:09:24:18:30:00"
              }
            },
            {
              "type": "STOP",
              "time": {
                "timestamp": "2025:09:24:19:30:00"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          }
        }
      ],
      "tags": [
        {
          "descriptor": {
            "code": "surcharge-request",
            "name": "Surcharge Request"
          },
          "list": [
            {
              "descriptor": {
                "code": "apply-surcharge",
                "name": "Apply Surcharge"
              },
              "value": "true"
            },
            {
              "descriptor": {
                "code": "surcharge-type",
                "name": "Surcharge Type"
              },
              "value": "PEAK_HOUR"
            }
          ]
        }
      ]
    }
  }
}
```

### **on_select with Surcharge Pricing**

The BPP responds with pricing that includes the applied surcharge.

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
    "timestamp": "2025:09:24:18:30:30"
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
                "timestamp": "2025:09:24:18:30:00"
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
                "timestamp": "2025:09:24:19:30:00"
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
          "value": "120",
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
            "title": "Peak Hour Surcharge (20%)",
            "price": {
              "currency": "INR",
              "value": "18"
            }
          },
          {
            "title": "Location Surcharge (₹2/kWh)",
            "price": {
              "currency": "INR",
              "value": "10"
            }
          },
          {
            "title": "GST (18%)",
            "price": {
              "currency": "INR",
              "value": "22.60"
            }
          }
        ]
      },
      "tags": [
        {
          "descriptor": {
            "code": "surcharge-breakdown",
            "name": "Surcharge Breakdown"
          },
          "list": [
            {
              "descriptor": {
                "code": "base-rate",
                "name": "Base Rate"
              },
              "value": "₹18/kWh"
            },
            {
              "descriptor": {
                "code": "peak-surcharge",
                "name": "Peak Hour Surcharge"
              },
              "value": "20%"
            },
            {
              "descriptor": {
                "code": "location-surcharge",
                "name": "Location Surcharge"
              },
              "value": "₹2/kWh"
            },
            {
              "descriptor": {
                "code": "effective-rate",
                "name": "Effective Rate"
              },
              "value": "₹23.60/kWh"
            },
            {
              "descriptor": {
                "code": "surcharge-valid-until",
                "name": "Surcharge Valid Until"
              },
              "value": "2025:09:24:20:00:00"
            }
          ]
        }
      ]
    }
  }
}
```

### **Init with Surcharge**

The consumer initiates the charging session with surcharge applied.

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
    "timestamp": "2025:09:24:18:35:00",
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
                "timestamp": "2025:09:24:18:30:00"
              }
            },
            {
              "type": "STOP",
              "time": {
                "timestamp": "2025:09:24:19:30:00"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          },
          "customer": {
            "person": {
              "name": "David Smith"
            },
            "contact": {
              "phone": "+91-9876543210"
            }
          }
        }
      ],
      "billing": {
        "name": "David Smith",
        "address": "456 Park Street, Mumbai, Maharashtra, 400001, India",
        "email": "david.smith@email.com",
        "phone": "+91-9876543210",
        "time": {
          "timestamp": "2025:09:24:18:35:00Z"
        }
      },
      "tags": [
        {
          "descriptor": {
            "code": "surcharge-acceptance",
            "name": "Surcharge Acceptance"
          },
          "list": [
            {
              "descriptor": {
                "code": "surcharge-accepted",
                "name": "Surcharge Accepted"
              },
              "value": "true"
            },
            {
              "descriptor": {
                "code": "surcharge-acknowledgment",
                "name": "Surcharge Acknowledgment"
              },
              "value": "User acknowledges peak hour surcharge"
            }
          ]
        }
      ]
    }
  }
}
```

### **on_init with Surcharge Confirmation**

The BPP confirms the surcharge application and provides payment details.

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
    "timestamp": "2025:09:24:18:35:30"
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
                "timestamp": "2025:09:24:18:30:00"
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
                "timestamp": "2025:09:24:19:30:00"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          },
          "customer": {
            "person": {
              "name": "David Smith"
            },
            "contact": {
              "phone": "+91-9876543210"
            }
          }
        }
      ],
      "billing": {
        "name": "David Smith",
        "address": "456 Park Street, Mumbai, Maharashtra, 400001, India",
        "email": "david.smith@email.com",
        "phone": "+91-9876543210",
        "time": {
          "timestamp": "2025:09:24:18:35:00Z"
        }
      },
      "quote": {
        "price": {
          "value": "120",
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
            "title": "Peak Hour Surcharge (20%)",
            "price": {
              "currency": "INR",
              "value": "18"
            }
          },
          {
            "title": "Location Surcharge (₹2/kWh)",
            "price": {
              "currency": "INR",
              "value": "10"
            }
          },
          {
            "title": "GST (18%)",
            "price": {
              "currency": "INR",
              "value": "22.60"
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
            "amount": "120",
            "currency": "INR"
          },
          "type": "PRE-FULFILLMENT",
          "status": "NOT-PAID"
        }
      ],
      "tags": [
        {
          "descriptor": {
            "code": "surcharge-details",
            "name": "Surcharge Details"
          },
          "list": [
            {
              "descriptor": {
                "code": "surcharge-applied",
                "name": "Surcharge Applied"
              },
              "value": "true"
            },
            {
              "descriptor": {
                "code": "surcharge-types",
                "name": "Surcharge Types"
              },
              "value": "PEAK_HOUR,LOCATION"
            },
            {
              "descriptor": {
                "code": "total-surcharge",
                "name": "Total Surcharge"
              },
              "value": "₹28"
            },
            {
              "descriptor": {
                "code": "surcharge-percentage",
                "name": "Surcharge Percentage"
              },
              "value": "28%"
            }
          ]
        }
      ]
    }
  }
}
```

### **Session Completion with Surcharge Details**

The final session update includes detailed surcharge application and final pricing.

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
    "timestamp": "2025:09:24:19:35:00",
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
                "value": "5.1",
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
            "updated_at": "2025:09:24:19:35:00Z",
            "updated_by": "charging-system"
          },
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2025:09:24:18:30:00+05:30"
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
                "timestamp": "2025:09:24:19:30:00+05:30"
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
              "name": "David Smith"
            },
            "contact": {
              "phone": "+91-9876543210"
            }
          }
        }
      ],
      "billing": {
        "name": "David Smith",
        "address": "456 Park Street, Mumbai, Maharashtra, 400001, India",
        "email": "david.smith@email.com",
        "phone": "+91-9876543210",
        "time": {
          "timestamp": "2025:09:24:18:35:00Z"
        }
      },
      "quote": {
        "price": {
          "value": "122.40",
          "currency": "INR"
        },
        "breakup": [
          {
            "title": "Charging session cost (5.1 kWh @ ₹18.00/kWh)",
            "item": {
              "id": "pe-charging-01"
            },
            "price": {
              "value": "91.80",
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
            "title": "Peak Hour Surcharge (20%)",
            "price": {
              "currency": "INR",
              "value": "18.36"
            }
          },
          {
            "title": "Location Surcharge (₹2/kWh)",
            "price": {
              "currency": "INR",
              "value": "10.20"
            }
          },
          {
            "title": "GST (18%)",
            "price": {
              "currency": "INR",
              "value": "22.04"
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
            "amount": "122.40",
            "currency": "INR"
          }
        }
      ],
      "tags": [
        {
          "descriptor": {
            "code": "surcharge-summary",
            "name": "Surcharge Summary"
          },
          "list": [
            {
              "descriptor": {
                "code": "base-cost",
                "name": "Base Cost"
              },
              "value": "₹101.80"
            },
            {
              "descriptor": {
                "code": "total-surcharge",
                "name": "Total Surcharge"
              },
              "value": "₹28.56"
            },
            {
              "descriptor": {
                "code": "surcharge-breakdown",
                "name": "Surcharge Breakdown"
              },
              "value": "Peak Hour: ₹18.36, Location: ₹10.20"
            },
            {
              "descriptor": {
                "code": "surcharge-percentage",
                "name": "Surcharge Percentage"
              },
              "value": "28%"
            },
            {
              "descriptor": {
                "code": "effective-rate",
                "name": "Effective Rate"
              },
              "value": "₹24/kWh"
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
1. **Surcharge Display**: Clearly show surcharge information in search results
2. **Transparent Pricing**: Display surcharge breakdown in pricing details
3. **User Consent**: Obtain user acknowledgment for surcharge application
4. **Real-time Updates**: Update surcharge information based on time and conditions

### **For BPPs (Service Providers):**
1. **Surcharge Logic**: Implement dynamic surcharge calculation algorithms
2. **Condition Monitoring**: Monitor conditions that trigger surcharges
3. **Pricing Transparency**: Provide clear surcharge explanations
4. **Analytics**: Track surcharge impact on usage patterns

### **For CPOs (Charge Point Operators):**
1. **Surcharge Strategy**: Develop surcharge policies for different scenarios
2. **Infrastructure Integration**: Connect surcharge systems with charging infrastructure
3. **Customer Communication**: Clearly communicate surcharge policies
4. **Performance Monitoring**: Monitor surcharge effectiveness and customer impact

## **Key Surcharge Features**

### **Dynamic Application**
- Real-time surcharge calculation
- Time-based surcharge triggers
- Location-based surcharge application
- Demand-based surcharge adjustment

### **Transparency Requirements**
- Clear surcharge explanations
- Detailed pricing breakdowns
- Advance notice of surcharge changes
- User acknowledgment of surcharge acceptance

### **Flexibility Options**
- Multiple surcharge types
- Stackable surcharges
- Conditional surcharge application
- Surcharge exemptions for certain users

### **Monitoring and Analytics**
- Surcharge impact on usage
- Customer behavior analysis
- Revenue optimization
- Demand management effectiveness
