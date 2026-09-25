export interface User {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phone: string | null;
  role: string;
  isHost: boolean;
  isVerified: boolean;
  profilePhotoUrl: string | null;
  createdAt: string;
}

export interface LoginResponse {
  user: User;
  accessToken: string;
}

export interface PropertyImage {
  id: string;
  imageUrl: string;
  displayOrder: number;
  isCover: boolean;
}

export interface Amenity {
  id: string;
  name: string;
  icon: string | null;
}

export interface PropertyAmenity {
  amenity: Amenity;
}

export interface HostSummary {
  id: string;
  firstName: string;
  lastName: string;
  isVerified: boolean;
  profilePhotoUrl: string | null;
}

export interface Property {
  id: string;
  hostId: string;
  title: string;
  description: string;
  address: string;
  city: string;
  state: string;
  country: string;
  pricePerNight: string; // Decimal serialized as string
  bedrooms: number;
  bathrooms: number;
  maxGuests: number;
  status: string;
  images: PropertyImage[];
  amenities?: PropertyAmenity[];
  host?: HostSummary;
  averageRating?: number;
  reviewCount?: number;
}

export interface PropertySearchResponse {
  data: Property[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export type BookingStatus =
  | 'PENDING'
  | 'AWAITING_HOST'
  | 'CONFIRMED'
  | 'DECLINED'
  | 'CANCELLED'
  | 'COMPLETED'
  | 'REFUNDED'
  | 'EXPIRED';

export interface Booking {
  id: string;
  propertyId: string;
  guestId: string;
  checkIn: string;
  checkOut: string;
  guestCount: number;
  nightlyRate: string;
  subtotal: string;
  serviceFee: string;
  total: string;
  currency: string;
  status: BookingStatus;
  createdAt: string;
  updatedAt: string;
  property: Property;
  review?: Review | null;
}

export interface ReviewUser {
  id: string;
  firstName: string;
  lastName: string;
  profilePhotoUrl: string | null;
}

export interface Review {
  id: string;
  bookingId: string;
  propertyId: string;
  userId: string;
  rating: number;
  comment: string | null;
  createdAt: string;
  user?: ReviewUser;
  property?: { id: string; title: string };
}

export interface PropertyReviewsResponse {
  property: { id: string; title: string };
  summary: { averageRating: number; reviewCount: number };
  reviews: Review[];
}

export interface ConversationMessage {
  id: string;
  conversationId: string;
  senderId: string;
  message: string;
  createdAt: string;
  readAt: string | null;
}

export interface Conversation {
  id: string;
  propertyId: string;
  bookingId: string | null;
  guestId: string;
  hostId: string;
  createdAt: string;
  updatedAt: string;
  property: {
    id: string;
    title: string;
    city: string;
    state: string;
    images: PropertyImage[];
  };
  booking: {
    id: string;
    checkIn: string;
    checkOut: string;
    status: BookingStatus;
  } | null;
  guest: ReviewUser;
  host: ReviewUser;
  messages?: ConversationMessage[];
  lastMessage?: ConversationMessage | null;
  unreadCount?: number;
}

export interface SavedStay {
  id: string;
  propertyId: string;
  createdAt: string;
  property: Property;
}

export class ApiError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}
