# UIKit-WeatherApp

[![Swift](https://img.shields.io/badge/Swift-6.3-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS_18.0+-blue.svg)](https://developer.apple.com/ios/)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM+Clean-green.svg)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

**UIKit-WeatherApp** is a demo weather forecast application built entirely with **UIKit**, leveraging modern approaches: **Compositional Layout**, **Diffable Data Source**, **Observation Framework** (Swift Observation), and **Clean Architecture**. The project showcases industrial‑grade code organisation for medium‑complexity iOS apps.

## Requirements

- Xcode 26.4 or later (Swift 6.3 compiler required)
- iOS 18.0+ (deployment target)
- Swift 6.3+

## 📖 Project History

This application was originally created as an **MVP (Minimum Viable Product)** using a **local Large Language Model** (LLM) running entirely offline. The initial generation took about an hour, producing a working version that served as a solid starting point. This approach ensures that no code or data is ever transmitted to external servers — an essential requirement for companies with strict data privacy policies.

The initial code was functional but had typical AI‑generation flaws:

- No clear architecture (everything in a single `ViewController`)
- Tight coupling to the network layer
- Minimal error handling
- No tests or modularity

**The goal I set for myself** was to turn this raw MVP into a reference‑quality industrial project by applying iterative improvements:

1. **Refactoring** – introduce Clean Architecture, split into layers.
2. **Modularisation** – extract each layer into a separate SPM package.
3. **Adoption of modern UIKit practices** – Compositional Layout, Diffable Data Source, Observation Framework for reactive bindings.
4. **Test coverage** – add unit and UI tests.
5. **Documentation & CI/CD** – write this README and set up automated builds.

This process demonstrates my approach to working with legacy or AI‑generated code – spotting architectural flaws and systematically fixing them. The project is no longer just a demo; it’s a **living portfolio of engineering culture**.

> *Once the project reaches a stable version, I plan to introduce a separate CHANGELOG to track version‑based changes.*

## 🚀 Features

- 📍 Current weather (temperature, humidity, wind, pressure) — fetched from a **real API** using a demo key
- ⏱ Hourly forecast for the next 24 hours
- 📅 **3‑day forecast** with min/max temperatures
- 🌙 Dark Mode Support
- 🔤 Dynamic Type Support
- ❌ Network error handling with retry option
- 🌐 **Localisation** – supports English and Russian

> **Note:** The app uses a real API with a demo key. Mock repositories are only used for unit tests and offline development (e.g., screenshot capture). They are never used in production builds.

## 🏗 Architecture

The project follows **Clean Architecture** principles, separating the code into three distinct layers: Presentation → Domain ← Data. This ensures that the business logic remains isolated and testable.

For a detailed breakdown of each layer and its modularisation using Swift Packages, see the **Modules (SPM)** section below.

### Modules (SPM)

The project is split into several Swift Packages to enforce separation of concerns and enable independent testing:

- **Domain** – Contains business entities, repository interfaces, and use cases.
- **Data** – implements the repository interfaces defined in Domain. Handles networking (`URLSession` + `Codable`) and provides data to the upper layers.
- **Presentation (ViewModels)** – contains the presentation logic, including `ViewModels` that use the Observation Framework for reactive bindings.
- **Toolbox** – provides shared utilities, extensions, and configuration helpers used across the other packages.
- **Mocks** – provides fake implementations of repositories and other services for testing and offline development. Not used in production builds.

The remaining UI components – `ViewControllers`, `Views`, and navigation logic – are kept in the main Xcode project, ensuring a clean boundary between the UI layer and the rest of the application.

This modular structure provides:
- **Testability** – each layer can be verified in isolation.
- **Replaceability** – easily swap the real API for mocks or a different provider.
- **Scalability** – adding new features doesn’t break existing code.

## 🛠 Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **UI** | UIKit + Compositional Layout + Diffable Data Source | Flexible, performant layout with automatic collection updates and animations |
| **Reactivity** | Observation Framework | ViewModel ↔ View binding, loading state handling |
| **Networking** | URLSession + Codable | REST calls to an external weather API |
| **Modularisation** | Swift Package Manager | Logical separation with explicit dependencies |

## 🚀 Swift 7 Readiness

The project is **fully prepared for the upcoming Swift 7** – all necessary compiler flags and language features are already enabled. This forward‑compatibility is a deliberate design choice, demonstrating a proactive approach to keeping the codebase current and maintainable. I will personally handle the migration to Swift 7 once the final toolchain is released, ensuring zero disruption.

## 📄 License

MIT © [Vitaliy Pykhtin](https://github.com/VitaliyPykhtin). See [LICENSE](LICENSE) for details.

## ✍️ Author

**Vitaliy Pykhtin**
Mobile Tech Lead · iOS · Android · Flutter
Passionate about Swift & Apple platforms

[GitHub](https://github.com/VitaliyPykhtin) · [LinkedIn](https://www.linkedin.com/in/vitaliy-pykhtin-b00ab8156) · [Telegram](https://t.me/bboyViT)

---

*This project is a demonstration of architectural design skills and proficiency with modern UIKit. Feedback is always welcome!* 🚀
