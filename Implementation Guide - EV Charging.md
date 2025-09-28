# **Implementation Guide \- EV Charging (DRAFT)**

## **Copyright Notice**

#### **License: [CC-BY-NC-SA 4.0](https://becknprotocol.io/license/) becknprotocol.io**

## **Status of This Memo**

#### **This is a draft RFC for implementing EV charging using the Beckn Protocol. It provides implementation guidance for anyone to build interoperable EV charging applications that integrate with each other on a decentralized network  while maintaining compatibility with OCPI standards for CPO communication.**

## **Abstract**

This RFC proposes a practical way to make EV charging easier to find and use by applying the Beckn Protocol’s distributed commerce model. Instead of juggling multiple apps and accounts for different charging networks, drivers can discover and book charging sessions from any participating Charge Point Operator (CPO) through a single consumer interface.

The design shifts today’s fragmented network silos into an open, interoperable marketplace. Drivers can search, compare options, view transparent pricing, and reserve a slot at any eligible station—regardless of the underlying CPO. By standardizing discovery, pricing, and booking, the approach tackles three persistent barriers to EV adoption: charging anxiety, network fragmentation, and payment complexity.

Built on Beckn’s commerce capabilities and aligned with OCPI for technical interoperability, the implementation lets e-Mobility Service Providers (eMSPs) aggregate services from multiple CPOs while delivering a consistent, app-agnostic experience to consumers. The result is a scalable foundation that supports growth today and remains flexible for future expansion of the EV charging ecosystem.

## **Introduction**

This document provides an implementation guidance for deploying EV charging services using the Beckn Protocol ecosystem. It specifically addresses how consumer applications can provide unified access to charging infrastructure across multiple Charge Point Operators while maintaining technical compatibility with existing OCPI-based systems.

### **Scope**

This document covers:

* Architecture patterns for EV charging marketplace implementation using Beckn Protocol  
* Discovery and charging mechanisms for charging EVs across multiple CPOs  
* Real-time availability and pricing integration with OCPI-based systems  
* Session management and billing coordination between Beckn and OCPI protocols

This document does NOT cover:

* Detailed OCPI protocol specifications (refer to OCPI 2.2.1 documentation)  
* Physical charging infrastructure requirements and standards  
* Regulatory compliance beyond technical implementation (varies by jurisdiction)  
* Smart grid integration and load management systems

### **Target Audience**

* Consumer Application Developers (BAPs: Pulse, ChargeZone, Kazam etc): Building EV driver-facing charging applications with unified cross-network access  
* e-Mobility Service Providers (eMSPs/BPPs: EZ Charge, ChargeGrid, ElectricPe): Implementing charging service aggregation platforms across multiple CPO networks  
* Charge Point Operators (CPOs:Jio-bp pulse, Zeon Charging, Glida): Understanding integration requirements for Beckn-enabled marketplace participation  
* Technology Integrators: Building bridges between existing OCPI infrastructure and new Beckn-based marketplaces  
* System Architects: Designing scalable, interoperable EV charging ecosystems  
* Business Stakeholders: Understanding technical capabilities and implementation requirements for EV charging marketplace strategies  
* Standards Organizations: Evaluating interoperability approaches for future EV charging standards development

## **Conventions and Terminology**

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described [here](https://github.com/beckn/protocol-specifications/blob/draft/docs/BECKN-010-Keyword-Definitions-for-Technical-Specifications.md).

### **Terminology**

| Acronym | Full Form/Description |
| ----- | ----- |
| BAP | Beckn App Platform: Consumer-facing application that initiates transactions |
| BPP | Beckn Provider Platform: Service provider platform that responds to BAP requests |
| eMSP | e-Mobility Service Provider: Service provider that aggregates multiple CPOs |
| CPO | Charge Point Operator: Entity that owns and operates charging infrastructure |
| EVSE | Electric Vehicle Supply Equipment: Individual charging station unit |
| OCPI | Open Charge Point Interface: Protocol for communication between eMSPs and CPOs |

## **General Beckn message flow and error handling**

This section is relevant to all the message flows illustrated below and discussed further in the document.

Beckn is an asynchronous protocol at its core.

* When a network participant(NP1) sends a message to another participant(NP2), the other participant(NP2) immediately returns back an ACK/NACK(Acknowledgement or Negative Acknowledgement in case of error \- usually with wrongly formed messages).  
* An ACK is an indicator that the receiving participant(NP2) will process this message and dispatch an on\_xxxxxx message to original NP (NP1)  
* Subsequently after processing the message NP2 sends back the real response in the corresponding on\_xxxxxx message, to which again the first participant(NP1).  
* This message can contain a message field (for success) or error field (for failure)  
* NP1 when it receives the on\_xxxxxx message, sends back an ACK/NACK (Here in both the cases NP1 will not send any subsequent message).  
* In the Use case diagrams, this ACK/NACK is not illustrated explicitly to keep the diagrams crisp.  
* However when writing software we should be prepared to receive these NACK messages as well as error field in the on\_xxxxxx messages  
* While this discussion is from a Beckn perspective, Adapters can provide synchronous modes. For example, the Protocol Server which is the reference implementation of the Beckn Adapter provides a synchronous mode by default. So if your software calls the support endpoint on the BAP Protocol Server, the Protocol Server waits till it gets the on\_support and returns back that as the response.

Structure of a message with a NACK

{  
    "message": {  
        "ack": {  
            "status": "NACK"  
        }  
    },  
    "error": {  
        "code": 400,  
        "message": "OpenApiValidator Error at BAP-CLIENT",  
    }  
}

Structure of a on\_select message with an error

{  
    "context": {  
        "action": "on\_select",  
        "version": "1.1.0",  
    },  
    "error": {  
        "code": 30001,  
        "message": "Requested provider is not in the database"  
    }  
}

Note: This document does not detail the mapping between Beckn Protocol and OCPI. Please refer to [this](https://docs.google.com/document/d/13gtF2GHoWnjahqwzCRsOojjPLzhlOhWx_04m72VAdM4/edit?tab=t.0) document for the same.

## **Use cases:**

This document explores the below use cases for EV charging interactions:

1. Walk-in flow (MOST POPULAR)  
2. Reservation in advance  
3. Undercharge \&overcharge  
4. Loyalty or subscription  
5. B2B deal  
6. Offers  
7. Surcharge

## **Use case 1- Reservation of an EV charging time slot.**

This section covers advance reservation of a charging slot where users discover and book a charger before driving to the location.

### **User journey:**

Srilekha, a 29-year-old product manager driving from Bengaluru to Mysuru. She plans stops tightly and prefers reserving a charger next to reliable food options. About 30 minutes before her lunch window, Srilekha checks where she’ll likely stop and decides to charge during lunch rather than add a separate halt.

**Discovery:** In her EV app, she filters for DC fast chargers near food courts/restaurants along her route. The app returns options with ETA from her live location, connector compatibility, tariff, and any active offers.

**Order (Reservation):** She selects a charger at a highway food court complex and books a time slot. The app presents session terms (rate, grace period/idle fee, cancellation rules) and payment choices (hold/prepay/postpay as supported). She confirms; a reservation ID and navigation link are issued.

**Fulfilment:** On arrival, Srilekha scans the charger QR, the booking is matched to her reservation, and charging starts. She tracks kWh, ₹, and ETA in-app while she eats. If she’s a few minutes late, the system applies the defined grace period before releasing the slot.

**Post-Fulfilment:** Charging stops at target energy or when she ends the session. She receives a digital invoice and session summary. She rates the amenities around, overall experience at a scale of 1-5 at the end and continues with her trip.

## **API Calls and Schema**

### **Search** {#search}

Consumer searches for EV charging stations with specific criteria including location, connector type, time window, finder fee etc.

This is like typing "EV charger" into Google Maps and saying "find me charging stations within 5km of this location that have CCS2 connectors." The app sends this request to find available charging stations that match your criteria.

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
    "message\_id": "e138f204-ec0b-415d-9c9a-7b5bafe10bfe",  
    "transaction\_id": "2ad735b9-e190-457f-98e5-9702fd895996",  
    "domain": "deg:ev-charging",  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
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
        "stops": \[  
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
        \],  
        "tags": \[  
          {  
            "list": \[  
              {  
                "descriptor": {  
                  "code": "connector-type"  
                },  
                "value": "CCS2"  
              }  
            \]  
          }  
        \]  
      },  
     "tags": \[  
        {  
          "descriptor": {  
            "code": "buyer-finder-fee"  
          },  
          "list": \[  
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
          \]  
        }  
      \]  
    }  
  }  
}

**Search Criteria**:

* message.intent.descriptor.name: Free text search for charging stations (user can enter any search terms like "EV charger", "fast charging", etc.)  
* message.intent.category.descriptor.code: Category-based search filter (e.g., "green-tariff" for eco-friendly charging options)

**Location and Timing**:

* message.intent.fulfillment.stops\[\].location.circle.gps: GPS coordinates for search center (REQUIRED \- format: "latitude,longitude")  
* message.intent.fulfillment.stops\[\].location.circle.radius.value: Search radius value (REQUIRED \- e.g., "5")  
* message.intent.fulfillment.stops\[\].location.circle.radius.unit: Unit of measurement (REQUIRED \- e.g., "km", "miles")  
* message.intent.fulfillment.stops\[\].time.range.start: Earliest acceptable charging start time (OPTIONAL \- format: "YYYY:MM:DD:HH:MM:SS")  
* message.intent.fulfillment.stops\[\].time.range.end: Latest acceptable charging end time (OPTIONAL \- format: "YYYY:MM:DD:HH:MM:SS")

**Connector Type Filtering**:

* message.intent.fulfillment.tags.list.descriptor.code: Connector type filter code (e.g., "connector-type")  
* message.intent.fulfillment.tags.list.value: Specific connector type value (e.g., "CCS2", "CHAdeMO", "Type 2")  
* Used by BPP to filter charging stations that match vehicle requirements

**Buyer Finder Fee Declaration:**

* message.intent.tags.descriptor.code: Tag group to describe the buyer funder fee or the commission amount for the BAP as part of the transaction.  
* Message.intent.tags.list.\[descriptor.code=”type”\].value: Tag to define if the commission is a percentage of the order value or a flat amount. Possible values are “PERCENTAGE” and “AMOUNT”  
* Message.intent.tags.list.\[descriptor.code=”value”\].value: Tag to define the buyer finder fee value.

### **on\_search** {#on_search}

BPP returns a comprehensive catalog of available charging stations from multiple CPOs with detailed specifications, pricing, and location information.

1. Multiple providers (CPOs) with their charging networks  
2. Detailed location information with GPS coordinates  
3. Individual charging station specifications and pricing  
4. Connector types, power ratings, and availability status

This is the response you get back after searching \- like getting a list of all nearby restaurants from Google Maps. It shows you all the charging stations available, their locations, prices, and what type of connectors they have. Think of it as a "charging station directory" for your area.

