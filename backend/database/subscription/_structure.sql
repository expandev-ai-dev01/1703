/**
 * @schema subscription
 * Contains tables for managing accounts (tenants), subscriptions, and billing.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'subscription')
BEGIN
    EXEC('CREATE SCHEMA subscription');
END
GO

/**
 * @table {account} Represents a tenant in the multi-tenant architecture.
 * @multitenancy false
 * @softDelete false
 * @alias acc
 */
CREATE TABLE [subscription].[account] (
  [idAccount] INT IDENTITY(1, 1) NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [active] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey {pkAccount}
 * @keyType Object
 */
ALTER TABLE [subscription].[account]
ADD CONSTRAINT [pkAccount] PRIMARY KEY CLUSTERED ([idAccount]);
GO
