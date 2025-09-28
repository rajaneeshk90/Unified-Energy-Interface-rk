# **Implementation Guide - EV Charging (DRAFT)**

## **Copyright Notice**

#### **License: [CC-BY-NC-SA 4.0](https://becknprotocol.io/license/) becknprotocol.io**

## **Status of This Memo**

#### **This is a draft RFC for implementing EV charging using the Beckn Protocol. It provides implementation guidance for anyone to build interoperable EV charging applications that integrate with each other on a decentralized network while maintaining compatibility with OCPI standards for CPO communication.**

## **Abstract**

This RFC proposes a practical way to make EV charging easier to find and use by applying the Beckn Protocol's distributed commerce model. Instead of juggling multiple apps and accounts for different charging networks, drivers can discover and book charging sessions from any participating Charge Point Operator (CPO) through a single consumer interface.

The design shifts today's fragmented network silos into an open, interoperable marketplace. Drivers can search, compare options, view transparent pricing, and reserve a slot at any eligible station—regardless of the underlying CPO. By standardizing discovery, pricing, and booking, the approach tackles three persistent barriers to EV adoption: charging anxiety, network fragmentation, and payment complexity.

Built on Beckn's commerce capabilities and aligned with OCPI for technical interoperability, the implementation lets e-Mobility Service Providers (eMSPs) aggregate services from multiple CPOs while delivering a consistent, app-agnostic experience to consumers. The result is a scalable foundation that supports growth today and remains flexible for future expansion of the EV charging ecosystem.

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

* When a network participant(NP1) sends a message to another participant(NP2), the other participant(NP2) immediately returns back an ACK/NACK(Acknowledgement or Negative Acknowledgement in case of error - usually with wrongly formed messages).  
* An ACK is an indicator that the receiving participant(NP2) will process this message and dispatch an on_xxxxxx message to original NP (NP1)  
* Subsequently after processing the message NP2 sends back the real response in the corresponding on_xxxxxx message, to which again the first participant(NP1).  
* This message can contain a message field (for success) or error field (for failure)  
* NP1 when it receives the on_xxxxxx message, sends back an ACK/NACK (Here in both the cases NP1 will not send any subsequent message).  
* In the Use case diagrams, this ACK/NACK is not illustrated explicitly to keep the diagrams crisp.  
* However when writing software we should be prepared to receive these NACK messages as well as error field in the on_xxxxxx messages  
* While this discussion is from a Beckn perspective, Adapters can provide synchronous modes. For example, the Protocol Server which is the reference implementation of the Beckn Adapter provides a synchronous mode by default. So if your software calls the support endpoint on the BAP Protocol Server, the Protocol Server waits till it gets the on_support and returns back that as the response.

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

Structure of a on_select message with an error

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

Note: This document does not detail the mapping between Beckn Protocol and OCPI. Please refer to [this](https://docs.google.com/document/d/13gtF2GHoWnjahqwzCRsOojjPLzhlOhWx_04m72VAdM4/edit?tab=t.0) document for the same.

## **Use cases:**

This document explores the below use cases for EV charging interactions:

1. [Walk-in flow (MOST POPULAR)](./1_Walkin_use_case.md)  
2. [Reservation in advance](./2_Reservation_use_case.md)  
3. [Undercharge & overcharge](./3_Under_and_overcharge.md)  
4. [Loyalty or subscription](./4_Loyalty_and_subscription.md)  
5. [B2B deal](./5_B2B_deals.md)  
6. [Offers](./6_offers.md)  
7. [Surcharge](./7_Surcharge.md)

## **Integrating with your software**

This section gives a general walkthrough of how you would integrate your software with the Beckn network (say the sandbox environment). Refer to the starter kit for details on how to register with the sandbox and get credentials.

Beckn-ONIX is an initiative to promote easy installation and maintenance of a Beckn Network. Apart from the Registry and Gateway components that are required for a network facilitator, Beckn-ONIX provides a Beckn Adapter. A reference implementation of the Beckn-ONIX specification is available at [Beckn-ONIX repository](https://github.com/beckn/beckn-onix). The reference implementation of the Beckn Adapter is called the Protocol Server. Based on whether we are writing the seeker platform or the provider platform, we will be installing the BAP Protocol Server or the BPP Protocol Server respectively.

### **Integrating the seeker platform**

If you are writing the seeker platform software, the following are the steps you can follow to build and integrate your application.

1. Identify the use cases from the above section that are close to the functionality you plan for your application.  
2. Design and develop the UI that implements the flow you need. Typically you will have an API server that this UI talks to and it is called the Seeker Platform in the diagram below.  
3. The API server should construct the required JSON message packets required for the different endpoints shown in the API section above.  
4. Install the BAP Protocol Server using the reference implementation of Beckn-ONIX. During the installation, you will need the address of the registry of the environment, a URL where the Beckn responses will arrive (called Subscriber URL) and a subscriber_id (typically the same as subscriber URL without the "https://" prefix)  
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
2. Design and develop the component that accepts the Beckn requests and interacts with your software to do transactions. It has to be an endpoint(it is called as webhook_url in the description below) which receives all the Beckn requests (search, select etc). This endpoint can either exist outside of your marketplace/shop software or within it. That is a design decision that will have to be taken by you based on the design of your existing marketplace/shop software. This component is also responsible for sending back the responses to the Beckn Adaptor.  
3. Install the BPP Protocol Server using the reference implementation of Beckn-ONIX. During the installation, you will need the address of the registry of the environment, a URL where the Beckn responses will arrive (called Subscriber URL), a subscriber_id (typically the same as subscriber URL without the "https://" prefix) and the webhook_url that you configured in the step above. Also the address of the BPP Protocol Server Client will have to be configured in your component above. This address hosts all the response endpoints (on_search,on_select etc)  
4. Install the layer 2 file for the domain (Link is in the last section of this document)  
5. Check with your network tech support to enable your BPP Protocol Server in the registry.  
6. Once enabled, you can transact on the Beckn Network. Typically the sandbox environment will have the rest of the components you need to test your software. In the diagram below,  
   * you write the Provider Platform(dark blue) - Here the component you wrote above in point 2 as well as your marketplace/shop software is together shown as Provider Platform  
   * install the BPP Protocol Server (light blue)  
   * the remaining components are provided by the sandbox environment  
   * Use the postman collection to test your Provider Platform  
7. Once the application is working on the Sandbox, refer to the Starter kit for instructions to take it to pre-production and production.

## **Links to artefacts**

* [Postman collection for UEI EV Charging](https://github.com/beckn/missions/blob/main/UEI/postman/ev-charging_uei_postman_collection.json)  
* [Layer2 config for UEI EV Charging](https://github.com/beckn/missions/blob/main/UEI/layer2/EV-charging/3.1/energy_EV_1.1.0_openapi_3.1.yaml)  
* When installing layer2 using Beckn-ONIX use this web address ([https://raw.githubusercontent.com/beckn/missions/refs/heads/main/UEI/layer2/EV-charging/3.1/energy_EV_1.1.0_openapi_3.1.yaml](https://raw.githubusercontent.com/beckn/missions/refs/heads/main/UEI/layer2/EV-charging/3.1/energy_EV_1.1.0_openapi_3.1.yaml))
