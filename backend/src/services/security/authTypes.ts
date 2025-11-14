export interface LoginRequest {
  email: string;
  password: string;
  rememberMe?: boolean;
  ipAddress: string;
  userAgent: string;
}

export interface UserInfo {
  id: number;
  name: string;
  email: string;
}

export interface LoginResponse {
  token: string;
  user: UserInfo;
}

export interface UserAccount {
  idUserAccount: number;
  idAccount: number;
  name: string;
  email: string;
  passwordHash: string;
  failedLoginAttempts: number;
}

export interface JwtPayload {
  id: number;
  idAccount: number;
  email: string;
}
