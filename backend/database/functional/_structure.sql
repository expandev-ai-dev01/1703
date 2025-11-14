/**
 * @schema functional
 * Contains tables related to the core business logic and entities of the application.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'functional')
BEGIN
    EXEC('CREATE SCHEMA functional');
END
GO

-- FEATURE INTEGRATION POINT
-- Tables for business entities like users, products, orders, etc., will be defined here.
-- Example:
/*
CREATE TABLE [functional].[user] (
  [idUser] INT IDENTITY(1,1) NOT NULL,
  [idAccount] INT NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [email] NVARCHAR(255) NOT NULL,
  [passwordHash] NVARCHAR(255) NOT NULL,
  [deleted] BIT NOT NULL DEFAULT (0)
);
*/
