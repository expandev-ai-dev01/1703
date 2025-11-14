/**
 * @schema security
 * Contains tables related to authentication, authorization, roles, and permissions.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'security')
BEGIN
    EXEC('CREATE SCHEMA security');
END
GO

-- FEATURE INTEGRATION POINT
-- Tables for roles, permissions, user roles, etc., will be defined here.
-- Example:
/*
CREATE TABLE [security].[role] (
  [idRole] INT IDENTITY(1,1) NOT NULL,
  [idAccount] INT NOT NULL,
  [name] NVARCHAR(50) NOT NULL,
  [deleted] BIT NOT NULL DEFAULT (0)
);
*/
