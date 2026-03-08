import { Request, Response, NextFunction } from 'express';
import { validationResult } from 'express-validator';

// Validates express-validator results and short-circuits with 422 if invalid
export const validate = (req: Request, res: Response, next: NextFunction): void => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    res.status(422).json({ errors: errors.array() });
    return;
  }
  next();
};

// Global error handler — mount last in Express
export const errorHandler = (
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
): void => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error', message: err.message });
};