{  
    "context": {  
      "domain": "deg:ev-charging",  
      "action": "on\_search",  
      "location": {  
        "country": {  
          "code": "IND"  
        },  
        "city": {  
          "code": "std:080"  
        }  
      },  
      "version": "1.1.0",  
      "bap\_id": "example-bap.com",  
      "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
      "bpp\_id": "example-bpp.com",  
      "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
      "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
      "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
      "timestamp": "2023-07-16T04:41:16Z"  
    },  
    "message": {  
      "catalog": {  
        "providers": \[  
          {  
            "id": "cpo1.com",  
            "descriptor": {  
              "name": "CPO1 EV charging Company",  
              "short\_desc": "CPO1 provides EV charging facility across India",  
              "images": \[  
                {  
                  "url": "https://cpo1.com/images/logo.png"  
                }  
              \]  
            },  
            "locations": \[  
              {  
                "id": "LOC-DELHI-001",  
                "gps": "28.345345,77.389754",  
                "descriptor": {  
                  "name": "BlueCharge Connaught Place Station"  
                },  
                "address": "Connaught Place, New Delhi"  
              }  
            \],  
            "fulfillments": \[  
              {  
                "id": "fulfillment-001",  
                "type": "CHARGING",  
                "stops": \[  
                  {  
                    "location": {  
                      "gps": "28.6304,77.2177",  
                      "address": "Connaught Place, New Delhi”  
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
                \]  
              },  
              {  
                "id": "fulfillment-002",  
                "type": "CHARGING",  
                "stops": \[  
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
                      "address":"Saket, New Delhi"  
                    },  
                    "time": {  
                        "range": {  
                          "start": "2025:09:24:15:00:00",  
                          "end": "2025:09:24:16:00:00"  
                        }  
                    }  
                  }  
                \]  
              }  
            \],  
            "offers": \[  
                {  
                    "id": "offer-001",  
                    "descriptor": {  
                        "name": "Early Bird Charging Special",  
                        "code": "early-bird-discount",  
                        "short\_desc": "20% off on all charging sessions booked before 12 PM",  
                        "long\_desc": "Get 20% discount on both AC and DC fast charging at our Connaught Place station when you book your charging slot before 12:00 PM. Valid for all connector types including CCS2. Perfect for early commuters and business travelers.",  
                        "images": \[  
                            {  
                                "url": "https://cpo1.com/images/early-bird-offer.png"  
                            }  
                        \]  
                    },  
                    "location\_ids": \[  
                        "LOC-DELHI-001"  
                    \],  
                    "item\_ids": \[  
                        "pe-charging-01",  
                        "pe-charging-02"  
                    \],  
                    "time": {  
                      "range": {  
                        "start": "2025-09-16T04:00:00Z",  
                        "end": "2025-09-16T012:00:00Z"  
                      }  
                    }  
                },  
                {  
                  "id": "offer-002",  
                  "descriptor":{  
                    "name": "Location Based Offer",  
                    "short\_desc": "10% off on all orders from our new location"  
                  },  
                  "location\_ids": \[  
                    "LOC-DELHI-001"  
                  \]  
                },  
            \],  
            "items": \[  
              {  
                "id": "pe-charging-01",  
                "descriptor": {  
                  "name": "EV Charger \#1 (AC Fast Charger)",  
                  "code": "CHARGER"  
                },  
                "price": {  
                  "value": "18",  
                  "currency": "INR/kWh"  
                },  
                "fulfillment\_ids": \[  
                  "fulfillment-001"  
                \],  
                "location\_ids": \[  
                  "LOC-DELHI-001"  
                \],  
                "tags": \[  
                  {  
                    "descriptor": {  
                      "code": "connector-specifications",  
                      "name": "Connector Specifications"  
                    },  
                    "list": \[  
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
                        "value": "AC\_3\_PHASE"  
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
                    \]  
                  }  
                \]  
              },  
              {  
                "id": "pe-charging-02",  
                "descriptor": {  
                  "name": "EV Charger \#1 (AC Fast Charger)",  
                  "code": "CHARGER",  
                  "short\_desc": "Spot Booking"  
                },  
                "price": {  
                  "value": "21",  
                  "currency": "INR/kWh"  
                },  
                "fulfillment\_ids": \[  
                  "fulfillment-001"  
                \],  
                "location\_ids": \[  
                  "LOC-DELHI-001"  
                \],  
                "tags": \[  
                  {  
                    "descriptor": {  
                      "code": "connector-specifications",  
                      "name": "Connector Specifications"  
                    },  
                    "list": \[  
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
                        "value": "AC\_3\_PHASE"  
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
                    \]  
                  }  
                \]  
              },  
              {  
                "id": "pe-charging-02",  
                "descriptor": {  
                  "name": "EV Charger \#2 (DC Fast Charger)",  
                  "code": "CHARGER"  
                },  
                "price": {  
                  "value": "25",  
                  "currency": "INR/kWh"  
                },  
                "fulfillment\_ids": \[  
                  "fulfillment-002"  
                \],  
                "location\_ids": \[  
                  "LOC-DELHI-002"  
                \],  
                "tags": \[  
                  {  
                    "descriptor": {  
                      "name": "Connector Specifications"  
                    },  
                    "list": \[  
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
                    \]  
                  }  
                \]  
              },  
              {  
                "id": "pe-charging-02",  
                "descriptor": {  
                  "name": "EV Charger \#2 (DC Fast Charger)",  
                  "code": "CHARGER",  
                  "short\_desc": "Spot Booking"  
                },  
                "price": {  
                  "value": "28",  
                  "currency": "INR/kWh"  
                },  
                "fulfillment\_ids": \[  
                  "fulfillment-002"  
                \],  
                "location\_ids": \[  
                  "LOC-DELHI-002"  
                \],  
                "tags": \[  
                  {  
                    "descriptor": {  
                      "name": "Connector Specifications"  
                    },  
                    "list": \[  
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
                    \]  
                  }  
                \]  
              }  
            \]  
          }  
        \]  
      }  
    }  
  }

Note: This is just an example catalog. CPOs are encouraged to innovate on various catalog offerings that involve charging services \+ add\_ons, green charging, etc. More such examples will be added to this document in future releases.

Provider Information:

* message.catalog.providers.id: Unique identifier for the charging network provider (CPO)  
* message.catalog.providers.descriptor.name: Display name of the charging network (e.g., "CPO1 EV charging Company")  
* message.catalog.providers.descriptor.short\_desc: Brief description of provider's services and coverage area

Location Details:

* message.catalog.providers.locations.id: Unique location identifier for the charging station  
* message.catalog.providers.locations.gps: GPS coordinates of the charging station (format: "latitude,longitude")  
* message.catalog.providers.locations.descriptor.name: Human-readable name of the charging station  
* message.catalog.providers.locations.address: Full address of the charging station

Availability Time Slots:

* message.catalog.providers.fulfillments.stops\[\].time.range.start: Start time of available charging slot (format: "YYYY:MM:DD:HH:MM:SS")  
* message.catalog.providers.fulfillments.stops\[\].time.range.end: End time of available charging slot (format: "YYYY:MM:DD:HH:MM:SS")  
* Multiple stops entries represent different available time slots for the same charger location  
* Each time slot indicates when the charging station is available for booking or immediate use

Charging Station Specifications (Items\*):

* message.catalog.providers.items.id: Unique identifier for the specific charging point/EVSE  
* message.catalog.providers.items.descriptor.name: Human-readable name of the charging point  
* message.catalog.providers.items.price.value: Charging rate per unit (e.g., "18" for ₹18/kWh)  
* message.catalog.providers.items.price.currency: Currency and unit basis (e.g., "INR/kWh")

\* Note: *The serialization format of the Item schema and any sub-schemas referred in this and following example JSONs is shortly expected to be upgraded to JSON-LD with alignment to schema.org to allow semantic interoperability.* 

Technical Specifications (Tags):

* connector-id: Physical connector identifier at the charging station  
* power-type: Type of power delivery (e.g., "AC\_3\_PHASE", "DC")  
* connector-type: Connector standard (e.g., "CCS2", "CHAdeMO", "Type 2")  
* charging-speed: Relative charging speed classification (e.g., "FAST", "SLOW")  
* power-rating: Maximum power output in kilowatts (e.g., "30kW", "40kW")  
* status: Current availability status (e.g., "Available", "In Use", "Maintenance")

Fulfillment and Category Links:

* fulfillment\_ids: Links to fulfillment options (charging service delivery methods)  
* category\_ids: Links to program categories (e.g., "green-tariff" for eco-friendly options)  
* location\_ids: Links to specific charging station locations

**Offers:**  
While browsing the charging app for a session, Srilekha notices a banner:  
 “Limited Time Offer: ₹20 off when you charge above 5 kWh – Valid till Sunday\!”  
**User Journey:**   
**Discovery**  
Srilekha searches for a charger.  
The app shows eligible stations with a badge or label indicating the reward:

* “Offer: ₹20 off above 5 kWh”  
* Visible next to charger name or on charger details screen  
* Optional “Know More” link to view:  
  * Offer conditions  
  * Validity window  
  * Eligible locations

**Charging session initiation**  
Srilekha selects a charger that displays the reward.  
Before starting, she sees a preview:

* Estimated cost based on kWh  
* Reward condition reminder: “Charge ≥5 kWh to get ₹20 off”  
* Final price estimate with and without reward

**Charging**   
While charging:

* The app shows real-time updates (optional):  
  * Energy delivered  
  * How close he is to hitting the reward threshold  
  * “You will unlock ₹20 off\!” once 5 kWh is crossed

If the session ends before meeting the threshold, app shows:

* “You used 3.2 kWh \- reward not applied”

**Post-charging**  
Aarav receives a receipt or invoice with a clear breakdown:

* Base charge (e.g., ₹60)  
* Reward discount (e.g., – ₹20)  
* Final amount paid (e.g., ₹40)  
* Message: “Thanks for charging with us. You saved ₹20 with this week’s offer\!”

Fields in the offer object are described below:

* message.catalog.providers.offers.id: Unique identifier for the promotional offer  
* message.catalog.providers.offers.descriptor.name: Human-readable name of the offer (e.g., "Early Bird Charging Special")  
* message.catalog.providers.offers.descriptor.code: Machine-readable offer code (e.g., "early-bird-discount")  
* message.catalog.providers.offers.descriptor.short\_desc: Brief description of the offer benefits  
* message.catalog.providers.offers.descriptor.long\_desc: Detailed explanation of offer terms, conditions, and target audience  
* message.catalog.providers.offers.descriptor.images: Visual promotional materials for the offer  
* message.catalog.providers.offers.location\_ids: Specific charging locations where the offer is applicable  
* message.catalog.providers.offers.item\_ids: Specific charging items/services covered by the offer  
* message.catalog.providers.offers.tags: Structured offer metadata including discount percentage, validity periods, applicable days, and offer type classification

### **Select** {#select}

The consumer can select an EV charging time slot from a specific charging station to get the real time availability and quote from the BPP.

.

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
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "timestamp": "2025:09:24:10:00:00",  
    "ttl": "15S"  
  },  
  "message": {  
    "order": {  
      "provider": {  
        "id": "cpo1.com"  
      },  
      "items": \[  
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
      \],  
      "fulfillments": \[  
        {  
          "id": "1",  
          "stops": \[  
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
          \],  
          "vehicle": {  
            "make": "Tata",  
            "model": "Nexon EV"  
          }  
        }  
      \],  
      "offers": \[  
        {  
          "id": "offer-001"  
        }  
      \],  
      "tags": \[  
        {  
          "descriptor": {  
            "code": "buyer-finder-fee"  
          },  
          "list": \[  
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
          \]  
        }  
      \]  
    }  
  }  
}

Charging Station Specifications (Items):

* message.order.items.id: Unique identifier for the specific charging point/EVSE

Charging Session Information (Fulfillments):

* message.order.fulfillments.id: Unique identifier for this charging session  
* message.order.fulfillments.stops.type: Session type (set to "start" for charging initiation and "stop" for ending the session)  
* message.order.fulfillments.stops.time.timestamp: Requested charging start timestamp and end timestamp. In case of future time slot bookings, the user will give the future requested time slot here. The BPP may respond with the nearest time slot available, if exact slots are not available for booking. If they are absent or if the timestamp is of current timestamp or of a timeframe within a short duration, this can be considered a spot booking scenario.

Buyer Finder Fee Declaration:

* message.order.tags.descriptor.code: Tag group to describe the buyer funder fee or the commission amount for the BAP as part of the transaction.  
* Message.order.tags.list.\[descriptor.code=”type”\].value: Tag to define if the commission is a percentage of the order value or a flat amount. Possible values are “PERCENTAGE” and “AMOUNT”  
* Message.order.tags.list.\[descriptor.code=”value”\].value: Tag to define the buyer finder fee value.

BAP can also support EV charging by kWh. Below is an example of the same:

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

### **on\_select** {#on_select}

