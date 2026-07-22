# InsureXThon Architecture

## System Overview

InsureXThon follows a **Clean Architecture** pattern with clear separation of concerns across five layers:

```
┌─────────────────────────────────────┐
│   Presentation Layer (Angular UI)   │
├─────────────────────────────────────┤
│   API Layer (ASP.NET Core)          │
├─────────────────────────────────────┤
│   Application Layer (CQRS/MediatR)  │
├─────────────────────────────────────┤
│   Domain Layer (DDD)                │
├─────────────────────────────────────┤
│   Infrastructure Layer              │
└─────────────────────────────────────┘
```

## Layer Responsibilities

### 1. Presentation Layer (Frontend - Angular 18)
- **Location:** `frontend/insurexthon-web/src/app`
- **Components:** Dashboard, Portfolio Manager, Risk Dashboard, AI Copilot
- **State Management:** RxJS Signals (modern Angular)
- **HTTP Client:** Signal-based API service
- **Maps:** Leaflet.js for geographic visualization
- **Charts:** Chart.js for risk metrics

**Key Features:**
- Responsive Material Design UI
- Real-time data binding
- Lazy-loaded feature modules
- Authentication guards

### 2. API Layer (ASP.NET Core)
- **Location:** `src/API`
- **Framework:** ASP.NET Core 8 Minimal APIs + Controllers
- **Authentication:** Azure Entra ID JWT
- **Authorization:** Role-Based Access Control (RBAC)
- **Validation:** FluentValidation middleware

**Endpoints:**
- `POST /api/portfolios` - Upload portfolio
- `GET /api/portfolios/{id}/risk` - Calculate risk
- `POST /api/scenarios/{id}/stress-test` - Run stress test
- `POST /api/reports/generate` - Generate AI report
- `GET /api/copilot/chat` - RAG-enabled chat

### 3. Application Layer (CQRS - MediatR)
- **Location:** `src/Application`
- **Pattern:** Command Query Responsibility Segregation
- **Commands:** CreatePortfolio, UploadPolicy, RunRiskCalculation
- **Queries:** GetPortfolio, GetRiskResults, ListScenarios
- **DTOs:** Strongly typed records for API contracts
- **Validators:** FluentValidation rules per command/query
- **Mappings:** AutoMapper profiles

**Advantages:**
- Separation of reads and writes
- Easier testing (each command/query is isolated)
- Scalable (separate read/write models later)

### 4. Domain Layer (DDD)
- **Location:** `src/Domain`
- **Aggregates:**
  - **Portfolio Aggregate:** Portfolio, Policies, Properties
  - **Risk Aggregate:** CatScenario, RiskResult, StressTest
  - **Reinsurance Aggregate:** Treaty, Optimization
  - **AI Aggregate:** AIReport, Audit Log
- **Value Objects:** Money, Risk Score, Premium
- **Interfaces:** IRepository<T>, IUnitOfWork
- **Domain Events:** Ready for event sourcing expansion

**Business Rules Enforced:**
- Portfolio exposure limits
- Premium validation
- Risk thresholds
- Treaty compliance

### 5. Infrastructure Layer
- **Location:** `src/Infrastructure`
- **Data Access:** EF Core 8 with Azure SQL
- **Repositories:** Generic `Repository<T>` pattern
- **Unit of Work:** Transaction coordination
- **Services:**
  - **RiskCalculationService:** Monte Carlo, TVaR, PML
  - **BlobStorageService:** Azure Blob access
  - **AzureOpenAIService:** GPT-4o integration
  - **AzureSearchService:** Semantic search for RAG
- **Dependency Injection:** Composition root in `DependencyInjection.cs`

## Data Flow

### Portfolio Upload Flow
```
1. User uploads Excel file → Angular Component
2. Component → POST /api/portfolios/upload
3. PortfoliosController → UploadPortfolioCommand (MediatR)
4. MediatR → UploadPortfolioCommandHandler
5. Handler → Repository → EF Core → SQL Server
6. Response → Portfolio created with ID
```

