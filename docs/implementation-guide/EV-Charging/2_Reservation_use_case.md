# **Use case 2- Reservation of an EV charging time slot**

This section covers advance reservation of a charging slot where users discover and book a charger before driving to the location.

> **Note**: For general Beckn message flow and error handling, please refer to the [Overview](./0_Overview.md) section.

## **User journey**

Srilekha, a 29-year-old product manager driving from Bengaluru to Mysuru. She plans stops tightly and prefers reserving a charger next to reliable food options. About 30 minutes before her lunch window, Srilekha checks where she'll likely stop and decides to charge during lunch rather than add a separate halt.

**Discovery:** In her EV app, she filters for DC fast chargers near food courts/restaurants along her route. The app returns options with ETA from her live location, connector compatibility, tariff, and any active offers.

**Order (Reservation):** She selects a charger at a highway food court complex and books a time slot. The app presents session terms (rate, grace period/idle fee, cancellation rules) and payment choices (hold/prepay/postpay as supported). She confirms; a reservation ID and navigation link are issued.

**Fulfilment:** On arrival, Srilekha scans the charger QR, the booking is matched to her reservation, and charging starts. She tracks kWh, ₹, and ETA in-app while she eats. If she's a few minutes late, the system applies the defined grace period before releasing the slot.

**Post-Fulfilment:** Charging stops at target energy or when she ends the session. She receives a digital invoice and session summary. She rates the amenities around, overall experience at a scale of 1-5 at the end and continues with her trip.

## **API Calls and Schema**

### **Search** {#search}

Consumer searches for EV charging stations with specific criteria including location, connector type, time window, finder fee etc.

This is like typing "EV charger" into Google Maps and saying "find me charging stations within 5km of this location that have CCS2 connectors." The app sends this request to find available charging stations that match your criteria.

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
      },
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

**Search Criteria:**
* message.intent.descriptor.name: Free text search for charging stations (user can enter any search terms like "EV charger", "fast charging", etc.)  
* message.intent.category.descriptor.code: Category-based search filter (e.g., "green-tariff" for eco-friendly charging options)

**Location and Timing:**
* message.intent.fulfillment.stops[].location.circle.gps: GPS coordinates for search center (REQUIRED - format: "latitude,longitude")  
* message.intent.fulfillment.stops[].location.circle.radius.value: Search radius value (REQUIRED - e.g., "5")  
* message.intent.fulfillment.stops[].location.circle.radius.unit: Unit of measurement (REQUIRED - e.g., "km", "miles")  
* message.intent.fulfillment.stops[].time.range.start: Earliest acceptable charging start time (OPTIONAL - format: "YYYY:MM:DD:HH:MM:SS")  
* message.intent.fulfillment.stops[].time.range.end: Latest acceptable charging end time (OPTIONAL - format: "YYYY:MM:DD:HH:MM:SS")

**Connector Type Filtering:**
* message.intent.fulfillment.tags.list.descriptor.code: Connector type filter code (e.g., "connector-type")  
* message.intent.fulfillment.tags.list.value: Specific connector type value (e.g., "CCS2", "CHAdeMO", "Type 2")  
* Used by BPP to filter charging stations that match vehicle requirements

**Buyer Finder Fee Declaration:**
* message.intent.tags.descriptor.code: Tag group to describe the buyer finder fee or the commission amount for the BAP as part of the transaction.  
* Message.intent.tags.list.[descriptor.code="type"].value: Tag to define if the commission is a percentage of the order value or a flat amount. Possible values are "PERCENTAGE" and "AMOUNT"  
* Message.intent.tags.list.[descriptor.code="value"].value: Tag to define the buyer finder fee value.

### **on_search** {#on_search}

BPP returns a comprehensive catalog of available charging stations from multiple CPOs with detailed specifications, pricing, and location information.

1. Multiple providers (CPOs) with their charging networks  
2. Detailed location information with GPS coordinates  
3. Individual charging station specifications and pricing  
4. Connector types, power ratings, and availability status

This is the response you get back after searching - like getting a list of all nearby restaurants from Google Maps. It shows you all the charging stations available, their locations, prices, and what type of connectors they have. Think of it as a "charging station directory" for your area.

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

