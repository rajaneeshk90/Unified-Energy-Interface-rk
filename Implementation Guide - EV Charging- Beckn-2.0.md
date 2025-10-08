# **Implementation Guide \- EV Charging with Beckn 2.0 (DRAFT)**

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

```json
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
```

Structure of a on\_select message with an error

```json
{
    "context": {
        "action": "on_select",
        "version": "1.1.0",
    },
    "error": {
        "code": 30001,
        "message": "Requested provider is not in the database"
    }
}
```

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

### **Discover**

Consumer searches for EV charging stations with specific criteria including location, connector type, time window, finder fee etc.

This is like typing "EV charger" into Google Maps and saying "find me charging stations within 5km of this location that have CCS2 connectors." The app sends this request to find available charging stations that match your criteria.


```json
{
  "context": {
    "version": "2.0.0",
    "action": "discover",
    "domain": "deg:ev-charging",
    "location": {
      "country": {
        "code": "IND"
      },
      "city": {
        "code": "std:080"
      }
    },
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "transaction_id": "2ad735b9-e190-457f-98e5-9702fd895996",
    "message_id": "e138f204-ec0b-415d-9c9a-7b5bafe10bfe",
    "timestamp": "2024-08-05T09:21:12.618Z",
    "ttl": "PT10M",
    "network_id": [
      "beckn.energy.india"
    ],
    "schema_context": [
      "https://becknprotocol.io/schemas/energy/v1/EVChargingItem/schema-context.jsonld"
    ]
  },
  "text_search": "EV charger CCS2 connector",
  "filters": "$[?(@.itemAttributes.connector-type == 'CCS2' && @.availableAt[*].gps.latitude >= 12.0 && @.availableAt[*].gps.latitude <= 13.0)]",
  "pagination": {
    "page": 1,
    "limit": 20
  }
}
```

**Discovery Criteria**:

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

* message.intent.tags.descriptor.code: Tag group to describe the buyer finder fee or the commission amount for the BAP as part of the transaction.  
* Message.intent.tags.list.\[descriptor.code=”type”\].value: Tag to define if the commission is a percentage of the order value or a flat amount. Possible values are “PERCENTAGE” and “AMOUNT”  
* Message.intent.tags.list.\[descriptor.code=”value”\].value: Tag to define the buyer finder fee value.

### **on_discover**

BPP returns a comprehensive catalog of available charging stations from multiple CPOs with detailed specifications, pricing, and location information.

1. Multiple providers (CPOs) with their charging networks  
2. Detailed location information with GPS coordinates  
3. Individual charging station specifications and pricing  
4. Connector types, power ratings, and availability status

This is the response you get back after searching \- like getting a list of all nearby restaurants from Google Maps. It shows you all the charging stations available, their locations, prices, and what type of connectors they have. Think of it as a "charging station directory" for your area.

```json
{
  "context": {
    "version": "2.0.0",
    "action": "on_discover",
    "domain": "deg:ev-charging",
    "location": {
      "country": {
        "code": "IND"
      },
      "city": {
        "code": "std:080"
      }
    },
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "PT30S",
    "network_id": [
      "beckn.energy.india"
    ]
  },
  "catalogs": [
    {
      "@context": "https://becknprotocol.io/schemas/core/v1/Catalog/schema-context.jsonld",
      "@type": "beckn:Catalog",
      "beckn:id": "catalog-ev-charging-001",
      "beckn:descriptor": {
        "@type": "beckn:Descriptor",
        "schema:name": "CPO1 EV Charging Network",
        "beckn:shortDesc": "CPO1 provides EV charging facility across India",
        "schema:image": [
          "https://cpo1.com/images/logo.png"
        ]
      },
      "beckn:providerId": "cpo1.com",
      "beckn:items": [
        {
          "@context": "https://becknprotocol.io/schemas/core/v1/Item/schema-context.jsonld",
          "@type": "beckn:Item",
          "beckn:id": "pe-charging-01",
          "beckn:descriptor": {
            "@type": "beckn:Descriptor",
            "schema:name": "EV Charger #1 (AC Fast Charger)"
          },
          "beckn:category": {
            "@type": "schema:CategoryCode",
            "schema:codeValue": "ev-charging",
            "schema:name": "EV Charging"
          },
          "beckn:availableAt": [
            {
              "@type": "beckn:Location",
              "beckn:gps": {
                "schema:latitude": 28.345345,
                "schema:longitude": 77.389754
              },
              "beckn:address": {
                "schema:streetAddress": "Connaught Place",
                "schema:addressLocality": "New Delhi",
                "schema:addressCountry": "India"
              }
            }
          ],
          "beckn:rateable": true,
          "beckn:rating": {
            "@type": "beckn:Rating",
            "beckn:ratingValue": 4.5,
            "beckn:ratingCount": 120
          },
          "beckn:networkId": [
            "beckn.energy.india"
          ],
          "beckn:provider": {
            "beckn:id": "cpo1.com",
            "beckn:descriptor": {
              "@type": "beckn:Descriptor",
              "schema:name": "CPO1 EV charging Company",
              "beckn:shortDesc": "CPO1 provides EV charging facility across India"
            }
          },
          "beckn:itemAttributes": {
            "@context": "https://example.org/schema/items/v1/EVCharging/item-attributes.schema.json",
            "@type": "ev:EVChargingAttributes",
            "ev:connectorType": "CCS2",
            "ev:currentType": "AC",
            "ev:maxPowerKW": 30,
            "ev:availability": "AVAILABLE",
            "ev:tariff": {
              "schema:price": 18,
              "schema:priceCurrency": "INR",
              "ev:pricingUnit": "PER_KWH"
            }
          }
        },
        {
          "@context": "https://becknprotocol.io/schemas/core/v1/Item/schema-context.jsonld",
          "@type": "beckn:Item",
          "beckn:id": "pe-charging-02",
          "beckn:descriptor": {
            "@type": "beckn:Descriptor",
            "schema:name": "EV Charger #2 (AC Fast Charger)",
            "beckn:shortDesc": "Spot Booking"
          },
          "beckn:category": {
            "@type": "schema:CategoryCode",
            "schema:codeValue": "ev-charging",
            "schema:name": "EV Charging"
          },
          "beckn:availableAt": [
            {
              "@type": "beckn:Location",
              "beckn:gps": {
                "schema:latitude": 28.345345,
                "schema:longitude": 77.389754
              },
              "beckn:address": {
                "schema:streetAddress": "Connaught Place",
                "schema:addressLocality": "New Delhi",
                "schema:addressCountry": "India"
              }
            }
          ],
          "beckn:rateable": true,
          "beckn:rating": {
            "@type": "beckn:Rating",
            "beckn:ratingValue": 4.7,
            "beckn:ratingCount": 85
          },
          "beckn:networkId": [
            "beckn.energy.india"
          ],
          "beckn:provider": {
            "beckn:id": "cpo1.com",
            "beckn:descriptor": {
              "@type": "beckn:Descriptor",
              "schema:name": "CPO1 EV charging Company",
              "beckn:shortDesc": "CPO1 provides EV charging facility across India"
            }
          },
          "beckn:itemAttributes": {
            "@context": "https://example.org/schema/items/v1/EVCharging/item-attributes.schema.json",
            "@type": "ev:EVChargingAttributes",
            "ev:connectorType": "CCS2",
            "ev:currentType": "AC",
            "ev:maxPowerKW": 30,
            "ev:availability": "AVAILABLE",
            "ev:providerTags": [
              "SPOT"
            ],
            "ev:tariff": {
              "schema:price": 21,
              "schema:priceCurrency": "INR",
              "ev:pricingUnit": "PER_KWH"
            }
          }
        }
      ],
      "beckn:offers": [
        {
          "@context": "https://becknprotocol.io/schemas/core/v1/Offer/schema-context.jsonld",
          "@type": "beckn:Offer",
          "beckn:id": "offer-charging-01",
          "beckn:descriptor": {
            "@type": "beckn:Descriptor",
            "schema:name": "Standard Charging Rate"
          },
          "beckn:provider": "cpo1.com",
          "beckn:items": [
            "pe-charging-01"
          ],
          "beckn:price": {
            "currency": "INR",
            "value": 18
          }
        },
        {
          "@context": "https://becknprotocol.io/schemas/core/v1/Offer/schema-context.jsonld",
          "@type": "beckn:Offer",
          "beckn:id": "offer-charging-02",
          "beckn:descriptor": {
            "@type": "beckn:Descriptor",
            "schema:name": "Spot Booking Rate"
          },
          "beckn:provider": "cpo1.com",
          "beckn:items": [
            "pe-charging-02"
          ],
          "beckn:price": {
            "currency": "INR",
            "value": 21
          }
        }
      ]
    }
  ]
}
```

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

