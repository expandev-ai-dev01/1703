interface SuccessResponse<T> {
  success: true;
  data: T;
  timestamp: string;
}

interface ErrorResponse {
  success: false;
  error: {
    message: string;
    details?: any;
  };
  timestamp: string;
}

/**
 * @summary Creates a standardized success response object.
 * @param data The payload to be included in the response.
 * @returns A success response object.
 */
export const successResponse = <T>(data: T): SuccessResponse<T> => ({
  success: true,
  data,
  timestamp: new Date().toISOString(),
});

/**
 * @summary Creates a standardized error response object.
 * @param message The error message.
 * @param details Optional additional details about the error.
 * @returns An error response object.
 */
export const errorResponse = (message: string, details?: any): ErrorResponse => ({
  success: false,
  error: {
    message,
    details,
  },
  timestamp: new Date().toISOString(),
});
