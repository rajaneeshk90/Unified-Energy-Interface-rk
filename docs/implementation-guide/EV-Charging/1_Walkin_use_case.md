# **Use case 1- Walk-In to a charging station without reservation**

This section covers a walk-in case where users discover the charger using third-party apps, word of mouth, or Beckn API, and then drive to the location without advance booking.

> **Note**: For general Beckn message flow and error handling, please refer to the [Overview](./0_Overview.md) section.

## **Technical Implementation Perspective**

From a technical standpoint, this walk-in scenario is comparable to booking an instant slot after reaching the location. While it may appear different from a user experience perspective, the underlying API calls and system processes remain largely the same as the advance reservation use case, with key differences in timing and availability checks:

* Real-time availability: The system checks for immediate slot availability instead of future time slots  
* Instant booking: The entire discovery → select → init → confirm flow happens within minutes at the physical location  
* Same API endpoints: Uses identical Beckn protocol calls but with compressed timeframes  
* Immediate fulfillment: The charging session can start immediately after confirmation, rather than waiting for a scheduled time

## **Operational Context**

The order flow happens while the user is physically present at the charging station. This creates a more compressed transaction timeline where all booking steps occur on-site, making it essential for the system to handle real-time availability updates and quick response times to ensure a smooth user experience.

## **User journey**

A 34-year-old sales manager who drives an EV to client meetings. He's time-bound, cost-conscious, and prefers simple, scan-and-go experiences. Raghav arrives at a large dine-in restaurant for a one-hour client meeting. He notices a charging bay in the parking lot and decides to top up while he's inside.

**Discovery:** Raghav opens his EV app, taps sScan & Charge, and scans the QR on the charger. The app pulls the charger's details (connector, power rating, live status, tariff, any active time-bound offer).

**Order:** Raghav selects a 60-minute top-up, reviews session terms (rate, idle fee window, cancellation rules), and confirms. He chooses UPI and authorizes payment (or an authorization hold, as supported). The app returns a booking/transaction ID.

**Fulfilment:** He plugs in and starts the session from the app. Live progress (kWh, ₹ consumed, ETA) is shown while he's in the meeting. If the bay has a lunch-hour promo, the discounted rate is applied automatically.

**Post-Fulfilment:** At ~60 minutes, the session stops (or notifies him to unplug). He receives a digital invoice and session summary in-app. If anything went wrong (e.g., session interrupted, SOC reaches 100%, etc.), the app reconciles to bill only for energy delivered and issues any adjustment or refund automatically.

## **API Calls and Schema**

> **Note on Discovery Methods**: 
> 
> In walk-in scenarios, discovery of charging stations MAY occur through various off-network channels including, but not limited to:
> - Physical signage at the location
> - Word-of-mouth recommendations
> - Third-party mapping applications
> - Other non-Beckn discovery mechanisms
>
> Network Participants (NPs) MAY choose to implement the discovery APIs described below to provide additional discovery capabilities. When implemented:
> - BAPs MUST support the complete discovery flow as specified
> - BPPs MUST respond with real-time availability and pricing information
> - The discovery flow MUST maintain consistency with other booking flows
>
> The following sections detail the discovery APIs for implementations that choose to support them.

### **Search**

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
**Alternative Discovery Scenario:**

Another possibility is that users discover the charging station through off-network channels (such as physical signage, word-of-mouth, or third-party apps not integrated with Beckn) and arrive directly at the location to initiate charging. In this scenario:

* The discovery phase is skipped entirely  
* Users proceed directly to the Select API call by scanning QR codes or using location-based identification  
* The charging station must be able to handle direct selection requests without prior search/discovery  
* This represents a more streamlined flow for walk-in customers who have already identified their preferred charging location

### **on_search**

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

### **select** 

Once at the charging station, the user physically connects their EV to a charging slot. This action represents the initiation of the fulfillment process.

The fulfillment start time attribute SHALL be set to the current timestamp, indicating immediate commencement of the charging session. The fulfillment end time attribute SHALL be determined based on the user’s specified requirement, such as desired energy intake, duration, or departure time.

This is like clicking on a specific restaurant from the Google Maps results - you're saying "I want to book this particular charging station with this specific connector type."

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

**Selection Details:**
* message.order.provider.id: Selected charging network provider ID
* message.order.items.id: Selected charging station/connector ID
* message.order.items.quantity.selected.measure.value: Desired charging duration
* message.order.items.quantity.selected.measure.unit: Time unit (e.g., "MINUTES", "HOURS")
* message.order.fulfillments.stops.time.range: Preferred charging time window

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

### **on_select** 

BPP confirms the selection and provides detailed pricing, terms, and next steps.

