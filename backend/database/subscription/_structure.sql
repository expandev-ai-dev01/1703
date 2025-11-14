/**
 * @schema subscription
 * Contains tables for managing accounts (tenants), subscriptions, and billing.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'subscription')
BEGIN
    EXEC('CREATE SCHEMA subscription');
END
GO

-- FEATURE INTEGRATION POINT
-- The primary [account] table, which is central to the multi-tenancy architecture, will be defined here.
-- Example:
/*
CREATE TABLE [subscription].[account] (
  [idAccount] INT IDENTITY(1,1) NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [isActive] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
*/
