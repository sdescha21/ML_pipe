type UserDashboardStats = {
  totalEarnings: number;         // Total money earned by the user
  totalBookings: number;         // Total number of bookings
  avgBookingsPerMonth: number;   // Average bookings per month
  totalReviews: number;          // Total number of reviews received
  averageRating: number;         // Average rating from reviews
  lastBookingDate?: string;      // Date of the most recent booking
  topActivity?: string;          // Most booked activity title
};

{
  "totalEarnings": 1240.50,
  "totalBookings": 32,
  "avgBookingsPerMonth": 4.5,
  "totalReviews": 28,
  "averageRating": 4.8,
  "lastBookingDate": "2026-02-20T14:30:00Z",
  "topActivity": "Coffee Chat"
}
