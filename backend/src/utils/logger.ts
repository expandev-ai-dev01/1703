/**
 * @summary Basic logger utility.
 * @description A simple wrapper around console logging. Can be replaced with a more
 * robust logging library like Winston or Pino for production environments.
 */
export const logger = {
  info: (message: string, ...args: any[]): void => {
    console.log(`[INFO] ${new Date().toISOString()}: ${message}`, ...args);
  },
  warn: (message: string, ...args: any[]): void => {
    console.warn(`[WARN] ${new Date().toISOString()}: ${message}`, ...args);
  },
  error: (message: string, ...args: any[]): void => {
    console.error(`[ERROR] ${new Date().toISOString()}: ${message}`, ...args);
  },
};
