import { z } from 'zod';

// Base string with min/max length
export const zString = (min = 1, max = 255) =>
  z
    .string()
    .min(min, { message: `Must be ${min} or more characters long` })
    .max(max, { message: `Must be ${max} or fewer characters long` });

// Common named elements
export const zName = zString(1, 100);
export const zDescription = zString(1, 500);
export const zNullableDescription = zDescription.nullable();

// Foreign Keys (ID)
export const zFK = z.number().int().positive({ message: 'Must be a positive integer' });
export const zNullableFK = zFK.nullable();

// Bit/Boolean
export const zBit = z.boolean();

// Email
export const zEmail = z.string().email({ message: 'Invalid email address' });
