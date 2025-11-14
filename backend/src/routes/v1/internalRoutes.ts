import { Router } from 'express';
import { authMiddleware } from '@/middleware/authMiddleware';

const router = Router();

// All internal routes are protected by the auth middleware
router.use(authMiddleware);

// FEATURE INTEGRATION POINT
// Example: import userRoutes from '@/api/v1/internal/users/routes';
// router.use('/users', userRoutes);

export default router;
