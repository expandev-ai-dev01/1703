import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { executeProcedure } from '@/utils/database';
import { config } from '@/config';
import { LoginRequest, LoginResponse, UserAccount, JwtPayload } from './authTypes';

/**
 * @summary
 * Handles the business logic for user authentication.
 *
 * @param {LoginRequest} params - The login request parameters.
 * @returns {Promise<LoginResponse>} The authentication token and user info.
 * @throws {Error} If login fails due to invalid credentials or a locked account.
 */
export async function loginService(params: LoginRequest): Promise<LoginResponse> {
  const { email, password, rememberMe, ipAddress, userAgent } = params;

  // 1. Fetch user data from the database
  const userResult = await executeProcedure('[security].[spUserAccountLogin]', {
    email,
    password, // Note: Password is not used in this SP, but passed for consistency
    ipAddress,
    userAgent,
  });

  const user: UserAccount | undefined = userResult[0];

  // 2. Handle user not found or locked account (errors are raised by the SP)
  if (!user) {
    // This case is primarily handled by the SP raising an error, but as a fallback:
    throw new Error('InvalidCredentials');
  }

  // 3. Compare password
  const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

  // 4. Update login status in DB (success or failure)
  await executeProcedure('[security].[spUpdateLoginStatus]', {
    idUserAccount: user.idUserAccount,
    loginSuccess: isPasswordValid,
    ipAddress,
    userAgent,
  });

  if (!isPasswordValid) {
    throw new Error('InvalidCredentials');
  }

  // 5. Generate JWT
  const expiresIn = rememberMe ? config.jwt.rememberMeExpiresIn : config.jwt.expiresIn;
  const payload: JwtPayload = {
    id: user.idUserAccount,
    idAccount: user.idAccount,
    email: user.email,
  };

  const token = jwt.sign(payload, config.jwt.secret, { expiresIn });

  // 6. Create a session record
  const decodedToken = jwt.decode(token) as { exp?: number };
  const expiresAt = decodedToken?.exp ? new Date(decodedToken.exp * 1000) : new Date();

  await executeProcedure('[security].[spUserSessionCreate]', {
    idAccount: user.idAccount,
    idUserAccount: user.idUserAccount,
    token,
    ipAddress,
    userAgent,
    expiresAt,
  });

  // 7. Return response
  return {
    token,
    user: {
      id: user.idUserAccount,
      name: user.name,
      email: user.email,
    },
  };
}
