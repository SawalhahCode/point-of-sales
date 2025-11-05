// Common validation utilities

export class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

export const validate = {
  required(value: any, fieldName: string): void {
    if (value === undefined || value === null || value === '') {
      throw new ValidationError(`${fieldName} is required`);
    }
  },

  email(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  },

  phone(phone: string): boolean {
    const phoneRegex = /^\+?[\d\s-()]+$/;
    return phoneRegex.test(phone) && phone.replace(/\D/g, '').length >= 10;
  },

  positiveNumber(value: number, fieldName: string): void {
    if (typeof value !== 'number' || value <= 0) {
      throw new ValidationError(`${fieldName} must be a positive number`);
    }
  },

  minLength(value: string, minLength: number, fieldName: string): void {
    if (!value || value.length < minLength) {
      throw new ValidationError(
        `${fieldName} must be at least ${minLength} characters long`
      );
    }
  },

  maxLength(value: string, maxLength: number, fieldName: string): void {
    if (value && value.length > maxLength) {
      throw new ValidationError(
        `${fieldName} must not exceed ${maxLength} characters`
      );
    }
  },

  isEnum<T>(value: any, enumObj: T, fieldName: string): void {
    const enumValues = Object.values(enumObj as object);
    if (!enumValues.includes(value)) {
      throw new ValidationError(
        `${fieldName} must be one of: ${enumValues.join(', ')}`
      );
    }
  }
};