**Note on Quantity and Price:**
- `beckn:quantity`: Represents the number of charging sessions (typically `1` for a single session)
- `beckn:price`: Specifies the budget/price limit for the charging session (e.g., 100 INR means "I want to charge for up to ₹100")
- The actual energy delivered (in kWh) will be determined by the charging session and communicated in subsequent status updates

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
    "version": "2.0.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2025-09-24T10:00:00Z",
    "ttl": "PT15S",
    "network_id": [
      "beckn.energy.india"
    ],
    "schema_context": [
      "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "https://becknprotocol.io/schemas/energy/v1/ev-charging-context.jsonld"
    ]
  },
  "message": {
    "order": {
      "@context": "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "@type": "beckn:Order",
      "beckn:id": "order-draft-6743e9e2",
      "beckn:state": "DRAFT",
      "beckn:seller": "cpo1.com",
      "beckn:buyer": "customer-bap-001",
      "beckn:orderItems": [
        {
          "beckn:lineId": "line-001",
          "beckn:orderedItem": "pe-charging-01",
          "beckn:quantity": 1,
          "beckn:price": {
            "currency": "INR",
            "value": 100
          }
        }
      ],
      "beckn:fulfillment": "fulfillment-001",
      "beckn:orderAttributes": {
        "fulfillment-details": {
          "beckn:id": "fulfillment-001",
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2025-09-24T10:00:00Z"
              }
            },
            {
              "type": "STOP",
              "time": {
                "timestamp": "2025-09-24T11:00:00Z"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          }
        },
        "buyer-finder-fee": {
          "type": "PERCENTAGE",
          "value": "2"
        }
      }
    }
  }
}
```

Charging Station Specifications (Items):

* message.order.items.id: Unique identifier for the specific charging point/EVSE

Charging Session Information (Fulfillments):

* message.order.fulfillments.id: Unique identifier for this charging session  
* message.order.fulfillments.stops.type: Session type (set to "start" for charging initiation and "stop" for ending the session)  
* message.order.fulfillments.stops.time.timestamp: Requested charging start timestamp and end timestamp. In case of future time slot bookings, the user will give the future requested time slot here. The BPP may respond with the nearest time slot available, if exact slots are not available for booking. If they are absent or if the timestamp is of current timestamp or of a timeframe within a short duration, this can be considered a spot booking scenario.

Buyer Finder Fee Declaration:

* message.order.tags.descriptor.code: Tag group to describe the buyer finder fee or the commission amount for the BAP as part of the transaction.  
* Message.order.tags.list.\[descriptor.code=”type”\].value: Tag to define if the commission is a percentage of the order value or a flat amount. Possible values are “PERCENTAGE” and “AMOUNT”  
* Message.order.tags.list.\[descriptor.code=”value”\].value: Tag to define the buyer finder fee value.

BAP can also support EV charging by kWh. Below is an example of the same:

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
    "version": "2.0.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2025-09-24T10:00:00Z",
    "ttl": "PT15S",
    "network_id": ["beckn.energy.india"],
    "schema_context": [
      "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "https://becknprotocol.io/schemas/energy/v1/ev-charging-context.jsonld"
    ]
  },
  "message": {
    "order": {
      "@context": "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "@type": "beckn:Order",
      "beckn:id": "order-draft-6743e9e2",
      "beckn:state": "DRAFT",
      "beckn:seller": "cpo1.com",
      "beckn:buyer": "customer-bap-001",
      "beckn:orderItems": [
        {
          "beckn:lineId": "line-001",
          "beckn:orderedItem": "pe-charging-01",
          "beckn:quantity": 100,
          "beckn:orderItemAttributes": {
            "quantity-measure": {
              "type": "CONSTANT",
              "value": "100",
              "unit": "INR"
            }
          }
        }
      ],
      "beckn:fulfillment": "fulfillment-001",
      "beckn:orderAttributes": {
        "fulfillment-details": {
          "beckn:id": "fulfillment-001",
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2025-09-24T10:00:00Z"
              }
            },
            {
              "type": "STOP",
              "time": {
                "timestamp": "2025-09-24T11:00:00Z"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          }
        },
        "buyer-finder-fee": {
          "type": "PERCENTAGE",
          "value": "2"
        }
      }
    }
  }
}
```

### **on_select** {#on_select}

Here the BPP returns with the estimated quote for the service. If the service is unavailable, the BPP returns with an error.

on_select
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
    "version": "2.0.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "PT15S",
    "network_id": [
      "beckn.energy.india"
    ],
    "schema_context": [
      "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "https://becknprotocol.io/schemas/energy/v1/ev-charging-context.jsonld",
      "https://schema.org"
    ]
  },
  "message": {
    "order": {
      "@context": "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "@type": "beckn:Order",
      "beckn:id": "order-draft-6743e9e2",
      "beckn:state": "QUOTED",
      "beckn:seller": "cpo1.com",
      "beckn:buyer": "customer-bap-001",
      "beckn:orderItems": [
        {
          "beckn:lineId": "line-001",
          "beckn:orderedItem": "pe-charging-01",
          "beckn:quantity": 1,
          "beckn:price": {
            "currency": "INR",
            "value": 90
          },
          "beckn:orderItemAttributes": {
            "@context": "https://example.org/schema/items/v1/EVCharging/item-attributes.schema.json",
            "@type": "ev:EVChargingAttributes",
            "ev:connectorType": "CCS2",
            "ev:currentType": "AC",
            "ev:maxPowerKW": 30,
            "ev:availability": "AVAILABLE",
            "ev:tariff": {
              "schema:price": 18,
              "schema:priceCurrency": "INR",
              "ev:pricingUnit": "PER_KWH"
            }
          }
        }
      ],
      "beckn:fulfillment": "fulfillment-001",
      "beckn:totals": {
        "@type": "schema:PriceSpecification",
        "schema:priceCurrency": "INR",
        "schema:price": 100,
        "beckn:breakup": [
          {
            "schema:name": "Charging session cost (5 kWh @ ₹18.00/kWh)",
            "beckn:itemId": "pe-charging-01",
            "schema:price": 90,
            "schema:priceCurrency": "INR"
          },
          {
            "schema:name": "service fee",
            "schema:price": 10,
            "schema:priceCurrency": "INR"
          }
        ]
      },
      "beckn:orderAttributes": {
        "provider-details": {
          "beckn:id": "cpo1.com",
          "schema:name": "CPO1 EV charging Company",
          "schema:description": "CPO1 provides EV charging facility across India",
          "schema:image": [
            {
              "@type": "schema:ImageObject",
              "schema:url": "https://cpo1.com/images/logo.png"
            }
          ]
        },
        "fulfillment-details": {
          "beckn:id": "fulfillment-001",
          "beckn:mode": "RESERVATION",
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2025-09-24T10:00:00Z"
              },
              "location": {
                "schema:geo": {
                  "@type": "schema:GeoCoordinates",
                  "schema:latitude": "28.345345",
                  "schema:longitude": "77.389754"
                },
                "schema:name": "BlueCharge Connaught Place Station",
                "schema:address": {
                  "@type": "schema:PostalAddress",
                  "schema:addressLocality": "Connaught Place, New Delhi"
                }
              },
              "instructions": {
                "short_desc": "Ground floor, Pillar Number 4"
              }
            },
            {
              "type": "STOP",
              "time": {
                "timestamp": "2025-09-24T11:00:00Z"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          }
        },
        "fulfillment-type": "CHARGING"
      }
    }
  }
}
```

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

init
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
    "version": "2.0.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "PT15S",
    "network_id": [
      "beckn.energy.india"
    ],
    "schema_context": [
      "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "https://becknprotocol.io/schemas/energy/v1/ev-charging-context.jsonld",
      "https://schema.org"
    ]
  },
  "message": {
    "order": {
      "@context": "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "@type": "beckn:Order",
      "beckn:id": "order-init-6743e9e2",
      "beckn:state": "INITIALIZED",
      "beckn:seller": "cpo1.com",
      "beckn:buyer": "customer-ravi-001",
      "beckn:orderItems": [
        {
          "beckn:lineId": "line-001",
          "beckn:orderedItem": "pe-charging-01",
          "beckn:quantity": 1,
          "beckn:price": {
            "currency": "INR",
            "value": 100
          }
        }
      ],
      "beckn:billing": "invoice-001",
      "beckn:fulfillment": "fulfillment-001",
      "beckn:orderAttributes": {
        "billing-details": {
          "beckn:id": "invoice-001",
          "beckn:payer": "customer-ravi-001",
          "schema:name": "Ravi Kumar",
          "schema:email": "ravi.kumar@greencharge.com",
          "schema:telephone": "+918765432100",
          "schema:address": {
            "@type": "schema:PostalAddress",
            "schema:streetAddress": "Apartment 123, MG Road",
            "schema:addressLocality": "Bengaluru",
            "schema:addressRegion": "Karnataka",
            "schema:postalCode": "560001",
            "schema:addressCountry": "India"
          },
          "organization": {
            "schema:name": "GreenCharge Pvt Ltd"
          },
          "tax-id": "GSTIN29ABCDE1234F1Z5",
          "timestamp": "2025-07-30T12:02:00Z"
        },
        "fulfillment-details": {
          "beckn:id": "fulfillment-001",
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
            "schema:name": "Ravi Kumar",
            "schema:telephone": "+91-9887766554"
          }
        },
        "buyer-finder-fee": {
          "type": "PERCENTAGE",
          "value": "10"
        }
      }
    }
  }
}
```

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