This is like getting a detailed quote from the restaurant - "Here's exactly what you'll get, how much it costs, and what happens next."

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

**Quote Details:**
* message.order.quote.price.value: Total estimated cost
* message.order.quote.price.currency: Currency for the transaction
* message.order.quote.breakup: Itemized breakdown of costs
* message.order.quote.breakup[].title: Description of each cost component
* message.order.quote.breakup[].price: Amount for each component

### **init** 

Consumer initiates the transaction by accepting the quote and providing payment details.

This is like clicking "Proceed to Payment" after reviewing your restaurant booking details. You're saying "I agree to these terms and prices, let's move forward with payment."

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

**Initialization Details:**
* message.order.billing: Customer billing information
* message.order.billing.name: Customer's full name
* message.order.billing.organization: Business details if applicable
* message.order.billing.address: Complete billing address
* message.order.billing.tax_id: GST number or other tax identifier
* message.order.fulfillments.customer: Customer contact details for the charging session

### **on_init**

BPP confirms the initialization and provides payment details.

This is like getting the final payment screen with all the payment options and instructions. The charging station is saying "Great! Here's how you can pay for your charging session."

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

**Payment Details:**
* message.order.payments[].collected_by: Entity collecting the payment (BPP/BAP)
* message.order.payments[].params.transaction_id: Unique payment transaction identifier
* message.order.payments[].params.amount: Amount to be paid
* message.order.payments[].status: Current payment status
* message.order.payments[].type: When payment is collected (pre/post fulfillment)
* message.order.payments[].url: Payment gateway URL


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

### **confirm**

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

**Order Status:**
* message.order.id: Unique order identifier assigned by the BPP
* message.order.fulfillments.state.descriptor.code: Current order status (e.g., "PENDING")
* message.order.fulfillments.state.updated_at: Timestamp of last status update
* message.order.fulfillments.state.updated_by: System that updated the status

### **on_confirm** 

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

### **update** (start charging)

#### Physical Charging Process

Before initiating the charging session through the API, the EV driver must complete the following physical steps at the charging station:

1. **Drive to the charging point:** The user arrives at the reserved charging location at the scheduled time
2. **Plug the vehicle:** Connect the charging cable from the EVSE (Electric Vehicle Supply Equipment) to their vehicle's charging port
3. **Provide the OTP:** Enter or scan the OTP received during the init process to authenticate and authorize the start of the charging session

Once these physical steps are completed, the charging session can be initiated through the update API call.

> This is like pressing the "Start" button on a washing machine. You're telling the charging station "I'm ready to start charging now, please begin the session." It's the moment when you actually start using the charging service you booked.

```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "update",
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
    "update_target": "order.fulfillments[0].state",
    "order": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "fulfillments": [
        {
          "id": "fulfillment-001",
          "type": "CHARGING",
          "state": {
            "descriptor": {
              "code": "start-charging"
            }
          },
          "stops": [
            {
              "authorization": {
                "type": "OTP",
                "token": "7484"
              }
            }
          ]
        }
      ]
    }
  }
}
```

**Update Target:**
* message.update_target: Specifies which part of the order to update (e.g., "order.fulfillments.state")
* message.order.id: Order identifier from the confirmed booking
* State Change:
* message.order.fulfillments.state.descriptor.code: New state value (e.g., "start-charging")
* message.order.fulfillments.type: Service type (set to "CHARGING")
* Authorization:
* message.order.fulfillments.stops.authorization.token: Authorization token for the charging session. This token validates that the user is authorized to start charging at this station.

### **on_update** (start charging)
* This is like getting a "Washing Started" notification from your washing machine. The charging station is saying "Perfect! Your charging session has begun. You can now track your progress and see how much energy is being delivered to your vehicle."

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
              "code": "ACTIVE",
              "name": "Charging in progress"
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
          "collected_by": "bpp",
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

**Session Status Update:**
* message.order.fulfillments.state.descriptor.code: Current session status (changed to "ACTIVE")
* message.order.fulfillments.state.updated_at: Timestamp when charging started
* message.order.fulfillments.state.updated_by: System that initiated the charging session

### **track**

This is like asking "Where's my package?" on an e-commerce website. You're requesting a link to monitor your charging session in real-time - how much energy has been delivered, how much it's costing, and when it will be complete. Think of it as getting a "live dashboard" for your charging session.