Here the BPP returns with the estimated quote for the service. If the service is unavailable, the BPP returns with an error.

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_select",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "timestamp": "2023-07-16T04:41:16Z",  
    "ttl": "15S"  
  },  
  "message": {  
    "order": {  
      "provider": {  
        "id": "cpo1.com",  
        "descriptor": {  
          "name": "CPO1 EV charging Company",  
          "short\_desc": "CPO1 provides EV charging facility across India",  
          "images": \[  
            {  
              "url": "https://cpo1.com/images/logo.png"  
            }  
          \]  
        }  
      },  
      "items": \[  
        {  
          "id": "pe-charging-01",  
          "descriptor": {  
            "name": "EV Charger \#1 (AC Fast Charger)",  
            "code": "ev-charger"  
            "short\_desc": "Book now"  
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
          "tags": \[  
            {  
              "descriptor": {  
                "code": "connector-specifications",  
                "name": "Connector Specifications"  
              },  
              "list": \[  
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
                  "value": "AC\_3\_PHASE"  
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
              \]  
            }  
          \]  
        }  
      \],  
      "fulfillments": \[  
        {  
          "id": "fulfillment-001",  
          "type": "CHARGING",  
          "stops": \[  
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
                "short\_desc": "Ground floor, Pillar Number 4"  
              }  
            },  
            {  
              "type": "STOP",  
              "time": {  
                "timestamp": "2025:09:24:11:00:00"  
              }  
            }  
          \],  
          "vehicle": {  
            "make": "Tata",  
            "model": "Nexon EV"  
          }  
        }  
      \],  
      "quote": {  
        "price": {  
          "value": "118",  
          "currency": "INR"  
        },  
        "breakup": \[  
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
          }  
        \]  
      }  
    }  
  }  
}

Charging Session Information (Fulfillments):

* message.order.fulfillments.id: Unique identifier for this charging session  
* message.order.fulfillments.stops.type: Session type (set to "start" for charging initiation and "stop" for ending the session)  
* message.order.fulfillments.stops.instructions: Suggested instructions to the end user for starting charging.  
* Message.order.fulfillments.stops.time.timestamp: The timeslot for which the quote is returned to the user by the BPP. Here the returned timeslot is slightly different from the selected timeslots based on availability from the end user.

## **Surge Pricing** 

A surge price is an additional fee applied on top of the base charging tariff under specific conditions-such as time of use or location.  
**User Journey:**  
**Discovery**  
While searching for a charger around 6:15 PM, Srilekha sees a warning icon and note:  
 “Congestion Fee: ₹1/kWh between 6 PM – 9 PM”  
The app highlights this surcharge in:

* The station list view (via badge or icon)  
* The charger details page  
* A “Know More” section that explains:  
  * What the surcharge is  
  * When and where it applies  
  * How it’s calculated

**Session preview**  
Before starting, the app shows the full estimated cost:

* Base rate: ₹16/kWh  
* Congestion fee: ₹1/kWh  
* Estimated total for 5 kWh: ₹85

**Charging**  
Srilekha starts the session at 6:25 PM.  
Mid-session:

* She sees kWh delivered  
* Total cost is incrementally calculated including the surcharge  
   (e.g., 3.4 kWh → ₹58.00 \= ₹54.4 base \+ ₹3.4 congestion fee)

**Post-charging**  
Once the session ends, Srilekha receives an itemized receipt:  
Session Summary:

* Energy Delivered: 5.2 kWh  
* Base Energy Cost: ₹83.20  
* Congestion Fee (₹1 x 5.2): ₹5.20  
* Total Payable: ₹88.40

Quote Information:

* message.order.quote.price.value: Total estimated price for the service (e.g., "118" INR after applying offer discount)  
* message.order.quote.currency: Currency of the total estimated price (e.g., "INR")  
* message.order.quote.breakup: Itemized breakdown of the total estimated price including:  
  * title: Description of the charge (e.g., "Charging session cost", "overcharge", "surge price(20%)", "offer discount(20%)")  
  * item.id: Identifier of the item the charge applies to (if applicable)  
  * price.value: Value of the individual charge in the breakup (positive for charges, negative for discounts)  
  * price.currency: Currency of the individual charge in the breakup  
  * Breakup includes base charges, additional fees, surge pricing, and promotional discounts from applied offers

### **init** {#init}

Loyalty Program and Authorization Process:

The system handles two different scenarios for loyalty programs and authorization:

Example Individual Customer Approach:

* User provides their mobile number in the billing details  
* The BPP may check the user's registered mobile number to identify any active loyalty programs attached to it  
* If loyalty programs are found, the BPP can automatically adjust discounts in the quote based on the customer's loyalty status  
* This approach provides seamless discount application without requiring additional user input

Example B2B Fleet Approach:

* B2B deals typically happen offline, where fleet operators and CPOs (Charge Point Operators) establish commercial agreements outside of the Beckn protocol  
* Fleet drivers may choose an option indicating they have a B2B loyalty program  
* The fleet driver could provide an OTP received from the BPP on their registered mobile number  
* The BPP validates the OTP and adjusts the final quote based on the B2B loyalty program benefits  
* This approach ensures fleet-specific pricing and discounts are applied correctly

Note: These are example implementation approaches. Different networks may choose alternative methods for loyalty program integration, such as QR code scanning, app-based authentication, RFID cards, or other identification mechanisms depending on their technical infrastructure and business requirements.

This step is like filling out a hotel room booking form \- you're telling the charging station "I want to charge here, here's my contact info and billing details." It's the first step in actually doing transacting.

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
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "timestamp": "2023-07-16T04:41:16Z",  
    "ttl": "15S"  
  },  
  "message": {  
    "order": {  
      "provider": {  
        "id": "cpo1.com"  
      },  
      "items": \[  
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
      \],  
      "offers": \[  
        {  
          "id": "offer-001"  
        }  
      \],  
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
        "tax\_id": "GSTIN29ABCDE1234F1Z5"  
      },  
      "fulfillments": \[  
        {  
          "id": "1",  
          "stops": \[  
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
          \],  
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
      \],  
      "tags": \[  
        {  
          "descriptor": {  
            "code": "buyer-finder-fee"  
          },  
          "list": \[  
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
          \]  
        }  
      \]  
    }  
  }  
}

Charging Session Information (Fulfillments):

* message.order.fulfillments.id: Unique identifier for this charging session  
* message.order.fulfillments.stops.type: Session type (set to "start" for charging initiation)  
* message.order.fulfillments.stops.time.timestamp: Requested charging start timestamp and stop timestamp in case of future reservations.  
* message.order.fulfillments.customer.person.name: Customer name for session identification  
* message.order.fulfillments.customer.contact.phone: Customer phone for session coordination

Billing Information:

* message.order.billing.name: Customer's full name for billing purposes  
* message.order.billing.organization.descriptor.name: Company name if charging for business use  
* message.order.billing.address: Complete billing address for tax and invoice purposes  
* message.order.billing.email: Contact email for billing communications  
* message.order.billing.phone: Contact phone number for billing inquiries  
* message.order.billing.tax\_id: GST number for business billing and tax compliance

### **on\_init** {#on_init}

This is like getting a hotel room quote when you are booking a hotel room \- "Your charging session will cost ₹100, here are the payment options." It's the charging station saying "I can accommodate your request, here are the terms and how to pay."

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_init",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "timestamp": "2023-07-16T04:41:16Z",  
    "ttl": "15S"  
  },  
  "message": {  
    "order": {  
      "provider": {  
        "id": "cpo1.com",  
        "descriptor": {  
          "name": "CPO1 EV charging Company",  
          "short\_desc": "CPO1 provides EV charging facility across India",  
          "images": \[  
            {  
              "url": "https://cpo1.com/images/logo.png"  
            }  
          \]  
        }  
      },  
      "items": \[  
        {  
          "id": "pe-charging-01",  
          "descriptor": {  
            "name": "EV Charger \#1 (AC Fast Charger)",  
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
          "tags": \[  
            {  
              "descriptor": {  
                "code": "connector-specifications",  
                "name": "Connector Specifications"  
              },  
              "list": \[  
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
                  "value": "AC\_3\_PHASE"  
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
              \]  
            }  
          \]  
        }  
      \],  
      "fulfillments": \[  
        {  
          "id": "fulfillment-001",  
          "type": "CHARGING",  
          "stops": \[  
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
                "short\_desc": "OTP will be shared to the user’s registered number to confirm order"  
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
          \],  
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
      \],  
      "quote": {  
        "price": {  
          "value": "118",  
          "currency": "INR"  
        },  
        "breakup": \[  
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
        \]  
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
        "tax\_id": "GSTIN29ABCDE1234F1Z5"  
      },  
      "payments": \[  
        {  
          "id": "payment-123e4567-e89b-12d3-a456-426614174000",  
          "collected\_by": "BPP",  
          "url": "https://payments.bluechargenet-aggregator.io/pay?transaction\_id=$transaction\_id\&amount=$amount",  
          "params": {  
            "amount": "118.00",  
            "currency": "INR",  
            "bank\_code": "HDFC000123",  
            "bank\_account\_number": "1131324242424"  
          },  
          "type": "PRE-FULFILLMENT",  
          "status": "NOT-PAID",  
          "time": {  
            "timestamp": "2025-07-30T14:59:00Z"  
          },  
          "tags": \[  
            {  
              "descriptor": {  
                "code": "payment-methods"  
              },  
              "list": \[  
                {  
                  "descriptor": {  
                    "code": "BANK-TRANSFER",  
                    "short\_desc": "Pay by transferring to a bank account"  
                  }  
                },  
                {  
                  "descriptor": {  
                    "code": "PAYMENT-LINK",  
                    "short\_desc": "Pay through a bank link received"  
                  }  
                },  
                {  
                  "descriptor": {  
                    "code": "UPI-TRANSFER",  
                    "short\_desc": "Pay by setting a UPI mandate"  
                  }  
                }  
              \]  
            }  
          \]  
        }  
      \],  
      "refund\_terms": \[  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Order Confirmed",  
              "code": "CONFIRMED",  
              "long\_desc": "85% refund available if cancelled at least 4 hours before the scheduled charging time"  
            }  
          },  
          "refund\_eligible": true,  
          "refund\_within": {  
            "duration": "PT2H"  
          },  
          "refund\_amount": {  
            "currency": "INR",  
            "value": "85"  
          }  
        },  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Charging Active",  
              "code": "ACTIVE"  
            }  
          },  
          "refund\_eligible": false  
        }  
      \]  
    }  
  }  
}

Payment Information:

* message.order.payments.id: Unique payment identifier for tracking  
* message.order.payments.collected\_by: Who collects the payment (BPP in this case)  
* message.order.payments.url: Payment gateway URL for processing the transaction  
* message.order.payments.params:  
  * amount: Amount payable in this payment object  
  * currency: Currency of the payment  
  * bank\_code: Bank code of the BPP to send the payment to if the payment method selected is bank transfer   
  * bank\_account\_number: Account number of the BPP to send the payment to if the payment method selected is bank transfer  
* message.order.payments.type: Payment timing (PRE-FULFILLMENT for advance payment)  
* message.order.payments.status: Current payment status (NOT-PAID initially)  
* message.order.payments.tags:  
  * descriptor.code: Code payment-methods is used to define the payment method options available to the user.  
  * List\[\].descriptor.code:  
    * "BANK-TRANSFER": Here the payment is made directly to the bank account  
    * "PAYMENT-LINK": Here the user will use the payment link returned by the BPP to make the payment directly to the BPP.   
    * "UPI-TRANSFER": Here the BPP will use the virtual payment address of the user to send a payment request. If the BAP is choosing this options, the source\_virtual\_payment\_address will also need to be transmitted.

If authorization is required for confirming the order, the BPP will share message.order.fulfillments\[\].stops\[\].authorization.type with the type of authorization that would be required. The BAP will get the authorization data from the user and transmit the same in confirm API.

