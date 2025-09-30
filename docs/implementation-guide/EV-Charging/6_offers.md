# **Use case 6- Offers**

This section covers promotional offers and discounts that can be applied to EV charging sessions, including time-based promotions, loyalty discounts, and special pricing schemes.

> **Note**: For general Beckn message flow and error handling, please refer to the [Overview](./0_Overview.md) section.

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

While browsing the charging app for a session, Srilekha notices a banner:

> "Limited Time Offer: ₹20 off when you charge above 5 kWh – Valid till Sunday!"

### **Discovery**

Srilekha searches for a charger. The app shows eligible stations with a badge or label indicating the reward:

* "Offer: ₹20 off above 5 kWh"
* Visible next to charger name or on charger details screen
* Optional "Know More" link to view:
  - Offer conditions
  - Validity window
  - Eligible locations

### **Charging Session Initiation**

Srilekha selects a charger that displays the reward. Before starting, she sees a preview:

* Estimated cost based on kWh
* Reward condition reminder: "Charge ≥5 kWh to get ₹20 off"
* Final price estimate with and without reward

### **Charging**

While charging, the app shows real-time updates (optional):

* Energy delivered
* How close she is to hitting the reward threshold
* "You will unlock ₹20 off!" once 5 kWh is crossed

If the session ends before meeting the threshold, app shows:

* "You used 3.2 kWh - reward not applied"

### **Post-Charging**

Srilekha receives a receipt or invoice with a clear breakdown:

* Base charge (e.g., ₹60)
* Reward discount (e.g., – ₹20)
* Final amount paid (e.g., ₹40)
* Message: "Thanks for charging with us. You saved ₹20 with this week's offer!"

## **Offer Object Fields**

The following fields in the offer object provide detailed information about promotional offers:

* **message.catalog.providers.offers.id:** Unique identifier for the promotional offer
* **message.catalog.providers.offers.descriptor.name:** Human-readable name of the offer (e.g., "Early Bird Charging Special")
* **message.catalog.providers.offers.descriptor.code:** Machine-readable offer code (e.g., "early-bird-discount")
* **message.catalog.providers.offers.descriptor.short_desc:** Brief description of the offer benefits
* **message.catalog.providers.offers.descriptor.long_desc:** Detailed explanation of offer terms, conditions, and target audience
* **message.catalog.providers.offers.descriptor.images:** Visual promotional materials for the offer
* **message.catalog.providers.offers.location_ids:** Specific charging locations where the offer is applicable
* **message.catalog.providers.offers.item_ids:** Specific charging items/services covered by the offer
* **message.catalog.providers.offers.tags:** Structured offer metadata including discount percentage, validity periods, applicable days, and offer type classification