```json
{
    "context": {
        "domain": "deg:ev-charging",
        "action": "track",
        "location": {
            "city": {
                "code": "std:080"
            },
            "country": {
                "code": "IND"
            }
        },
        "bap_id": "example-bap.com",
        "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
        "bpp_id": "example-bpp.com",,
        "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
        "transaction_id": "e0a38442-69b7-4698-aa94-a1b6b5d244c2",
        "message_id": "6ace310b-6440-4421-a2ed-b484c7548bd5",
        "timestamp": "2023-02-18T17:00:40.065Z",
        "version": "1.0.0",
        "ttl": "PT10M"
    },
    "message": {
        "order_id": "b989c9a9-f603-4d44-b38d-26fd72286b38"
        "callback_url": "https://example-bap-url.com/SESSION/5e4f"
    }
}
```

**Tracking Request:**
* **message.order_id:** Unique order identifier for the charging session to track. This links the tracking request to the specific booking.
* **message.callback_url:** Optional URL which can be provided by the BAP, to which the BPP will trigger PATCH requests (with only fields to be updated and any fields that are left out remain unchanged) with real time details of the charging session.

> **Tip for NFOs:** The structure and frequency for the PATCH requests may be decided based on the needs of the network by the NFO. A suggested request structure for the PATCH requests can be found below based on session details in OCPI-2.2.1:

```json
{
  "kwh": 7.35,
  "status": "ACTIVE",
  "currency": "INR",
  "charging_periods": [
    {
      "start_date_time": "2025-09-17T10:55:00Z",
      "dimensions": [
        { "type": "ENERGY", "volume": 0.25 },
        { "type": "POWER",  "volume": 7.2  },
        { "type": "CURRENT","volume": 16.0 },
        { "type": "VOLTAGE","volume": 230.0 },
        { "type": "STATE_OF_CHARGE","volume": 63.0 }
      ]
    }
  ],
  "total_cost": {
    "excl_vat": 78.50,
    "incl_vat": 92.63
  },
  "last_updated": "2025-09-17T10:55:05Z"
}
```

**Session Data Structure:**
* **kwh:** Total energy consumed during the session in kilowatt-hours
* **status:** Current status of the charging session (e.g., "ACTIVE", "COMPLETED")
* **currency:** Currency used for charging costs (e.g., "INR")
* **charging_periods:** Array containing details of different charging intervals within the session
  - **start_date_time:** Timestamp when the charging period started
  - **dimensions:** Array of measurements during the charging period
  - **type:** Type of measurement (e.g., "ENERGY", "POWER", "CURRENT", "VOLTAGE", "STATE_OF_CHARGE" as per CdrDimensionType enum in OCPI-2.2.1)
  - **volume:** Value of the measurement
* **total_cost:** Breakdown of the total cost for the session
  - **excl_vat:** Total cost excluding VAT
  - **incl_vat:** Total cost including VAT
* **last_updated:** Timestamp of the last update to the session details

### **on_track**

This is like getting a FedEx tracking link - "Click here to see your package's journey." The charging station is giving you a special webpage where you can watch your charging session live, see the current power being delivered, and get real-time updates on your charging progress.

```json
{
    "context": {
        "domain": "deg:ev-charging",
        "action": "on_track",
        "location": {
            "city": {
                "code": "std:080"
            },
            "country": {
                "code": "IND"
            }
        },
        "bap_id": "example-bap.com",
        "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
        "bpp_id": "example-bpp.com",,
        "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
        "transaction_id": "e0a38442-69b7-4698-aa94-a1b6b5d244c2",
        "message_id": "6ace310b-6440-4421-a2ed-b484c7548bd5",
        "timestamp": "2023-02-18T17:00:40.065Z",
        "version": "1.0.0",
        "ttl": "PT10M"
    },
    "message": {
        "tracking": {
            "id": "TRACK-SESSION-9876543210",
            "url": "https://track.bluechargenet-aggregator.io/session/SESSION-9876543210",
            "status": "ACTIVE"
        }
    }
}
```

**Tracking Response:**
* **message.tracking.id:** Unique tracking identifier for the charging session
* **message.tracking.url:** Live tracking dashboard URL for monitoring charging progress
* **message.tracking.status:** Current tracking status (e.g., "active" for ongoing session)

### **Asynchronous on_status** (temporary connection interruption)

This is used in case of a connection interruption during a charging session.

* Applicable only in case of temporary connection interruptions, BPPs expect to recover from these connection interruptions in the short term
* BPP notifies the BAP about this interruption using an unsolicited on_status callback

> **NOTE:** If the issue remains unresolved and BPP expects it to be a long term issue, BPP must send an unsolicited on_update to the BAP with relevant details.