### **on_init** {#on_init}

This is like getting a hotel room quote when you are booking a hotel room \- "Your charging session will cost ₹100, here are the payment options." It's the charging station saying "I can accommodate your request, here are the terms and how to pay."

on_init
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
    "version": "2.0.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "PT15S",
    "network_id": [
      "beckn.energy.india"
    ],
    "schema_context": [
      "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "https://becknprotocol.io/schemas/energy/v1/ev-charging-context.jsonld",
      "https://schema.org"
    ]
  },
  "message": {
    "order": {
      "@context": "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "@type": "beckn:Order",
      "beckn:id": "order-init-6743e9e2",
      "beckn:state": "INITIALIZED",
      "beckn:seller": "cpo1.com",
      "beckn:buyer": "customer-ravi-001",
      "beckn:orderItems": [
        {
          "beckn:lineId": "line-001",
          "beckn:orderedItem": "pe-charging-01",
          "beckn:quantity": 1,
          "beckn:price": {
            "currency": "INR",
            "value": 90
          },
          "beckn:orderItemAttributes": {
            "@context": "https://example.org/schema/items/v1/EVCharging/item-attributes.schema.json",
            "@type": "ev:EVChargingAttributes",
            "ev:connectorType": "CCS2",
            "ev:currentType": "AC",
            "ev:maxPowerKW": 30,
            "ev:availability": "AVAILABLE",
            "ev:tariff": {
              "schema:price": 18,
              "schema:priceCurrency": "INR",
              "ev:pricingUnit": "PER_KWH"
            }
          }
        }
      ],
      "beckn:billing": "invoice-001",
      "beckn:payment": "payment-123e4567",
      "beckn:fulfillment": "fulfillment-001",
      "beckn:totals": {
        "@type": "schema:PriceSpecification",
        "schema:priceCurrency": "INR",
        "schema:price": 100,
        "beckn:breakup": [
          {
            "schema:name": "Charging session cost (5 kWh @ ₹18.00/kWh)",
            "beckn:itemId": "pe-charging-01",
            "schema:price": 90,
            "schema:priceCurrency": "INR"
          },
          {
            "schema:name": "Service fee",
            "schema:price": 10,
            "schema:priceCurrency": "INR"
          }
        ]
      },
      "beckn:orderAttributes": {
        "provider-details": {
          "beckn:id": "cpo1.com",
          "schema:name": "CPO1 EV charging Company",
          "schema:description": "CPO1 provides EV charging facility across India",
          "schema:image": [
            {
              "@type": "schema:ImageObject",
              "schema:url": "https://cpo1.com/images/logo.png"
            }
          ]
        },
        "billing-details": {
          "beckn:id": "invoice-001",
          "beckn:payer": "customer-ravi-001",
          "schema:name": "Ravi Kumar",
          "schema:email": "ravi.kumar@greencharge.com",
          "schema:telephone": "+918765432100",
          "schema:address": {
            "@type": "schema:PostalAddress",
            "schema:streetAddress": "Apartment 123, MG Road",
            "schema:addressLocality": "Bengaluru",
            "schema:addressRegion": "Karnataka",
            "schema:postalCode": "560001",
            "schema:addressCountry": "India"
          },
          "organization": {
            "schema:name": "GreenCharge Pvt Ltd"
          },
          "tax-id": "GSTIN29ABCDE1234F1Z5",
          "timestamp": "2025-07-30T12:02:00Z"
        },
        "payment-details": {
          "beckn:id": "payment-123e4567-e89b-12d3-a456-426614174000",
          "beckn:method": "PAYMENT-LINK",
          "beckn:status": "NOT-PAID",
          "beckn:amount": {
            "currency": "INR",
            "value": 100.0
          },
          "collected-by": "BPP",
          "payment-url": "https://payments.bluechargenet-aggregator.io/pay?transaction_id=$transaction_id&amount=$amount",
          "payment-type": "PRE-FULFILLMENT",
          "timestamp": "2025-07-30T14:59:00Z",
          "beckn:paymentAttributes": {
            "bank-details": {
              "bank-code": "HDFC000123",
              "bank-account-number": "1131324242424"
            },
            "payment-methods": [
              {
                "code": "BANK-TRANSFER",
                "description": "Pay by transferring to a bank account"
              },
              {
                "code": "PAYMENT-LINK",
                "description": "Pay through a bank link received"
              },
              {
                "code": "UPI-TRANSFER",
                "description": "Pay by setting a UPI mandate"
              }
            ]
          }
        },
        "fulfillment-details": {
          "beckn:id": "fulfillment-001",
          "beckn:mode": "RESERVATION",
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2023-07-16T10:00:00+05:30"
              },
              "location": {
                "schema:geo": {
                  "@type": "schema:GeoCoordinates",
                  "schema:latitude": "28.345345",
                  "schema:longitude": "77.389754"
                },
                "schema:name": "BlueCharge Connaught Place Station",
                "schema:address": {
                  "@type": "schema:PostalAddress",
                  "schema:addressLocality": "Connaught Place, New Delhi"
                }
              },
              "instructions": {
                "short_desc": "OTP will be shared to the user's registered number to confirm order"
              },
              "authorization": {
                "type": "OTP"
              }
            },
            {
              "type": "STOP",
              "time": {
                "timestamp": "2025-09-24T11:00:00Z"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          },
          "customer": {
            "schema:name": "Ravi Kumar",
            "schema:telephone": "+91-9887766554"
          }
        },
        "refund-terms": [
          {
            "fulfillment-state": {
              "name": "Order Confirmed",
              "code": "CONFIRMED",
              "description": "85% refund available if cancelled at least 4 hours before the scheduled charging time"
            },
            "refund-eligible": true,
            "refund-within": "PT2H",
            "refund-amount": {
              "currency": "INR",
              "value": "85"
            }
          },
          {
            "fulfillment-state": {
              "name": "Charging Active",
              "code": "ACTIVE"
            },
            "refund-eligible": false
          }
        ],
        "fulfillment-type": "CHARGING"
      }
    }
  }
}
```

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

on_status payment
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
    "version": "2.0.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "PT15S",
    "network_id": [
      "beckn.energy.india"
    ],
    "schema_context": [
      "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "https://becknprotocol.io/schemas/energy/v1/ev-charging-context.jsonld",
      "https://schema.org"
    ]
  },
  "message": {
    "order": {
      "@context": "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "@type": "beckn:Order",
      "beckn:id": "6743e9e2-4fb5-487c-92b7",
      "beckn:state": "PENDING",
      "beckn:orderNumber": "ORD-6743e9e2",
      "beckn:seller": "cpo1.com",
      "beckn:buyer": "customer-ravi-001",
      "beckn:orderItems": [
        {
          "beckn:lineId": "line-001",
          "beckn:orderedItem": "pe-charging-01",
          "beckn:quantity": 1,
          "beckn:price": {
            "currency": "INR",
            "value": 90
          },
          "beckn:orderItemAttributes": {
            "@context": "https://example.org/schema/items/v1/EVCharging/item-attributes.schema.json",
            "@type": "ev:EVChargingAttributes",
            "ev:connectorType": "CCS2",
            "ev:currentType": "AC",
            "ev:maxPowerKW": 30,
            "ev:availability": "AVAILABLE",
            "ev:tariff": {
              "schema:price": 18,
              "schema:priceCurrency": "INR",
              "ev:pricingUnit": "PER_KWH"
            }
          }
        }
      ],
      "beckn:billing": "invoice-001",
      "beckn:payment": "payment-123e4567",
      "beckn:fulfillment": "fulfillment-001",
      "beckn:totals": {
        "@type": "schema:PriceSpecification",
        "schema:priceCurrency": "INR",
        "schema:price": 100,
        "beckn:breakup": [
          {
            "schema:name": "Charging session cost (5 kWh @ ₹18.00/kWh)",
            "beckn:itemId": "pe-charging-01",
            "schema:price": 90,
            "schema:priceCurrency": "INR"
          },
          {
            "schema:name": "Service Fee",
            "schema:price": 10,
            "schema:priceCurrency": "INR"
          }
        ]
      },
      "beckn:orderAttributes": {
        "provider-details": {
          "beckn:id": "cpo1.com",
          "schema:name": "CPO1 EV charging Company",
          "schema:description": "CPO1 provides EV charging facility across India",
          "schema:image": [
            {
              "@type": "schema:ImageObject",
              "schema:url": "https://cpo1.com/images/logo.png"
            }
          ]
        },
        "billing-details": {
          "beckn:id": "invoice-001",
          "beckn:payer": "customer-ravi-001",
          "schema:name": "Ravi Kumar",
          "schema:email": "ravi.kumar@greencharge.com",
          "schema:telephone": "+918765432100",
          "schema:address": {
            "@type": "schema:PostalAddress",
            "schema:streetAddress": "Apartment 123, MG Road",
            "schema:addressLocality": "Bengaluru",
            "schema:addressRegion": "Karnataka",
            "schema:postalCode": "560001",
            "schema:addressCountry": "India"
          },
          "organization": {
            "schema:name": "GreenCharge Pvt Ltd"
          },
          "tax-id": "GSTIN29ABCDE1234F1Z5",
          "timestamp": "2025-07-30T12:02:00Z"
        },
        "payment-details": {
          "beckn:id": "payment-123e4567-e89b-12d3-a456-426614174000",
          "beckn:method": "UPI-TRANSFER",
          "beckn:status": "PAID",
          "beckn:amount": {
            "currency": "INR",
            "value": 100.0
          },
          "beckn:txnRef": "123e4567-e89b-12d3-a456-426614174000",
          "collected-by": "BPP",
          "payment-url": "https://payments.bluechargenet-aggregator.io/pay?transaction_id=$transaction_id&amount=$amount",
          "payment-type": "ON-ORDER",
          "timestamp": "2025-07-30T14:59:00Z"
        },
        "fulfillment-details": {
          "beckn:id": "fulfillment-001",
          "beckn:mode": "RESERVATION",
          "beckn:status": "PENDING",
          "state": {
            "code": "PENDING",
            "name": "Charging Pending",
            "updated-at": "2025-07-30T12:06:02Z",
            "updated-by": "bluechargenet-aggregator.io"
          },
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2023-07-16T10:00:00+05:30"
              },
              "location": {
                "schema:geo": {
                  "@type": "schema:GeoCoordinates",
                  "schema:latitude": "28.345345",
                  "schema:longitude": "77.389754"
                },
                "schema:name": "BlueCharge Connaught Place Station",
                "schema:address": {
                  "@type": "schema:PostalAddress",
                  "schema:addressLocality": "Connaught Place, New Delhi"
                }
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
          }
        },
        "refund-terms": [
          {
            "fulfillment-state": {
              "name": "Order Confirmed",
              "code": "CONFIRMED",
              "description": "85% refund available if cancelled at least 4 hours before the scheduled charging time"
            },
            "refund-eligible": true,
            "refund-within": "PT2H",
            "refund-amount": {
              "currency": "INR",
              "value": "85"
            }
          },
          {
            "fulfillment-state": {
              "name": "Charging active",
              "code": "ACTIVE"
            },
            "refund-eligible": false
          }
        ],
        "fulfillment-type": "CHARGING"
      }
    }
  }
}
```