**Provider Information:**
* message.catalog.providers.id: Unique identifier for the charging network provider (CPO)  
* message.catalog.providers.descriptor.name: Display name of the charging network (e.g., "CPO1 EV charging Company")  
* message.catalog.providers.descriptor.short_desc: Brief description of provider's services and coverage area

**Location Details:**
* message.catalog.providers.locations.id: Unique location identifier for the charging station  
* message.catalog.providers.locations.gps: GPS coordinates of the charging station (format: "latitude,longitude")  
* message.catalog.providers.locations.descriptor.name: Human-readable name of the charging station  
* message.catalog.providers.locations.address: Full address of the charging station

**Availability Time Slots:**
* message.catalog.providers.fulfillments.stops[].time.range.start: Start time of available charging slot (format: "YYYY:MM:DD:HH:MM:SS")  
* message.catalog.providers.fulfillments.stops[].time.range.end: End time of available charging slot (format: "YYYY:MM:DD:HH:MM:SS")  
* Multiple stops entries represent different available time slots for the same charger location  
* Each time slot indicates when the charging station is available for booking or immediate use

**Charging Station Specifications (Items):**
* message.catalog.providers.items.id: Unique identifier for the specific charging point/EVSE  
* message.catalog.providers.items.descriptor.name: Human-readable name of the charging point  
* message.catalog.providers.items.price.value: Charging rate per unit (e.g., "18" for ₹18/kWh)  
* message.catalog.providers.items.price.currency: Currency and unit basis (e.g., "INR/kWh")

**Technical Specifications (Tags):**
* connector-id: Physical connector identifier at the charging station  
* power-type: Type of power delivery (e.g., "AC_3_PHASE", "DC")  
* connector-type: Connector standard (e.g., "CCS2", "CHAdeMO", "Type 2")  
* charging-speed: Relative charging speed classification (e.g., "FAST", "SLOW")  
* power-rating: Maximum power output in kilowatts (e.g., "30kW", "40kW")  
* status: Current availability status (e.g., "Available", "In Use", "Maintenance")

**Fulfillment and Category Links:**
* fulfillment_ids: Links to fulfillment options (charging service delivery methods)  
* category_ids: Links to program categories (e.g., "green-tariff" for eco-friendly options)  
* location_ids: Links to specific charging station locations

### **Select** {#select}

The consumer can select an EV charging time slot from a specific charging station to get the real time availability and quote from the BPP.

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

**Charging Station Specifications (Items):**
* message.order.items.id: Unique identifier for the specific charging point/EVSE

**Charging Session Information (Fulfillments):**
* message.order.fulfillments.id: Unique identifier for this charging session  
* message.order.fulfillments.stops.type: Session type (set to "start" for charging initiation and "stop" for ending the session)  
* message.order.fulfillments.stops.time.timestamp: Requested charging start timestamp and end timestamp. In case of future time slot bookings, the user will give the future requested time slot here. The BPP may respond with the nearest time slot available, if exact slots are not available for booking. If they are absent or if the timestamp is of current timestamp or of a timeframe within a short duration, this can be considered a spot booking scenario.

**Buyer Finder Fee Declaration:**
* message.order.tags.descriptor.code: Tag group to describe the buyer finder fee or the commission amount for the BAP as part of the transaction.  
* Message.order.tags.list.[descriptor.code="type"].value: Tag to define if the commission is a percentage of the order value or a flat amount. Possible values are "PERCENTAGE" and "AMOUNT"  
* Message.order.tags.list.[descriptor.code="value"].value: Tag to define the buyer finder fee value.

BAP can also support EV charging by kWh. Below is an example of the same:

```json
{
    "context": {
       "action": "select"
    },
    "message": {
      "order": {
        "item": {
           "id": "pe-charging-01",
            "quantity": {
              "selected": {
                "measure": {
                   "type": "CONSTANT",
                   "value": "2.5",
                   "unit": "kWh"
                }
             }
           }
       }
    }
  }
}
```

### **on_select** {#on_select}