In cases where **BPP is collecting payment** directly using a payment link and the payment terms dictate that the payment needs to be completed PRE-ORDER, once the payment completion event happens at the BPP’s payment gateway, the BPP may send an unsolicited on\_status call to the BAP with payment.status changed to PAID. Once the BAP receives the same they can trigger the confirm API with payment.status as PAID.

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_status",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "timestamp": "2023-07-16T04:41:16Z",  
    "ttl": "15S"  
  },  
  "message": {  
    "order": {  
      "provider": {  
        "id": "cpo1.com",  
        "descriptor": {  
          "name": "CPO1 EV charging Company",  
          "short\_desc": "CPO1 provides EV charging facility across India",  
          "images": \[  
            {  
              "url": "https://cpo1.com/images/logo.png"  
            }  
          \]  
        }  
      },  
      "items": \[  
        {  
          "id": "pe-charging-01",  
          "descriptor": {  
            "name": "EV Charger \#1 (AC Fast Charger)",  
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
          "tags": \[  
            {  
              "descriptor": {  
                "code": "connector-specifications",  
                "name": "Connector Specifications"  
              },  
              "list": \[  
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
                  "value": "AC\_3\_PHASE"  
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
              \]  
            }  
          \]  
        }  
      \],  
      "fulfillments": \[  
        {  
          "id": "fulfillment-001",  
          "type": "CHARGING",  
          "state": {  
            "descriptor": {  
              "code": "PENDING",  
              "name": "Charging Pending"  
            },  
            "updated\_at": "2025-07-30T12:06:02Z",  
            "updated\_by": "bluechargenet-aggregator.io"  
          },  
          "stops": \[  
            {  
              "type": "START",  
              "time": {  
                "timestamp": "2025-07-16T10:00:00+05:30"  
              },  
              "location": {  
                "gps": "28.345345,77.389754",  
                "descriptor": {  
                  "name": "BlueCharge Connaught Place Station"  
                },  
                "address": "Connaught Place, New Delhi"  
              },  
              "instructions": {  
                "short\_desc": "Ground floor, Pillar Number 4"  
              }  
            },  
            {  
              "type": "START",  
              "time": {  
                "timestamp": "2025-07-16T11:00:00+05:30"  
              }  
            }  
          \],  
          "vehicle": {  
            "make": "Tata",  
            "model": "Nexon EV"  
          },  
        }  
      \],  
      "quote": {  
        "price": {  
          "value": "118",  
          "currency": "INR"  
        },  
        "breakup": \[  
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
          }  
        \]  
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
        "tax\_id": "GSTIN29ABCDE1234F1Z5"  
      },  
      "payments": \[  
        {  
          "id": "payment-123e4567-e89b-12d3-a456-426614174000",  
          "collected\_by": "BPP",  
          "url": "https://payments.bluechargenet-aggregator.io/pay?transaction\_id=$transaction\_id\&amount=$amount",  
          "params": {  
            "transaction\_id": "123e4567-e89b-12d3-a456-426614174000",  
            "amount": "118.00",  
            "currency": "INR"  
          },  
          "type": "ON-ORDER",  
          "status": "PAID",  
          "time": {  
            "timestamp": "2025-07-30T14:59:00Z"  
          }  
        }  
      \],  
      "refund\_terms": \[  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Order Confirmed",  
              "code": "CONFIRMED",  
              "long\_desc": "85% refund available if cancelled at least 4 hours before the scheduled charging time"  
            }  
          },  
          "refund\_eligible": true,  
          "refund\_within": {  
            "duration": "PT2H"  
          },  
          "refund\_amount": {  
            "currency": "INR",  
            "value": "85"  
          }  
        },  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Charging active",  
              "code": "ACTIVE"  
            }  
          },  
          "refund\_eligible": false  
        }  
      \]  
    }  
  }  
}

In case the BAP is not receiving on\_status from the BPP, it may also allow the user to declare they have completed payment and confirm the order using a user input at the BAP.

### **confirm** {#confirm}

This is like clicking "Confirm Booking" on a hotel website after you've completed the payment. You're saying "Yes, I accept these terms and want to proceed with this charging session." The payment has already been processed (you can see the transaction ID in the message), and this is the final confirmation step before your charging session is officially booked.

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
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "timestamp": "2023-07-16T04:41:16Z",  
    "ttl": "15S"  
  },  
  "message": {  
    "order": {  
      "provider": {  
        "id": "cpo1.com"  
      },  
      "items": \[  
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
      \],  
      "offers": \[  
        {  
          "id": "offer-001"  
        }  
      \],  
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
        "tax\_id": "GSTIN29ABCDE1234F1Z5"  
      },  
      "fulfillments": \[  
        {  
          "id": "fulfillment-001",  
          "stops": \[  
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
          \],  
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
      \],  
      "payments": \[  
        {  
          "id": "payment-123e4567-e89b-12d3-a456-426614174000",  
          "collected\_by": "BPP",  
          "url": "https://payments.bluechargenet-aggregator.io/pay?transaction\_id=$transaction\_id\&amount=$amount",  
          "params": {  
            "amount": "118.00",  
            "currency": "INR",  
            "source\_virtual\_payment\_address": "ravi@ptsbi"  
          },  
          "type": "PRE-FULFILLMENT",  
          "status": "NOT-PAID",  
          "time": {  
            "timestamp": "2025-07-30T14:59:00Z"  
          },  
          "tags": \[  
            {  
              "descriptor": {  
                "code": "Payment-methods"  
              },  
              "list": \[  
                {  
                  "descriptor": {  
                    "code": "UPI-TRANFER"  
                  }  
                }  
              \]  
            }  
          \]  
        }  
      \],  
      "tags": \[d  
        {  
          "descriptor": {  
            "code": "buyer-finder-fee"  
          },  
          "list": \[  
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
          \]  
        }  
      \]  
    }  
  }  
}

Payment Confirmation:

* message.order.payments.id: Payment identifier matching the on\_init response  
* message.order.payments.status: Payment status (changed from "NOT-PAID" to "PAID")  
* message.order.payments.params.amount: Confirmed payment amount  
* Message.order.payments.params.source\_virtual\_payment\_address: Virtual payment address to which the collect request will be sent to  
* message.order.payments.tags.list.descriptor.code: Selected payment method

### **on\_confirm** {#on_confirm}

This is like getting a hotel confirmation email \- "Your booking is confirmed\! Here's your reservation number." The charging station is saying "Great\! Your charging session is booked and ready. Here's your order ID and all the details."

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_confirm",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
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
          "short\_desc": "CPO1 provides EV charging facility across India",  
          "images": \[  
            {  
              "url": "https://cpo1.com/images/logo.png"  
            }  
          \]  
        }  
      },  
      "items": \[  
        {  
          "id": "pe-charging-01",  
          "descriptor": {  
            "name": "EV Charger \#1 (AC Fast Charger)",  
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
          "tags": \[  
            {  
              "descriptor": {  
                "code": "connector-specifications",  
                "name": "Connector Specifications"  
              },  
              "list": \[  
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
                  "value": "AC\_3\_PHASE"  
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
              \]  
            }  
          \]  
        }  
      \],  
      "fulfillments": \[  
        {  
          "id": "fulfillment-001",  
          "type": "CHARGING",  
          "state": {  
            "descriptor": {  
              "code": "PENDING",  
              "name": "Charging Pending"  
            },  
            "updated\_at": "2025-07-30T12:06:02Z",  
            "updated\_by": "bluechargenet-aggregator.io"  
          },  
          "stops": \[  
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
                "short\_desc": "Ground floor, Pillar Number 4"  
              }  
            },  
            {  
              "type": "START",  
              "time": {  
                "timestamp": "2025-07-16T11:00:00+05:30"  
              }  
            }  
          \],  
          "vehicle": {  
            "make": "Tata",  
            "model": "Nexon EV"  
          },  
        }  
      \],  
      "quote": {  
        "price": {  
          "value": "118",  
          "currency": "INR"  
        },  
        "breakup": \[  
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
        \]  
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
        "tax\_id": "GSTIN29ABCDE1234F1Z5"  
      },  
      "payments": \[  
        {  
          "id": "payment-123e4567-e89b-12d3-a456-426614174000",  
          "collected\_by": "BPP",  
          "url": "https://payments.bluechargenet-aggregator.io/pay?transaction\_id=$transaction\_id\&amount=$amount",  
          "params": {  
            "transaction\_id": "123e4567-e89b-12d3-a456-426614174000",  
            "amount": "118.00",  
            "currency": "INR"  
          },  
          "type": "PRE-FULFILLMENT",  
          "status": "PAID",  
          "time": {  
            "timestamp": "2025-07-30T14:59:00Z"  
          }  
        }  
      \],  
      "refund\_terms": \[  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Order Confirmed",  
              "code": "CONFIRMED",  
              "long\_desc": "85% refund available if cancelled at least 4 hours before the scheduled charging time"  
            }  
          },  
          "refund\_eligible": true,  
          "refund\_within": {  
            "duration": "PT2H"  
          },  
          "refund\_amount": {  
            "currency": "INR",  
            "value": "85"  
          }  
        },  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Charging Active",  
              "code": "ACTIVE"  
            }  
          },  
          "refund\_eligible": false  
        }  
      \]  
    }  
  }  
}

Order Status:

* message.order.id: Unique order identifier assigned by the BPP  
* message.order.fulfillments.state.descriptor.code: Current order status (e.g., "PENDING")  
* message.order.fulfillments.state.updated\_at: Timestamp of last status update  
* message.order.fulfillments.state.updated\_by: System that updated the status

### **update (start charging)**

Physical Charging Process:

Before initiating the charging session through the API, the EV driver must complete the following physical steps at the charging station:

1. Drive to the charging point: The user arrives at the reserved charging location at the scheduled time  
2. Plug the vehicle: Connect the charging cable from the EVSE (Electric Vehicle Supply Equipment) to their vehicle's charging port  
3. Provide the OTP: Enter or scan the OTP received during the init process to authenticate and authorize the start of the charging session

Once these physical steps are completed, the charging session can be initiated through the update API call.

This is like pressing the "Start" button on a washing machine. You're telling the charging station "I'm ready to start charging now, please begin the session." It's the moment when you actually start using the charging service you booked.

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
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "timestamp": "2023-07-16T04:41:16Z",  
    "ttl": "15S"  
  },  
  "message": {  
    "update\_target": "order.fulfillments\[0\].state",  
    "order": {  
      "id": "123e4567-e89b-12d3-a456-426614174000",  
      "fulfillments": \[  
        {  
          "id": "fulfillment-001",  
          "type": "CHARGING",  
          "state": {  
            "descriptor": {  
              "code": "start-charging"  
            }  
          },  
          "stops": \[  
            {  
              "authorization": {  
                "type": "OTP",  
                "token": "7484"  
              }  
            }  
          \]  
        }  
      \]  
    }  
  }  
}

Update Target:

* message.update\_target: Specifies which part of the order to update (e.g., "order.fulfillments.state")  
* message.order.id: Order identifier from the confirmed booking

State Change:

* message.order.fulfillments.state.descriptor.code: New state value (e.g., "start-charging")  
* message.order.fulfillments.type: Service type (set to "CHARGING")

Authorization:

* message.order.fulfillments.stops.authorization.token: Authorization token for the charging session. This token validates that the user is authorized to start charging at this station.

### **on\_update (start charging)**