In case the BAP is not receiving on_status from the BPP, it may also allow the user to declare they have completed payment and confirm the order using a user input at the BAP.

### **confirm** {#confirm}

This is like clicking "Confirm Booking" on a hotel website after you've completed the payment. You're saying "Yes, I accept these terms and want to proceed with this charging session." The payment has already been processed (you can see the transaction ID in the message), and this is the final confirmation step before your charging session is officially booked.

confirm
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
    "version": "2.0.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "PT15S",
    "network_id": [
      "beckn.energy.india"
    ],
    "schema_context": [
      "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "https://becknprotocol.io/schemas/energy/v1/ev-charging-context.jsonld",
      "https://schema.org"
    ]
  },
  "message": {
    "order": {
      "@context": "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "@type": "beckn:Order",
      "beckn:id": "order-confirm-6743e9e2",
      "beckn:state": "CONFIRMING",
      "beckn:seller": "cpo1.com",
      "beckn:buyer": "customer-ravi-001",
      "beckn:orderItems": [
        {
          "beckn:lineId": "line-001",
          "beckn:orderedItem": "pe-charging-01",
          "beckn:quantity": 1,
          "beckn:price": {
            "currency": "INR",
            "value": 100
          }
        }
      ],
      "beckn:billing": "invoice-001",
      "beckn:payment": "payment-123e4567",
      "beckn:fulfillment": "fulfillment-001",
      "beckn:orderAttributes": {
        "billing-details": {
          "beckn:id": "invoice-001",
          "beckn:payer": "customer-ravi-001",
          "schema:name": "Ravi Kumar",
          "schema:email": "ravi.kumar@greencharge.com",
          "schema:telephone": "+918765432100",
          "schema:address": {
            "@type": "schema:PostalAddress",
            "schema:streetAddress": "Apartment 123, MG Road",
            "schema:addressLocality": "Bengaluru",
            "schema:addressRegion": "Karnataka",
            "schema:postalCode": "560001",
            "schema:addressCountry": "India"
          },
          "organization": {
            "schema:name": "GreenCharge Pvt Ltd"
          },
          "tax-id": "GSTIN29ABCDE1234F1Z5",
          "timestamp": "2025-07-30T12:02:00Z"
        },
        "payment-details": {
          "beckn:id": "payment-123e4567-e89b-12d3-a456-426614174000",
          "beckn:method": "UPI-TRANSFER",
          "beckn:status": "NOT-PAID",
          "beckn:amount": {
            "currency": "INR",
            "value": 100.0
          },
          "collected-by": "BPP",
          "payment-url": "https://payments.bluechargenet-aggregator.io/pay?transaction_id=$transaction_id&amount=$amount",
          "payment-type": "PRE-FULFILLMENT",
          "timestamp": "2025-07-30T14:59:00Z",
          "beckn:paymentAttributes": {
            "source-vpa": "ravi@ptsbi",
            "payment-method": "UPI-TRANSFER"
          }
        },
        "fulfillment-details": {
          "beckn:id": "fulfillment-001",
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2023-07-16T10:00:00+05:30"
              },
              "authorization": {
                "type": "OTP",
                "token": "2442"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          },
          "customer": {
            "schema:name": "Ravi kumar",
            "schema:telephone": "+91-9887766554"
          }
        },
        "buyer-finder-fee": {
          "type": "PERCENTAGE",
          "value": "2"
        }
      }
    }
  }
}
```

Payment Confirmation:

* message.order.payments.id: Payment identifier matching the on\_init response  
* message.order.payments.status: Payment status (changed from "NOT-PAID" to "PAID")  
* message.order.payments.params.amount: Confirmed payment amount  
* Message.order.payments.params.source\_virtual\_payment\_address: Virtual payment address to which the collect request will be sent to  
* message.order.payments.tags.list.descriptor.code: Selected payment method

### **on_confirm** {#on_confirm}

This is like getting a hotel confirmation email \- "Your booking is confirmed\! Here's your reservation number." The charging station is saying "Great\! Your charging session is booked and ready. Here's your order ID and all the details."

on_confirm
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
    "version": "2.0.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "PT15S",
    "network_id": [
      "beckn.energy.india"
    ],
    "schema_context": [
      "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "https://becknprotocol.io/schemas/energy/v1/ev-charging-context.jsonld",
      "https://schema.org"
    ]
  },
  "message": {
    "order": {
      "@context": "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "@type": "beckn:Order",
      "beckn:id": "6743e9e2-4fb5-487c-92b7",
      "beckn:state": "CONFIRMED",
      "beckn:orderNumber": "ORD-6743e9e2",
      "beckn:seller": "cpo1.com",
      "beckn:buyer": "customer-ravi-001",
      "beckn:orderItems": [
        {
          "beckn:lineId": "line-001",
          "beckn:orderedItem": "pe-charging-01",
          "beckn:quantity": 1,
          "beckn:price": {
            "currency": "INR",
            "value": 90
          },
          "beckn:orderItemAttributes": {
            "@context": "https://example.org/schema/items/v1/EVCharging/item-attributes.schema.json",
            "@type": "ev:EVChargingAttributes",
            "ev:connectorType": "CCS2",
            "ev:currentType": "AC",
            "ev:maxPowerKW": 30,
            "ev:availability": "AVAILABLE",
            "ev:tariff": {
              "schema:price": 18,
              "schema:priceCurrency": "INR",
              "ev:pricingUnit": "PER_KWH"
            }
          }
        }
      ],
      "beckn:billing": "invoice-001",
      "beckn:payment": "payment-123e4567",
      "beckn:fulfillment": "fulfillment-001",
      "beckn:totals": {
        "@type": "schema:PriceSpecification",
        "schema:priceCurrency": "INR",
        "schema:price": 100,
        "beckn:breakup": [
          {
            "schema:name": "Charging session cost (5 kWh @ ₹18.00/kWh)",
            "beckn:itemId": "pe-charging-01",
            "schema:price": 90,
            "schema:priceCurrency": "INR"
          },
          {
            "schema:name": "Service Fee",
            "schema:price": 10,
            "schema:priceCurrency": "INR"
          }
        ]
      },
      "beckn:orderAttributes": {
        "provider-details": {
          "beckn:id": "cpo1.com",
          "schema:name": "CPO1 EV charging Company",
          "schema:description": "CPO1 provides EV charging facility across India",
          "schema:image": [
            {
              "@type": "schema:ImageObject",
              "schema:url": "https://cpo1.com/images/logo.png"
            }
          ]
        },
        "billing-details": {
          "beckn:id": "invoice-001",
          "beckn:payer": "customer-ravi-001",
          "schema:name": "Ravi Kumar",
          "schema:email": "ravi.kumar@greencharge.com",
          "schema:telephone": "+918765432100",
          "schema:address": {
            "@type": "schema:PostalAddress",
            "schema:streetAddress": "Apartment 123, MG Road",
            "schema:addressLocality": "Bengaluru",
            "schema:addressRegion": "Karnataka",
            "schema:postalCode": "560001",
            "schema:addressCountry": "India"
          },
          "organization": {
            "schema:name": "GreenCharge Pvt Ltd"
          },
          "tax-id": "GSTIN29ABCDE1234F1Z5",
          "timestamp": "2025-07-30T12:02:00Z"
        },
        "payment-details": {
          "beckn:id": "payment-123e4567-e89b-12d3-a456-426614174000",
          "beckn:method": "UPI-TRANSFER",
          "beckn:status": "PAID",
          "beckn:amount": {
            "currency": "INR",
            "value": 100.0
          },
          "beckn:txnRef": "123e4567-e89b-12d3-a456-426614174000",
          "collected-by": "BPP",
          "payment-url": "https://payments.bluechargenet-aggregator.io/pay?transaction_id=$transaction_id&amount=$amount",
          "payment-type": "PRE-FULFILLMENT",
          "timestamp": "2025-07-30T14:59:00Z"
        },
        "fulfillment-details": {
          "beckn:id": "fulfillment-001",
          "beckn:mode": "RESERVATION",
          "beckn:status": "PENDING",
          "state": {
            "code": "PENDING",
            "name": "Charging Pending",
            "updated-at": "2025-07-30T12:06:02Z",
            "updated-by": "bluechargenet-aggregator.io"
          },
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2023-07-16T10:00:00+05:30"
              },
              "location": {
                "schema:geo": {
                  "@type": "schema:GeoCoordinates",
                  "schema:latitude": "28.345345",
                  "schema:longitude": "77.389754"
                },
                "schema:name": "BlueCharge Connaught Place Station",
                "schema:address": {
                  "@type": "schema:PostalAddress",
                  "schema:addressLocality": "Connaught Place, New Delhi"
                }
              },
              "instructions": {
                "short_desc": "Ground floor, Pillar Number 4"
              }
            },
            {
              "type": "STOP",
              "time": {
                "timestamp": "2025-07-16T11:00:00+05:30"
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV"
          }
        },
        "refund-terms": [
          {
            "fulfillment-state": {
              "name": "Order Confirmed",
              "code": "CONFIRMED",
              "description": "85% refund available if cancelled at least 4 hours before the scheduled charging time"
            },
            "refund-eligible": true,
            "refund-within": "PT2H",
            "refund-amount": {
              "currency": "INR",
              "value": "85"
            }
          },
          {
            "fulfillment-state": {
              "name": "Charging Active",
              "code": "ACTIVE"
            },
            "refund-eligible": false
          }
        ],
        "fulfillment-type": "CHARGING"
      }
    }
  }
}
```

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

