import { Request, Response, NextFunction } from 'express';
import { successResponse, errorResponse } from '@/utils/responseHandler';
import { loginService } from '@/services/security/authService';
import { LoginRequest } from '@/services/security/authTypes';

/**
 * @api {post} /external/security/login User Login
 * @apiName UserLogin
 * @apiGroup Security
 * @apiVersion 1.0.0
 *
 * @apiDescription Authenticates a user and returns a JWT token upon success.
 *
 * @apiParam {String} email User's email address.
 * @apiParam {String} password User's password.
 * @apiParam {Boolean} [rememberMe] If true, the session token will have a longer expiration.
 *
 * @apiSuccess {Object} data The authentication data.
 * @apiSuccess {String} data.token The JWT authentication token.
 * @apiSuccess {Object} data.user The user's basic information.
 * @apiSuccess {Number} data.user.id The user's ID.
 * @apiSuccess {String} data.user.name The user's name.
 * @apiSuccess {String} data.user.email The user's email.
 *
 * @apiError {String} InvalidCredentials The provided email or password is incorrect.
 * @apiError {String} AccountLocked The account is temporarily locked due to too many failed login attempts.
 * @apiError {String} ValidationError The request body is invalid.
 */
export async function postHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const loginPayload: LoginRequest = req.body;
    const ipAddress = req.ip || 'unknown';
    const userAgent = req.headers['user-agent'] || 'unknown';

    const result = await loginService({
      ...loginPayload,
      ipAddress,
      userAgent,
    });

    res.status(200).json(successResponse(result));
  } catch (error: any) {
    // Custom error handling for login-specific errors
    if (error.message.startsWith('InvalidCredentials')) {
      res.status(401).json(errorResponse('Invalid email or password.'));
    } else if (error.message.startsWith('AccountLocked')) {
      const lockoutTime = error.message.split(':')[1];
      res
        .status(403)
        .json(
          errorResponse(
            `Account is temporarily locked. Please try again later. Lockout until: ${lockoutTime}`
          )
        );
    } else {
      next(error); // Pass to generic error handler
    }
  }
}
