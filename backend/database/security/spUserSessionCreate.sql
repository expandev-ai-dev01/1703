/**
 * @summary
 * Creates a new user session record upon successful login.
 * 
 * @procedure spUserSessionCreate
 * @schema security
 * @type stored-procedure
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: The account ID.
 * @param {INT} idUserAccount
 *   - Required: Yes
 *   - Description: The user account ID.
 * @param {NVARCHAR(1000)} token
 *   - Required: Yes
 *   - Description: The JWT token for the session.
 * @param {VARCHAR(45)} ipAddress
 *   - Required: Yes
 *   - Description: The IP address of the user.
 * @param {NVARCHAR(500)} userAgent
 *   - Required: Yes
 *   - Description: The user agent of the user's browser.
 * @param {DATETIME2} expiresAt
 *   - Required: Yes
 *   - Description: The expiration timestamp of the token.
 * 
 * @returns {BIGINT} The ID of the newly created session.
 */
CREATE OR ALTER PROCEDURE [security].[spUserSessionCreate]
    @idAccount INT,
    @idUserAccount INT,
    @token NVARCHAR(1000),
    @ipAddress VARCHAR(45),
    @userAgent NVARCHAR(500),
    @expiresAt DATETIME2
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [security].[userSession] 
        ([idAccount], [idUserAccount], [token], [ipAddress], [userAgent], [expiresAt])
    VALUES 
        (@idAccount, @idUserAccount, @token, @ipAddress, @userAgent, @expiresAt);

    SELECT SCOPE_IDENTITY() AS idUserSession;
END;
GO
