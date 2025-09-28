# **Use case 1- Walk-In to a charging station without reservation**

This section covers a walk-in case where users discover the charger using third-party apps, word of mouth, or Beckn API, and then drive to the location without advance booking.

> **Note**: For general Beckn message flow and error handling, please refer to the [Overview](./0_Overview.md#general-beckn-message-flow-and-error-handling) section.

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

Note: The API calls and schema for walk-in charging are identical to the advance reservation use case ([Use Case 2](./2_Reservation_use_case.md)) with minor differences in timing and availability. Where sections reference Use Case 2, the same API structure, field definitions, and examples apply unless specifically noted otherwise.

### **Search**

Consumer searches for EV charging stations with specific criteria including location, connector type, and category filters.

The search functionality works identically to the advance reservation use case described in [Use Case 2](./2_Reservation_use_case.md#search). Please refer to that section for detailed API specifications and examples.

**Alternative Discovery Scenario:**

Another possibility is that users discover the charging station through off-network channels (such as physical signage, word-of-mouth, or third-party apps not integrated with Beckn) and arrive directly at the location to initiate charging. In this scenario:

* The discovery phase is skipped entirely  
* Users proceed directly to the Select API call by scanning QR codes or using location-based identification  
* The charging station must be able to handle direct selection requests without prior search/discovery  
* This represents a more streamlined flow for walk-in customers who have already identified their preferred charging location

### **on_search**

The on_search response structure and content are identical to the advance reservation use case. Please refer to the [on_search section](./2_Reservation_use_case.md#on_search) in Use Case 2 for detailed response schema, field descriptions, and examples.

**Key difference for walk-in scenario:** The availability time slots in fulfillments.stops[].time.range will show immediate availability (current time onwards) rather than future scheduled slots.

### **Select**

The select functionality works identically to the advance reservation use case. Please refer to the [Select section](./2_Reservation_use_case.md#select) in Use Case 2 for detailed API specifications, request structure, and examples.

**Key difference for walk-in scenario:** The selected time slots will be for immediate charging rather than future scheduled slots.

### **on_select**

The on_select response structure and pricing logic are identical to the advance reservation use case. Please refer to the [on_select section](./2_Reservation_use_case.md#on_select) in Use Case 2 for detailed response schema, quote breakup, and field descriptions.

### **init**

The init functionality works identically to the advance reservation use case. Please refer to the [init section](./2_Reservation_use_case.md#init) in Use Case 2 for detailed API specifications, request structure, and examples.

**Key difference for walk-in scenario:** The init process happens immediately at the charging location rather than in advance.

### **on_init**

The on_init response structure and payment options are identical to the advance reservation use case. Please refer to the [on_init section](./2_Reservation_use_case.md#on_init) in Use Case 2 for detailed response schema, payment methods, and field descriptions.

### **confirm**

The confirm functionality works identically to the advance reservation use case. Please refer to the [confirm section](./2_Reservation_use_case.md#confirm) in Use Case 2 for detailed API specifications, payment confirmation, and examples.

**Key difference for walk-in scenario:** The confirmation happens immediately at the location rather than for a future scheduled session.

### **on_confirm**

The on_confirm response structure and order confirmation details are identical to the advance reservation use case. Please refer to the [on_confirm section](./2_Reservation_use_case.md#on_confirm) in Use Case 2 for detailed response schema, order status, and field descriptions.

### **update (start charging)**

Physical Charging Process:

Before initiating the charging session through the API, the EV driver must complete the following physical steps at the charging station:

1. Drive to the charging point: The user arrives at the reserved charging location at the scheduled time  
2. Plug the vehicle: Connect the charging cable from the EVSE (Electric Vehicle Supply Equipment) to their vehicle's charging port  
3. Provide the OTP: Enter or scan the OTP received during the init process to authenticate and authorize the start of the charging session

Once these physical steps are completed, the charging session can be initiated through the update API call.

This is like pressing the "Start" button on a washing machine. You're telling the charging station "I'm ready to start charging now, please begin the session." It's the moment when you actually start using the charging service you booked.

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

**State Change:**
* message.order.fulfillments.state.descriptor.code: New state value (e.g., "start-charging")  
* message.order.fulfillments.type: Service type (set to "CHARGING")

**Authorization:**
* message.order.fulfillments.stops.authorization.token: Authorization token for the charging session. This token validates that the user is authorized to start charging at this station.

### **on_update (start charging)**

This is like getting a "Washing Started" notification from your washing machine. The charging station is saying "Perfect! Your charging session has begun. You can now track your progress and see how much energy is being delivered to your vehicle."

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
            "title": "Service Fee",
            "price": {
              "currency": "INR",
              "value": "10"
            }
          },
          {
            "title": "overcharge estimation",
            "price": {
              "currency": "INR",
              "value": "18"
            }
          },
          {
            "title": "surge price(20%)",
            "price": {
              "currency": "INR",
              "value": "18"
            }
          },
          {
            "title": "offer discount(20%)",
            "price": {
              "currency": "INR",
              "value": "18"
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
          "collected_by": "bpp",
          "url": "https://payments.bluechargenet-aggregator.io/pay?transaction_id=$transaction_id&amount=$amount",
          "params": {
            "transaction_id": "123e4567-e89b-12d3-a456-426614174000",
            "amount": "118.00",
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
        "bpp_id": "example-bpp.com",
        "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
        "transaction_id": "e0a38442-69b7-4698-aa94-a1b6b5d244c2",
        "message_id": "6ace310b-6440-4421-a2ed-b484c7548bd5",
        "timestamp": "2023-02-18T17:00:40.065Z",
        "version": "1.0.0",
        "ttl": "PT10M"
    },
    "message": {
        "order_id": "b989c9a9-f603-4d44-b38d-26fd72286b38",
        "callback_url": "https://example-bap-url.com/SESSION/5e4f"
    }
}
```

**Tracking Request:**
* message.order_id: Unique order identifier for the charging session to track.  
* This links the tracking request to the specific booking.  
* message.callback_url: Optional URL which can be provided by the BAP, to which the BPP will trigger PATCH requests (with only fields to be updated and any fields that are left out remain unchanged) with real time details of the charging session.

**Tip for NFOs:**
* The structure and frequency for the PATCH requests may be decided based on the needs of the network by the NFO. A suggested request structure for the PATCH requests can be found below based on session details in *OCPI-2.2.1*:

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

* kwh: Total energy consumed during the session in kilowatt-hours.  
* status: Current status of the charging session (e.g., "ACTIVE", "COMPLETED").  
* currency: Currency used for charging costs (e.g., "INR").  
* charging_periods: Array containing details of different charging intervals within the session.  
  * start_date_time: Timestamp when the charging period started.  
  * dimensions: Array of measurements during the charging period.  
    * type: Type of measurement (e.g., "ENERGY", "POWER", "CURRENT", "VOLTAGE", "STATE_OF_CHARGE" as per CdrDimensionType *enum in OCPI-2.2.1*).  
    * volume: Value of the measurement.  
* total_cost: Breakdown of the total cost for the session.  
  * excl_vat: Total cost excluding VAT.  
  * incl_vat: Total cost including VAT.  
* last_updated: Timestamp of the last update to the session details.

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
        "bpp_id": "example-bpp.com",
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
* message.tracking.id: Unique tracking identifier for the charging session  
* message.tracking.url: Live tracking dashboard URL for monitoring charging progress  
* message.tracking.status: Current tracking status (e.g., "active" for ongoing session)

### **Asynchronous on_status (temporary connection interruption)**

1. This is used in case of a connection interruption during a charging session.  
2. Applicable only in case of temporary connection interruptions, BPPs expect to recover from these connection interruptions in the short term.  
3. BPP notifies the BAP about this interruption using an unsolicited on_status callback.  
4. NOTE: if the issue remains unresolved and BPP expects it to be a long term issue, BPP must send an unsolicited on_update to the BAP with relevant details.

### **Asynchronous on_update (stop charging)**

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
          },
          {
            "title": "surge price(20%)",
            "price": {
              "currency": "INR",
              "value": "18"
            }
          },
          {
            "title": "offer discount(20%)",
            "price": {
              "currency": "INR",
              "value": "18"
            }
          },
          {
            "title": "loyalty program discount",
            "price": {
              "currency": "INR",
              "value": "-10"
            }
          },
          {
            "title": "Overcharge refund",
            "price": {
              "currency": "INR",
              "value": "-33"
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
            "amount": "118.00",
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
            "amount": "33.00",
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
               "value": "33INR"
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
* message.order.fulfillments.state.descriptor.code: Final session status (changed to "COMPLETED")  
* message.order.fulfillments.state.updated_at: Timestamp when charging session ended  
* message.order.fulfillments.state.updated_by: System that completed the session

**Session Timeline:**
* message.order.fulfillments.stops.time.timestamp: Session start time  
* message.order.fulfillments.stops.time.timestamp: Session end time  
* message.order.fulfillments.stops.type: Set to "finish" indicating session completion

### **Rating**

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

**Note:** All remaining API calls (track, on_track, asynchronous on_update, on_status, rating, on_rating, support, on_support) work exactly the same as the advance reservation use case ([Use Case 2](./2_Reservation_use_case.md)).