This is like getting a "Washing Started" notification from your washing machine. The charging station is saying "Perfect\! Your charging session has begun. You can now track your progress and see how much energy is being delivered to your vehicle."

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_update",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
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
          "short\_desc": "CPO1 provides EV charging facility across India",  
          "images": \[  
            {  
              "url": "https://cpo1.com/images/logo.png"  
            }  
          \]  
        }  
      },  
      "items": \[  
        {  
          "id": "pe-charging-01",  
          "descriptor": {  
            "name": "EV Charger \#1 (AC Fast Charger)",  
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
          "tags": \[  
            {  
              "descriptor": {  
                "code": "connector-specifications",  
                "name": "Connector Specifications"  
              },  
              "list": \[  
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
                  "value": "AC\_3\_PHASE"  
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
              \]  
            }  
          \]  
        }  
      \],  
      "fulfillments": \[  
        {  
          "id": "fulfillment-001",  
          "type": "CHARGING",  
          "state": {  
            "descriptor": {  
              "code": "ACTIVE",  
              "name": "Charging in progress"  
            },  
            "updated\_at": "2025-07-30T12:06:02Z",  
            "updated\_by": "bluechargenet-aggregator.io"  
          },  
          "stops": \[  
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
                "short\_desc": "Ground floor, Pillar Number 4"  
              }  
            }  
          \],  
          "vehicle": {  
            "make": "Tata",  
            "model": "Nexon EV"  
          },  
        }  
      \],  
      "quote": {  
        "price": {  
          "value": "118",  
          "currency": "INR"  
        },  
        "breakup": \[  
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
        \]  
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
        "tax\_id": "GSTIN29ABCDE1234F1Z5"  
      },  
      "payments": \[  
        {  
          "id": "payment-123e4567-e89b-12d3-a456-426614174000",  
          "collected\_by": "bpp",  
          "url": "https://payments.bluechargenet-aggregator.io/pay?transaction\_id=$transaction\_id\&amount=$amount",  
          "params": {  
            "transaction\_id": "123e4567-e89b-12d3-a456-426614174000",  
            "amount": "118.00",  
            "currency": "INR"  
          },  
          "type": "PRE-FULFILLMENT",  
          "status": "PAID",  
          "time": {  
            "timestamp": "2025-07-30T14:59:00Z"  
          }  
        }  
      \],  
      "refund\_terms": \[  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Order Confirmed",  
              "code": "CONFIRMED",  
              "long\_desc": "85% refund available if cancelled at least 4 hours before the scheduled charging time"  
            }  
          },  
          "refund\_eligible": true,  
          "refund\_within": {  
            "duration": "PT2H"  
          },  
          "refund\_amount": {  
            "currency": "INR",  
            "value": "85"  
          }  
        },  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Charging Active",  
              "code": "ACTIVE"  
            }  
          },  
          "refund\_eligible": false  
        }  
      \]  
    }  
  }  
}

Session Status Update:

* message.order.fulfillments.state.descriptor.code: Current session status (changed to "ACTIVE")  
* message.order.fulfillments.state.updated\_at: Timestamp when charging started  
* message.order.fulfillments.state.updated\_by: System that initiated the charging session

### **track**

This is like asking "Where's my package?" on an e-commerce website. You're requesting a link to monitor your charging session in real-time \- how much energy has been delivered, how much it's costing, and when it will be complete. Think of it as getting a "live dashboard" for your charging session.

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
        "bap\_id": "example-bap.com",  
        "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
        "bpp\_id": "example-bpp.com",,  
        "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
        "transaction\_id": "e0a38442-69b7-4698-aa94-a1b6b5d244c2",  
        "message\_id": "6ace310b-6440-4421-a2ed-b484c7548bd5",  
        "timestamp": "2023-02-18T17:00:40.065Z",  
        "version": "1.0.0",  
        "ttl": "PT10M"  
    },  
    "message": {  
        "order\_id": "b989c9a9-f603-4d44-b38d-26fd72286b38"  
        "callback\_url": "https://example-bap-url.com/SESSION/5e4f"  
    }  
}

Tracking Request:

* message.order\_id: Unique order identifier for the charging session to track.  
* This links the tracking request to the specific booking.  
* message.callback\_url: Optional URL which can be provided by the BAP, to which the BPP will trigger PATCH requests (with only fields to be updated and any fields that are left out remain unchanged) with real time details of the charging session.

Tip for NFOs:

* The structure and frequency for the PATCH requests may be decided based on the needs of the network by the NFO. A suggested request structure for the PATCH requests can be found below based on session details in *OCPI-2.2.1*:

{  
  "kwh": 7.35,  
  "status": "ACTIVE",  
  "currency": "INR",  
  "charging\_periods": \[  
    {  
      "start\_date\_time": "2025-09-17T10:55:00Z",  
      "dimensions": \[  
        { "type": "ENERGY", "volume": 0.25 },  
        { "type": "POWER",  "volume": 7.2  },  
        { "type": "CURRENT","volume": 16.0 },  
        { "type": "VOLTAGE","volume": 230.0 },  
        { "type": "STATE\_OF\_CHARGE","volume": 63.0 }  
      \]  
    }  
  \],  
  "total\_cost": {  
    "excl\_vat": 78.50,  
    "incl\_vat": 92.63  
  },  
  "last\_updated": "2025-09-17T10:55:05Z"  
}

* kwh: Total energy consumed during the session in kilowatt-hours.  
* status: Current status of the charging session (e.g., "ACTIVE", "COMPLETED").  
* currency: Currency used for charging costs (e.g., "INR").  
* charging\_periods: Array containing details of different charging intervals within the session.  
  * start\_date\_time: Timestamp when the charging period started.  
  * dimensions: Array of measurements during the charging period.  
    * type: Type of measurement (e.g., "ENERGY", "POWER", "CURRENT", "VOLTAGE", "STATE\_OF\_CHARGE" as per CdrDimensionType *enum in OCPI-2.2.1*).  
    * volume: Value of the measurement.  
* total\_cost: Breakdown of the total cost for the session.  
  * excl\_vat: Total cost excluding VAT.  
  * incl\_vat: Total cost including VAT.  
* last\_updated: Timestamp of the last update to the session details.

### **on\_track**

This is like getting a FedEx tracking link \- "Click here to see your package's journey." The charging station is giving you a special webpage where you can watch your charging session live, see the current power being delivered, and get real-time updates on your charging progress.

{  
    "context": {  
        "domain": "deg:ev-charging",  
        "action": "on\_track",  
        "location": {  
            "city": {  
                "code": "std:080"  
            },  
            "country": {  
                "code": "IND"  
            }  
        },  
        "bap\_id": "example-bap.com",  
        "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
        "bpp\_id": "example-bpp.com",,  
        "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
        "transaction\_id": "e0a38442-69b7-4698-aa94-a1b6b5d244c2",  
        "message\_id": "6ace310b-6440-4421-a2ed-b484c7548bd5",  
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

Tracking Response:

* message.tracking.id: Unique tracking identifier for the charging session  
* message.tracking.url: Live tracking dashboard URL for monitoring charging progress  
* message.tracking.status: Current tracking status (e.g., "active" for ongoing session)

### **Asynchronous on\_status (temporary connection interruption)**

1. This is used in case of a connection interruption during a charging session.  
2. Applicable only in case of temporary connection interruptions, BPPs expect to recover from these connection interruptions in the short term.  
3. BPP notifies the BAP about this interruption using an unsolicited on\_status callback.  
4. NOTE: if the issue remains unresolved and BPP expects it to be a long term issue, BPP must send an unsolicited on\_update to the BAP with relevant details.

#### **Under and Overcharge Scenarios**

##### **A) Undercharge (Power Cut Mid-Session)**

Scenario: The user reserves a 12:45–13:30 slot and prepays ₹500 in the app to the BPP platform. Charging starts on time; the app shows ETA and live ₹/kWh. At 13:05 a power cut stops the charger. The charger loses connectivity and can’t push meter data. The app immediately shows: “Session interrupted—only actual energy will be billed. You may unplug or wait for power to resume.”

Handling & experience:

* User side: Clear banner \+ push notification; live session switches to “Paused (site offline)”. If the user leaves, the session is treated as completed-so-far.  
* CPO/BPP side: When power/comms return, the CMS syncs the actual kWh delivered and stop timestamp.  
* Settlement logic:  
  * If prepaid: compute final ₹ from synced kWh; auto-refund the unused balance to the original instrument; issue invoice.  
  * If auth-hold/UPI mandate (preferred): capture only the final ₹; release remainder instantly.

Contract/UI terms to bake in: “Power/interruption protection: you are charged only for energy delivered; any excess prepayment is automatically refunded on sync.” Show an estimated refund immediately, and a final confirmation after sync.

##### **B) Overcharge (Charger Offline to CMS; Keeps Dispensing)**

Scenario: The user reserves a slot with ₹500 budget. Charging begins; mid-session the charger loses connectivity to its CMS (e.g., basement, patchy network). Hardware keeps dispensing; when connectivity returns, the log shows ₹520 worth of energy delivered.

Handling & experience:

* User side: The app shows “Connectivity issue at site—session continues locally. The final bill will be reconciled in sync.” On sync, the app shows: “Final: ₹520 for X kWh; ₹30 auto-settled.”  
* CPO/BPP side: Charger syncs start/stop/kWh; CMS reconciles vs. contract.

Settlement logic (three safe patterns):

* Buffer in quote (prepaid with overage provision):  
  * Quote line items include: “Energy (₹500) \+ Overage Provision (₹50) — unused portion auto-refunded.”  
  * BPP collects ₹550; captures actual ₹520; refunds ₹30 immediately on sync.  
* Authorization hold / UPI one-time mandate (preferred):  
  * Place a hold/mandate for ₹550; capture ₹520, release ₹30. No debit-then-refund friction.  
* Top-up debit fallback:  
  * If only ₹500 was captured and no mandate exists, the app auto-initiates a ₹20 top-up request (same instrument), with clear messaging and a single-tap confirmation.

Contract/UI terms to bake in: “Offline continuity & overage: sessions may continue locally during short connectivity loss; final billing reflects meter data. We place a buffer hold to avoid delays; unused amounts are released automatically.”

API Implementation: The above under and overcharge scenarios are supported through Beckn protocol callbacks:

* Interruption notification: BPP informs BAP about any session interruption using unsolicited on\_status callback  
* Final billing adjustment: The adjusted bill reflecting overcharge or undercharge reconciliation is conveyed through the on\_update API quote  
* Real-time status updates: Continuous session monitoring and status communication ensure transparent billing for actual energy delivered

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_status",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
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
          "short\_desc": "CPO1 provides EV charging facility across India",  
          "images": \[  
            {  
              "url": "https://cpo1.com/images/logo.png"  
            }  
          \]  
        }  
      },  
      "items": \[  
        {  
          "id": "pe-charging-01",  
          "descriptor": {  
            "name": "EV Charger \#1 (AC Fast Charger)",  
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
          "tags": \[  
            {  
              "descriptor": {  
                "code": "connector-specifications",  
                "name": "Connector Specifications"  
              },  
              "list": \[  
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
                  "value": "AC\_3\_PHASE"  
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
              \]  
            }  
          \]  
        }  
      \],  
      "fulfillments": \[  
        {  
          "id": "fulfillment-001",  
          "type": "CHARGING",  
          "state": {  
            "descriptor": {  
              "code": "CONNECTION-INTERRUPTED",  
              "name": "Charging connection lost. Retrying automatically. If this continues, please check your cable"  
            },  
            "updated\_at": "2025-07-30T13:07:02Z",  
            "updated\_by": "bluechargenet-aggregator.io"  
          },  
          "stops": \[  
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
                "short\_desc": "Ground floor, Pillar Number 4"  
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
                "short\_desc": "Ground floor, Pillar Number 4"  
              }  
            }  
          \]  
        }  
      \],  
      "quote": {  
        "price": {  
          "value": "85",  
          "currency": "INR"  
        },  
        "breakup": \[  
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
              "value": "10"  
            }  
          }  
        \]  
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
        "tax\_id": "GSTIN29ABCDE1234F1Z5"  
      },  
      "payments": \[  
        {  
          "id": "payment-123e4567-e89b-12d3-a456-426614174000",  
          "collected\_by": "bpp",  
          "url": "https://payments.bluechargenet-aggregator.io/pay?transaction\_id=$transaction\_id\&amount=$amount",  
          "params": {  
            "transaction\_id": "123e4567-e89b-12d3-a456-426614174000",  
            "amount": "118.00",  
            "currency": "INR"  
          },  
          "type": "PRE-FULFILLMENT",  
          "status": "PAID",  
          "time": {  
            "timestamp": "2025-07-30T14:59:00Z"  
          }  
        }  
      \],  
      "refund\_terms": \[  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Order Confirmed",  
              "code": "CONFIRMED",  
              "long\_desc": "85% refund available if cancelled at least 4 hours before the scheduled charging time"  
            }  
          },  
          "refund\_eligible": true,  
          "refund\_within": {  
            "duration": "PT2H"  
          },  
          "refund\_amount": {  
            "currency": "INR",  
            "value": "85"  
          }  
        },  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Charging Active",  
              "code": "ACTIVE"  
            }  
          },  
          "refund\_eligible": false  
        }  
      \]  
    }  
  }  
}