update(start charging)
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
    "version": "2.0.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "PT15S",
    "network_id": [
      "beckn.energy.india"
    ],
    "schema_context": [
      "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "https://becknprotocol.io/schemas/energy/v1/ev-charging-context.jsonld"
    ]
  },
  "message": {
    "order": {
      "@context": "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "@type": "beckn:Order",
      "beckn:id": "123e4567-e89b-12d3-a456-426614174000",
      "beckn:state": "ACTIVE",
      "beckn:seller": "cpo1.com",
      "beckn:buyer": "customer-001",
      "beckn:orderItems": [],
      "beckn:fulfillment": "fulfillment-001",
      "beckn:orderAttributes": {
        "update-target": "order.fulfillments[0].state",
        "fulfillment-update": {
          "beckn:id": "fulfillment-001",
          "beckn:mode": "RESERVATION",
          "beckn:status": "start-charging",
          "state": {
            "code": "start-charging"
          },
          "authorization": {
            "type": "OTP",
            "token": "7484"
          }
        },
        "fulfillment-type": "CHARGING"
      }
    }
  }
}
```

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

on_update(start charging)
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
    "version": "2.0.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "PT15S",
    "network_id": [
      "beckn.energy.india"
    ],
    "schema_context": [
      "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "https://becknprotocol.io/schemas/energy/v1/ev-charging-context.jsonld",
      "https://schema.org"
    ]
  },
  "message": {
    "order": {
      "@context": "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "@type": "beckn:Order",
      "beckn:id": "6743e9e2-4fb5-487c-92b7",
      "beckn:state": "ACTIVE",
      "beckn:orderNumber": "ORD-6743e9e2",
      "beckn:seller": "cpo1.com",
      "beckn:buyer": "customer-ravi-001",
      "beckn:orderItems": [
        {
          "beckn:lineId": "line-001",
          "beckn:orderedItem": "pe-charging-01",
          "beckn:quantity": 1,
          "beckn:price": {
            "currency": "INR",
            "value": 90
          },
          "beckn:orderItemAttributes": {
            "@context": "https://example.org/schema/items/v1/EVCharging/item-attributes.schema.json",
            "@type": "ev:EVChargingAttributes",
            "ev:connectorType": "CCS2",
            "ev:currentType": "AC",
            "ev:maxPowerKW": 30,
            "ev:availability": "AVAILABLE",
            "ev:tariff": {
              "schema:price": 18,
              "schema:priceCurrency": "INR",
              "ev:pricingUnit": "PER_KWH"
            }
          }
        }
      ],
      "beckn:billing": "invoice-001",
      "beckn:payment": "payment-123e4567",
      "beckn:fulfillment": "fulfillment-001",
      "beckn:totals": {
        "@type": "schema:PriceSpecification",
        "schema:priceCurrency": "INR",
        "schema:price": 100,
        "beckn:breakup": [
          {
            "schema:name": "Charging session cost (5 kWh @ ₹18.00/kWh)",
            "beckn:itemId": "pe-charging-01",
            "schema:price": 90,
            "schema:priceCurrency": "INR"
          },
          {
            "schema:name": "Service Fee",
            "schema:price": 10,
            "schema:priceCurrency": "INR"
          }
        ]
      },
      "beckn:orderAttributes": {
        "provider-details": {
          "beckn:id": "cpo1.com",
          "schema:name": "CPO1 EV charging Company",
          "schema:description": "CPO1 provides EV charging facility across India",
          "schema:image": [
            {
              "@type": "schema:ImageObject",
              "schema:url": "https://cpo1.com/images/logo.png"
            }
          ]
        },
        "billing-details": {
          "beckn:id": "invoice-001",
          "beckn:payer": "customer-ravi-001",
          "schema:name": "Ravi Kumar",
          "schema:email": "ravi.kumar@greencharge.com",
          "schema:telephone": "+918765432100",
          "schema:address": {
            "@type": "schema:PostalAddress",
            "schema:streetAddress": "Apartment 123, MG Road",
            "schema:addressLocality": "Bengaluru",
            "schema:addressRegion": "Karnataka",
            "schema:postalCode": "560001",
            "schema:addressCountry": "India"
          },
          "organization": {
            "schema:name": "GreenCharge Pvt Ltd"
          },
          "tax-id": "GSTIN29ABCDE1234F1Z5",
          "timestamp": "2025-07-30T12:02:00Z"
        },
        "payment-details": {
          "beckn:id": "payment-123e4567-e89b-12d3-a456-426614174000",
          "beckn:method": "UPI-TRANSFER",
          "beckn:status": "PAID",
          "beckn:amount": {
            "currency": "INR",
            "value": 100.0
          },
          "beckn:txnRef": "123e4567-e89b-12d3-a456-426614174000",
          "collected-by": "bpp",
          "payment-type": "PRE-FULFILLMENT",
          "timestamp": "2025-07-30T14:59:00Z"
        },
        "fulfillment-details": {
          "beckn:id": "fulfillment-001",
          "beckn:mode": "RESERVATION",
          "beckn:status": "ACTIVE",
          "state": {
            "code": "ACTIVE",
            "name": "Charging in progress",
            "updated-at": "2025-07-30T12:06:02Z",
            "updated-by": "bluechargenet-aggregator.io"
          },
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2023-07-16T10:00:00+05:30"
              },
              "location": {
                "schema:geo": {
                  "@type": "schema:GeoCoordinates",
                  "schema:latitude": "28.345345",
                  "schema:longitude": "77.389754"
                },
                "schema:name": "BlueCharge Connaught Place Station",
                "schema:address": {
                  "@type": "schema:PostalAddress",
                  "schema:addressLocality": "Connaught Place, New Delhi"
                }
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
        },
        "refund-terms": [
          {
            "fulfillment-state": {
              "name": "Order Confirmed",
              "code": "CONFIRMED",
              "description": "85% refund available if cancelled at least 4 hours before the scheduled charging time"
            },
            "refund-eligible": true,
            "refund-within": "PT2H",
            "refund-amount": {
              "currency": "INR",
              "value": "85"
            }
          },
          {
            "fulfillment-state": {
              "name": "Charging Active",
              "code": "ACTIVE"
            },
            "refund-eligible": false
          }
        ],
        "fulfillment-type": "CHARGING"
      }
    }
  }
}
```

