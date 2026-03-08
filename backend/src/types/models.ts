// Shared TypeScript types matching the DB schema

export interface User {
  id: number;
  email: string;
  password_hash: string;
  name: string;
  role: 'user' | 'admin';
  created_at: Date;
}

export interface Country {
  id: number;
  code: string;      // e.g. "HK"
  name: string;      // e.g. "Hong Kong"
  flag: string;      // emoji
  currency: string;  // e.g. "HKD"
}

export interface Store {
  id: number;
  country_id: number;
  name: string;
  type: 'local' | 'online';
}

export interface Product {
  id: number;
  name: string;
  brand: string;
  category: string;        // product type
  functionalities: string[];
  description: string;
  ingredients: string[];
  image_url: string;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface ProductAvailability {
  id: number;
  product_id: number;
  country_id: number;
  price: number;
  currency: string;
  store_id: number;
}

export interface Favorite {
  id: number;
  user_id: number;
  product_id: number;
  created_at: Date;
}

export interface Review {
  id: number;
  product_id: number;
  user_id: number;
  rating: number;          // 1–5
  title: string;
  body: string;
  created_at: Date;
  updated_at: Date;
}

// Augmented Express Request type
export interface AuthenticatedRequest extends Express.Request {
  user?: { id: number; email: string; role: string };
}