Session Interruptions:

* Message.order.fulfillments.state.descriptor.code: Interruption state (changed to "CONNECTION-INTERRUPTED")  
* Message.order.fulfillments.state.descriptor.name: (changed to a relevant notification)  
* message.order.fulfillments.state.updated\_at: Timestamp when charging session ended  
* message.order.fulfillments.state.updated\_by: System that completed the session

### **Asynchronous on\_update (stop charging)**

This is like getting a "Washing Complete" notification from your washing machine. The charging station is saying "Your charging session has finished\! Here's the final bill and session summary."

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_update",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
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
          "short\_desc": "CPO1 provides EV charging facility across India",  
          "images": \[  
            {  
              "url": "https://cpo1.com/images/logo.png"  
            }  
          \]  
        }  
      },  
      "items": \[  
        {  
          "id": "pe-charging-01",  
          "descriptor": {  
            "name": "EV Charger \#1 (AC Fast Charger)",  
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
          "tags": \[  
            {  
              "descriptor": {  
                "code": "connector-specifications",  
                "name": "Connector Specifications"  
              },  
              "list": \[  
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
                  "value": "AC\_3\_PHASE"  
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
              \]  
            }  
          \]  
        }  
      \],  
      "fulfillments": \[  
        {  
          "id": "fulfillment-001",  
          "type": "CHARGING",  
          "state": {  
            "descriptor": {  
              "code": "COMPLETED",  
              "name": "Charging completed"  
            },  
            "updated\_at": "2025-07-30T13:07:02Z",  
            "updated\_by": "bluechargenet-aggregator.io"  
          },  
          "stops": \[  
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
                "short\_desc": "Ground floor, Pillar Number 4"  
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
                "short\_desc": "Ground floor, Pillar Number 4"  
              }  
            }  
          \]  
        }  
      \],  
      "quote": {  
        "price": {  
          "value": "78",  
          "currency": "INR"  
        },  
        "breakup": \[  
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
        \]  
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
        "tax\_id": "GSTIN29ABCDE1234F1Z5"  
      },  
      "payments": \[  
        {  
          "id": "payment-123e4567-e89b-12d3-a456-426614174000",  
          "collected\_by": "bpp",  
          "url": "https://payments.bluechargenet-aggregator.io/pay?transaction\_id=$transaction\_id\&amount=$amount",  
          "params": {  
            "transaction\_id": "123e4567-e89b-12d3-a456-426614174000",  
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
           "status": "NOT\_PAID",  
           "tags": \[  
             {  
               "descriptor": {  
                 "code": "refund-type",  
               },  
               "value": "OVERCHARGE\_REFUND"  
             },  
             {  
               "descriptor": {  
                 "code": "refund-amount",  
               },  
               "value": "33INR"  
             }  
           \]  
        }  
      \],  
      "refund\_terms": \[  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Order Confirmed",  
              "code": "CONFIRMED",  
              "long\_desc": "85% refund available if cancelled at least 4 hours before the scheduled charging time"  
            }  
          },  
          "refund\_eligible": true,  
          "refund\_within": {  
            "duration": "PT2H"  
          },  
          "refund\_amount": {  
            "currency": "INR",  
            "value": "85"  
          }  
        },  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Charging Active",  
              "code": "ACTIVE"  
            }  
          },  
          "refund\_eligible": false  
        }  
      \]  
    }  
  }  
}

Session Completion:

* message.order.fulfillments.state.descriptor.code: Final session status (changed to "COMPLETED")  
* message.order.fulfillments.state.updated\_at: Timestamp when charging session ended  
* message.order.fulfillments.state.updated\_by: System that completed the session

Session Timeline:

* message.order.fulfillments.stops.time.timestamp: Session start time  
* message.order.fulfillments.stops.time.timestamp: Session end time  
* message.order.fulfillments.stops.type: Set to "finish" indicating session completion

### **Rating**

This is like leaving a review on Amazon or rating your Uber driver. You're giving feedback on your charging experience \- how easy it was to find the station, how fast the charging was, and overall satisfaction. It helps other users and improves the service.

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
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "timestamp": "2023-07-16T04:41:16Z"  
  },  
  "message": {  
    "ratings": \[  
      {  
        "id": "fulfillment-001",  
        "rating\_category": "Fulfillment",  
        "value": "5"  
      }  
    \]  
  }  
}

### **on\_rating**

This is like getting a "Thank you for your review\!" message from Amazon. The charging station is acknowledging your rating and might ask for more detailed feedback.

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_rating",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "timestamp": "2023-07-16T04:41:16Z"  
  },  
  "message": {  
    "feedback\_form": {  
      "form": {  
        "url": "https://example-bpp.comfeedback/portal",  
   "mime\_type": "application/xml"

      },  
      "required": false  
    }  
  }  
}

### **support**

This is like calling customer service when you have a problem with your hotel booking. You're asking for help with your charging session \- maybe the charger isn't working, you have a billing question, or you need to report an issue. It's your way of getting assistance when something goes wrong.

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
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "timestamp": "2023-07-16T04:41:16Z"  
  },  
  "message": {  
    "support": {  
      "ref\_id": "6743e9e2-4fb5-487c-92b7",  
	 "callback\_phone": "+911234567890",  
      "email": "ravi.kumar@bookmycharger.com"  
    }  
  }  
}

### **on\_support**

This is like getting a customer service response \- "Here's our support phone number, email, and a link to create a support ticket." The charging station is providing you with contact information and ways to get help, similar to how a hotel would give you their front desk number and manager's contact details.

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_support",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "timestamp": "2023-07-16T04:41:16Z"  
  },  
  "message": {  
    "support": {  
      "ref\_id": "6743e9e2-4fb5-487c-92b7",  
      "phone": "18001080",  
      "email": "support@bluechargenet-aggregator.io",  
      "url": "https://support.bluechargenet-aggregator.io/ticket/SUP-20250730-001"  
    }  
  }  
}

## **Use case 2- Walk-In to a charging station without reservation.**

This section covers a walk-in case where users discover the charger using third-party apps, word of mouth, or Beckn API, and then drive to the location without advance booking.

Technical Implementation Perspective:

From a technical standpoint, this walk-in scenario is comparable to booking an instant slot after reaching the location. While it may appear different from a user experience perspective, the underlying API calls and system processes remain largely the same as the advance reservation use case, with key differences in timing and availability checks:

* Real-time availability: The system checks for immediate slot availability instead of future time slots  
* Instant booking: The entire discovery → select → init → confirm flow happens within minutes at the physical location  
* Same API endpoints: Uses identical Beckn protocol calls but with compressed timeframes  
* Immediate fulfillment: The charging session can start immediately after confirmation, rather than waiting for a scheduled time

Operational Context:

The order flow happens while the user is physically present at the charging station. This creates a more compressed transaction timeline where all booking steps occur on-site, making it essential for the system to handle real-time availability updates and quick response times to ensure a smooth user experience.

### **User journey:**

A 34-year-old sales manager who drives an EV to client meetings. He’s time-bound, cost-conscious, and prefers simple, scan-and-go experiences. Raghav arrives at a large dine-in restaurant for a one-hour client meeting. He notices a charging bay in the parking lot and decides to top up while he’s inside.

**Discovery:** Raghav opens his EV app, taps sScan & Charge, and scans the QR on the charger. The app pulls the charger’s details (connector, power rating, live status, tariff, any active time-bound offer).

**Order:** Raghav selects a 60-minute top-up, reviews session terms (rate, idle fee window, cancellation rules), and confirms. He chooses UPI and authorizes payment (or an authorization hold, as supported). The app returns a booking/transaction ID.

**Fulfilment:** He plugs in and starts the session from the app. Live progress (kWh, ₹ consumed, ETA) is shown while he’s in the meeting. If the bay has a lunch-hour promo, the discounted rate is applied automatically.

**Post-Fulfilment:** At \~60 minutes, the session stops (or notifies him to unplug). He receives a digital invoice and session summary in-app. If anything went wrong (e.g., session interrupted, SOC reaches 100%, etc.), the app reconciles to bill only for energy delivered and issues any adjustment or refund automatically.

## **API Calls and Schema**

Note: The API calls and schema for walk-in charging are identical to the advance reservation use case (Use Case 1\) with minor differences in timing and availability. Where sections reference Use Case 1, the same API structure, field definitions, and examples apply unless specifically noted otherwise.

### **Search**

Consumer searches for EV charging stations with specific criteria including location, connector type, and category filters.