Session Status Update:

* message.order.fulfillments.state.descriptor.code: Current session status (changed to "ACTIVE")  
* message.order.fulfillments.state.updated\_at: Timestamp when charging started  
* message.order.fulfillments.state.updated\_by: System that initiated the charging session

### **track**

This is like asking "Where's my package?" on an e-commerce website. You're requesting a link to monitor your charging session in real-time \- how much energy has been delivered, how much it's costing, and when it will be complete. Think of it as getting a "live dashboard" for your charging session.

track
```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "track",
    "location": {
      "country": {
        "code": "IND"
      },
      "city": {
        "code": "std:080"
      }
    },
    "version": "2.0.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "e0a38442-69b7-4698-aa94-a1b6b5d244c2",
    "message_id": "6ace310b-6440-4421-a2ed-b484c7548bd5",
    "timestamp": "2023-02-18T17:00:40.065Z",
    "ttl": "PT10M",
    "network_id": [
      "beckn.energy.india"
    ],
    "schema_context": [
      "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "https://becknprotocol.io/schemas/energy/v1/ev-charging-context.jsonld"
    ]
  },
  "message": {
    "order": {
      "@context": "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "@type": "beckn:Order",
      "beckn:id": "b989c9a9-f603-4d44-b38d-26fd72286b38",
      "beckn:state": "ACTIVE",
      "beckn:seller": "cpo1.com",
      "beckn:buyer": "customer-001",
      "beckn:orderItems": [],
      "beckn:orderAttributes": {
        "callback-url": "https://example-bap-url.com/SESSION/5e4f",
        "track-fulfillment": true
      }
    }
  }
}
```

Tracking Request:

* message.order\_id: Unique order identifier for the charging session to track.  
* This links the tracking request to the specific booking.  
* message.callback\_url: Optional URL which can be provided by the BAP, to which the BPP will trigger PATCH requests (with only fields to be updated and any fields that are left out remain unchanged) with real time details of the charging session.

Tip for NFOs:

* The structure and frequency for the PATCH requests may be decided based on the needs of the network by the NFO. A suggested request structure for the PATCH requests can be found below based on session details in *OCPI-2.2.1*:

```json
{
  "@context": "https://becknprotocol.io/schemas/energy/v1/ev-charging-session.jsonld",
  "@type": "ev:ChargingSessionUpdate",
  "ev:energyDelivered": {
    "@type": "schema:QuantitativeValue",
    "schema:value": 7.35,
    "schema:unitCode": "KWH"
  },
  "beckn:status": "ACTIVE",
  "schema:priceCurrency": "INR",
  "ev:chargingPeriods": [
    {
      "@type": "ev:ChargingPeriod",
      "schema:startTime": "2025-09-17T10:55:00Z",
      "ev:metrics": [
        {
          "@type": "ev:ChargingMetric",
          "ev:metricType": "ENERGY",
          "schema:value": 0.25,
          "schema:unitCode": "KWH"
        },
        {
          "@type": "ev:ChargingMetric",
          "ev:metricType": "POWER",
          "schema:value": 7.2,
          "schema:unitCode": "KW"
        },
        {
          "@type": "ev:ChargingMetric",
          "ev:metricType": "CURRENT",
          "schema:value": 16.0,
          "schema:unitCode": "AMP"
        },
        {
          "@type": "ev:ChargingMetric",
          "ev:metricType": "VOLTAGE",
          "schema:value": 230.0,
          "schema:unitCode": "VLT"
        },
        {
          "@type": "ev:ChargingMetric",
          "ev:metricType": "STATE_OF_CHARGE",
          "schema:value": 63.0,
          "schema:unitCode": "P1"
        }
      ]
    }
  ],
  "beckn:totalCost": {
    "@type": "schema:PriceSpecification",
    "beckn:excludingTax": {
      "schema:price": 78.50,
      "schema:priceCurrency": "INR"
    },
    "beckn:includingTax": {
      "schema:price": 92.63,
      "schema:priceCurrency": "INR"
    }
  },
  "schema:dateModified": "2025-09-17T10:55:05Z"
}
```

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

### **on_track**

This is like getting a FedEx tracking link \- "Click here to see your package's journey." The charging station is giving you a special webpage where you can watch your charging session live, see the current power being delivered, and get real-time updates on your charging progress.

