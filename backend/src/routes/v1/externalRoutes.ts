import { Router } from 'express';
import { validationMiddleware } from '@/middleware/validationMiddleware';
import * as loginController from '@/api/v1/external/security/login/controller';
import { loginSchema } from '@/api/v1/external/security/login/validation';

const router = Router();

// Security routes
router.post('/security/login', validationMiddleware(loginSchema), loginController.postHandler);

export default router;