The search functionality works identically to the advance reservation use case described above. Please refer to the [Search section](#search) in Use Case 1 for detailed API specifications and examples.

Alternative Discovery Scenario:

Another possibility is that users discover the charging station through off-network channels (such as physical signage, word-of-mouth, or third-party apps not integrated with Beckn) and arrive directly at the location to initiate charging. In this scenario:

* The discovery phase is skipped entirely  
* Users proceed directly to the Select API call by scanning QR codes or using location-based identification  
* The charging station must be able to handle direct selection requests without prior search/discovery  
* This represents a more streamlined flow for walk-in customers who have already identified their preferred charging location

### **on\_search**

The on\_search response structure and content are identical to the advance reservation use case. Please refer to the [on\_search section](#on_search) in Use Case 1 for detailed response schema, field descriptions, and examples.

Key difference for walk-in scenario: The availability time slots in fulfillments.stops\[\].time.range will show immediate availability (current time onwards) rather than future scheduled slots.

### **Select**

The select functionality works identically to the advance reservation use case. Please refer to the [Select section](#select) in Use Case 1 for detailed API specifications, request structure, and examples.

Key difference for walk-in scenario: The selected time slots will be for immediate charging rather than future scheduled slots.

### **on\_select**

The on\_select response structure and pricing logic are identical to the advance reservation use case. Please refer to the [on\_select section](#on_select) in Use Case 1 for detailed response schema, quote breakup, and field descriptions.

### **init**

The init functionality works identically to the advance reservation use case. Please refer to the [init section](#init) in Use Case 1 for detailed API specifications, request structure, and examples.

Key difference for walk-in scenario: The init process happens immediately at the charging location rather than in advance.

### **on\_init**

The on\_init response structure and payment options are identical to the advance reservation use case. Please refer to the [on\_init section](#on_init) in Use Case 1 for detailed response schema, payment methods, and field descriptions.

### **confirm**

The confirm functionality works identically to the advance reservation use case. Please refer to the [confirm section](#confirm) in Use Case 1 for detailed API specifications, payment confirmation, and examples.

Key difference for walk-in scenario: The confirmation happens immediately at the location rather than for a future scheduled session.

### **on\_confirm**

The on\_confirm response structure and order confirmation details are identical to the advance reservation use case. Please refer to the [on\_confirm section](#on_confirm) in Use Case 1 for detailed response schema, order status, and field descriptions.

Note: All remaining API calls (track, on\_track, asynchronous on\_update, on\_status, rating, on\_rating, support, on\_support) work exactly the same as the advance reservation use case (Use Case 1).

## **Use case 3- Loyalty program discovery and subscription**

This section covers the discovery and subscription process for loyalty programs offered by charging providers, enabling users to access preferential pricing and exclusive benefits.

### **User journey:**

Kavya Nair, a 32-year-old consultant who charges 3- 4 times a week along Bengaluru corridors. She’s price-sensitive and happy to pay for a loyalty that reliably reduces per-kWh costs at her usual CPOs.

Subscribing to a loyalty program (as a catalog item)

Discovery: While planning an early reservation for the day, Kavya sees a “CPO Gold Pass – ₹299/month” in her EV app’s catalog.

Order:

* The app clearly separates the Charging vs Loyalty program using category codes. Kavya taps the LOY item, views benefits (-10% on weekdays, idle fee waiver 15 min, priority slots), and buys it standalone. (The app could also offer a bundle: “Book charger \+ add Gold Pass now”.)  
* She is redirected to the loyalty details page (through a ‘know more’ link) where she completes the purchase. Thus loyalty is bound to her mobile number (primary identifier; email as secondary).  
* The BPP confirms activation and tier \= Gold with validity dates. The app adds this program to her “My Loyalty Map” so she sees where it applies.

Tip to BAPs (product hint)

* Treat loyalty as a retail SKU with its own category code and lifecycle.  
* BPPs can bundle loyalty as a catalog response for every search or in selective cases. It may not always necessarily need a separate search call.

## **API Calls and Schema**

### **Search**

The consumer searches for available loyalty programs by specifying the loyalty program category. This targeted search allows users to discover subscription-based loyalty offerings from charging providers without mixing them with charging station results.

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
    "message\_id": "e138f204-ec0b-415d-9c9a-7b5bafe10bfe",  
    "transaction\_id": "2ad735b9-e190-457f-98e5-9702fd895996",  
    "domain": "deg:ev-charging",  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
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

The consumer can also perform a free text search to discover loyalty programs by name or description. This flexible search method allows users to find specific loyalty programs using natural language queries, making program discovery more intuitive and accessible.

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
    "message\_id": "e138f204-ec0b-415d-9c9a-7b5bafe10bfe",  
    "transaction\_id": "2ad735b9-e190-457f-98e5-9702fd895996",  
    "domain": "deg:ev-charging",  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
  },  
  "message": {  
    "intent": {  
        "descriptor": {  
          "name": "loyalty programs"  
        }  
    }  
  }  
}

### **on\_search**

The BPP responds with a comprehensive catalog of available loyalty programs from the network. This response includes detailed program information, pricing, benefits, and subscription terms for each loyalty offering. The catalog can be delivered either as a direct response to consumer search requests or proactively as unsolicited recommendations based on user preferences and charging patterns.

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_search",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "timestamp": "2023-07-16T04:41:16Z"  
  },  
  "message": {  
    "catalog": {  
      "providers": \[  
        {  
          "id": "cpo1.com",  
          "descriptor": {  
            "name": "CPO1 EV Charging Company",  
            "short\_desc": "Premium EV charging network across India",  
            "images": \[  
              {  
                "url": "https://cpo1.com/images/logo.png"  
              }  
            \]  
          },  
          "categories": \[  
            {  
              "id": "loyalty-programs",  
              "descriptor": {  
                "code": "loyalty-program",  
                "name": "Loyalty Programs"  
              }  
            }  
          \],  
          "items": \[  
            {  
              "id": "loyalty-gold-pass",  
              "descriptor": {  
                "name": "CPO Gold Pass",  
                "code": "loyalty-subscription",  
                "short\_desc": "Premium loyalty program with exclusive benefits",  
                "long\_desc": "Get 10% discount on weekday charging, idle fee waiver up to 15 minutes, priority access to charging slots, and dedicated customer support.",  
                "additional\_desc": {  
                  "url": "https://example-bpp.com/gold-pass.html",  
                  "content-type": "text/html"  
                },  
                "images": \[  
                  {  
                    "url": "https://cpo1.com/images/gold-pass.png"  
                  }  
                \]  
              },  
              "price": {  
                "value": "299",  
                "currency": "INR"  
              },  
              "category\_ids": \[  
                "loyalty-programs"  
              \],  
              "tags": \[  
                {  
                  "descriptor": {  
                    "code": "loyalty-benefits",  
                    "name": "Program Benefits"  
                  },  
                  "list": \[  
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
                  \]  
                },  
                {  
                  "descriptor": {  
                    "code": "subscription-details",  
                    "name": "Subscription Details"  
                  },  
                  "list": \[  
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
                  \]  
                }  
              \]  
            },  
            {  
              "id": "loyalty-platinum-pass",  
              "descriptor": {  
                "name": "CPO Platinum Pass",  
                "code": "loyalty-subscription",  
                "short\_desc": "Ultimate loyalty program with maximum savings",  
                "long\_desc": "Enjoy 15% discount on all charging sessions, idle fee waiver up to 30 minutes, guaranteed slot availability, premium customer support, and exclusive access to new stations.",  
                "additional\_desc": {  
                  "url": "https://example-bpp.com/platinum-pass.html",  
                  "content-type": "text/html"  
                },  
                "images": \[  
                  {  
                    "url": "https://cpo1.com/images/platinum-pass.png"  
                  }  
                \]  
              },  
              "price": {  
                "value": "499",  
                "currency": "INR"  
              },  
              "category\_ids": \[  
                "loyalty-programs"  
              \],  
              "tags": \[  
                {  
                  "descriptor": {  
                    "code": "loyalty-benefits",  
                    "name": "Program Benefits"  
                  },  
                  "list": \[  
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
                  \]  
                },  
                {  
                  "descriptor": {  
                    "code": "subscription-details",  
                    "name": "Subscription Details"  
                  },  
                  "list": \[  
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
                  \]  
                }  
              \]  
            }  
          \]  
        }  
      \]  
    }  
  }  
}

Loyalty program catalogs can be bundled together with charging station catalogs in a single response. This integrated approach allows consumers to discover both charging services and loyalty programs simultaneously, enabling cross-selling opportunities and providing a comprehensive view of available offerings from charging providers.

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_search",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "timestamp": "2023-07-16T04:41:16Z"  
  },  
  "message": {  
    "catalog": {  
      "providers": \[  
        {  
          "id": "cpo1.com",  
          "descriptor": {  
            "name": "CPO1 EV charging Company",  
            "short\_desc": "CPO1 provides EV charging facility across India",  
            "images": \[  
              {  
                "url": "https://cpo1.com/images/logo.png"  
              }  
            \]  
          },  
          "categories": \[  
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
          \],  
          "locations": \[  
            {  
              "id": "LOC-DELHI-001",  
              "gps": "28.345345,77.389754",  
              "descriptor": {  
                "name": "BlueCharge Connaught Place Station"  
              },  
              "address": "Connaught Place, New Delhi"  
            }  
          \],  
          "fulfillments": \[  
            {  
              "id": "fulfillment-001",  
              "type": "CHARGING",  
              "stops": \[  
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
              \]  
            },  
            {  
              "id": "fulfillment-002",  
              "type": "DIGITAL",  
              "stops": \[  
                {  
                  "type": "START",  
                  "time": {  
                    "timestamp": "2025:09:24:10:15:00"  
                  }  
                }  
              \]  
            }  
          \],  
          "items": \[  
            {  
              "id": "pe-charging-01",  
              "descriptor": {  
                "name": "EV Charger \#1 (AC Fast Charger)",  
                "code": "CHARGER",  
                "short\_desc": "Book now"  
              },  
              "price": {  
                "value": "18",  
                "currency": "INR/kWh"  
              },  
              "fulfillment\_ids": \[  
                "fulfillment-001"  
              \],  
              "category\_ids": \[  
                "category-gt"  
              \],  
              "location\_ids": \[  
                "LOC-DELHI-001"  
              \],  
              "tags": \[  
                {  
                  "descriptor": {  
                    "code": "connector-specifications",  
                    "name": "Connector Specifications"  
                  },  
                  "list": \[  
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
                      "value": "AC\_3\_PHASE"  
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
                  \]  
                }  
              \]  
            },  
            {  
              "id": "loyalty-gold-pass",  
              "descriptor": {  
                "name": "CPO Gold Pass",  
                "code": "loyalty-subscription",  
                "short\_desc": "Premium loyalty program with exclusive benefits",  
                "long\_desc": "Get 10% discount on weekday charging, idle fee waiver up to 15 minutes, priority access to charging slots, and dedicated customer support.",  
                "additional\_desc": {  
                  "url": "https://example-bpp.com/gold-pass.html",  
                  "content-type": "text/html"  
                }  
              },  
              "price": {  
                "value": "299",  
                "currency": "INR"  
              },  
              "fulfillment\_ids": \[  
                "fulfillment-002"  
              \],  
              "category\_ids": \[  
                "loyalty-programs"  
              \],  
              "tags": \[  
                {  
                  "descriptor": {  
                    "code": "loyalty-benefits",  
                    "name": "Program Benefits"  
                  },  
                  "list": \[  
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
                  \]  
                },  
                {  
                  "descriptor": {  
                    "code": "subscription-details",  
                    "name": "Subscription Details"  
                  },  
                  "list": \[  
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
                  \]  
                }  
              \]  
            }  
          \]  
        }  
      \]  
    }  
  }  
}

Note: These are just example catalogs. CPOs are encouraged to innovate on various catalog offerings that involve a wide set of features . More such examples will be added to this document in future releases.

The BPP may create a page with the details of the loyalty program including terms and conditions and transmit it via item.descriptor.additional\_desc. The tags are optional and the BAP may display the same to the end user. They are not standardised and the BPP may transmit them as per their discretion and structure of the loyalty program.

### **Select**

The consumer selects a specific loyalty program from the available catalog to proceed with subscription. This call initiates the ordering process by specifying the chosen loyalty program item. The BAP sends this request to confirm the user's intent to purchase the loyalty subscription.

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
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "select-loyalty-msg-001",  
    "timestamp": "2025:09:24:10:05:00",  
    "ttl": "15S"  
  },  
  "message": {  
    "order": {  
      "provider": {  
        "id": "cpo1.com"  
      },  
      "items": \[  
        {  
          "id": "loyalty-gold-pass"  
        }  
      \],  
      "fulfillments": \[  
        {  
          "id": "fulfillment-002",  
          "type": "DIGITAL"  
        }  
      \]  
    }  
  }  
}

### **on\_select**

The BPP responds with a detailed quotation for the selected loyalty program, including pricing breakdown and subscription terms. This response provides all necessary information for the consumer to make an informed purchase decision. The fulfillment status indicates the program is ready for activation upon payment completion.

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_select",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "on-select-loyalty-msg-001",  
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
      "items": \[  
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
      \],  
      "fulfillments": \[  
        {  
          "id": "fulfillment-002",  
          "type": "DIGITAL"  
        }  
      \],  
      "quote": {  
        "price": {  
          "value": "299",  
          "currency": "INR"  
        },  
        "breakup": \[  
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
        \]  
      }  
    }  
  }  
}

### **Init**

The consumer initiates the loyalty program purchase by providing complete billing information. This call establishes the customer's identity and billing details required for subscription activation. The BAP includes customer contact information that will be used for loyalty program binding and future communications related to the subscription service.

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
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "init-loyalty-msg-001",  
    "timestamp": "2025:09:24:10:10:00",  
    "ttl": "15S"  
  },  
  "message": {  
    "order": {  
      "provider": {  
        "id": "cpo1.com"  
      },  
      "items": \[  
        {  
          "id": "loyalty-gold-pass"  
        }  
      \],  
      "fulfillments": \[  
        {  
          "id": "fulfillment-002",  
          "type": "DIGITAL"  
        }  
      \],  
      "billing": {  
        "name": "Kavya Nair",  
        "phone": "+91-9876543210",  
        "email": "kavya.nair@email.com",  
        "address": "123 MG Road, Indiranagar, Bengaluru, Karnataka 560038"  
      }  
    }  
  }  
}

### **on\_init**

