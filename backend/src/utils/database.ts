import sql, { IRecordSet, ConnectionPool } from 'mssql';
import { config } from '@/config';
import { logger } from './logger';

const sqlConfig: sql.config = {
  server: config.database.server,
  port: config.database.port,
  user: config.database.user,
  password: config.database.password,
  database: config.database.database,
  options: {
    encrypt: config.database.options.encrypt,
    trustServerCertificate: config.database.options.trustServerCertificate,
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000,
  },
};

let pool: ConnectionPool;

/**
 * @summary Establishes and returns a singleton connection pool to the database.
 * @returns {Promise<ConnectionPool>} The SQL Server connection pool.
 */
export const getPool = async (): Promise<ConnectionPool> => {
  if (pool && pool.connected) {
    return pool;
  }
  try {
    pool = await new ConnectionPool(sqlConfig).connect();
    logger.info('Database connection pool established.');
    pool.on('error', (err) => {
      logger.error('Database pool error', err);
    });
    return pool;
  } catch (err) {
    logger.error('Failed to establish database connection pool', err);
    process.exit(1);
  }
};

/**
 * @summary Executes a stored procedure with the given parameters.
 * @param {string} procedureName The name of the stored procedure to execute.
 * @param {object} params An object containing the input parameters for the procedure.
 * @returns {Promise<IRecordSet<any>>} The result from the database.
 */
export const executeProcedure = async (
  procedureName: string,
  params: { [key: string]: any }
): Promise<IRecordSet<any>> => {
  const pool = await getPool();
  const request = pool.request();

  for (const key in params) {
    if (Object.prototype.hasOwnProperty.call(params, key)) {
      request.input(key, params[key]);
    }
  }

  const result = await request.execute(procedureName);
  return result.recordset;
};