Here the BPP returns with the estimated quote for the service. If the service is unavailable, the BPP returns with an error.

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
          "value": "100",
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
          }
        ]
      }
    }
  }
}
```


**Charging Session Information (Fulfillments):**
* message.order.fulfillments.id: Unique identifier for this charging session  
* message.order.fulfillments.stops.type: Session type (set to "start" for charging initiation and "stop" for ending the session)  
* message.order.fulfillments.stops.instructions: Suggested instructions to the end user for starting charging.  
* Message.order.fulfillments.stops.time.timestamp: The timeslot for which the quote is returned to the user by the BPP. Here the returned timeslot is slightly different from the selected timeslots based on availability from the end user.

**Quote Information:**
* message.order.quote.price.value: Total estimated price for the service (e.g., "118" INR after applying offer discount)  
* message.order.quote.currency: Currency of the total estimated price (e.g., "INR")  
* message.order.quote.breakup: Itemized breakdown of the total estimated price including:  
  * title: Description of the charge (e.g., "Charging session cost", "overcharge", "surge price(20%)", "offer discount(20%)")  
  * item.id: Identifier of the item the charge applies to (if applicable)  
  * price.value: Value of the individual charge in the breakup (positive for charges, negative for discounts)  
  * price.currency: Currency of the individual charge in the breakup  
  * Breakup includes base charges, additional fees, surge pricing, and promotional discounts from applied offers

### **init** {#init}

This step is like filling out a hotel room booking form - you're telling the charging station "I want to charge here, here's my contact info and billing details." It's the first step in actually doing transacting.

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
              "value": "10"
            }
          ]
        }
      ]
    }
  }
}
```


**Charging Session Information (Fulfillments):**
* message.order.fulfillments.id: Unique identifier for this charging session  
* message.order.fulfillments.stops.type: Session type (set to "start" for charging initiation)  
* message.order.fulfillments.stops.time.timestamp: Requested charging start timestamp and stop timestamp in case of future reservations.  
* message.order.fulfillments.customer.person.name: Customer name for session identification  
* message.order.fulfillments.customer.contact.phone: Customer phone for session coordination

**Billing Information:**
* message.order.billing.name: Customer's full name for billing purposes  
* message.order.billing.organization.descriptor.name: Company name if charging for business use  
* message.order.billing.address: Complete billing address for tax and invoice purposes  
* message.order.billing.email: Contact email for billing communications  
* message.order.billing.phone: Contact phone number for billing inquiries  
* message.order.billing.tax_id: GST number for business billing and tax compliance

### **on_init** {#on_init}

This is like getting a hotel room quote when you are booking a hotel room - "Your charging session will cost ₹100, here are the payment options." It's the charging station saying "I can accommodate your request, here are the terms and how to pay."

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
          "value": "100",
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
            "amount": "100.00",
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