The BPP responds with comprehensive payment information and loyalty program activation details. This response includes payment gateway links, subscription validity periods, tier level confirmation, and activation timeline. The BPP confirms all billing information and provides the consumer with clear expectations about program benefits and activation process upon successful payment completion.

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_init",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "on-init-loyalty-msg-001",  
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
      "items": \[  
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
          "tags": \[  
            {  
              "descriptor": {  
                "code": "loyalty-activation",  
                "name": "Loyalty Program Activation"  
              },  
              "list": \[  
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
              \]  
            }  
          \]  
        }  
      \],  
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
        "breakup": \[  
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
        \]  
      },  
      "payments": \[  
        {  
          "id": "payment-001",  
          "type": "PRE-ORDER",  
          "status": "NOT-PAID",  
          "params": {  
            "amount": "299",  
            "currency": "INR",  
            "payment\_link": "https://payments.cpo1.com/pay/loyalty-gold-pass-001"  
          }  
        }  
      \],  
      "cancellation\_terms": \[  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Subscription Active",  
              "code": "ACTIVE"  
            }  
          },  
          "cancellation\_eligible": true,  
          "cancellation\_fee": {  
            "amount": {  
              "value": "0",  
              "currency": "INR"  
            }  
          },  
          "applicable\_within": {  
            "duration": "P30D"  
          }  
        }  
      \]  
    }  
  }  
}

### **confirm**

The consumer confirms the loyalty program purchase after successful payment completion. This call includes payment transaction details and serves as final confirmation of the subscription order. The BAP sends this request with updated payment status to trigger the loyalty program activation process and establish the customer's membership in the selected tier.

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
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "confirm-loyalty-msg-001",  
    "timestamp": "2025:09:24:10:15:00",  
    "ttl": "15S"  
  },  
  "message": {  
    "order": {  
      "provider": {  
        "id": "cpo1.com"  
      },  
      "items": \[  
        {  
          "id": "loyalty-gold-pass"  
        }  
      \],  
      "fulfillments": \[  
        {  
          "id": "fulfillment-002",  
          "type": "DIGITAL"  
        }  
      \],  
      "billing": {  
        "name": "Kavya Nair",  
        "phone": "+91-9876543210",  
        "email": "kavya.nair@email.com",  
        "address": "123 MG Road, Indiranagar, Bengaluru, Karnataka 560038"  
      },  
      "payments": \[  
        {  
          "id": "payment-001",  
          "type": "PRE-ORDER",  
          "status": "PAID",  
          "params": {  
            "amount": "299",  
            "currency": "INR",  
            "transaction\_id": "txn-loyalty-001"  
          }  
        }  
      \]  
    }  
  }  
}

### **on\_confirm**

The BPP confirms successful loyalty program activation and provides comprehensive membership details. This response establishes the active subscription with unique membership ID, tier benefits, validity periods, and auto-renewal settings. The digital fulfillment is marked as active with customer binding, confirming that the loyalty program benefits are immediately available for use in future charging sessions.

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_confirm",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "on-confirm-loyalty-msg-001",  
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
      "items": \[  
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
          "tags": \[  
              {  
                "descriptor": {  
                  "code": "loyalty-membership",  
                  "name": "Loyalty Membership Details"  
                },  
                "list": \[  
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
                \]  
              },  
              {  
                "descriptor": {  
                  "code": "loyalty-benefits",  
                  "name": "Active Benefits"  
                },  
                "list": \[  
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
                \]  
              }  
            \]  
        }  
      \],  
      "fulfillments": \[  
        {  
          "id": "fulfillment-002",  
          "type": "DIGITAL",  
          "state": {  
            "descriptor": {  
              "code": "ACTIVE",  
              "name": "Loyalty Program Active"  
            }  
          },  
          "stops": \[  
            {  
              "type": "START",  
              "time": {  
                "timestamp": "2025:09:24:10:15:30"  
              }  
            }  
          \],  
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
      \],  
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
        "breakup": \[  
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
        \]  
      },  
      "payments": \[  
        {  
          "id": "payment-001",  
          "type": "PRE-ORDER",  
          "status": "PAID",  
          "params": {  
            "amount": "299",  
            "currency": "INR",  
            "transaction\_id": "txn-loyalty-001"  
          }  
        }  
      \],  
      "cancellation\_terms": \[  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Subscription Active",  
              "code": "ACTIVE"  
            }  
          },  
          "cancellation\_eligible": true,  
          "cancellation\_fee": {  
            "amount": {  
              "value": "0",  
              "currency": "INR"  
            }  
          },  
          "applicable\_within": {  
            "duration": "P30D"  
          }  
        }  
      \]  
    }  
  }  
}

### **on\_status**

BPP provides the current status of the loyalty program subscription, including membership details, and tier progression information.

{  
  "context": {  
    "domain": "deg:ev-charging",  
    "action": "on\_status",  
    "location": {  
      "country": {  
        "code": "IND"  
      },  
      "city": {  
        "code": "std:080"  
      }  
    },  
    "version": "1.1.0",  
    "bap\_id": "example-bap.com",  
    "bap\_uri": "https://api.example-bap.com/pilot/bap/energy/v1",  
    "bpp\_id": "example-bpp.com",  
    "bpp\_uri": "https://example-bpp.com/pilot/bap/energy/v1",  
    "transaction\_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",  
    "message\_id": "on-status-loyalty-msg-001",  
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
      "items": \[  
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
          "tags": \[  
            {  
                "descriptor": {  
                    "code": "loyalty-membership",  
                    "name": "Loyalty Membership Details"  
                },  
                "list": \[  
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
                \]  
            },  
            {  
                "descriptor": {  
                    "code": "usage-statistics",  
                    "name": "Usage Statistics"  
                },  
                "list": \[  
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
                \]  
            },  
            {  
                "descriptor": {  
                    "code": "tier-progress",  
                    "name": "Tier Upgrade Progress"  
                },  
                "list": \[  
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
                \]  
            }  
          \]  
        }  
      \],  
      "fulfillments": \[  
        {  
          "id": "fulfillment-002",  
          "type": "DIGITAL",  
          "state": {  
            "descriptor": {  
              "code": "ACTIVE",  
              "name": "Loyalty Program Active"  
            }  
          },  
          "stops": \[  
            {  
              "type": "START",  
              "time": {  
                "timestamp": "2025:09:24:10:15:30"  
              }  
            }  
          \],  
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
      \],  
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
        "breakup": \[  
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
        \]  
      },  
      "payments": \[  
        {  
          "id": "payment-001",  
          "type": "PRE-ORDER",  
          "status": "PAID",  
          "params": {  
            "amount": "299",  
            "currency": "INR",  
            "transaction\_id": "txn-loyalty-001"  
          }  
        }  
      \],  
      "cancellation\_terms": \[  
        {  
          "fulfillment\_state": {  
            "descriptor": {  
              "name": "Subscription Active",  
              "code": "ACTIVE"  
            }  
          },  
          "cancellation\_eligible": true,  
          "cancellation\_fee": {  
            "amount": {  
              "value": "0",  
              "currency": "INR"  
            }  
          },  
          "applicable\_within": {  
            "duration": "P30D"  
          }  
        }  
      \]  
  }  
}

Using the Loyalty Program in a Charging Session Next day, Kavya searches for a fast charger near Indiranagar.

Discovery

* Her BAP sends the init call and pushes the billing information (consisting of the loyalty mobile number);  
* BPP/CPO CMS checks identifiers (mobile/email) and detects an active Gold program.  
* The quote returned includes a loyalty line item (e.g., “Gold discount –10%”), clearly separated from energy and fees.

Order

* The app presents a revised quote showing base tariff, loyalty discount, and net payable.  
* Kavya accepts and proceeds (UPI or direct-to-CPO, per terms).

Fulfilment

* Charging runs as usual. Mid-session status shows kWh, base ₹, loyalty ₹ saved, and ETA.

Post-Fulfilment

* Invoice itemizes:  
* Energy (kWh x rate)  
* Loyalty Discount (Gold)  
* Idle Fee (waived up to 15 min)

If her monthly spend crosses the next threshold, the on\_status event upgrades her to Platinum, with a push note: “You’ve been upgraded to Platinum- new benefits apply from next session.”

## **Integrating with your software**

This section gives a general walkthrough of how you would integrate your software with the Beckn network (say the sandbox environment). Refer to the starter kit for details on how to register with the sandbox and get credentials.

Beckn-ONIX is an initiative to promote easy installation and maintenance of a Beckn Network. Apart from the Registry and Gateway components that are required for a network facilitator, Beckn-ONIX provides a Beckn Adapter. A reference implementation of the Beckn-ONIX specification is available at [Beckn-ONIX repository](https://github.com/beckn/beckn-onix). The reference implementation of the Beckn Adapter is called the Protocol Server. Based on whether we are writing the seeker platform or the provider platform, we will be installing the BAP Protocol Server or the BPP Protocol Server respectively.

### **Integrating the seeker platform**

If you are writing the seeker platform software, the following are the steps you can follow to build and integrate your application.

1. Identify the use cases from the above section that are close to the functionality you plan for your application.  
2. Design and develop the UI that implements the flow you need. Typically you will have an API server that this UI talks to and it is called the Seeker Platform in the diagram below.  
3. The API server should construct the required JSON message packets required for the different endpoints shown in the API section above.  
4. Install the BAP Protocol Server using the reference implementation of Beckn-ONIX. During the installation, you will need the address of the registry of the environment, a URL where the Beckn responses will arrive (called Subscriber URL) and a subscriber\_id (typically the same as subscriber URL without the "https://" prefix)  
5. Install the layer 2 file for the domain (Link is in the last section of this document)  
6. Check with your network tech support to enable your BAP Protocol Server in the registry.  
7. Once enabled, you can transact on the Beckn Network. Typically the sandbox environment will have the rest of the components you need to test your software. In the diagram below,  
   * you write the Seeker Platform(dark blue)  
   * install the BAP Protocol Server (light blue)  
   * the remaining components are provided by the sandbox environment  
8. Once the application is working on the Sandbox, refer to the Starter kit for instructions to take it to pre-production and production.

### **Integrating the provider platform**

If you are writing the provider platform software, the following are the steps you can follow to build and integrate your application.

1. Identify the use cases from the above section that are close to the functionality you plan for your application.  
2. Design and develop the component that accepts the Beckn requests and interacts with your software to do transactions. It has to be an endpoint(it is called as webhook\_url in the description below) which receives all the Beckn requests (search, select etc). This endpoint can either exist outside of your marketplace/shop software or within it. That is a design decision that will have to be taken by you based on the design of your existing marketplace/shop software. This component is also responsible for sending back the responses to the Beckn Adaptor.  
3. Install the BPP Protocol Server using the reference implementation of Beckn-ONIX. During the installation, you will need the address of the registry of the environment, a URL where the Beckn responses will arrive (called Subscriber URL), a subscriber\_id (typically the same as subscriber URL without the "https://" prefix) and the webhook\_url that you configured in the step above. Also the address of the BPP Protocol Server Client will have to be configured in your component above. This address hosts all the response endpoints (on\_search,on\_select etc)  
4. Install the layer 2 file for the domain (Link is in the last section of this document)  
5. Check with your network tech support to enable your BPP Protocol Server in the registry.  
6. Once enabled, you can transact on the Beckn Network. Typically the sandbox environment will have the rest of the components you need to test your software. In the diagram below,  
   * you write the Provider Platform(dark blue) \- Here the component you wrote above in point 2 as well as your marketplace/shop software is together shown as Provider Platform  
   * install the BPP Protocol Server (light blue)  
   * the remaining components are provided by the sandbox environment  
   * Use the postman collection to test your Provider Platform  
7. Once the application is working on the Sandbox, refer to the Starter kit for instructions to take it to pre-production and production.

## **Links to artefacts**

* [Postman collection for UEI EV Charging](https://github.com/beckn/missions/blob/main/UEI/postman/ev-charging_uei_postman_collection.json)  
* [Layer2 config for UEI EV Charging](https://github.com/beckn/missions/blob/main/UEI/layer2/EV-charging/3.1/energy_EV_1.1.0_openapi_3.1.yaml)  
* When installing layer2 using Beckn-ONIX use this web address ([https://raw.githubusercontent.com/beckn/missions/refs/heads/main/UEI/layer2/EV-charging/3.1/energy\_EV\_1.1.0\_openapi\_3.1.yaml](https://raw.githubusercontent.com/beckn/missions/refs/heads/main/UEI/layer2/EV-charging/3.1/energy_EV_1.1.0_openapi_3.1.yaml))