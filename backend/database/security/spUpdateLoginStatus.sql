/**
 * @summary
 * Updates the user's login status after a login attempt. It can reset failed attempts on success
 * or increment them and potentially lock the account on failure.
 * 
 * @procedure spUpdateLoginStatus
 * @schema security
 * @type stored-procedure
 * 
 * @parameters
 * @param {INT} idUserAccount
 *   - Required: Yes
 *   - Description: The ID of the user account.
 * @param {BIT} loginSuccess
 *   - Required: Yes
 *   - Description: 1 if the login was successful, 0 otherwise.
 * @param {VARCHAR(45)} ipAddress
 *   - Required: Yes
 *   - Description: The IP address of the login attempt.
 * @param {NVARCHAR(500)} userAgent
 *   - Required: Yes
 *   - Description: The user agent of the login attempt.
 * 
 * @testScenarios
 * - Call with loginSuccess = 1 resets attempts to 0.
 * - Call with loginSuccess = 0 increments attempts.
 * - Fifth consecutive call with loginSuccess = 0 locks the account for 15 minutes.
 */
CREATE OR ALTER PROCEDURE [security].[spUpdateLoginStatus]
    @idUserAccount INT,
    @loginSuccess BIT,
    @ipAddress VARCHAR(45),
    @userAgent NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idAccount INT;
    DECLARE @email NVARCHAR(255);

    SELECT @idAccount = [idAccount], @email = [email] FROM [security].[userAccount] WHERE [idUserAccount] = @idUserAccount;

    IF @loginSuccess = 1
    BEGIN
        -- Reset failed attempts and clear lockout on success
        UPDATE [security].[userAccount]
        SET 
            [failedLoginAttempts] = 0,
            [lockoutUntil] = NULL,
            [dateModified] = GETUTCDATE()
        WHERE [idUserAccount] = @idUserAccount;

        INSERT INTO [security].[loginAttempt] ([idAccount], [idUserAccount], [emailAttempt], [ipAddress], [userAgent], [status])
        VALUES (@idAccount, @idUserAccount, @email, @ipAddress, @userAgent, 0); -- 0: Success
    END
    ELSE
    BEGIN
        -- Increment failed attempts and check for lockout
        DECLARE @newAttemptCount INT;

        UPDATE [security].[userAccount]
        SET 
            [failedLoginAttempts] = [failedLoginAttempts] + 1,
            [dateModified] = GETUTCDATE()
        WHERE [idUserAccount] = @idUserAccount;

        SELECT @newAttemptCount = [failedLoginAttempts] FROM [security].[userAccount] WHERE [idUserAccount] = @idUserAccount;

        IF @newAttemptCount >= 5
        BEGIN
            UPDATE [security].[userAccount]
            SET [lockoutUntil] = DATEADD(MINUTE, 15, GETUTCDATE())
            WHERE [idUserAccount] = @idUserAccount;
        END

        INSERT INTO [security].[loginAttempt] ([idAccount], [idUserAccount], [emailAttempt], [ipAddress], [userAgent], [status])
        VALUES (@idAccount, @idUserAccount, @email, @ipAddress, @userAgent, 2); -- 2: Failure (Password)
    END
END;
GO