### Risk Calculation Flow
```
1. User clicks "Calculate Risk" → Angular
2. Component → POST /api/risk/calculate
3. RiskController → CalculateRiskCommand
4. Handler → RiskCalculationService
5. Service reads Portfolio from Repository
6. Monte Carlo: 10,000 iterations with seeded RNG
7. Compute TVaR, PML, AAL, MFL, Risk Score
8. Save RiskResult to DB
9. Return metrics to frontend → Charts
```

### AI Report Generation
```
1. User clicks "Generate Report" → Angular
2. Component → POST /api/reports/generate
3. AIReportsController → GenerateReportCommand
4. Handler → AIReportService
5. Service reads RiskResult, Portfolio
6. Constructs prompt from ai-prompts.json
7. Calls Azure OpenAI GPT-4o
8. Parses structured JSON response
9. Saves to AIReport table
10. Stream response to frontend
```

## Technology Decisions

| Decision | Rationale |
|----------|----------|
| **Clean Architecture** | Maintainability, testability, independence from frameworks |
| **DDD** | Complex domain logic (risk modeling) benefits from explicit aggregates |
| **CQRS** | Separate read/write concerns, scalability path |
| **Repository + UoW** | Abstraction over EF Core, easier unit testing |
| **EF Core 8** | Modern .NET ORM, async all the way, LINQ flexibility |
| **MediatR** | Decouples commands/queries from handlers, easy testing |
| **Angular Signals** | Modern state management (RxJS replacement), performance |
| **Bicep** | Infrastructure as Code for Azure, version-controlled |
| **GitHub Actions** | CI/CD native to GitHub, no extra platform |
| **Serilog** | Structured logging, Application Insights integration |

## Deployment Architecture

```
                          ┌─ Azure CDN ◄──┐
                          │               │
    GitHub Repo ─► GitHub Actions ────► Static Web Apps (Frontend)
                          │               │
                          ├─────────────► App Service (Backend API)
                          │               │
                          ├─────────────► SQL Database (Hyperscale)
                          │               │
                          ├─────────────► Blob Storage
                          │               │
                          ├─────────────► Key Vault (Secrets)
                          │               │
                          └─────────────► App Insights (Monitoring)
```

## Security Architecture

- **Authentication:** Azure Entra ID (JWT bearer tokens)
- **Authorization:** Custom RBAC policies (Admin, Actuary, Underwriter)
- **Data Encryption:** TLS in transit, encryption at rest in Azure
- **Secrets:** Azure Key Vault, never in code/config
- **Audit:** All mutations logged to AuditLog table
- **CORS:** Frontend domain whitelist
- **Rate Limiting:** API throttling per user/IP

## Testing Strategy

### Unit Tests (xUnit + Moq)
- Domain logic (risk calculations)
- Validators
- Service methods

### Integration Tests (WebApplicationFactory)
- API endpoints
- EF Core + Database
- Full request/response cycle

### E2E Tests (Cypress/Playwright)
- User workflows
- UI interactions
- Data persistence

## Performance Considerations

- **Database:** Azure SQL Hyperscale for large portfolios
- **Caching:** Redis for frequently accessed data (scenario definitions, user sessions)
- **API:** Response compression, async/await throughout
- **Frontend:** Lazy loading, OnPush change detection, tree-shaking
- **AI:** Batch processing for report generation, async background jobs

## Scalability Path

1. **Phase 1 (Current):** Monolithic API, single SQL database
2. **Phase 2:** Separate read/write DB (CQRS pattern full implementation)
3. **Phase 3:** Microservices (Risk Service, AI Service, Optimization Service)
4. **Phase 4:** Event sourcing, real-time updates via SignalR

---

**For more details, see:**
- [SRS.md](SRS.md) - Feature specifications
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Setup instructions
- [TESTING_STRATEGY.md](TESTING_STRATEGY.md) - Test plans
