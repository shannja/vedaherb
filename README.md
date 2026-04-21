# Veda.Herb (vedaherb.app)

[![Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![AI Engine](https://img.shields.io/badge/AI-Gemma%203%20%2B%20LiteRT-green?style=flat-square)](https://ai.google.dev)

> **"Heritage in your pocket, health in your hands."**

Veda.Herb is an offline-first mobile solution designed for the **ASEAN AI Hackathon**. It digitizes traditional herbal wisdom across the ASEAN region, using Edge AI to provide safe, verified, and culturally resonant medical guidance in areas without internet connectivity.

## The Challenge
In rural ASEAN, healthcare is often hours away. Communities rely on herbal heritage, but as this knowledge fades, the misuse of antibiotics (AMR) rises. **Veda.Herb** acts as a bridge, ensuring traditional remedies are used safely and according to modern medical standards.

## Key Features
* **Step by Step Identification:** Combines **Computer Vision** (LiteRT), **Sensory Triage** (User input), and **Ecological Data** (GPS/Seasonality) to prevent toxic look-alike errors.
* **Offline LLM Reasoning:** Powered by **Gemma 3**, providing localized conversational triage and dosage instructions without requiring constant internet.
* **Safety-First Grounding:** Knowledge is grounded in a verified **ObjectBox** vector database (e.g., DOH-certified "10 Halamang Gamot").
* **Active Monitoring:** A dynamic symptom tracking loop that escalates to emergency clinical locations if health does not improve.

## Tech Stack
- **Frontend:** Flutter (Mobile & Web)
- **State Management:** Riverpod
- **Local AI:** LiteRT (formerly TensorFlow Lite) for Vision & Gemma 3 for NLP
- **Database:** ObjectBox (NoSQL / Vector Database)