## **API Implementation**

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
                    "address": "Connaught Place, New Delhi"
                  },
                  "time": {
                    "range": {
                      "start": "2025:09:24:10:00:00",
                      "end": "2025:09:24:11:00:00"
                    }
                  }
                },
                {
                  "location": {
                    "gps": "28.6304,77.2177",
                    "address": "Connaught Place, New Delhi"
                  },
                  "time": {
                    "range": {
                      "start": "2025:09:24:12:00:00",
                      "end": "2025:09:24:13:00:00"
                    }
                  }
                }
              ]
            },
            {
              "id": "fulfillment-002",
              "type": "CHARGING",
              "stops": [
                {
                  "location": {
                    "gps": "28.6310,77.2200",
                    "address": "Saket, New Delhi"
                  },
                  "time": {
                    "range": {
                      "start": "2025:09:24:11:00:00",
                      "end": "2025:09:24:12:00:00"
                    }
                  }
                },
                {
                  "location": {
                    "gps": "28.6310,77.2200",
                    "address": "Saket, New Delhi"
                  },
                  "time": {
                    "range": {
                      "start": "2025:09:24:15:00:00",
                      "end": "2025:09:24:16:00:00"
                    }
                  }
                }
              ]
            }
          ],
          "offers": [
            {
              "id": "offer-001",
              "descriptor": {
                "name": "Early Bird Charging Special",
                "code": "early-bird-discount",
                "short_desc": "20% off on all charging sessions booked before 12 PM",
                "long_desc": "Get 20% discount on both AC and DC fast charging at our Connaught Place station when you book your charging slot before 12:00 PM. Valid for all connector types including CCS2. Perfect for early commuters and business travelers.",
                "images": [
                  {
                    "url": "https://cpo1.com/images/early-bird-offer.png"
                  }
                ]
              },
              "location_ids": [
                "LOC-DELHI-001"
              ],
              "item_ids": [
                "pe-charging-01",
                "pe-charging-02"
              ],
              "time": {
                "range": {
                  "start": "2025-09-16T04:00:00Z",
                  "end": "2025-09-16T012:00:00Z"
                }
              }
            },
            {
              "id": "offer-002",
              "descriptor": {
                "name": "Location Based Offer",
                "short_desc": "10% off on all orders from our new location"
              },
              "location_ids": [
                "LOC-DELHI-001"
              ]
            }
          ],
          "items": [
            {
              "id": "pe-charging-01",
              "descriptor": {
                "name": "EV Charger #1 (AC Fast Charger)",
                "code": "CHARGER"
              },
              "price": {
                "value": "18",
                "currency": "INR/kWh"
              },
              "fulfillment_ids": [
                "fulfillment-001"
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
            },
            {
              "id": "pe-charging-02",
              "descriptor": {
                "name": "EV Charger #1 (AC Fast Charger)",
                "code": "CHARGER",
                "short_desc": "Spot Booking"
              },
              "price": {
                "value": "21",
                "currency": "INR/kWh"
              },
              "fulfillment_ids": [
                "fulfillment-001"
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
            },
            {
              "id": "pe-charging-02",
              "descriptor": {
                "name": "EV Charger #2 (DC Fast Charger)",
                "code": "CHARGER"
              },
              "price": {
                "value": "25",
                "currency": "INR/kWh"
              },
              "fulfillment_ids": [
                "fulfillment-002"
              ],
              "location_ids": [
                "LOC-DELHI-002"
              ],
              "tags": [
                {
                  "descriptor": {
                    "name": "Connector Specifications"
                  },
                  "list": [
                    {
                      "descriptor": {
                        "name": "connector ID",
                        "code": "connector-id"
                      },
                      "value": "2"
                    },
                    {
                      "descriptor": {
                        "name": "Power Type",
                        "code": "power-type"
                      },
                      "value": "DC"
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
                      "value": "CABLE"
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
                      "value": "40kW"
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
              "id": "pe-charging-02",
              "descriptor": {
                "name": "EV Charger #2 (DC Fast Charger)",
                "code": "CHARGER",
                "short_desc": "Spot Booking"
              },
              "price": {
                "value": "28",
                "currency": "INR/kWh"
              },
              "fulfillment_ids": [
                "fulfillment-002"
              ],
              "location_ids": [
                "LOC-DELHI-002"
              ],
              "tags": [
                {
                  "descriptor": {
                    "name": "Connector Specifications"
                  },
                  "list": [
                    {
                      "descriptor": {
                        "name": "connector ID",
                        "code": "connector-id"
                      },
                      "value": "2"
                    },
                    {
                      "descriptor": {
                        "name": "Power Type",
                        "code": "power-type"
                      },
                      "value": "DC"
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
                      "value": "CABLE"
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
                      "value": "40kW"
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
          "id": "offer-001"
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

### **on_select with Offer Pricing**

<make consistent with RFC style language>The BPP responds with pricing that includes the applied offer discount. The offer discount reflects in the quotation object.

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
          "value": "82",
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
            "title": "offer discount(20%)",
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
          "value": "82",
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
            "title": "offer discount(20%)",
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
            "amount": "82.00",
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
            "value": "65"
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
