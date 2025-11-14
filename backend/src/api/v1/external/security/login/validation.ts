import { z } from 'zod';
import { zEmail } from '@/utils/zodValidation';

export const loginSchema = z.object({
  body: z.object({
    email: zEmail,
    password: z.string().min(1, { message: 'Password is required' }),
    rememberMe: z.boolean().optional().default(false),
  }),
});
