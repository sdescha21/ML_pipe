
export enum UserRole {
  CLIENT = 'Client',
  COMPANION = 'Companion',
  BOUNCER = 'Bouncer',
  ADMIN = 'Admin'
}

export interface User {
  id: string;
  name: string;
  avatar: string;
  roles: UserRole[];
  bio: string;
  hourlyRate?: number;
  rating: number;
  reviewCount: number;
  activities?: string[];
  interests?: string[];
  isVerified: boolean;
  isBouncerVerified?: boolean;
  certifications?: string[];
  incidentHistoryCount?: number;
  location?: string;
  city?: string;
  country?: string;
  latitude?: number;
  longitude?: number;
  isBouncer?: boolean;
}

export interface Interest {
  id: string;
  name: string;
  category?: string;
  icon_url?: string;
  emoji?: string;
  description?: string;
  is_active?: boolean;
  popularity_rank?: number;
}

export interface PaymentMethod {
  id: string;
  user_id: string;
  brand: string;
  last4: string;
  exp_month: number;
  exp_year: number;
  is_default: boolean;
  created_at?: string;
  updated_at?: string;
}

export interface Profile {
  id: string;
  auth_id: string;
  full_name: string;
  display_name?: string;
  username?: string;
  email: string;
  phone_number?: string;
  
  // Profile content
  profile_photo_url?: string;
  cover_photo_url?: string;
  avatar_url?: string;
  avatar_storage_path?: string;
  bio?: string;
  headline?: string;
  
  // Demographics
  date_of_birth?: string;
  gender?: string;
  sexual_orientation?: string;
  
  // Location
  city?: string;
  state_province?: string;
  country?: string;
  latitude?: number;
  longitude?: number;
  show_location?: boolean;
  location?: string;
  
  // Interests & Activities
  interests?: string[];
  activities?: string[];
  roles?: string[];
  
  // Verification & Safety
  is_verified?: boolean;
  is_bouncer_verified?: boolean;
  identity_verified?: boolean;
  identity_verification_date?: string;
  id_document_url?: string;
  verification_status?: 'unverified' | 'pending' | 'verified' | 'rejected';
  certifications?: string[];
  incident_history_count?: number;
  
  // Profile visibility & settings
  is_public?: boolean;
  is_discoverable?: boolean;
  show_online_status?: boolean;
  last_active?: string;
  
  // Engagement metrics
  hourly_rate?: number;
  rating?: number;
  review_count?: number;
  profile_views_count?: number;
  likes_received_count?: number;
  reviews_count?: number;
  average_rating?: number;
  
  // Account status
  status?: 'active' | 'inactive' | 'suspended' | 'deleted';
  account_type?: 'standard' | 'premium' | 'verified';
  
  // Timestamps
  created_at?: string;
  updated_at?: string;
  deleted_at?: string;
}

export interface ProfileMedia {
  id: string;
  user_id: string;
  
  // Media info
  media_type: 'image' | 'video';
  media_url: string;
  thumbnail_url?: string;
  storage_path?: string;
  
  // Upload details
  file_name?: string;
  file_size?: number;
  mime_type?: string;
  duration_seconds?: number;
  
  // Metadata
  width?: number;
  height?: number;
  aspect_ratio?: string;
  
  // Display settings
  position_order: number;
  is_visible: boolean;
  caption?: string;
  
  // Content moderation
  is_approved: boolean;
  moderation_status: 'pending' | 'approved' | 'rejected';
  flagged_count: number;
  
  // Engagement
  likes_count: number;
  comments_count: number;
  shares_count: number;
  
  // Timestamps
  created_at: string;
  updated_at: string;
  deleted_at?: string;
}

export interface MediaUpload {
  id: string;
  user_id: string;
  media_id?: string;
  
  // Upload progress
  upload_status: 'pending' | 'uploading' | 'processing' | 'completed' | 'failed';
  progress_percentage: number;
  
  // Processing
  processing_status?: 'queued' | 'processing' | 'completed';
  processing_error?: string;
  
  // Storage
  storage_bucket?: string;
  storage_path?: string;
  storage_provider: 'supabase';
  
  // Timestamps
  created_at: string;
  completed_at?: string;
  expires_at?: string;
}

export interface MediaLike {
  id: string;
  media_id: string;
  liked_by_user_id: string;
  created_at: string;
}

export interface MediaComment {
  id: string;
  media_id: string;
  commented_by_user_id: string;
  comment_text: string;
  is_edited: boolean;
  created_at: string;
  updated_at: string;
  deleted_at?: string;
}

export interface ProfileLike {
  id: string;
  profile_id: string;
  liked_by_user_id: string;
  created_at: string;
}

export interface Activity {
  id: string;
  title: string;
  image: string;
  category: string;
  vibe?: 'Chill' | 'Energetic' | 'Focused' | 'Social';
  price?: number;
}

export interface Booking {
  id: string;
  companion: User;
  bouncer?: User;
  bookerId?: number;
  providerId?: number;
  bouncerId?: number | null;
  date: string;
  time: string;
  duration: number;
  startTime?: string;
  endTime?: string;
  proposedDate?: string | null;
  proposedTime?: string | null;
  status:
    | 'requested'
    | 'pending'
    | 'pending_bouncer'
    | 'proposed'
    | 'approved'
    | 'denied'
    | 'upcoming'
    | 'active'
    | 'completed'
    | 'canceled';
  totalAmount: number;
  escrowStatus: 'held' | 'released' | 'refunded';
}

// Dashboard metrics for user profile modal
export type UserDashboardStats = {
  totalEarnings: number;
  totalBookings: number;
  avgBookingsPerMonth: number;
  totalReviews: number;
  averageRating: number;
  lastBookingDate?: string;
  topActivity?: string;
};
