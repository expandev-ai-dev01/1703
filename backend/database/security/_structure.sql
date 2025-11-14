/**
 * @schema security
 * Contains tables related to authentication, authorization, roles, and permissions.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'security')
BEGIN
    EXEC('CREATE SCHEMA security');
END
GO

/**
 * @table {userAccount} Stores user credentials and account status.
 * @multitenancy true
 * @softDelete true
 * @alias ua
 */
CREATE TABLE [security].[userAccount] (
  [idUserAccount] INT IDENTITY(1, 1) NOT NULL,
  [idAccount] INT NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [email] NVARCHAR(255) NOT NULL,
  [passwordHash] NVARCHAR(255) NOT NULL,
  [failedLoginAttempts] INT NOT NULL DEFAULT (0),
  [lockoutUntil] DATETIME2 NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table {loginAttempt} Logs all login attempts for security and auditing.
 * @multitenancy true
 * @softDelete false
 * @alias la
 */
CREATE TABLE [security].[loginAttempt] (
    [idLoginAttempt] BIGINT IDENTITY(1,1) NOT NULL,
    [idAccount] INT NULL, -- Can be null if account doesn't exist for the email
    [idUserAccount] INT NULL, -- Can be null if user doesn't exist
    [emailAttempt] NVARCHAR(255) NOT NULL,
    [ipAddress] VARCHAR(45) NOT NULL,
    [userAgent] NVARCHAR(500) NOT NULL,
    [attemptTime] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
    [status] TINYINT NOT NULL -- 0: Success, 1: Failure (Email), 2: Failure (Password), 3: Failure (Locked)
);
GO

/**
 * @table {userSession} Stores active user sessions.
 * @multitenancy true
 * @softDelete false
 * @alias us
 */
CREATE TABLE [security].[userSession] (
    [idUserSession] BIGINT IDENTITY(1,1) NOT NULL,
    [idAccount] INT NOT NULL,
    [idUserAccount] INT NOT NULL,
    [token] NVARCHAR(1000) NOT NULL,
    [ipAddress] VARCHAR(45) NOT NULL,
    [userAgent] NVARCHAR(500) NOT NULL,
    [expiresAt] DATETIME2 NOT NULL,
    [createdAt] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
    [revokedAt] DATETIME2 NULL
);
GO

-- Constraints for userAccount
/**
 * @primaryKey {pkUserAccount}
 * @keyType Object
 */
ALTER TABLE [security].[userAccount]
ADD CONSTRAINT [pkUserAccount] PRIMARY KEY CLUSTERED ([idUserAccount]);
GO

/**
 * @foreignKey {fkUserAccount_Account} Links user to a specific tenant account.
 * @target {subscription.account}
 */
ALTER TABLE [security].[userAccount]
ADD CONSTRAINT [fkUserAccount_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);
GO

-- Constraints for loginAttempt
/**
 * @primaryKey {pkLoginAttempt}
 * @keyType Object
 */
ALTER TABLE [security].[loginAttempt]
ADD CONSTRAINT [pkLoginAttempt] PRIMARY KEY CLUSTERED ([idLoginAttempt]);
GO

/**
 * @check {chkLoginAttempt_Status} Ensures status is within the defined range.
 * @enum {0} Success
 * @enum {1} Failure (Email not found)
 * @enum {2} Failure (Incorrect Password)
 * @enum {3} Failure (Account Locked)
 */
ALTER TABLE [security].[loginAttempt]
ADD CONSTRAINT [chkLoginAttempt_Status] CHECK ([status] BETWEEN 0 AND 3);
GO

-- Constraints for userSession
/**
 * @primaryKey {pkUserSession}
 * @keyType Object
 */
ALTER TABLE [security].[userSession]
ADD CONSTRAINT [pkUserSession] PRIMARY KEY CLUSTERED ([idUserSession]);
GO

/**
 * @foreignKey {fkUserSession_Account} Links session to a specific tenant account.
 * @target {subscription.account}
 */
ALTER TABLE [security].[userSession]
ADD CONSTRAINT [fkUserSession_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);
GO

/**
 * @foreignKey {fkUserSession_UserAccount} Links session to a specific user.
 * @target {security.userAccount}
 */
ALTER TABLE [security].[userSession]
ADD CONSTRAINT [fkUserSession_UserAccount] FOREIGN KEY ([idUserAccount])
REFERENCES [security].[userAccount]([idUserAccount]);
GO

-- Indexes
/**
 * @index {uqUserAccount_Account_Email} Ensures email is unique per account.
 * @type Search
 * @unique true
 * @filter Excludes soft-deleted records.
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqUserAccount_Account_Email]
ON [security].[userAccount]([idAccount], [email])
WHERE [deleted] = 0;
GO

/**
 * @index {ixLoginAttempt_Email_Time} For quick lookup of recent login attempts for an email.
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixLoginAttempt_Email_Time]
ON [security].[loginAttempt]([emailAttempt], [attemptTime]);
GO

/**
 * @index {ixUserSession_UserAccount} For finding active sessions for a user.
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixUserSession_UserAccount]
ON [security].[userSession]([idUserAccount])
WHERE [revokedAt] IS NULL;
GO