on_track
```json
{
  "context": {
    "domain": "deg:ev-charging",
    "action": "on_track",
    "location": {
      "country": {
        "code": "IND"
      },
      "city": {
        "code": "std:080"
      }
    },
    "version": "2.0.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "e0a38442-69b7-4698-aa94-a1b6b5d244c2",
    "message_id": "6ace310b-6440-4421-a2ed-b484c7548bd5",
    "timestamp": "2023-02-18T17:00:40.065Z",
    "ttl": "PT10M",
    "network_id": [
      "beckn.energy.india"
    ],
    "schema_context": [
      "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "https://becknprotocol.io/schemas/energy/v1/ev-charging-context.jsonld",
      "https://schema.org"
    ]
  },
  "message": {
    "order": {
      "@context": "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "@type": "beckn:Order",
      "beckn:id": "b989c9a9-f603-4d44-b38d-26fd72286b38",
      "beckn:state": "ACTIVE",
      "beckn:orderNumber": "ORD-b989c9a9",
      "beckn:seller": "cpo1.com",
      "beckn:buyer": "customer-001",
      "beckn:orderItems": [
        {
          "beckn:lineId": "line-001",
          "beckn:orderedItem": "pe-charging-01",
          "beckn:quantity": 100,
          "beckn:orderItemAttributes": {
            "real-time-metrics": {
              "energy-delivered": "3.2",
              "energy-unit": "kWh",
              "current-power": "30",
              "power-unit": "kW",
              "session-duration": "PT6M24S",
              "estimated-completion": "PT23M36S"
            }
          }
        }
      ],
      "beckn:fulfillment": "fulfillment-001",
      "beckn:totals": {
        "@type": "schema:PriceSpecification",
        "schema:priceCurrency": "INR",
        "schema:price": 57.6,
        "beckn:breakup": [
          {
            "schema:name": "Charging cost so far (3.2 kWh @ ₹18.00/kWh)",
            "beckn:itemId": "pe-charging-01",
            "schema:price": 57.6,
            "schema:priceCurrency": "INR"
          }
        ]
      },
      "beckn:orderAttributes": {
        "tracking-details": {
          "beckn:id": "TRACK-SESSION-9876543210",
          "beckn:url": "https://track.bluechargenet-aggregator.io/session/SESSION-9876543210",
          "beckn:status": "ACTIVE",
          "live-updates": {
            "update-frequency": "PT30S",
            "next-update-at": "2023-02-18T17:01:10.065Z"
          }
        },
        "fulfillment-details": {
          "beckn:id": "fulfillment-001",
          "beckn:mode": "RESERVATION",
          "beckn:status": "ACTIVE",
          "state": {
            "code": "CHARGING-IN-PROGRESS",
            "name": "Charging Active",
            "updated-at": "2023-02-18T17:00:40.065Z",
            "updated-by": "bluechargenet-aggregator.io"
          },
          "real-time-data": {
            "charging-speed": "FAST",
            "battery-level": "45%",
            "estimated-full-charge": "2023-02-18T17:24:16.065Z",
            "connector-temperature": "32°C",
            "vehicle-status": "CONNECTED"
          },
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2023-02-18T16:54:16.065Z"
              },
              "location": {
                "schema:geo": {
                  "@type": "schema:GeoCoordinates",
                  "schema:latitude": "28.345345",
                  "schema:longitude": "77.389754"
                },
                "schema:name": "BlueCharge Connaught Place Station",
                "schema:address": {
                  "@type": "schema:PostalAddress",
                  "schema:addressLocality": "Connaught Place, New Delhi"
                }
              }
            }
          ],
          "vehicle": {
            "make": "Tata",
            "model": "Nexon EV",
            "registration": "DL-01-XX-1234"
          }
        },
        "fulfillment-type": "CHARGING"
      }
    }
  }
}
```

Tracking Response:

* message.tracking.id: Unique tracking identifier for the charging session  
* message.tracking.url: Live tracking dashboard URL for monitoring charging progress  
* message.tracking.status: Current tracking status (e.g., "active" for ongoing session)

### **Asynchronous on_status (temporary connection interruption)**

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

