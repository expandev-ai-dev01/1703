import { Request, Response } from 'express';
import { errorResponse } from '@/utils/responseHandler';

/**
 * @summary Handles requests to non-existent routes.
 * @description Responds with a 404 Not Found error for any request that
 * doesn't match a defined route.
 */
export function notFoundMiddleware(req: Request, res: Response): void {
  res.status(404).json(errorResponse(`Not Found: ${req.method} ${req.originalUrl}`));
}
