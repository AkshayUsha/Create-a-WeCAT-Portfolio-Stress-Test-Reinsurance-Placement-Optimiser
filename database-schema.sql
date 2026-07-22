-- CreateInsureXThon Database Schema

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'InsureXThonDb')
    CREATE DATABASE InsureXThonDb;

GO

USE InsureXThonDb;
GO

-- Users Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
CREATE TABLE dbo.Users (
    UserId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Email NVARCHAR(255) NOT NULL UNIQUE,
    FullName NVARCHAR(255) NOT NULL,
    Role NVARCHAR(50) NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- Portfolios Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Portfolios')
CREATE TABLE dbo.Portfolios (
    PortfolioId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    PortfolioName NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX),
    UserId UNIQUEIDENTIFIER NOT NULL,
    TotalPremium DECIMAL(18, 2),
    TotalExposure DECIMAL(18, 2),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
);

-- Policies Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Policies')
CREATE TABLE dbo.Policies (
    PolicyId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    PortfolioId UNIQUEIDENTIFIER NOT NULL,
    PolicyNumber NVARCHAR(50) NOT NULL UNIQUE,
    InsuredName NVARCHAR(255) NOT NULL,
    Premium DECIMAL(18, 2),
    Limit DECIMAL(18, 2),
    Deductible DECIMAL(18, 2),
    EffectiveDate DATE,
    ExpiryDate DATE,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (PortfolioId) REFERENCES dbo.Portfolios(PortfolioId)
);

-- Properties Table (Geographic Data)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Properties')
CREATE TABLE dbo.Properties (
    PropertyId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    PolicyId UNIQUEIDENTIFIER NOT NULL,
    Address NVARCHAR(500),
    Latitude DECIMAL(10, 6),
    Longitude DECIMAL(10, 6),
    TIV DECIMAL(18, 2),
    ConstructionType NVARCHAR(50),
    YearBuilt INT,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (PolicyId) REFERENCES dbo.Policies(PolicyId)
);

-- CAT Scenarios Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CatScenarios')
CREATE TABLE dbo.CatScenarios (
    ScenarioId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ScenarioName NVARCHAR(255) NOT NULL,
    PerilType NVARCHAR(50) NOT NULL,
    Severity DECIMAL(5, 2),
    ReturnPeriod INT,
    Description NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- Risk Results Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RiskResults')
CREATE TABLE dbo.RiskResults (
    ResultId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    PortfolioId UNIQUEIDENTIFIER NOT NULL,
    ScenarioId UNIQUEIDENTIFIER,
    MonteCarloIterations INT DEFAULT 10000,
    AAL DECIMAL(18, 2),
    MFL DECIMAL(18, 2),
    PML DECIMAL(18, 2),
    TVaR95 DECIMAL(18, 2),
    TVaR99 DECIMAL(18, 2),
    RiskScore DECIMAL(5, 2),
    CoefficientOfVariation DECIMAL(5, 2),
    CalculatedAt DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (PortfolioId) REFERENCES dbo.Portfolios(PortfolioId),
    FOREIGN KEY (ScenarioId) REFERENCES dbo.CatScenarios(ScenarioId)
);

-- Stress Tests Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'StressTests')
CREATE TABLE dbo.StressTests (
    StressTestId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    PortfolioId UNIQUEIDENTIFIER NOT NULL,
    TestName NVARCHAR(255),
    Parameter NVARCHAR(100),
    ParameterValue DECIMAL(10, 2),
    ResultLoss DECIMAL(18, 2),
    ExecutedAt DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (PortfolioId) REFERENCES dbo.Portfolios(PortfolioId)
);

-- Reinsurance Treaties Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ReinsuranceTreaties')
CREATE TABLE dbo.ReinsuranceTreaties (
    TreatyId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TreatyName NVARCHAR(255) NOT NULL,
    Type NVARCHAR(50),
    Limit DECIMAL(18, 2),
    Attachment DECIMAL(18, 2),
    Premium DECIMAL(18, 2),
    Ceded DECIMAL(18, 2),
    ReinsurerId NVARCHAR(255),
    EffectiveDate DATE,
    ExpiryDate DATE,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);

-- Reinsurance Optimization Results Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ReinsuranceOptimizations')
CREATE TABLE dbo.ReinsuranceOptimizations (
    OptimizationId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    PortfolioId UNIQUEIDENTIFIER NOT NULL,
    SelectedTreatyId UNIQUEIDENTIFIER,
    NetRetention DECIMAL(18, 2),
    GrossRetention DECIMAL(18, 2),
    TotalPremium DECIMAL(18, 2),
    ExpectedCost DECIMAL(18, 2),
    RiskMitigation DECIMAL(5, 2),
    ROI DECIMAL(5, 2),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (PortfolioId) REFERENCES dbo.Portfolios(PortfolioId),
    FOREIGN KEY (SelectedTreatyId) REFERENCES dbo.ReinsuranceTreaties(TreatyId)
);

-- AI Reports Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AIReports')
CREATE TABLE dbo.AIReports (
    ReportId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    PortfolioId UNIQUEIDENTIFIER NOT NULL,
    ReportType NVARCHAR(100),
    ExecutiveSummary NVARCHAR(MAX),
    RiskExplanation NVARCHAR(MAX),
    Recommendations NVARCHAR(MAX),
    GeneratedAt DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (PortfolioId) REFERENCES dbo.Portfolios(PortfolioId)
);

-- Audit Logs Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AuditLogs')
CREATE TABLE dbo.AuditLogs (
    LogId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER,
    Action NVARCHAR(100),
    Entity NVARCHAR(100),
    EntityId UNIQUEIDENTIFIER,
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    Timestamp DATETIME2 DEFAULT GETUTCDATE(),
    FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
);

-- Create Indexes
CREATE INDEX IX_Portfolios_UserId ON dbo.Portfolios(UserId);
CREATE INDEX IX_Policies_PortfolioId ON dbo.Policies(PortfolioId);
CREATE INDEX IX_Properties_PolicyId ON dbo.Properties(PolicyId);
CREATE INDEX IX_RiskResults_PortfolioId ON dbo.RiskResults(PortfolioId);
CREATE INDEX IX_RiskResults_ScenarioId ON dbo.RiskResults(ScenarioId);
CREATE INDEX IX_StressTests_PortfolioId ON dbo.StressTests(PortfolioId);
CREATE INDEX IX_ReinsuranceOptimizations_PortfolioId ON dbo.ReinsuranceOptimizations(PortfolioId);
CREATE INDEX IX_AIReports_PortfolioId ON dbo.AIReports(PortfolioId);
CREATE INDEX IX_AuditLogs_UserId ON dbo.AuditLogs(UserId);
CREATE INDEX IX_AuditLogs_Timestamp ON dbo.AuditLogs(Timestamp);

-- Insert Sample Data
INSERT INTO dbo.Users (Email, FullName, Role) VALUES
    ('admin@insurexthon.com', 'Admin User', 'Admin'),
    ('actuary@insurexthon.com', 'John Actuary', 'Actuary'),
    ('underwriter@insurexthon.com', 'Jane Underwriter', 'Underwriter');

INSERT INTO dbo.CatScenarios (ScenarioName, PerilType, Severity, ReturnPeriod) VALUES
    ('Major Flood Event', 'Flood', 0.8, 100),
    ('Moderate Earthquake', 'Earthquake', 0.6, 50),
    ('Hurricane Season Peak', 'Cyclone', 0.9, 200),
    ('Wildfire Season', 'Wildfire', 0.7, 75);

GO
