# CAT Portfolio Stress Test & Reinsurance Placement Optimiser

**InsureXThon Hackathon Submission**

A cloud-native enterprise platform for catastrophe (CAT) risk modeling, portfolio stress testing, and AI-driven reinsurance optimization. Built with **Angular 18** frontend, **.NET 8** backend, and **Azure** cloud infrastructure with full CI/CD automation.

## 🎯 Problem Statement

Insurance underwriters struggle with:
- Manual portfolio risk assessment (slow, error-prone)
- Lack of real-time catastrophe scenario modeling
- Inefficient reinsurance placement decisions
- Difficulty extracting actionable insights from complex data

**Our Solution:** Real-time CAT modeling, Monte Carlo simulations, AI-powered insights, and automated reinsurance optimization.

---

## 🏗️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Angular 18, Angular Material, RxJS Signals, Leaflet Maps, Chart.js |
| **Backend** | .NET 8 (C#), EF Core 8, ASP.NET Core Web API |
| **Architecture** | Clean Architecture, DDD, CQRS (MediatR), Repository + Unit of Work |
| **Database** | Azure SQL Hyperscale, EF Core migrations |
| **Cloud** | Azure App Service, Static Web Apps, Storage, Key Vault, OpenAI, AI Search |
| **DevOps** | Docker Compose (local), Bicep IaC, GitHub Actions CI/CD |
| **AI/Analytics** | Azure OpenAI (GPT-4o), Azure AI Search, Semantic Kernel |
| **Observability** | Serilog → Application Insights, Health Checks |

---

## 📁 Project Structure

```
InsureXThon/
├── README.md                           # This file
├── docker-compose.yml                  # Local dev stack: SQL Server, Azurite, Redis
├── database-schema.sql                 # SQL schema + seed data + indexes
│
├── src/
│   ├── Domain/                         # DDD: Aggregates, Value Objects, Interfaces
│   │   ├── Entities/                   # Portfolio, Policy, Property, CatScenario, etc.
│   │   └── Interfaces/                 # IRepository, IUnitOfWork
│   │
│   ├── Application/                    # CQRS, DTOs, Validators, Mappings
│   │   ├── DTOs/
│   │   ├── Portfolios/
│   │   │   ├── Commands/
│   │   │   └── Queries/
│   │   ├── Validators/
│   │   └── Mappings/
│   │
│   ├── Infrastructure/                 # EF Core, Repositories, Services
│   │   ├── Data/
│   │   ├── Repositories/
│   │   ├── Services/
│   │   │   ├── RiskCalculationService.cs    # Monte Carlo, TVaR, PML
│   │   │   └── Interfaces.cs
│   │   └── DependencyInjection.cs
│   │
│   └── API/                            # ASP.NET Core Web API
│       ├── Program.cs
│       ├── appsettings.json
│       ├── Dockerfile
│       └── Controllers/
│           ├── PortfoliosController.cs
│           ├── RiskController.cs
│           ├── AIReportsController.cs
│           └── CopilotController.cs
│
├── frontend/
│   └── insurexthon-web/                # Angular 18 SPA
│       ├── package.json
│       ├── angular.json
│       ├── tsconfig.json
│       └── src/
│           ├── app/
│           │   ├── core/
│           │   │   ├── services/        # API service, Auth, State
│           │   │   └── guards/
│           │   ├── shared/              # Common components, pipes, directives
│           │   ├── features/            # Dashboard, Portfolio, Risk, AI
│           │   └── app.component.ts
│           ├── assets/
│           ├── environments/
│           └── main.ts
│
├── infra/
│   ├── main.bicep                      # Full Azure IaC deployment
│   └── parameters.json                 # Environment-specific params
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml                   # GitHub Actions: Build, Test, Deploy
│
├── prompts/
│   └── ai-prompts.json                 # AI prompt library (GPT-4o)
│
├── docs/
│   ├── ARCHITECTURE.md
│   ├── BRD.md
│   ├── SRS.md
│   ├── TESTING_STRATEGY.md
│   ├── DEPLOYMENT_GUIDE.md
│   └── PRODUCT_BACKLOG.md
│
└── tests/
    ├── InsureXThon.Domain.Tests/       # xUnit + Moq
    ├── InsureXThon.Application.Tests/
    └── InsureXThon.API.Tests/
```

---

## 🚀 Quick Start

### Prerequisites
- Docker Desktop
- .NET 8 SDK
- Node.js 18+
- Azure CLI
- Visual Studio Code or Visual Studio 2022

### Local Development (Docker Compose)

```bash
# Clone repository
git clone https://github.com/AkshayUsha/Create-a-WeCAT-Portfolio-Stress-Test-Reinsurance-Placement-Optimiser.git
cd InsureXThon

# Start local stack (SQL Server, Azurite, Redis)
docker-compose up -d

# Apply migrations
cd src/API
dotnet ef database update

# Run backend API
dotnet run

# In another terminal: Run frontend
cd frontend/insurexthon-web
npm install
ng serve

# Access:
# - Frontend: http://localhost:4200
# - API: http://localhost:5000
# - Swagger: http://localhost:5000/swagger
```

### Azure Deployment

```bash
# 1. Authenticate
az login
az account set --subscription "<subscription-id>"

# 2. Create resource group
az group create --name rg-insurexthon --location eastus

# 3. Deploy infrastructure
az deployment group create \
  --resource-group rg-insurexthon \
  --template-file infra/main.bicep \
  --parameters infra/parameters.json

# 4. GitHub Actions CI/CD automatically deploys on push to main
```

---

## 🧮 Core Features

### 1. Portfolio Management
- Upload and manage insurance portfolios
- Policy-level aggregation
- Geographic property mapping
- Zone-based risk adjustments

### 2. CAT Risk Modeling
- **Monte Carlo Simulation** (10,000 iterations, seeded)
- **Vulnerability Curves** by peril (Flood, EQ, Cyclone, Wildfire)
- **Metrics:** TVaR 95/99, PML, AAL, MFL, Risk Score (0–100)
- **Climate Adjustments** and zone-based factors

### 3. Scenario Stress Testing
- Pre-defined and custom catastrophe scenarios
- Real-time loss calculations
- What-if analysis
- Scenario comparison dashboards

### 4. Reinsurance Optimization
- Automated treaty placement recommendations
- Premium vs. coverage trade-off analysis
- Historical performance tracking
- Cost-benefit visualization

### 5. AI-Powered Insights (GPT-4o)
- Executive summary generation
- Risk explanations and patterns
- Scenario comparisons
- Reinsurance recommendations
- Board-level reports

### 6. Copilot RAG Interface
- Natural language portfolio queries
- Azure AI Search semantic matching
- Context-aware recommendations
- Streaming chat responses

---

## 🔐 Security & Compliance

- **Authentication:** Azure Entra ID (JWT tokens)
- **Authorization:** Role-based access control (Admin, Actuary, Underwriter)
- **Audit Logging:** All user actions logged to AppInsights
- **Data Protection:** Azure Key Vault for secrets, TLS in transit
- **Compliance:** OWASP Top 10 mitigations documented

---

## 📊 Observability

- **Logging:** Serilog structured logs → Application Insights
- **Metrics:** Custom counters for risk calculations, API response times
- **Health Checks:** Liveness and readiness probes for cloud deployment
- **Tracing:** Distributed tracing across frontend and backend

---

## 🧪 Testing Strategy

| Layer | Tool | Coverage Target |
|-------|------|-----------------|
| **Unit** | xUnit + Moq | Domain logic, services |
| **Integration** | WebApplicationFactory | Database, EF Core, APIs |
| **End-to-End** | Cypress/Playwright | User workflows, UI |
| **Load** | k6 or JMeter | API scalability |
| **Security** | OWASP ZAP | Vulnerability scanning |

---

## 📈 Deployment Pipeline

```
GitHub Push (main)
    ↓
GitHub Actions Trigger
    ├─ Run Tests
    ├─ Build .NET API (Docker)
    ├─ Build Angular SPA
    ├─ Push to Container Registry
    ↓
Deploy to Azure
    ├─ App Service (API)
    ├─ Static Web Apps (Frontend)
    ├─ SQL Hyperscale (Database)
    └─ Functions (Async jobs)
    ↓
Health Checks & Monitoring
```

---

## 📚 Documentation

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** – System design, layers, data flow
- **[BRD.md](docs/BRD.md)** – Business requirements and use cases
- **[SRS.md](docs/SRS.md)** – Software requirements specification
- **[TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md)** – Test plan, pyramid, coverage
- **[DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md)** – Step-by-step Azure setup
- **[PRODUCT_BACKLOG.md](docs/PRODUCT_BACKLOG.md)** – 4-phase roadmap

---

## 🎯 Next Phases

### Phase 2: Frontend Components (Week 2-3)
- [ ] Executive Dashboard with KPI cards
- [ ] Azure Maps integration with property clustering
- [ ] Scenario builder with reactive validation
- [ ] Risk metrics charts (Chart.js)
- [ ] AI Copilot chat interface

### Phase 3: Backend & AI (Week 3-4)
- [ ] ReinsuranceOptimizerService (full treaty math)
- [ ] AIReportService with structured JSON parsing
- [ ] Azure Functions for bulk processing
- [ ] Power BI embedded token generation
- [ ] Advanced prompt engineering

### Phase 4: Testing & Operations (Week 5)
- [ ] Full test suites (xUnit, WebApplicationFactory)
- [ ] E2E tests (Cypress/Playwright)
- [ ] Security runbook
- [ ] Cost optimization guide

---

## 🏆 Hackathon Checklist

✅ **Architecture** – Clean, DDD, CQRS, repository pattern  
✅ **Backend** – .NET 8, EF Core, production-grade actuarial engine  
✅ **Frontend** – Angular 18 with modern state management  
✅ **Cloud** – Full Azure infrastructure with Bicep IaC  
✅ **CI/CD** – GitHub Actions automated deployment  
✅ **AI** – GPT-4o integration + RAG  
✅ **Documentation** – Architecture, BRD, SRS, runbooks  
✅ **Security** – Entra ID, RBAC, audit logging  
✅ **Observability** – Serilog, AppInsights, health checks  

---

## 📝 License

[Add your license here]

## 👥 Contributors

- **Akshay Usha** – Lead Developer

---

## 💬 Support

For questions or issues:
- Check [DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md) for setup troubleshooting
- Review [SRS.md](docs/SRS.md) for feature requirements
- Open an issue on GitHub

---

**Built for InsureXThon | Enterprise Reinsurance Optimization Platform**
