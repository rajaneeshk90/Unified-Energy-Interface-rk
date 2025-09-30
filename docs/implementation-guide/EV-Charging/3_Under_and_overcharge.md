# **Use case 3- Undercharge & Overcharge**

This section covers scenarios where charging sessions are interrupted or experience connectivity issues, leading to billing adjustments for actual energy delivered versus what was initially estimated or prepaid.

> **Note**: For general Beckn message flow and error handling, please refer to the [Overview](./0_Overview.md#general-beckn-message-flow-and-error-handling) section.

## **Under and Overcharge Scenarios**

### **A) Undercharge (Power Cut Mid-Session)**

**Scenario:** The user reserves a 12:45–13:30 slot and prepays ₹500 in the app to the BPP platform. Charging starts on time; the app shows ETA and live ₹/kWh. At 13:05 a power cut stops the charger. The charger loses connectivity and can't push meter data. The app immediately shows: "Session interrupted—only actual energy will be billed. You may unplug or wait for power to resume."

**Handling & experience:**
* User side: Clear banner + push notification; live session switches to "Paused (site offline)". If the user leaves, the session is treated as completed-so-far.  
* CPO/BPP side: When power/comms return, the CMS syncs the actual kWh delivered and stop timestamp.  
* Settlement logic:  
  * If prepaid: compute final ₹ from synced kWh; auto-refund the unused balance to the original instrument; issue invoice.  
  * If auth-hold/UPI mandate (preferred): capture only the final ₹; release remainder instantly.

**Contract/UI terms to bake in:** "Power/interruption protection: you are charged only for energy delivered; any excess prepayment is automatically refunded on sync." Show an estimated refund immediately, and a final confirmation after sync.

### **B) Overcharge (Charger Offline to CMS; Keeps Dispensing)**

**Scenario:** The user reserves a slot with ₹500 budget. Charging begins; mid-session the charger loses connectivity to its CMS (e.g., basement, patchy network). Hardware keeps dispensing; when connectivity returns, the log shows ₹520 worth of energy delivered.

**Handling & experience:**
* User side: The app shows "Connectivity issue at site—session continues locally. The final bill will be reconciled in sync." On sync, the app shows: "Final: ₹520 for X kWh; ₹30 auto-settled."  
* CPO/BPP side: Charger syncs start/stop/kWh; CMS reconciles vs. contract.

**Settlement logic (three safe patterns):**

* **Buffer in quote (prepaid with overage provision):**  
  * Quote line items include: "Energy (₹500) + Overage Provision (₹50) — unused portion auto-refunded."  
  * BPP collects ₹550; captures actual ₹520; refunds ₹30 immediately on sync.  
* **Authorization hold / UPI one-time mandate (preferred):**  
  * Place a hold/mandate for ₹550; capture ₹520, release ₹30. No debit-then-refund friction.  
* **Top-up debit fallback:**  
  * If only ₹500 was captured and no mandate exists, the app auto-initiates a ₹20 top-up request (same instrument), with clear messaging and a single-tap confirmation.

**Contract/UI terms to bake in:** "Offline continuity & overage: sessions may continue locally during short connectivity loss; final billing reflects meter data. We place a buffer hold to avoid delays; unused amounts are released automatically."

## **API Implementation**

The above under and overcharge scenarios are supported through Beckn protocol callbacks:

* Interruption notification: BPP informs BAP about any session interruption using unsolicited on_status callback  
* Final billing adjustment: The adjusted bill reflecting overcharge or undercharge reconciliation is conveyed through the on_update API quote  
* Real-time status updates: Continuous session monitoring and status communication ensure transparent billing for actual energy delivered

### **on_init**

<make this language RFC style>
To account for the estimated overcharge for each transaction, BPP adds an overcharge estimation in the initial quotation for the charging session. This is reflected in the order.quote object.

Note: Overcharge is an estimated portion of the quote.

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
            "title": "overcharge estimation",
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


### **Asynchronous on_update (stop charging with reconciliation)**

### **Session Completion and Final Billing**

When the charging session ends (gracefully or with error):

* The BPP SHALL send the final status to the BAP with the complete billing details via an unsolicited `on_update` callback
* The `order.quote` object MUST contain any overcharge refund that is applicable for this charging session
* The `order.quote.breakup` array SHALL include overcharge refund line items with negative values
* Each refund line item MUST be clearly identified in the `title` field (e.g., "Overcharge refund")
* The final `order.quote.price.value` SHALL reflect the net amount after all adjustments

This is like getting a "Washing Complete" notification from your washing machine. The charging station is saying "Your charging session has finished! Here's the final bill and session summary with any adjustments for actual energy delivered."

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
                "value": "5.5",
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
          "value": "109",
          "currency": "INR"
        },
        "breakup": [
          {
            "title": "Charging session cost (5.5 kWh @ ₹18.00/kWh)",
            "item": {
              "id": "pe-charging-01"
            },
            "price": {
              "value": "99",
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
            "title": "Overcharge refund",
            "price": {
              "currency": "INR",
              "value": "-9"
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
            "amount": "9.00",
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
               "value": "9INR"
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

**Key Reconciliation Fields:**
* message.order.items[].quantity.allocated: Actual energy delivered (e.g., "5.5" kWh)
* message.order.quote.breakup[].title: "Overcharge refund"
* message.order.quote.breakup[].price.value: Adjustment amount (negative for refunds)
* message.order.payments[].type: "POST-FULFILLMENT" for reconciliation payments
* message.order.payments[].tags: Refund type and amount details

## **Implementation Guidelines**

### **For BAPs (Consumer Apps):**
1. **Real-time Status Updates**: Implement push notifications for connection interruptions
2. **Transparent Messaging**: Clearly communicate billing adjustments to users
3. **Refund Processing**: Handle automatic refunds for over payments
4. **Session Recovery**: Allow users to resume interrupted sessions when possible

### **For BPPs (Service Providers):**
1. **Meter Data Sync**: Ensure accurate energy measurement and reporting
2. **Graceful Degradation**: Continue charging during connectivity loss when safe
3. **Automatic Reconciliation**: Process billing adjustments based on actual usage
4. **Buffer Management**: Implement appropriate hold amounts for overage protection

### **For CPOs (Charge Point Operators):**
1. **Offline Capability**: Enable local charging during network interruptions
2. **Data Integrity**: Maintain accurate session logs for later reconciliation
3. **Safety Protocols**: Ensure safe operation during connectivity issues
4. **Recovery Procedures**: Implement robust reconnection and sync mechanisms
