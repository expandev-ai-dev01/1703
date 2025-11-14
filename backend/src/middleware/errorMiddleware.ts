import { Request, Response, NextFunction } from 'express';
import { logger } from '@/utils/logger';
import { errorResponse } from '@/utils/responseHandler';

/**
 * @summary Centralized error handling middleware.
 * @description Catches errors from route handlers and middleware, logs them,
 * and sends a standardized 500 Internal Server Error response.
 */
export function errorMiddleware(
  err: Error,
  req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  next: NextFunction
): void {
  logger.error('An unexpected error occurred', {
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  res.status(500).json(errorResponse('Internal Server Error'));
}