In cases where BPP is collecting payment directly using a payment link and the payment terms dictate that the payment needs to be completed PRE-ORDER, once the payment completion event happens at the BPP’s payment gateway, the BPP may send an unsolicited on_status call to the BAP with payment.status changed to PAID. Once the BAP receives the same they can trigger the confirm API with payment.status as PAID.

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
          "state": {
            "descriptor": {
              "code": "PENDING",
              "name": "Charging Pending"
            },
            "updated_at": "2025-07-30T12:06:02Z",
            "updated_by": "bluechargenet-aggregator.io"
          },
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
                "short_desc": "Ground floor, Pillar Number 4"
              }
            },
            {
              "type": "START",
              "time": {
                "timestamp": "2025-07-16T11:00:00+05:30"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          },
        }
      ],
      "quote": {
        "price": {
          "value": "100",
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
            "amount": "100.00",
            "currency": "INR"
          },
          "type": "ON-ORDER",
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
              "name": "Charging active",
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

**Order Status:**
* message.order.id: Unique order identifier assigned by the BPP
* message.order.fulfillments.state.descriptor.code: Current order status (e.g., "PENDING")
* message.order.fulfillments.state.updated_at: Timestamp of last status update
* message.order.fulfillments.state.updated_by: System that updated the status


**Payment Information:**
* message.order.payments.id: Unique payment identifier for tracking  
* message.order.payments.collected_by: Who collects the payment (BPP in this case)  
* message.order.payments.url: Payment gateway URL for processing the transaction  
* message.order.payments.params:  
  * amount: Amount payable in this payment object  
  * currency: Currency of the payment  
  * bank_code: Bank code of the BPP to send the payment to if the payment method selected is bank transfer   
  * bank_account_number: Account number of the BPP to send the payment to if the payment method selected is bank transfer  
* message.order.payments.type: Payment timing (PRE-FULFILLMENT for advance payment)  
* message.order.payments.status: Current payment status (NOT-PAID initially)  
* message.order.payments.tags:  
  * descriptor.code: Code payment-methods is used to define the payment method options available to the user.  
  * List[].descriptor.code:  
    * "BANK-TRANSFER": Here the payment is made directly to the bank account  
    * "PAYMENT-LINK": Here the user will use the payment link returned by the BPP to make the payment directly to the BPP.   
    * "UPI-TRANSFER": Here the BPP will use the virtual payment address of the user to send a payment request. If the BAP is choosing this options, the source_virtual_payment_address will also need to be transmitted.

If authorization is required for confirming the order, the BPP will share message.order.fulfillments[].stops[].authorization.type with the type of authorization that would be required. The BAP will get the authorization data from the user and transmit the same in confirm API.

In cases where **BPP is collecting payment** directly using a payment link and the payment terms dictate that the payment needs to be completed PRE-ORDER, once the payment completion event happens at the BPP's payment gateway, the BPP may send an unsolicited on_status call to the BAP with payment.status changed to PAID. Once the BAP receives the same they can trigger the confirm API with payment.status as PAID.

### **confirm** {#confirm}

This is like clicking "Confirm Booking" on a hotel website after you've completed the payment. You're saying "Yes, I accept these terms and want to proceed with this charging session." The payment has already been processed (you can see the transaction ID in the message), and this is the final confirmation step before your charging session is officially booked.

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
            "amount": "100.00",
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


**Payment Confirmation:**
* message.order.payments.id: Payment identifier matching the on_init response  
* message.order.payments.status: Payment status (changed from "NOT-PAID" to "PAID")  
* message.order.payments.params.amount: Confirmed payment amount  
* Message.order.payments.params.source_virtual_payment_address: Virtual payment address to which the collect request will be sent to  
* message.order.payments.tags.list.descriptor.code: Selected payment method

### **on_confirm** {#on_confirm}

This is like getting a hotel confirmation email - "Your booking is confirmed! Here's your reservation number." The charging station is saying "Great! Your charging session is booked and ready. Here's your order ID and all the details."

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
      "id": "6743e9e2-4fb5-487c-92b7",
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
          "state": {
            "descriptor": {
              "code": "PENDING",
              "name": "Charging Pending"
            },
            "updated_at": "2025-07-30T12:06:02Z",
            "updated_by": "bluechargenet-aggregator.io"
          },
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
                "short_desc": "Ground floor, Pillar Number 4"
              }
            },
            {
              "type": "START",
              "time": {
                "timestamp": "2025-07-16T11:00:00+05:30"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          },
        }
      ],
      "quote": {
        "price": {
          "value": "100",
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
            "amount": "100.00",
            "currency": "INR"
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

**Order Status:**
* message.order.id: Unique order identifier assigned by the BPP  
* message.order.fulfillments.state.descriptor.code: Current order status (e.g., "PENDING")  
* message.order.fulfillments.state.updated_at: Timestamp of last status update  
* message.order.fulfillments.state.updated_by: System that updated the status

## **Additional API Calls**

The remaining API calls (update, on_update, track, on_track, rating, on_rating, support, on_support) work exactly the same as described in the [Walk-in Use Case](./1_Walkin_use_case.md). Please refer to that document for complete API specifications and examples.

> **Post-Booking Flow:**
> 
> Once the user has successfully booked a slot through the reservation flow described above:
> 
> 1. The user MUST drive to the charging location at the scheduled time
> 2. The user MUST physically plug their vehicle into the booked charging point
> 3. The user SHALL initiate the charging session using the `update` API call
> 4. The BPP SHALL respond with session confirmation via the `on_update` callback
> 5. The user MAY monitor the charging progress in real-time using the `track` and `on_track` APIs
> 6. The BPP SHALL provide live session data including energy delivered, cost, and estimated completion time
> 
> For detailed specifications of these post-booking APIs (`update`, `on_update`, `track`, `on_track`), please refer to the corresponding sections in the [Walk-in Use Case](./1_Walkin_use_case.md#update-start-charging) documentation.

## **Key Differences from Walk-in Flow**

1. **Timing**: All API calls happen in advance rather than at the charging location
2. **Availability**: Time slots are for future booking rather than immediate use
3. **Grace Period**: System handles late arrivals with defined grace periods
4. **Reservation Management**: Order includes reservation ID and navigation details
5. **Cancellation**: More complex cancellation terms for advance bookings