> **Understanding Overcharge and Undercharge Scenarios:** For detailed information on handling billing adjustments when charging sessions are interrupted or experience connectivity issues (leading to undercharge or overcharge situations), please refer to the [Undercharge & Overcharge](./3_Under_and_overcharge.md) use case documentation.

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
                  "value": "con1"
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
              "code": "CONNECTION-INTERRUPTED",
              "name": "Charging connection lost. Retrying automatically. If this continues, please check your cable"
            },
            "updated_at": "2025-07-30T13:07:02Z",
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
              "type": "END",
              "time": {
                "timestamp": "2023-07-16T10:30:00+05:30"
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
      ],
      "quote": {
        "price": {
          "value": "85",
          "currency": "INR"
        },
        "breakup": [
          {
            "title": "Charging session cost (5 kWh @ ₹18.00/kWh)",
            "item": {
              "id": "pe-charging-01"
            },
            "price": {
              "value": "75",
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
          "collected_by": "bpp",
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

**Session Interruptions:**
* **Message.order.fulfillments.state.descriptor.code:** Interruption state (changed to "CONNECTION-INTERRUPTED")
* **Message.order.fulfillments.state.descriptor.name:** Changed to a relevant notification
* **message.order.fulfillments.state.updated_at:** Timestamp when charging session ended
* **message.order.fulfillments.state.updated_by:** System that completed the session

### **Asynchronous on_update** (stop charging)

This is like getting a "Washing Complete" notification from your washing machine. The charging station is saying "Your charging session has finished! Here's the final bill and session summary."

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
              },
              "allocated": {
                  "measure": {
                     "type": "CONSTANT",
                     "value": "5.2",
                     "unit": "kWh"
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
                  "value": "con1"
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
              "code": "COMPLETED",
              "name": "Charging completed"
            },
            "updated_at": "2025-07-30T13:07:02Z",
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
              "type": "END",
              "time": {
                "timestamp": "2023-07-16T10:30:00+05:30"
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
      ],
      "quote": {
        "price": {
          "value": "78",
          "currency": "INR"
        },
        "breakup": [
          {
            "title": "Charging session cost (3.7 kWh @ ₹18.00/kWh)",
            "item": {
              "id": "pe-charging-01"
            },
            "price": {
              "value": "68",
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
          "collected_by": "bpp",
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
        },
        {
          "params": {
            "amount": "22.00",
            "currency": "INR"
          },
          "type": "POST-FULFILLMENT",
           "status": "NOT_PAID",
           "tags": [
             {
               "descriptor": {
                 "code": "refund-type",
               },
               "value": "OVERCHARGE_REFUND"
             },
             {
               "descriptor": {
                 "code": "refund-amount",
               },
               "value": "22INR"
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

**Session Completion:**
* **message.order.fulfillments.state.descriptor.code:** Final session status (changed to "COMPLETED")
* **message.order.fulfillments.state.updated_at:** Timestamp when charging session ended
* **message.order.fulfillments.state.updated_by:** System that completed the session

**Session Timeline:**
* **message.order.fulfillments.stops.time.timestamp:** Session start time
* **message.order.fulfillments.stops.time.timestamp:** Session end time
* **message.order.fulfillments.stops.type:** Set to "finish" indicating session completion

### **rating**

This is like leaving a review on Amazon or rating your Uber driver. You're giving feedback on your charging experience - how easy it was to find the station, how fast the charging was, and overall satisfaction. It helps other users and improves the service.

```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "rating",
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
    "ratings": [
      {
        "id": "fulfillment-001",
        "rating_category": "Fulfillment",
        "value": "5"
      }
    ]
  }
}
```

### **on_rating**

This is like getting a "Thank you for your review!" message from Amazon. The charging station is acknowledging your rating and might ask for more detailed feedback.

```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "on_rating",
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
    "feedback_form": {
      "form": {
        "url": "https://example-bpp.comfeedback/portal",
   "mime_type": "application/xml"

      },
      "required": false
    }
  }
}
```

### **support**

This is like calling customer service when you have a problem with your hotel booking. You're asking for help with your charging session - maybe the charger isn't working, you have a billing question, or you need to report an issue. It's your way of getting assistance when something goes wrong.

```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "support",
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
    "support": {
      "ref_id": "6743e9e2-4fb5-487c-92b7",
	 "callback_phone": "+911234567890",
      "email": "ravi.kumar@bookmycharger.com"
    }
  }
}
```

### **on_support**

This is like getting a customer service response - "Here's our support phone number, email, and a link to create a support ticket." The charging station is providing you with contact information and ways to get help, similar to how a hotel would give you their front desk number and manager's contact details.

```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "on_support",
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
    "support": {
      "ref_id": "6743e9e2-4fb5-487c-92b7",
      "phone": "18001080",
      "email": "support@bluechargenet-aggregator.io",
      "url": "https://support.bluechargenet-aggregator.io/ticket/SUP-20250730-001"
    }
  }
}
```