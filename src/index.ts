import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { errorHandler } from './shared/middleware/errorHandler';
import { logger } from './shared/utils/logger';
import { db } from './config/database';

// Import feature routes
import { orderRoutes } from './features/ordering';
import { billRoutes } from './features/billing';
import { deliveryRoutes } from './features/delivery';
import { reservationRoutes } from './features/reservations';

// Load environment variables
dotenv.config();

// Create Express application
const app: Application = express();
const PORT = process.env.PORT || 3000;
const API_VERSION = process.env.API_VERSION || 'v1';

// Middleware
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS
app.use(morgan('dev')); // HTTP request logger
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies

// Health check endpoint
app.get('/health', (req: Request, res: Response) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API root
app.get(`/api/${API_VERSION}`, (req: Request, res: Response) => {
  res.json({
    message: 'Restaurant Ordering System API',
    version: API_VERSION,
    features: {
      ordering: `/api/${API_VERSION}/orders`,
      billing: `/api/${API_VERSION}/bills`,
      delivery: `/api/${API_VERSION}/deliveries`,
      reservations: `/api/${API_VERSION}/reservations`
    },
    documentation: '/api/docs'
  });
});

// Feature routes
app.use(`/api/${API_VERSION}/orders`, orderRoutes);
app.use(`/api/${API_VERSION}/bills`, billRoutes);
app.use(`/api/${API_VERSION}/deliveries`, deliveryRoutes);
app.use(`/api/${API_VERSION}/reservations`, reservationRoutes);

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    error: 'Route not found',
    path: req.path
  });
});

// Global error handler (must be last)
app.use(errorHandler);

// Start server
const startServer = async () => {
  try {
    // Initialize database connection
    await db.connect();

    // Start Express server
    app.listen(PORT, () => {
      logger.info(`Server running on port ${PORT}`);
      logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
      logger.info(`API version: ${API_VERSION}`);
      logger.info(`Health check: http://localhost:${PORT}/health`);
      logger.info(`API root: http://localhost:${PORT}/api/${API_VERSION}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Handle uncaught exceptions
process.on('uncaughtException', (error: Error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason: any) => {
  logger.error('Unhandled Rejection:', reason);
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully...');
  await db.disconnect();
  process.exit(0);
});

process.on('SIGINT', async () => {
  logger.info('SIGINT received, shutting down gracefully...');
  await db.disconnect();
  process.exit(0);
});

// Start the server
startServer();

export default app;