on_status
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
    "version": "2.0.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "PT15S",
    "network_id": ["beckn.energy.india"],
    "schema_context": [
      "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "https://becknprotocol.io/schemas/energy/v1/ev-charging-context.jsonld",
      "https://schema.org"
    ]
  },
  "message": {
    "order": {
      "@context": "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "@type": "beckn:Order",
      "beckn:id": "6743e9e2-4fb5-487c-92b7",
      "beckn:state": "ACTIVE",
      "beckn:orderNumber": "ORD-6743e9e2",
      "beckn:seller": "cpo1.com",
      "beckn:buyer": "customer-ravi-001",
      "beckn:orderItems": [
        {
          "beckn:lineId": "line-001",
          "beckn:orderedItem": "pe-charging-01",
          "beckn:quantity": 100,
          "beckn:price": {
            "@type": "schema:PriceSpecification",
            "schema:priceCurrency": "INR",
            "schema:price": 75
          },
          "beckn:orderItemAttributes": {
            "item-details": {
              "schema:name": "EV Charger #1 (AC Fast Charger)",
              "beckn:code": "ev-charger",
              "unit-price": {
                "value": "18",
                "currency": "INR/kWh"
              }
            },
            "quantity-measure": {
              "type": "CONSTANT",
              "value": "100",
              "unit": "INR"
            },
            "ev:itemAttributes": {
              "@context": "https://example.org/schema/items/v1/EVCharging/item-attributes.schema.json",
              "@type": "ev:EVChargingAttributes",
              "ev:connectorType": "CCS2",
              "ev:currentType": "AC",
              "ev:maxPowerKW": 30,
              "ev:availability": "AVAILABLE",
              "ev:tariff": {
                "schema:price": 18,
                "schema:priceCurrency": "INR",
                "ev:pricingUnit": "PER_KWH"
              }
            }
          }
        }
      ],
      "beckn:billing": "invoice-001",
      "beckn:payment": "payment-123e4567",
      "beckn:fulfillment": "fulfillment-001",
      "beckn:totals": {
        "@type": "schema:PriceSpecification",
        "schema:priceCurrency": "INR",
        "schema:price": 85,
        "beckn:breakup": [
          {
            "schema:name": "Charging session cost (5 kWh @ ₹18.00/kWh)",
            "beckn:itemId": "pe-charging-01",
            "schema:price": 75,
            "schema:priceCurrency": "INR"
          },
          {
            "schema:name": "Service Fee",
            "schema:price": 10,
            "schema:priceCurrency": "INR"
          }
        ]
      },
      "beckn:orderAttributes": {
        "provider-details": {
          "beckn:id": "cpo1.com",
          "schema:name": "CPO1 EV charging Company",
          "schema:description": "CPO1 provides EV charging facility across India",
          "schema:image": [
          "https://cpo1.com/images/logo.png"
        ]
        },
        "billing-details": {
          "beckn:id": "invoice-001",
          "beckn:payer": "customer-ravi-001",
          "schema:name": "Ravi Kumar",
          "schema:email": "ravi.kumar@greencharge.com",
          "schema:telephone": "+918765432100",
          "schema:address": {
            "@type": "schema:PostalAddress",
            "schema:streetAddress": "Apartment 123, MG Road",
            "schema:addressLocality": "Bengaluru",
            "schema:addressRegion": "Karnataka",
            "schema:postalCode": "560001",
            "schema:addressCountry": "India"
          },
          "organization": {
            "schema:name": "GreenCharge Pvt Ltd"
          },
          "tax-id": "GSTIN29ABCDE1234F1Z5",
          "timestamp": "2025-07-30T12:02:00Z"
        },
        "payment-details": {
          "beckn:id": "payment-123e4567-e89b-12d3-a456-426614174000",
          "beckn:method": "UPI-TRANSFER",
          "beckn:status": "PAID",
          "beckn:amount": {
            "currency": "INR",
            "value": 100.00
          },
          "beckn:txnRef": "123e4567-e89b-12d3-a456-426614174000",
          "collected-by": "bpp",
          "payment-type": "PRE-FULFILLMENT",
          "timestamp": "2025-07-30T14:59:00Z"
        },
        "fulfillment-details": {
          "beckn:id": "fulfillment-001",
          "beckn:mode": "RESERVATION",
          "beckn:status": "CONNECTION-INTERRUPTED",
          "state": {
            "code": "CONNECTION-INTERRUPTED",
            "name": "Charging connection lost. Retrying automatically. If this continues, please check your cable",
            "updated-at": "2025-07-30T13:07:02Z",
            "updated-by": "bluechargenet-aggregator.io"
          },
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2023-07-16T10:00:00+05:30"
              },
              "location": {
                "schema:geo": {
                  "@type": "schema:GeoCoordinates",
                  "schema:latitude": "28.345345",
                  "schema:longitude": "77.389754"
                },
                "schema:name": "BlueCharge Connaught Place Station",
                "schema:address": {
                  "@type": "schema:PostalAddress",
                  "schema:addressLocality": "Connaught Place, New Delhi"
                }
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
                "schema:geo": {
                  "@type": "schema:GeoCoordinates",
                  "schema:latitude": "28.345345",
                  "schema:longitude": "77.389754"
                },
                "schema:name": "BlueCharge Connaught Place Station",
                "schema:address": {
                  "@type": "schema:PostalAddress",
                  "schema:addressLocality": "Connaught Place, New Delhi"
                }
              },
              "instructions": {
                "short_desc": "Ground floor, Pillar Number 4"
              }
            }
          ]
        },
        "refund-terms": [
          {
            "fulfillment-state": {
              "name": "Order Confirmed",
              "code": "CONFIRMED",
              "description": "85% refund available if cancelled at least 4 hours before the scheduled charging time"
            },
            "refund-eligible": true,
            "refund-within": "PT2H",
            "refund-amount": {
              "currency": "INR",
              "value": "85"
            }
          },
          {
            "fulfillment-state": {
              "name": "Charging Active",
              "code": "ACTIVE"
            },
            "refund-eligible": false
          }
        ],
        "fulfillment-type": "CHARGING"
      }
    }
  }
}
```

Session Interruptions:

* Message.order.fulfillments.state.descriptor.code: Interruption state (changed to "CONNECTION-INTERRUPTED")  
* Message.order.fulfillments.state.descriptor.name: (changed to a relevant notification)  
* message.order.fulfillments.state.updated\_at: Timestamp when charging session ended  
* message.order.fulfillments.state.updated\_by: System that completed the session

### **Asynchronous on_update (stop charging)**

This is like getting a "Washing Complete" notification from your washing machine. The charging station is saying "Your charging session has finished\! Here's the final bill and session summary."

on_update(stop charging)
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
    "version": "2.0.0",
    "bap_id": "example-bap.com",
    "bap_uri": "https://api.example-bap.com/pilot/bap/energy/v1",
    "bpp_id": "example-bpp.com",
    "bpp_uri": "https://example-bpp.com/pilot/bap/energy/v1",
    "transaction_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "message_id": "6743e9e2-4fb5-487c-92b7-13ba8018f176",
    "timestamp": "2023-07-16T04:41:16Z",
    "ttl": "PT15S",
    "network_id": [
      "beckn.energy.india"
    ],
    "schema_context": [
      "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "https://becknprotocol.io/schemas/energy/v1/ev-charging-context.jsonld",
      "https://schema.org"
    ]
  },
  "message": {
    "order": {
      "@context": "https://becknprotocol.io/schemas/core/v2/Order/schema-context.jsonld",
      "@type": "beckn:Order",
      "beckn:id": "6743e9e2-4fb5-487c-92b7",
      "beckn:state": "COMPLETED",
      "beckn:orderNumber": "ORD-6743e9e2",
      "beckn:seller": "cpo1.com",
      "beckn:buyer": "customer-ravi-001",
      "beckn:orderItems": [
        {
          "beckn:lineId": "line-001",
          "beckn:orderedItem": "pe-charging-01",
          "beckn:quantity": 1,
          "beckn:price": {
            "currency": "INR",
            "value": 68
          },
          "beckn:orderItemAttributes": {
            "@context": "https://example.org/schema/items/v1/EVCharging/item-attributes.schema.json",
            "@type": "ev:EVChargingAttributes",
            "ev:connectorType": "CCS2",
            "ev:currentType": "AC",
            "ev:maxPowerKW": 30,
            "ev:availability": "AVAILABLE",
            "ev:tariff": {
              "schema:price": 18,
              "schema:priceCurrency": "INR",
              "ev:pricingUnit": "PER_KWH"
            }
          }
        }
      ],
      "beckn:billing": "invoice-001",
      "beckn:payment": "payment-123e4567",
      "beckn:fulfillment": "fulfillment-001",
      "beckn:totals": {
        "@type": "schema:PriceSpecification",
        "schema:priceCurrency": "INR",
        "schema:price": 78,
        "beckn:breakup": [
          {
            "schema:name": "Charging session cost (3.7 kWh @ ₹18.00/kWh)",
            "beckn:itemId": "pe-charging-01",
            "schema:price": 68,
            "schema:priceCurrency": "INR"
          },
          {
            "schema:name": "Service Fee",
            "schema:price": 10,
            "schema:priceCurrency": "INR"
          }
        ]
      },
      "beckn:orderAttributes": {
        "provider-details": {
          "beckn:id": "cpo1.com",
          "schema:name": "CPO1 EV charging Company",
          "schema:description": "CPO1 provides EV charging facility across India",
          "schema:image": [
            {
              "@type": "schema:ImageObject",
              "schema:url": "https://cpo1.com/images/logo.png"
            }
          ]
        },
        "billing-details": {
          "beckn:id": "invoice-001",
          "beckn:payer": "customer-ravi-001",
          "schema:name": "Ravi Kumar",
          "schema:email": "ravi.kumar@greencharge.com",
          "schema:telephone": "+918765432100",
          "schema:address": {
            "@type": "schema:PostalAddress",
            "schema:streetAddress": "Apartment 123, MG Road",
            "schema:addressLocality": "Bengaluru",
            "schema:addressRegion": "Karnataka",
            "schema:postalCode": "560001",
            "schema:addressCountry": "India"
          },
          "organization": {
            "schema:name": "GreenCharge Pvt Ltd"
          },
          "tax-id": "GSTIN29ABCDE1234F1Z5",
          "timestamp": "2025-07-30T12:02:00Z"
        },
        "payment-details": [
          {
            "beckn:id": "payment-123e4567-e89b-12d3-a456-426614174000",
            "beckn:method": "UPI-TRANSFER",
            "beckn:status": "PAID",
            "beckn:amount": {
              "currency": "INR",
              "value": 100.0
            },
            "beckn:txnRef": "123e4567-e89b-12d3-a456-426614174000",
            "collected-by": "bpp",
            "payment-type": "PRE-FULFILLMENT",
            "timestamp": "2025-07-30T14:59:00Z"
          },
          {
            "beckn:id": "refund-overcharge-001",
            "beckn:method": "REFUND",
            "beckn:status": "NOT_PAID",
            "beckn:amount": {
              "currency": "INR",
              "value": 22.0
            },
            "payment-type": "POST-FULFILLMENT",
            "beckn:paymentAttributes": {
              "refund-type": "OVERCHARGE_REFUND",
              "refund-amount": "22INR"
            }
          }
        ],
        "fulfillment-details": {
          "beckn:id": "fulfillment-001",
          "beckn:mode": "RESERVATION",
          "beckn:status": "COMPLETED",
          "state": {
            "code": "COMPLETED",
            "name": "Charging completed",
            "updated-at": "2025-07-30T13:07:02Z",
            "updated-by": "bluechargenet-aggregator.io"
          },
          "stops": [
            {
              "type": "START",
              "time": {
                "timestamp": "2023-07-16T10:00:00+05:30"
              },
              "location": {
                "schema:geo": {
                  "@type": "schema:GeoCoordinates",
                  "schema:latitude": "28.345345",
                  "schema:longitude": "77.389754"
                },
                "schema:name": "BlueCharge Connaught Place Station",
                "schema:address": {
                  "@type": "schema:PostalAddress",
                  "schema:addressLocality": "Connaught Place, New Delhi"
                }
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
                "schema:geo": {
                  "@type": "schema:GeoCoordinates",
                  "schema:latitude": "28.345345",
                  "schema:longitude": "77.389754"
                },
                "schema:name": "BlueCharge Connaught Place Station",
                "schema:address": {
                  "@type": "schema:PostalAddress",
                  "schema:addressLocality": "Connaught Place, New Delhi"
                }
              },
              "instructions": {
                "short_desc": "Ground floor, Pillar Number 4"
              }
            }
          ]
        },
        "refund-terms": [
          {
            "fulfillment-state": {
              "name": "Order Confirmed",
              "code": "CONFIRMED",
              "description": "85% refund available if cancelled at least 4 hours before the scheduled charging time"
            },
            "refund-eligible": true,
            "refund-within": "PT2H",
            "refund-amount": {
              "currency": "INR",
              "value": "85"
            }
          },
          {
            "fulfillment-state": {
              "name": "Charging Active",
              "code": "ACTIVE"
            },
            "refund-eligible": false
          }
        ],
        "fulfillment-type": "CHARGING"
      }
    }
  }
}
```

Session Completion:

* message.order.fulfillments.state.descriptor.code: Final session status (changed to "COMPLETED")  
* message.order.fulfillments.state.updated\_at: Timestamp when charging session ended  
* message.order.fulfillments.state.updated\_by: System that completed the session

Session Timeline:

* message.order.fulfillments.stops.time.timestamp: Session start time  
* message.order.fulfillments.stops.time.timestamp: Session end time  
* message.order.fulfillments.stops.type: Set to "finish" indicating session completion


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

### **on_discover**

The on_discover response structure and content are identical to the advance reservation use case. Please refer to the [on_discover section](#on_discover) in Use Case 1 for detailed response schema, field descriptions, and examples.

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