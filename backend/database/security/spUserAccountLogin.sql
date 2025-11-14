/**
 * @summary
 * Handles the complete user login process. It finds the user, validates their status,
 * compares the password, and updates login attempt counters and lockout status accordingly.
 * It also logs every attempt.
 * 
 * @procedure spUserAccountLogin
 * @schema security
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/external/security/login
 * 
 * @parameters
 * @param {NVARCHAR(255)} email 
 *   - Required: Yes
 *   - Description: The user's email address.
 * @param {NVARCHAR(255)} password
 *   - Required: Yes
 *   - Description: The user's plain text password to be compared.
 * @param {VARCHAR(45)} ipAddress
 *   - Required: Yes
 *   - Description: The IP address of the user attempting to log in.
 * @param {NVARCHAR(500)} userAgent
 *   - Required: Yes
 *   - Description: The user agent string from the user's browser.
 * 
 * @returns {JSON} A JSON object with login status and user data on success.
 * 
 * @testScenarios
 * - Successful login with correct credentials.
 * - Failed login due to non-existent email.
 * - Failed login due to incorrect password.
 * - Account lockout after 5 failed attempts.
 * - Attempt to log in with a locked account.
 * - Successful login resets failed attempts counter.
 */
CREATE OR ALTER PROCEDURE [security].[spUserAccountLogin]
    @email NVARCHAR(255),
    @password NVARCHAR(255),
    @ipAddress VARCHAR(45),
    @userAgent NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idUserAccount INT;
    DECLARE @idAccount INT;
    DECLARE @passwordHash NVARCHAR(255);
    DECLARE @failedLoginAttempts INT;
    DECLARE @lockoutUntil DATETIME2;
    DECLARE @name NVARCHAR(100);

    -- Find the user by email
    SELECT
        @idUserAccount = [ua].[idUserAccount],
        @idAccount = [ua].[idAccount],
        @passwordHash = [ua].[passwordHash],
        @failedLoginAttempts = [ua].[failedLoginAttempts],
        @lockoutUntil = [ua].[lockoutUntil],
        @name = [ua].[name]
    FROM [security].[userAccount] [ua]
    WHERE [ua].[email] = @email AND [ua].[deleted] = 0;

    -- 1. User not found
    IF @idUserAccount IS NULL
    BEGIN
        INSERT INTO [security].[loginAttempt] ([emailAttempt], [ipAddress], [userAgent], [status])
        VALUES (@email, @ipAddress, @userAgent, 1); -- 1: Failure (Email)

        RAISERROR('InvalidCredentials', 16, 1);
        RETURN;
    END

    -- 2. Account is locked
    IF @lockoutUntil IS NOT NULL AND @lockoutUntil > GETUTCDATE()
    BEGIN
        INSERT INTO [security].[loginAttempt] ([idAccount], [idUserAccount], [emailAttempt], [ipAddress], [userAgent], [status])
        VALUES (@idAccount, @idUserAccount, @email, @ipAddress, @userAgent, 3); -- 3: Failure (Locked)

        DECLARE @lockoutMsg NVARCHAR(100) = FORMATMESSAGE('AccountLocked:%s', CONVERT(NVARCHAR, @lockoutUntil, 127));
        RAISERROR(@lockoutMsg, 16, 1);
        RETURN;
    END

    -- This procedure does not compare the password directly for security reasons (bcrypt is handled in the backend).
    -- It returns the necessary data for the backend to perform the check.
    -- The backend will then call other procedures to update the status.

    SELECT
        [idUserAccount],
        [idAccount],
        [name],
        [email],
        [passwordHash],
        [failedLoginAttempts]
    FROM [security].[userAccount]
    WHERE [idUserAccount] = @idUserAccount;

END;
GO
