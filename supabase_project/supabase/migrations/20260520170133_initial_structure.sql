create schema if not exists "drizzle";

create extension if not exists "pg_net" with schema "public";

create extension if not exists "postgis" with schema "public";

create extension if not exists "vector" with schema "public";

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON t.typnamespace = n.oid
    WHERE t.typname = 'booking_status' AND n.nspname = 'public'
  ) THEN
    CREATE TYPE public.booking_status AS enum ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled', 'disputed');
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON t.typnamespace = n.oid
    WHERE t.typname = 'bud_direction' AND n.nspname = 'public'
  ) THEN
    CREATE TYPE public.bud_direction AS enum ('user', 'bud');
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON t.typnamespace = n.oid
    WHERE t.typname = 'entity_type' AND n.nspname = 'public'
  ) THEN
    CREATE TYPE public.entity_type AS enum ('event', 'companion', 'service');
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON t.typnamespace = n.oid
    WHERE t.typname = 'event_status' AND n.nspname = 'public'
  ) THEN
    CREATE TYPE public.event_status AS enum ('draft', 'published', 'completed', 'cancelled');
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON t.typnamespace = n.oid
    WHERE t.typname = 'moderation_status' AND n.nspname = 'public'
  ) THEN
    CREATE TYPE public.moderation_status AS enum ('pending', 'approved', 'flagged', 'removed');
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON t.typnamespace = n.oid
    WHERE t.typname = 'plan_tier' AND n.nspname = 'public'
  ) THEN
    CREATE TYPE public.plan_tier AS enum ('free', 'starter', 'growth', 'scale', 'enterprise');
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON t.typnamespace = n.oid
    WHERE t.typname = 'user_role' AND n.nspname = 'public'
  ) THEN
    CREATE TYPE public.user_role AS enum ('user', 'provider', 'host', 'companion', 'admin');
  END IF;
END$$;

create sequence "drizzle"."__drizzle_migrations_id_seq";

create sequence "public"."activities_id_seq";

create sequence "public"."activity_bookings_id_seq";

create sequence "public"."activity_reviews_id_seq";

create sequence "public"."adminLogs_id_seq";

create sequence "public"."availability_id_seq";

create sequence "public"."bookingBouncers_id_seq";

create sequence "public"."bookings_id_seq";

create sequence "public"."bouncer_services_id_seq";

create sequence "public"."companion_activities_id_seq";

create sequence "public"."companion_services_id_seq";

create sequence "public"."conversations_id_seq";

create sequence "public"."earnings_id_seq";

create sequence "public"."event_registrations_id_seq";

create sequence "public"."events_id_seq";

create sequence "public"."favorites_id_seq";

create sequence "public"."group_conversation_members_id_seq";

create sequence "public"."group_conversations_id_seq";

create sequence "public"."group_messages_id_seq";

create sequence "public"."messages_id_seq";

create sequence "public"."notifications_id_seq";

create sequence "public"."panicEvents_id_seq";

create sequence "public"."payments_id_seq";

create sequence "public"."photos_id_seq";

create sequence "public"."profiles_id_seq";

create sequence "public"."reports_id_seq";

create sequence "public"."reviews_id_seq";

create sequence "public"."roles_id_seq";

create sequence "public"."safetyFlags_id_seq";

create sequence "public"."service_availability_id_seq";

create sequence "public"."service_bookings_id_seq";

create sequence "public"."service_reviews_id_seq";

create sequence "public"."services_id_seq";

create sequence "public"."subscriptions_id_seq";

create sequence "public"."users_id_seq";

create sequence "public"."verificationAudits_id_seq";

create sequence "public"."verificationRequests_id_seq";

create sequence "public"."waitlist_id_seq";

create sequence "public"."webrtc_signals_id_seq";


  create table "drizzle"."__drizzle_migrations" (
    "id" integer not null default nextval('drizzle.__drizzle_migrations_id_seq'::regclass),
    "hash" text not null,
    "created_at" bigint
      );



  create table "public"."account_activity_log" (
    "id" uuid not null default gen_random_uuid(),
    "profile_id" integer not null,
    "action" text not null,
    "details" jsonb,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."account_activity_log" enable row level security;


  create table "public"."activities" (
    "id" integer not null default nextval('public.activities_id_seq'::regclass),
    "userId" integer not null,
    "title" character varying(255) not null,
    "description" text,
    "category" character varying(100) not null,
    "hourlyRate" numeric(8,2) not null,
    "minHours" integer not null default 1,
    "maxHours" integer not null default 8,
    "location" character varying(255),
    "isRemote" boolean not null default false,
    "photoUrls" jsonb not null,
    "isActive" boolean not null default true,
    "createdAt" timestamp without time zone not null default now(),
    "updatedAt" timestamp without time zone not null default now(),
    "image" text,
    "vibe" text,
    "price" numeric,
    "host_id" integer,
    "media_urls" text[] default '{}'::text[],
    "thumbnail_url" text,
    "duration_hours" numeric,
    "is_featured" boolean default false,
    "view_count" integer default 0
      );


alter table "public"."activities" enable row level security;


  create table "public"."activities_media" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "activity_id" integer not null,
    "media_url" text not null,
    "storage_path" text not null,
    "media_type" text not null,
    "position_order" integer default 0,
    "caption" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."activities_media" enable row level security;


  create table "public"."activity_bookings" (
    "id" bigint not null default nextval('public.activity_bookings_id_seq'::regclass),
    "activity_id" bigint not null,
    "user_id" bigint not null,
    "booking_date" timestamp with time zone,
    "payment_status" character varying(50) default 'pending'::character varying,
    "amount" numeric(10,2) not null,
    "payment_intent_id" character varying(255),
    "status" character varying(50) default 'upcoming'::character varying,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "booked_slots" integer default 1,
    "tax_rate" numeric(6,4) default 0.15,
    "tax_amount" numeric(10,2) default 0,
    "platform_fee_rate" numeric(6,4) default 0.0999,
    "platform_fee_amount" numeric(10,2) default 0,
    "total_amount" numeric(10,2),
    "cancelled_at" timestamp with time zone,
    "host_profile_id" bigint,
    "host_payout_status" text default 'locked'::text,
    "host_payout_locked_reason" text,
    "host_payout_eligible" boolean default false,
    "subtotal_amount" numeric(10,2),
    "notes" text
      );


alter table "public"."activity_bookings" enable row level security;


  create table "public"."activity_reviews" (
    "id" bigint not null default nextval('public.activity_reviews_id_seq'::regclass),
    "booking_id" bigint not null,
    "activity_id" bigint not null,
    "reviewer_id" bigint not null,
    "companion_id" bigint not null,
    "rating" integer not null,
    "review" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."activity_reviews" enable row level security;


  create table "public"."activity_shares" (
    "id" uuid not null default gen_random_uuid(),
    "activity_id" bigint not null,
    "shared_by" integer,
    "platform" text not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."activity_shares" enable row level security;


  create table "public"."activity_views" (
    "id" uuid not null default gen_random_uuid(),
    "activity_id" bigint not null,
    "viewed_by" integer,
    "view_source" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."activity_views" enable row level security;


  create table "public"."adminLogs" (
    "id" integer not null default nextval('public."adminLogs_id_seq"'::regclass),
    "actorId" integer,
    "action" character varying(255) not null,
    "entityType" character varying(100),
    "entityId" integer,
    "meta" jsonb not null default '{}'::jsonb,
    "createdAt" timestamp without time zone not null default now()
      );


alter table "public"."adminLogs" enable row level security;


  create table "public"."admin_access_emails" (
    "email" text not null,
    "created_at" timestamp with time zone not null default now(),
    "added_by" uuid,
    "note" text
      );


alter table "public"."admin_access_emails" enable row level security;


  create table "public"."api_keys" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone default now(),
    "client_name" text not null,
    "api_key_hash" text not null,
    "plan" text default 'free'::text,
    "monthly_limit" integer default 500,
    "current_month_usage" integer default 0,
    "usage_reset_at" timestamp with time zone default (date_trunc('month'::text, now()) + '1 mon'::interval),
    "webhook_url" text,
    "functions_schema" jsonb default '[]'::jsonb,
    "lemonsqueezy_customer_id" text,
    "enabled" boolean default true,
    "last_used_at" timestamp with time zone
      );


alter table "public"."api_keys" enable row level security;


  create table "public"."availability" (
    "id" integer not null default nextval('public.availability_id_seq'::regclass),
    "userId" integer not null,
    "dayOfWeek" integer not null,
    "startTime" character varying(5) not null,
    "endTime" character varying(5) not null,
    "isActive" boolean not null default true,
    "createdAt" timestamp without time zone not null default now(),
    "updatedAt" timestamp without time zone not null default now()
      );


alter table "public"."availability" enable row level security;


  create table "public"."availability_slots" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "profile_id" integer not null,
    "day_of_week" text not null,
    "start_time" text not null,
    "end_time" text not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."availability_slots" enable row level security;


  create table "public"."blocked_dates" (
    "id" uuid not null default gen_random_uuid(),
    "profile_id" integer not null,
    "blocked_date" date not null,
    "reason" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."blocked_dates" enable row level security;


  create table "public"."bookingBouncers" (
    "id" integer not null default nextval('public."bookingBouncers_id_seq"'::regclass),
    "bookingId" integer not null,
    "bouncerId" integer not null,
    "rate" numeric(10,2),
    "confirmed" boolean not null default false,
    "createdAt" timestamp without time zone not null default now()
      );


alter table "public"."bookingBouncers" enable row level security;


  create table "public"."booking_review_audit_log" (
    "id" bigint generated always as identity not null,
    "entity_type" text not null,
    "entity_id" uuid not null,
    "action" text not null,
    "actor_profile_id" bigint,
    "old_row" jsonb,
    "new_row" jsonb,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."booking_review_audit_log" enable row level security;


  create table "public"."booking_review_flags" (
    "id" bigint generated always as identity not null,
    "review_id" uuid,
    "flag_type" text not null,
    "flag_reason" text not null,
    "severity" smallint not null default 1,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."booking_review_flags" enable row level security;


  create table "public"."booking_review_helpful_votes" (
    "review_id" uuid not null,
    "voter_profile_id" bigint not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."booking_review_helpful_votes" enable row level security;


  create table "public"."booking_review_media" (
    "id" uuid not null default gen_random_uuid(),
    "review_id" uuid not null,
    "reviewer_profile_id" bigint not null,
    "storage_path" text not null,
    "public_url" text,
    "mime" text,
    "size_bytes" bigint,
    "moderation_status" text not null default 'pending'::text,
    "moderation_reasons" text[] not null default '{}'::text[],
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."booking_review_media" enable row level security;


  create table "public"."booking_review_responses" (
    "id" uuid not null default gen_random_uuid(),
    "review_id" uuid not null,
    "responder_profile_id" bigint not null,
    "body" text not null,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."booking_review_responses" enable row level security;


  create table "public"."booking_reviews" (
    "id" uuid not null default gen_random_uuid(),
    "booking_id" text not null,
    "reviewer_profile_id" bigint not null,
    "reviewee_profile_id" bigint not null,
    "rating" smallint,
    "body" text,
    "status" text not null default 'draft'::text,
    "submitted_at" timestamp with time zone,
    "revealed_at" timestamp with time zone,
    "moderation_status" text not null default 'pending'::text,
    "moderation_reasons" text[] not null default '{}'::text[],
    "moderated_at" timestamp with time zone,
    "moderated_by" bigint,
    "counts_toward_rating" boolean not null default true,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "communication_rating" integer,
    "punctuality_rating" integer,
    "experience_rating" integer,
    "overall_rating" integer,
    "review_text" text,
    "activity_booking_id" bigint,
    "photo_url" text
      );


alter table "public"."booking_reviews" enable row level security;


  create table "public"."booking_status_history" (
    "id" uuid not null default gen_random_uuid(),
    "booking_id" integer not null,
    "from_status" text,
    "to_status" text not null,
    "changed_by" integer,
    "notes" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."booking_status_history" enable row level security;


  create table "public"."bookings" (
    "id" integer not null default nextval('public.bookings_id_seq'::regclass),
    "activityId" integer,
    "bookerId" integer not null,
    "providerId" integer not null,
    "startTime" timestamp without time zone,
    "endTime" timestamp without time zone,
    "durationHours" numeric(5,2),
    "hourlyRate" numeric(8,2),
    "totalPrice" numeric(10,2),
    "status" text not null default 'requested'::text,
    "cancellationReason" text,
    "cancelledBy" integer,
    "cancelledAt" timestamp without time zone,
    "bookerNotes" text,
    "providerNotes" text,
    "createdAt" timestamp without time zone not null default now(),
    "updatedAt" timestamp without time zone not null default now(),
    "bouncerId" integer,
    "companionFee" numeric(10,2),
    "bouncerFee" numeric(10,2),
    "platformFee" numeric(10,2),
    "companion_id" integer,
    "bouncer_id" integer,
    "client_id" integer,
    "proposed_date" date,
    "proposed_time" text,
    "alternative_proposal_by" uuid,
    "start_time" timestamp with time zone,
    "end_time" timestamp with time zone,
    "cancellation_requested_at" timestamp with time zone,
    "cancellation_requested_by" integer,
    "cancellation_reason" text,
    "cancelled_at" timestamp with time zone,
    "cancellation_fee" numeric(10,2) default 0,
    "refund_amount" numeric(10,2) default 0,
    "reschedule_requested_at" timestamp with time zone,
    "reschedule_requested_by" integer,
    "reschedule_count" integer default 0,
    "original_start_time" timestamp with time zone,
    "previous_dates" jsonb default '[]'::jsonb,
    "completed_at" timestamp with time zone,
    "in_progress_at" timestamp with time zone,
    "duration" integer default 1,
    "hours" integer,
    "hourly_rate" numeric(10,2),
    "bouncer_hourly_rate" numeric(10,2),
    "subtotal_amount" numeric(10,2),
    "tax_rate" numeric(6,4),
    "tax_amount" numeric(10,2),
    "platform_fee_client_rate" numeric(6,4),
    "platform_fee_client_amount" numeric(10,2),
    "platform_fee_companion_rate" numeric(6,4),
    "platform_fee_companion_amount" numeric(10,2),
    "platform_fee_bouncer_rate" numeric(6,4),
    "platform_fee_bouncer_amount" numeric(10,2),
    "duration_hours" numeric(6,2),
    "payment_status" text default 'unpaid'::text
      );


alter table "public"."bookings" enable row level security;


  create table "public"."bookings_v2" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "entity_id" uuid not null,
    "entity_type" public.entity_type not null,
    "status" public.booking_status default 'pending'::public.booking_status,
    "amount_cents" integer default 0,
    "helcium_payment_ref" text,
    "starts_at" timestamp with time zone,
    "ends_at" timestamp with time zone,
    "special_instructions" text,
    "confirmed_at" timestamp with time zone,
    "completed_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."bookings_v2" enable row level security;


  create table "public"."bouncer_services" (
    "id" integer not null default nextval('public.bouncer_services_id_seq'::regclass),
    "profile_id" integer not null,
    "service_type" text not null,
    "pricing" numeric(10,2),
    "currency" text default 'USD'::text,
    "availability_notes" text,
    "use_global_availability" boolean default true,
    "specific_slots" jsonb default '[]'::jsonb,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."bouncer_services" enable row level security;


  create table "public"."bud_api_keys" (
    "id" uuid not null default gen_random_uuid(),
    "client_name" text not null,
    "api_key_hash" text not null,
    "plan" public.plan_tier default 'free'::public.plan_tier,
    "monthly_limit" integer default 500,
    "current_month_usage" integer default 0,
    "usage_reset_at" timestamp with time zone default (date_trunc('month'::text, now()) + '1 mon'::interval),
    "webhook_url" text,
    "functions_schema" jsonb default '[]'::jsonb,
    "lemonsqueezy_customer_id" text,
    "enabled" boolean default true,
    "last_used_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."bud_conversations" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone default now(),
    "user_id" integer not null,
    "session_id" text not null,
    "turn_number" integer default 0,
    "direction" text not null,
    "transcript" text,
    "function_called" text,
    "function_result" jsonb,
    "latency_ms" integer,
    "language" text default 'en'::text,
    "model_used" text default 'groq/llama-3.1-8b-instant'::text,
    "tenant_id" uuid,
    "message" text,
    "reply" text,
    "source" text,
    "cost_estimate" numeric(10,6)
      );


alter table "public"."bud_conversations" enable row level security;


  create table "public"."bud_conversations_v2" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "api_key_id" uuid,
    "session_id" text not null,
    "turn_number" integer default 0,
    "direction" public.bud_direction not null,
    "transcript" text,
    "function_called" text,
    "function_result" jsonb,
    "latency_ms" integer,
    "language" text default 'en'::text,
    "model_used" text default 'groq/qwen2.5-7b'::text,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."call_ice_candidates" (
    "id" uuid not null default gen_random_uuid(),
    "call_log_id" uuid not null,
    "sender_profile_id" bigint not null,
    "candidate" jsonb not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."call_ice_candidates" enable row level security;


  create table "public"."call_logs" (
    "id" uuid not null default gen_random_uuid(),
    "conversation_id" bigint not null,
    "caller_profile_id" bigint not null,
    "callee_profile_id" bigint not null,
    "status" text not null default 'initiated'::text,
    "started_at" timestamp with time zone not null default now(),
    "answered_at" timestamp with time zone,
    "ended_at" timestamp with time zone,
    "duration_seconds" integer generated always as (
CASE
    WHEN ((answered_at IS NOT NULL) AND (ended_at IS NOT NULL)) THEN (EXTRACT(epoch FROM (ended_at - answered_at)))::integer
    ELSE NULL::integer
END) stored,
    "created_at" timestamp with time zone not null default now(),
    "offer_sdp" jsonb,
    "answer_sdp" jsonb,
    "last_signal_at" timestamp with time zone
      );


alter table "public"."call_logs" enable row level security;


  create table "public"."call_transcripts" (
    "id" uuid not null default gen_random_uuid(),
    "call_log_id" uuid,
    "profile_id" integer,
    "text" text not null default ''::text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."call_transcripts" enable row level security;


  create table "public"."campaigns" (
    "id" uuid not null default gen_random_uuid(),
    "profile_id" bigint not null,
    "activity_id" bigint,
    "name" text not null,
    "description" text,
    "status" text not null default 'draft'::text,
    "start_date" date,
    "end_date" date,
    "budget_cents" integer not null default 0,
    "currency_code" text not null default 'USD'::text,
    "metadata" jsonb not null default '{}'::jsonb,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."campaigns" enable row level security;


  create table "public"."cc_activities" (
    "id" uuid not null default gen_random_uuid(),
    "facility_id" uuid,
    "title" text not null,
    "activity_type" text,
    "scheduled_at" timestamp with time zone not null,
    "duration_min" integer default 45,
    "capacity" integer,
    "companion_id" uuid,
    "resident_count" integer default 0,
    "status" text default 'scheduled'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."cc_activities" enable row level security;


  create table "public"."cc_activity_attendance" (
    "id" uuid not null default gen_random_uuid(),
    "activity_id" uuid,
    "resident_id" uuid,
    "attended" boolean default true,
    "session_notes" text
      );


alter table "public"."cc_activity_attendance" enable row level security;


  create table "public"."cc_activity_templates" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "description" text,
    "category" text,
    "duration_minutes" integer default 60,
    "materials" text[],
    "suitable_for" text[],
    "created_at" timestamp with time zone default now()
      );


alter table "public"."cc_activity_templates" enable row level security;


  create table "public"."cc_admin_users" (
    "id" uuid not null default gen_random_uuid(),
    "facility_id" uuid not null,
    "user_id" text,
    "name" text not null,
    "email" text not null,
    "role" text not null default 'Facility Admin'::text,
    "permissions" jsonb default '{}'::jsonb,
    "last_login" timestamp with time zone,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."cc_admin_users" enable row level security;


  create table "public"."cc_audit_log" (
    "id" uuid not null default gen_random_uuid(),
    "facility_id" uuid not null,
    "user_id" text,
    "action" text not null,
    "details" jsonb default '{}'::jsonb,
    "ip" text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."cc_audit_log" enable row level security;


  create table "public"."cc_billing_info" (
    "id" uuid not null default gen_random_uuid(),
    "facility_id" uuid not null,
    "plan" text not null default 'starter'::text,
    "billing_name" text,
    "billing_email" text,
    "card_last4" text,
    "card_brand" text,
    "card_exp" text,
    "stripe_customer_id" text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."cc_billing_info" enable row level security;


  create table "public"."cc_companion_assignments" (
    "id" uuid not null default gen_random_uuid(),
    "companion_id" uuid,
    "resident_id" uuid,
    "assigned_at" timestamp with time zone default now(),
    "is_primary" boolean default true,
    "facility_id" uuid
      );


alter table "public"."cc_companion_assignments" enable row level security;


  create table "public"."cc_companion_bookings" (
    "id" uuid not null default gen_random_uuid(),
    "companion_id" uuid,
    "resident_id" uuid,
    "facility_id" uuid,
    "booked_by" uuid,
    "booked_at" timestamp with time zone default now(),
    "session_date" timestamp with time zone,
    "duration_hours" numeric(4,1) default 1,
    "service" text,
    "status" text default 'pending'::text,
    "notes" text
      );


alter table "public"."cc_companion_bookings" enable row level security;


  create table "public"."cc_companions" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "facility_id" uuid,
    "full_name" text not null,
    "email" text not null,
    "specialties" text[],
    "bio" text,
    "rating" numeric(3,2) default 0,
    "session_count" integer default 0,
    "is_verified" boolean default false,
    "availability_status" text default 'available'::text,
    "created_at" timestamp with time zone default now(),
    "services" text[] default '{}'::text[],
    "available" boolean default true,
    "hourly_rate" numeric(10,2),
    "photo_url" text,
    "years_experience" integer,
    "paused" boolean default false,
    "pause_until" timestamp with time zone,
    "banking_info" jsonb default '{}'::jsonb
      );


alter table "public"."cc_companions" enable row level security;


  create table "public"."cc_facilities" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "slug" text not null,
    "plan" text not null default 'essential'::text,
    "resident_count" integer default 0,
    "address" text,
    "city" text,
    "state" text,
    "billing_email" text,
    "trial_ends_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "type" text default 'nursing_home'::text,
    "phone" text,
    "status" text not null default 'trial'::text,
    "stripe_customer_id" text
      );


alter table "public"."cc_facilities" enable row level security;


  create table "public"."cc_facility_members" (
    "id" uuid not null default gen_random_uuid(),
    "facility_id" uuid,
    "user_id" uuid,
    "role" text not null default 'admin'::text,
    "accepted_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."cc_facility_members" enable row level security;


  create table "public"."cc_family_connections" (
    "id" uuid not null default gen_random_uuid(),
    "resident_id" uuid,
    "user_id" uuid,
    "full_name" text not null,
    "relationship" text,
    "email" text,
    "phone" text,
    "is_primary" boolean default false,
    "last_login_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."cc_family_connections" enable row level security;


  create table "public"."cc_family_members" (
    "id" uuid not null default gen_random_uuid(),
    "primary_user_id" uuid not null,
    "resident_id" uuid,
    "name" text not null,
    "relationship" text,
    "email" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."cc_family_members" enable row level security;


  create table "public"."cc_family_messages" (
    "id" uuid not null default gen_random_uuid(),
    "facility_id" uuid not null,
    "family_user_id" text not null,
    "resident_id" uuid,
    "body" text not null,
    "read" boolean not null default false,
    "direction" text not null default 'family_to_facility'::text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."cc_family_messages" enable row level security;


  create table "public"."cc_family_users" (
    "id" uuid not null default gen_random_uuid(),
    "facility_id" uuid not null,
    "family_user_id" text not null,
    "resident_id" uuid,
    "relationship" text,
    "approved" boolean not null default false,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."cc_family_users" enable row level security;


  create table "public"."cc_marketplace_companions" (
    "id" uuid not null default gen_random_uuid(),
    "companion_id" uuid,
    "display_name" text not null,
    "bio" text,
    "services" text[] default '{}'::text[],
    "hourly_rate" numeric(10,2),
    "photo_url" text,
    "rating" numeric(3,1) default 0,
    "review_count" integer default 0,
    "available" boolean default true,
    "facility_id" uuid,
    "created_at" timestamp with time zone default now(),
    "pause_until" timestamp with time zone,
    "paused" boolean default false
      );


alter table "public"."cc_marketplace_companions" enable row level security;


  create table "public"."cc_messages" (
    "id" uuid not null default gen_random_uuid(),
    "facility_id" uuid,
    "from_user_id" uuid not null,
    "to_user_id" uuid,
    "resident_id" uuid,
    "body" text not null,
    "read" boolean default false,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."cc_messages" enable row level security;


  create table "public"."cc_mood_checkins" (
    "id" uuid not null default gen_random_uuid(),
    "resident_id" uuid,
    "mood" text not null,
    "mood_score" integer,
    "notes" text,
    "logged_by" text,
    "checked_in_at" timestamp with time zone default now(),
    "source" text default 'staff'::text,
    "facility_id" uuid
      );


alter table "public"."cc_mood_checkins" enable row level security;


  create table "public"."cc_org_users" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" text not null,
    "facility_id" uuid not null,
    "role" text not null default 'admin'::text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."cc_org_users" enable row level security;


  create table "public"."cc_residents" (
    "id" uuid not null default gen_random_uuid(),
    "facility_id" uuid,
    "full_name" text not null,
    "age" integer,
    "room_number" text,
    "wing" text,
    "preferences" text[],
    "dietary_notes" text,
    "medical_notes" text,
    "primary_family_contact" text,
    "companion_id" uuid,
    "wellbeing_score" numeric(3,1),
    "last_activity_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."cc_residents" enable row level security;


  create table "public"."cc_security_settings" (
    "id" uuid not null default gen_random_uuid(),
    "facility_id" uuid not null,
    "two_factor_enabled" boolean not null default false,
    "session_timeout_mins" integer not null default 60,
    "ip_whitelist" text[] default '{}'::text[],
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."cc_security_settings" enable row level security;


  create table "public"."cc_session_notes" (
    "id" uuid not null default gen_random_uuid(),
    "resident_id" uuid,
    "companion_id" uuid,
    "activity_id" uuid,
    "note" text not null,
    "mood_observed" text,
    "created_at" timestamp with time zone default now(),
    "mood_before" integer,
    "mood_after" integer,
    "participation_level" integer,
    "highlights" text,
    "concerns" text,
    "share_with_family" boolean default false,
    "activity_type" text,
    "facility_id" uuid
      );


alter table "public"."cc_session_notes" enable row level security;


  create table "public"."cc_staff" (
    "id" uuid not null default gen_random_uuid(),
    "facility_id" uuid not null,
    "name" text not null,
    "role" text not null default 'Nursing'::text,
    "email" text,
    "phone" text,
    "status" text not null default 'active'::text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."cc_staff" enable row level security;


  create table "public"."companion_activities" (
    "id" bigint not null default nextval('public.companion_activities_id_seq'::regclass),
    "created_by" bigint not null,
    "title" character varying(255) not null,
    "description" text,
    "activity_type" character varying(100) not null,
    "fee" numeric(10,2) not null default 0,
    "duration" integer not null default 60,
    "location" character varying(255),
    "is_active" boolean default true,
    "max_participants" integer default 1,
    "image_url" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "share_count" integer default 0,
    "view_count" integer default 0,
    "last_shared_at" timestamp with time zone,
    "activity_category" text,
    "event_start_at" timestamp with time zone,
    "maps_poi_name" text,
    "maps_poi_url" text,
    "category" text,
    "event_end_at" timestamp with time zone,
    "max_attendees" integer,
    "current_attendees" integer default 0,
    "is_free" boolean default true,
    "is_online" boolean default false,
    "meeting_url" text
      );


alter table "public"."companion_activities" enable row level security;


  create table "public"."companion_services" (
    "id" integer not null default nextval('public.companion_services_id_seq'::regclass),
    "profile_id" integer not null,
    "service_type" text not null,
    "pricing" numeric(10,2),
    "currency" text default 'USD'::text,
    "availability_notes" text,
    "use_global_availability" boolean default true,
    "specific_slots" jsonb default '[]'::jsonb,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "min_hours" integer default 1,
    "max_hours" integer default 8
      );


alter table "public"."companion_services" enable row level security;


  create table "public"."companions" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "user_id" integer not null,
    "bio" text,
    "hourly_rate_cents" integer default 0,
    "activities" text[] default '{}'::text[],
    "languages" text[] default '{English}'::text[],
    "availability_schedule" jsonb default '{}'::jsonb,
    "bio_embedding" public.vector(384),
    "verified" boolean default false,
    "rating_avg" numeric(3,2) default 0,
    "review_count" integer default 0,
    "status" text default 'active'::text
      );


alter table "public"."companions" enable row level security;


  create table "public"."companions_v2" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "bio" text,
    "hourly_rate_cents" integer default 0,
    "activities" text[] default '{}'::text[],
    "languages" text[] default '{English}'::text[],
    "availability_schedule" jsonb default '{}'::jsonb,
    "bio_embedding" public.vector(384),
    "verified" boolean default false,
    "rating_avg" numeric(3,2) default 0,
    "review_count" integer default 0,
    "status" text default 'active'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."companions_v2" enable row level security;


  create table "public"."conversations" (
    "id" integer not null default nextval('public.conversations_id_seq'::regclass),
    "bookingId" integer,
    "topic" text,
    "createdAt" timestamp without time zone not null default now(),
    "updatedAt" timestamp without time zone not null default now(),
    "lastMessageAt" timestamp without time zone,
    "participant1_id" integer,
    "participant2_id" integer,
    "last_message_at" timestamp with time zone,
    "last_message" text,
    "unread_count" integer default 0
      );


alter table "public"."conversations" enable row level security;


  create table "public"."ct_admissions" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "applicant_name" text not null,
    "applicant_email" text not null,
    "applicant_phone" text,
    "program" text,
    "status" text default 'applied'::text,
    "gpa" numeric(3,2),
    "notes" text,
    "reviewed_by" uuid,
    "applied_at" timestamp with time zone default now(),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_admissions" enable row level security;


  create table "public"."ct_ai_insights" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid not null,
    "insight_type" text not null default 'engagement'::text,
    "title" text not null,
    "description" text,
    "severity" text not null default 'info'::text,
    "data" jsonb default '{}'::jsonb,
    "is_read" boolean not null default false,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_ai_insights" enable row level security;


  create table "public"."ct_announcements" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid,
    "title" text not null,
    "body" text,
    "priority" text default 'normal'::text,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "audience" text default 'all'::text,
    "status" text default 'published'::text,
    "institution_id" uuid,
    "author_id" uuid,
    "updated_at" timestamp with time zone default now(),
    "target_roles" text[] default '{}'::text[]
      );


alter table "public"."ct_announcements" enable row level security;


  create table "public"."ct_api_keys" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "created_by" uuid,
    "name" text not null,
    "key_hash" text not null,
    "key_prefix" text not null,
    "scopes" text[],
    "is_active" boolean default true,
    "last_used_at" timestamp with time zone,
    "expires_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "description" text
      );


alter table "public"."ct_api_keys" enable row level security;


  create table "public"."ct_assignment_documents" (
    "id" uuid not null default gen_random_uuid(),
    "assignment_id" uuid,
    "name" text not null,
    "url" text not null,
    "mime_type" text,
    "size_bytes" bigint,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_assignment_documents" enable row level security;


  create table "public"."ct_assignment_submissions" (
    "id" uuid not null default gen_random_uuid(),
    "assignment_id" uuid,
    "student_id" uuid,
    "submitted_at" timestamp with time zone default now(),
    "notes" text
      );


alter table "public"."ct_assignment_submissions" enable row level security;


  create table "public"."ct_assignments" (
    "id" uuid not null default gen_random_uuid(),
    "class_id" uuid,
    "teacher_id" uuid,
    "title" text not null,
    "description" text,
    "due_date" timestamp with time zone,
    "total_marks" integer default 100,
    "assignment_type" text default 'assignment'::text,
    "is_published" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "institution_id" uuid,
    "max_points" integer default 100,
    "created_by" uuid,
    "course_id" uuid
      );


alter table "public"."ct_assignments" enable row level security;


  create table "public"."ct_athletes" (
    "id" uuid not null default gen_random_uuid(),
    "team_id" uuid,
    "user_id" uuid,
    "position" text,
    "jersey_number" text,
    "stats" jsonb default '{}'::jsonb,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "waiver_signed" boolean default false,
    "waiver_signed_at" timestamp with time zone
      );


alter table "public"."ct_athletes" enable row level security;


  create table "public"."ct_attendance" (
    "id" uuid not null default gen_random_uuid(),
    "class_id" uuid,
    "student_id" uuid,
    "teacher_id" uuid,
    "date" date not null,
    "status" text default 'present'::text,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_attendance" enable row level security;


  create table "public"."ct_audit_logs" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "actor_id" uuid,
    "action" text not null,
    "resource_type" text,
    "resource_id" uuid,
    "metadata" jsonb default '{}'::jsonb,
    "ip_address" text,
    "user_agent" text,
    "severity" text default 'info'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_audit_logs" enable row level security;


  create table "public"."ct_billing_invoices" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid not null,
    "subscription_id" uuid,
    "amount" numeric(10,2) not null,
    "currency" text not null default 'CAD'::text,
    "status" text not null default 'pending'::text,
    "payment_method_id" uuid,
    "period_start" timestamp with time zone,
    "period_end" timestamp with time zone,
    "paid_at" timestamp with time zone,
    "notes" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_billing_invoices" enable row level security;


  create table "public"."ct_billing_plans" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid not null,
    "plan_name" text not null default 'standard'::text,
    "price_per_user_monthly" numeric(10,2) not null default 4.99,
    "billing_cycle" text not null default 'monthly'::text,
    "currency" text not null default 'CAD'::text,
    "active" boolean not null default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_billing_plans" enable row level security;


  create table "public"."ct_blog_posts" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "slug" text not null,
    "category" text not null,
    "excerpt" text not null,
    "body" text not null,
    "author" text not null default 'Campus Tribe Research Team'::text,
    "image_url" text not null,
    "published_at" timestamp with time zone default now(),
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_blog_posts" enable row level security;


  create table "public"."ct_broadcast_notifications" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "title" text not null,
    "body" text not null,
    "audience" text default 'all'::text,
    "created_by" uuid,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_broadcast_notifications" enable row level security;


  create table "public"."ct_budget_items" (
    "id" uuid not null default gen_random_uuid(),
    "budget_id" uuid,
    "description" text not null,
    "amount" numeric(10,2) not null,
    "category" text,
    "receipt_url" text,
    "approved_by" uuid,
    "status" text default 'pending'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_budget_items" enable row level security;


  create table "public"."ct_budgets" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "department" text,
    "club_id" uuid,
    "fiscal_year" text,
    "total_allocated" numeric(12,2) default 0,
    "total_spent" numeric(12,2) default 0,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_budgets" enable row level security;


  create table "public"."ct_challenge_entries" (
    "id" uuid not null default gen_random_uuid(),
    "challenge_id" uuid,
    "user_id" uuid,
    "institution_id" uuid,
    "score" numeric,
    "rank" integer,
    "submitted_at" timestamp with time zone default now()
      );


alter table "public"."ct_challenge_entries" enable row level security;


  create table "public"."ct_challenge_scores" (
    "id" uuid not null default gen_random_uuid(),
    "challenge_id" uuid,
    "user_id" uuid,
    "score" numeric,
    "notes" text,
    "posted_by" uuid,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_challenge_scores" enable row level security;


  create table "public"."ct_children" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "parent_id" uuid,
    "teacher_id" uuid,
    "full_name" text not null,
    "date_of_birth" date,
    "room" text,
    "allergies" text,
    "medical_notes" text,
    "emergency_contact" text,
    "avatar_url" text,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_children" enable row level security;


  create table "public"."ct_classes" (
    "id" uuid not null default gen_random_uuid(),
    "course_id" uuid,
    "teacher_id" uuid,
    "institution_id" uuid,
    "section" text,
    "room" text,
    "schedule" text,
    "semester" text,
    "academic_year" text,
    "capacity" integer default 35,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_classes" enable row level security;


  create table "public"."ct_club_election_candidates" (
    "id" uuid not null default gen_random_uuid(),
    "election_id" uuid not null,
    "student_id" uuid,
    "position" text not null,
    "statement" text,
    "votes_count" integer not null default 0,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_club_election_candidates" enable row level security;


  create table "public"."ct_club_election_votes" (
    "id" uuid not null default gen_random_uuid(),
    "election_id" uuid not null,
    "candidate_id" uuid not null,
    "voter_id" uuid not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_club_election_votes" enable row level security;


  create table "public"."ct_club_elections" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid not null,
    "club_id" uuid not null,
    "title" text not null,
    "description" text,
    "status" text not null default 'open'::text,
    "starts_at" timestamp with time zone,
    "ends_at" timestamp with time zone,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_club_elections" enable row level security;


  create table "public"."ct_club_events" (
    "id" uuid not null default gen_random_uuid(),
    "club_id" uuid,
    "event_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_club_events" enable row level security;


  create table "public"."ct_club_members" (
    "id" uuid not null default gen_random_uuid(),
    "club_id" uuid,
    "user_id" uuid,
    "role" text default 'member'::text,
    "status" text default 'active'::text,
    "joined_at" timestamp with time zone default now(),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "institution_id" uuid
      );


alter table "public"."ct_club_members" enable row level security;


  create table "public"."ct_club_memberships" (
    "id" uuid not null default gen_random_uuid(),
    "club_id" uuid,
    "student_id" uuid,
    "role" text default 'member'::text,
    "joined_at" timestamp with time zone default now()
      );


alter table "public"."ct_club_memberships" enable row level security;


  create table "public"."ct_club_posts" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid not null,
    "club_id" uuid not null,
    "author_id" uuid,
    "content" text not null,
    "media_url" text,
    "post_type" text not null default 'update'::text,
    "likes_count" integer not null default 0,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_club_posts" enable row level security;


  create table "public"."ct_club_recognition_requests" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid not null,
    "club_name" text not null,
    "description" text,
    "category" text,
    "contact_name" text,
    "contact_email" text,
    "advisor_name" text,
    "status" text not null default 'pending'::text,
    "submitted_by" uuid,
    "reviewed_by" uuid,
    "reviewed_at" timestamp with time zone,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_club_recognition_requests" enable row level security;


  create table "public"."ct_clubs" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid,
    "name" text not null,
    "category" text,
    "description" text,
    "member_count" integer default 0,
    "meeting_schedule" text,
    "created_at" timestamp with time zone default now(),
    "institution_id" uuid,
    "max_members" integer,
    "created_by" uuid,
    "status" text default 'active'::text,
    "leader_id" uuid,
    "is_approved" boolean default false,
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_clubs" enable row level security;


  create table "public"."ct_course_enrollments" (
    "id" uuid not null default gen_random_uuid(),
    "course_id" uuid,
    "student_id" uuid,
    "enrolled_at" timestamp with time zone default now()
      );


alter table "public"."ct_course_enrollments" enable row level security;


  create table "public"."ct_courses" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "code" text not null,
    "name" text not null,
    "description" text,
    "department" text,
    "credits" integer default 3,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "teacher_id" uuid
      );


alter table "public"."ct_courses" enable row level security;


  create table "public"."ct_daily_reports" (
    "id" uuid not null default gen_random_uuid(),
    "child_id" uuid,
    "teacher_id" uuid,
    "report_date" date not null,
    "mood" integer,
    "meals" jsonb default '{}'::jsonb,
    "nap_duration_minutes" integer,
    "activities" text[],
    "teacher_note" text,
    "photos" text[],
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_daily_reports" enable row level security;


  create table "public"."ct_demo_requests" (
    "id" uuid not null default gen_random_uuid(),
    "full_name" text not null,
    "email" text not null,
    "institution_name" text not null,
    "institution_type" text not null,
    "student_count" text not null,
    "message" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_demo_requests" enable row level security;


  create table "public"."ct_direct_messages" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "sender_id" uuid,
    "recipient_id" uuid,
    "message" text not null,
    "read_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_direct_messages" enable row level security;


  create table "public"."ct_discovery_profiles" (
    "id" uuid not null default gen_random_uuid(),
    "student_id" uuid not null,
    "org_id" uuid not null,
    "discovery_enabled" boolean not null default true,
    "looking_for" text default 'friend'::text,
    "availability" text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_discovery_profiles" enable row level security;


  create table "public"."ct_email_rate_limits" (
    "ip" text not null,
    "date" date not null,
    "count" integer default 0
      );


alter table "public"."ct_email_rate_limits" enable row level security;


  create table "public"."ct_email_verifications" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "email" text not null,
    "token" text not null default encode(extensions.gen_random_bytes(32), 'hex'::text),
    "verified_at" timestamp with time zone,
    "expires_at" timestamp with time zone default (now() + '24:00:00'::interval),
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_email_verifications" enable row level security;


  create table "public"."ct_engagement_points" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "institution_id" uuid,
    "points" integer default 0,
    "badges" text[],
    "rank" integer,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_engagement_points" enable row level security;


  create table "public"."ct_engagement_scores" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "institution_id" uuid,
    "score" integer default 0,
    "event_attendance_count" integer default 0,
    "club_count" integer default 0,
    "wellbeing_check_count" integer default 0,
    "survey_response_count" integer default 0,
    "last_active_at" timestamp with time zone default now(),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_engagement_scores" enable row level security;


  create table "public"."ct_enrollments" (
    "id" uuid not null default gen_random_uuid(),
    "class_id" uuid,
    "student_id" uuid,
    "status" text default 'enrolled'::text,
    "grade" text,
    "gpa_points" numeric(3,2),
    "enrolled_at" timestamp with time zone default now(),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_enrollments" enable row level security;


  create table "public"."ct_error_logs" (
    "id" uuid not null default gen_random_uuid(),
    "level" text not null default 'error'::text,
    "message" text not null,
    "context" jsonb,
    "user_id" uuid,
    "institution_id" uuid,
    "resolved_at" timestamp with time zone,
    "resolved_by" uuid,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_error_logs" enable row level security;


  create table "public"."ct_event_rsvps" (
    "id" uuid not null default gen_random_uuid(),
    "event_id" uuid,
    "student_id" uuid,
    "status" text default 'going'::text,
    "created_at" timestamp with time zone default now(),
    "org_id" uuid,
    "user_id" uuid,
    "updated_at" timestamp with time zone default now(),
    "checked_in" boolean default false,
    "checked_in_at" timestamp with time zone
      );


alter table "public"."ct_event_rsvps" enable row level security;


  create table "public"."ct_events" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid,
    "title" text not null,
    "description" text,
    "venue_id" uuid,
    "event_date" timestamp with time zone not null,
    "end_date" timestamp with time zone,
    "capacity" integer,
    "rsvp_count" integer default 0,
    "status" text default 'upcoming'::text,
    "category" text,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "image_url" text,
    "institution_id" uuid,
    "location" text,
    "start_time" timestamp with time zone,
    "end_time" timestamp with time zone,
    "checkin_enabled" boolean default false
      );


alter table "public"."ct_events" enable row level security;


  create table "public"."ct_feature_events" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "institution_id" uuid,
    "feature_name" text not null,
    "action" text,
    "metadata" jsonb,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_feature_events" enable row level security;


  create table "public"."ct_free_trial_requests" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "institution_id" uuid,
    "reason" text,
    "status" text not null default 'pending'::text,
    "trial_months" integer default 3,
    "trial_start" timestamp with time zone,
    "trial_end" timestamp with time zone,
    "reviewed_by" uuid,
    "reviewed_at" timestamp with time zone,
    "review_note" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_free_trial_requests" enable row level security;


  create table "public"."ct_funding_requests" (
    "id" uuid not null default gen_random_uuid(),
    "club_id" uuid,
    "institution_id" uuid,
    "submitted_by" uuid,
    "amount" numeric(12,2) not null,
    "purpose" text not null,
    "description" text,
    "status" text default 'pending'::text,
    "reviewed_by" uuid,
    "review_notes" text,
    "reviewed_at" timestamp with time zone,
    "receipt_urls" text[] default '{}'::text[],
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_funding_requests" enable row level security;


  create table "public"."ct_games" (
    "id" uuid not null default gen_random_uuid(),
    "home_team_id" uuid,
    "away_team_id" uuid,
    "venue_id" uuid,
    "scheduled_at" timestamp with time zone,
    "home_score" integer,
    "away_score" integer,
    "status" text default 'scheduled'::text,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_games" enable row level security;


  create table "public"."ct_grades" (
    "id" uuid not null default gen_random_uuid(),
    "enrollment_id" uuid,
    "student_id" uuid,
    "class_id" uuid,
    "assignment_id" uuid,
    "score" numeric(5,2),
    "letter_grade" text,
    "gpa_points" numeric(3,2),
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "graded_by" uuid,
    "feedback" text,
    "points" integer,
    "grade" numeric,
    "max_points" numeric,
    "graded_at" timestamp with time zone default now(),
    "graded_by_teacher" uuid
      );


alter table "public"."ct_grades" enable row level security;


  create table "public"."ct_group_activities" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid not null,
    "title" text not null,
    "description" text,
    "activity_type" text not null default 'social'::text,
    "max_participants" integer,
    "scheduled_at" timestamp with time zone,
    "venue_id" uuid,
    "organizer_id" uuid,
    "status" text not null default 'open'::text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_group_activities" enable row level security;


  create table "public"."ct_group_activity_members" (
    "id" uuid not null default gen_random_uuid(),
    "activity_id" uuid not null,
    "student_id" uuid not null,
    "joined_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_group_activity_members" enable row level security;


  create table "public"."ct_institution_requests" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "request_type" text not null,
    "institution_id" uuid,
    "requested_name" text,
    "requested_type" text,
    "status" text not null default 'pending'::text,
    "reviewed_by" uuid,
    "reviewed_at" timestamp with time zone,
    "review_note" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_institution_requests" enable row level security;


  create table "public"."ct_institution_settings" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "key" text not null,
    "value" text,
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_institution_settings" enable row level security;


  create table "public"."ct_institution_subscriptions" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid not null,
    "plan_id" uuid,
    "status" text not null default 'trial'::text,
    "trial_ends_at" timestamp with time zone default (now() + '30 days'::interval),
    "current_period_start" timestamp with time zone default now(),
    "current_period_end" timestamp with time zone default (now() + '1 mon'::interval),
    "payment_method_id" uuid,
    "seats_paid" integer default 0,
    "covers_roles" text[] default ARRAY['admin'::text, 'it_director'::text, 'teacher'::text, 'coach'::text, 'staff'::text],
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_institution_subscriptions" enable row level security;


  create table "public"."ct_institutions" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "domain" text not null,
    "logo_url" text,
    "plan" text not null default 'starter'::text,
    "student_count" integer default 0,
    "created_at" timestamp with time zone default now(),
    "institution_type" text not null default 'university'::text,
    "city" text,
    "country" text default 'Canada'::text,
    "website" text,
    "description" text,
    "color_primary" text default '#0047AB'::text,
    "updated_at" timestamp with time zone default now(),
    "invite_code" text,
    "short_name" text,
    "subscription_status" text default 'trial'::text
      );


alter table "public"."ct_institutions" enable row level security;


  create table "public"."ct_interest_onboarding" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "completed" boolean default false,
    "interests" text[] default '{}'::text[],
    "goals" text[] default '{}'::text[],
    "social_pref" text default 'mixed'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_interest_onboarding" enable row level security;


  create table "public"."ct_match_participants" (
    "id" uuid not null default gen_random_uuid(),
    "match_id" uuid,
    "user_id" uuid,
    "institution_id" uuid,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_match_participants" enable row level security;


  create table "public"."ct_match_results" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid not null,
    "challenge_id" uuid,
    "winner_id" uuid,
    "sport" text,
    "score_challenger" integer,
    "score_challenged" integer,
    "notes" text,
    "played_at" timestamp with time zone not null default now(),
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_match_results" enable row level security;


  create table "public"."ct_note_requests" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "parent_id" uuid not null,
    "student_id" uuid not null,
    "teacher_id" uuid,
    "course_id" uuid,
    "request_message" text,
    "status" text default 'pending'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_note_requests" enable row level security;


  create table "public"."ct_notification_preferences" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "org_id" uuid,
    "events_enabled" boolean not null default true,
    "clubs_enabled" boolean not null default true,
    "sports_enabled" boolean not null default true,
    "wellbeing_enabled" boolean not null default true,
    "announcements_enabled" boolean not null default true,
    "email_digest" text not null default 'none'::text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_notification_preferences" enable row level security;


  create table "public"."ct_notification_prefs" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "institution_id" uuid,
    "channel" text not null,
    "event_type" text not null,
    "enabled" boolean default true,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_notification_prefs" enable row level security;


  create table "public"."ct_notifications" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "title" text not null,
    "body" text,
    "read" boolean default false,
    "created_at" timestamp with time zone default now(),
    "created_by" uuid,
    "institution_id" uuid,
    "link" text,
    "type" text default 'system'::text,
    "is_read" boolean default false
      );


alter table "public"."ct_notifications" enable row level security;


  create table "public"."ct_onboarding" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "institution_id" uuid,
    "step_completed" integer default 0,
    "interests" text[] default '{}'::text[],
    "goals" text[] default '{}'::text[],
    "completed_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_onboarding" enable row level security;


  create table "public"."ct_org_members" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid,
    "user_id" uuid,
    "role" text not null default 'admin'::text,
    "invited_at" timestamp with time zone default now(),
    "accepted_at" timestamp with time zone
      );


alter table "public"."ct_org_members" enable row level security;


  create table "public"."ct_org_users" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" text not null,
    "org_id" uuid not null,
    "role" text not null default 'admin'::text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_org_users" enable row level security;


  create table "public"."ct_organizations" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "slug" text not null,
    "plan" text not null default 'starter'::text,
    "student_count" integer default 0,
    "billing_email" text,
    "trial_ends_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "type" text default 'school'::text,
    "phone" text,
    "status" text not null default 'trial'::text,
    "stripe_customer_id" text
      );


alter table "public"."ct_organizations" enable row level security;


  create table "public"."ct_parent_links" (
    "id" uuid not null default gen_random_uuid(),
    "parent_user_id" uuid not null,
    "student_id" uuid,
    "org_id" uuid,
    "status" text default 'pending'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_parent_links" enable row level security;


  create table "public"."ct_parent_updates" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "child_id" uuid not null,
    "author_id" uuid,
    "audience" text not null default 'parent'::text,
    "note_type" text not null default 'update'::text,
    "note" text not null,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_parent_updates" enable row level security;


  create table "public"."ct_payment_methods" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "user_id" uuid,
    "payment_type" text not null default 'card'::text,
    "card_last4" text,
    "card_brand" text,
    "card_exp_month" integer,
    "card_exp_year" integer,
    "card_holder_name" text,
    "bank_reference" text,
    "is_default" boolean not null default false,
    "verified" boolean not null default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_payment_methods" enable row level security;


  create table "public"."ct_peer_connections" (
    "id" uuid not null default gen_random_uuid(),
    "requester_id" uuid not null,
    "recipient_id" uuid not null,
    "org_id" uuid not null,
    "status" text not null default 'pending'::text,
    "message" text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_peer_connections" enable row level security;


  create table "public"."ct_performance_notes" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "teacher_id" uuid not null,
    "student_id" uuid not null,
    "course_id" uuid,
    "class_id" uuid,
    "title" text not null,
    "content" text not null,
    "note_type" text not null default 'general'::text,
    "frequency" text default 'manual'::text,
    "send_to_student" boolean default true,
    "send_to_parent" boolean default false,
    "is_sent" boolean default false,
    "sent_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_performance_notes" enable row level security;


  create table "public"."ct_platform_settings" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid not null,
    "category" text not null,
    "provider" text not null,
    "status" text not null default 'draft'::text,
    "notes" text,
    "config" jsonb not null default '{}'::jsonb,
    "updated_by" uuid,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_platform_settings" enable row level security;


  create table "public"."ct_sport_challenge_participants" (
    "id" uuid not null default gen_random_uuid(),
    "challenge_id" uuid,
    "user_id" uuid,
    "joined_at" timestamp with time zone default now()
      );


alter table "public"."ct_sport_challenge_participants" enable row level security;


  create table "public"."ct_sport_challenges" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "created_by" uuid,
    "sport" text not null,
    "title" text not null,
    "description" text,
    "challenge_date" timestamp with time zone,
    "location" text,
    "max_participants" integer default 10,
    "status" text default 'open'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_sport_challenges" enable row level security;


  create table "public"."ct_sport_participants" (
    "id" uuid not null default gen_random_uuid(),
    "student_id" uuid,
    "team_id" uuid,
    "org_id" uuid,
    "joined_at" timestamp with time zone default now(),
    "user_id" uuid,
    "league_id" uuid,
    "institution_id" uuid,
    "is_free_agent" boolean default false,
    "waiver_signed" boolean default false
      );


alter table "public"."ct_sport_participants" enable row level security;


  create table "public"."ct_sport_rankings" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "institution_id" uuid,
    "sport" text not null,
    "wins" integer default 0,
    "losses" integer default 0,
    "points" integer default 0,
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_sport_rankings" enable row level security;


  create table "public"."ct_sports_challenges" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid,
    "challenger_id" uuid,
    "challenged_id" uuid,
    "sport" text not null,
    "message" text,
    "status" text default 'pending'::text,
    "scheduled_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "venue_id" uuid,
    "title" text,
    "description" text,
    "institution_id" uuid,
    "is_open" boolean default true,
    "challenger_score" integer,
    "challenged_score" integer,
    "result_posted_at" timestamp with time zone
      );


alter table "public"."ct_sports_challenges" enable row level security;


  create table "public"."ct_sports_games" (
    "id" uuid not null default gen_random_uuid(),
    "league_id" uuid,
    "home_team_id" uuid,
    "away_team_id" uuid,
    "home_score" integer,
    "away_score" integer,
    "scheduled_at" timestamp with time zone not null,
    "venue_id" uuid,
    "status" text not null default 'scheduled'::text,
    "created_at" timestamp with time zone default now(),
    "institution_id" uuid,
    "home_sportsmanship" integer,
    "away_sportsmanship" integer
      );


alter table "public"."ct_sports_games" enable row level security;


  create table "public"."ct_sports_leagues" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "name" text not null,
    "sport" text not null,
    "season" text not null,
    "status" text not null default 'registration'::text,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "format" text default 'round_robin'::text
      );


alter table "public"."ct_sports_leagues" enable row level security;


  create table "public"."ct_sports_teams" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid,
    "name" text not null,
    "description" text,
    "sport_type" text,
    "wins" integer default 0,
    "losses" integer default 0,
    "created_at" timestamp with time zone default now(),
    "league_id" uuid,
    "institution_id" uuid,
    "draws" integer default 0,
    "points" integer default 0
      );


alter table "public"."ct_sports_teams" enable row level security;


  create table "public"."ct_staff_registrations" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid not null,
    "token" text,
    "full_name" text not null,
    "email" text not null,
    "phone" text,
    "role" text default 'Teacher'::text,
    "group_room" text,
    "bio" text,
    "status" text not null default 'pending'::text,
    "reviewed_by" uuid,
    "reviewed_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_staff_registrations" enable row level security;


  create table "public"."ct_stealth_sessions" (
    "id" uuid not null default gen_random_uuid(),
    "superadmin_id" uuid,
    "target_institution_id" uuid,
    "target_user_id" uuid,
    "target_role" text,
    "started_at" timestamp with time zone default now(),
    "ended_at" timestamp with time zone,
    "ip_address" text,
    "user_agent" text,
    "notes" text
      );


alter table "public"."ct_stealth_sessions" enable row level security;


  create table "public"."ct_student_journey" (
    "id" uuid not null default gen_random_uuid(),
    "student_id" uuid,
    "org_id" uuid,
    "institution_name" text not null,
    "institution_type" text not null default 'school'::text,
    "year_start" integer,
    "year_end" integer,
    "degree_or_grade" text,
    "notes" text,
    "status" text not null default 'current'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_student_journey" enable row level security;


  create table "public"."ct_student_notes" (
    "id" uuid not null default gen_random_uuid(),
    "teacher_id" uuid,
    "student_id" uuid,
    "class_id" uuid,
    "note" text,
    "is_at_risk" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_student_notes" enable row level security;


  create table "public"."ct_student_registrations" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid not null,
    "full_name" text not null,
    "email" text not null,
    "year" text,
    "major" text,
    "campus" text,
    "class_section" text,
    "student_id_number" text,
    "phone" text,
    "bio" text,
    "interests" text[],
    "status" text not null default 'pending'::text,
    "form_data" jsonb,
    "token" text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_student_registrations" enable row level security;


  create table "public"."ct_students" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid,
    "user_id" uuid,
    "student_id" text,
    "full_name" text not null,
    "email" text not null,
    "year" integer,
    "major" text,
    "residence_hall" text,
    "wellbeing_score" integer default 7,
    "mood_today" text,
    "last_active_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "interests" text[] default '{}'::text[],
    "social_pref" text default 'all'::text,
    "goals" text[] default '{}'::text[],
    "avatar_url" text,
    "bio" text
      );


alter table "public"."ct_students" enable row level security;


  create table "public"."ct_submission_files" (
    "id" uuid not null default gen_random_uuid(),
    "submission_id" uuid,
    "name" text not null,
    "url" text not null,
    "mime_type" text,
    "size_bytes" bigint,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_submission_files" enable row level security;


  create table "public"."ct_submissions" (
    "id" uuid not null default gen_random_uuid(),
    "assignment_id" uuid,
    "student_id" uuid,
    "submitted_at" timestamp with time zone default now(),
    "file_url" text,
    "content" text,
    "score" numeric(5,2),
    "feedback" text,
    "graded_by" uuid,
    "graded_at" timestamp with time zone,
    "status" text default 'submitted'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_submissions" enable row level security;


  create table "public"."ct_superadmins" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "email" text not null,
    "added_by" uuid,
    "permissions" jsonb default '{"view_all": true, "stealth_login": true, "manage_billing": true, "manage_institutions": true}'::jsonb,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_superadmins" enable row level security;


  create table "public"."ct_survey_questions" (
    "id" uuid not null default gen_random_uuid(),
    "survey_id" uuid not null,
    "question_text" text not null,
    "question_type" text not null default 'multiple_choice'::text,
    "options" jsonb,
    "required" boolean not null default true,
    "order_index" integer not null default 0,
    "prompt" text,
    "position" integer
      );


alter table "public"."ct_survey_questions" enable row level security;


  create table "public"."ct_survey_responses" (
    "id" uuid not null default gen_random_uuid(),
    "survey_id" uuid not null,
    "student_id" uuid,
    "org_id" uuid,
    "answers" jsonb not null default '{}'::jsonb,
    "submitted_at" timestamp with time zone not null default now(),
    "user_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_survey_responses" enable row level security;


  create table "public"."ct_surveys" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid not null,
    "title" text not null,
    "description" text,
    "target_audience" text default 'all'::text,
    "target_value" text,
    "status" text not null default 'draft'::text,
    "anonymous" boolean not null default false,
    "scheduled_at" timestamp with time zone,
    "closes_at" timestamp with time zone,
    "created_by" uuid,
    "created_at" timestamp with time zone not null default now(),
    "institution_id" uuid,
    "is_active" boolean default false,
    "target_roles" text[] default '{}'::text[],
    "updated_at" timestamp with time zone default now(),
    "is_anonymous" boolean default false
      );


alter table "public"."ct_surveys" enable row level security;


  create table "public"."ct_teams" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "name" text not null,
    "sport" text,
    "coach_id" uuid,
    "wins" integer default 0,
    "losses" integer default 0,
    "draws" integer default 0,
    "points" integer default 0,
    "season" text,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_teams" enable row level security;


  create table "public"."ct_ticket_messages" (
    "id" uuid not null default gen_random_uuid(),
    "ticket_id" uuid,
    "sender_id" uuid,
    "message" text not null,
    "is_internal" boolean default false,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_ticket_messages" enable row level security;


  create table "public"."ct_tickets" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid,
    "created_by" uuid,
    "assigned_to" uuid,
    "ticket_type" text not null,
    "title" text not null,
    "description" text,
    "status" text not null default 'open'::text,
    "priority" text not null default 'medium'::text,
    "category" text,
    "resolution_notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "resolved_at" timestamp with time zone
      );


alter table "public"."ct_tickets" enable row level security;


  create table "public"."ct_tournament_matches" (
    "id" uuid not null default gen_random_uuid(),
    "tournament_id" uuid not null,
    "round_number" integer not null default 1,
    "team_a_id" uuid,
    "team_b_id" uuid,
    "winner_id" uuid,
    "score_a" integer,
    "score_b" integer,
    "scheduled_at" timestamp with time zone,
    "played_at" timestamp with time zone,
    "bracket_position" integer,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_tournament_matches" enable row level security;


  create table "public"."ct_tournament_teams" (
    "id" uuid not null default gen_random_uuid(),
    "tournament_id" uuid not null,
    "team_id" uuid,
    "team_name" text,
    "seed" integer,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_tournament_teams" enable row level security;


  create table "public"."ct_tournaments" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid not null,
    "sport_type" text not null,
    "name" text not null,
    "format" text not null default 'single_elim'::text,
    "status" text not null default 'registration'::text,
    "start_date" date,
    "end_date" date,
    "max_teams" integer default 16,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_tournaments" enable row level security;


  create table "public"."ct_training_sessions" (
    "id" uuid not null default gen_random_uuid(),
    "team_id" uuid,
    "coach_id" uuid,
    "venue_id" uuid,
    "scheduled_at" timestamp with time zone,
    "duration_minutes" integer default 90,
    "title" text,
    "focus_area" text,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "institution_id" uuid
      );


alter table "public"."ct_training_sessions" enable row level security;


  create table "public"."ct_trial_requests" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "status" text default 'pending'::text,
    "requested_at" timestamp with time zone default now(),
    "reviewed_by" uuid,
    "reviewed_at" timestamp with time zone,
    "notes" text
      );


alter table "public"."ct_trial_requests" enable row level security;


  create table "public"."ct_user_notifications" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "institution_id" uuid,
    "title" text not null,
    "body" text,
    "type" text default 'info'::text,
    "is_read" boolean default false,
    "link" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_user_notifications" enable row level security;


  create table "public"."ct_user_seat_billing" (
    "id" uuid not null default gen_random_uuid(),
    "institution_id" uuid not null,
    "user_id" uuid not null,
    "subscription_id" uuid,
    "role" text not null,
    "is_paid" boolean not null default false,
    "paid_by" uuid,
    "paid_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."ct_user_seat_billing" enable row level security;


  create table "public"."ct_users" (
    "id" uuid not null,
    "email" text not null,
    "full_name" text not null,
    "role" text not null default 'student'::text,
    "institution_id" uuid,
    "avatar_url" text,
    "created_at" timestamp with time zone default now(),
    "institution_type" text,
    "bio" text,
    "major" text,
    "year_of_study" integer,
    "interests" text[] default '{}'::text[],
    "phone" text,
    "onboarding_complete" boolean default false,
    "updated_at" timestamp with time zone default now(),
    "is_active" boolean default true,
    "platform_type" text,
    "free_agent" boolean default false,
    "gender" character varying(50),
    "roles" text[] default '{}'::text[],
    "department" text,
    "student_id_number" text,
    "notification_prefs" jsonb default '{}'::jsonb,
    "is_at_risk" boolean default false,
    "student_number" text,
    "is_athlete" boolean default false,
    "athlete_sport" text,
    "athlete_team_id" uuid,
    "athlete_coach_id" uuid,
    "payment_status" text default 'not_required'::text,
    "email_verified" boolean default false,
    "email_verified_at" timestamp with time zone,
    "trial_status" text,
    "trial_expires_at" timestamp with time zone,
    "active_role" text,
    "trial_ends_at" timestamp with time zone
      );


alter table "public"."ct_users" enable row level security;


  create table "public"."ct_venue_booking_history" (
    "id" uuid not null default gen_random_uuid(),
    "booking_id" uuid not null,
    "actor_id" uuid,
    "action" text not null,
    "from_status" text,
    "to_status" text,
    "note" text,
    "metadata" jsonb not null default '{}'::jsonb,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."ct_venue_booking_history" enable row level security;


  create table "public"."ct_venue_bookings" (
    "id" uuid not null default gen_random_uuid(),
    "venue_id" uuid,
    "org_id" uuid,
    "booked_by" uuid,
    "purpose" text,
    "start_time" timestamp with time zone not null,
    "end_time" timestamp with time zone not null,
    "attendee_count" integer,
    "status" text default 'confirmed'::text,
    "created_at" timestamp with time zone default now(),
    "notes" text,
    "approved_by" uuid,
    "updated_at" timestamp with time zone default now(),
    "resources_requested" jsonb default '{}'::jsonb,
    "is_recurring" boolean default false,
    "recurrence_weeks" integer default 1
      );


alter table "public"."ct_venue_bookings" enable row level security;


  create table "public"."ct_venues" (
    "id" uuid not null default gen_random_uuid(),
    "org_id" uuid,
    "name" text not null,
    "capacity" integer,
    "location" text,
    "amenities" text[],
    "status" text default 'available'::text,
    "image_url" text,
    "created_at" timestamp with time zone default now(),
    "institution_id" uuid,
    "created_by" uuid,
    "building" text,
    "room_number" text,
    "is_bookable" boolean default true,
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."ct_venues" enable row level security;


  create table "public"."ct_wellbeing_checkins" (
    "id" uuid not null default gen_random_uuid(),
    "student_id" uuid,
    "mood" integer not null,
    "energy" integer,
    "stress" integer,
    "note" text,
    "checked_in_at" timestamp with time zone default now(),
    "org_id" uuid,
    "mood_score" integer,
    "institution_id" uuid,
    "user_id" uuid
      );


alter table "public"."ct_wellbeing_checkins" enable row level security;


  create table "public"."ct_wellbeing_checks" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "date" date not null,
    "mood" integer,
    "energy" integer,
    "stress" integer,
    "sleep_hours" numeric(3,1),
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "happiness_score" integer,
    "stress_score" integer
      );


alter table "public"."ct_wellbeing_checks" enable row level security;


  create table "public"."ct_wellness_checkins" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "mood" integer not null,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "date" date default CURRENT_DATE
      );


alter table "public"."ct_wellness_checkins" enable row level security;


  create table "public"."demo_requests" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "email" text not null,
    "institution" text not null,
    "message" text,
    "platform" text not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."demo_requests" enable row level security;


  create table "public"."earnings" (
    "id" integer not null default nextval('public.earnings_id_seq'::regclass),
    "userId" integer not null,
    "bookingId" integer not null,
    "grossAmount" numeric(10,2) not null,
    "platformFee" numeric(10,2) not null,
    "netAmount" numeric(10,2) not null,
    "status" text not null default 'pending'::text,
    "withdrawnAt" timestamp without time zone,
    "createdAt" timestamp without time zone not null default now(),
    "updatedAt" timestamp without time zone not null default now()
      );


alter table "public"."earnings" enable row level security;


  create table "public"."enterprise_invoices" (
    "id" uuid not null default gen_random_uuid(),
    "product" text not null,
    "org_id" uuid,
    "amount_cents" integer not null,
    "currency" text default 'USD'::text,
    "status" text default 'paid'::text,
    "period_start" date,
    "period_end" date,
    "pdf_url" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."enterprise_invoices" enable row level security;


  create table "public"."event_news_comments" (
    "id" bigint generated always as identity not null,
    "post_id" uuid not null,
    "profile_id" bigint not null,
    "body" text not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."event_news_comments" enable row level security;


  create table "public"."event_news_likes" (
    "post_id" uuid not null,
    "profile_id" bigint not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."event_news_likes" enable row level security;


  create table "public"."event_news_posts" (
    "id" uuid not null default gen_random_uuid(),
    "author_profile_id" bigint not null,
    "caption" text,
    "media" jsonb not null default '[]'::jsonb,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."event_news_posts" enable row level security;


  create table "public"."event_registrations" (
    "id" bigint not null default nextval('public.event_registrations_id_seq'::regclass),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "event_id" bigint not null,
    "user_id" integer not null,
    "status" text default 'registered'::text,
    "ticket_type" text default 'general'::text,
    "amount_paid" numeric(10,2) default 0,
    "payment_status" text default 'unpaid'::text,
    "payment_intent_id" text
      );


alter table "public"."event_registrations" enable row level security;


  create table "public"."events" (
    "id" bigint not null default nextval('public.events_id_seq'::regclass),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "organizer_id" integer not null,
    "title" text not null,
    "description" text,
    "category" text,
    "image_url" text,
    "location" text,
    "address" text,
    "event_start_at" timestamp with time zone not null,
    "event_end_at" timestamp with time zone,
    "is_free" boolean default true,
    "price" numeric(10,2) default 0,
    "max_attendees" integer,
    "current_attendees" integer default 0,
    "is_active" boolean default true,
    "is_online" boolean default false,
    "meeting_url" text,
    "tags" text[]
      );


alter table "public"."events" enable row level security;


  create table "public"."events_v2" (
    "id" uuid not null default gen_random_uuid(),
    "host_user_id" uuid not null,
    "title" text not null,
    "description" text,
    "category" text not null,
    "location_lat" numeric(10,8),
    "location_lng" numeric(11,8),
    "address" jsonb,
    "starts_at" timestamp with time zone not null,
    "ends_at" timestamp with time zone,
    "price_cents" integer default 0,
    "is_free" boolean default true,
    "capacity" integer,
    "current_attendees" integer default 0,
    "status" public.event_status default 'published'::public.event_status,
    "image_url" text,
    "tags" text[],
    "embedding_vector" public.vector(384),
    "created_at" timestamp with time zone default now()
      );


alter table "public"."events_v2" enable row level security;


  create table "public"."favorites" (
    "id" integer not null default nextval('public.favorites_id_seq'::regclass),
    "userId" integer not null,
    "activityId" integer not null,
    "createdAt" timestamp without time zone not null default now()
      );


alter table "public"."favorites" enable row level security;


  create table "public"."group_conversation_members" (
    "id" bigint not null default nextval('public.group_conversation_members_id_seq'::regclass),
    "group_conversation_id" bigint not null,
    "profile_id" bigint not null,
    "added_by" bigint,
    "joined_at" timestamp with time zone not null default now(),
    "last_read_at" timestamp with time zone not null default now()
      );


alter table "public"."group_conversation_members" enable row level security;


  create table "public"."group_conversations" (
    "id" bigint not null default nextval('public.group_conversations_id_seq'::regclass),
    "name" text not null default 'Group Chat'::text,
    "activity_id" bigint,
    "created_by" bigint not null,
    "created_at" timestamp with time zone not null default now(),
    "last_message_at" timestamp with time zone,
    "booking_id" bigint
      );


alter table "public"."group_conversations" enable row level security;


  create table "public"."group_messages" (
    "id" bigint not null default nextval('public.group_messages_id_seq'::regclass),
    "group_conversation_id" bigint not null,
    "sender_id" bigint not null,
    "message_text" text not null,
    "created_at" timestamp with time zone not null default now(),
    "is_system_message" boolean not null default false
      );


alter table "public"."group_messages" enable row level security;


  create table "public"."interests" (
    "id" uuid not null default extensions.uuid_generate_v4(),
    "name" text not null,
    "category" text,
    "icon_url" text,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "emoji" character varying(10),
    "description" text,
    "popularity_rank" integer
      );


alter table "public"."interests" enable row level security;


  create table "public"."media_comments" (
    "id" uuid not null default gen_random_uuid(),
    "media_id" uuid not null,
    "commented_by_user_id" integer not null,
    "comment_text" text not null,
    "is_edited" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone
      );


alter table "public"."media_comments" enable row level security;


  create table "public"."media_likes" (
    "id" uuid not null default gen_random_uuid(),
    "media_id" uuid not null,
    "liked_by_user_id" integer not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."media_likes" enable row level security;


  create table "public"."media_uploads" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" integer not null,
    "media_id" uuid,
    "upload_status" character varying(50) default 'pending'::character varying,
    "progress_percentage" integer default 0,
    "processing_status" character varying(50),
    "processing_error" text,
    "storage_bucket" character varying(100),
    "storage_path" character varying(500),
    "storage_provider" character varying(50) default 'supabase'::character varying,
    "created_at" timestamp with time zone default now(),
    "completed_at" timestamp with time zone,
    "expires_at" timestamp with time zone
      );


alter table "public"."media_uploads" enable row level security;


  create table "public"."messages" (
    "id" integer not null default nextval('public.messages_id_seq'::regclass),
    "senderId" integer,
    "recipientId" integer,
    "content" text,
    "isRead" boolean not null default false,
    "readAt" timestamp without time zone,
    "bookingId" integer,
    "createdAt" timestamp without time zone not null default now(),
    "updatedAt" timestamp without time zone not null default now(),
    "conversationId" integer,
    "sender_id" integer,
    "message_text" text,
    "sent_at" timestamp with time zone,
    "conversation_id" integer,
    "is_system_message" boolean not null default false,
    "is_flagged" boolean not null default false,
    "flag_reason" text
      );


alter table "public"."messages" enable row level security;


  create table "public"."notifications" (
    "id" integer not null default nextval('public.notifications_id_seq'::regclass),
    "userId" integer not null,
    "type" character varying(100) not null,
    "title" character varying(255) not null,
    "content" text,
    "relatedBookingId" integer,
    "relatedUserId" integer,
    "isRead" boolean not null default false,
    "readAt" timestamp without time zone,
    "createdAt" timestamp without time zone not null default now(),
    "body" text,
    "data" jsonb default '{}'::jsonb,
    "read" boolean default false,
    "read_at" timestamp with time zone,
    "push_sent" boolean default false
      );


alter table "public"."notifications" enable row level security;


  create table "public"."panicEvents" (
    "id" integer not null default nextval('public."panicEvents_id_seq"'::regclass),
    "userId" integer not null,
    "bookingId" integer,
    "status" character varying(20) not null default 'open'::character varying,
    "location" text,
    "createdAt" timestamp without time zone not null default now(),
    "resolvedAt" timestamp without time zone
      );


alter table "public"."panicEvents" enable row level security;


  create table "public"."payment_methods" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" integer not null,
    "brand" text not null,
    "last4" text not null,
    "exp_month" smallint not null,
    "exp_year" smallint not null,
    "is_default" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."payment_methods" enable row level security;


  create table "public"."payments" (
    "id" integer not null default nextval('public.payments_id_seq'::regclass),
    "bookingId" integer not null,
    "amount" numeric(10,2) not null,
    "currency" character varying(3) not null default 'USD'::character varying,
    "stripePaymentIntentId" character varying(255),
    "status" text not null default 'pending'::text,
    "payoutId" character varying(255),
    "payoutStatus" text not null default 'pending'::text,
    "failureReason" text,
    "createdAt" timestamp without time zone not null default now(),
    "updatedAt" timestamp without time zone not null default now()
      );


alter table "public"."payments" enable row level security;


  create table "public"."photos" (
    "id" integer not null default nextval('public.photos_id_seq'::regclass),
    "userId" integer not null,
    "url" text not null,
    "caption" character varying(255),
    "type" text not null default 'profile'::text,
    "displayOrder" integer not null default 0,
    "isApproved" boolean not null default true,
    "isFlagged" boolean not null default false,
    "createdAt" timestamp without time zone not null default now()
      );


alter table "public"."photos" enable row level security;


  create table "public"."profanity_terms" (
    "term" text not null
      );


alter table "public"."profanity_terms" enable row level security;


  create table "public"."profile_delete_backups" (
    "backup_id" bigint generated always as identity not null,
    "profile_id" bigint not null,
    "auth_id" uuid,
    "full_name" text,
    "display_name" text,
    "username" text,
    "email" text,
    "profile_photo_url" text,
    "cover_photo_url" text,
    "account_status" text,
    "deleted_at" timestamp with time zone not null default now(),
    "raw_row" jsonb not null
      );


alter table "public"."profile_delete_backups" enable row level security;


  create table "public"."profile_likes" (
    "id" uuid not null default gen_random_uuid(),
    "profile_id" integer not null,
    "liked_by_user_id" integer not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."profile_likes" enable row level security;


  create table "public"."profile_media" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" integer not null,
    "media_type" character varying(50) not null,
    "media_url" character varying(500) not null,
    "thumbnail_url" character varying(500),
    "storage_path" character varying(500),
    "file_name" character varying(255),
    "file_size" bigint,
    "mime_type" character varying(100),
    "duration_seconds" integer,
    "width" integer,
    "height" integer,
    "aspect_ratio" character varying(10),
    "position_order" integer default 0,
    "is_visible" boolean default true,
    "caption" text,
    "is_approved" boolean default true,
    "moderation_status" character varying(50) default 'approved'::character varying,
    "flagged_count" integer default 0,
    "likes_count" integer default 0,
    "comments_count" integer default 0,
    "shares_count" integer default 0,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone,
    "privacy_setting" text default 'public'::text
      );


alter table "public"."profile_media" enable row level security;


  create table "public"."profiles" (
    "id" integer not null default nextval('public.profiles_id_seq'::regclass),
    "userId" integer,
    "name" character varying(255),
    "bio" text,
    "location" character varying(255),
    "photos" jsonb default '[]'::jsonb,
    "languages" text[] not null default ARRAY['en'::text],
    "interests" text[] default '{}'::text[],
    "createdAt" timestamp without time zone default now(),
    "updatedAt" timestamp without time zone default now(),
    "auth_id" text,
    "full_name" text,
    "display_name" text,
    "email" text,
    "profile_photo_url" text,
    "avatar_url" text,
    "avatar_storage_path" text,
    "date_of_birth" date,
    "hourly_rate" numeric,
    "rating" numeric,
    "review_count" integer default 0,
    "roles" text[] default '{Companion}'::text[],
    "activities" text[] default '{}'::text[],
    "is_verified" boolean default false,
    "is_bouncer_verified" boolean default false,
    "certifications" text[] default '{}'::text[],
    "incident_history_count" integer default 0,
    "username" character varying(50),
    "cover_photo_url" character varying(500),
    "headline" character varying(200),
    "gender" character varying(50),
    "sexual_orientation" character varying(100),
    "phone_number" character varying(20),
    "city" character varying(100),
    "state_province" character varying(100),
    "country" character varying(100),
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "show_location" boolean default true,
    "identity_verification_date" timestamp with time zone,
    "id_document_url" character varying(500),
    "verification_status" character varying(50) default 'unverified'::character varying,
    "is_public" boolean default true,
    "is_discoverable" boolean default true,
    "show_online_status" boolean default true,
    "last_active" timestamp with time zone,
    "profile_views_count" integer default 0,
    "likes_received_count" integer default 0,
    "reviews_count" integer default 0,
    "average_rating" numeric(2,1),
    "status" character varying(50) default 'active'::character varying,
    "account_type" character varying(50) default 'standard'::character varying,
    "deleted_at" timestamp with time zone,
    "cover_storage_path" text,
    "availability" text[] default '{}'::text[],
    "updated_at" timestamp with time zone default timezone('utc'::text, now()),
    "availability_timezone" text default 'UTC'::text,
    "min_booking_notice_hours" integer default 24,
    "max_advance_booking_days" integer default 60,
    "account_status" text default 'active'::text,
    "paused_at" timestamp with time zone,
    "paused_until" timestamp with time zone,
    "deletion_requested_at" timestamp with time zone,
    "deletion_scheduled_for" timestamp with time zone,
    "deletion_reason" text,
    "preferred_language" text not null default 'en'::text,
    "profile_visibility" text not null default 'public'::text,
    "fcm_token" text,
    "fcm_token_updated_at" timestamp with time zone,
    "bio_flagged" boolean not null default false,
    "service_types" text[],
    "verified" boolean default false,
    "total_reviews" integer default 0,
    "wallet_balance_cents" integer default 0,
    "trust_score" integer default 50,
    "identity_verified" boolean default false,
    "push_token" text,
    "role" text default 'user'::text,
    "location_lat" numeric(10,8),
    "location_lng" numeric(11,8),
    "location_city" text
      );


alter table "public"."profiles" enable row level security;


  create table "public"."profiles_backup" (
    "id" integer,
    "userId" integer,
    "name" character varying(255),
    "bio" text,
    "location" character varying(255),
    "photos" jsonb,
    "languages" jsonb,
    "interests" text[],
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "auth_id" text,
    "full_name" text,
    "display_name" text,
    "email" text,
    "profile_photo_url" text,
    "avatar_url" text,
    "avatar_storage_path" text,
    "date_of_birth" date,
    "hourly_rate" numeric,
    "rating" numeric,
    "review_count" integer,
    "roles" text[],
    "activities" text[],
    "is_verified" boolean,
    "is_bouncer_verified" boolean,
    "certifications" text[],
    "incident_history_count" integer,
    "username" character varying(50),
    "cover_photo_url" character varying(500),
    "headline" character varying(200),
    "gender" character varying(50),
    "sexual_orientation" character varying(100),
    "phone_number" character varying(20),
    "city" character varying(100),
    "state_province" character varying(100),
    "country" character varying(100),
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "show_location" boolean,
    "identity_verification_date" timestamp with time zone,
    "id_document_url" character varying(500),
    "verification_status" character varying(50),
    "is_public" boolean,
    "is_discoverable" boolean,
    "show_online_status" boolean,
    "last_active" timestamp with time zone,
    "profile_views_count" integer,
    "likes_received_count" integer,
    "reviews_count" integer,
    "average_rating" numeric(2,1),
    "status" character varying(50),
    "account_type" character varying(50),
    "deleted_at" timestamp with time zone,
    "cover_storage_path" text,
    "availability" text[],
    "updated_at" timestamp with time zone
      );


alter table "public"."profiles_backup" enable row level security;


  create table "public"."push_tokens" (
    "id" uuid not null default gen_random_uuid(),
    "profile_id" text not null,
    "token" text not null,
    "platform" text not null default 'web'::text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."push_tokens" enable row level security;


  create table "public"."reports" (
    "id" integer not null default nextval('public.reports_id_seq'::regclass),
    "reporterId" integer not null,
    "targetUserId" integer not null,
    "bookingId" integer,
    "category" character varying(50) not null default 'safety'::character varying,
    "reason" character varying(255) not null,
    "notes" text,
    "status" character varying(20) not null default 'open'::character varying,
    "createdAt" timestamp without time zone not null default now()
      );


alter table "public"."reports" enable row level security;


  create table "public"."review_notification_outbox" (
    "id" bigint generated always as identity not null,
    "event_type" text not null,
    "booking_id" text,
    "review_id" uuid,
    "recipient_profile_id" bigint,
    "payload" jsonb not null default '{}'::jsonb,
    "send_at" timestamp with time zone,
    "sent_at" timestamp with time zone,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."review_notification_outbox" enable row level security;


  create table "public"."reviews" (
    "id" integer not null default nextval('public.reviews_id_seq'::regclass),
    "bookingId" integer not null,
    "reviewerId" integer not null,
    "revieweeId" integer not null,
    "rating" integer not null,
    "title" character varying(255),
    "content" text,
    "communicationRating" integer,
    "reliabilityRating" integer,
    "safetyRating" integer,
    "photoUrls" jsonb not null,
    "response" text,
    "respondedAt" timestamp without time zone,
    "isFlagged" boolean not null default false,
    "flagReason" character varying(255),
    "createdAt" timestamp without time zone not null default now(),
    "updatedAt" timestamp without time zone not null default now(),
    "entity_id" uuid,
    "entity_type" text,
    "voice_transcript" text,
    "review_text" text,
    "bud_extracted" boolean default false,
    "moderation_status" text default 'pending'::text
      );


alter table "public"."reviews" enable row level security;


  create table "public"."reviews_v2" (
    "id" uuid not null default gen_random_uuid(),
    "reviewer_id" uuid not null,
    "entity_id" uuid not null,
    "entity_type" public.entity_type not null,
    "booking_id" uuid,
    "rating" integer not null,
    "voice_transcript" text,
    "review_text" text,
    "bud_extracted" boolean default false,
    "moderation_status" public.moderation_status default 'pending'::public.moderation_status,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."reviews_v2" enable row level security;


  create table "public"."roles" (
    "id" integer not null default nextval('public.roles_id_seq'::regclass),
    "name" character varying(50) not null,
    "description" text,
    "createdAt" timestamp without time zone not null default now()
      );


alter table "public"."roles" enable row level security;


  create table "public"."safetyFlags" (
    "id" integer not null default nextval('public."safetyFlags_id_seq"'::regclass),
    "bookingId" integer not null,
    "reporterId" integer not null,
    "reportedUserId" integer not null,
    "severity" character varying(20) not null default 'medium'::character varying,
    "reason" character varying(255) not null,
    "notes" text,
    "status" character varying(20) not null default 'open'::character varying,
    "createdAt" timestamp without time zone not null default now(),
    "updatedAt" timestamp without time zone not null default now()
      );


alter table "public"."safetyFlags" enable row level security;


  create table "public"."seo_ai_rank_snapshots" (
    "id" bigint generated always as identity not null,
    "tracking_query_id" bigint,
    "provider" text not null,
    "query" text not null,
    "target_path" text not null,
    "rank_position" integer,
    "visibility_score" numeric(6,2),
    "observed_at" timestamp with time zone not null default now(),
    "source" text not null default 'manual'::text,
    "notes" text
      );


alter table "public"."seo_ai_rank_snapshots" enable row level security;


  create table "public"."seo_ai_tracking_queries" (
    "id" bigint generated always as identity not null,
    "provider" text not null,
    "query" text not null,
    "target_path" text not null,
    "is_active" boolean not null default true,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."seo_ai_tracking_queries" enable row level security;


  create table "public"."service_availability" (
    "id" bigint not null default nextval('public.service_availability_id_seq'::regclass),
    "created_at" timestamp with time zone default now(),
    "provider_id" integer not null,
    "service_id" integer,
    "slot_date" text not null,
    "slot_time" text not null,
    "available" boolean default true
      );


alter table "public"."service_availability" enable row level security;


  create table "public"."service_bookings" (
    "id" bigint not null default nextval('public.service_bookings_id_seq'::regclass),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "service_id" integer,
    "client_id" integer not null,
    "provider_id" integer not null,
    "scheduled_at" timestamp with time zone,
    "hours" numeric(4,1) default 1,
    "total_amount" numeric(10,2) default 0,
    "status" text default 'pending'::text,
    "notes" text,
    "address" text,
    "payment_status" text default 'unpaid'::text,
    "payment_intent_id" text
      );


alter table "public"."service_bookings" enable row level security;


  create table "public"."service_providers_v2" (
    "id" uuid not null default gen_random_uuid(),
    "profile_id" integer not null,
    "service_types" text[] not null default '{}'::text[],
    "hourly_rate_cents" integer default 0,
    "certifications" jsonb default '[]'::jsonb,
    "rating_avg" numeric(3,2) default 0,
    "review_count" integer default 0,
    "verified" boolean default false,
    "status" text default 'active'::text,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."service_reviews" (
    "id" bigint not null default nextval('public.service_reviews_id_seq'::regclass),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "service_id" integer not null,
    "booking_id" bigint,
    "reviewer_id" integer not null,
    "rating" integer,
    "comment" text
      );


alter table "public"."service_reviews" enable row level security;


  create table "public"."services" (
    "id" integer not null default nextval('public.services_id_seq'::regclass),
    "userId" integer not null,
    "title" character varying(255) not null,
    "category" character varying(100) not null,
    "description" text,
    "rate" numeric(10,2) not null,
    "isActive" boolean not null default true,
    "createdAt" timestamp without time zone not null default now(),
    "updatedAt" timestamp without time zone not null default now(),
    "provider_id" integer,
    "price_per_hour" numeric(10,2),
    "is_free" boolean default false,
    "min_hours" numeric(4,1) default 1,
    "location" text,
    "availability_notes" text,
    "is_active" boolean default true,
    "image_url" text,
    "tags" text[],
    "rating" numeric(3,2) default 0,
    "total_reviews" integer default 0,
    "total_bookings" integer default 0,
    "updated_at" timestamp with time zone default now(),
    "created_at" timestamp with time zone default now()
      );


alter table "public"."services" enable row level security;


  create table "public"."subscriptions" (
    "id" integer not null default nextval('public.subscriptions_id_seq'::regclass),
    "userId" integer not null,
    "plan" character varying(50) not null default 'basic'::character varying,
    "status" character varying(20) not null default 'active'::character varying,
    "currentPeriodEnd" timestamp without time zone,
    "createdAt" timestamp without time zone not null default now(),
    "profile_id" bigint,
    "product" text,
    "tier" text,
    "currency_code" text not null default 'USD'::text,
    "price_cents" integer not null default 0,
    "discount_percent" numeric(5,2) not null default 0,
    "promo_ends_at" timestamp with time zone,
    "current_period_start" timestamp with time zone not null default now(),
    "current_period_end" timestamp with time zone not null default (now() + '1 mon'::interval),
    "metadata" jsonb not null default '{}'::jsonb,
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."subscriptions" enable row level security;


  create table "public"."transactions" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone default now(),
    "wallet_id" uuid not null,
    "user_id" integer not null,
    "type" text not null,
    "amount_cents" integer not null,
    "description" text,
    "reference_id" uuid,
    "reference_type" text,
    "status" text default 'completed'::text
      );


alter table "public"."transactions" enable row level security;


  create table "public"."transactions_v2" (
    "id" uuid not null default gen_random_uuid(),
    "wallet_id" uuid not null,
    "user_id" uuid not null,
    "type" text not null,
    "amount_cents" integer not null,
    "description" text,
    "reference_id" uuid,
    "reference_type" text,
    "status" text default 'completed'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."transactions_v2" enable row level security;


  create table "public"."user_interests" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" integer not null,
    "interest_id" uuid not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."user_interests" enable row level security;


  create table "public"."users" (
    "id" integer not null default nextval('public.users_id_seq'::regclass),
    "openId" character varying(64) not null,
    "name" text,
    "email" character varying(320),
    "loginMethod" character varying(64),
    "role" text not null default 'user'::text,
    "bio" text,
    "profilePhotoUrl" text,
    "location" character varying(255),
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "trustScore" integer not null default 0,
    "isVerified" boolean not null default false,
    "verificationBadge" text not null default 'none'::text,
    "verificationDate" timestamp without time zone,
    "totalBookings" integer not null default 0,
    "totalEarnings" numeric(12,2) not null default '0'::numeric,
    "averageRating" numeric(3,2) not null default '0'::numeric,
    "totalReviews" integer not null default 0,
    "accountStatus" text not null default 'active'::text,
    "createdAt" timestamp without time zone not null default now(),
    "updatedAt" timestamp without time zone not null default now(),
    "lastSignedIn" timestamp without time zone not null default now(),
    "isClient" boolean not null default true,
    "isCompanion" boolean not null default false,
    "isBouncer" boolean not null default false,
    "companionHourlyRate" numeric(8,2),
    "bouncerHourlyRate" numeric(8,2),
    "verificationLevel" text not null default 'none'::text,
    "safetyExperience" text,
    "serviceModes" jsonb not null default '[]'::jsonb,
    "onboardingCompleted" boolean not null default false,
    "introVideoUrl" text,
    "portfolioPhotoUrls" jsonb not null default '[]'::jsonb,
    "safetyCertifications" jsonb not null default '[]'::jsonb
      );


alter table "public"."users" enable row level security;


  create table "public"."users_v2" (
    "id" uuid not null default gen_random_uuid(),
    "phone" text,
    "email" text,
    "display_name" text not null default ''::text,
    "avatar_url" text,
    "bio" text,
    "preferred_language" text default 'en'::text,
    "location_lat" numeric(10,8),
    "location_lng" numeric(11,8),
    "location_city" text,
    "identity_verified" boolean default false,
    "trust_score" integer default 50,
    "role" public.user_role default 'user'::public.user_role,
    "bud_voice_enabled" boolean default true,
    "supabase_auth_id" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );



  create table "public"."verificationAudits" (
    "id" integer not null default nextval('public."verificationAudits_id_seq"'::regclass),
    "verificationId" integer not null,
    "reviewerId" integer not null,
    "action" character varying(20) not null,
    "notes" text,
    "createdAt" timestamp without time zone not null default now()
      );


alter table "public"."verificationAudits" enable row level security;


  create table "public"."verificationRequests" (
    "id" integer not null default nextval('public."verificationRequests_id_seq"'::regclass),
    "userId" integer not null,
    "documentType" character varying(100) not null,
    "documentUrl" text not null,
    "status" text not null default 'pending'::text,
    "reviewedBy" integer,
    "reviewNotes" text,
    "reviewedAt" timestamp without time zone,
    "createdAt" timestamp without time zone not null default now(),
    "updatedAt" timestamp without time zone not null default now()
      );


alter table "public"."verificationRequests" enable row level security;


  create table "public"."vip_accounts" (
    "email" text not null,
    "tier" text not null default 'enterprise'::text,
    "note" text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."vip_accounts" enable row level security;


  create table "public"."voice_studio_clones" (
    "id" uuid not null default gen_random_uuid(),
    "profile_id" integer not null,
    "name" text not null,
    "language" text default 'en'::text,
    "sample_storage_path" text,
    "oci_voice_id" text,
    "status" text not null default 'processing'::text,
    "duration_seconds" numeric(8,2),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."voice_studio_clones" enable row level security;


  create table "public"."voice_studio_jobs" (
    "id" uuid not null default gen_random_uuid(),
    "profile_id" integer not null,
    "job_type" text not null,
    "status" text not null default 'pending'::text,
    "input_text" text,
    "voice_id" text,
    "language" text default 'en'::text,
    "speed" numeric(3,2) default 1.0,
    "duration_seconds" numeric(8,2),
    "output_storage_path" text,
    "output_url" text,
    "error_message" text,
    "metadata" jsonb default '{}'::jsonb,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."voice_studio_jobs" enable row level security;


  create table "public"."voice_studio_usage" (
    "id" uuid not null default gen_random_uuid(),
    "profile_id" integer not null,
    "month_year" text not null,
    "tts_minutes_used" numeric(10,2) default 0,
    "clone_minutes_used" numeric(10,2) default 0,
    "clone_count" integer default 0,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."voice_studio_usage" enable row level security;


  create table "public"."waitlist" (
    "id" bigint not null default nextval('public.waitlist_id_seq'::regclass),
    "email" text not null,
    "location" text,
    "age" integer,
    "gender" text,
    "services" text[],
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."waitlist" enable row level security;


  create table "public"."wallets" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "user_id" integer not null,
    "balance_cents" integer default 0,
    "pending_payout_cents" integer default 0,
    "total_earned_cents" integer default 0,
    "currency" text default 'CAD'::text
      );


alter table "public"."wallets" enable row level security;


  create table "public"."wallets_v2" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "balance_cents" integer default 0,
    "pending_payout_cents" integer default 0,
    "total_earned_cents" integer default 0,
    "currency" text default 'CAD'::text,
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."wallets_v2" enable row level security;


  create table "public"."wc_ai_agents" (
    "id" uuid not null default gen_random_uuid(),
    "business_profile_id" integer not null,
    "name" text not null,
    "role" text not null default 'custom'::text,
    "department" text,
    "languages" text[] default '{en}'::text[],
    "greeting_script" text,
    "capabilities" jsonb default '{}'::jsonb,
    "voice_config" jsonb default '{}'::jsonb,
    "routing_rules" jsonb default '[]'::jsonb,
    "widget_config" jsonb default '{}'::jsonb,
    "status" text default 'draft'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "assigned_phone_number_id" uuid,
    "oci_voice_id" text
      );


alter table "public"."wc_ai_agents" enable row level security;


  create table "public"."wc_ai_cases" (
    "id" uuid not null default gen_random_uuid(),
    "ai_employee_id" uuid not null,
    "owner_profile_id" integer not null,
    "title" text not null,
    "description" text,
    "status" text not null default 'open'::text,
    "priority" text not null default 'medium'::text,
    "category" text,
    "assigned_to" text,
    "messages" jsonb default '[]'::jsonb,
    "metadata" jsonb default '{}'::jsonb,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."wc_ai_cases" enable row level security;


  create table "public"."wc_ai_employees" (
    "id" uuid not null default gen_random_uuid(),
    "owner_profile_id" integer not null,
    "name" text not null,
    "voice_id" text,
    "persona_prompt" text,
    "platform" text default 'wevsocial'::text,
    "active" boolean default true,
    "calls_handled" integer default 0,
    "created_at" timestamp with time zone default now(),
    "role" text default 'support'::text,
    "system_prompt" text,
    "triage_rules" jsonb default '[]'::jsonb,
    "integrations" jsonb default '{}'::jsonb,
    "deploy_embed_key" text,
    "deployed_domains" text[] default '{}'::text[],
    "voice_enabled" boolean default false,
    "escalation_email" text,
    "stats" jsonb default '{"resolved": 0, "escalated": 0, "total_conversations": 0}'::jsonb
      );


alter table "public"."wc_ai_employees" enable row level security;


  create table "public"."wc_ai_staff" (
    "id" uuid not null default gen_random_uuid(),
    "owner_profile_id" integer not null,
    "name" text not null,
    "voice" text not null default 'en_US-amy-medium'::text,
    "status" text not null default 'inactive'::text,
    "assigned_queue_id" uuid,
    "auto_answer" boolean not null default false,
    "greeting_text" text default 'Hello, how can I help you today?'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."wc_ai_staff" enable row level security;


  create table "public"."wc_analytics" (
    "id" uuid not null default gen_random_uuid(),
    "call_log_id" uuid,
    "room_id" uuid,
    "event_type" text not null,
    "profile_id" integer,
    "platform" text default 'wevsocial'::text,
    "metadata" jsonb default '{}'::jsonb,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."wc_analytics" enable row level security;


  create table "public"."wc_call_sessions" (
    "id" uuid not null default gen_random_uuid(),
    "call_control_id" text,
    "business_profile_id" integer,
    "ai_agent_id" uuid,
    "phone_number_id" uuid,
    "caller_phone" text,
    "called_phone" text,
    "channel" text default 'pstn'::text,
    "direction" text default 'inbound'::text,
    "status" text default 'active'::text,
    "transcript" jsonb default '[]'::jsonb,
    "exchange_count" integer default 0,
    "started_at" timestamp with time zone default now(),
    "ended_at" timestamp with time zone,
    "duration_seconds" integer
      );



  create table "public"."wc_calls" (
    "id" uuid not null default gen_random_uuid(),
    "caller_profile_id" integer not null,
    "callee_profile_id" integer not null,
    "status" text not null default 'ringing'::text,
    "started_at" timestamp with time zone,
    "ended_at" timestamp with time zone,
    "duration_seconds" integer,
    "call_type" text not null default 'voice'::text,
    "created_at" timestamp with time zone default now(),
    "room_id" uuid
      );


alter table "public"."wc_calls" enable row level security;


  create table "public"."wc_contacts" (
    "id" uuid not null default gen_random_uuid(),
    "owner_profile_id" integer not null,
    "name" text not null,
    "phone" text,
    "email" text,
    "company" text,
    "role" text,
    "notes" text,
    "avatar_url" text,
    "internal_profile_id" integer,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."wc_contacts" enable row level security;


  create table "public"."wc_departments" (
    "id" uuid not null default gen_random_uuid(),
    "business_profile_id" integer not null,
    "name" text not null,
    "description" text,
    "color" text default '#7C3AED'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."wc_departments" enable row level security;


  create table "public"."wc_entitlements" (
    "profile_id" integer not null,
    "platform" text default 'wevsocial'::text,
    "tier" text not null default 'free'::text,
    "call_minutes_used" integer default 0,
    "call_minutes_limit" integer default '-1'::integer,
    "recording_hours_used" integer default 0,
    "recording_hours_limit" integer default 0,
    "ai_employees_limit" integer default 0,
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."wc_entitlements" enable row level security;


  create table "public"."wc_followup_tasks" (
    "id" uuid not null default gen_random_uuid(),
    "business_profile_id" integer not null,
    "call_control_id" text,
    "caller_phone" text,
    "transcript_summary" text,
    "suggested_followup_at" timestamp with time zone,
    "email_sent_at" timestamp with time zone,
    "status" text default 'pending'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."wc_followup_tasks" enable row level security;


  create table "public"."wc_messages" (
    "id" uuid not null default gen_random_uuid(),
    "from_profile_id" integer not null,
    "to_profile_id" integer not null,
    "content" text not null,
    "created_at" timestamp with time zone default now(),
    "read_at" timestamp with time zone,
    "channel" text default 'wev'::text,
    "phone_number_id" uuid,
    "telnyx_message_id" text,
    "sender_phone" text,
    "recipient_phone" text,
    "direction" text default 'inbound'::text,
    "media_urls" jsonb default '[]'::jsonb
      );


alter table "public"."wc_messages" enable row level security;


  create table "public"."wc_number_requests" (
    "id" uuid not null default gen_random_uuid(),
    "profile_id" integer not null,
    "country" text not null,
    "number_type" text not null,
    "business_name" text,
    "status" text not null default 'pending'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."wc_number_requests" enable row level security;


  create table "public"."wc_org_settings" (
    "profile_id" integer not null,
    "org_name" text,
    "website" text,
    "industry" text,
    "timezone" text,
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."wc_org_settings" enable row level security;


  create table "public"."wc_org_users" (
    "id" uuid not null default gen_random_uuid(),
    "business_profile_id" integer not null,
    "profile_id" integer not null,
    "department_id" uuid,
    "role_id" uuid,
    "display_name" text,
    "extension" text,
    "is_active" boolean default true,
    "is_available" boolean default true,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."wc_org_users" enable row level security;


  create table "public"."wc_participants" (
    "id" uuid not null default gen_random_uuid(),
    "room_id" uuid,
    "profile_id" integer not null,
    "joined_at" timestamp with time zone default now(),
    "left_at" timestamp with time zone,
    "role" text not null default 'participant'::text,
    "audio_muted" boolean default false,
    "video_muted" boolean default false
      );


alter table "public"."wc_participants" enable row level security;


  create table "public"."wc_phone_numbers" (
    "id" uuid not null default gen_random_uuid(),
    "business_profile_id" integer not null,
    "telnyx_number_id" text,
    "phone_number" text not null,
    "number_type" text not null default 'local'::text,
    "country_code" text default 'CA'::text,
    "region" text,
    "monthly_cost_usd" numeric(8,4) default 1.00,
    "capabilities" jsonb default '{"sms": true, "voice": true}'::jsonb,
    "status" text default 'active'::text,
    "friendly_name" text,
    "purchased_at" timestamp with time zone default now(),
    "created_at" timestamp with time zone default now(),
    "ai_agent_id" uuid
      );


alter table "public"."wc_phone_numbers" enable row level security;


  create table "public"."wc_queue" (
    "id" uuid not null default gen_random_uuid(),
    "business_profile_id" integer not null,
    "caller_profile_id" integer not null,
    "caller_name" text,
    "platform" text not null default 'wevsocial'::text,
    "position" integer,
    "status" text not null default 'waiting'::text,
    "wait_started_at" timestamp with time zone default now(),
    "connected_at" timestamp with time zone,
    "abandoned_at" timestamp with time zone,
    "agent_profile_id" integer,
    "channel" text default 'wev'::text,
    "phone_number_id" uuid,
    "department_id" uuid,
    "caller_phone" text,
    "telnyx_call_control_id" text
      );


alter table "public"."wc_queue" enable row level security;


  create table "public"."wc_recordings" (
    "id" uuid not null default gen_random_uuid(),
    "room_id" uuid,
    "call_log_id" uuid,
    "owner_profile_id" integer not null,
    "title" text,
    "file_path" text,
    "file_url" text,
    "duration_seconds" integer default 0,
    "size_bytes" bigint default 0,
    "has_transcript" boolean default false,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."wc_recordings" enable row level security;


  create table "public"."wc_roles" (
    "id" uuid not null default gen_random_uuid(),
    "business_profile_id" integer not null,
    "name" text not null,
    "permissions" jsonb default '{"can_send_sms": true, "can_make_calls": true, "can_manage_queue": false, "can_manage_users": false, "can_receive_calls": true, "can_manage_numbers": false}'::jsonb,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."wc_roles" enable row level security;


  create table "public"."wc_rooms" (
    "id" uuid not null default gen_random_uuid(),
    "name" text,
    "type" text not null,
    "host_profile_id" integer not null,
    "platform" text not null default 'wevsocial'::text,
    "status" text not null default 'active'::text,
    "max_participants" integer default 25,
    "recording_enabled" boolean default false,
    "transcript_enabled" boolean default false,
    "created_at" timestamp with time zone default now(),
    "ended_at" timestamp with time zone
      );


alter table "public"."wc_rooms" enable row level security;


  create table "public"."wc_routing_edges" (
    "id" uuid not null default gen_random_uuid(),
    "rule_id" uuid not null,
    "source_step_id" uuid not null,
    "target_step_id" uuid not null,
    "label" text,
    "condition_value" text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."wc_routing_edges" enable row level security;


  create table "public"."wc_routing_rules" (
    "id" uuid not null default gen_random_uuid(),
    "business_profile_id" integer not null,
    "phone_number_id" uuid,
    "name" text not null,
    "channel" text not null default 'voice'::text,
    "priority_order" integer default 0,
    "conditions" jsonb default '{}'::jsonb,
    "action" text not null default 'queue'::text,
    "target_department_id" uuid,
    "target_user_id" uuid,
    "fallback_action" text default 'voicemail'::text,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "description" text,
    "canvas_layout" jsonb default '{}'::jsonb
      );


alter table "public"."wc_routing_rules" enable row level security;


  create table "public"."wc_routing_steps" (
    "id" uuid not null default gen_random_uuid(),
    "rule_id" uuid not null,
    "business_profile_id" integer not null,
    "step_type" text not null,
    "label" text not null,
    "config" jsonb default '{}'::jsonb,
    "notes" jsonb default '[]'::jsonb,
    "position_x" numeric default 0,
    "position_y" numeric default 0,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."wc_routing_steps" enable row level security;


  create table "public"."wc_signaling" (
    "id" uuid not null default gen_random_uuid(),
    "call_id" uuid not null,
    "from_profile_id" integer not null,
    "to_profile_id" integer not null,
    "type" text not null,
    "payload" jsonb not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."wc_signaling" enable row level security;


  create table "public"."wc_transcripts" (
    "id" uuid not null default gen_random_uuid(),
    "recording_id" uuid,
    "call_log_id" uuid,
    "owner_profile_id" integer not null,
    "full_text" text,
    "language" text default 'en'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."wc_transcripts" enable row level security;


  create table "public"."wc_whatsapp_configs" (
    "profile_id" bigint not null,
    "phone_number_id" text not null,
    "access_token" text not null,
    "verify_token" text not null default 'wevconnect-whatsapp-verify-2026'::text,
    "webhook_url" text,
    "connected" boolean not null default true,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."wc_whatsapp_configs" enable row level security;


  create table "public"."wc_whatsapp_messages" (
    "id" uuid not null default gen_random_uuid(),
    "profile_id" bigint not null,
    "wa_message_id" text,
    "direction" text not null,
    "from_number" text not null,
    "to_number" text not null,
    "body" text not null default ''::text,
    "status" text not null default 'received'::text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."wc_whatsapp_messages" enable row level security;


  create table "public"."webrtc_signals" (
    "id" bigint not null default nextval('public.webrtc_signals_id_seq'::regclass),
    "room_id" text not null,
    "sender_id" integer,
    "signal_type" text not null,
    "payload" jsonb not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."webrtc_signals" enable row level security;

alter sequence "drizzle"."__drizzle_migrations_id_seq" owned by "drizzle"."__drizzle_migrations"."id";

alter sequence "public"."activities_id_seq" owned by "public"."activities"."id";

alter sequence "public"."activity_bookings_id_seq" owned by "public"."activity_bookings"."id";

alter sequence "public"."activity_reviews_id_seq" owned by "public"."activity_reviews"."id";

alter sequence "public"."adminLogs_id_seq" owned by "public"."adminLogs"."id";

alter sequence "public"."availability_id_seq" owned by "public"."availability"."id";

alter sequence "public"."bookingBouncers_id_seq" owned by "public"."bookingBouncers"."id";

alter sequence "public"."bookings_id_seq" owned by "public"."bookings"."id";

alter sequence "public"."bouncer_services_id_seq" owned by "public"."bouncer_services"."id";

alter sequence "public"."companion_activities_id_seq" owned by "public"."companion_activities"."id";

alter sequence "public"."companion_services_id_seq" owned by "public"."companion_services"."id";

alter sequence "public"."conversations_id_seq" owned by "public"."conversations"."id";

alter sequence "public"."earnings_id_seq" owned by "public"."earnings"."id";

alter sequence "public"."event_registrations_id_seq" owned by "public"."event_registrations"."id";

alter sequence "public"."events_id_seq" owned by "public"."events"."id";

alter sequence "public"."favorites_id_seq" owned by "public"."favorites"."id";

alter sequence "public"."group_conversation_members_id_seq" owned by "public"."group_conversation_members"."id";

alter sequence "public"."group_conversations_id_seq" owned by "public"."group_conversations"."id";

alter sequence "public"."group_messages_id_seq" owned by "public"."group_messages"."id";

alter sequence "public"."messages_id_seq" owned by "public"."messages"."id";

alter sequence "public"."notifications_id_seq" owned by "public"."notifications"."id";

alter sequence "public"."panicEvents_id_seq" owned by "public"."panicEvents"."id";

alter sequence "public"."payments_id_seq" owned by "public"."payments"."id";

alter sequence "public"."photos_id_seq" owned by "public"."photos"."id";

alter sequence "public"."profiles_id_seq" owned by "public"."profiles"."id";

alter sequence "public"."reports_id_seq" owned by "public"."reports"."id";

alter sequence "public"."reviews_id_seq" owned by "public"."reviews"."id";

alter sequence "public"."roles_id_seq" owned by "public"."roles"."id";

alter sequence "public"."safetyFlags_id_seq" owned by "public"."safetyFlags"."id";

alter sequence "public"."service_availability_id_seq" owned by "public"."service_availability"."id";

alter sequence "public"."service_bookings_id_seq" owned by "public"."service_bookings"."id";

alter sequence "public"."service_reviews_id_seq" owned by "public"."service_reviews"."id";

alter sequence "public"."services_id_seq" owned by "public"."services"."id";

alter sequence "public"."subscriptions_id_seq" owned by "public"."subscriptions"."id";

alter sequence "public"."users_id_seq" owned by "public"."users"."id";

alter sequence "public"."verificationAudits_id_seq" owned by "public"."verificationAudits"."id";

alter sequence "public"."verificationRequests_id_seq" owned by "public"."verificationRequests"."id";

alter sequence "public"."waitlist_id_seq" owned by "public"."waitlist"."id";

alter sequence "public"."webrtc_signals_id_seq" owned by "public"."webrtc_signals"."id";

CREATE UNIQUE INDEX __drizzle_migrations_pkey ON drizzle.__drizzle_migrations USING btree (id);

CREATE UNIQUE INDEX account_activity_log_pkey ON public.account_activity_log USING btree (id);

CREATE INDEX activities_category_idx ON public.activities USING btree (category);

CREATE UNIQUE INDEX activities_media_pkey ON public.activities_media USING btree (id);

CREATE UNIQUE INDEX activities_pkey ON public.activities USING btree (id);

CREATE INDEX "activities_userId_idx" ON public.activities USING btree ("userId");

CREATE INDEX activity_bookings_activity_id_idx ON public.activity_bookings USING btree (activity_id);

CREATE UNIQUE INDEX activity_bookings_activity_id_user_id_booking_date_key ON public.activity_bookings USING btree (activity_id, user_id, booking_date);

CREATE UNIQUE INDEX activity_bookings_pkey ON public.activity_bookings USING btree (id);

CREATE INDEX activity_bookings_user_id_idx ON public.activity_bookings USING btree (user_id);

CREATE UNIQUE INDEX activity_reviews_booking_id_key ON public.activity_reviews USING btree (booking_id);

CREATE UNIQUE INDEX activity_reviews_pkey ON public.activity_reviews USING btree (id);

CREATE UNIQUE INDEX activity_shares_pkey ON public.activity_shares USING btree (id);

CREATE UNIQUE INDEX activity_views_pkey ON public.activity_views USING btree (id);

CREATE INDEX "adminLogs_actor_idx" ON public."adminLogs" USING btree ("actorId");

CREATE INDEX "adminLogs_entity_idx" ON public."adminLogs" USING btree ("entityId");

CREATE UNIQUE INDEX "adminLogs_pkey" ON public."adminLogs" USING btree (id);

CREATE UNIQUE INDEX admin_access_emails_pkey ON public.admin_access_emails USING btree (email);

CREATE UNIQUE INDEX api_keys_api_key_hash_key ON public.api_keys USING btree (api_key_hash);

CREATE UNIQUE INDEX api_keys_pkey ON public.api_keys USING btree (id);

CREATE UNIQUE INDEX availability_pkey ON public.availability USING btree (id);

CREATE UNIQUE INDEX availability_slots_pkey ON public.availability_slots USING btree (id);

CREATE UNIQUE INDEX availability_slots_profile_id_day_of_week_start_time_end_ti_key ON public.availability_slots USING btree (profile_id, day_of_week, start_time, end_time);

CREATE INDEX "availability_userId_idx" ON public.availability USING btree ("userId");

CREATE UNIQUE INDEX blocked_dates_pkey ON public.blocked_dates USING btree (id);

CREATE UNIQUE INDEX blocked_dates_profile_id_blocked_date_key ON public.blocked_dates USING btree (profile_id, blocked_date);

CREATE INDEX "bookingBouncers_booking_idx" ON public."bookingBouncers" USING btree ("bookingId");

CREATE INDEX "bookingBouncers_bouncer_idx" ON public."bookingBouncers" USING btree ("bouncerId");

CREATE UNIQUE INDEX "bookingBouncers_pkey" ON public."bookingBouncers" USING btree (id);

CREATE UNIQUE INDEX "bookingBouncers_unique" ON public."bookingBouncers" USING btree ("bookingId", "bouncerId");

CREATE UNIQUE INDEX booking_review_audit_log_pkey ON public.booking_review_audit_log USING btree (id);

CREATE UNIQUE INDEX booking_review_flags_pkey ON public.booking_review_flags USING btree (id);

CREATE UNIQUE INDEX booking_review_helpful_votes_pkey ON public.booking_review_helpful_votes USING btree (review_id, voter_profile_id);

CREATE UNIQUE INDEX booking_review_media_pkey ON public.booking_review_media USING btree (id);

CREATE UNIQUE INDEX booking_review_responses_pkey ON public.booking_review_responses USING btree (id);

CREATE UNIQUE INDEX booking_review_responses_review_id_key ON public.booking_review_responses USING btree (review_id);

CREATE UNIQUE INDEX booking_reviews_one_per_direction ON public.booking_reviews USING btree (booking_id, reviewer_profile_id, reviewee_profile_id);

CREATE UNIQUE INDEX booking_reviews_pkey ON public.booking_reviews USING btree (id);

CREATE UNIQUE INDEX booking_status_history_pkey ON public.booking_status_history USING btree (id);

CREATE INDEX "bookings_activityId_idx" ON public.bookings USING btree ("activityId");

CREATE INDEX "bookings_bookerId_idx" ON public.bookings USING btree ("bookerId");

CREATE INDEX bookings_bookerid_idx ON public.bookings USING btree ("bookerId");

CREATE UNIQUE INDEX bookings_pkey ON public.bookings USING btree (id);

CREATE INDEX "bookings_providerId_idx" ON public.bookings USING btree ("providerId");

CREATE INDEX bookings_providerid_idx ON public.bookings USING btree ("providerId");

CREATE INDEX "bookings_startTime_idx" ON public.bookings USING btree ("startTime");

CREATE INDEX bookings_starttime_idx ON public.bookings USING btree ("startTime");

CREATE INDEX bookings_status_idx ON public.bookings USING btree (status);

CREATE UNIQUE INDEX bookings_v2_pkey ON public.bookings_v2 USING btree (id);

CREATE UNIQUE INDEX bouncer_services_pkey ON public.bouncer_services USING btree (id);

CREATE UNIQUE INDEX bouncer_services_profile_id_service_type_key ON public.bouncer_services USING btree (profile_id, service_type);

CREATE UNIQUE INDEX bud_api_keys_api_key_hash_key ON public.bud_api_keys USING btree (api_key_hash);

CREATE UNIQUE INDEX bud_api_keys_pkey ON public.bud_api_keys USING btree (id);

CREATE UNIQUE INDEX bud_conversations_pkey ON public.bud_conversations USING btree (id);

CREATE UNIQUE INDEX bud_conversations_v2_pkey ON public.bud_conversations_v2 USING btree (id);

CREATE UNIQUE INDEX call_ice_candidates_pkey ON public.call_ice_candidates USING btree (id);

CREATE UNIQUE INDEX call_logs_pkey ON public.call_logs USING btree (id);

CREATE UNIQUE INDEX call_transcripts_pkey ON public.call_transcripts USING btree (id);

CREATE UNIQUE INDEX campaigns_pkey ON public.campaigns USING btree (id);

CREATE UNIQUE INDEX cc_activities_pkey ON public.cc_activities USING btree (id);

CREATE UNIQUE INDEX cc_activity_attendance_activity_id_resident_id_key ON public.cc_activity_attendance USING btree (activity_id, resident_id);

CREATE UNIQUE INDEX cc_activity_attendance_pkey ON public.cc_activity_attendance USING btree (id);

CREATE UNIQUE INDEX cc_activity_templates_pkey ON public.cc_activity_templates USING btree (id);

CREATE UNIQUE INDEX cc_admin_users_pkey ON public.cc_admin_users USING btree (id);

CREATE UNIQUE INDEX cc_audit_log_pkey ON public.cc_audit_log USING btree (id);

CREATE UNIQUE INDEX cc_billing_info_facility_id_key ON public.cc_billing_info USING btree (facility_id);

CREATE UNIQUE INDEX cc_billing_info_pkey ON public.cc_billing_info USING btree (id);

CREATE UNIQUE INDEX cc_companion_assignments_companion_id_resident_id_key ON public.cc_companion_assignments USING btree (companion_id, resident_id);

CREATE UNIQUE INDEX cc_companion_assignments_pkey ON public.cc_companion_assignments USING btree (id);

CREATE UNIQUE INDEX cc_companion_bookings_pkey ON public.cc_companion_bookings USING btree (id);

CREATE UNIQUE INDEX cc_companions_pkey ON public.cc_companions USING btree (id);

CREATE UNIQUE INDEX cc_facilities_pkey ON public.cc_facilities USING btree (id);

CREATE UNIQUE INDEX cc_facilities_slug_key ON public.cc_facilities USING btree (slug);

CREATE UNIQUE INDEX cc_facility_members_facility_id_user_id_key ON public.cc_facility_members USING btree (facility_id, user_id);

CREATE UNIQUE INDEX cc_facility_members_pkey ON public.cc_facility_members USING btree (id);

CREATE UNIQUE INDEX cc_family_connections_pkey ON public.cc_family_connections USING btree (id);

CREATE UNIQUE INDEX cc_family_members_pkey ON public.cc_family_members USING btree (id);

CREATE UNIQUE INDEX cc_family_messages_pkey ON public.cc_family_messages USING btree (id);

CREATE UNIQUE INDEX cc_family_users_family_user_id_resident_id_key ON public.cc_family_users USING btree (family_user_id, resident_id);

CREATE UNIQUE INDEX cc_family_users_pkey ON public.cc_family_users USING btree (id);

CREATE UNIQUE INDEX cc_marketplace_companions_pkey ON public.cc_marketplace_companions USING btree (id);

CREATE UNIQUE INDEX cc_messages_pkey ON public.cc_messages USING btree (id);

CREATE UNIQUE INDEX cc_mood_checkins_pkey ON public.cc_mood_checkins USING btree (id);

CREATE UNIQUE INDEX cc_org_users_pkey ON public.cc_org_users USING btree (id);

CREATE UNIQUE INDEX cc_org_users_user_id_facility_id_key ON public.cc_org_users USING btree (user_id, facility_id);

CREATE UNIQUE INDEX cc_residents_pkey ON public.cc_residents USING btree (id);

CREATE UNIQUE INDEX cc_security_settings_facility_id_key ON public.cc_security_settings USING btree (facility_id);

CREATE UNIQUE INDEX cc_security_settings_pkey ON public.cc_security_settings USING btree (id);

CREATE UNIQUE INDEX cc_session_notes_pkey ON public.cc_session_notes USING btree (id);

CREATE UNIQUE INDEX cc_staff_pkey ON public.cc_staff USING btree (id);

CREATE UNIQUE INDEX companion_activities_pkey ON public.companion_activities USING btree (id);

CREATE UNIQUE INDEX companion_services_pkey ON public.companion_services USING btree (id);

CREATE UNIQUE INDEX companion_services_profile_id_service_type_key ON public.companion_services USING btree (profile_id, service_type);

CREATE UNIQUE INDEX companions_pkey ON public.companions USING btree (id);

CREATE UNIQUE INDEX companions_user_id_key ON public.companions USING btree (user_id);

CREATE UNIQUE INDEX companions_v2_pkey ON public.companions_v2 USING btree (id);

CREATE UNIQUE INDEX companions_v2_user_id_key ON public.companions_v2 USING btree (user_id);

CREATE INDEX conversations_booking_idx ON public.conversations USING btree ("bookingId");

CREATE UNIQUE INDEX conversations_pkey ON public.conversations USING btree (id);

CREATE UNIQUE INDEX ct_admissions_pkey ON public.ct_admissions USING btree (id);

CREATE UNIQUE INDEX ct_ai_insights_pkey ON public.ct_ai_insights USING btree (id);

CREATE INDEX ct_announcements_author_created_idx ON public.ct_announcements USING btree (author_id, created_at DESC);

CREATE INDEX ct_announcements_institution_created_idx ON public.ct_announcements USING btree (institution_id, created_at DESC);

CREATE UNIQUE INDEX ct_announcements_pkey ON public.ct_announcements USING btree (id);

CREATE UNIQUE INDEX ct_api_keys_pkey ON public.ct_api_keys USING btree (id);

CREATE UNIQUE INDEX ct_assignment_documents_pkey ON public.ct_assignment_documents USING btree (id);

CREATE UNIQUE INDEX ct_assignment_submissions_assignment_id_student_id_key ON public.ct_assignment_submissions USING btree (assignment_id, student_id);

CREATE UNIQUE INDEX ct_assignment_submissions_pkey ON public.ct_assignment_submissions USING btree (id);

CREATE UNIQUE INDEX ct_assignments_pkey ON public.ct_assignments USING btree (id);

CREATE UNIQUE INDEX ct_athletes_pkey ON public.ct_athletes USING btree (id);

CREATE UNIQUE INDEX ct_attendance_pkey ON public.ct_attendance USING btree (id);

CREATE UNIQUE INDEX ct_audit_logs_pkey ON public.ct_audit_logs USING btree (id);

CREATE UNIQUE INDEX ct_billing_invoices_pkey ON public.ct_billing_invoices USING btree (id);

CREATE UNIQUE INDEX ct_billing_plans_pkey ON public.ct_billing_plans USING btree (id);

CREATE UNIQUE INDEX ct_blog_posts_pkey ON public.ct_blog_posts USING btree (id);

CREATE UNIQUE INDEX ct_blog_posts_slug_key ON public.ct_blog_posts USING btree (slug);

CREATE UNIQUE INDEX ct_broadcast_notifications_pkey ON public.ct_broadcast_notifications USING btree (id);

CREATE UNIQUE INDEX ct_budget_items_pkey ON public.ct_budget_items USING btree (id);

CREATE UNIQUE INDEX ct_budgets_pkey ON public.ct_budgets USING btree (id);

CREATE UNIQUE INDEX ct_challenge_entries_challenge_id_user_id_key ON public.ct_challenge_entries USING btree (challenge_id, user_id);

CREATE UNIQUE INDEX ct_challenge_entries_pkey ON public.ct_challenge_entries USING btree (id);

CREATE UNIQUE INDEX ct_challenge_scores_pkey ON public.ct_challenge_scores USING btree (id);

CREATE UNIQUE INDEX ct_children_pkey ON public.ct_children USING btree (id);

CREATE UNIQUE INDEX ct_classes_pkey ON public.ct_classes USING btree (id);

CREATE UNIQUE INDEX ct_club_election_candidates_pkey ON public.ct_club_election_candidates USING btree (id);

CREATE UNIQUE INDEX ct_club_election_votes_election_id_voter_id_key ON public.ct_club_election_votes USING btree (election_id, voter_id);

CREATE UNIQUE INDEX ct_club_election_votes_pkey ON public.ct_club_election_votes USING btree (id);

CREATE UNIQUE INDEX ct_club_elections_pkey ON public.ct_club_elections USING btree (id);

CREATE UNIQUE INDEX ct_club_events_pkey ON public.ct_club_events USING btree (id);

CREATE UNIQUE INDEX ct_club_members_pkey ON public.ct_club_members USING btree (id);

CREATE UNIQUE INDEX ct_club_memberships_club_id_student_id_key ON public.ct_club_memberships USING btree (club_id, student_id);

CREATE UNIQUE INDEX ct_club_memberships_pkey ON public.ct_club_memberships USING btree (id);

CREATE UNIQUE INDEX ct_club_posts_pkey ON public.ct_club_posts USING btree (id);

CREATE UNIQUE INDEX ct_club_recognition_requests_pkey ON public.ct_club_recognition_requests USING btree (id);

CREATE INDEX ct_clubs_institution_leader_idx ON public.ct_clubs USING btree (institution_id, leader_id);

CREATE UNIQUE INDEX ct_clubs_pkey ON public.ct_clubs USING btree (id);

CREATE UNIQUE INDEX ct_course_enrollments_course_id_student_id_key ON public.ct_course_enrollments USING btree (course_id, student_id);

CREATE UNIQUE INDEX ct_course_enrollments_pkey ON public.ct_course_enrollments USING btree (id);

CREATE UNIQUE INDEX ct_courses_pkey ON public.ct_courses USING btree (id);

CREATE UNIQUE INDEX ct_daily_reports_pkey ON public.ct_daily_reports USING btree (id);

CREATE UNIQUE INDEX ct_demo_requests_pkey ON public.ct_demo_requests USING btree (id);

CREATE UNIQUE INDEX ct_direct_messages_pkey ON public.ct_direct_messages USING btree (id);

CREATE UNIQUE INDEX ct_discovery_profiles_pkey ON public.ct_discovery_profiles USING btree (id);

CREATE UNIQUE INDEX ct_discovery_profiles_student_id_key ON public.ct_discovery_profiles USING btree (student_id);

CREATE UNIQUE INDEX ct_email_rate_limits_pkey ON public.ct_email_rate_limits USING btree (ip, date);

CREATE UNIQUE INDEX ct_email_verifications_pkey ON public.ct_email_verifications USING btree (id);

CREATE UNIQUE INDEX ct_email_verifications_token_key ON public.ct_email_verifications USING btree (token);

CREATE UNIQUE INDEX ct_engagement_points_pkey ON public.ct_engagement_points USING btree (id);

CREATE UNIQUE INDEX ct_engagement_scores_pkey ON public.ct_engagement_scores USING btree (id);

CREATE UNIQUE INDEX ct_engagement_scores_user_id_key ON public.ct_engagement_scores USING btree (user_id);

CREATE UNIQUE INDEX ct_enrollments_pkey ON public.ct_enrollments USING btree (id);

CREATE UNIQUE INDEX ct_error_logs_pkey ON public.ct_error_logs USING btree (id);

CREATE UNIQUE INDEX ct_event_rsvps_event_id_student_id_key ON public.ct_event_rsvps USING btree (event_id, student_id);

CREATE UNIQUE INDEX ct_event_rsvps_event_user_uidx ON public.ct_event_rsvps USING btree (event_id, user_id) WHERE (user_id IS NOT NULL);

CREATE UNIQUE INDEX ct_event_rsvps_pkey ON public.ct_event_rsvps USING btree (id);

CREATE UNIQUE INDEX ct_events_pkey ON public.ct_events USING btree (id);

CREATE UNIQUE INDEX ct_feature_events_pkey ON public.ct_feature_events USING btree (id);

CREATE UNIQUE INDEX ct_free_trial_requests_pkey ON public.ct_free_trial_requests USING btree (id);

CREATE UNIQUE INDEX ct_funding_requests_pkey ON public.ct_funding_requests USING btree (id);

CREATE UNIQUE INDEX ct_games_pkey ON public.ct_games USING btree (id);

CREATE UNIQUE INDEX ct_grades_assignment_student_unique ON public.ct_grades USING btree (assignment_id, student_id);

CREATE UNIQUE INDEX ct_grades_pkey ON public.ct_grades USING btree (id);

CREATE UNIQUE INDEX ct_group_activities_pkey ON public.ct_group_activities USING btree (id);

CREATE UNIQUE INDEX ct_group_activity_members_activity_id_student_id_key ON public.ct_group_activity_members USING btree (activity_id, student_id);

CREATE UNIQUE INDEX ct_group_activity_members_pkey ON public.ct_group_activity_members USING btree (id);

CREATE UNIQUE INDEX ct_institution_requests_pkey ON public.ct_institution_requests USING btree (id);

CREATE UNIQUE INDEX ct_institution_settings_institution_id_key_key ON public.ct_institution_settings USING btree (institution_id, key);

CREATE UNIQUE INDEX ct_institution_settings_pkey ON public.ct_institution_settings USING btree (id);

CREATE UNIQUE INDEX ct_institution_subscriptions_institution_id_key ON public.ct_institution_subscriptions USING btree (institution_id);

CREATE UNIQUE INDEX ct_institution_subscriptions_pkey ON public.ct_institution_subscriptions USING btree (id);

CREATE UNIQUE INDEX ct_institutions_domain_key ON public.ct_institutions USING btree (domain);

CREATE UNIQUE INDEX ct_institutions_invite_code_key ON public.ct_institutions USING btree (invite_code);

CREATE UNIQUE INDEX ct_institutions_pkey ON public.ct_institutions USING btree (id);

CREATE UNIQUE INDEX ct_interest_onboarding_pkey ON public.ct_interest_onboarding USING btree (id);

CREATE UNIQUE INDEX ct_interest_onboarding_user_id_key ON public.ct_interest_onboarding USING btree (user_id);

CREATE UNIQUE INDEX ct_match_participants_pkey ON public.ct_match_participants USING btree (id);

CREATE UNIQUE INDEX ct_match_results_pkey ON public.ct_match_results USING btree (id);

CREATE UNIQUE INDEX ct_note_requests_pkey ON public.ct_note_requests USING btree (id);

CREATE UNIQUE INDEX ct_notification_preferences_pkey ON public.ct_notification_preferences USING btree (id);

CREATE UNIQUE INDEX ct_notification_preferences_user_id_key ON public.ct_notification_preferences USING btree (user_id);

CREATE UNIQUE INDEX ct_notification_prefs_pkey ON public.ct_notification_prefs USING btree (id);

CREATE UNIQUE INDEX ct_notification_prefs_user_id_channel_event_type_key ON public.ct_notification_prefs USING btree (user_id, channel, event_type);

CREATE UNIQUE INDEX ct_notifications_pkey ON public.ct_notifications USING btree (id);

CREATE UNIQUE INDEX ct_onboarding_pkey ON public.ct_onboarding USING btree (id);

CREATE UNIQUE INDEX ct_onboarding_user_id_key ON public.ct_onboarding USING btree (user_id);

CREATE UNIQUE INDEX ct_org_members_org_id_user_id_key ON public.ct_org_members USING btree (org_id, user_id);

CREATE UNIQUE INDEX ct_org_members_pkey ON public.ct_org_members USING btree (id);

CREATE UNIQUE INDEX ct_org_users_pkey ON public.ct_org_users USING btree (id);

CREATE UNIQUE INDEX ct_org_users_user_id_org_id_key ON public.ct_org_users USING btree (user_id, org_id);

CREATE UNIQUE INDEX ct_organizations_pkey ON public.ct_organizations USING btree (id);

CREATE UNIQUE INDEX ct_organizations_slug_key ON public.ct_organizations USING btree (slug);

CREATE UNIQUE INDEX ct_parent_links_parent_user_id_student_id_key ON public.ct_parent_links USING btree (parent_user_id, student_id);

CREATE UNIQUE INDEX ct_parent_links_pkey ON public.ct_parent_links USING btree (id);

CREATE INDEX ct_parent_updates_child_created_idx ON public.ct_parent_updates USING btree (child_id, created_at DESC);

CREATE INDEX ct_parent_updates_institution_created_idx ON public.ct_parent_updates USING btree (institution_id, created_at DESC);

CREATE UNIQUE INDEX ct_parent_updates_pkey ON public.ct_parent_updates USING btree (id);

CREATE UNIQUE INDEX ct_payment_methods_pkey ON public.ct_payment_methods USING btree (id);

CREATE UNIQUE INDEX ct_peer_connections_pkey ON public.ct_peer_connections USING btree (id);

CREATE UNIQUE INDEX ct_peer_connections_requester_id_recipient_id_key ON public.ct_peer_connections USING btree (requester_id, recipient_id);

CREATE UNIQUE INDEX ct_performance_notes_pkey ON public.ct_performance_notes USING btree (id);

CREATE UNIQUE INDEX ct_platform_settings_institution_category_provider_key ON public.ct_platform_settings USING btree (institution_id, category, provider);

CREATE INDEX ct_platform_settings_institution_updated_idx ON public.ct_platform_settings USING btree (institution_id, updated_at DESC);

CREATE UNIQUE INDEX ct_platform_settings_pkey ON public.ct_platform_settings USING btree (id);

CREATE UNIQUE INDEX ct_sport_challenge_participants_challenge_id_user_id_key ON public.ct_sport_challenge_participants USING btree (challenge_id, user_id);

CREATE UNIQUE INDEX ct_sport_challenge_participants_pkey ON public.ct_sport_challenge_participants USING btree (id);

CREATE UNIQUE INDEX ct_sport_challenges_pkey ON public.ct_sport_challenges USING btree (id);

CREATE UNIQUE INDEX ct_sport_participants_pkey ON public.ct_sport_participants USING btree (id);

CREATE UNIQUE INDEX ct_sport_participants_student_id_team_id_key ON public.ct_sport_participants USING btree (student_id, team_id);

CREATE UNIQUE INDEX ct_sport_rankings_pkey ON public.ct_sport_rankings USING btree (id);

CREATE UNIQUE INDEX ct_sport_rankings_user_id_institution_id_sport_key ON public.ct_sport_rankings USING btree (user_id, institution_id, sport);

CREATE UNIQUE INDEX ct_sport_rankings_user_institution_sport ON public.ct_sport_rankings USING btree (user_id, institution_id, sport);

CREATE UNIQUE INDEX ct_sports_challenges_pkey ON public.ct_sports_challenges USING btree (id);

CREATE UNIQUE INDEX ct_sports_games_pkey ON public.ct_sports_games USING btree (id);

CREATE UNIQUE INDEX ct_sports_leagues_pkey ON public.ct_sports_leagues USING btree (id);

CREATE UNIQUE INDEX ct_sports_teams_pkey ON public.ct_sports_teams USING btree (id);

CREATE INDEX ct_staff_reg_email_idx ON public.ct_staff_registrations USING btree (email);

CREATE INDEX ct_staff_reg_org_idx ON public.ct_staff_registrations USING btree (org_id);

CREATE UNIQUE INDEX ct_staff_registrations_pkey ON public.ct_staff_registrations USING btree (id);

CREATE UNIQUE INDEX ct_stealth_sessions_pkey ON public.ct_stealth_sessions USING btree (id);

CREATE UNIQUE INDEX ct_student_journey_pkey ON public.ct_student_journey USING btree (id);

CREATE UNIQUE INDEX ct_student_notes_pkey ON public.ct_student_notes USING btree (id);

CREATE UNIQUE INDEX ct_student_registrations_pkey ON public.ct_student_registrations USING btree (id);

CREATE UNIQUE INDEX ct_students_pkey ON public.ct_students USING btree (id);

CREATE UNIQUE INDEX ct_submission_files_pkey ON public.ct_submission_files USING btree (id);

CREATE UNIQUE INDEX ct_submissions_pkey ON public.ct_submissions USING btree (id);

CREATE UNIQUE INDEX ct_superadmins_email_key ON public.ct_superadmins USING btree (email);

CREATE UNIQUE INDEX ct_superadmins_pkey ON public.ct_superadmins USING btree (id);

CREATE UNIQUE INDEX ct_superadmins_user_id_key ON public.ct_superadmins USING btree (user_id);

CREATE UNIQUE INDEX ct_survey_questions_pkey ON public.ct_survey_questions USING btree (id);

CREATE INDEX ct_survey_questions_survey_position_idx ON public.ct_survey_questions USING btree (survey_id, "position");

CREATE UNIQUE INDEX ct_survey_responses_pkey ON public.ct_survey_responses USING btree (id);

CREATE UNIQUE INDEX ct_survey_responses_survey_user_uidx ON public.ct_survey_responses USING btree (survey_id, user_id) WHERE (user_id IS NOT NULL);

CREATE INDEX ct_surveys_institution_status_idx ON public.ct_surveys USING btree (institution_id, status, created_at DESC);

CREATE UNIQUE INDEX ct_surveys_pkey ON public.ct_surveys USING btree (id);

CREATE UNIQUE INDEX ct_teams_pkey ON public.ct_teams USING btree (id);

CREATE UNIQUE INDEX ct_ticket_messages_pkey ON public.ct_ticket_messages USING btree (id);

CREATE UNIQUE INDEX ct_tickets_pkey ON public.ct_tickets USING btree (id);

CREATE UNIQUE INDEX ct_tournament_matches_pkey ON public.ct_tournament_matches USING btree (id);

CREATE UNIQUE INDEX ct_tournament_teams_pkey ON public.ct_tournament_teams USING btree (id);

CREATE UNIQUE INDEX ct_tournament_teams_tournament_id_team_id_key ON public.ct_tournament_teams USING btree (tournament_id, team_id);

CREATE UNIQUE INDEX ct_tournaments_pkey ON public.ct_tournaments USING btree (id);

CREATE UNIQUE INDEX ct_training_sessions_pkey ON public.ct_training_sessions USING btree (id);

CREATE UNIQUE INDEX ct_trial_requests_pkey ON public.ct_trial_requests USING btree (id);

CREATE UNIQUE INDEX ct_trial_requests_user_id_key ON public.ct_trial_requests USING btree (user_id);

CREATE UNIQUE INDEX ct_user_notifications_pkey ON public.ct_user_notifications USING btree (id);

CREATE UNIQUE INDEX ct_user_seat_billing_institution_id_user_id_key ON public.ct_user_seat_billing USING btree (institution_id, user_id);

CREATE UNIQUE INDEX ct_user_seat_billing_pkey ON public.ct_user_seat_billing USING btree (id);

CREATE UNIQUE INDEX ct_users_pkey ON public.ct_users USING btree (id);

CREATE INDEX ct_venue_booking_history_booking_created_idx ON public.ct_venue_booking_history USING btree (booking_id, created_at DESC);

CREATE UNIQUE INDEX ct_venue_booking_history_pkey ON public.ct_venue_booking_history USING btree (id);

CREATE UNIQUE INDEX ct_venue_bookings_pkey ON public.ct_venue_bookings USING btree (id);

CREATE INDEX ct_venue_bookings_venue_time_idx ON public.ct_venue_bookings USING btree (venue_id, start_time, end_time, status);

CREATE UNIQUE INDEX ct_venues_pkey ON public.ct_venues USING btree (id);

CREATE UNIQUE INDEX ct_wellbeing_checkins_pkey ON public.ct_wellbeing_checkins USING btree (id);

CREATE UNIQUE INDEX ct_wellbeing_checks_pkey ON public.ct_wellbeing_checks USING btree (id);

CREATE UNIQUE INDEX ct_wellbeing_checks_user_id_date_key ON public.ct_wellbeing_checks USING btree (user_id, date);

CREATE UNIQUE INDEX ct_wellness_checkins_pkey ON public.ct_wellness_checkins USING btree (id);

CREATE UNIQUE INDEX ct_wellness_checkins_user_date_unique ON public.ct_wellness_checkins USING btree (user_id, date);

CREATE UNIQUE INDEX demo_requests_pkey ON public.demo_requests USING btree (id);

CREATE INDEX "earnings_bookingId_idx" ON public.earnings USING btree ("bookingId");

CREATE UNIQUE INDEX earnings_pkey ON public.earnings USING btree (id);

CREATE INDEX earnings_status_idx ON public.earnings USING btree (status);

CREATE INDEX "earnings_userId_idx" ON public.earnings USING btree ("userId");

CREATE INDEX email_idx ON public.users USING btree (email);

CREATE UNIQUE INDEX enterprise_invoices_pkey ON public.enterprise_invoices USING btree (id);

CREATE UNIQUE INDEX event_news_comments_pkey ON public.event_news_comments USING btree (id);

CREATE UNIQUE INDEX event_news_likes_pkey ON public.event_news_likes USING btree (post_id, profile_id);

CREATE UNIQUE INDEX event_news_posts_pkey ON public.event_news_posts USING btree (id);

CREATE INDEX event_registrations_event_id_idx ON public.event_registrations USING btree (event_id);

CREATE UNIQUE INDEX event_registrations_event_id_user_id_key ON public.event_registrations USING btree (event_id, user_id);

CREATE UNIQUE INDEX event_registrations_pkey ON public.event_registrations USING btree (id);

CREATE INDEX event_registrations_user_id_idx ON public.event_registrations USING btree (user_id);

CREATE INDEX events_event_start_at_idx ON public.events USING btree (event_start_at);

CREATE INDEX events_is_active_idx ON public.events USING btree (is_active);

CREATE INDEX events_organizer_id_idx ON public.events USING btree (organizer_id);

CREATE UNIQUE INDEX events_pkey ON public.events USING btree (id);

CREATE UNIQUE INDEX events_v2_pkey ON public.events_v2 USING btree (id);

CREATE INDEX "favorites_activityId_idx" ON public.favorites USING btree ("activityId");

CREATE UNIQUE INDEX favorites_pkey ON public.favorites USING btree (id);

CREATE UNIQUE INDEX favorites_unique_idx ON public.favorites USING btree ("userId", "activityId");

CREATE INDEX "favorites_userId_idx" ON public.favorites USING btree ("userId");

CREATE UNIQUE INDEX group_conversation_members_group_conversation_id_profile_id_key ON public.group_conversation_members USING btree (group_conversation_id, profile_id);

CREATE UNIQUE INDEX group_conversation_members_pkey ON public.group_conversation_members USING btree (id);

CREATE UNIQUE INDEX group_conversations_pkey ON public.group_conversations USING btree (id);

CREATE UNIQUE INDEX group_messages_pkey ON public.group_messages USING btree (id);

CREATE INDEX idx_account_activity_log_action ON public.account_activity_log USING btree (action);

CREATE INDEX idx_account_activity_log_created ON public.account_activity_log USING btree (created_at);

CREATE INDEX idx_account_activity_log_profile ON public.account_activity_log USING btree (profile_id);

CREATE INDEX idx_activities_category ON public.activities USING btree (category);

CREATE INDEX idx_activities_featured ON public.activities USING btree (is_featured);

CREATE INDEX idx_activities_media_activity ON public.activities_media USING btree (activity_id);

CREATE INDEX idx_activity_bookings_activity_id ON public.activity_bookings USING btree (activity_id);

CREATE INDEX idx_activity_bookings_host_date ON public.activity_bookings USING btree (host_profile_id, booking_date);

CREATE INDEX idx_activity_bookings_host_payout_status ON public.activity_bookings USING btree (host_payout_status);

CREATE INDEX idx_activity_bookings_host_profile_id ON public.activity_bookings USING btree (host_profile_id);

CREATE INDEX idx_activity_bookings_status ON public.activity_bookings USING btree (status);

CREATE INDEX idx_activity_bookings_user_id ON public.activity_bookings USING btree (user_id);

CREATE INDEX idx_activity_reviews_activity_id ON public.activity_reviews USING btree (activity_id);

CREATE INDEX idx_activity_reviews_companion_id ON public.activity_reviews USING btree (companion_id);

CREATE INDEX idx_activity_shares_activity ON public.activity_shares USING btree (activity_id);

CREATE INDEX idx_activity_shares_created ON public.activity_shares USING btree (created_at);

CREATE INDEX idx_activity_shares_platform ON public.activity_shares USING btree (platform);

CREATE INDEX idx_activity_views_activity ON public.activity_views USING btree (activity_id);

CREATE INDEX idx_activity_views_created ON public.activity_views USING btree (created_at);

CREATE INDEX idx_api_keys_enabled ON public.api_keys USING btree (enabled);

CREATE INDEX idx_api_keys_hash ON public.api_keys USING btree (api_key_hash);

CREATE INDEX idx_api_keys_plan ON public.api_keys USING btree (plan);

CREATE INDEX idx_availability_slots_day ON public.availability_slots USING btree (day_of_week);

CREATE INDEX idx_availability_slots_profile ON public.availability_slots USING btree (profile_id);

CREATE INDEX idx_blocked_dates_date ON public.blocked_dates USING btree (blocked_date);

CREATE INDEX idx_blocked_dates_profile ON public.blocked_dates USING btree (profile_id);

CREATE INDEX idx_booking_review_media_review ON public.booking_review_media USING btree (review_id);

CREATE INDEX idx_booking_reviews_booking ON public.booking_reviews USING btree (booking_id);

CREATE INDEX idx_booking_reviews_revealed ON public.booking_reviews USING btree (revealed_at DESC);

CREATE INDEX idx_booking_reviews_reviewee ON public.booking_reviews USING btree (reviewee_profile_id);

CREATE INDEX idx_booking_reviews_status ON public.booking_reviews USING btree (status, moderation_status);

CREATE INDEX idx_booking_status_history_booking ON public.booking_status_history USING btree (booking_id);

CREATE INDEX idx_booking_status_history_created ON public.booking_status_history USING btree (created_at);

CREATE INDEX idx_bookings_bouncer ON public.bookings USING btree (bouncer_id);

CREATE INDEX idx_bookings_bouncer_start ON public.bookings USING btree (bouncer_id, start_time);

CREATE INDEX idx_bookings_client ON public.bookings USING btree (client_id);

CREATE INDEX idx_bookings_companion ON public.bookings USING btree (companion_id);

CREATE INDEX idx_bookings_companion_start ON public.bookings USING btree (companion_id, start_time);

CREATE INDEX idx_bookings_start_time ON public.bookings USING btree (start_time);

CREATE INDEX idx_bookings_v2_entity ON public.bookings_v2 USING btree (entity_id, entity_type);

CREATE INDEX idx_bouncer_services_active ON public.bouncer_services USING btree (is_active);

CREATE INDEX idx_bouncer_services_profile_id ON public.bouncer_services USING btree (profile_id);

CREATE INDEX idx_bud_conv_date ON public.bud_conversations USING btree (created_at DESC);

CREATE INDEX idx_bud_conv_tenant ON public.bud_conversations USING btree (tenant_id);

CREATE INDEX idx_bud_conv_user ON public.bud_conversations USING btree (user_id);

CREATE INDEX idx_bud_conv_v2_session ON public.bud_conversations_v2 USING btree (session_id);

CREATE INDEX idx_bud_conversations_user ON public.bud_conversations USING btree (user_id, created_at DESC);

CREATE INDEX idx_call_ice_call_log_sender ON public.call_ice_candidates USING btree (call_log_id, sender_profile_id, created_at);

CREATE INDEX idx_call_logs_callee ON public.call_logs USING btree (callee_profile_id, created_at DESC);

CREATE INDEX idx_call_logs_caller ON public.call_logs USING btree (caller_profile_id, created_at DESC);

CREATE INDEX idx_call_logs_conversation ON public.call_logs USING btree (conversation_id, created_at DESC);

CREATE INDEX idx_call_logs_status_created ON public.call_logs USING btree (status, created_at DESC);

CREATE INDEX idx_campaigns_activity ON public.campaigns USING btree (activity_id);

CREATE INDEX idx_campaigns_profile_status ON public.campaigns USING btree (profile_id, status);

CREATE INDEX idx_cc_admin_users_facility ON public.cc_admin_users USING btree (facility_id);

CREATE INDEX idx_cc_audit_log_facility ON public.cc_audit_log USING btree (facility_id, created_at DESC);

CREATE INDEX idx_cc_bk_companion ON public.cc_companion_bookings USING btree (companion_id);

CREATE INDEX idx_cc_bk_facility ON public.cc_companion_bookings USING btree (facility_id);

CREATE INDEX idx_cc_bk_resident ON public.cc_companion_bookings USING btree (resident_id);

CREATE INDEX idx_cc_bk_status ON public.cc_companion_bookings USING btree (status);

CREATE INDEX idx_cc_comp_user ON public.cc_companions USING btree (user_id);

CREATE INDEX idx_cc_family_messages_facility ON public.cc_family_messages USING btree (facility_id);

CREATE INDEX idx_cc_family_users_facility ON public.cc_family_users USING btree (facility_id);

CREATE INDEX idx_cc_staff_facility ON public.cc_staff USING btree (facility_id);

CREATE INDEX idx_companion_activities_created_by ON public.companion_activities USING btree (created_by);

CREATE INDEX idx_companion_activities_is_active ON public.companion_activities USING btree (is_active);

CREATE INDEX idx_companion_services_active ON public.companion_services USING btree (is_active);

CREATE INDEX idx_companion_services_profile_id ON public.companion_services USING btree (profile_id);

CREATE INDEX idx_companions_status ON public.companions USING btree (status);

CREATE INDEX idx_companions_user_id ON public.companions USING btree (user_id);

CREATE INDEX idx_companions_v2_status ON public.companions_v2 USING btree (status);

CREATE INDEX idx_conversations_last_message ON public.conversations USING btree (last_message_at DESC);

CREATE INDEX idx_conversations_participant1 ON public.conversations USING btree (participant1_id);

CREATE INDEX idx_conversations_participant2 ON public.conversations USING btree (participant2_id);

CREATE INDEX idx_ct_ai_org ON public.ct_ai_insights USING btree (org_id);

CREATE INDEX idx_ct_ai_severity ON public.ct_ai_insights USING btree (severity);

CREATE INDEX idx_ct_blog_posts_published ON public.ct_blog_posts USING btree (published_at DESC);

CREATE INDEX idx_ct_cp_club ON public.ct_club_posts USING btree (club_id);

CREATE INDEX idx_ct_cp_org ON public.ct_club_posts USING btree (org_id);

CREATE INDEX idx_ct_crr_org ON public.ct_club_recognition_requests USING btree (org_id);

CREATE INDEX idx_ct_dp_org ON public.ct_discovery_profiles USING btree (org_id);

CREATE INDEX idx_ct_ga_org ON public.ct_group_activities USING btree (org_id);

CREATE INDEX idx_ct_mr_org ON public.ct_match_results USING btree (org_id);

CREATE INDEX idx_ct_mr_winner ON public.ct_match_results USING btree (winner_id);

CREATE INDEX idx_ct_pc_recipient ON public.ct_peer_connections USING btree (recipient_id);

CREATE INDEX idx_ct_sr_survey ON public.ct_survey_responses USING btree (survey_id);

CREATE INDEX idx_ct_student_reg_org ON public.ct_student_registrations USING btree (org_id);

CREATE INDEX idx_ct_student_reg_status ON public.ct_student_registrations USING btree (status);

CREATE INDEX idx_ct_surveys_org ON public.ct_surveys USING btree (org_id);

CREATE INDEX idx_ct_t_org ON public.ct_tournaments USING btree (org_id);

CREATE INDEX idx_ct_wc_org ON public.ct_wellbeing_checkins USING btree (org_id);

CREATE INDEX idx_ct_wc_student ON public.ct_wellbeing_checkins USING btree (student_id);

CREATE INDEX idx_event_news_comments_post_created ON public.event_news_comments USING btree (post_id, created_at DESC);

CREATE INDEX idx_event_news_comments_profile ON public.event_news_comments USING btree (profile_id);

CREATE INDEX idx_event_news_likes_post ON public.event_news_likes USING btree (post_id);

CREATE INDEX idx_event_news_likes_profile ON public.event_news_likes USING btree (profile_id);

CREATE INDEX idx_event_news_posts_author ON public.event_news_posts USING btree (author_profile_id);

CREATE INDEX idx_event_news_posts_created_at ON public.event_news_posts USING btree (created_at DESC);

CREATE INDEX idx_events_v2_starts_at ON public.events_v2 USING btree (starts_at);

CREATE INDEX idx_events_v2_status ON public.events_v2 USING btree (status);

CREATE INDEX idx_group_conversations_activity ON public.group_conversations USING btree (activity_id);

CREATE INDEX idx_group_conversations_created_by ON public.group_conversations USING btree (created_by);

CREATE INDEX idx_group_members_conv ON public.group_conversation_members USING btree (group_conversation_id);

CREATE INDEX idx_group_members_conv_profile_read ON public.group_conversation_members USING btree (group_conversation_id, profile_id, last_read_at);

CREATE INDEX idx_group_members_profile ON public.group_conversation_members USING btree (profile_id);

CREATE INDEX idx_group_messages_conv ON public.group_messages USING btree (group_conversation_id, created_at);

CREATE INDEX idx_media_comments_media_id ON public.media_comments USING btree (media_id);

CREATE INDEX idx_media_comments_user_id ON public.media_comments USING btree (commented_by_user_id);

CREATE INDEX idx_media_likes_media_id ON public.media_likes USING btree (media_id);

CREATE INDEX idx_media_likes_user_id ON public.media_likes USING btree (liked_by_user_id);

CREATE INDEX idx_media_uploads_status ON public.media_uploads USING btree (upload_status);

CREATE INDEX idx_media_uploads_user_id ON public.media_uploads USING btree (user_id);

CREATE INDEX idx_messages_conversation ON public.messages USING btree (conversation_id);

CREATE INDEX idx_messages_is_system ON public.messages USING btree (is_system_message);

CREATE INDEX idx_messages_sender ON public.messages USING btree (sender_id);

CREATE INDEX idx_messages_sent_at ON public.messages USING btree (sent_at DESC);

CREATE INDEX idx_note_requests_parent ON public.ct_note_requests USING btree (parent_id);

CREATE INDEX idx_note_requests_teacher ON public.ct_note_requests USING btree (teacher_id);

CREATE INDEX idx_notifications_user ON public.notifications USING btree ("userId", "isRead", "createdAt" DESC);

CREATE INDEX idx_payment_methods_user_id ON public.payment_methods USING btree (user_id);

CREATE INDEX idx_perf_notes_student ON public.ct_performance_notes USING btree (student_id);

CREATE INDEX idx_perf_notes_teacher ON public.ct_performance_notes USING btree (teacher_id);

CREATE INDEX idx_profile_likes_profile_id ON public.profile_likes USING btree (profile_id);

CREATE INDEX idx_profile_likes_user_id ON public.profile_likes USING btree (liked_by_user_id);

CREATE INDEX idx_profile_media_position ON public.profile_media USING btree (user_id, position_order);

CREATE INDEX idx_profile_media_type ON public.profile_media USING btree (media_type);

CREATE INDEX idx_profile_media_user_id ON public.profile_media USING btree (user_id);

CREATE INDEX idx_profile_media_visible ON public.profile_media USING btree (user_id, is_visible);

CREATE UNIQUE INDEX idx_profiles_auth_id ON public.profiles USING btree (auth_id);

CREATE UNIQUE INDEX idx_profiles_email ON public.profiles USING btree (email);

CREATE INDEX idx_profiles_is_discoverable ON public.profiles USING btree (is_discoverable);

CREATE INDEX idx_profiles_location ON public.profiles USING btree (city, country);

CREATE INDEX idx_profiles_role ON public.profiles USING btree (role);

CREATE INDEX idx_profiles_username ON public.profiles USING btree (username);

CREATE INDEX idx_profiles_verification_status ON public.profiles USING btree (verification_status);

CREATE INDEX idx_push_tokens_profile ON public.push_tokens USING btree (profile_id);

CREATE INDEX idx_reviews_entity ON public.reviews USING btree (entity_id, entity_type);

CREATE INDEX idx_reviews_reviewer ON public.reviews USING btree ("reviewerId");

CREATE INDEX idx_reviews_v2_entity ON public.reviews_v2 USING btree (entity_id, entity_type);

CREATE INDEX idx_subscriptions_period_end ON public.subscriptions USING btree (current_period_end);

CREATE INDEX idx_subscriptions_profile_product_status ON public.subscriptions USING btree (profile_id, product, status);

CREATE INDEX idx_transactions_user_id ON public.transactions USING btree (user_id);

CREATE INDEX idx_transactions_wallet_id ON public.transactions USING btree (wallet_id);

CREATE INDEX idx_user_interests_interest_id ON public.user_interests USING btree (interest_id);

CREATE INDEX idx_user_interests_user_id ON public.user_interests USING btree (user_id);

CREATE INDEX idx_wallets_user_id ON public.wallets USING btree (user_id);

CREATE UNIQUE INDEX interests_name_key ON public.interests USING btree (name);

CREATE UNIQUE INDEX interests_pkey ON public.interests USING btree (id);

CREATE INDEX location_idx ON public.users USING btree (location);

CREATE UNIQUE INDEX media_comments_pkey ON public.media_comments USING btree (id);

CREATE UNIQUE INDEX media_likes_media_id_liked_by_user_id_key ON public.media_likes USING btree (media_id, liked_by_user_id);

CREATE UNIQUE INDEX media_likes_pkey ON public.media_likes USING btree (id);

CREATE UNIQUE INDEX media_uploads_pkey ON public.media_uploads USING btree (id);

CREATE INDEX "messages_bookingId_idx" ON public.messages USING btree ("bookingId");

CREATE INDEX messages_conversation_idx ON public.messages USING btree ("conversationId");

CREATE INDEX "messages_createdAt_idx" ON public.messages USING btree ("createdAt");

CREATE UNIQUE INDEX messages_pkey ON public.messages USING btree (id);

CREATE INDEX "messages_recipientId_idx" ON public.messages USING btree ("recipientId");

CREATE INDEX "messages_senderId_idx" ON public.messages USING btree ("senderId");

CREATE INDEX "notifications_isRead_idx" ON public.notifications USING btree ("isRead");

CREATE UNIQUE INDEX notifications_pkey ON public.notifications USING btree (id);

CREATE INDEX notifications_type_idx ON public.notifications USING btree (type);

CREATE INDEX "notifications_userId_idx" ON public.notifications USING btree ("userId");

CREATE INDEX "panicEvents_booking_idx" ON public."panicEvents" USING btree ("bookingId");

CREATE UNIQUE INDEX "panicEvents_pkey" ON public."panicEvents" USING btree (id);

CREATE INDEX "panicEvents_status_idx" ON public."panicEvents" USING btree (status);

CREATE INDEX "panicEvents_user_idx" ON public."panicEvents" USING btree ("userId");

CREATE UNIQUE INDEX payment_methods_pkey ON public.payment_methods USING btree (id);

CREATE INDEX "payments_bookingId_idx" ON public.payments USING btree ("bookingId");

CREATE UNIQUE INDEX payments_pkey ON public.payments USING btree (id);

CREATE INDEX payments_status_idx ON public.payments USING btree (status);

CREATE UNIQUE INDEX photos_pkey ON public.photos USING btree (id);

CREATE INDEX photos_type_idx ON public.photos USING btree (type);

CREATE INDEX "photos_userId_idx" ON public.photos USING btree ("userId");

CREATE UNIQUE INDEX profanity_terms_pkey ON public.profanity_terms USING btree (term);

CREATE UNIQUE INDEX profile_delete_backups_pkey ON public.profile_delete_backups USING btree (backup_id);

CREATE UNIQUE INDEX profile_likes_pkey ON public.profile_likes USING btree (id);

CREATE UNIQUE INDEX profile_likes_profile_id_liked_by_user_id_key ON public.profile_likes USING btree (profile_id, liked_by_user_id);

CREATE UNIQUE INDEX profile_media_pkey ON public.profile_media USING btree (id);

CREATE INDEX profiles_auth_id_idx ON public.profiles USING btree (auth_id);

CREATE UNIQUE INDEX profiles_auth_id_key ON public.profiles USING btree (auth_id);

CREATE INDEX profiles_email_idx ON public.profiles USING btree (email);

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

CREATE INDEX "profiles_userId_idx" ON public.profiles USING btree ("userId");

CREATE UNIQUE INDEX "profiles_userId_unique" ON public.profiles USING btree ("userId");

CREATE UNIQUE INDEX profiles_username_key ON public.profiles USING btree (username);

CREATE UNIQUE INDEX push_tokens_pkey ON public.push_tokens USING btree (id);

CREATE UNIQUE INDEX push_tokens_profile_id_token_key ON public.push_tokens USING btree (profile_id, token);

CREATE UNIQUE INDEX reports_pkey ON public.reports USING btree (id);

CREATE INDEX reports_reporter_idx ON public.reports USING btree ("reporterId");

CREATE INDEX reports_status_idx ON public.reports USING btree (status);

CREATE INDEX reports_target_idx ON public.reports USING btree ("targetUserId");

CREATE UNIQUE INDEX review_notification_outbox_pkey ON public.review_notification_outbox USING btree (id);

CREATE INDEX "reviews_bookingId_idx" ON public.reviews USING btree ("bookingId");

CREATE UNIQUE INDEX reviews_pkey ON public.reviews USING btree (id);

CREATE INDEX "reviews_revieweeId_idx" ON public.reviews USING btree ("revieweeId");

CREATE INDEX "reviews_reviewerId_idx" ON public.reviews USING btree ("reviewerId");

CREATE UNIQUE INDEX reviews_reviewer_booking_unique ON public.reviews USING btree ("bookingId", "reviewerId");

CREATE UNIQUE INDEX reviews_v2_booking_id_key ON public.reviews_v2 USING btree (booking_id);

CREATE UNIQUE INDEX reviews_v2_pkey ON public.reviews_v2 USING btree (id);

CREATE INDEX roles_name_idx ON public.roles USING btree (name);

CREATE UNIQUE INDEX roles_name_unique ON public.roles USING btree (name);

CREATE UNIQUE INDEX roles_pkey ON public.roles USING btree (id);

CREATE INDEX sa_provider_date_idx ON public.service_availability USING btree (provider_id, slot_date);

CREATE INDEX "safetyFlags_booking_idx" ON public."safetyFlags" USING btree ("bookingId");

CREATE UNIQUE INDEX "safetyFlags_pkey" ON public."safetyFlags" USING btree (id);

CREATE INDEX "safetyFlags_reported_idx" ON public."safetyFlags" USING btree ("reportedUserId");

CREATE INDEX "safetyFlags_reporter_idx" ON public."safetyFlags" USING btree ("reporterId");

CREATE INDEX "safetyFlags_status_idx" ON public."safetyFlags" USING btree (status);

CREATE UNIQUE INDEX seo_ai_rank_snapshots_pkey ON public.seo_ai_rank_snapshots USING btree (id);

CREATE UNIQUE INDEX seo_ai_tracking_queries_pkey ON public.seo_ai_tracking_queries USING btree (id);

CREATE UNIQUE INDEX seo_ai_tracking_queries_provider_query_target_path_key ON public.seo_ai_tracking_queries USING btree (provider, query, target_path);

CREATE UNIQUE INDEX service_availability_pkey ON public.service_availability USING btree (id);

CREATE UNIQUE INDEX service_availability_provider_id_slot_date_slot_time_key ON public.service_availability USING btree (provider_id, slot_date, slot_time);

CREATE INDEX service_bookings_client_id_idx ON public.service_bookings USING btree (client_id);

CREATE UNIQUE INDEX service_bookings_pkey ON public.service_bookings USING btree (id);

CREATE INDEX service_bookings_provider_id_idx ON public.service_bookings USING btree (provider_id);

CREATE INDEX service_bookings_service_id_idx ON public.service_bookings USING btree (service_id);

CREATE INDEX service_bookings_status_idx ON public.service_bookings USING btree (status);

CREATE UNIQUE INDEX service_providers_v2_pkey ON public.service_providers_v2 USING btree (id);

CREATE UNIQUE INDEX service_providers_v2_profile_id_key ON public.service_providers_v2 USING btree (profile_id);

CREATE INDEX service_reviews_booking_id_idx ON public.service_reviews USING btree (booking_id);

CREATE UNIQUE INDEX service_reviews_booking_id_reviewer_id_key ON public.service_reviews USING btree (booking_id, reviewer_id);

CREATE UNIQUE INDEX service_reviews_pkey ON public.service_reviews USING btree (id);

CREATE INDEX service_reviews_reviewer_id_idx ON public.service_reviews USING btree (reviewer_id);

CREATE INDEX service_reviews_service_id_idx ON public.service_reviews USING btree (service_id);

CREATE INDEX services_category_idx ON public.services USING btree (category);

CREATE UNIQUE INDEX services_pkey ON public.services USING btree (id);

CREATE INDEX "services_userId_idx" ON public.services USING btree ("userId");

CREATE UNIQUE INDEX subscriptions_pkey ON public.subscriptions USING btree (id);

CREATE UNIQUE INDEX subscriptions_profile_product_key ON public.subscriptions USING btree (profile_id, product);

CREATE INDEX subscriptions_status_idx ON public.subscriptions USING btree (status);

CREATE INDEX subscriptions_user_idx ON public.subscriptions USING btree ("userId");

CREATE UNIQUE INDEX transactions_pkey ON public.transactions USING btree (id);

CREATE UNIQUE INDEX transactions_v2_pkey ON public.transactions_v2 USING btree (id);

CREATE UNIQUE INDEX user_interests_pkey ON public.user_interests USING btree (id);

CREATE UNIQUE INDEX user_interests_user_id_interest_id_key ON public.user_interests USING btree (user_id, interest_id);

CREATE UNIQUE INDEX "users_openId_unique" ON public.users USING btree ("openId");

CREATE UNIQUE INDEX users_pkey ON public.users USING btree (id);

CREATE UNIQUE INDEX users_v2_email_key ON public.users_v2 USING btree (email);

CREATE UNIQUE INDEX users_v2_phone_key ON public.users_v2 USING btree (phone);

CREATE UNIQUE INDEX users_v2_pkey ON public.users_v2 USING btree (id);

CREATE UNIQUE INDEX users_v2_supabase_auth_id_key ON public.users_v2 USING btree (supabase_auth_id);

CREATE UNIQUE INDEX "verificationAudits_pkey" ON public."verificationAudits" USING btree (id);

CREATE INDEX "verificationAudits_reviewer_idx" ON public."verificationAudits" USING btree ("reviewerId");

CREATE INDEX "verificationAudits_verification_idx" ON public."verificationAudits" USING btree ("verificationId");

CREATE UNIQUE INDEX "verificationRequests_pkey" ON public."verificationRequests" USING btree (id);

CREATE INDEX "verificationRequests_status_idx" ON public."verificationRequests" USING btree (status);

CREATE INDEX "verificationRequests_userId_idx" ON public."verificationRequests" USING btree ("userId");

CREATE INDEX verification_idx ON public.users USING btree ("isVerified");

CREATE UNIQUE INDEX vip_accounts_pkey ON public.vip_accounts USING btree (email);

CREATE UNIQUE INDEX voice_studio_clones_pkey ON public.voice_studio_clones USING btree (id);

CREATE UNIQUE INDEX voice_studio_jobs_pkey ON public.voice_studio_jobs USING btree (id);

CREATE UNIQUE INDEX voice_studio_usage_pkey ON public.voice_studio_usage USING btree (id);

CREATE UNIQUE INDEX voice_studio_usage_profile_id_month_year_key ON public.voice_studio_usage USING btree (profile_id, month_year);

CREATE UNIQUE INDEX waitlist_email_key ON public.waitlist USING btree (email);

CREATE UNIQUE INDEX waitlist_pkey ON public.waitlist USING btree (id);

CREATE UNIQUE INDEX wallets_pkey ON public.wallets USING btree (id);

CREATE UNIQUE INDEX wallets_user_id_key ON public.wallets USING btree (user_id);

CREATE UNIQUE INDEX wallets_v2_pkey ON public.wallets_v2 USING btree (id);

CREATE UNIQUE INDEX wallets_v2_user_id_key ON public.wallets_v2 USING btree (user_id);

CREATE UNIQUE INDEX wc_ai_agents_pkey ON public.wc_ai_agents USING btree (id);

CREATE INDEX wc_ai_agents_profile_idx ON public.wc_ai_agents USING btree (business_profile_id);

CREATE UNIQUE INDEX wc_ai_cases_pkey ON public.wc_ai_cases USING btree (id);

CREATE UNIQUE INDEX wc_ai_employees_pkey ON public.wc_ai_employees USING btree (id);

CREATE INDEX wc_ai_staff_owner_idx ON public.wc_ai_staff USING btree (owner_profile_id);

CREATE UNIQUE INDEX wc_ai_staff_pkey ON public.wc_ai_staff USING btree (id);

CREATE UNIQUE INDEX wc_analytics_pkey ON public.wc_analytics USING btree (id);

CREATE UNIQUE INDEX wc_call_sessions_call_control_id_key ON public.wc_call_sessions USING btree (call_control_id);

CREATE INDEX wc_call_sessions_ctrl_idx ON public.wc_call_sessions USING btree (call_control_id);

CREATE UNIQUE INDEX wc_call_sessions_pkey ON public.wc_call_sessions USING btree (id);

CREATE INDEX wc_call_sessions_profile_idx ON public.wc_call_sessions USING btree (business_profile_id);

CREATE INDEX wc_calls_callee_idx ON public.wc_calls USING btree (callee_profile_id, status);

CREATE INDEX wc_calls_caller_idx ON public.wc_calls USING btree (caller_profile_id);

CREATE UNIQUE INDEX wc_calls_pkey ON public.wc_calls USING btree (id);

CREATE INDEX wc_calls_room_idx ON public.wc_calls USING btree (room_id);

CREATE INDEX wc_contacts_owner_idx ON public.wc_contacts USING btree (owner_profile_id);

CREATE UNIQUE INDEX wc_contacts_pkey ON public.wc_contacts USING btree (id);

CREATE UNIQUE INDEX wc_departments_pkey ON public.wc_departments USING btree (id);

CREATE UNIQUE INDEX wc_entitlements_pkey ON public.wc_entitlements USING btree (profile_id);

CREATE UNIQUE INDEX wc_followup_tasks_pkey ON public.wc_followup_tasks USING btree (id);

CREATE INDEX wc_messages_channel_2_idx ON public.wc_messages USING btree (channel, created_at DESC);

CREATE INDEX wc_messages_channel_idx ON public.wc_messages USING btree (channel);

CREATE INDEX wc_messages_from_profile_idx ON public.wc_messages USING btree (from_profile_id, created_at DESC);

CREATE UNIQUE INDEX wc_messages_pkey ON public.wc_messages USING btree (id);

CREATE INDEX wc_messages_sender_phone_idx ON public.wc_messages USING btree (sender_phone);

CREATE UNIQUE INDEX wc_messages_telnyx_id_idx ON public.wc_messages USING btree (telnyx_message_id) WHERE (telnyx_message_id IS NOT NULL);

CREATE INDEX wc_messages_to_idx ON public.wc_messages USING btree (to_profile_id, created_at DESC);

CREATE INDEX wc_messages_to_profile_idx ON public.wc_messages USING btree (to_profile_id, created_at DESC);

CREATE UNIQUE INDEX wc_number_requests_pkey ON public.wc_number_requests USING btree (id);

CREATE UNIQUE INDEX wc_org_settings_pkey ON public.wc_org_settings USING btree (profile_id);

CREATE UNIQUE INDEX wc_org_users_business_profile_id_profile_id_key ON public.wc_org_users USING btree (business_profile_id, profile_id);

CREATE UNIQUE INDEX wc_org_users_pkey ON public.wc_org_users USING btree (id);

CREATE UNIQUE INDEX wc_participants_pkey ON public.wc_participants USING btree (id);

CREATE UNIQUE INDEX wc_participants_room_id_profile_id_key ON public.wc_participants USING btree (room_id, profile_id);

CREATE UNIQUE INDEX wc_phone_numbers_pkey ON public.wc_phone_numbers USING btree (id);

CREATE UNIQUE INDEX wc_queue_pkey ON public.wc_queue USING btree (id);

CREATE UNIQUE INDEX wc_recordings_pkey ON public.wc_recordings USING btree (id);

CREATE UNIQUE INDEX wc_roles_pkey ON public.wc_roles USING btree (id);

CREATE UNIQUE INDEX wc_rooms_pkey ON public.wc_rooms USING btree (id);

CREATE UNIQUE INDEX wc_routing_edges_pkey ON public.wc_routing_edges USING btree (id);

CREATE UNIQUE INDEX wc_routing_rules_pkey ON public.wc_routing_rules USING btree (id);

CREATE UNIQUE INDEX wc_routing_steps_pkey ON public.wc_routing_steps USING btree (id);

CREATE INDEX wc_signaling_call_idx ON public.wc_signaling USING btree (call_id, to_profile_id);

CREATE UNIQUE INDEX wc_signaling_pkey ON public.wc_signaling USING btree (id);

CREATE UNIQUE INDEX wc_transcripts_pkey ON public.wc_transcripts USING btree (id);

CREATE UNIQUE INDEX wc_whatsapp_configs_pkey ON public.wc_whatsapp_configs USING btree (profile_id);

CREATE UNIQUE INDEX wc_whatsapp_messages_pkey ON public.wc_whatsapp_messages USING btree (id);

CREATE INDEX wc_whatsapp_messages_profile_id_idx ON public.wc_whatsapp_messages USING btree (profile_id, created_at DESC);

CREATE UNIQUE INDEX webrtc_signals_pkey ON public.webrtc_signals USING btree (id);

alter table "drizzle"."__drizzle_migrations" add constraint "__drizzle_migrations_pkey" PRIMARY KEY using index "__drizzle_migrations_pkey";

alter table "public"."account_activity_log" add constraint "account_activity_log_pkey" PRIMARY KEY using index "account_activity_log_pkey";

alter table "public"."activities" add constraint "activities_pkey" PRIMARY KEY using index "activities_pkey";

alter table "public"."activities_media" add constraint "activities_media_pkey" PRIMARY KEY using index "activities_media_pkey";

alter table "public"."activity_bookings" add constraint "activity_bookings_pkey" PRIMARY KEY using index "activity_bookings_pkey";

alter table "public"."activity_reviews" add constraint "activity_reviews_pkey" PRIMARY KEY using index "activity_reviews_pkey";

alter table "public"."activity_shares" add constraint "activity_shares_pkey" PRIMARY KEY using index "activity_shares_pkey";

alter table "public"."activity_views" add constraint "activity_views_pkey" PRIMARY KEY using index "activity_views_pkey";

alter table "public"."adminLogs" add constraint "adminLogs_pkey" PRIMARY KEY using index "adminLogs_pkey";

alter table "public"."admin_access_emails" add constraint "admin_access_emails_pkey" PRIMARY KEY using index "admin_access_emails_pkey";

alter table "public"."api_keys" add constraint "api_keys_pkey" PRIMARY KEY using index "api_keys_pkey";

alter table "public"."availability" add constraint "availability_pkey" PRIMARY KEY using index "availability_pkey";

alter table "public"."availability_slots" add constraint "availability_slots_pkey" PRIMARY KEY using index "availability_slots_pkey";

alter table "public"."blocked_dates" add constraint "blocked_dates_pkey" PRIMARY KEY using index "blocked_dates_pkey";

alter table "public"."bookingBouncers" add constraint "bookingBouncers_pkey" PRIMARY KEY using index "bookingBouncers_pkey";

alter table "public"."booking_review_audit_log" add constraint "booking_review_audit_log_pkey" PRIMARY KEY using index "booking_review_audit_log_pkey";

alter table "public"."booking_review_flags" add constraint "booking_review_flags_pkey" PRIMARY KEY using index "booking_review_flags_pkey";

alter table "public"."booking_review_helpful_votes" add constraint "booking_review_helpful_votes_pkey" PRIMARY KEY using index "booking_review_helpful_votes_pkey";

alter table "public"."booking_review_media" add constraint "booking_review_media_pkey" PRIMARY KEY using index "booking_review_media_pkey";

alter table "public"."booking_review_responses" add constraint "booking_review_responses_pkey" PRIMARY KEY using index "booking_review_responses_pkey";

alter table "public"."booking_reviews" add constraint "booking_reviews_pkey" PRIMARY KEY using index "booking_reviews_pkey";

alter table "public"."booking_status_history" add constraint "booking_status_history_pkey" PRIMARY KEY using index "booking_status_history_pkey";

alter table "public"."bookings" add constraint "bookings_pkey" PRIMARY KEY using index "bookings_pkey";

alter table "public"."bookings_v2" add constraint "bookings_v2_pkey" PRIMARY KEY using index "bookings_v2_pkey";

alter table "public"."bouncer_services" add constraint "bouncer_services_pkey" PRIMARY KEY using index "bouncer_services_pkey";

alter table "public"."bud_api_keys" add constraint "bud_api_keys_pkey" PRIMARY KEY using index "bud_api_keys_pkey";

alter table "public"."bud_conversations" add constraint "bud_conversations_pkey" PRIMARY KEY using index "bud_conversations_pkey";

alter table "public"."bud_conversations_v2" add constraint "bud_conversations_v2_pkey" PRIMARY KEY using index "bud_conversations_v2_pkey";

alter table "public"."call_ice_candidates" add constraint "call_ice_candidates_pkey" PRIMARY KEY using index "call_ice_candidates_pkey";

alter table "public"."call_logs" add constraint "call_logs_pkey" PRIMARY KEY using index "call_logs_pkey";

alter table "public"."call_transcripts" add constraint "call_transcripts_pkey" PRIMARY KEY using index "call_transcripts_pkey";

alter table "public"."campaigns" add constraint "campaigns_pkey" PRIMARY KEY using index "campaigns_pkey";

alter table "public"."cc_activities" add constraint "cc_activities_pkey" PRIMARY KEY using index "cc_activities_pkey";

alter table "public"."cc_activity_attendance" add constraint "cc_activity_attendance_pkey" PRIMARY KEY using index "cc_activity_attendance_pkey";

alter table "public"."cc_activity_templates" add constraint "cc_activity_templates_pkey" PRIMARY KEY using index "cc_activity_templates_pkey";

alter table "public"."cc_admin_users" add constraint "cc_admin_users_pkey" PRIMARY KEY using index "cc_admin_users_pkey";

alter table "public"."cc_audit_log" add constraint "cc_audit_log_pkey" PRIMARY KEY using index "cc_audit_log_pkey";

alter table "public"."cc_billing_info" add constraint "cc_billing_info_pkey" PRIMARY KEY using index "cc_billing_info_pkey";

alter table "public"."cc_companion_assignments" add constraint "cc_companion_assignments_pkey" PRIMARY KEY using index "cc_companion_assignments_pkey";

alter table "public"."cc_companion_bookings" add constraint "cc_companion_bookings_pkey" PRIMARY KEY using index "cc_companion_bookings_pkey";

alter table "public"."cc_companions" add constraint "cc_companions_pkey" PRIMARY KEY using index "cc_companions_pkey";

alter table "public"."cc_facilities" add constraint "cc_facilities_pkey" PRIMARY KEY using index "cc_facilities_pkey";

alter table "public"."cc_facility_members" add constraint "cc_facility_members_pkey" PRIMARY KEY using index "cc_facility_members_pkey";

alter table "public"."cc_family_connections" add constraint "cc_family_connections_pkey" PRIMARY KEY using index "cc_family_connections_pkey";

alter table "public"."cc_family_members" add constraint "cc_family_members_pkey" PRIMARY KEY using index "cc_family_members_pkey";

alter table "public"."cc_family_messages" add constraint "cc_family_messages_pkey" PRIMARY KEY using index "cc_family_messages_pkey";

alter table "public"."cc_family_users" add constraint "cc_family_users_pkey" PRIMARY KEY using index "cc_family_users_pkey";

alter table "public"."cc_marketplace_companions" add constraint "cc_marketplace_companions_pkey" PRIMARY KEY using index "cc_marketplace_companions_pkey";

alter table "public"."cc_messages" add constraint "cc_messages_pkey" PRIMARY KEY using index "cc_messages_pkey";

alter table "public"."cc_mood_checkins" add constraint "cc_mood_checkins_pkey" PRIMARY KEY using index "cc_mood_checkins_pkey";

alter table "public"."cc_org_users" add constraint "cc_org_users_pkey" PRIMARY KEY using index "cc_org_users_pkey";

alter table "public"."cc_residents" add constraint "cc_residents_pkey" PRIMARY KEY using index "cc_residents_pkey";

alter table "public"."cc_security_settings" add constraint "cc_security_settings_pkey" PRIMARY KEY using index "cc_security_settings_pkey";

alter table "public"."cc_session_notes" add constraint "cc_session_notes_pkey" PRIMARY KEY using index "cc_session_notes_pkey";

alter table "public"."cc_staff" add constraint "cc_staff_pkey" PRIMARY KEY using index "cc_staff_pkey";

alter table "public"."companion_activities" add constraint "companion_activities_pkey" PRIMARY KEY using index "companion_activities_pkey";

alter table "public"."companion_services" add constraint "companion_services_pkey" PRIMARY KEY using index "companion_services_pkey";

alter table "public"."companions" add constraint "companions_pkey" PRIMARY KEY using index "companions_pkey";

alter table "public"."companions_v2" add constraint "companions_v2_pkey" PRIMARY KEY using index "companions_v2_pkey";

alter table "public"."conversations" add constraint "conversations_pkey" PRIMARY KEY using index "conversations_pkey";

alter table "public"."ct_admissions" add constraint "ct_admissions_pkey" PRIMARY KEY using index "ct_admissions_pkey";

alter table "public"."ct_ai_insights" add constraint "ct_ai_insights_pkey" PRIMARY KEY using index "ct_ai_insights_pkey";

alter table "public"."ct_announcements" add constraint "ct_announcements_pkey" PRIMARY KEY using index "ct_announcements_pkey";

alter table "public"."ct_api_keys" add constraint "ct_api_keys_pkey" PRIMARY KEY using index "ct_api_keys_pkey";

alter table "public"."ct_assignment_documents" add constraint "ct_assignment_documents_pkey" PRIMARY KEY using index "ct_assignment_documents_pkey";

alter table "public"."ct_assignment_submissions" add constraint "ct_assignment_submissions_pkey" PRIMARY KEY using index "ct_assignment_submissions_pkey";

alter table "public"."ct_assignments" add constraint "ct_assignments_pkey" PRIMARY KEY using index "ct_assignments_pkey";

alter table "public"."ct_athletes" add constraint "ct_athletes_pkey" PRIMARY KEY using index "ct_athletes_pkey";

alter table "public"."ct_attendance" add constraint "ct_attendance_pkey" PRIMARY KEY using index "ct_attendance_pkey";

alter table "public"."ct_audit_logs" add constraint "ct_audit_logs_pkey" PRIMARY KEY using index "ct_audit_logs_pkey";

alter table "public"."ct_billing_invoices" add constraint "ct_billing_invoices_pkey" PRIMARY KEY using index "ct_billing_invoices_pkey";

alter table "public"."ct_billing_plans" add constraint "ct_billing_plans_pkey" PRIMARY KEY using index "ct_billing_plans_pkey";

alter table "public"."ct_blog_posts" add constraint "ct_blog_posts_pkey" PRIMARY KEY using index "ct_blog_posts_pkey";

alter table "public"."ct_broadcast_notifications" add constraint "ct_broadcast_notifications_pkey" PRIMARY KEY using index "ct_broadcast_notifications_pkey";

alter table "public"."ct_budget_items" add constraint "ct_budget_items_pkey" PRIMARY KEY using index "ct_budget_items_pkey";

alter table "public"."ct_budgets" add constraint "ct_budgets_pkey" PRIMARY KEY using index "ct_budgets_pkey";

alter table "public"."ct_challenge_entries" add constraint "ct_challenge_entries_pkey" PRIMARY KEY using index "ct_challenge_entries_pkey";

alter table "public"."ct_challenge_scores" add constraint "ct_challenge_scores_pkey" PRIMARY KEY using index "ct_challenge_scores_pkey";

alter table "public"."ct_children" add constraint "ct_children_pkey" PRIMARY KEY using index "ct_children_pkey";

alter table "public"."ct_classes" add constraint "ct_classes_pkey" PRIMARY KEY using index "ct_classes_pkey";

alter table "public"."ct_club_election_candidates" add constraint "ct_club_election_candidates_pkey" PRIMARY KEY using index "ct_club_election_candidates_pkey";

alter table "public"."ct_club_election_votes" add constraint "ct_club_election_votes_pkey" PRIMARY KEY using index "ct_club_election_votes_pkey";

alter table "public"."ct_club_elections" add constraint "ct_club_elections_pkey" PRIMARY KEY using index "ct_club_elections_pkey";

alter table "public"."ct_club_events" add constraint "ct_club_events_pkey" PRIMARY KEY using index "ct_club_events_pkey";

alter table "public"."ct_club_members" add constraint "ct_club_members_pkey" PRIMARY KEY using index "ct_club_members_pkey";

alter table "public"."ct_club_memberships" add constraint "ct_club_memberships_pkey" PRIMARY KEY using index "ct_club_memberships_pkey";

alter table "public"."ct_club_posts" add constraint "ct_club_posts_pkey" PRIMARY KEY using index "ct_club_posts_pkey";

alter table "public"."ct_club_recognition_requests" add constraint "ct_club_recognition_requests_pkey" PRIMARY KEY using index "ct_club_recognition_requests_pkey";

alter table "public"."ct_clubs" add constraint "ct_clubs_pkey" PRIMARY KEY using index "ct_clubs_pkey";

alter table "public"."ct_course_enrollments" add constraint "ct_course_enrollments_pkey" PRIMARY KEY using index "ct_course_enrollments_pkey";

alter table "public"."ct_courses" add constraint "ct_courses_pkey" PRIMARY KEY using index "ct_courses_pkey";

alter table "public"."ct_daily_reports" add constraint "ct_daily_reports_pkey" PRIMARY KEY using index "ct_daily_reports_pkey";

alter table "public"."ct_demo_requests" add constraint "ct_demo_requests_pkey" PRIMARY KEY using index "ct_demo_requests_pkey";

alter table "public"."ct_direct_messages" add constraint "ct_direct_messages_pkey" PRIMARY KEY using index "ct_direct_messages_pkey";

alter table "public"."ct_discovery_profiles" add constraint "ct_discovery_profiles_pkey" PRIMARY KEY using index "ct_discovery_profiles_pkey";

alter table "public"."ct_email_rate_limits" add constraint "ct_email_rate_limits_pkey" PRIMARY KEY using index "ct_email_rate_limits_pkey";

alter table "public"."ct_email_verifications" add constraint "ct_email_verifications_pkey" PRIMARY KEY using index "ct_email_verifications_pkey";

alter table "public"."ct_engagement_points" add constraint "ct_engagement_points_pkey" PRIMARY KEY using index "ct_engagement_points_pkey";

alter table "public"."ct_engagement_scores" add constraint "ct_engagement_scores_pkey" PRIMARY KEY using index "ct_engagement_scores_pkey";

alter table "public"."ct_enrollments" add constraint "ct_enrollments_pkey" PRIMARY KEY using index "ct_enrollments_pkey";

alter table "public"."ct_error_logs" add constraint "ct_error_logs_pkey" PRIMARY KEY using index "ct_error_logs_pkey";

alter table "public"."ct_event_rsvps" add constraint "ct_event_rsvps_pkey" PRIMARY KEY using index "ct_event_rsvps_pkey";

alter table "public"."ct_events" add constraint "ct_events_pkey" PRIMARY KEY using index "ct_events_pkey";

alter table "public"."ct_feature_events" add constraint "ct_feature_events_pkey" PRIMARY KEY using index "ct_feature_events_pkey";

alter table "public"."ct_free_trial_requests" add constraint "ct_free_trial_requests_pkey" PRIMARY KEY using index "ct_free_trial_requests_pkey";

alter table "public"."ct_funding_requests" add constraint "ct_funding_requests_pkey" PRIMARY KEY using index "ct_funding_requests_pkey";

alter table "public"."ct_games" add constraint "ct_games_pkey" PRIMARY KEY using index "ct_games_pkey";

alter table "public"."ct_grades" add constraint "ct_grades_pkey" PRIMARY KEY using index "ct_grades_pkey";

alter table "public"."ct_group_activities" add constraint "ct_group_activities_pkey" PRIMARY KEY using index "ct_group_activities_pkey";

alter table "public"."ct_group_activity_members" add constraint "ct_group_activity_members_pkey" PRIMARY KEY using index "ct_group_activity_members_pkey";

alter table "public"."ct_institution_requests" add constraint "ct_institution_requests_pkey" PRIMARY KEY using index "ct_institution_requests_pkey";

alter table "public"."ct_institution_settings" add constraint "ct_institution_settings_pkey" PRIMARY KEY using index "ct_institution_settings_pkey";

alter table "public"."ct_institution_subscriptions" add constraint "ct_institution_subscriptions_pkey" PRIMARY KEY using index "ct_institution_subscriptions_pkey";

alter table "public"."ct_institutions" add constraint "ct_institutions_pkey" PRIMARY KEY using index "ct_institutions_pkey";

alter table "public"."ct_interest_onboarding" add constraint "ct_interest_onboarding_pkey" PRIMARY KEY using index "ct_interest_onboarding_pkey";

alter table "public"."ct_match_participants" add constraint "ct_match_participants_pkey" PRIMARY KEY using index "ct_match_participants_pkey";

alter table "public"."ct_match_results" add constraint "ct_match_results_pkey" PRIMARY KEY using index "ct_match_results_pkey";

alter table "public"."ct_note_requests" add constraint "ct_note_requests_pkey" PRIMARY KEY using index "ct_note_requests_pkey";

alter table "public"."ct_notification_preferences" add constraint "ct_notification_preferences_pkey" PRIMARY KEY using index "ct_notification_preferences_pkey";

alter table "public"."ct_notification_prefs" add constraint "ct_notification_prefs_pkey" PRIMARY KEY using index "ct_notification_prefs_pkey";

alter table "public"."ct_notifications" add constraint "ct_notifications_pkey" PRIMARY KEY using index "ct_notifications_pkey";

alter table "public"."ct_onboarding" add constraint "ct_onboarding_pkey" PRIMARY KEY using index "ct_onboarding_pkey";

alter table "public"."ct_org_members" add constraint "ct_org_members_pkey" PRIMARY KEY using index "ct_org_members_pkey";

alter table "public"."ct_org_users" add constraint "ct_org_users_pkey" PRIMARY KEY using index "ct_org_users_pkey";

alter table "public"."ct_organizations" add constraint "ct_organizations_pkey" PRIMARY KEY using index "ct_organizations_pkey";

alter table "public"."ct_parent_links" add constraint "ct_parent_links_pkey" PRIMARY KEY using index "ct_parent_links_pkey";

alter table "public"."ct_parent_updates" add constraint "ct_parent_updates_pkey" PRIMARY KEY using index "ct_parent_updates_pkey";

alter table "public"."ct_payment_methods" add constraint "ct_payment_methods_pkey" PRIMARY KEY using index "ct_payment_methods_pkey";

alter table "public"."ct_peer_connections" add constraint "ct_peer_connections_pkey" PRIMARY KEY using index "ct_peer_connections_pkey";

alter table "public"."ct_performance_notes" add constraint "ct_performance_notes_pkey" PRIMARY KEY using index "ct_performance_notes_pkey";

alter table "public"."ct_platform_settings" add constraint "ct_platform_settings_pkey" PRIMARY KEY using index "ct_platform_settings_pkey";

alter table "public"."ct_sport_challenge_participants" add constraint "ct_sport_challenge_participants_pkey" PRIMARY KEY using index "ct_sport_challenge_participants_pkey";

alter table "public"."ct_sport_challenges" add constraint "ct_sport_challenges_pkey" PRIMARY KEY using index "ct_sport_challenges_pkey";

alter table "public"."ct_sport_participants" add constraint "ct_sport_participants_pkey" PRIMARY KEY using index "ct_sport_participants_pkey";

alter table "public"."ct_sport_rankings" add constraint "ct_sport_rankings_pkey" PRIMARY KEY using index "ct_sport_rankings_pkey";

alter table "public"."ct_sports_challenges" add constraint "ct_sports_challenges_pkey" PRIMARY KEY using index "ct_sports_challenges_pkey";

alter table "public"."ct_sports_games" add constraint "ct_sports_games_pkey" PRIMARY KEY using index "ct_sports_games_pkey";

alter table "public"."ct_sports_leagues" add constraint "ct_sports_leagues_pkey" PRIMARY KEY using index "ct_sports_leagues_pkey";

alter table "public"."ct_sports_teams" add constraint "ct_sports_teams_pkey" PRIMARY KEY using index "ct_sports_teams_pkey";

alter table "public"."ct_staff_registrations" add constraint "ct_staff_registrations_pkey" PRIMARY KEY using index "ct_staff_registrations_pkey";

alter table "public"."ct_stealth_sessions" add constraint "ct_stealth_sessions_pkey" PRIMARY KEY using index "ct_stealth_sessions_pkey";

alter table "public"."ct_student_journey" add constraint "ct_student_journey_pkey" PRIMARY KEY using index "ct_student_journey_pkey";

alter table "public"."ct_student_notes" add constraint "ct_student_notes_pkey" PRIMARY KEY using index "ct_student_notes_pkey";

alter table "public"."ct_student_registrations" add constraint "ct_student_registrations_pkey" PRIMARY KEY using index "ct_student_registrations_pkey";

alter table "public"."ct_students" add constraint "ct_students_pkey" PRIMARY KEY using index "ct_students_pkey";

alter table "public"."ct_submission_files" add constraint "ct_submission_files_pkey" PRIMARY KEY using index "ct_submission_files_pkey";

alter table "public"."ct_submissions" add constraint "ct_submissions_pkey" PRIMARY KEY using index "ct_submissions_pkey";

alter table "public"."ct_superadmins" add constraint "ct_superadmins_pkey" PRIMARY KEY using index "ct_superadmins_pkey";

alter table "public"."ct_survey_questions" add constraint "ct_survey_questions_pkey" PRIMARY KEY using index "ct_survey_questions_pkey";

alter table "public"."ct_survey_responses" add constraint "ct_survey_responses_pkey" PRIMARY KEY using index "ct_survey_responses_pkey";

alter table "public"."ct_surveys" add constraint "ct_surveys_pkey" PRIMARY KEY using index "ct_surveys_pkey";

alter table "public"."ct_teams" add constraint "ct_teams_pkey" PRIMARY KEY using index "ct_teams_pkey";

alter table "public"."ct_ticket_messages" add constraint "ct_ticket_messages_pkey" PRIMARY KEY using index "ct_ticket_messages_pkey";

alter table "public"."ct_tickets" add constraint "ct_tickets_pkey" PRIMARY KEY using index "ct_tickets_pkey";

alter table "public"."ct_tournament_matches" add constraint "ct_tournament_matches_pkey" PRIMARY KEY using index "ct_tournament_matches_pkey";

alter table "public"."ct_tournament_teams" add constraint "ct_tournament_teams_pkey" PRIMARY KEY using index "ct_tournament_teams_pkey";

alter table "public"."ct_tournaments" add constraint "ct_tournaments_pkey" PRIMARY KEY using index "ct_tournaments_pkey";

alter table "public"."ct_training_sessions" add constraint "ct_training_sessions_pkey" PRIMARY KEY using index "ct_training_sessions_pkey";

alter table "public"."ct_trial_requests" add constraint "ct_trial_requests_pkey" PRIMARY KEY using index "ct_trial_requests_pkey";

alter table "public"."ct_user_notifications" add constraint "ct_user_notifications_pkey" PRIMARY KEY using index "ct_user_notifications_pkey";

alter table "public"."ct_user_seat_billing" add constraint "ct_user_seat_billing_pkey" PRIMARY KEY using index "ct_user_seat_billing_pkey";

alter table "public"."ct_users" add constraint "ct_users_pkey" PRIMARY KEY using index "ct_users_pkey";

alter table "public"."ct_venue_booking_history" add constraint "ct_venue_booking_history_pkey" PRIMARY KEY using index "ct_venue_booking_history_pkey";

alter table "public"."ct_venue_bookings" add constraint "ct_venue_bookings_pkey" PRIMARY KEY using index "ct_venue_bookings_pkey";

alter table "public"."ct_venues" add constraint "ct_venues_pkey" PRIMARY KEY using index "ct_venues_pkey";

alter table "public"."ct_wellbeing_checkins" add constraint "ct_wellbeing_checkins_pkey" PRIMARY KEY using index "ct_wellbeing_checkins_pkey";

alter table "public"."ct_wellbeing_checks" add constraint "ct_wellbeing_checks_pkey" PRIMARY KEY using index "ct_wellbeing_checks_pkey";

alter table "public"."ct_wellness_checkins" add constraint "ct_wellness_checkins_pkey" PRIMARY KEY using index "ct_wellness_checkins_pkey";

alter table "public"."demo_requests" add constraint "demo_requests_pkey" PRIMARY KEY using index "demo_requests_pkey";

alter table "public"."earnings" add constraint "earnings_pkey" PRIMARY KEY using index "earnings_pkey";

alter table "public"."enterprise_invoices" add constraint "enterprise_invoices_pkey" PRIMARY KEY using index "enterprise_invoices_pkey";

alter table "public"."event_news_comments" add constraint "event_news_comments_pkey" PRIMARY KEY using index "event_news_comments_pkey";

alter table "public"."event_news_likes" add constraint "event_news_likes_pkey" PRIMARY KEY using index "event_news_likes_pkey";

alter table "public"."event_news_posts" add constraint "event_news_posts_pkey" PRIMARY KEY using index "event_news_posts_pkey";

alter table "public"."event_registrations" add constraint "event_registrations_pkey" PRIMARY KEY using index "event_registrations_pkey";

alter table "public"."events" add constraint "events_pkey" PRIMARY KEY using index "events_pkey";

alter table "public"."events_v2" add constraint "events_v2_pkey" PRIMARY KEY using index "events_v2_pkey";

alter table "public"."favorites" add constraint "favorites_pkey" PRIMARY KEY using index "favorites_pkey";

alter table "public"."group_conversation_members" add constraint "group_conversation_members_pkey" PRIMARY KEY using index "group_conversation_members_pkey";

alter table "public"."group_conversations" add constraint "group_conversations_pkey" PRIMARY KEY using index "group_conversations_pkey";

alter table "public"."group_messages" add constraint "group_messages_pkey" PRIMARY KEY using index "group_messages_pkey";

alter table "public"."interests" add constraint "interests_pkey" PRIMARY KEY using index "interests_pkey";

alter table "public"."media_comments" add constraint "media_comments_pkey" PRIMARY KEY using index "media_comments_pkey";

alter table "public"."media_likes" add constraint "media_likes_pkey" PRIMARY KEY using index "media_likes_pkey";

alter table "public"."media_uploads" add constraint "media_uploads_pkey" PRIMARY KEY using index "media_uploads_pkey";

alter table "public"."messages" add constraint "messages_pkey" PRIMARY KEY using index "messages_pkey";

alter table "public"."notifications" add constraint "notifications_pkey" PRIMARY KEY using index "notifications_pkey";

alter table "public"."panicEvents" add constraint "panicEvents_pkey" PRIMARY KEY using index "panicEvents_pkey";

alter table "public"."payment_methods" add constraint "payment_methods_pkey" PRIMARY KEY using index "payment_methods_pkey";

alter table "public"."payments" add constraint "payments_pkey" PRIMARY KEY using index "payments_pkey";

alter table "public"."photos" add constraint "photos_pkey" PRIMARY KEY using index "photos_pkey";

alter table "public"."profanity_terms" add constraint "profanity_terms_pkey" PRIMARY KEY using index "profanity_terms_pkey";

alter table "public"."profile_delete_backups" add constraint "profile_delete_backups_pkey" PRIMARY KEY using index "profile_delete_backups_pkey";

alter table "public"."profile_likes" add constraint "profile_likes_pkey" PRIMARY KEY using index "profile_likes_pkey";

alter table "public"."profile_media" add constraint "profile_media_pkey" PRIMARY KEY using index "profile_media_pkey";

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."push_tokens" add constraint "push_tokens_pkey" PRIMARY KEY using index "push_tokens_pkey";

alter table "public"."reports" add constraint "reports_pkey" PRIMARY KEY using index "reports_pkey";

alter table "public"."review_notification_outbox" add constraint "review_notification_outbox_pkey" PRIMARY KEY using index "review_notification_outbox_pkey";

alter table "public"."reviews" add constraint "reviews_pkey" PRIMARY KEY using index "reviews_pkey";

alter table "public"."reviews_v2" add constraint "reviews_v2_pkey" PRIMARY KEY using index "reviews_v2_pkey";

alter table "public"."roles" add constraint "roles_pkey" PRIMARY KEY using index "roles_pkey";

alter table "public"."safetyFlags" add constraint "safetyFlags_pkey" PRIMARY KEY using index "safetyFlags_pkey";

alter table "public"."seo_ai_rank_snapshots" add constraint "seo_ai_rank_snapshots_pkey" PRIMARY KEY using index "seo_ai_rank_snapshots_pkey";

alter table "public"."seo_ai_tracking_queries" add constraint "seo_ai_tracking_queries_pkey" PRIMARY KEY using index "seo_ai_tracking_queries_pkey";

alter table "public"."service_availability" add constraint "service_availability_pkey" PRIMARY KEY using index "service_availability_pkey";

alter table "public"."service_bookings" add constraint "service_bookings_pkey" PRIMARY KEY using index "service_bookings_pkey";

alter table "public"."service_providers_v2" add constraint "service_providers_v2_pkey" PRIMARY KEY using index "service_providers_v2_pkey";

alter table "public"."service_reviews" add constraint "service_reviews_pkey" PRIMARY KEY using index "service_reviews_pkey";

alter table "public"."services" add constraint "services_pkey" PRIMARY KEY using index "services_pkey";

alter table "public"."subscriptions" add constraint "subscriptions_pkey" PRIMARY KEY using index "subscriptions_pkey";

alter table "public"."transactions" add constraint "transactions_pkey" PRIMARY KEY using index "transactions_pkey";

alter table "public"."transactions_v2" add constraint "transactions_v2_pkey" PRIMARY KEY using index "transactions_v2_pkey";

alter table "public"."user_interests" add constraint "user_interests_pkey" PRIMARY KEY using index "user_interests_pkey";

alter table "public"."users" add constraint "users_pkey" PRIMARY KEY using index "users_pkey";

alter table "public"."users_v2" add constraint "users_v2_pkey" PRIMARY KEY using index "users_v2_pkey";

alter table "public"."verificationAudits" add constraint "verificationAudits_pkey" PRIMARY KEY using index "verificationAudits_pkey";

alter table "public"."verificationRequests" add constraint "verificationRequests_pkey" PRIMARY KEY using index "verificationRequests_pkey";

alter table "public"."vip_accounts" add constraint "vip_accounts_pkey" PRIMARY KEY using index "vip_accounts_pkey";

alter table "public"."voice_studio_clones" add constraint "voice_studio_clones_pkey" PRIMARY KEY using index "voice_studio_clones_pkey";

alter table "public"."voice_studio_jobs" add constraint "voice_studio_jobs_pkey" PRIMARY KEY using index "voice_studio_jobs_pkey";

alter table "public"."voice_studio_usage" add constraint "voice_studio_usage_pkey" PRIMARY KEY using index "voice_studio_usage_pkey";

alter table "public"."waitlist" add constraint "waitlist_pkey" PRIMARY KEY using index "waitlist_pkey";

alter table "public"."wallets" add constraint "wallets_pkey" PRIMARY KEY using index "wallets_pkey";

alter table "public"."wallets_v2" add constraint "wallets_v2_pkey" PRIMARY KEY using index "wallets_v2_pkey";

alter table "public"."wc_ai_agents" add constraint "wc_ai_agents_pkey" PRIMARY KEY using index "wc_ai_agents_pkey";

alter table "public"."wc_ai_cases" add constraint "wc_ai_cases_pkey" PRIMARY KEY using index "wc_ai_cases_pkey";

alter table "public"."wc_ai_employees" add constraint "wc_ai_employees_pkey" PRIMARY KEY using index "wc_ai_employees_pkey";

alter table "public"."wc_ai_staff" add constraint "wc_ai_staff_pkey" PRIMARY KEY using index "wc_ai_staff_pkey";

alter table "public"."wc_analytics" add constraint "wc_analytics_pkey" PRIMARY KEY using index "wc_analytics_pkey";

alter table "public"."wc_call_sessions" add constraint "wc_call_sessions_pkey" PRIMARY KEY using index "wc_call_sessions_pkey";

alter table "public"."wc_calls" add constraint "wc_calls_pkey" PRIMARY KEY using index "wc_calls_pkey";

alter table "public"."wc_contacts" add constraint "wc_contacts_pkey" PRIMARY KEY using index "wc_contacts_pkey";

alter table "public"."wc_departments" add constraint "wc_departments_pkey" PRIMARY KEY using index "wc_departments_pkey";

alter table "public"."wc_entitlements" add constraint "wc_entitlements_pkey" PRIMARY KEY using index "wc_entitlements_pkey";

alter table "public"."wc_followup_tasks" add constraint "wc_followup_tasks_pkey" PRIMARY KEY using index "wc_followup_tasks_pkey";

alter table "public"."wc_messages" add constraint "wc_messages_pkey" PRIMARY KEY using index "wc_messages_pkey";

alter table "public"."wc_number_requests" add constraint "wc_number_requests_pkey" PRIMARY KEY using index "wc_number_requests_pkey";

alter table "public"."wc_org_settings" add constraint "wc_org_settings_pkey" PRIMARY KEY using index "wc_org_settings_pkey";

alter table "public"."wc_org_users" add constraint "wc_org_users_pkey" PRIMARY KEY using index "wc_org_users_pkey";

alter table "public"."wc_participants" add constraint "wc_participants_pkey" PRIMARY KEY using index "wc_participants_pkey";

alter table "public"."wc_phone_numbers" add constraint "wc_phone_numbers_pkey" PRIMARY KEY using index "wc_phone_numbers_pkey";

alter table "public"."wc_queue" add constraint "wc_queue_pkey" PRIMARY KEY using index "wc_queue_pkey";

alter table "public"."wc_recordings" add constraint "wc_recordings_pkey" PRIMARY KEY using index "wc_recordings_pkey";

alter table "public"."wc_roles" add constraint "wc_roles_pkey" PRIMARY KEY using index "wc_roles_pkey";

alter table "public"."wc_rooms" add constraint "wc_rooms_pkey" PRIMARY KEY using index "wc_rooms_pkey";

alter table "public"."wc_routing_edges" add constraint "wc_routing_edges_pkey" PRIMARY KEY using index "wc_routing_edges_pkey";

alter table "public"."wc_routing_rules" add constraint "wc_routing_rules_pkey" PRIMARY KEY using index "wc_routing_rules_pkey";

alter table "public"."wc_routing_steps" add constraint "wc_routing_steps_pkey" PRIMARY KEY using index "wc_routing_steps_pkey";

alter table "public"."wc_signaling" add constraint "wc_signaling_pkey" PRIMARY KEY using index "wc_signaling_pkey";

alter table "public"."wc_transcripts" add constraint "wc_transcripts_pkey" PRIMARY KEY using index "wc_transcripts_pkey";

alter table "public"."wc_whatsapp_configs" add constraint "wc_whatsapp_configs_pkey" PRIMARY KEY using index "wc_whatsapp_configs_pkey";

alter table "public"."wc_whatsapp_messages" add constraint "wc_whatsapp_messages_pkey" PRIMARY KEY using index "wc_whatsapp_messages_pkey";

alter table "public"."webrtc_signals" add constraint "webrtc_signals_pkey" PRIMARY KEY using index "webrtc_signals_pkey";

alter table "public"."account_activity_log" add constraint "account_activity_log_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."account_activity_log" validate constraint "account_activity_log_profile_id_fkey";

alter table "public"."activities" add constraint "activities_host_id_fkey" FOREIGN KEY (host_id) REFERENCES public.profiles(id) not valid;

alter table "public"."activities" validate constraint "activities_host_id_fkey";

alter table "public"."activities_media" add constraint "activities_media_activity_id_fkey" FOREIGN KEY (activity_id) REFERENCES public.activities(id) ON DELETE CASCADE not valid;

alter table "public"."activities_media" validate constraint "activities_media_activity_id_fkey";

alter table "public"."activities_media" add constraint "activities_media_media_type_check" CHECK ((media_type = ANY (ARRAY['image'::text, 'video'::text]))) not valid;

alter table "public"."activities_media" validate constraint "activities_media_media_type_check";

alter table "public"."activity_bookings" add constraint "activity_bookings_activity_id_fkey" FOREIGN KEY (activity_id) REFERENCES public.companion_activities(id) ON DELETE CASCADE not valid;

alter table "public"."activity_bookings" validate constraint "activity_bookings_activity_id_fkey";

alter table "public"."activity_bookings" add constraint "activity_bookings_activity_id_user_id_booking_date_key" UNIQUE using index "activity_bookings_activity_id_user_id_booking_date_key";

alter table "public"."activity_bookings" add constraint "activity_bookings_booked_slots_check" CHECK ((booked_slots >= 1)) not valid;

alter table "public"."activity_bookings" validate constraint "activity_bookings_booked_slots_check";

alter table "public"."activity_bookings" add constraint "activity_bookings_host_payout_status_check" CHECK ((host_payout_status = ANY (ARRAY['locked'::text, 'eligible'::text, 'paid'::text]))) not valid;

alter table "public"."activity_bookings" validate constraint "activity_bookings_host_payout_status_check";

alter table "public"."activity_bookings" add constraint "activity_bookings_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."activity_bookings" validate constraint "activity_bookings_user_id_fkey";

alter table "public"."activity_reviews" add constraint "activity_reviews_activity_id_fkey" FOREIGN KEY (activity_id) REFERENCES public.companion_activities(id) ON DELETE CASCADE not valid;

alter table "public"."activity_reviews" validate constraint "activity_reviews_activity_id_fkey";

alter table "public"."activity_reviews" add constraint "activity_reviews_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES public.activity_bookings(id) ON DELETE CASCADE not valid;

alter table "public"."activity_reviews" validate constraint "activity_reviews_booking_id_fkey";

alter table "public"."activity_reviews" add constraint "activity_reviews_booking_id_key" UNIQUE using index "activity_reviews_booking_id_key";

alter table "public"."activity_reviews" add constraint "activity_reviews_companion_id_fkey" FOREIGN KEY (companion_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."activity_reviews" validate constraint "activity_reviews_companion_id_fkey";

alter table "public"."activity_reviews" add constraint "activity_reviews_rating_check" CHECK (((rating >= 1) AND (rating <= 5))) not valid;

alter table "public"."activity_reviews" validate constraint "activity_reviews_rating_check";

alter table "public"."activity_reviews" add constraint "activity_reviews_reviewer_id_fkey" FOREIGN KEY (reviewer_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."activity_reviews" validate constraint "activity_reviews_reviewer_id_fkey";

alter table "public"."activity_shares" add constraint "activity_shares_activity_id_fkey" FOREIGN KEY (activity_id) REFERENCES public.companion_activities(id) ON DELETE CASCADE not valid;

alter table "public"."activity_shares" validate constraint "activity_shares_activity_id_fkey";

alter table "public"."activity_shares" add constraint "activity_shares_platform_check" CHECK ((platform = ANY (ARRAY['whatsapp'::text, 'instagram'::text, 'tiktok'::text, 'twitter'::text, 'facebook'::text, 'copy_link'::text, 'native_share'::text, 'other'::text]))) not valid;

alter table "public"."activity_shares" validate constraint "activity_shares_platform_check";

alter table "public"."activity_shares" add constraint "activity_shares_shared_by_fkey" FOREIGN KEY (shared_by) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."activity_shares" validate constraint "activity_shares_shared_by_fkey";

alter table "public"."activity_views" add constraint "activity_views_activity_id_fkey" FOREIGN KEY (activity_id) REFERENCES public.companion_activities(id) ON DELETE CASCADE not valid;

alter table "public"."activity_views" validate constraint "activity_views_activity_id_fkey";

alter table "public"."activity_views" add constraint "activity_views_viewed_by_fkey" FOREIGN KEY (viewed_by) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."activity_views" validate constraint "activity_views_viewed_by_fkey";

alter table "public"."api_keys" add constraint "api_keys_api_key_hash_key" UNIQUE using index "api_keys_api_key_hash_key";

alter table "public"."api_keys" add constraint "api_keys_plan_check" CHECK ((plan = ANY (ARRAY['free'::text, 'growth'::text, 'scale'::text, 'enterprise'::text]))) not valid;

alter table "public"."api_keys" validate constraint "api_keys_plan_check";

alter table "public"."availability_slots" add constraint "availability_slots_profile_id_day_of_week_start_time_end_ti_key" UNIQUE using index "availability_slots_profile_id_day_of_week_start_time_end_ti_key";

alter table "public"."availability_slots" add constraint "availability_slots_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."availability_slots" validate constraint "availability_slots_profile_id_fkey";

alter table "public"."blocked_dates" add constraint "blocked_dates_profile_id_blocked_date_key" UNIQUE using index "blocked_dates_profile_id_blocked_date_key";

alter table "public"."blocked_dates" add constraint "blocked_dates_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."blocked_dates" validate constraint "blocked_dates_profile_id_fkey";

alter table "public"."booking_review_audit_log" add constraint "booking_review_audit_log_action_check" CHECK ((action = ANY (ARRAY['insert'::text, 'update'::text, 'delete'::text, 'submit'::text, 'moderate'::text, 'reveal'::text]))) not valid;

alter table "public"."booking_review_audit_log" validate constraint "booking_review_audit_log_action_check";

alter table "public"."booking_review_audit_log" add constraint "booking_review_audit_log_entity_type_check" CHECK ((entity_type = ANY (ARRAY['review'::text, 'media'::text, 'response'::text]))) not valid;

alter table "public"."booking_review_audit_log" validate constraint "booking_review_audit_log_entity_type_check";

alter table "public"."booking_review_flags" add constraint "booking_review_flags_review_id_fkey" FOREIGN KEY (review_id) REFERENCES public.booking_reviews(id) ON DELETE CASCADE not valid;

alter table "public"."booking_review_flags" validate constraint "booking_review_flags_review_id_fkey";

alter table "public"."booking_review_flags" add constraint "booking_review_flags_severity_check" CHECK (((severity >= 1) AND (severity <= 5))) not valid;

alter table "public"."booking_review_flags" validate constraint "booking_review_flags_severity_check";

alter table "public"."booking_review_helpful_votes" add constraint "booking_review_helpful_votes_review_id_fkey" FOREIGN KEY (review_id) REFERENCES public.booking_reviews(id) ON DELETE CASCADE not valid;

alter table "public"."booking_review_helpful_votes" validate constraint "booking_review_helpful_votes_review_id_fkey";

alter table "public"."booking_review_helpful_votes" add constraint "booking_review_helpful_votes_voter_profile_id_fkey" FOREIGN KEY (voter_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."booking_review_helpful_votes" validate constraint "booking_review_helpful_votes_voter_profile_id_fkey";

alter table "public"."booking_review_media" add constraint "booking_review_media_moderation_status_check" CHECK ((moderation_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text]))) not valid;

alter table "public"."booking_review_media" validate constraint "booking_review_media_moderation_status_check";

alter table "public"."booking_review_media" add constraint "booking_review_media_review_id_fkey" FOREIGN KEY (review_id) REFERENCES public.booking_reviews(id) ON DELETE CASCADE not valid;

alter table "public"."booking_review_media" validate constraint "booking_review_media_review_id_fkey";

alter table "public"."booking_review_media" add constraint "booking_review_media_reviewer_profile_id_fkey" FOREIGN KEY (reviewer_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."booking_review_media" validate constraint "booking_review_media_reviewer_profile_id_fkey";

alter table "public"."booking_review_responses" add constraint "booking_review_responses_body_len" CHECK (((char_length(body) >= 1) AND (char_length(body) <= 1000))) not valid;

alter table "public"."booking_review_responses" validate constraint "booking_review_responses_body_len";

alter table "public"."booking_review_responses" add constraint "booking_review_responses_responder_profile_id_fkey" FOREIGN KEY (responder_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."booking_review_responses" validate constraint "booking_review_responses_responder_profile_id_fkey";

alter table "public"."booking_review_responses" add constraint "booking_review_responses_review_id_fkey" FOREIGN KEY (review_id) REFERENCES public.booking_reviews(id) ON DELETE CASCADE not valid;

alter table "public"."booking_review_responses" validate constraint "booking_review_responses_review_id_fkey";

alter table "public"."booking_review_responses" add constraint "booking_review_responses_review_id_key" UNIQUE using index "booking_review_responses_review_id_key";

alter table "public"."booking_reviews" add constraint "booking_reviews_body_len" CHECK (((body IS NULL) OR (char_length(body) <= 3000))) not valid;

alter table "public"."booking_reviews" validate constraint "booking_reviews_body_len";

alter table "public"."booking_reviews" add constraint "booking_reviews_moderated_by_fkey" FOREIGN KEY (moderated_by) REFERENCES public.profiles(id) not valid;

alter table "public"."booking_reviews" validate constraint "booking_reviews_moderated_by_fkey";

alter table "public"."booking_reviews" add constraint "booking_reviews_moderation_status_check" CHECK ((moderation_status = ANY (ARRAY['pending'::text, 'approved'::text, 'flagged'::text, 'rejected'::text]))) not valid;

alter table "public"."booking_reviews" validate constraint "booking_reviews_moderation_status_check";

alter table "public"."booking_reviews" add constraint "booking_reviews_no_self" CHECK ((reviewer_profile_id <> reviewee_profile_id)) not valid;

alter table "public"."booking_reviews" validate constraint "booking_reviews_no_self";

alter table "public"."booking_reviews" add constraint "booking_reviews_one_per_direction" UNIQUE using index "booking_reviews_one_per_direction";

alter table "public"."booking_reviews" add constraint "booking_reviews_rating_range" CHECK (((rating IS NULL) OR ((rating >= 1) AND (rating <= 5)))) not valid;

alter table "public"."booking_reviews" validate constraint "booking_reviews_rating_range";

alter table "public"."booking_reviews" add constraint "booking_reviews_reviewee_profile_id_fkey" FOREIGN KEY (reviewee_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."booking_reviews" validate constraint "booking_reviews_reviewee_profile_id_fkey";

alter table "public"."booking_reviews" add constraint "booking_reviews_reviewer_profile_id_fkey" FOREIGN KEY (reviewer_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."booking_reviews" validate constraint "booking_reviews_reviewer_profile_id_fkey";

alter table "public"."booking_reviews" add constraint "booking_reviews_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'submitted'::text, 'revealed'::text, 'removed'::text]))) not valid;

alter table "public"."booking_reviews" validate constraint "booking_reviews_status_check";

alter table "public"."booking_status_history" add constraint "booking_status_history_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE not valid;

alter table "public"."booking_status_history" validate constraint "booking_status_history_booking_id_fkey";

alter table "public"."booking_status_history" add constraint "booking_status_history_changed_by_fkey" FOREIGN KEY (changed_by) REFERENCES public.profiles(id) not valid;

alter table "public"."booking_status_history" validate constraint "booking_status_history_changed_by_fkey";

alter table "public"."bookings" add constraint "bookings_bookerid_fkey" FOREIGN KEY ("bookerId") REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."bookings" validate constraint "bookings_bookerid_fkey";

alter table "public"."bookings" add constraint "bookings_bouncer_id_fkey" FOREIGN KEY (bouncer_id) REFERENCES public.profiles(id) not valid;

alter table "public"."bookings" validate constraint "bookings_bouncer_id_fkey";

alter table "public"."bookings" add constraint "bookings_bouncerid_fkey" FOREIGN KEY ("bouncerId") REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."bookings" validate constraint "bookings_bouncerid_fkey";

alter table "public"."bookings" add constraint "bookings_cancellation_requested_by_fkey" FOREIGN KEY (cancellation_requested_by) REFERENCES public.profiles(id) not valid;

alter table "public"."bookings" validate constraint "bookings_cancellation_requested_by_fkey";

alter table "public"."bookings" add constraint "bookings_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public.profiles(id) not valid;

alter table "public"."bookings" validate constraint "bookings_client_id_fkey";

alter table "public"."bookings" add constraint "bookings_companion_id_fkey" FOREIGN KEY (companion_id) REFERENCES public.profiles(id) not valid;

alter table "public"."bookings" validate constraint "bookings_companion_id_fkey";

alter table "public"."bookings" add constraint "bookings_providerid_fkey" FOREIGN KEY ("providerId") REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."bookings" validate constraint "bookings_providerid_fkey";

alter table "public"."bookings" add constraint "bookings_reschedule_requested_by_fkey" FOREIGN KEY (reschedule_requested_by) REFERENCES public.profiles(id) not valid;

alter table "public"."bookings" validate constraint "bookings_reschedule_requested_by_fkey";

alter table "public"."bookings" add constraint "bookings_status_check_v2" CHECK ((status = ANY (ARRAY['pending'::text, 'pending_bouncer'::text, 'approved'::text, 'denied'::text, 'proposed'::text, 'in_progress'::text, 'completed'::text, 'cancelled'::text, 'cancellation_requested'::text]))) not valid;

alter table "public"."bookings" validate constraint "bookings_status_check_v2";

alter table "public"."bookings_v2" add constraint "bookings_v2_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users_v2(id) ON DELETE CASCADE not valid;

alter table "public"."bookings_v2" validate constraint "bookings_v2_user_id_fkey";

alter table "public"."bouncer_services" add constraint "bouncer_services_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."bouncer_services" validate constraint "bouncer_services_profile_id_fkey";

alter table "public"."bouncer_services" add constraint "bouncer_services_profile_id_service_type_key" UNIQUE using index "bouncer_services_profile_id_service_type_key";

alter table "public"."bud_api_keys" add constraint "bud_api_keys_api_key_hash_key" UNIQUE using index "bud_api_keys_api_key_hash_key";

alter table "public"."bud_conversations" add constraint "bud_conversations_direction_check" CHECK ((direction = ANY (ARRAY['user'::text, 'bud'::text]))) not valid;

alter table "public"."bud_conversations" validate constraint "bud_conversations_direction_check";

alter table "public"."bud_conversations" add constraint "bud_conversations_source_check" CHECK ((source = ANY (ARRAY['llm'::text, 'edge'::text, 'nlp'::text]))) not valid;

alter table "public"."bud_conversations" validate constraint "bud_conversations_source_check";

alter table "public"."bud_conversations" add constraint "bud_conversations_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.api_keys(id) ON DELETE SET NULL not valid;

alter table "public"."bud_conversations" validate constraint "bud_conversations_tenant_id_fkey";

alter table "public"."bud_conversations" add constraint "bud_conversations_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."bud_conversations" validate constraint "bud_conversations_user_id_fkey";

alter table "public"."bud_conversations_v2" add constraint "bud_conversations_v2_api_key_id_fkey" FOREIGN KEY (api_key_id) REFERENCES public.bud_api_keys(id) ON DELETE SET NULL not valid;

alter table "public"."bud_conversations_v2" validate constraint "bud_conversations_v2_api_key_id_fkey";

alter table "public"."bud_conversations_v2" add constraint "bud_conversations_v2_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users_v2(id) ON DELETE CASCADE not valid;

alter table "public"."bud_conversations_v2" validate constraint "bud_conversations_v2_user_id_fkey";

alter table "public"."call_ice_candidates" add constraint "call_ice_candidates_call_log_id_fkey" FOREIGN KEY (call_log_id) REFERENCES public.call_logs(id) ON DELETE CASCADE not valid;

alter table "public"."call_ice_candidates" validate constraint "call_ice_candidates_call_log_id_fkey";

alter table "public"."call_ice_candidates" add constraint "call_ice_candidates_sender_profile_id_fkey" FOREIGN KEY (sender_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."call_ice_candidates" validate constraint "call_ice_candidates_sender_profile_id_fkey";

alter table "public"."call_logs" add constraint "call_logs_callee_profile_id_fkey" FOREIGN KEY (callee_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."call_logs" validate constraint "call_logs_callee_profile_id_fkey";

alter table "public"."call_logs" add constraint "call_logs_caller_profile_id_fkey" FOREIGN KEY (caller_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."call_logs" validate constraint "call_logs_caller_profile_id_fkey";

alter table "public"."call_logs" add constraint "call_logs_status_check" CHECK ((status = ANY (ARRAY['initiated'::text, 'ringing'::text, 'accepted'::text, 'declined'::text, 'missed'::text, 'ended'::text, 'failed'::text, 'cancelled'::text]))) not valid;

alter table "public"."call_logs" validate constraint "call_logs_status_check";

alter table "public"."call_transcripts" add constraint "call_transcripts_call_log_id_fkey" FOREIGN KEY (call_log_id) REFERENCES public.call_logs(id) ON DELETE CASCADE not valid;

alter table "public"."call_transcripts" validate constraint "call_transcripts_call_log_id_fkey";

alter table "public"."call_transcripts" add constraint "call_transcripts_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."call_transcripts" validate constraint "call_transcripts_profile_id_fkey";

alter table "public"."campaigns" add constraint "campaigns_activity_id_fkey" FOREIGN KEY (activity_id) REFERENCES public.companion_activities(id) ON DELETE SET NULL not valid;

alter table "public"."campaigns" validate constraint "campaigns_activity_id_fkey";

alter table "public"."campaigns" add constraint "campaigns_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."campaigns" validate constraint "campaigns_profile_id_fkey";

alter table "public"."campaigns" add constraint "campaigns_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'active'::text, 'paused'::text, 'ended'::text]))) not valid;

alter table "public"."campaigns" validate constraint "campaigns_status_check";

alter table "public"."cc_activities" add constraint "cc_activities_companion_id_fkey" FOREIGN KEY (companion_id) REFERENCES public.cc_companions(id) not valid;

alter table "public"."cc_activities" validate constraint "cc_activities_companion_id_fkey";

alter table "public"."cc_activities" add constraint "cc_activities_facility_id_fkey" FOREIGN KEY (facility_id) REFERENCES public.cc_facilities(id) ON DELETE CASCADE not valid;

alter table "public"."cc_activities" validate constraint "cc_activities_facility_id_fkey";

alter table "public"."cc_activity_attendance" add constraint "cc_activity_attendance_activity_id_fkey" FOREIGN KEY (activity_id) REFERENCES public.cc_activities(id) ON DELETE CASCADE not valid;

alter table "public"."cc_activity_attendance" validate constraint "cc_activity_attendance_activity_id_fkey";

alter table "public"."cc_activity_attendance" add constraint "cc_activity_attendance_activity_id_resident_id_key" UNIQUE using index "cc_activity_attendance_activity_id_resident_id_key";

alter table "public"."cc_activity_attendance" add constraint "cc_activity_attendance_resident_id_fkey" FOREIGN KEY (resident_id) REFERENCES public.cc_residents(id) ON DELETE CASCADE not valid;

alter table "public"."cc_activity_attendance" validate constraint "cc_activity_attendance_resident_id_fkey";

alter table "public"."cc_billing_info" add constraint "cc_billing_info_facility_id_key" UNIQUE using index "cc_billing_info_facility_id_key";

alter table "public"."cc_companion_assignments" add constraint "cc_companion_assignments_companion_id_fkey" FOREIGN KEY (companion_id) REFERENCES public.cc_companions(id) ON DELETE CASCADE not valid;

alter table "public"."cc_companion_assignments" validate constraint "cc_companion_assignments_companion_id_fkey";

alter table "public"."cc_companion_assignments" add constraint "cc_companion_assignments_companion_id_resident_id_key" UNIQUE using index "cc_companion_assignments_companion_id_resident_id_key";

alter table "public"."cc_companion_assignments" add constraint "cc_companion_assignments_resident_id_fkey" FOREIGN KEY (resident_id) REFERENCES public.cc_residents(id) ON DELETE CASCADE not valid;

alter table "public"."cc_companion_assignments" validate constraint "cc_companion_assignments_resident_id_fkey";

alter table "public"."cc_companion_bookings" add constraint "cc_companion_bookings_companion_id_fkey" FOREIGN KEY (companion_id) REFERENCES public.cc_companions(id) ON DELETE CASCADE not valid;

alter table "public"."cc_companion_bookings" validate constraint "cc_companion_bookings_companion_id_fkey";

alter table "public"."cc_companion_bookings" add constraint "cc_companion_bookings_resident_id_fkey" FOREIGN KEY (resident_id) REFERENCES public.cc_residents(id) ON DELETE CASCADE not valid;

alter table "public"."cc_companion_bookings" validate constraint "cc_companion_bookings_resident_id_fkey";

alter table "public"."cc_companions" add constraint "cc_companions_facility_id_fkey" FOREIGN KEY (facility_id) REFERENCES public.cc_facilities(id) not valid;

alter table "public"."cc_companions" validate constraint "cc_companions_facility_id_fkey";

alter table "public"."cc_companions" add constraint "cc_companions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."cc_companions" validate constraint "cc_companions_user_id_fkey";

alter table "public"."cc_facilities" add constraint "cc_facilities_slug_key" UNIQUE using index "cc_facilities_slug_key";

alter table "public"."cc_facility_members" add constraint "cc_facility_members_facility_id_fkey" FOREIGN KEY (facility_id) REFERENCES public.cc_facilities(id) ON DELETE CASCADE not valid;

alter table "public"."cc_facility_members" validate constraint "cc_facility_members_facility_id_fkey";

alter table "public"."cc_facility_members" add constraint "cc_facility_members_facility_id_user_id_key" UNIQUE using index "cc_facility_members_facility_id_user_id_key";

alter table "public"."cc_facility_members" add constraint "cc_facility_members_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."cc_facility_members" validate constraint "cc_facility_members_user_id_fkey";

alter table "public"."cc_family_connections" add constraint "cc_family_connections_resident_id_fkey" FOREIGN KEY (resident_id) REFERENCES public.cc_residents(id) ON DELETE CASCADE not valid;

alter table "public"."cc_family_connections" validate constraint "cc_family_connections_resident_id_fkey";

alter table "public"."cc_family_connections" add constraint "cc_family_connections_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."cc_family_connections" validate constraint "cc_family_connections_user_id_fkey";

alter table "public"."cc_family_members" add constraint "cc_family_members_resident_id_fkey" FOREIGN KEY (resident_id) REFERENCES public.cc_residents(id) ON DELETE CASCADE not valid;

alter table "public"."cc_family_members" validate constraint "cc_family_members_resident_id_fkey";

alter table "public"."cc_family_messages" add constraint "cc_family_messages_resident_id_fkey" FOREIGN KEY (resident_id) REFERENCES public.cc_residents(id) ON DELETE CASCADE not valid;

alter table "public"."cc_family_messages" validate constraint "cc_family_messages_resident_id_fkey";

alter table "public"."cc_family_users" add constraint "cc_family_users_family_user_id_resident_id_key" UNIQUE using index "cc_family_users_family_user_id_resident_id_key";

alter table "public"."cc_family_users" add constraint "cc_family_users_resident_id_fkey" FOREIGN KEY (resident_id) REFERENCES public.cc_residents(id) ON DELETE CASCADE not valid;

alter table "public"."cc_family_users" validate constraint "cc_family_users_resident_id_fkey";

alter table "public"."cc_marketplace_companions" add constraint "cc_marketplace_companions_companion_id_fkey" FOREIGN KEY (companion_id) REFERENCES public.cc_companions(id) ON DELETE CASCADE not valid;

alter table "public"."cc_marketplace_companions" validate constraint "cc_marketplace_companions_companion_id_fkey";

alter table "public"."cc_mood_checkins" add constraint "cc_mood_checkins_mood_score_check" CHECK (((mood_score >= 1) AND (mood_score <= 5))) not valid;

alter table "public"."cc_mood_checkins" validate constraint "cc_mood_checkins_mood_score_check";

alter table "public"."cc_mood_checkins" add constraint "cc_mood_checkins_resident_id_fkey" FOREIGN KEY (resident_id) REFERENCES public.cc_residents(id) ON DELETE CASCADE not valid;

alter table "public"."cc_mood_checkins" validate constraint "cc_mood_checkins_resident_id_fkey";

alter table "public"."cc_org_users" add constraint "cc_org_users_user_id_facility_id_key" UNIQUE using index "cc_org_users_user_id_facility_id_key";

alter table "public"."cc_residents" add constraint "cc_residents_facility_id_fkey" FOREIGN KEY (facility_id) REFERENCES public.cc_facilities(id) ON DELETE CASCADE not valid;

alter table "public"."cc_residents" validate constraint "cc_residents_facility_id_fkey";

alter table "public"."cc_security_settings" add constraint "cc_security_settings_facility_id_key" UNIQUE using index "cc_security_settings_facility_id_key";

alter table "public"."cc_session_notes" add constraint "cc_session_notes_activity_id_fkey" FOREIGN KEY (activity_id) REFERENCES public.cc_activities(id) not valid;

alter table "public"."cc_session_notes" validate constraint "cc_session_notes_activity_id_fkey";

alter table "public"."cc_session_notes" add constraint "cc_session_notes_companion_id_fkey" FOREIGN KEY (companion_id) REFERENCES public.cc_companions(id) not valid;

alter table "public"."cc_session_notes" validate constraint "cc_session_notes_companion_id_fkey";

alter table "public"."cc_session_notes" add constraint "cc_session_notes_resident_id_fkey" FOREIGN KEY (resident_id) REFERENCES public.cc_residents(id) ON DELETE CASCADE not valid;

alter table "public"."cc_session_notes" validate constraint "cc_session_notes_resident_id_fkey";

alter table "public"."companion_activities" add constraint "companion_activities_activity_category_check" CHECK ((activity_category = ANY (ARRAY['Active'::text, 'Culture'::text, 'Nightlife'::text, 'Dining'::text]))) not valid;

alter table "public"."companion_activities" validate constraint "companion_activities_activity_category_check";

alter table "public"."companion_activities" add constraint "companion_activities_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."companion_activities" validate constraint "companion_activities_created_by_fkey";

alter table "public"."companion_services" add constraint "companion_services_hours_range_check" CHECK ((max_hours >= min_hours)) not valid;

alter table "public"."companion_services" validate constraint "companion_services_hours_range_check";

alter table "public"."companion_services" add constraint "companion_services_max_hours_check" CHECK ((max_hours >= 1)) not valid;

alter table "public"."companion_services" validate constraint "companion_services_max_hours_check";

alter table "public"."companion_services" add constraint "companion_services_min_hours_check" CHECK ((min_hours >= 1)) not valid;

alter table "public"."companion_services" validate constraint "companion_services_min_hours_check";

alter table "public"."companion_services" add constraint "companion_services_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."companion_services" validate constraint "companion_services_profile_id_fkey";

alter table "public"."companion_services" add constraint "companion_services_profile_id_service_type_key" UNIQUE using index "companion_services_profile_id_service_type_key";

alter table "public"."companion_services" add constraint "companion_services_service_type_check" CHECK ((service_type = ANY (ARRAY['Mock date'::text, 'Concert Date'::text, 'Museum Buddy'::text, 'Hiking Partner'::text, 'Skiing Partner'::text, 'Dancing partner'::text, 'Night Club companion'::text]))) not valid;

alter table "public"."companion_services" validate constraint "companion_services_service_type_check";

alter table "public"."companions" add constraint "companions_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'paused'::text, 'suspended'::text]))) not valid;

alter table "public"."companions" validate constraint "companions_status_check";

alter table "public"."companions" add constraint "companions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."companions" validate constraint "companions_user_id_fkey";

alter table "public"."companions" add constraint "companions_user_id_key" UNIQUE using index "companions_user_id_key";

alter table "public"."companions_v2" add constraint "companions_v2_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users_v2(id) ON DELETE CASCADE not valid;

alter table "public"."companions_v2" validate constraint "companions_v2_user_id_fkey";

alter table "public"."companions_v2" add constraint "companions_v2_user_id_key" UNIQUE using index "companions_v2_user_id_key";

alter table "public"."conversations" add constraint "conversations_participant1_id_fkey" FOREIGN KEY (participant1_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."conversations" validate constraint "conversations_participant1_id_fkey";

alter table "public"."conversations" add constraint "conversations_participant2_id_fkey" FOREIGN KEY (participant2_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."conversations" validate constraint "conversations_participant2_id_fkey";

alter table "public"."ct_admissions" add constraint "ct_admissions_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_admissions" validate constraint "ct_admissions_institution_id_fkey";

alter table "public"."ct_admissions" add constraint "ct_admissions_reviewed_by_fkey" FOREIGN KEY (reviewed_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_admissions" validate constraint "ct_admissions_reviewed_by_fkey";

alter table "public"."ct_admissions" add constraint "ct_admissions_status_check" CHECK ((status = ANY (ARRAY['applied'::text, 'reviewing'::text, 'interview'::text, 'accepted'::text, 'rejected'::text, 'waitlisted'::text, 'enrolled'::text]))) not valid;

alter table "public"."ct_admissions" validate constraint "ct_admissions_status_check";

alter table "public"."ct_announcements" add constraint "ct_announcements_author_id_fkey" FOREIGN KEY (author_id) REFERENCES public.ct_users(id) ON DELETE SET NULL not valid;

alter table "public"."ct_announcements" validate constraint "ct_announcements_author_id_fkey";

alter table "public"."ct_announcements" add constraint "ct_announcements_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_announcements" validate constraint "ct_announcements_institution_id_fkey";

alter table "public"."ct_api_keys" add constraint "ct_api_keys_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_api_keys" validate constraint "ct_api_keys_created_by_fkey";

alter table "public"."ct_api_keys" add constraint "ct_api_keys_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_api_keys" validate constraint "ct_api_keys_institution_id_fkey";

alter table "public"."ct_assignment_documents" add constraint "ct_assignment_documents_assignment_id_fkey" FOREIGN KEY (assignment_id) REFERENCES public.ct_assignments(id) ON DELETE CASCADE not valid;

alter table "public"."ct_assignment_documents" validate constraint "ct_assignment_documents_assignment_id_fkey";

alter table "public"."ct_assignment_submissions" add constraint "ct_assignment_submissions_assignment_id_fkey" FOREIGN KEY (assignment_id) REFERENCES public.ct_assignments(id) ON DELETE CASCADE not valid;

alter table "public"."ct_assignment_submissions" validate constraint "ct_assignment_submissions_assignment_id_fkey";

alter table "public"."ct_assignment_submissions" add constraint "ct_assignment_submissions_assignment_id_student_id_key" UNIQUE using index "ct_assignment_submissions_assignment_id_student_id_key";

alter table "public"."ct_assignment_submissions" add constraint "ct_assignment_submissions_student_id_fkey" FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_assignment_submissions" validate constraint "ct_assignment_submissions_student_id_fkey";

alter table "public"."ct_assignments" add constraint "ct_assignments_assignment_type_check" CHECK ((assignment_type = ANY (ARRAY['assignment'::text, 'quiz'::text, 'midterm'::text, 'final'::text, 'lab'::text, 'project'::text]))) not valid;

alter table "public"."ct_assignments" validate constraint "ct_assignments_assignment_type_check";

alter table "public"."ct_assignments" add constraint "ct_assignments_class_id_fkey" FOREIGN KEY (class_id) REFERENCES public.ct_classes(id) not valid;

alter table "public"."ct_assignments" validate constraint "ct_assignments_class_id_fkey";

alter table "public"."ct_assignments" add constraint "ct_assignments_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_assignments" validate constraint "ct_assignments_created_by_fkey";

alter table "public"."ct_assignments" add constraint "ct_assignments_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_assignments" validate constraint "ct_assignments_institution_id_fkey";

alter table "public"."ct_assignments" add constraint "ct_assignments_teacher_id_fkey" FOREIGN KEY (teacher_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_assignments" validate constraint "ct_assignments_teacher_id_fkey";

alter table "public"."ct_athletes" add constraint "ct_athletes_team_id_fkey" FOREIGN KEY (team_id) REFERENCES public.ct_teams(id) not valid;

alter table "public"."ct_athletes" validate constraint "ct_athletes_team_id_fkey";

alter table "public"."ct_athletes" add constraint "ct_athletes_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_athletes" validate constraint "ct_athletes_user_id_fkey";

alter table "public"."ct_attendance" add constraint "ct_attendance_class_id_fkey" FOREIGN KEY (class_id) REFERENCES public.ct_classes(id) not valid;

alter table "public"."ct_attendance" validate constraint "ct_attendance_class_id_fkey";

alter table "public"."ct_attendance" add constraint "ct_attendance_status_check" CHECK ((status = ANY (ARRAY['present'::text, 'absent'::text, 'late'::text, 'excused'::text]))) not valid;

alter table "public"."ct_attendance" validate constraint "ct_attendance_status_check";

alter table "public"."ct_attendance" add constraint "ct_attendance_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_attendance" validate constraint "ct_attendance_student_id_fkey";

alter table "public"."ct_attendance" add constraint "ct_attendance_teacher_id_fkey" FOREIGN KEY (teacher_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_attendance" validate constraint "ct_attendance_teacher_id_fkey";

alter table "public"."ct_audit_logs" add constraint "ct_audit_logs_actor_id_fkey" FOREIGN KEY (actor_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_audit_logs" validate constraint "ct_audit_logs_actor_id_fkey";

alter table "public"."ct_audit_logs" add constraint "ct_audit_logs_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_audit_logs" validate constraint "ct_audit_logs_institution_id_fkey";

alter table "public"."ct_audit_logs" add constraint "ct_audit_logs_severity_check" CHECK ((severity = ANY (ARRAY['info'::text, 'warning'::text, 'error'::text, 'critical'::text]))) not valid;

alter table "public"."ct_audit_logs" validate constraint "ct_audit_logs_severity_check";

alter table "public"."ct_billing_invoices" add constraint "ct_billing_invoices_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_billing_invoices" validate constraint "ct_billing_invoices_institution_id_fkey";

alter table "public"."ct_billing_invoices" add constraint "ct_billing_invoices_payment_method_id_fkey" FOREIGN KEY (payment_method_id) REFERENCES public.ct_payment_methods(id) not valid;

alter table "public"."ct_billing_invoices" validate constraint "ct_billing_invoices_payment_method_id_fkey";

alter table "public"."ct_billing_invoices" add constraint "ct_billing_invoices_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'paid'::text, 'failed'::text, 'refunded'::text, 'waived'::text]))) not valid;

alter table "public"."ct_billing_invoices" validate constraint "ct_billing_invoices_status_check";

alter table "public"."ct_billing_invoices" add constraint "ct_billing_invoices_subscription_id_fkey" FOREIGN KEY (subscription_id) REFERENCES public.ct_institution_subscriptions(id) not valid;

alter table "public"."ct_billing_invoices" validate constraint "ct_billing_invoices_subscription_id_fkey";

alter table "public"."ct_billing_plans" add constraint "ct_billing_plans_billing_cycle_check" CHECK ((billing_cycle = ANY (ARRAY['monthly'::text, 'quarterly'::text, 'annual'::text]))) not valid;

alter table "public"."ct_billing_plans" validate constraint "ct_billing_plans_billing_cycle_check";

alter table "public"."ct_billing_plans" add constraint "ct_billing_plans_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_billing_plans" validate constraint "ct_billing_plans_institution_id_fkey";

alter table "public"."ct_blog_posts" add constraint "ct_blog_posts_slug_key" UNIQUE using index "ct_blog_posts_slug_key";

alter table "public"."ct_broadcast_notifications" add constraint "ct_broadcast_notifications_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "public"."ct_broadcast_notifications" validate constraint "ct_broadcast_notifications_created_by_fkey";

alter table "public"."ct_broadcast_notifications" add constraint "ct_broadcast_notifications_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_broadcast_notifications" validate constraint "ct_broadcast_notifications_institution_id_fkey";

alter table "public"."ct_budget_items" add constraint "ct_budget_items_approved_by_fkey" FOREIGN KEY (approved_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_budget_items" validate constraint "ct_budget_items_approved_by_fkey";

alter table "public"."ct_budget_items" add constraint "ct_budget_items_budget_id_fkey" FOREIGN KEY (budget_id) REFERENCES public.ct_budgets(id) not valid;

alter table "public"."ct_budget_items" validate constraint "ct_budget_items_budget_id_fkey";

alter table "public"."ct_budget_items" add constraint "ct_budget_items_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text]))) not valid;

alter table "public"."ct_budget_items" validate constraint "ct_budget_items_status_check";

alter table "public"."ct_budgets" add constraint "ct_budgets_club_id_fkey" FOREIGN KEY (club_id) REFERENCES public.ct_clubs(id) not valid;

alter table "public"."ct_budgets" validate constraint "ct_budgets_club_id_fkey";

alter table "public"."ct_budgets" add constraint "ct_budgets_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_budgets" validate constraint "ct_budgets_institution_id_fkey";

alter table "public"."ct_challenge_entries" add constraint "ct_challenge_entries_challenge_id_fkey" FOREIGN KEY (challenge_id) REFERENCES public.ct_sports_challenges(id) ON DELETE CASCADE not valid;

alter table "public"."ct_challenge_entries" validate constraint "ct_challenge_entries_challenge_id_fkey";

alter table "public"."ct_challenge_entries" add constraint "ct_challenge_entries_challenge_id_user_id_key" UNIQUE using index "ct_challenge_entries_challenge_id_user_id_key";

alter table "public"."ct_challenge_entries" add constraint "ct_challenge_entries_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_challenge_entries" validate constraint "ct_challenge_entries_user_id_fkey";

alter table "public"."ct_challenge_scores" add constraint "ct_challenge_scores_challenge_id_fkey" FOREIGN KEY (challenge_id) REFERENCES public.ct_sport_challenges(id) ON DELETE CASCADE not valid;

alter table "public"."ct_challenge_scores" validate constraint "ct_challenge_scores_challenge_id_fkey";

alter table "public"."ct_challenge_scores" add constraint "ct_challenge_scores_posted_by_fkey" FOREIGN KEY (posted_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_challenge_scores" validate constraint "ct_challenge_scores_posted_by_fkey";

alter table "public"."ct_challenge_scores" add constraint "ct_challenge_scores_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_challenge_scores" validate constraint "ct_challenge_scores_user_id_fkey";

alter table "public"."ct_children" add constraint "ct_children_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_children" validate constraint "ct_children_institution_id_fkey";

alter table "public"."ct_children" add constraint "ct_children_parent_id_fkey" FOREIGN KEY (parent_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_children" validate constraint "ct_children_parent_id_fkey";

alter table "public"."ct_children" add constraint "ct_children_teacher_id_fkey" FOREIGN KEY (teacher_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_children" validate constraint "ct_children_teacher_id_fkey";

alter table "public"."ct_classes" add constraint "ct_classes_course_id_fkey" FOREIGN KEY (course_id) REFERENCES public.ct_courses(id) not valid;

alter table "public"."ct_classes" validate constraint "ct_classes_course_id_fkey";

alter table "public"."ct_classes" add constraint "ct_classes_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_classes" validate constraint "ct_classes_institution_id_fkey";

alter table "public"."ct_classes" add constraint "ct_classes_teacher_id_fkey" FOREIGN KEY (teacher_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_classes" validate constraint "ct_classes_teacher_id_fkey";

alter table "public"."ct_club_election_candidates" add constraint "ct_club_election_candidates_election_id_fkey" FOREIGN KEY (election_id) REFERENCES public.ct_club_elections(id) ON DELETE CASCADE not valid;

alter table "public"."ct_club_election_candidates" validate constraint "ct_club_election_candidates_election_id_fkey";

alter table "public"."ct_club_election_candidates" add constraint "ct_club_election_candidates_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_students(id) ON DELETE CASCADE not valid;

alter table "public"."ct_club_election_candidates" validate constraint "ct_club_election_candidates_student_id_fkey";

alter table "public"."ct_club_election_votes" add constraint "ct_club_election_votes_candidate_id_fkey" FOREIGN KEY (candidate_id) REFERENCES public.ct_club_election_candidates(id) ON DELETE CASCADE not valid;

alter table "public"."ct_club_election_votes" validate constraint "ct_club_election_votes_candidate_id_fkey";

alter table "public"."ct_club_election_votes" add constraint "ct_club_election_votes_election_id_fkey" FOREIGN KEY (election_id) REFERENCES public.ct_club_elections(id) ON DELETE CASCADE not valid;

alter table "public"."ct_club_election_votes" validate constraint "ct_club_election_votes_election_id_fkey";

alter table "public"."ct_club_election_votes" add constraint "ct_club_election_votes_election_id_voter_id_key" UNIQUE using index "ct_club_election_votes_election_id_voter_id_key";

alter table "public"."ct_club_election_votes" add constraint "ct_club_election_votes_voter_id_fkey" FOREIGN KEY (voter_id) REFERENCES public.ct_students(id) ON DELETE CASCADE not valid;

alter table "public"."ct_club_election_votes" validate constraint "ct_club_election_votes_voter_id_fkey";

alter table "public"."ct_club_elections" add constraint "ct_club_elections_club_id_fkey" FOREIGN KEY (club_id) REFERENCES public.ct_clubs(id) ON DELETE CASCADE not valid;

alter table "public"."ct_club_elections" validate constraint "ct_club_elections_club_id_fkey";

alter table "public"."ct_club_events" add constraint "ct_club_events_club_id_fkey" FOREIGN KEY (club_id) REFERENCES public.ct_clubs(id) not valid;

alter table "public"."ct_club_events" validate constraint "ct_club_events_club_id_fkey";

alter table "public"."ct_club_events" add constraint "ct_club_events_event_id_fkey" FOREIGN KEY (event_id) REFERENCES public.ct_events(id) not valid;

alter table "public"."ct_club_events" validate constraint "ct_club_events_event_id_fkey";

alter table "public"."ct_club_members" add constraint "ct_club_members_club_id_fkey" FOREIGN KEY (club_id) REFERENCES public.ct_clubs(id) not valid;

alter table "public"."ct_club_members" validate constraint "ct_club_members_club_id_fkey";

alter table "public"."ct_club_members" add constraint "ct_club_members_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_club_members" validate constraint "ct_club_members_institution_id_fkey";

alter table "public"."ct_club_members" add constraint "ct_club_members_role_check" CHECK ((role = ANY (ARRAY['member'::text, 'officer'::text, 'leader'::text]))) not valid;

alter table "public"."ct_club_members" validate constraint "ct_club_members_role_check";

alter table "public"."ct_club_members" add constraint "ct_club_members_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'pending'::text, 'removed'::text]))) not valid;

alter table "public"."ct_club_members" validate constraint "ct_club_members_status_check";

alter table "public"."ct_club_members" add constraint "ct_club_members_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_club_members" validate constraint "ct_club_members_user_id_fkey";

alter table "public"."ct_club_memberships" add constraint "ct_club_memberships_club_id_fkey" FOREIGN KEY (club_id) REFERENCES public.ct_clubs(id) ON DELETE CASCADE not valid;

alter table "public"."ct_club_memberships" validate constraint "ct_club_memberships_club_id_fkey";

alter table "public"."ct_club_memberships" add constraint "ct_club_memberships_club_id_student_id_key" UNIQUE using index "ct_club_memberships_club_id_student_id_key";

alter table "public"."ct_club_memberships" add constraint "ct_club_memberships_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_students(id) ON DELETE CASCADE not valid;

alter table "public"."ct_club_memberships" validate constraint "ct_club_memberships_student_id_fkey";

alter table "public"."ct_club_posts" add constraint "ct_club_posts_author_id_fkey" FOREIGN KEY (author_id) REFERENCES public.ct_students(id) ON DELETE SET NULL not valid;

alter table "public"."ct_club_posts" validate constraint "ct_club_posts_author_id_fkey";

alter table "public"."ct_club_posts" add constraint "ct_club_posts_club_id_fkey" FOREIGN KEY (club_id) REFERENCES public.ct_clubs(id) ON DELETE CASCADE not valid;

alter table "public"."ct_club_posts" validate constraint "ct_club_posts_club_id_fkey";

alter table "public"."ct_clubs" add constraint "ct_clubs_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_clubs" validate constraint "ct_clubs_created_by_fkey";

alter table "public"."ct_clubs" add constraint "ct_clubs_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_clubs" validate constraint "ct_clubs_institution_id_fkey";

alter table "public"."ct_clubs" add constraint "ct_clubs_leader_id_fkey" FOREIGN KEY (leader_id) REFERENCES public.ct_users(id) ON DELETE SET NULL not valid;

alter table "public"."ct_clubs" validate constraint "ct_clubs_leader_id_fkey";

alter table "public"."ct_clubs" add constraint "ct_clubs_org_id_fkey" FOREIGN KEY (org_id) REFERENCES public.ct_organizations(id) ON DELETE CASCADE not valid;

alter table "public"."ct_clubs" validate constraint "ct_clubs_org_id_fkey";

alter table "public"."ct_course_enrollments" add constraint "ct_course_enrollments_course_id_fkey" FOREIGN KEY (course_id) REFERENCES public.ct_courses(id) ON DELETE CASCADE not valid;

alter table "public"."ct_course_enrollments" validate constraint "ct_course_enrollments_course_id_fkey";

alter table "public"."ct_course_enrollments" add constraint "ct_course_enrollments_course_id_student_id_key" UNIQUE using index "ct_course_enrollments_course_id_student_id_key";

alter table "public"."ct_course_enrollments" add constraint "ct_course_enrollments_student_id_fkey" FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_course_enrollments" validate constraint "ct_course_enrollments_student_id_fkey";

alter table "public"."ct_courses" add constraint "ct_courses_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_courses" validate constraint "ct_courses_institution_id_fkey";

alter table "public"."ct_daily_reports" add constraint "ct_daily_reports_child_id_fkey" FOREIGN KEY (child_id) REFERENCES public.ct_children(id) not valid;

alter table "public"."ct_daily_reports" validate constraint "ct_daily_reports_child_id_fkey";

alter table "public"."ct_daily_reports" add constraint "ct_daily_reports_mood_check" CHECK (((mood >= 1) AND (mood <= 5))) not valid;

alter table "public"."ct_daily_reports" validate constraint "ct_daily_reports_mood_check";

alter table "public"."ct_daily_reports" add constraint "ct_daily_reports_teacher_id_fkey" FOREIGN KEY (teacher_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_daily_reports" validate constraint "ct_daily_reports_teacher_id_fkey";

alter table "public"."ct_direct_messages" add constraint "ct_direct_messages_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_direct_messages" validate constraint "ct_direct_messages_institution_id_fkey";

alter table "public"."ct_direct_messages" add constraint "ct_direct_messages_recipient_id_fkey" FOREIGN KEY (recipient_id) REFERENCES auth.users(id) not valid;

alter table "public"."ct_direct_messages" validate constraint "ct_direct_messages_recipient_id_fkey";

alter table "public"."ct_direct_messages" add constraint "ct_direct_messages_sender_id_fkey" FOREIGN KEY (sender_id) REFERENCES auth.users(id) not valid;

alter table "public"."ct_direct_messages" validate constraint "ct_direct_messages_sender_id_fkey";

alter table "public"."ct_discovery_profiles" add constraint "ct_discovery_profiles_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_students(id) ON DELETE CASCADE not valid;

alter table "public"."ct_discovery_profiles" validate constraint "ct_discovery_profiles_student_id_fkey";

alter table "public"."ct_discovery_profiles" add constraint "ct_discovery_profiles_student_id_key" UNIQUE using index "ct_discovery_profiles_student_id_key";

alter table "public"."ct_email_verifications" add constraint "ct_email_verifications_token_key" UNIQUE using index "ct_email_verifications_token_key";

alter table "public"."ct_email_verifications" add constraint "ct_email_verifications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_email_verifications" validate constraint "ct_email_verifications_user_id_fkey";

alter table "public"."ct_engagement_points" add constraint "ct_engagement_points_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_engagement_points" validate constraint "ct_engagement_points_institution_id_fkey";

alter table "public"."ct_engagement_points" add constraint "ct_engagement_points_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_engagement_points" validate constraint "ct_engagement_points_user_id_fkey";

alter table "public"."ct_engagement_scores" add constraint "ct_engagement_scores_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_engagement_scores" validate constraint "ct_engagement_scores_institution_id_fkey";

alter table "public"."ct_engagement_scores" add constraint "ct_engagement_scores_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_engagement_scores" validate constraint "ct_engagement_scores_user_id_fkey";

alter table "public"."ct_engagement_scores" add constraint "ct_engagement_scores_user_id_key" UNIQUE using index "ct_engagement_scores_user_id_key";

alter table "public"."ct_enrollments" add constraint "ct_enrollments_class_id_fkey" FOREIGN KEY (class_id) REFERENCES public.ct_classes(id) not valid;

alter table "public"."ct_enrollments" validate constraint "ct_enrollments_class_id_fkey";

alter table "public"."ct_enrollments" add constraint "ct_enrollments_status_check" CHECK ((status = ANY (ARRAY['enrolled'::text, 'dropped'::text, 'completed'::text, 'waitlisted'::text]))) not valid;

alter table "public"."ct_enrollments" validate constraint "ct_enrollments_status_check";

alter table "public"."ct_enrollments" add constraint "ct_enrollments_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_enrollments" validate constraint "ct_enrollments_student_id_fkey";

alter table "public"."ct_error_logs" add constraint "ct_error_logs_level_check" CHECK ((level = ANY (ARRAY['error'::text, 'warning'::text, 'info'::text]))) not valid;

alter table "public"."ct_error_logs" validate constraint "ct_error_logs_level_check";

alter table "public"."ct_event_rsvps" add constraint "ct_event_rsvps_event_id_fkey" FOREIGN KEY (event_id) REFERENCES public.ct_events(id) ON DELETE CASCADE not valid;

alter table "public"."ct_event_rsvps" validate constraint "ct_event_rsvps_event_id_fkey";

alter table "public"."ct_event_rsvps" add constraint "ct_event_rsvps_event_id_student_id_key" UNIQUE using index "ct_event_rsvps_event_id_student_id_key";

alter table "public"."ct_event_rsvps" add constraint "ct_event_rsvps_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_students(id) ON DELETE CASCADE not valid;

alter table "public"."ct_event_rsvps" validate constraint "ct_event_rsvps_student_id_fkey";

alter table "public"."ct_events" add constraint "ct_events_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "public"."ct_events" validate constraint "ct_events_created_by_fkey";

alter table "public"."ct_events" add constraint "ct_events_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_events" validate constraint "ct_events_institution_id_fkey";

alter table "public"."ct_events" add constraint "ct_events_org_id_fkey" FOREIGN KEY (org_id) REFERENCES public.ct_organizations(id) ON DELETE CASCADE not valid;

alter table "public"."ct_events" validate constraint "ct_events_org_id_fkey";

alter table "public"."ct_free_trial_requests" add constraint "ct_free_trial_requests_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_free_trial_requests" validate constraint "ct_free_trial_requests_institution_id_fkey";

alter table "public"."ct_free_trial_requests" add constraint "ct_free_trial_requests_reviewed_by_fkey" FOREIGN KEY (reviewed_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_free_trial_requests" validate constraint "ct_free_trial_requests_reviewed_by_fkey";

alter table "public"."ct_free_trial_requests" add constraint "ct_free_trial_requests_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text]))) not valid;

alter table "public"."ct_free_trial_requests" validate constraint "ct_free_trial_requests_status_check";

alter table "public"."ct_free_trial_requests" add constraint "ct_free_trial_requests_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_free_trial_requests" validate constraint "ct_free_trial_requests_user_id_fkey";

alter table "public"."ct_funding_requests" add constraint "ct_funding_requests_club_id_fkey" FOREIGN KEY (club_id) REFERENCES public.ct_clubs(id) ON DELETE CASCADE not valid;

alter table "public"."ct_funding_requests" validate constraint "ct_funding_requests_club_id_fkey";

alter table "public"."ct_funding_requests" add constraint "ct_funding_requests_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_funding_requests" validate constraint "ct_funding_requests_institution_id_fkey";

alter table "public"."ct_funding_requests" add constraint "ct_funding_requests_reviewed_by_fkey" FOREIGN KEY (reviewed_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_funding_requests" validate constraint "ct_funding_requests_reviewed_by_fkey";

alter table "public"."ct_funding_requests" add constraint "ct_funding_requests_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text, 'cancelled'::text]))) not valid;

alter table "public"."ct_funding_requests" validate constraint "ct_funding_requests_status_check";

alter table "public"."ct_funding_requests" add constraint "ct_funding_requests_submitted_by_fkey" FOREIGN KEY (submitted_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_funding_requests" validate constraint "ct_funding_requests_submitted_by_fkey";

alter table "public"."ct_games" add constraint "ct_games_away_team_id_fkey" FOREIGN KEY (away_team_id) REFERENCES public.ct_teams(id) not valid;

alter table "public"."ct_games" validate constraint "ct_games_away_team_id_fkey";

alter table "public"."ct_games" add constraint "ct_games_home_team_id_fkey" FOREIGN KEY (home_team_id) REFERENCES public.ct_teams(id) not valid;

alter table "public"."ct_games" validate constraint "ct_games_home_team_id_fkey";

alter table "public"."ct_games" add constraint "ct_games_status_check" CHECK ((status = ANY (ARRAY['scheduled'::text, 'live'::text, 'completed'::text, 'cancelled'::text]))) not valid;

alter table "public"."ct_games" validate constraint "ct_games_status_check";

alter table "public"."ct_games" add constraint "ct_games_venue_id_fkey" FOREIGN KEY (venue_id) REFERENCES public.ct_venues(id) not valid;

alter table "public"."ct_games" validate constraint "ct_games_venue_id_fkey";

alter table "public"."ct_grades" add constraint "ct_grades_assignment_id_fkey" FOREIGN KEY (assignment_id) REFERENCES public.ct_assignments(id) not valid;

alter table "public"."ct_grades" validate constraint "ct_grades_assignment_id_fkey";

alter table "public"."ct_grades" add constraint "ct_grades_assignment_student_unique" UNIQUE using index "ct_grades_assignment_student_unique";

alter table "public"."ct_grades" add constraint "ct_grades_class_id_fkey" FOREIGN KEY (class_id) REFERENCES public.ct_classes(id) not valid;

alter table "public"."ct_grades" validate constraint "ct_grades_class_id_fkey";

alter table "public"."ct_grades" add constraint "ct_grades_enrollment_id_fkey" FOREIGN KEY (enrollment_id) REFERENCES public.ct_enrollments(id) not valid;

alter table "public"."ct_grades" validate constraint "ct_grades_enrollment_id_fkey";

alter table "public"."ct_grades" add constraint "ct_grades_graded_by_fkey" FOREIGN KEY (graded_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_grades" validate constraint "ct_grades_graded_by_fkey";

alter table "public"."ct_grades" add constraint "ct_grades_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_grades" validate constraint "ct_grades_student_id_fkey";

alter table "public"."ct_group_activities" add constraint "ct_group_activities_venue_id_fkey" FOREIGN KEY (venue_id) REFERENCES public.ct_venues(id) ON DELETE SET NULL not valid;

alter table "public"."ct_group_activities" validate constraint "ct_group_activities_venue_id_fkey";

alter table "public"."ct_group_activity_members" add constraint "ct_group_activity_members_activity_id_fkey" FOREIGN KEY (activity_id) REFERENCES public.ct_group_activities(id) ON DELETE CASCADE not valid;

alter table "public"."ct_group_activity_members" validate constraint "ct_group_activity_members_activity_id_fkey";

alter table "public"."ct_group_activity_members" add constraint "ct_group_activity_members_activity_id_student_id_key" UNIQUE using index "ct_group_activity_members_activity_id_student_id_key";

alter table "public"."ct_group_activity_members" add constraint "ct_group_activity_members_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_students(id) ON DELETE CASCADE not valid;

alter table "public"."ct_group_activity_members" validate constraint "ct_group_activity_members_student_id_fkey";

alter table "public"."ct_institution_requests" add constraint "ct_institution_requests_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_institution_requests" validate constraint "ct_institution_requests_institution_id_fkey";

alter table "public"."ct_institution_requests" add constraint "ct_institution_requests_request_type_check" CHECK ((request_type = ANY (ARRAY['join_existing'::text, 'create_new'::text, 'change_institution'::text]))) not valid;

alter table "public"."ct_institution_requests" validate constraint "ct_institution_requests_request_type_check";

alter table "public"."ct_institution_requests" add constraint "ct_institution_requests_reviewed_by_fkey" FOREIGN KEY (reviewed_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_institution_requests" validate constraint "ct_institution_requests_reviewed_by_fkey";

alter table "public"."ct_institution_requests" add constraint "ct_institution_requests_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text]))) not valid;

alter table "public"."ct_institution_requests" validate constraint "ct_institution_requests_status_check";

alter table "public"."ct_institution_requests" add constraint "ct_institution_requests_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_institution_requests" validate constraint "ct_institution_requests_user_id_fkey";

alter table "public"."ct_institution_settings" add constraint "ct_institution_settings_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_institution_settings" validate constraint "ct_institution_settings_institution_id_fkey";

alter table "public"."ct_institution_settings" add constraint "ct_institution_settings_institution_id_key_key" UNIQUE using index "ct_institution_settings_institution_id_key_key";

alter table "public"."ct_institution_subscriptions" add constraint "ct_institution_subscriptions_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_institution_subscriptions" validate constraint "ct_institution_subscriptions_institution_id_fkey";

alter table "public"."ct_institution_subscriptions" add constraint "ct_institution_subscriptions_institution_id_key" UNIQUE using index "ct_institution_subscriptions_institution_id_key";

alter table "public"."ct_institution_subscriptions" add constraint "ct_institution_subscriptions_payment_method_id_fkey" FOREIGN KEY (payment_method_id) REFERENCES public.ct_payment_methods(id) not valid;

alter table "public"."ct_institution_subscriptions" validate constraint "ct_institution_subscriptions_payment_method_id_fkey";

alter table "public"."ct_institution_subscriptions" add constraint "ct_institution_subscriptions_plan_id_fkey" FOREIGN KEY (plan_id) REFERENCES public.ct_billing_plans(id) not valid;

alter table "public"."ct_institution_subscriptions" validate constraint "ct_institution_subscriptions_plan_id_fkey";

alter table "public"."ct_institution_subscriptions" add constraint "ct_institution_subscriptions_status_check" CHECK ((status = ANY (ARRAY['trial'::text, 'active'::text, 'past_due'::text, 'cancelled'::text, 'pending_payment'::text]))) not valid;

alter table "public"."ct_institution_subscriptions" validate constraint "ct_institution_subscriptions_status_check";

alter table "public"."ct_institutions" add constraint "ct_institutions_domain_key" UNIQUE using index "ct_institutions_domain_key";

alter table "public"."ct_institutions" add constraint "ct_institutions_institution_type_check" CHECK ((institution_type = ANY (ARRAY['university'::text, 'school'::text, 'preschool'::text]))) not valid;

alter table "public"."ct_institutions" validate constraint "ct_institutions_institution_type_check";

alter table "public"."ct_institutions" add constraint "ct_institutions_invite_code_key" UNIQUE using index "ct_institutions_invite_code_key";

alter table "public"."ct_interest_onboarding" add constraint "ct_interest_onboarding_user_id_key" UNIQUE using index "ct_interest_onboarding_user_id_key";

alter table "public"."ct_match_participants" add constraint "ct_match_participants_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_match_participants" validate constraint "ct_match_participants_institution_id_fkey";

alter table "public"."ct_match_participants" add constraint "ct_match_participants_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_match_participants" validate constraint "ct_match_participants_user_id_fkey";

alter table "public"."ct_match_results" add constraint "ct_match_results_challenge_id_fkey" FOREIGN KEY (challenge_id) REFERENCES public.ct_sports_challenges(id) ON DELETE SET NULL not valid;

alter table "public"."ct_match_results" validate constraint "ct_match_results_challenge_id_fkey";

alter table "public"."ct_match_results" add constraint "ct_match_results_winner_id_fkey" FOREIGN KEY (winner_id) REFERENCES public.ct_students(id) ON DELETE SET NULL not valid;

alter table "public"."ct_match_results" validate constraint "ct_match_results_winner_id_fkey";

alter table "public"."ct_note_requests" add constraint "ct_note_requests_course_id_fkey" FOREIGN KEY (course_id) REFERENCES public.ct_courses(id) not valid;

alter table "public"."ct_note_requests" validate constraint "ct_note_requests_course_id_fkey";

alter table "public"."ct_note_requests" add constraint "ct_note_requests_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_note_requests" validate constraint "ct_note_requests_institution_id_fkey";

alter table "public"."ct_note_requests" add constraint "ct_note_requests_parent_id_fkey" FOREIGN KEY (parent_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_note_requests" validate constraint "ct_note_requests_parent_id_fkey";

alter table "public"."ct_note_requests" add constraint "ct_note_requests_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_note_requests" validate constraint "ct_note_requests_student_id_fkey";

alter table "public"."ct_note_requests" add constraint "ct_note_requests_teacher_id_fkey" FOREIGN KEY (teacher_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_note_requests" validate constraint "ct_note_requests_teacher_id_fkey";

alter table "public"."ct_notification_preferences" add constraint "ct_notification_preferences_user_id_key" UNIQUE using index "ct_notification_preferences_user_id_key";

alter table "public"."ct_notification_prefs" add constraint "ct_notification_prefs_channel_check" CHECK ((channel = ANY (ARRAY['email'::text, 'in_app'::text]))) not valid;

alter table "public"."ct_notification_prefs" validate constraint "ct_notification_prefs_channel_check";

alter table "public"."ct_notification_prefs" add constraint "ct_notification_prefs_user_id_channel_event_type_key" UNIQUE using index "ct_notification_prefs_user_id_channel_event_type_key";

alter table "public"."ct_notification_prefs" add constraint "ct_notification_prefs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_notification_prefs" validate constraint "ct_notification_prefs_user_id_fkey";

alter table "public"."ct_notifications" add constraint "ct_notifications_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_notifications" validate constraint "ct_notifications_created_by_fkey";

alter table "public"."ct_notifications" add constraint "ct_notifications_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_notifications" validate constraint "ct_notifications_institution_id_fkey";

alter table "public"."ct_onboarding" add constraint "ct_onboarding_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_onboarding" validate constraint "ct_onboarding_institution_id_fkey";

alter table "public"."ct_onboarding" add constraint "ct_onboarding_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_onboarding" validate constraint "ct_onboarding_user_id_fkey";

alter table "public"."ct_onboarding" add constraint "ct_onboarding_user_id_key" UNIQUE using index "ct_onboarding_user_id_key";

alter table "public"."ct_org_members" add constraint "ct_org_members_org_id_fkey" FOREIGN KEY (org_id) REFERENCES public.ct_organizations(id) ON DELETE CASCADE not valid;

alter table "public"."ct_org_members" validate constraint "ct_org_members_org_id_fkey";

alter table "public"."ct_org_members" add constraint "ct_org_members_org_id_user_id_key" UNIQUE using index "ct_org_members_org_id_user_id_key";

alter table "public"."ct_org_members" add constraint "ct_org_members_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_org_members" validate constraint "ct_org_members_user_id_fkey";

alter table "public"."ct_org_users" add constraint "ct_org_users_user_id_org_id_key" UNIQUE using index "ct_org_users_user_id_org_id_key";

alter table "public"."ct_organizations" add constraint "ct_organizations_slug_key" UNIQUE using index "ct_organizations_slug_key";

alter table "public"."ct_parent_links" add constraint "ct_parent_links_parent_user_id_student_id_key" UNIQUE using index "ct_parent_links_parent_user_id_student_id_key";

alter table "public"."ct_parent_links" add constraint "ct_parent_links_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_students(id) ON DELETE CASCADE not valid;

alter table "public"."ct_parent_links" validate constraint "ct_parent_links_student_id_fkey";

alter table "public"."ct_parent_updates" add constraint "ct_parent_updates_author_id_fkey" FOREIGN KEY (author_id) REFERENCES public.ct_users(id) ON DELETE SET NULL not valid;

alter table "public"."ct_parent_updates" validate constraint "ct_parent_updates_author_id_fkey";

alter table "public"."ct_parent_updates" add constraint "ct_parent_updates_child_id_fkey" FOREIGN KEY (child_id) REFERENCES public.ct_children(id) ON DELETE CASCADE not valid;

alter table "public"."ct_parent_updates" validate constraint "ct_parent_updates_child_id_fkey";

alter table "public"."ct_parent_updates" add constraint "ct_parent_updates_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_parent_updates" validate constraint "ct_parent_updates_institution_id_fkey";

alter table "public"."ct_payment_methods" add constraint "ct_payment_methods_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_payment_methods" validate constraint "ct_payment_methods_institution_id_fkey";

alter table "public"."ct_payment_methods" add constraint "ct_payment_methods_payment_type_check" CHECK ((payment_type = ANY (ARRAY['card'::text, 'bank_transfer'::text, 'direct_deposit'::text]))) not valid;

alter table "public"."ct_payment_methods" validate constraint "ct_payment_methods_payment_type_check";

alter table "public"."ct_payment_methods" add constraint "ct_payment_methods_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_payment_methods" validate constraint "ct_payment_methods_user_id_fkey";

alter table "public"."ct_peer_connections" add constraint "ct_peer_connections_recipient_id_fkey" FOREIGN KEY (recipient_id) REFERENCES public.ct_students(id) ON DELETE CASCADE not valid;

alter table "public"."ct_peer_connections" validate constraint "ct_peer_connections_recipient_id_fkey";

alter table "public"."ct_peer_connections" add constraint "ct_peer_connections_requester_id_fkey" FOREIGN KEY (requester_id) REFERENCES public.ct_students(id) ON DELETE CASCADE not valid;

alter table "public"."ct_peer_connections" validate constraint "ct_peer_connections_requester_id_fkey";

alter table "public"."ct_peer_connections" add constraint "ct_peer_connections_requester_id_recipient_id_key" UNIQUE using index "ct_peer_connections_requester_id_recipient_id_key";

alter table "public"."ct_performance_notes" add constraint "ct_performance_notes_class_id_fkey" FOREIGN KEY (class_id) REFERENCES public.ct_classes(id) not valid;

alter table "public"."ct_performance_notes" validate constraint "ct_performance_notes_class_id_fkey";

alter table "public"."ct_performance_notes" add constraint "ct_performance_notes_course_id_fkey" FOREIGN KEY (course_id) REFERENCES public.ct_courses(id) not valid;

alter table "public"."ct_performance_notes" validate constraint "ct_performance_notes_course_id_fkey";

alter table "public"."ct_performance_notes" add constraint "ct_performance_notes_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_performance_notes" validate constraint "ct_performance_notes_institution_id_fkey";

alter table "public"."ct_performance_notes" add constraint "ct_performance_notes_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_performance_notes" validate constraint "ct_performance_notes_student_id_fkey";

alter table "public"."ct_performance_notes" add constraint "ct_performance_notes_teacher_id_fkey" FOREIGN KEY (teacher_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_performance_notes" validate constraint "ct_performance_notes_teacher_id_fkey";

alter table "public"."ct_platform_settings" add constraint "ct_platform_settings_institution_category_provider_key" UNIQUE using index "ct_platform_settings_institution_category_provider_key";

alter table "public"."ct_platform_settings" add constraint "ct_platform_settings_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_platform_settings" validate constraint "ct_platform_settings_institution_id_fkey";

alter table "public"."ct_platform_settings" add constraint "ct_platform_settings_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES public.ct_users(id) ON DELETE SET NULL not valid;

alter table "public"."ct_platform_settings" validate constraint "ct_platform_settings_updated_by_fkey";

alter table "public"."ct_sport_challenge_participants" add constraint "ct_sport_challenge_participants_challenge_id_fkey" FOREIGN KEY (challenge_id) REFERENCES public.ct_sport_challenges(id) ON DELETE CASCADE not valid;

alter table "public"."ct_sport_challenge_participants" validate constraint "ct_sport_challenge_participants_challenge_id_fkey";

alter table "public"."ct_sport_challenge_participants" add constraint "ct_sport_challenge_participants_challenge_id_user_id_key" UNIQUE using index "ct_sport_challenge_participants_challenge_id_user_id_key";

alter table "public"."ct_sport_challenge_participants" add constraint "ct_sport_challenge_participants_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_sport_challenge_participants" validate constraint "ct_sport_challenge_participants_user_id_fkey";

alter table "public"."ct_sport_challenges" add constraint "ct_sport_challenges_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_sport_challenges" validate constraint "ct_sport_challenges_created_by_fkey";

alter table "public"."ct_sport_challenges" add constraint "ct_sport_challenges_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_sport_challenges" validate constraint "ct_sport_challenges_institution_id_fkey";

alter table "public"."ct_sport_participants" add constraint "ct_sport_participants_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_students(id) ON DELETE CASCADE not valid;

alter table "public"."ct_sport_participants" validate constraint "ct_sport_participants_student_id_fkey";

alter table "public"."ct_sport_participants" add constraint "ct_sport_participants_student_id_team_id_key" UNIQUE using index "ct_sport_participants_student_id_team_id_key";

alter table "public"."ct_sport_participants" add constraint "ct_sport_participants_team_id_fkey" FOREIGN KEY (team_id) REFERENCES public.ct_sports_teams(id) ON DELETE CASCADE not valid;

alter table "public"."ct_sport_participants" validate constraint "ct_sport_participants_team_id_fkey";

alter table "public"."ct_sport_rankings" add constraint "ct_sport_rankings_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_sport_rankings" validate constraint "ct_sport_rankings_user_id_fkey";

alter table "public"."ct_sport_rankings" add constraint "ct_sport_rankings_user_id_institution_id_sport_key" UNIQUE using index "ct_sport_rankings_user_id_institution_id_sport_key";

alter table "public"."ct_sport_rankings" add constraint "ct_sport_rankings_user_institution_sport" UNIQUE using index "ct_sport_rankings_user_institution_sport";

alter table "public"."ct_sports_challenges" add constraint "ct_sports_challenges_challenged_id_fkey" FOREIGN KEY (challenged_id) REFERENCES public.ct_students(id) ON DELETE CASCADE not valid;

alter table "public"."ct_sports_challenges" validate constraint "ct_sports_challenges_challenged_id_fkey";

alter table "public"."ct_sports_challenges" add constraint "ct_sports_challenges_challenger_id_fkey" FOREIGN KEY (challenger_id) REFERENCES public.ct_students(id) ON DELETE CASCADE not valid;

alter table "public"."ct_sports_challenges" validate constraint "ct_sports_challenges_challenger_id_fkey";

alter table "public"."ct_sports_challenges" add constraint "ct_sports_challenges_org_id_fkey" FOREIGN KEY (org_id) REFERENCES public.ct_organizations(id) ON DELETE CASCADE not valid;

alter table "public"."ct_sports_challenges" validate constraint "ct_sports_challenges_org_id_fkey";

alter table "public"."ct_sports_challenges" add constraint "ct_sports_challenges_venue_id_fkey" FOREIGN KEY (venue_id) REFERENCES public.ct_venues(id) ON DELETE SET NULL not valid;

alter table "public"."ct_sports_challenges" validate constraint "ct_sports_challenges_venue_id_fkey";

alter table "public"."ct_stealth_sessions" add constraint "ct_stealth_sessions_superadmin_id_fkey" FOREIGN KEY (superadmin_id) REFERENCES public.ct_superadmins(id) ON DELETE CASCADE not valid;

alter table "public"."ct_stealth_sessions" validate constraint "ct_stealth_sessions_superadmin_id_fkey";

alter table "public"."ct_stealth_sessions" add constraint "ct_stealth_sessions_target_institution_id_fkey" FOREIGN KEY (target_institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_stealth_sessions" validate constraint "ct_stealth_sessions_target_institution_id_fkey";

alter table "public"."ct_stealth_sessions" add constraint "ct_stealth_sessions_target_user_id_fkey" FOREIGN KEY (target_user_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_stealth_sessions" validate constraint "ct_stealth_sessions_target_user_id_fkey";

alter table "public"."ct_student_journey" add constraint "ct_student_journey_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_students(id) ON DELETE CASCADE not valid;

alter table "public"."ct_student_journey" validate constraint "ct_student_journey_student_id_fkey";

alter table "public"."ct_student_notes" add constraint "ct_student_notes_class_id_fkey" FOREIGN KEY (class_id) REFERENCES public.ct_classes(id) not valid;

alter table "public"."ct_student_notes" validate constraint "ct_student_notes_class_id_fkey";

alter table "public"."ct_student_notes" add constraint "ct_student_notes_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_student_notes" validate constraint "ct_student_notes_student_id_fkey";

alter table "public"."ct_student_notes" add constraint "ct_student_notes_teacher_id_fkey" FOREIGN KEY (teacher_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_student_notes" validate constraint "ct_student_notes_teacher_id_fkey";

alter table "public"."ct_students" add constraint "ct_students_org_id_fkey" FOREIGN KEY (org_id) REFERENCES public.ct_organizations(id) ON DELETE CASCADE not valid;

alter table "public"."ct_students" validate constraint "ct_students_org_id_fkey";

alter table "public"."ct_students" add constraint "ct_students_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."ct_students" validate constraint "ct_students_user_id_fkey";

alter table "public"."ct_submission_files" add constraint "ct_submission_files_submission_id_fkey" FOREIGN KEY (submission_id) REFERENCES public.ct_assignment_submissions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_submission_files" validate constraint "ct_submission_files_submission_id_fkey";

alter table "public"."ct_submissions" add constraint "ct_submissions_assignment_id_fkey" FOREIGN KEY (assignment_id) REFERENCES public.ct_assignments(id) not valid;

alter table "public"."ct_submissions" validate constraint "ct_submissions_assignment_id_fkey";

alter table "public"."ct_submissions" add constraint "ct_submissions_graded_by_fkey" FOREIGN KEY (graded_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_submissions" validate constraint "ct_submissions_graded_by_fkey";

alter table "public"."ct_submissions" add constraint "ct_submissions_status_check" CHECK ((status = ANY (ARRAY['submitted'::text, 'graded'::text, 'returned'::text, 'late'::text]))) not valid;

alter table "public"."ct_submissions" validate constraint "ct_submissions_status_check";

alter table "public"."ct_submissions" add constraint "ct_submissions_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_submissions" validate constraint "ct_submissions_student_id_fkey";

alter table "public"."ct_superadmins" add constraint "ct_superadmins_email_key" UNIQUE using index "ct_superadmins_email_key";

alter table "public"."ct_superadmins" add constraint "ct_superadmins_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_superadmins" validate constraint "ct_superadmins_user_id_fkey";

alter table "public"."ct_superadmins" add constraint "ct_superadmins_user_id_key" UNIQUE using index "ct_superadmins_user_id_key";

alter table "public"."ct_survey_questions" add constraint "ct_survey_questions_survey_id_fkey" FOREIGN KEY (survey_id) REFERENCES public.ct_surveys(id) ON DELETE CASCADE not valid;

alter table "public"."ct_survey_questions" validate constraint "ct_survey_questions_survey_id_fkey";

alter table "public"."ct_survey_responses" add constraint "ct_survey_responses_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_students(id) ON DELETE SET NULL not valid;

alter table "public"."ct_survey_responses" validate constraint "ct_survey_responses_student_id_fkey";

alter table "public"."ct_survey_responses" add constraint "ct_survey_responses_survey_id_fkey" FOREIGN KEY (survey_id) REFERENCES public.ct_surveys(id) ON DELETE CASCADE not valid;

alter table "public"."ct_survey_responses" validate constraint "ct_survey_responses_survey_id_fkey";

alter table "public"."ct_survey_responses" add constraint "ct_survey_responses_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_survey_responses" validate constraint "ct_survey_responses_user_id_fkey";

alter table "public"."ct_surveys" add constraint "ct_surveys_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_surveys" validate constraint "ct_surveys_institution_id_fkey";

alter table "public"."ct_teams" add constraint "ct_teams_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_teams" validate constraint "ct_teams_coach_id_fkey";

alter table "public"."ct_teams" add constraint "ct_teams_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_teams" validate constraint "ct_teams_institution_id_fkey";

alter table "public"."ct_ticket_messages" add constraint "ct_ticket_messages_sender_id_fkey" FOREIGN KEY (sender_id) REFERENCES auth.users(id) not valid;

alter table "public"."ct_ticket_messages" validate constraint "ct_ticket_messages_sender_id_fkey";

alter table "public"."ct_ticket_messages" add constraint "ct_ticket_messages_ticket_id_fkey" FOREIGN KEY (ticket_id) REFERENCES public.ct_tickets(id) ON DELETE CASCADE not valid;

alter table "public"."ct_ticket_messages" validate constraint "ct_ticket_messages_ticket_id_fkey";

alter table "public"."ct_tickets" add constraint "ct_tickets_assigned_to_fkey" FOREIGN KEY (assigned_to) REFERENCES auth.users(id) not valid;

alter table "public"."ct_tickets" validate constraint "ct_tickets_assigned_to_fkey";

alter table "public"."ct_tickets" add constraint "ct_tickets_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "public"."ct_tickets" validate constraint "ct_tickets_created_by_fkey";

alter table "public"."ct_tickets" add constraint "ct_tickets_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_tickets" validate constraint "ct_tickets_institution_id_fkey";

alter table "public"."ct_tickets" add constraint "ct_tickets_priority_check" CHECK ((priority = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'urgent'::text]))) not valid;

alter table "public"."ct_tickets" validate constraint "ct_tickets_priority_check";

alter table "public"."ct_tickets" add constraint "ct_tickets_status_check" CHECK ((status = ANY (ARRAY['open'::text, 'in_progress'::text, 'resolved'::text, 'closed'::text]))) not valid;

alter table "public"."ct_tickets" validate constraint "ct_tickets_status_check";

alter table "public"."ct_tickets" add constraint "ct_tickets_ticket_type_check" CHECK ((ticket_type = ANY (ARRAY['ops'::text, 'it'::text, 'admin'::text, 'general'::text]))) not valid;

alter table "public"."ct_tickets" validate constraint "ct_tickets_ticket_type_check";

alter table "public"."ct_tournament_matches" add constraint "ct_tournament_matches_team_a_id_fkey" FOREIGN KEY (team_a_id) REFERENCES public.ct_tournament_teams(id) ON DELETE SET NULL not valid;

alter table "public"."ct_tournament_matches" validate constraint "ct_tournament_matches_team_a_id_fkey";

alter table "public"."ct_tournament_matches" add constraint "ct_tournament_matches_team_b_id_fkey" FOREIGN KEY (team_b_id) REFERENCES public.ct_tournament_teams(id) ON DELETE SET NULL not valid;

alter table "public"."ct_tournament_matches" validate constraint "ct_tournament_matches_team_b_id_fkey";

alter table "public"."ct_tournament_matches" add constraint "ct_tournament_matches_tournament_id_fkey" FOREIGN KEY (tournament_id) REFERENCES public.ct_tournaments(id) ON DELETE CASCADE not valid;

alter table "public"."ct_tournament_matches" validate constraint "ct_tournament_matches_tournament_id_fkey";

alter table "public"."ct_tournament_matches" add constraint "ct_tournament_matches_winner_id_fkey" FOREIGN KEY (winner_id) REFERENCES public.ct_tournament_teams(id) ON DELETE SET NULL not valid;

alter table "public"."ct_tournament_matches" validate constraint "ct_tournament_matches_winner_id_fkey";

alter table "public"."ct_tournament_teams" add constraint "ct_tournament_teams_team_id_fkey" FOREIGN KEY (team_id) REFERENCES public.ct_sports_teams(id) ON DELETE SET NULL not valid;

alter table "public"."ct_tournament_teams" validate constraint "ct_tournament_teams_team_id_fkey";

alter table "public"."ct_tournament_teams" add constraint "ct_tournament_teams_tournament_id_fkey" FOREIGN KEY (tournament_id) REFERENCES public.ct_tournaments(id) ON DELETE CASCADE not valid;

alter table "public"."ct_tournament_teams" validate constraint "ct_tournament_teams_tournament_id_fkey";

alter table "public"."ct_tournament_teams" add constraint "ct_tournament_teams_tournament_id_team_id_key" UNIQUE using index "ct_tournament_teams_tournament_id_team_id_key";

alter table "public"."ct_training_sessions" add constraint "ct_training_sessions_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_training_sessions" validate constraint "ct_training_sessions_coach_id_fkey";

alter table "public"."ct_training_sessions" add constraint "ct_training_sessions_team_id_fkey" FOREIGN KEY (team_id) REFERENCES public.ct_teams(id) not valid;

alter table "public"."ct_training_sessions" validate constraint "ct_training_sessions_team_id_fkey";

alter table "public"."ct_training_sessions" add constraint "ct_training_sessions_venue_id_fkey" FOREIGN KEY (venue_id) REFERENCES public.ct_venues(id) not valid;

alter table "public"."ct_training_sessions" validate constraint "ct_training_sessions_venue_id_fkey";

alter table "public"."ct_trial_requests" add constraint "ct_trial_requests_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."ct_trial_requests" validate constraint "ct_trial_requests_user_id_fkey";

alter table "public"."ct_trial_requests" add constraint "ct_trial_requests_user_id_key" UNIQUE using index "ct_trial_requests_user_id_key";

alter table "public"."ct_user_notifications" add constraint "ct_user_notifications_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_user_notifications" validate constraint "ct_user_notifications_institution_id_fkey";

alter table "public"."ct_user_notifications" add constraint "ct_user_notifications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_user_notifications" validate constraint "ct_user_notifications_user_id_fkey";

alter table "public"."ct_user_seat_billing" add constraint "ct_user_seat_billing_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_user_seat_billing" validate constraint "ct_user_seat_billing_institution_id_fkey";

alter table "public"."ct_user_seat_billing" add constraint "ct_user_seat_billing_institution_id_user_id_key" UNIQUE using index "ct_user_seat_billing_institution_id_user_id_key";

alter table "public"."ct_user_seat_billing" add constraint "ct_user_seat_billing_paid_by_fkey" FOREIGN KEY (paid_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_user_seat_billing" validate constraint "ct_user_seat_billing_paid_by_fkey";

alter table "public"."ct_user_seat_billing" add constraint "ct_user_seat_billing_subscription_id_fkey" FOREIGN KEY (subscription_id) REFERENCES public.ct_institution_subscriptions(id) not valid;

alter table "public"."ct_user_seat_billing" validate constraint "ct_user_seat_billing_subscription_id_fkey";

alter table "public"."ct_user_seat_billing" add constraint "ct_user_seat_billing_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_user_seat_billing" validate constraint "ct_user_seat_billing_user_id_fkey";

alter table "public"."ct_users" add constraint "ct_users_athlete_coach_id_fkey" FOREIGN KEY (athlete_coach_id) REFERENCES public.ct_users(id) ON DELETE SET NULL not valid;

alter table "public"."ct_users" validate constraint "ct_users_athlete_coach_id_fkey";

alter table "public"."ct_users" add constraint "ct_users_athlete_team_id_fkey" FOREIGN KEY (athlete_team_id) REFERENCES public.ct_sports_teams(id) ON DELETE SET NULL not valid;

alter table "public"."ct_users" validate constraint "ct_users_athlete_team_id_fkey";

alter table "public"."ct_users" add constraint "ct_users_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."ct_users" validate constraint "ct_users_id_fkey";

alter table "public"."ct_users" add constraint "ct_users_payment_status_check" CHECK ((payment_status = ANY (ARRAY['not_required'::text, 'pending'::text, 'paid'::text, 'overdue'::text]))) not valid;

alter table "public"."ct_users" validate constraint "ct_users_payment_status_check";

alter table "public"."ct_users" add constraint "ct_users_role_check" CHECK ((role = ANY (ARRAY['student'::text, 'student_rep'::text, 'teacher'::text, 'admin'::text, 'coach'::text, 'club_leader'::text, 'staff'::text, 'it_director'::text, 'parent'::text]))) not valid;

alter table "public"."ct_users" validate constraint "ct_users_role_check";

alter table "public"."ct_venue_booking_history" add constraint "ct_venue_booking_history_action_check" CHECK ((action = ANY (ARRAY['submitted'::text, 'status_changed'::text, 'note_updated'::text, 'reviewed'::text]))) not valid;

alter table "public"."ct_venue_booking_history" validate constraint "ct_venue_booking_history_action_check";

alter table "public"."ct_venue_booking_history" add constraint "ct_venue_booking_history_actor_id_fkey" FOREIGN KEY (actor_id) REFERENCES public.ct_users(id) ON DELETE SET NULL not valid;

alter table "public"."ct_venue_booking_history" validate constraint "ct_venue_booking_history_actor_id_fkey";

alter table "public"."ct_venue_booking_history" add constraint "ct_venue_booking_history_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES public.ct_venue_bookings(id) ON DELETE CASCADE not valid;

alter table "public"."ct_venue_booking_history" validate constraint "ct_venue_booking_history_booking_id_fkey";

alter table "public"."ct_venue_bookings" add constraint "ct_venue_bookings_approved_by_fkey" FOREIGN KEY (approved_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_venue_bookings" validate constraint "ct_venue_bookings_approved_by_fkey";

alter table "public"."ct_venue_bookings" add constraint "ct_venue_bookings_booked_by_fkey" FOREIGN KEY (booked_by) REFERENCES auth.users(id) not valid;

alter table "public"."ct_venue_bookings" validate constraint "ct_venue_bookings_booked_by_fkey";

alter table "public"."ct_venue_bookings" add constraint "ct_venue_bookings_org_id_fkey" FOREIGN KEY (org_id) REFERENCES public.ct_organizations(id) ON DELETE CASCADE not valid;

alter table "public"."ct_venue_bookings" validate constraint "ct_venue_bookings_org_id_fkey";

alter table "public"."ct_venue_bookings" add constraint "ct_venue_bookings_time_range_check" CHECK ((end_time > start_time)) not valid;

alter table "public"."ct_venue_bookings" validate constraint "ct_venue_bookings_time_range_check";

alter table "public"."ct_venue_bookings" add constraint "ct_venue_bookings_venue_id_fkey" FOREIGN KEY (venue_id) REFERENCES public.ct_venues(id) ON DELETE CASCADE not valid;

alter table "public"."ct_venue_bookings" validate constraint "ct_venue_bookings_venue_id_fkey";

alter table "public"."ct_venues" add constraint "ct_venues_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_venues" validate constraint "ct_venues_created_by_fkey";

alter table "public"."ct_venues" add constraint "ct_venues_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) ON DELETE CASCADE not valid;

alter table "public"."ct_venues" validate constraint "ct_venues_institution_id_fkey";

alter table "public"."ct_venues" add constraint "ct_venues_org_id_fkey" FOREIGN KEY (org_id) REFERENCES public.ct_organizations(id) ON DELETE CASCADE not valid;

alter table "public"."ct_venues" validate constraint "ct_venues_org_id_fkey";

alter table "public"."ct_wellbeing_checkins" add constraint "ct_wellbeing_checkins_energy_check" CHECK (((energy >= 1) AND (energy <= 5))) not valid;

alter table "public"."ct_wellbeing_checkins" validate constraint "ct_wellbeing_checkins_energy_check";

alter table "public"."ct_wellbeing_checkins" add constraint "ct_wellbeing_checkins_institution_id_fkey" FOREIGN KEY (institution_id) REFERENCES public.ct_institutions(id) not valid;

alter table "public"."ct_wellbeing_checkins" validate constraint "ct_wellbeing_checkins_institution_id_fkey";

alter table "public"."ct_wellbeing_checkins" add constraint "ct_wellbeing_checkins_mood_check" CHECK (((mood >= 1) AND (mood <= 5))) not valid;

alter table "public"."ct_wellbeing_checkins" validate constraint "ct_wellbeing_checkins_mood_check";

alter table "public"."ct_wellbeing_checkins" add constraint "ct_wellbeing_checkins_stress_check" CHECK (((stress >= 1) AND (stress <= 5))) not valid;

alter table "public"."ct_wellbeing_checkins" validate constraint "ct_wellbeing_checkins_stress_check";

alter table "public"."ct_wellbeing_checkins" add constraint "ct_wellbeing_checkins_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.ct_students(id) ON DELETE CASCADE not valid;

alter table "public"."ct_wellbeing_checkins" validate constraint "ct_wellbeing_checkins_student_id_fkey";

alter table "public"."ct_wellbeing_checkins" add constraint "ct_wellbeing_checkins_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_wellbeing_checkins" validate constraint "ct_wellbeing_checkins_user_id_fkey";

alter table "public"."ct_wellbeing_checks" add constraint "ct_wellbeing_checks_energy_check" CHECK (((energy >= 1) AND (energy <= 5))) not valid;

alter table "public"."ct_wellbeing_checks" validate constraint "ct_wellbeing_checks_energy_check";

alter table "public"."ct_wellbeing_checks" add constraint "ct_wellbeing_checks_mood_check" CHECK (((mood >= 1) AND (mood <= 5))) not valid;

alter table "public"."ct_wellbeing_checks" validate constraint "ct_wellbeing_checks_mood_check";

alter table "public"."ct_wellbeing_checks" add constraint "ct_wellbeing_checks_stress_check" CHECK (((stress >= 1) AND (stress <= 5))) not valid;

alter table "public"."ct_wellbeing_checks" validate constraint "ct_wellbeing_checks_stress_check";

alter table "public"."ct_wellbeing_checks" add constraint "ct_wellbeing_checks_user_id_date_key" UNIQUE using index "ct_wellbeing_checks_user_id_date_key";

alter table "public"."ct_wellbeing_checks" add constraint "ct_wellbeing_checks_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.ct_users(id) not valid;

alter table "public"."ct_wellbeing_checks" validate constraint "ct_wellbeing_checks_user_id_fkey";

alter table "public"."ct_wellness_checkins" add constraint "ct_wellness_checkins_mood_check" CHECK (((mood >= 1) AND (mood <= 5))) not valid;

alter table "public"."ct_wellness_checkins" validate constraint "ct_wellness_checkins_mood_check";

alter table "public"."ct_wellness_checkins" add constraint "ct_wellness_checkins_user_date_unique" UNIQUE using index "ct_wellness_checkins_user_date_unique";

alter table "public"."demo_requests" add constraint "demo_requests_platform_check" CHECK ((platform = ANY (ARRAY['campus-tribe'::text, 'care-circle'::text]))) not valid;

alter table "public"."demo_requests" validate constraint "demo_requests_platform_check";

alter table "public"."event_news_comments" add constraint "event_news_comments_body_len" CHECK (((char_length(body) >= 1) AND (char_length(body) <= 500))) not valid;

alter table "public"."event_news_comments" validate constraint "event_news_comments_body_len";

alter table "public"."event_news_comments" add constraint "event_news_comments_post_id_fkey" FOREIGN KEY (post_id) REFERENCES public.event_news_posts(id) ON DELETE CASCADE not valid;

alter table "public"."event_news_comments" validate constraint "event_news_comments_post_id_fkey";

alter table "public"."event_news_comments" add constraint "event_news_comments_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."event_news_comments" validate constraint "event_news_comments_profile_id_fkey";

alter table "public"."event_news_likes" add constraint "event_news_likes_post_id_fkey" FOREIGN KEY (post_id) REFERENCES public.event_news_posts(id) ON DELETE CASCADE not valid;

alter table "public"."event_news_likes" validate constraint "event_news_likes_post_id_fkey";

alter table "public"."event_news_likes" add constraint "event_news_likes_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."event_news_likes" validate constraint "event_news_likes_profile_id_fkey";

alter table "public"."event_news_posts" add constraint "event_news_posts_author_profile_id_fkey" FOREIGN KEY (author_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."event_news_posts" validate constraint "event_news_posts_author_profile_id_fkey";

alter table "public"."event_news_posts" add constraint "event_news_posts_media_is_array" CHECK ((jsonb_typeof(media) = 'array'::text)) not valid;

alter table "public"."event_news_posts" validate constraint "event_news_posts_media_is_array";

alter table "public"."event_news_posts" add constraint "event_news_posts_media_max2" CHECK ((jsonb_array_length(media) <= 2)) not valid;

alter table "public"."event_news_posts" validate constraint "event_news_posts_media_max2";

alter table "public"."event_registrations" add constraint "event_registrations_event_id_fkey" FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE not valid;

alter table "public"."event_registrations" validate constraint "event_registrations_event_id_fkey";

alter table "public"."event_registrations" add constraint "event_registrations_event_id_user_id_key" UNIQUE using index "event_registrations_event_id_user_id_key";

alter table "public"."event_registrations" add constraint "event_registrations_payment_status_check" CHECK ((payment_status = ANY (ARRAY['unpaid'::text, 'paid'::text, 'refunded'::text, 'waived'::text]))) not valid;

alter table "public"."event_registrations" validate constraint "event_registrations_payment_status_check";

alter table "public"."event_registrations" add constraint "event_registrations_status_check" CHECK ((status = ANY (ARRAY['registered'::text, 'waitlisted'::text, 'attended'::text, 'cancelled'::text, 'no_show'::text]))) not valid;

alter table "public"."event_registrations" validate constraint "event_registrations_status_check";

alter table "public"."event_registrations" add constraint "event_registrations_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."event_registrations" validate constraint "event_registrations_user_id_fkey";

alter table "public"."events" add constraint "events_organizer_id_fkey" FOREIGN KEY (organizer_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."events" validate constraint "events_organizer_id_fkey";

alter table "public"."events_v2" add constraint "events_v2_host_user_id_fkey" FOREIGN KEY (host_user_id) REFERENCES public.users_v2(id) ON DELETE CASCADE not valid;

alter table "public"."events_v2" validate constraint "events_v2_host_user_id_fkey";

alter table "public"."group_conversation_members" add constraint "group_conversation_members_added_by_fkey" FOREIGN KEY (added_by) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."group_conversation_members" validate constraint "group_conversation_members_added_by_fkey";

alter table "public"."group_conversation_members" add constraint "group_conversation_members_group_conversation_id_fkey" FOREIGN KEY (group_conversation_id) REFERENCES public.group_conversations(id) ON DELETE CASCADE not valid;

alter table "public"."group_conversation_members" validate constraint "group_conversation_members_group_conversation_id_fkey";

alter table "public"."group_conversation_members" add constraint "group_conversation_members_group_conversation_id_profile_id_key" UNIQUE using index "group_conversation_members_group_conversation_id_profile_id_key";

alter table "public"."group_conversation_members" add constraint "group_conversation_members_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."group_conversation_members" validate constraint "group_conversation_members_profile_id_fkey";

alter table "public"."group_conversations" add constraint "group_conversations_activity_id_fkey" FOREIGN KEY (activity_id) REFERENCES public.companion_activities(id) ON DELETE SET NULL not valid;

alter table "public"."group_conversations" validate constraint "group_conversations_activity_id_fkey";

alter table "public"."group_conversations" add constraint "group_conversations_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE SET NULL not valid;

alter table "public"."group_conversations" validate constraint "group_conversations_booking_id_fkey";

alter table "public"."group_conversations" add constraint "group_conversations_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."group_conversations" validate constraint "group_conversations_created_by_fkey";

alter table "public"."group_messages" add constraint "group_messages_group_conversation_id_fkey" FOREIGN KEY (group_conversation_id) REFERENCES public.group_conversations(id) ON DELETE CASCADE not valid;

alter table "public"."group_messages" validate constraint "group_messages_group_conversation_id_fkey";

alter table "public"."group_messages" add constraint "group_messages_sender_id_fkey" FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."group_messages" validate constraint "group_messages_sender_id_fkey";

alter table "public"."interests" add constraint "interests_name_key" UNIQUE using index "interests_name_key";

alter table "public"."media_comments" add constraint "media_comments_commented_by_user_id_fkey" FOREIGN KEY (commented_by_user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."media_comments" validate constraint "media_comments_commented_by_user_id_fkey";

alter table "public"."media_comments" add constraint "media_comments_media_id_fkey" FOREIGN KEY (media_id) REFERENCES public.profile_media(id) ON DELETE CASCADE not valid;

alter table "public"."media_comments" validate constraint "media_comments_media_id_fkey";

alter table "public"."media_likes" add constraint "media_likes_liked_by_user_id_fkey" FOREIGN KEY (liked_by_user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."media_likes" validate constraint "media_likes_liked_by_user_id_fkey";

alter table "public"."media_likes" add constraint "media_likes_media_id_fkey" FOREIGN KEY (media_id) REFERENCES public.profile_media(id) ON DELETE CASCADE not valid;

alter table "public"."media_likes" validate constraint "media_likes_media_id_fkey";

alter table "public"."media_likes" add constraint "media_likes_media_id_liked_by_user_id_key" UNIQUE using index "media_likes_media_id_liked_by_user_id_key";

alter table "public"."media_uploads" add constraint "media_uploads_media_id_fkey" FOREIGN KEY (media_id) REFERENCES public.profile_media(id) ON DELETE CASCADE not valid;

alter table "public"."media_uploads" validate constraint "media_uploads_media_id_fkey";

alter table "public"."media_uploads" add constraint "media_uploads_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."media_uploads" validate constraint "media_uploads_user_id_fkey";

alter table "public"."messages" add constraint "messages_sender_id_fkey" FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."messages" validate constraint "messages_sender_id_fkey";

alter table "public"."payment_methods" add constraint "payment_methods_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."payment_methods" validate constraint "payment_methods_user_id_fkey";

alter table "public"."profile_likes" add constraint "profile_likes_liked_by_user_id_fkey" FOREIGN KEY (liked_by_user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."profile_likes" validate constraint "profile_likes_liked_by_user_id_fkey";

alter table "public"."profile_likes" add constraint "profile_likes_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."profile_likes" validate constraint "profile_likes_profile_id_fkey";

alter table "public"."profile_likes" add constraint "profile_likes_profile_id_liked_by_user_id_key" UNIQUE using index "profile_likes_profile_id_liked_by_user_id_key";

alter table "public"."profile_media" add constraint "profile_media_media_type_check" CHECK (((media_type)::text = ANY (ARRAY[('image'::character varying)::text, ('video'::character varying)::text]))) not valid;

alter table "public"."profile_media" validate constraint "profile_media_media_type_check";

alter table "public"."profile_media" add constraint "profile_media_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."profile_media" validate constraint "profile_media_user_id_fkey";

alter table "public"."profiles" add constraint "profiles_account_status_check" CHECK ((account_status = ANY (ARRAY['active'::text, 'paused'::text, 'deleted'::text, 'suspended'::text]))) not valid;

alter table "public"."profiles" validate constraint "profiles_account_status_check";

alter table "public"."profiles" add constraint "profiles_auth_id_key" UNIQUE using index "profiles_auth_id_key";

alter table "public"."profiles" add constraint "profiles_preferred_language_check" CHECK ((preferred_language = ANY (ARRAY['en'::text, 'es'::text, 'fr'::text]))) not valid;

alter table "public"."profiles" validate constraint "profiles_preferred_language_check";

alter table "public"."profiles" add constraint "profiles_role_check" CHECK ((role = ANY (ARRAY['user'::text, 'companion'::text, 'provider'::text, 'host'::text, 'admin'::text]))) not valid;

alter table "public"."profiles" validate constraint "profiles_role_check";

alter table "public"."profiles" add constraint "profiles_userId_unique" UNIQUE using index "profiles_userId_unique";

alter table "public"."profiles" add constraint "profiles_username_check" CHECK (((username)::text <> ''::text)) not valid;

alter table "public"."profiles" validate constraint "profiles_username_check";

alter table "public"."profiles" add constraint "profiles_username_key" UNIQUE using index "profiles_username_key";

alter table "public"."push_tokens" add constraint "push_tokens_profile_id_token_key" UNIQUE using index "push_tokens_profile_id_token_key";

alter table "public"."review_notification_outbox" add constraint "review_notification_outbox_event_type_check" CHECK ((event_type = ANY (ARRAY['review_prompt'::text, 'review_response_posted'::text]))) not valid;

alter table "public"."review_notification_outbox" validate constraint "review_notification_outbox_event_type_check";

alter table "public"."reviews" add constraint "reviews_entity_type_check" CHECK ((entity_type = ANY (ARRAY['companion'::text, 'service_provider'::text, 'event'::text, 'service'::text]))) not valid;

alter table "public"."reviews" validate constraint "reviews_entity_type_check";

alter table "public"."reviews" add constraint "reviews_moderation_status_check" CHECK ((moderation_status = ANY (ARRAY['pending'::text, 'approved'::text, 'flagged'::text, 'removed'::text]))) not valid;

alter table "public"."reviews" validate constraint "reviews_moderation_status_check";

alter table "public"."reviews_v2" add constraint "reviews_v2_booking_id_key" UNIQUE using index "reviews_v2_booking_id_key";

alter table "public"."reviews_v2" add constraint "reviews_v2_reviewer_id_fkey" FOREIGN KEY (reviewer_id) REFERENCES public.users_v2(id) ON DELETE CASCADE not valid;

alter table "public"."reviews_v2" validate constraint "reviews_v2_reviewer_id_fkey";

alter table "public"."roles" add constraint "roles_name_unique" UNIQUE using index "roles_name_unique";

alter table "public"."seo_ai_rank_snapshots" add constraint "seo_ai_rank_snapshots_tracking_query_id_fkey" FOREIGN KEY (tracking_query_id) REFERENCES public.seo_ai_tracking_queries(id) ON DELETE CASCADE not valid;

alter table "public"."seo_ai_rank_snapshots" validate constraint "seo_ai_rank_snapshots_tracking_query_id_fkey";

alter table "public"."seo_ai_tracking_queries" add constraint "seo_ai_tracking_queries_provider_query_target_path_key" UNIQUE using index "seo_ai_tracking_queries_provider_query_target_path_key";

alter table "public"."service_availability" add constraint "service_availability_provider_id_fkey" FOREIGN KEY (provider_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."service_availability" validate constraint "service_availability_provider_id_fkey";

alter table "public"."service_availability" add constraint "service_availability_provider_id_slot_date_slot_time_key" UNIQUE using index "service_availability_provider_id_slot_date_slot_time_key";

alter table "public"."service_availability" add constraint "service_availability_service_id_fkey" FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE CASCADE not valid;

alter table "public"."service_availability" validate constraint "service_availability_service_id_fkey";

alter table "public"."service_bookings" add constraint "service_bookings_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."service_bookings" validate constraint "service_bookings_client_id_fkey";

alter table "public"."service_bookings" add constraint "service_bookings_payment_status_check" CHECK ((payment_status = ANY (ARRAY['unpaid'::text, 'paid'::text, 'refunded'::text, 'waived'::text]))) not valid;

alter table "public"."service_bookings" validate constraint "service_bookings_payment_status_check";

alter table "public"."service_bookings" add constraint "service_bookings_provider_id_fkey" FOREIGN KEY (provider_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."service_bookings" validate constraint "service_bookings_provider_id_fkey";

alter table "public"."service_bookings" add constraint "service_bookings_service_id_fkey" FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE SET NULL not valid;

alter table "public"."service_bookings" validate constraint "service_bookings_service_id_fkey";

alter table "public"."service_bookings" add constraint "service_bookings_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'in_progress'::text, 'completed'::text, 'cancelled'::text, 'declined'::text]))) not valid;

alter table "public"."service_bookings" validate constraint "service_bookings_status_check";

alter table "public"."service_providers_v2" add constraint "service_providers_v2_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."service_providers_v2" validate constraint "service_providers_v2_profile_id_fkey";

alter table "public"."service_providers_v2" add constraint "service_providers_v2_profile_id_key" UNIQUE using index "service_providers_v2_profile_id_key";

alter table "public"."service_reviews" add constraint "service_reviews_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES public.service_bookings(id) ON DELETE CASCADE not valid;

alter table "public"."service_reviews" validate constraint "service_reviews_booking_id_fkey";

alter table "public"."service_reviews" add constraint "service_reviews_booking_id_reviewer_id_key" UNIQUE using index "service_reviews_booking_id_reviewer_id_key";

alter table "public"."service_reviews" add constraint "service_reviews_rating_check" CHECK (((rating >= 1) AND (rating <= 5))) not valid;

alter table "public"."service_reviews" validate constraint "service_reviews_rating_check";

alter table "public"."service_reviews" add constraint "service_reviews_reviewer_id_fkey" FOREIGN KEY (reviewer_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."service_reviews" validate constraint "service_reviews_reviewer_id_fkey";

alter table "public"."service_reviews" add constraint "service_reviews_service_id_fkey" FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE CASCADE not valid;

alter table "public"."service_reviews" validate constraint "service_reviews_service_id_fkey";

alter table "public"."services" add constraint "services_provider_id_fkey" FOREIGN KEY (provider_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."services" validate constraint "services_provider_id_fkey";

alter table "public"."subscriptions" add constraint "subscriptions_profile_product_key" UNIQUE using index "subscriptions_profile_product_key";

alter table "public"."subscriptions" add constraint "subscriptions_tier_check" CHECK ((tier = ANY (ARRAY['free'::text, 'premium'::text]))) not valid;

alter table "public"."subscriptions" validate constraint "subscriptions_tier_check";

alter table "public"."transactions" add constraint "transactions_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'completed'::text, 'failed'::text, 'reversed'::text]))) not valid;

alter table "public"."transactions" validate constraint "transactions_status_check";

alter table "public"."transactions" add constraint "transactions_type_check" CHECK ((type = ANY (ARRAY['topup'::text, 'booking_payment'::text, 'booking_refund'::text, 'platform_fee'::text, 'payout'::text, 'tip'::text]))) not valid;

alter table "public"."transactions" validate constraint "transactions_type_check";

alter table "public"."transactions" add constraint "transactions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."transactions" validate constraint "transactions_user_id_fkey";

alter table "public"."transactions" add constraint "transactions_wallet_id_fkey" FOREIGN KEY (wallet_id) REFERENCES public.wallets(id) ON DELETE CASCADE not valid;

alter table "public"."transactions" validate constraint "transactions_wallet_id_fkey";

alter table "public"."transactions_v2" add constraint "transactions_v2_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users_v2(id) ON DELETE CASCADE not valid;

alter table "public"."transactions_v2" validate constraint "transactions_v2_user_id_fkey";

alter table "public"."transactions_v2" add constraint "transactions_v2_wallet_id_fkey" FOREIGN KEY (wallet_id) REFERENCES public.wallets_v2(id) ON DELETE CASCADE not valid;

alter table "public"."transactions_v2" validate constraint "transactions_v2_wallet_id_fkey";

alter table "public"."user_interests" add constraint "user_interests_interest_id_fkey" FOREIGN KEY (interest_id) REFERENCES public.interests(id) ON DELETE CASCADE not valid;

alter table "public"."user_interests" validate constraint "user_interests_interest_id_fkey";

alter table "public"."user_interests" add constraint "user_interests_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."user_interests" validate constraint "user_interests_user_id_fkey";

alter table "public"."user_interests" add constraint "user_interests_user_id_interest_id_key" UNIQUE using index "user_interests_user_id_interest_id_key";

alter table "public"."users" add constraint "users_openId_unique" UNIQUE using index "users_openId_unique";

alter table "public"."users_v2" add constraint "users_v2_email_key" UNIQUE using index "users_v2_email_key";

alter table "public"."users_v2" add constraint "users_v2_phone_key" UNIQUE using index "users_v2_phone_key";

alter table "public"."users_v2" add constraint "users_v2_supabase_auth_id_key" UNIQUE using index "users_v2_supabase_auth_id_key";

alter table "public"."users_v2" add constraint "users_v2_trust_score_check" CHECK (((trust_score >= 0) AND (trust_score <= 100))) not valid;

alter table "public"."users_v2" validate constraint "users_v2_trust_score_check";

alter table "public"."voice_studio_clones" add constraint "voice_studio_clones_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."voice_studio_clones" validate constraint "voice_studio_clones_profile_id_fkey";

alter table "public"."voice_studio_clones" add constraint "voice_studio_clones_status_check" CHECK ((status = ANY (ARRAY['processing'::text, 'ready'::text, 'failed'::text]))) not valid;

alter table "public"."voice_studio_clones" validate constraint "voice_studio_clones_status_check";

alter table "public"."voice_studio_jobs" add constraint "voice_studio_jobs_job_type_check" CHECK ((job_type = ANY (ARRAY['tts'::text, 'voice_clone'::text, 'synthesize_clone'::text]))) not valid;

alter table "public"."voice_studio_jobs" validate constraint "voice_studio_jobs_job_type_check";

alter table "public"."voice_studio_jobs" add constraint "voice_studio_jobs_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."voice_studio_jobs" validate constraint "voice_studio_jobs_profile_id_fkey";

alter table "public"."voice_studio_jobs" add constraint "voice_studio_jobs_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'processing'::text, 'completed'::text, 'failed'::text]))) not valid;

alter table "public"."voice_studio_jobs" validate constraint "voice_studio_jobs_status_check";

alter table "public"."voice_studio_usage" add constraint "voice_studio_usage_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."voice_studio_usage" validate constraint "voice_studio_usage_profile_id_fkey";

alter table "public"."voice_studio_usage" add constraint "voice_studio_usage_profile_id_month_year_key" UNIQUE using index "voice_studio_usage_profile_id_month_year_key";

alter table "public"."waitlist" add constraint "waitlist_age_check" CHECK (((age >= 13) AND (age <= 120))) not valid;

alter table "public"."waitlist" validate constraint "waitlist_age_check";

alter table "public"."waitlist" add constraint "waitlist_email_key" UNIQUE using index "waitlist_email_key";

alter table "public"."wallets" add constraint "wallets_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."wallets" validate constraint "wallets_user_id_fkey";

alter table "public"."wallets" add constraint "wallets_user_id_key" UNIQUE using index "wallets_user_id_key";

alter table "public"."wallets_v2" add constraint "wallets_v2_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users_v2(id) ON DELETE CASCADE not valid;

alter table "public"."wallets_v2" validate constraint "wallets_v2_user_id_fkey";

alter table "public"."wallets_v2" add constraint "wallets_v2_user_id_key" UNIQUE using index "wallets_v2_user_id_key";

alter table "public"."wc_ai_agents" add constraint "wc_ai_agents_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'paused'::text, 'draft'::text]))) not valid;

alter table "public"."wc_ai_agents" validate constraint "wc_ai_agents_status_check";

alter table "public"."wc_ai_cases" add constraint "wc_ai_cases_ai_employee_id_fkey" FOREIGN KEY (ai_employee_id) REFERENCES public.wc_ai_employees(id) ON DELETE CASCADE not valid;

alter table "public"."wc_ai_cases" validate constraint "wc_ai_cases_ai_employee_id_fkey";

alter table "public"."wc_ai_cases" add constraint "wc_ai_cases_owner_profile_id_fkey" FOREIGN KEY (owner_profile_id) REFERENCES public.profiles(id) not valid;

alter table "public"."wc_ai_cases" validate constraint "wc_ai_cases_owner_profile_id_fkey";

alter table "public"."wc_ai_cases" add constraint "wc_ai_cases_priority_check" CHECK ((priority = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'urgent'::text]))) not valid;

alter table "public"."wc_ai_cases" validate constraint "wc_ai_cases_priority_check";

alter table "public"."wc_ai_cases" add constraint "wc_ai_cases_status_check" CHECK ((status = ANY (ARRAY['open'::text, 'in_progress'::text, 'escalated'::text, 'resolved'::text, 'closed'::text]))) not valid;

alter table "public"."wc_ai_cases" validate constraint "wc_ai_cases_status_check";

alter table "public"."wc_ai_employees" add constraint "wc_ai_employees_role_check" CHECK ((role = ANY (ARRAY['support'::text, 'sales'::text, 'marketing'::text, 'reception'::text, 'custom'::text]))) not valid;

alter table "public"."wc_ai_employees" validate constraint "wc_ai_employees_role_check";

alter table "public"."wc_ai_staff" add constraint "wc_ai_staff_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'inactive'::text]))) not valid;

alter table "public"."wc_ai_staff" validate constraint "wc_ai_staff_status_check";

alter table "public"."wc_call_sessions" add constraint "wc_call_sessions_ai_agent_id_fkey" FOREIGN KEY (ai_agent_id) REFERENCES public.wc_ai_agents(id) not valid;

alter table "public"."wc_call_sessions" validate constraint "wc_call_sessions_ai_agent_id_fkey";

alter table "public"."wc_call_sessions" add constraint "wc_call_sessions_call_control_id_key" UNIQUE using index "wc_call_sessions_call_control_id_key";

alter table "public"."wc_call_sessions" add constraint "wc_call_sessions_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'completed'::text, 'transferred'::text, 'voicemail'::text]))) not valid;

alter table "public"."wc_call_sessions" validate constraint "wc_call_sessions_status_check";

alter table "public"."wc_calls" add constraint "wc_calls_callee_profile_id_fkey" FOREIGN KEY (callee_profile_id) REFERENCES public.profiles(id) not valid;

alter table "public"."wc_calls" validate constraint "wc_calls_callee_profile_id_fkey";

alter table "public"."wc_calls" add constraint "wc_calls_caller_profile_id_fkey" FOREIGN KEY (caller_profile_id) REFERENCES public.profiles(id) not valid;

alter table "public"."wc_calls" validate constraint "wc_calls_caller_profile_id_fkey";

alter table "public"."wc_calls" add constraint "wc_calls_room_id_fkey" FOREIGN KEY (room_id) REFERENCES public.wc_rooms(id) ON DELETE SET NULL not valid;

alter table "public"."wc_calls" validate constraint "wc_calls_room_id_fkey";

alter table "public"."wc_contacts" add constraint "wc_contacts_internal_profile_id_fkey" FOREIGN KEY (internal_profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."wc_contacts" validate constraint "wc_contacts_internal_profile_id_fkey";

alter table "public"."wc_contacts" add constraint "wc_contacts_owner_profile_id_fkey" FOREIGN KEY (owner_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."wc_contacts" validate constraint "wc_contacts_owner_profile_id_fkey";

alter table "public"."wc_entitlements" add constraint "wc_entitlements_tier_check" CHECK ((tier = ANY (ARRAY['free'::text, 'premium'::text, 'pro'::text, 'enterprise'::text]))) not valid;

alter table "public"."wc_entitlements" validate constraint "wc_entitlements_tier_check";

alter table "public"."wc_followup_tasks" add constraint "wc_followup_tasks_business_profile_id_fkey" FOREIGN KEY (business_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."wc_followup_tasks" validate constraint "wc_followup_tasks_business_profile_id_fkey";

alter table "public"."wc_messages" add constraint "wc_messages_phone_number_id_fkey" FOREIGN KEY (phone_number_id) REFERENCES public.wc_phone_numbers(id) not valid;

alter table "public"."wc_messages" validate constraint "wc_messages_phone_number_id_fkey";

alter table "public"."wc_number_requests" add constraint "wc_number_requests_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) not valid;

alter table "public"."wc_number_requests" validate constraint "wc_number_requests_profile_id_fkey";

alter table "public"."wc_org_settings" add constraint "wc_org_settings_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) not valid;

alter table "public"."wc_org_settings" validate constraint "wc_org_settings_profile_id_fkey";

alter table "public"."wc_org_users" add constraint "wc_org_users_business_profile_id_profile_id_key" UNIQUE using index "wc_org_users_business_profile_id_profile_id_key";

alter table "public"."wc_org_users" add constraint "wc_org_users_department_id_fkey" FOREIGN KEY (department_id) REFERENCES public.wc_departments(id) ON DELETE SET NULL not valid;

alter table "public"."wc_org_users" validate constraint "wc_org_users_department_id_fkey";

alter table "public"."wc_org_users" add constraint "wc_org_users_role_id_fkey" FOREIGN KEY (role_id) REFERENCES public.wc_roles(id) ON DELETE SET NULL not valid;

alter table "public"."wc_org_users" validate constraint "wc_org_users_role_id_fkey";

alter table "public"."wc_participants" add constraint "wc_participants_role_check" CHECK ((role = ANY (ARRAY['host'::text, 'participant'::text, 'observer'::text]))) not valid;

alter table "public"."wc_participants" validate constraint "wc_participants_role_check";

alter table "public"."wc_participants" add constraint "wc_participants_room_id_fkey" FOREIGN KEY (room_id) REFERENCES public.wc_rooms(id) ON DELETE CASCADE not valid;

alter table "public"."wc_participants" validate constraint "wc_participants_room_id_fkey";

alter table "public"."wc_participants" add constraint "wc_participants_room_id_profile_id_key" UNIQUE using index "wc_participants_room_id_profile_id_key";

alter table "public"."wc_queue" add constraint "wc_queue_department_id_fkey" FOREIGN KEY (department_id) REFERENCES public.wc_departments(id) not valid;

alter table "public"."wc_queue" validate constraint "wc_queue_department_id_fkey";

alter table "public"."wc_queue" add constraint "wc_queue_phone_number_id_fkey" FOREIGN KEY (phone_number_id) REFERENCES public.wc_phone_numbers(id) not valid;

alter table "public"."wc_queue" validate constraint "wc_queue_phone_number_id_fkey";

alter table "public"."wc_queue" add constraint "wc_queue_status_check" CHECK ((status = ANY (ARRAY['waiting'::text, 'connected'::text, 'abandoned'::text, 'declined'::text]))) not valid;

alter table "public"."wc_queue" validate constraint "wc_queue_status_check";

alter table "public"."wc_recordings" add constraint "wc_recordings_room_id_fkey" FOREIGN KEY (room_id) REFERENCES public.wc_rooms(id) ON DELETE SET NULL not valid;

alter table "public"."wc_recordings" validate constraint "wc_recordings_room_id_fkey";

alter table "public"."wc_rooms" add constraint "wc_rooms_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'ended'::text]))) not valid;

alter table "public"."wc_rooms" validate constraint "wc_rooms_status_check";

alter table "public"."wc_rooms" add constraint "wc_rooms_type_check" CHECK ((type = ANY (ARRAY['p2p'::text, 'group'::text, 'webinar'::text]))) not valid;

alter table "public"."wc_rooms" validate constraint "wc_rooms_type_check";

alter table "public"."wc_routing_edges" add constraint "wc_routing_edges_rule_id_fkey" FOREIGN KEY (rule_id) REFERENCES public.wc_routing_rules(id) ON DELETE CASCADE not valid;

alter table "public"."wc_routing_edges" validate constraint "wc_routing_edges_rule_id_fkey";

alter table "public"."wc_routing_edges" add constraint "wc_routing_edges_source_step_id_fkey" FOREIGN KEY (source_step_id) REFERENCES public.wc_routing_steps(id) ON DELETE CASCADE not valid;

alter table "public"."wc_routing_edges" validate constraint "wc_routing_edges_source_step_id_fkey";

alter table "public"."wc_routing_edges" add constraint "wc_routing_edges_target_step_id_fkey" FOREIGN KEY (target_step_id) REFERENCES public.wc_routing_steps(id) ON DELETE CASCADE not valid;

alter table "public"."wc_routing_edges" validate constraint "wc_routing_edges_target_step_id_fkey";

alter table "public"."wc_routing_rules" add constraint "wc_routing_rules_phone_number_id_fkey" FOREIGN KEY (phone_number_id) REFERENCES public.wc_phone_numbers(id) ON DELETE CASCADE not valid;

alter table "public"."wc_routing_rules" validate constraint "wc_routing_rules_phone_number_id_fkey";

alter table "public"."wc_routing_rules" add constraint "wc_routing_rules_target_department_id_fkey" FOREIGN KEY (target_department_id) REFERENCES public.wc_departments(id) ON DELETE SET NULL not valid;

alter table "public"."wc_routing_rules" validate constraint "wc_routing_rules_target_department_id_fkey";

alter table "public"."wc_routing_rules" add constraint "wc_routing_rules_target_user_id_fkey" FOREIGN KEY (target_user_id) REFERENCES public.wc_org_users(id) ON DELETE SET NULL not valid;

alter table "public"."wc_routing_rules" validate constraint "wc_routing_rules_target_user_id_fkey";

alter table "public"."wc_routing_steps" add constraint "wc_routing_steps_business_profile_id_fkey" FOREIGN KEY (business_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."wc_routing_steps" validate constraint "wc_routing_steps_business_profile_id_fkey";

alter table "public"."wc_routing_steps" add constraint "wc_routing_steps_rule_id_fkey" FOREIGN KEY (rule_id) REFERENCES public.wc_routing_rules(id) ON DELETE CASCADE not valid;

alter table "public"."wc_routing_steps" validate constraint "wc_routing_steps_rule_id_fkey";

alter table "public"."wc_signaling" add constraint "wc_signaling_call_id_fkey" FOREIGN KEY (call_id) REFERENCES public.wc_calls(id) ON DELETE CASCADE not valid;

alter table "public"."wc_signaling" validate constraint "wc_signaling_call_id_fkey";

alter table "public"."wc_transcripts" add constraint "wc_transcripts_recording_id_fkey" FOREIGN KEY (recording_id) REFERENCES public.wc_recordings(id) ON DELETE CASCADE not valid;

alter table "public"."wc_transcripts" validate constraint "wc_transcripts_recording_id_fkey";

alter table "public"."wc_whatsapp_configs" add constraint "wc_whatsapp_configs_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."wc_whatsapp_configs" validate constraint "wc_whatsapp_configs_profile_id_fkey";

alter table "public"."wc_whatsapp_messages" add constraint "wc_whatsapp_messages_direction_check" CHECK ((direction = ANY (ARRAY['inbound'::text, 'outbound'::text]))) not valid;

alter table "public"."wc_whatsapp_messages" validate constraint "wc_whatsapp_messages_direction_check";

alter table "public"."wc_whatsapp_messages" add constraint "wc_whatsapp_messages_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."wc_whatsapp_messages" validate constraint "wc_whatsapp_messages_profile_id_fkey";

alter table "public"."webrtc_signals" add constraint "webrtc_signals_sender_id_fkey" FOREIGN KEY (sender_id) REFERENCES public.profiles(id) not valid;

alter table "public"."webrtc_signals" validate constraint "webrtc_signals_sender_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public._jsonb_text_array_to_text_array(j jsonb)
 RETURNS text[]
 LANGUAGE sql
 IMMUTABLE
AS $function$
    SELECT COALESCE(
      ARRAY(
        SELECT jsonb_array_elements_text(
          CASE
            WHEN j IS NULL THEN '[]'::jsonb
            WHEN jsonb_typeof(j) = 'array' THEN j
            ELSE '[]'::jsonb
          END
        )
      ),
      ARRAY[]::text[]
    );
  $function$
;

CREATE OR REPLACE FUNCTION public.activity_booking_exists_for_me(activity_id_in bigint)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  IF activity_id_in IS NULL THEN
    RETURN false;
  END IF;

  RETURN EXISTS (
    SELECT 1
    FROM public.activity_bookings ab
    WHERE ab.activity_id = activity_id_in
      AND ab.user_id = public.current_profile_id()
      AND lower(COALESCE(ab.status, '')) NOT IN ('cancelled', 'canceled', 'denied', 'failed', 'refunded')
  );
END;
$function$
;

create or replace view "public"."activity_host_performance_90d" as  SELECT ca.created_by AS profile_id,
    count(DISTINCT
        CASE
            WHEN (((ab.status)::text = 'completed'::text) AND (ab.booking_date >= (now() - '90 days'::interval))) THEN ca.id
            ELSE NULL::bigint
        END) AS completed_activity_count_90d,
    count(DISTINCT
        CASE
            WHEN (((ab.status)::text = 'completed'::text) AND (ab.booking_date >= (now() - '90 days'::interval))) THEN ab.user_id
            ELSE NULL::bigint
        END) AS distinct_users_90d,
    COALESCE(avg(
        CASE
            WHEN (ar.created_at >= (now() - '90 days'::interval)) THEN ar.rating
            ELSE NULL::integer
        END), (0)::numeric) AS avg_rating_90d,
    count(
        CASE
            WHEN (ar.created_at >= (now() - '90 days'::interval)) THEN ar.id
            ELSE NULL::bigint
        END) AS review_count_90d
   FROM ((public.companion_activities ca
     LEFT JOIN public.activity_bookings ab ON ((ab.activity_id = ca.id)))
     LEFT JOIN public.activity_reviews ar ON ((ar.activity_id = ca.id)))
  GROUP BY ca.created_by;


create or replace view "public"."activity_stats" as  SELECT ca.id AS activity_id,
    ca.title,
    ca.created_by,
    count(DISTINCT ab.id) AS total_bookings,
    count(DISTINCT
        CASE
            WHEN ((ab.status)::text = 'completed'::text) THEN ab.id
            ELSE NULL::bigint
        END) AS completed_bookings,
    COALESCE(avg(ar.rating), (0)::numeric) AS average_rating,
    count(ar.id) AS review_count,
    sum(
        CASE
            WHEN ((ab.payment_status)::text = 'completed'::text) THEN ab.amount
            ELSE (0)::numeric
        END) AS total_revenue
   FROM ((public.companion_activities ca
     LEFT JOIN public.activity_bookings ab ON ((ca.id = ab.activity_id)))
     LEFT JOIN public.activity_reviews ar ON ((ca.id = ar.activity_id)))
  GROUP BY ca.id, ca.title, ca.created_by;


CREATE OR REPLACE FUNCTION public.admin_get_all_users()
 RETURNS TABLE(id uuid, email text, full_name text, role text, roles text[], institution_id uuid, institution_name text, payment_status text, is_active boolean, created_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  IF NOT is_superadmin() THEN
    RAISE EXCEPTION 'Superadmin access required';
  END IF;
  RETURN QUERY
    SELECT u.id, au.email::TEXT, u.full_name, u.role, u.roles,
           u.institution_id, i.name::TEXT as institution_name,
           u.payment_status::TEXT, u.is_active, u.created_at
    FROM ct_users u
    JOIN auth.users au ON au.id = u.id
    LEFT JOIN ct_institutions i ON i.id = u.institution_id
    ORDER BY u.created_at DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.approve_free_trial(req_id uuid, reviewer uuid, months integer DEFAULT 3)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE req RECORD;
BEGIN
  IF NOT is_superadmin() THEN RAISE EXCEPTION 'Superadmin only'; END IF;
  SELECT * INTO req FROM ct_free_trial_requests WHERE id=req_id;
  UPDATE ct_users SET
    payment_status='paid',
    trial_status='active',
    trial_expires_at=NOW() + (months || ' months')::INTERVAL,
    trial_ends_at=NOW() + (months || ' months')::INTERVAL
  WHERE id=req.user_id;
  UPDATE ct_free_trial_requests SET
    status='approved', reviewed_by=reviewer, reviewed_at=NOW(),
    trial_months=months, trial_start=NOW(), trial_end=NOW()+(months||' months')::INTERVAL
  WHERE id=req_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.approve_institution_request(req_id uuid, reviewer uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE req RECORD;
  new_inst_id UUID;
BEGIN
  IF NOT is_superadmin() THEN RAISE EXCEPTION 'Superadmin only'; END IF;
  SELECT * INTO req FROM ct_institution_requests WHERE id=req_id;
  IF req.request_type IN ('join_existing','change_institution') THEN
    UPDATE ct_users SET institution_id=req.institution_id WHERE id=req.user_id;
    new_inst_id := req.institution_id;
  ELSIF req.request_type='create_new' THEN
    INSERT INTO ct_institutions(name, institution_type, country)
    VALUES(req.requested_name, COALESCE(req.requested_type,'university'), 'Canada')
    RETURNING id INTO new_inst_id;
    UPDATE ct_users SET institution_id=new_inst_id WHERE id=req.user_id;
  END IF;
  UPDATE ct_institution_requests SET status='approved', reviewed_by=reviewer, reviewed_at=NOW() WHERE id=req_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.audit_booking_review_changes()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  actor bigint;
BEGIN
  actor := NULLIF(public.current_profile_id(), 0);

  IF TG_TABLE_NAME = 'booking_reviews' THEN
    IF TG_OP = 'INSERT' THEN
      INSERT INTO public.booking_review_audit_log(entity_type, entity_id, action, actor_profile_id, new_row)
      VALUES ('review', NEW.id, 'insert', actor, to_jsonb(NEW));
      RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
      INSERT INTO public.booking_review_audit_log(entity_type, entity_id, action, actor_profile_id, old_row, new_row)
      VALUES ('review', NEW.id, 'update', actor, to_jsonb(OLD), to_jsonb(NEW));
      RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
      INSERT INTO public.booking_review_audit_log(entity_type, entity_id, action, actor_profile_id, old_row)
      VALUES ('review', OLD.id, 'delete', actor, to_jsonb(OLD));
      RETURN OLD;
    END IF;
  ELSIF TG_TABLE_NAME = 'booking_review_media' THEN
    IF TG_OP = 'INSERT' THEN
      INSERT INTO public.booking_review_audit_log(entity_type, entity_id, action, actor_profile_id, new_row)
      VALUES ('media', NEW.id, 'insert', actor, to_jsonb(NEW));
      RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
      INSERT INTO public.booking_review_audit_log(entity_type, entity_id, action, actor_profile_id, old_row, new_row)
      VALUES ('media', NEW.id, 'update', actor, to_jsonb(OLD), to_jsonb(NEW));
      RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
      INSERT INTO public.booking_review_audit_log(entity_type, entity_id, action, actor_profile_id, old_row)
      VALUES ('media', OLD.id, 'delete', actor, to_jsonb(OLD));
      RETURN OLD;
    END IF;
  ELSIF TG_TABLE_NAME = 'booking_review_responses' THEN
    IF TG_OP = 'INSERT' THEN
      INSERT INTO public.booking_review_audit_log(entity_type, entity_id, action, actor_profile_id, new_row)
      VALUES ('response', NEW.id, 'insert', actor, to_jsonb(NEW));
      RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
      INSERT INTO public.booking_review_audit_log(entity_type, entity_id, action, actor_profile_id, old_row, new_row)
      VALUES ('response', NEW.id, 'update', actor, to_jsonb(OLD), to_jsonb(NEW));
      RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
      INSERT INTO public.booking_review_audit_log(entity_type, entity_id, action, actor_profile_id, old_row)
      VALUES ('response', OLD.id, 'delete', actor, to_jsonb(OLD));
      RETURN OLD;
    END IF;
  END IF;

  RETURN COALESCE(NEW, OLD);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.auth_user_facility_id()
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT facility_id FROM cc_org_users
  WHERE user_id = auth.uid()::text
  LIMIT 1;
$function$
;

CREATE OR REPLACE FUNCTION public.auth_user_org_id()
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT org_id FROM ct_org_users
  WHERE user_id = auth.uid()::text
  LIMIT 1;
$function$
;

CREATE OR REPLACE FUNCTION public.backup_profile_before_delete()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  INSERT INTO public.profile_delete_backups (
    profile_id,
    auth_id,
    full_name,
    display_name,
    username,
    email,
    profile_photo_url,
    cover_photo_url,
    account_status,
    raw_row
  ) VALUES (
    OLD.id,
    OLD.auth_id,
    OLD.full_name,
    OLD.display_name,
    OLD.username,
    OLD.email,
    OLD.profile_photo_url,
    OLD.cover_photo_url,
    OLD.account_status,
    to_jsonb(OLD)
  );
  RETURN OLD;
END;
$function$
;

create or replace view "public"."booking_reviews_moderation_queue" as  SELECT r.id,
    r.booking_id,
    r.reviewer_profile_id,
    r.reviewee_profile_id,
    r.rating,
    r.body,
    r.status,
    r.submitted_at,
    r.revealed_at,
    r.moderation_status,
    r.moderation_reasons,
    r.moderated_at,
    COALESCE(pr.display_name, pr.full_name, (pr.username)::text, pr.email, 'Reviewer'::text) AS reviewer_name,
    COALESCE(pe.display_name, pe.full_name, (pe.username)::text, pe.email, 'Reviewee'::text) AS reviewee_name
   FROM ((public.booking_reviews r
     JOIN public.profiles pr ON ((pr.id = r.reviewer_profile_id)))
     JOIN public.profiles pe ON ((pe.id = r.reviewee_profile_id)))
  WHERE ((r.status = ANY (ARRAY['submitted'::text, 'revealed'::text])) AND (r.moderation_status = ANY (ARRAY['pending'::text, 'flagged'::text])));


create or replace view "public"."booking_reviews_public" as  SELECT r.id,
    r.booking_id,
    r.reviewer_profile_id,
    r.reviewee_profile_id,
    r.rating,
    r.body,
    r.created_at,
    r.revealed_at,
    r.counts_toward_rating,
    COALESCE(pr.display_name, pr.full_name, (pr.username)::text, pr.email, 'User'::text) AS reviewer_name,
    COALESCE(pr.profile_photo_url, pr.avatar_url) AS reviewer_avatar,
    ( SELECT count(*) AS count
           FROM public.booking_review_helpful_votes hv
          WHERE (hv.review_id = r.id)) AS helpful_count,
    resp.body AS response_body,
    resp.created_at AS response_created_at
   FROM ((public.booking_reviews r
     JOIN public.profiles pr ON ((pr.id = r.reviewer_profile_id)))
     LEFT JOIN public.booking_review_responses resp ON ((resp.review_id = r.id)))
  WHERE ((r.status = 'revealed'::text) AND (r.moderation_status = ANY (ARRAY['approved'::text, 'pending'::text])));


CREATE OR REPLACE FUNCTION public.can_manage_review_media_object(object_name text, object_owner uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  review_id_text text;
  rid uuid;
  reviewer bigint;
  booking text;
  reviewee bigint;
  ok boolean;
BEGIN
  IF object_owner IS NULL OR object_owner <> auth.uid() THEN
    RETURN false;
  END IF;

  review_id_text := NULLIF(split_part(object_name, '/', 2), '');
  IF review_id_text IS NULL THEN
    RETURN false;
  END IF;

  rid := review_id_text::uuid;

  SELECT br.booking_id, br.reviewer_profile_id, br.reviewee_profile_id
  INTO booking, reviewer, reviewee
  FROM public.booking_reviews br
  WHERE br.id = rid
    AND br.status = 'draft'
  LIMIT 1;

  IF booking IS NULL OR reviewer IS NULL THEN
    RETURN false;
  END IF;

  IF reviewer <> public.current_profile_id() THEN
    RETURN false;
  END IF;

  ok := public.can_review_booking(booking, reviewer, reviewee);
  RETURN COALESCE(ok, false);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.can_message_between_profiles(a bigint, b bigint)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  p1 bigint;
  p2 bigint;
  has_snake boolean;
  has_camel boolean;
  ok boolean;
BEGIN
  p1 := LEAST(a, b);
  p2 := GREATEST(a, b);

  IF p1 IS NULL OR p2 IS NULL OR p1 = p2 THEN
    RETURN false;
  END IF;

  -- Session bookings (try snake_case first)
  SELECT EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='bookings' AND column_name IN ('client_id','companion_id')
  ) INTO has_snake;

  IF has_snake THEN
    SELECT EXISTS(
      SELECT 1
      FROM public.bookings b
      WHERE lower(COALESCE(b.status,'')) NOT IN ('denied','cancelled','canceled')
        AND (
          (b.client_id = p1 AND b.companion_id = p2)
          OR (b.client_id = p2 AND b.companion_id = p1)
          OR (COALESCE(b.bouncer_id, -1) IN (p1,p2) AND b.client_id IN (p1,p2) AND b.companion_id IN (p1,p2))
        )
      LIMIT 1
    ) INTO ok;

    IF ok THEN
      RETURN true;
    END IF;
  END IF;

  -- Session bookings (legacy camelCase)
  SELECT EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='bookings' AND column_name IN ('clientId','companionId')
  ) INTO has_camel;

  IF has_camel THEN
    EXECUTE $q$
      SELECT EXISTS(
        SELECT 1
        FROM public.bookings b
        WHERE lower(COALESCE(b.status::text,'')) NOT IN ('denied','cancelled','canceled')
          AND (
            (b."clientId" = $1 AND b."companionId" = $2)
            OR (b."clientId" = $2 AND b."companionId" = $1)
            OR (COALESCE(b."bouncerId", -1) IN ($1,$2) AND b."clientId" IN ($1,$2) AND b."companionId" IN ($1,$2))
          )
        LIMIT 1
      )
    $q$ INTO ok USING p1, p2;

    IF ok THEN
      RETURN true;
    END IF;
  END IF;

  -- Activity bookings (guest <-> host)
  SELECT EXISTS(
    SELECT 1
    FROM public.activity_bookings ab
    JOIN public.companion_activities ca ON ca.id = ab.activity_id
    WHERE lower(COALESCE(ab.status,'')) NOT IN ('cancelled','canceled','denied')
      AND (
        (ab.user_id = p1 AND ca.created_by = p2)
        OR (ab.user_id = p2 AND ca.created_by = p1)
      )
    LIMIT 1
  ) INTO ok;

  IF ok THEN
    RETURN true;
  END IF;

  RETURN false;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.can_review_activity_booking(_booking_id bigint, _reviewer_id bigint)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  b record;
  starts_at timestamptz;
BEGIN
  IF _booking_id IS NULL OR _reviewer_id IS NULL THEN
    RETURN false;
  END IF;

  SELECT id, user_id, booking_date, status, payment_status
  INTO b
  FROM public.activity_bookings
  WHERE id = _booking_id;

  IF b.id IS NULL THEN
    RETURN false;
  END IF;

  IF b.user_id <> _reviewer_id THEN
    RETURN false;
  END IF;

  IF lower(COALESCE(b.status,'')) IN ('cancelled','canceled','denied') THEN
    RETURN false;
  END IF;

  IF lower(COALESCE(b.payment_status,'')) IN ('refunded') THEN
    RETURN false;
  END IF;

  starts_at := b.booking_date;
  IF starts_at IS NULL THEN
    RETURN false;
  END IF;

  -- Must have started/finished (activities are point-in-time in this schema)
  IF now() < starts_at THEN
    RETURN false;
  END IF;

  -- Window: 10 days from start
  IF now() > (starts_at + interval '10 days') THEN
    RETURN false;
  END IF;

  RETURN true;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.can_review_booking(booking text, reviewer bigint, reviewee bigint)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  b jsonb;
  status_text text;
  client_id bigint;
  companion_id bigint;
  bouncer_id bigint;
  refund_amount numeric;
  starts_at timestamptz;
  ends_at timestamptz;
  completed_at timestamptz;
  duration_raw numeric;
  duration_hours numeric;
BEGIN
  IF booking IS NULL OR btrim(booking) = '' THEN
    RETURN false;
  END IF;

  IF reviewer IS NULL OR reviewee IS NULL THEN
    RETURN false;
  END IF;

  IF reviewer = reviewee THEN
    RETURN false;
  END IF;

  SELECT to_jsonb(bk) INTO b
  FROM public.bookings bk
  WHERE bk.id::text = booking
  LIMIT 1;

  IF b IS NULL THEN
    RETURN false;
  END IF;

  status_text := lower(COALESCE(b->>'status', ''));
  IF status_text IN ('denied','cancelled','canceled') THEN
    RETURN false;
  END IF;

  client_id := COALESCE(
    public.safe_to_numeric(b->>'client_id'),
    public.safe_to_numeric(b->>'clientId'),
    public.safe_to_numeric(b->>'clientID')
  )::bigint;

  companion_id := COALESCE(
    public.safe_to_numeric(b->>'companion_id'),
    public.safe_to_numeric(b->>'companionId'),
    public.safe_to_numeric(b->>'companionID')
  )::bigint;

  bouncer_id := COALESCE(
    public.safe_to_numeric(b->>'bouncer_id'),
    public.safe_to_numeric(b->>'bouncerId'),
    public.safe_to_numeric(b->>'bouncerID')
  )::bigint;

  IF NOT (reviewer IN (client_id, companion_id, COALESCE(bouncer_id, -1))) THEN
    RETURN false;
  END IF;
  IF NOT (reviewee IN (client_id, companion_id, COALESCE(bouncer_id, -1))) THEN
    RETURN false;
  END IF;

  refund_amount := COALESCE(
    public.safe_to_numeric(b->>'refund_amount'),
    public.safe_to_numeric(b->>'refundAmount'),
    0
  );

  IF refund_amount > 0 THEN
    RETURN false;
  END IF;

  completed_at := COALESCE(
    public.safe_to_timestamptz(b->>'completed_at'),
    public.safe_to_timestamptz(b->>'completedAt')
  );

  starts_at := COALESCE(
    public.safe_to_timestamptz(b->>'start_time'),
    public.safe_to_timestamptz(b->>'startTime'),
    public.safe_to_timestamptz((b->>'date') || 'T' || COALESCE(b->>'time','00:00')),
    public.safe_to_timestamptz(b->>'date')
  );

  duration_raw := COALESCE(
    public.safe_to_numeric(b->>'hours'),
    public.safe_to_numeric(b->>'duration'),
    public.safe_to_numeric(b->>'duration_hours'),
    public.safe_to_numeric(b->>'durationHours'),
    public.safe_to_numeric(b->>'duration_minutes'),
    public.safe_to_numeric(b->>'durationMinutes')
  );

  -- Heuristic: if duration looks like minutes (> 12), convert to hours
  IF duration_raw IS NULL THEN
    duration_hours := 1;
  ELSIF duration_raw > 12 THEN
    duration_hours := duration_raw / 60;
  ELSE
    duration_hours := duration_raw;
  END IF;

  ends_at := COALESCE(
    public.safe_to_timestamptz(b->>'end_time'),
    public.safe_to_timestamptz(b->>'endTime'),
    CASE WHEN starts_at IS NOT NULL THEN starts_at + (duration_hours * interval '1 hour') ELSE NULL END
  );

  IF starts_at IS NULL THEN
    RETURN false;
  END IF;

  completed_at := COALESCE(completed_at, ends_at);
  IF completed_at IS NULL THEN
    RETURN false;
  END IF;

  -- Must have ended
  IF now() < completed_at THEN
    RETURN false;
  END IF;

  -- Window: 10 days from completion
  IF now() > (completed_at + interval '10 days') THEN
    RETURN false;
  END IF;

  RETURN true;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_double_booking()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  conflicting_count INTEGER;
  start_dt TIMESTAMPTZ;
  end_dt TIMESTAMPTZ;
  duration_hours NUMERIC;
  companion_profile_id INTEGER;
BEGIN
  IF NEW.status = 'approved' THEN
    start_dt := COALESCE(NEW.start_time, NEW."startTime");
    duration_hours := COALESCE(NEW.hours, NEW.duration, NEW."durationHours", 1);

    IF start_dt IS NOT NULL THEN
      end_dt := COALESCE(
        NEW.end_time,
        NEW."endTime",
        start_dt + (duration_hours::text || ' hours')::INTERVAL
      );

      companion_profile_id := COALESCE(NEW.companion_id, NEW."providerId");

      IF companion_profile_id IS NOT NULL AND end_dt IS NOT NULL THEN
        SELECT COUNT(*) INTO conflicting_count
        FROM bookings
        WHERE id <> NEW.id
          AND status = 'approved'
          AND COALESCE(companion_id, "providerId") = companion_profile_id
          AND (COALESCE(start_time, "startTime"), COALESCE(end_time, "endTime", start_dt)) OVERLAPS (start_dt, end_dt);

        IF conflicting_count > 0 THEN
          RAISE EXCEPTION 'Double booking detected. This time slot is already booked.';
        END IF;
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_event_capacity()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  evt RECORD;
BEGIN
  SELECT max_attendees, current_attendees INTO evt FROM events WHERE id = NEW.event_id;
  IF evt.max_attendees IS NOT NULL AND evt.current_attendees >= evt.max_attendees THEN
    RAISE EXCEPTION 'Event is at full capacity';
  END IF;
  UPDATE events SET current_attendees = current_attendees + 1 WHERE id = NEW.event_id;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_notification(p_user_profile_id bigint, p_type text, p_title text, p_content text, p_related_booking_id bigint DEFAULT NULL::bigint, p_related_user_id bigint DEFAULT NULL::bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$ BEGIN INSERT INTO notifications ("userId", type, title, content, "relatedBookingId", "relatedUserId", "isRead", "createdAt") VALUES (p_user_profile_id, p_type, p_title, p_content, p_related_booking_id, p_related_user_id, false, NOW()); END; $function$
;

CREATE OR REPLACE FUNCTION public.create_wallet_for_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  INSERT INTO wallets (user_id) VALUES (NEW.id) ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.ct_log_venue_booking_history()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  history_action TEXT;
  history_actor UUID;
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO ct_venue_booking_history (
      booking_id,
      actor_id,
      action,
      from_status,
      to_status,
      note,
      metadata
    ) VALUES (
      NEW.id,
      NEW.booked_by,
      'submitted',
      NULL,
      NEW.status,
      NEW.notes,
      jsonb_build_object(
        'purpose', NEW.purpose,
        'start_time', NEW.start_time,
        'end_time', NEW.end_time,
        'venue_id', NEW.venue_id
      )
    );

    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    IF COALESCE(NEW.status, '') IS DISTINCT FROM COALESCE(OLD.status, '') THEN
      history_action := CASE
        WHEN NEW.approved_by IS NOT NULL THEN 'reviewed'
        ELSE 'status_changed'
      END;
      history_actor := COALESCE(NEW.approved_by, OLD.approved_by, NEW.booked_by, OLD.booked_by);

      INSERT INTO ct_venue_booking_history (
        booking_id,
        actor_id,
        action,
        from_status,
        to_status,
        note,
        metadata
      ) VALUES (
        NEW.id,
        history_actor,
        history_action,
        OLD.status,
        NEW.status,
        NEW.notes,
        jsonb_build_object(
          'purpose', NEW.purpose,
          'start_time', NEW.start_time,
          'end_time', NEW.end_time,
          'venue_id', NEW.venue_id,
          'approved_by', NEW.approved_by
        )
      );
    ELSIF COALESCE(NEW.notes, '') IS DISTINCT FROM COALESCE(OLD.notes, '') THEN
      history_actor := COALESCE(NEW.approved_by, OLD.approved_by, NEW.booked_by, OLD.booked_by);

      INSERT INTO ct_venue_booking_history (
        booking_id,
        actor_id,
        action,
        from_status,
        to_status,
        note,
        metadata
      ) VALUES (
        NEW.id,
        history_actor,
        'note_updated',
        OLD.status,
        NEW.status,
        NEW.notes,
        jsonb_build_object(
          'purpose', NEW.purpose,
          'start_time', NEW.start_time,
          'end_time', NEW.end_time,
          'venue_id', NEW.venue_id,
          'approved_by', NEW.approved_by
        )
      );
    END IF;

    RETURN NEW;
  END IF;

  RETURN NEW;
END;
$function$
;

create or replace view "public"."ct_platform_analytics" as  SELECT i.id AS institution_id,
    i.name AS institution_name,
    i.institution_type,
    i.subscription_status,
    count(DISTINCT u.id) AS total_users,
    count(DISTINCT u.id) FILTER (WHERE (u.role = 'student'::text)) AS students,
    count(DISTINCT u.id) FILTER (WHERE (u.role = ANY (ARRAY['teacher'::text, 'coach'::text, 'admin'::text, 'it_director'::text, 'staff'::text]))) AS paid_users,
    count(DISTINCT u.id) FILTER (WHERE (u.payment_status = 'paid'::text)) AS paid_seats,
    COALESCE(sum(bi.amount) FILTER (WHERE (bi.status = 'paid'::text)), (0)::numeric) AS total_revenue,
    max(bi.paid_at) AS last_payment_at,
    i.created_at AS institution_created_at
   FROM ((public.ct_institutions i
     LEFT JOIN public.ct_users u ON ((u.institution_id = i.id)))
     LEFT JOIN public.ct_billing_invoices bi ON ((bi.institution_id = i.id)))
  GROUP BY i.id, i.name, i.institution_type, i.subscription_status, i.created_at;


CREATE OR REPLACE FUNCTION public.ct_prevent_overlapping_approved_venue_bookings()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  conflicting_booking_id UUID;
BEGIN
  IF NEW.status = 'approved' THEN
    SELECT booking.id
      INTO conflicting_booking_id
    FROM ct_venue_bookings booking
    WHERE booking.id <> NEW.id
      AND booking.venue_id = NEW.venue_id
      AND booking.status = 'approved'
      AND booking.start_time < NEW.end_time
      AND booking.end_time > NEW.start_time
    LIMIT 1;

    IF conflicting_booking_id IS NOT NULL THEN
      RAISE EXCEPTION USING
        ERRCODE = '23514',
        MESSAGE = 'Approved venue booking overlaps an existing approved booking.',
        DETAIL = format('Conflicting booking id: %s', conflicting_booking_id),
        HINT = 'Adjust the booking time or reject/cancel the conflicting approved booking first.';
    END IF;
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.ct_sync_announcement_compat()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.institution_id IS NULL THEN NEW.institution_id := NEW.org_id; END IF;
  IF NEW.org_id IS NULL THEN NEW.org_id := NEW.institution_id; END IF;
  IF NEW.author_id IS NULL THEN NEW.author_id := NEW.created_by; END IF;
  IF NEW.created_by IS NULL THEN NEW.created_by := NEW.author_id; END IF;
  IF NEW.target_roles IS NULL THEN NEW.target_roles := ARRAY[]::text[]; END IF;
  NEW.updated_at := now();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.ct_sync_event_rsvp_compat()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.user_id IS NULL THEN NEW.user_id := NEW.student_id; END IF;
  IF NEW.student_id IS NULL THEN NEW.student_id := NEW.user_id; END IF;
  NEW.updated_at := now();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.ct_sync_survey_compat()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.institution_id IS NULL THEN NEW.institution_id := NEW.org_id; END IF;
  IF NEW.org_id IS NULL THEN NEW.org_id := NEW.institution_id; END IF;
  IF NEW.target_roles IS NULL THEN
    NEW.target_roles := CASE
      WHEN NEW.target_audience IS NOT NULL AND btrim(NEW.target_audience) <> '' THEN ARRAY[NEW.target_audience]
      ELSE ARRAY[]::text[]
    END;
  END IF;
  IF NEW.is_active IS NULL THEN NEW.is_active := (NEW.status = 'published'); END IF;
  IF NEW.is_anonymous IS NULL THEN NEW.is_anonymous := COALESCE(NEW.anonymous, false); END IF;
  IF NEW.anonymous IS NULL THEN NEW.anonymous := COALESCE(NEW.is_anonymous, false); END IF;
  NEW.updated_at := now();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.ct_sync_survey_question_compat()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.prompt IS NULL THEN NEW.prompt := NEW.question_text; END IF;
  IF NEW.question_text IS NULL THEN NEW.question_text := NEW.prompt; END IF;
  IF NEW.position IS NULL THEN NEW.position := NEW.order_index; END IF;
  IF NEW.order_index IS NULL THEN NEW.order_index := NEW.position; END IF;
  IF NEW.options IS NULL THEN NEW.options := '[]'::jsonb; END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.ct_sync_survey_response_compat()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  survey_org_id uuid;
BEGIN
  IF NEW.user_id IS NULL THEN NEW.user_id := NEW.student_id; END IF;
  IF NEW.student_id IS NULL THEN NEW.student_id := NEW.user_id; END IF;
  IF NEW.answers IS NULL THEN NEW.answers := '{}'::jsonb; END IF;
  IF NEW.submitted_at IS NULL THEN NEW.submitted_at := now(); END IF;
  IF NEW.created_at IS NULL THEN NEW.created_at := now(); END IF;
  NEW.updated_at := now();

  IF NEW.org_id IS NULL THEN
    SELECT org_id INTO survey_org_id FROM ct_surveys WHERE id = NEW.survey_id;
    NEW.org_id := survey_org_id;
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.current_profile_id()
 RETURNS bigint
 LANGUAGE sql
 STABLE
AS $function$
  SELECT id::bigint FROM public.profiles WHERE auth_id = auth.uid()::text LIMIT 1;
$function$
;

CREATE OR REPLACE FUNCTION public.enforce_activity_capacity()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  max_allowed INTEGER;
  already_booked INTEGER;
BEGIN
  IF NEW.booking_date IS NULL THEN
    RAISE EXCEPTION 'booking_date is required for activity bookings';
  END IF;

  SELECT max_participants
  INTO max_allowed
  FROM companion_activities
  WHERE id = NEW.activity_id;

  IF max_allowed IS NULL THEN
    RAISE EXCEPTION 'Activity not found for booking';
  END IF;

  SELECT COALESCE(SUM(COALESCE(booked_slots, 1)), 0)
  INTO already_booked
  FROM activity_bookings ab
  WHERE ab.activity_id = NEW.activity_id
    AND ab.booking_date = NEW.booking_date
    AND ab.status NOT IN ('cancelled', 'completed')
    AND (TG_OP = 'INSERT' OR ab.id <> NEW.id);

  IF already_booked + COALESCE(NEW.booked_slots, 1) > max_allowed THEN
    RAISE EXCEPTION 'No slots available for this activity time';
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.enforce_booking_review_transitions()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF TG_OP <> 'UPDATE' THEN
    RETURN NEW;
  END IF;

  -- Lock any edits after leaving draft
  IF OLD.status <> 'draft' THEN
    IF NEW.status <> OLD.status THEN
      RAISE EXCEPTION 'Review cannot change status after submission';
    END IF;
    RETURN NEW;
  END IF;

  -- From draft: allow draft updates and submit; allow reveal only if trigger has set timestamps
  IF NEW.status = 'revealed' THEN
    IF NEW.submitted_at IS NULL OR NEW.revealed_at IS NULL THEN
      RAISE EXCEPTION 'Invalid reveal transition';
    END IF;
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.enforce_no_profanity_on_activity_reviews()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF public.text_contains_profanity(COALESCE(NEW.review, '')) THEN
    RAISE EXCEPTION 'Profanity is not allowed.';
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.enforce_no_profanity_on_event_news()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF public.text_contains_profanity(COALESCE(NEW.caption, '')) THEN
    RAISE EXCEPTION 'Profanity is not allowed.';
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.enforce_no_profanity_on_messages()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF public.text_contains_profanity(COALESCE(NEW.message_text, '')) OR public.text_contains_profanity(COALESCE(NEW.content, '')) THEN
    RAISE EXCEPTION 'Profanity is not allowed.';
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.enforce_no_profanity_on_profiles()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF public.text_contains_profanity(COALESCE(NEW.full_name, ''))
     OR public.text_contains_profanity(COALESCE(NEW.display_name, ''))
     OR public.text_contains_profanity(COALESCE(NEW.username, ''))
     OR public.text_contains_profanity(COALESCE(NEW.bio, ''))
     OR public.text_contains_profanity(COALESCE(NEW.headline, '')) THEN
    RAISE EXCEPTION 'Profanity is not allowed.';
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.ensure_activity_group_chat(p_activity_id bigint, p_host_profile_id bigint, p_guest_profile_id bigint, p_activity_title text DEFAULT 'Group Activity'::text)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$ DECLARE v_conv_id bigint; BEGIN SELECT id INTO v_conv_id FROM group_conversations WHERE activity_id = p_activity_id LIMIT 1; IF v_conv_id IS NULL THEN INSERT INTO group_conversations (name, activity_id, created_by, last_message_at) VALUES (p_activity_title, p_activity_id, p_host_profile_id, NOW()) RETURNING id INTO v_conv_id; INSERT INTO group_conversation_members (group_conversation_id, profile_id, added_by, joined_at) VALUES (v_conv_id, p_host_profile_id, p_host_profile_id, NOW()) ON CONFLICT DO NOTHING; INSERT INTO group_messages (group_conversation_id, sender_id, message_text, is_system_message) VALUES (v_conv_id, p_host_profile_id, 'Welcome to the group chat!', true); END IF; INSERT INTO group_conversation_members (group_conversation_id, profile_id, added_by, joined_at) VALUES (v_conv_id, p_guest_profile_id, p_host_profile_id, NOW()) ON CONFLICT DO NOTHING; INSERT INTO group_messages (group_conversation_id, sender_id, message_text, is_system_message) SELECT v_conv_id, p_guest_profile_id, COALESCE(full_name, email, 'A new member') || ' joined the group.', true FROM profiles WHERE id = p_guest_profile_id; RETURN v_conv_id; END; $function$
;

create or replace view "public"."event_news_posts_feed" as  SELECT p.id,
    p.author_profile_id,
    p.caption,
    p.media,
    p.created_at,
    p.updated_at,
    COALESCE(pr.display_name, pr.full_name, (pr.username)::text, pr.email, 'Host'::text) AS author_name,
    COALESCE(pr.profile_photo_url, pr.avatar_url) AS author_avatar,
    ( SELECT count(*) AS count
           FROM public.event_news_likes l
          WHERE (l.post_id = p.id)) AS like_count,
    ( SELECT count(*) AS count
           FROM public.event_news_comments c
          WHERE (c.post_id = p.id)) AS comment_count
   FROM (public.event_news_posts p
     JOIN public.profiles pr ON ((pr.id = p.author_profile_id)));

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON t.typnamespace = n.oid
    WHERE t.typname = 'geometry_dump' AND n.nspname = 'public'
  ) THEN
    CREATE TYPE public.geometry_dump AS (path integer[], geom public.geometry);
  END IF;
END$$;

CREATE OR REPLACE FUNCTION public.get_my_entitlements()
 RETURNS TABLE(profile_id integer, core_tier text, can_access_chat boolean, can_access_feed boolean, can_receive_activity_payouts boolean, can_be_companion boolean, can_be_bouncer boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$ DECLARE v_profile_id integer; v_tier text; BEGIN SELECT p.id INTO v_profile_id FROM profiles p WHERE p.auth_id = (auth.uid())::text LIMIT 1; IF v_profile_id IS NULL THEN RETURN; END IF; SELECT s.tier INTO v_tier FROM subscriptions s WHERE s.profile_id = v_profile_id AND s.product = 'core' AND s.status = 'active' AND s.current_period_end > now() ORDER BY CASE s.tier WHEN 'premium' THEN 1 WHEN 'base' THEN 2 ELSE 3 END LIMIT 1; v_tier := COALESCE(v_tier, 'free'); RETURN QUERY SELECT v_profile_id, v_tier, (v_tier IN ('base','premium'))::boolean, (v_tier = 'premium')::boolean, (v_tier IN ('base','premium'))::boolean, (v_tier = 'premium')::boolean, (v_tier IN ('base','premium'))::boolean; END; $function$
;

CREATE OR REPLACE FUNCTION public.get_my_institution_id()
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
  SELECT institution_id FROM ct_users WHERE id = auth.uid() LIMIT 1
$function$
;

CREATE OR REPLACE FUNCTION public.get_platform_analytics()
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  result JSON;
BEGIN
  -- Check super admin
  IF NOT EXISTS (SELECT 1 FROM ct_superadmins sa 
    JOIN auth.users au ON au.email = sa.email 
    WHERE au.id = auth.uid() AND sa.is_active = true) THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;
  
  SELECT json_build_object(
    'total_users', (SELECT count(*) FROM ct_users),
    'total_institutions', (SELECT count(*) FROM ct_institutions),
    'users_by_role', (SELECT json_agg(r) FROM (SELECT role, count(*) as count FROM ct_users GROUP BY role ORDER BY count DESC) r),
    'users_by_institution', (SELECT json_agg(r) FROM (SELECT i.name, count(u.id) as user_count FROM ct_institutions i LEFT JOIN ct_users u ON u.institution_id = i.id GROUP BY i.id, i.name ORDER BY user_count DESC LIMIT 5) r),
    'new_users_30d', (SELECT json_agg(r) FROM (SELECT created_at::date::text as date, count(*) as count FROM ct_users WHERE created_at > now()-interval '30 days' GROUP BY 1 ORDER BY 1) r)
  ) INTO result;
  
  RETURN result;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_platform_stats()
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE result JSON;
BEGIN
  SELECT json_build_object(
    'total_users', (SELECT COUNT(*) FROM ct_users),
    'total_institutions', (SELECT COUNT(DISTINCT institution_id) FROM ct_users WHERE institution_id IS NOT NULL),
    'active_payment_methods', (SELECT COUNT(*) FROM ct_payment_methods WHERE is_active=true),
    'pending_payments', (SELECT COUNT(*) FROM ct_users WHERE payment_status='pending'),
    'on_trial', (SELECT COUNT(*) FROM ct_users WHERE trial_status='active'),
    'students', (SELECT COUNT(*) FROM ct_users WHERE role='student'),
    'teachers', (SELECT COUNT(*) FROM ct_users WHERE role='teacher'),
    'coaches', (SELECT COUNT(*) FROM ct_users WHERE role='coach'),
    'admins', (SELECT COUNT(*) FROM ct_users WHERE role='admin'),
    'total_clubs', (SELECT COUNT(*) FROM ct_clubs),
    'total_events', (SELECT COUNT(*) FROM ct_events),
    'total_sports_leagues', (SELECT COUNT(*) FROM ct_sports_leagues),
    'wellness_checkins_30d', (SELECT COUNT(*) FROM ct_wellbeing_checks WHERE date >= NOW()-INTERVAL '30 days'),
    'error_count', (SELECT COUNT(*) FROM ct_error_logs WHERE created_at >= NOW()-INTERVAL '7 days'),
    'pending_institution_requests', (SELECT COUNT(*) FROM ct_institution_requests WHERE status='pending'),
    'pending_trial_requests', (SELECT COUNT(*) FROM ct_free_trial_requests WHERE status='pending')
  ) INTO result;
  RETURN result;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_top_institutions(lim integer DEFAULT 10)
 RETURNS TABLE(institution_id uuid, institution_name text, user_count bigint)
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
  SELECT u.institution_id, i.name AS institution_name, COUNT(*) as user_count
  FROM ct_users u JOIN ct_institutions i ON i.id = u.institution_id
  WHERE u.institution_id IS NOT NULL
  GROUP BY u.institution_id, i.name
  ORDER BY user_count DESC LIMIT lim;
$function$
;

CREATE OR REPLACE FUNCTION public.get_user_growth_30d()
 RETURNS TABLE(day date, new_users bigint)
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
  SELECT DATE_TRUNC('day', created_at)::DATE as day, COUNT(*) as new_users
  FROM ct_users WHERE created_at >= NOW() - INTERVAL '30 days'
  GROUP BY 1 ORDER BY 1;
$function$
;

CREATE OR REPLACE FUNCTION public.get_user_institution_name(uid uuid)
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
  SELECT i.name FROM ct_institutions i
  JOIN ct_users u ON u.institution_id = i.id
  WHERE u.id = uid
  LIMIT 1
$function$
;

CREATE OR REPLACE FUNCTION public.group_is_host(conv_id bigint)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.group_conversations gc
    WHERE gc.id = conv_id
      AND gc.created_by = public.current_profile_id()
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.group_is_member(conv_id bigint, profile_id bigint DEFAULT NULL::bigint)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  pid bigint;
BEGIN
  pid := COALESCE(profile_id, public.current_profile_id());
  RETURN EXISTS (
    SELECT 1
    FROM public.group_conversation_members m
    WHERE m.group_conversation_id = conv_id
      AND m.profile_id = pid
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_ct_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  INSERT INTO ct_users (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'student')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_profile()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  -- Ensure auth_id is set if not provided
  IF NEW.auth_id IS NULL THEN
    NEW.auth_id := current_setting('request.jwt.claim.sub', true);
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user_subscription()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_tier TEXT;
  v_period_end TIMESTAMPTZ;
  v_promo_ends TIMESTAMPTZ;
  v_discount NUMERIC;
  v_promo_meta JSONB;
BEGIN
  -- OPENCLAY_PROMO: early_adopter_promo signups before 2026-04-15 get 6mo Premium
  IF NOW() <= '2026-04-15T23:59:59Z'::timestamptz THEN
    v_tier       := 'premium';
    v_period_end := NOW() + INTERVAL '6 months';
    v_promo_ends := '2026-10-15T23:59:59Z'::timestamptz;
    v_discount   := 100;
    v_promo_meta := jsonb_build_object(
      'promo', true,
      'promo_name', 'early_adopter_promo',
      'granted_at', NOW(),
      'source', 'profiles_trigger'
    );
  ELSE
    v_tier       := 'free';
    v_period_end := NOW() + INTERVAL '1 month';
    v_promo_ends := NULL;
    v_discount   := 0;
    v_promo_meta := jsonb_build_object(
      'promo', false,
      'granted_at', NOW(),
      'source', 'profiles_trigger'
    );
  END IF;

  INSERT INTO public.subscriptions (
    "userId",
    profile_id,
    product,
    tier,
    status,
    currency_code,
    price_cents,
    discount_percent,
    promo_ends_at,
    current_period_start,
    current_period_end,
    metadata
  )
  VALUES (
    NEW.id::integer,
    NEW.id,
    'core',
    v_tier,
    'active',
    'USD',
    0,
    v_discount,
    v_promo_ends,
    NOW(),
    v_period_end,
    v_promo_meta
  )
  ON CONFLICT (profile_id, product)
  DO UPDATE SET
    tier = (
      CASE
        WHEN EXCLUDED.tier = 'premium' THEN 'premium'
        WHEN EXCLUDED.tier = 'base' AND public.subscriptions.tier = 'free' THEN 'base'
        ELSE public.subscriptions.tier
      END
    ),
    current_period_end = GREATEST(public.subscriptions.current_period_end, EXCLUDED.current_period_end),
    promo_ends_at = COALESCE(public.subscriptions.promo_ends_at, EXCLUDED.promo_ends_at),
    metadata = (public.subscriptions.metadata || EXCLUDED.metadata),
    updated_at = NOW();

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_vip_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_vip_tier TEXT;
BEGIN
  -- OPENCLAY_VIP: permanent enterprise accounts — do not remove
  SELECT tier INTO v_vip_tier
  FROM public.vip_accounts
  WHERE email = lower(trim(NEW.email));

  IF v_vip_tier IS NOT NULL THEN
    -- Grant VIP subscription (enterprise = premium with permanent period)
    INSERT INTO public.subscriptions (
      profile_id,
      product,
      tier,
      status,
      currency_code,
      price_cents,
      discount_percent,
      promo_ends_at,
      current_period_start,
      current_period_end,
      metadata
    )
    VALUES (
      NEW.id,
      'core',
      'premium',
      'active',
      'USD',
      0,
      100,
      '2099-12-31T23:59:59Z'::timestamptz,
      NOW(),
      '2099-12-31T23:59:59Z'::timestamptz,
      jsonb_build_object(
        'vip', true,
        'vip_tier', v_vip_tier,
        'granted_at', NOW(),
        'source', 'vip_trigger',
        'note', 'OPENCLAY_VIP permanent enterprise account'
      )
    )
    ON CONFLICT (profile_id, product)
    DO UPDATE SET
      tier = 'premium',
      status = 'active',
      price_cents = 0,
      discount_percent = 100,
      promo_ends_at = '2099-12-31T23:59:59Z'::timestamptz,
      current_period_end = '2099-12-31T23:59:59Z'::timestamptz,
      metadata = (public.subscriptions.metadata || jsonb_build_object(
        'vip', true,
        'vip_tier', v_vip_tier,
        'granted_at', NOW()
      )),
      updated_at = NOW();
  END IF;

  RETURN NEW;
END;
$function$
;

create or replace view "public"."host_activity_earnings" as  SELECT (id)::text AS booking_id,
    host_profile_id AS profile_id,
    'activity_host'::text AS role,
    booking_date AS booking_start,
    booking_date AS booking_end,
    status,
    payment_status,
    GREATEST((0)::numeric, ((COALESCE(subtotal_amount, total_amount, (0)::numeric) - COALESCE(platform_fee_amount, (0)::numeric)) - COALESCE(tax_amount, (0)::numeric))) AS net_amount,
    COALESCE(subtotal_amount, total_amount, (0)::numeric) AS gross_amount,
    COALESCE(platform_fee_amount, (0)::numeric) AS fee_amount
   FROM public.activity_bookings ab
  WHERE (host_profile_id IS NOT NULL);


CREATE OR REPLACE FUNCTION public.increment_activity_share_count()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE companion_activities
  SET 
    share_count = share_count + 1,
    last_shared_at = NOW()
  WHERE id = NEW.activity_id;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.increment_activity_view_count()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE companion_activities
  SET view_count = view_count + 1
  WHERE id = NEW.activity_id;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.increment_bud_usage(key_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  UPDATE api_keys
  SET current_month_usage = current_month_usage + 1,
      last_used_at = NOW()
  WHERE id = key_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_admin()
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles p
    WHERE p.auth_id = auth.uid()::text
      AND COALESCE(p.account_type, 'standard') = 'admin'
  );
$function$
;

CREATE OR REPLACE FUNCTION public.is_admin_user(check_email text DEFAULT NULL::text)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  jwt_email text;
BEGIN
  jwt_email := lower(coalesce(check_email, auth.jwt()->>'email', ''));
  IF jwt_email = '' THEN
    RETURN false;
  END IF;

  RETURN EXISTS (
    SELECT 1
    FROM public.admin_access_emails a
    WHERE lower(a.email) = jwt_email
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_superadmin()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
  SELECT COALESCE(
    EXISTS (
      SELECT 1 FROM ct_superadmins sa
      JOIN auth.users au ON au.email = sa.email
      WHERE au.id = auth.uid() AND sa.is_active = true
    ),
    false
  )
$function$
;

CREATE OR REPLACE FUNCTION public.is_verified_profile(pid bigint)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  SELECT COALESCE(p.is_verified, false) OR COALESCE(p.is_bouncer_verified, false)
  FROM public.profiles p
  WHERE p.id = pid;
$function$
;

CREATE OR REPLACE FUNCTION public.lock_response_edits_after_2d()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF OLD.created_at < (now() - interval '2 days') THEN
      RAISE EXCEPTION 'Response can no longer be edited after 2 days';
    END IF;
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.log_account_status_change()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Log pause
  IF NEW.account_status = 'paused' AND OLD.account_status != 'paused' THEN
    NEW.paused_at := NOW();
    INSERT INTO account_activity_log (profile_id, action, details)
    VALUES (NEW.id, 'account_paused', jsonb_build_object('previous_status', OLD.account_status));
  END IF;

  -- Log unpause
  IF NEW.account_status = 'active' AND OLD.account_status = 'paused' THEN
    NEW.paused_at := NULL;
    NEW.paused_until := NULL;
    INSERT INTO account_activity_log (profile_id, action, details)
    VALUES (NEW.id, 'account_resumed', jsonb_build_object('paused_duration', OLD.paused_at));
  END IF;

  -- Log deletion request
  IF NEW.account_status = 'deleted' AND OLD.account_status != 'deleted' THEN
    NEW.deletion_requested_at := NOW();
    NEW.deletion_scheduled_for := NOW() + INTERVAL '30 days';
    INSERT INTO account_activity_log (profile_id, action, details)
    VALUES (NEW.id, 'deletion_requested', jsonb_build_object('scheduled_for', NEW.deletion_scheduled_for));
  END IF;

  -- Recovery path: if account is no longer deleted, clear deletion markers
  IF NEW.account_status IS DISTINCT FROM 'deleted' THEN
    NEW.deletion_requested_at := NULL;
    NEW.deletion_scheduled_for := NULL;
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.log_booking_status_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  changed_by_id INTEGER;
BEGIN
  -- Get the current user's profile ID
  SELECT id INTO changed_by_id FROM profiles WHERE auth_id = auth.uid()::text LIMIT 1;
  
  -- Only log if status actually changed
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO booking_status_history (booking_id, from_status, to_status, changed_by)
    VALUES (NEW.id, OLD.status, NEW.status, changed_by_id);
  END IF;
  
  -- Track completion timestamp
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    NEW.completed_at := NOW();
  END IF;
  
  -- Track in_progress timestamp
  IF NEW.status = 'in_progress' AND OLD.status != 'in_progress' THEN
    NEW.in_progress_at := NOW();
  END IF;
  
  -- Track cancellation timestamp
  IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
    NEW.cancelled_at := NOW();
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.mark_group_conversation_read(p_group_conversation_id bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  UPDATE public.group_conversation_members m
  SET last_read_at = now()
  WHERE m.group_conversation_id = p_group_conversation_id
    AND m.profile_id = public.current_profile_id();
END;
$function$
;

CREATE OR REPLACE FUNCTION public.notify_demo_request()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  PERFORM net.http_post(
    url := 'https://ncftkuuxfllyohixiusb.supabase.co/functions/v1/demo-request',
    headers := jsonb_build_object('Content-Type','application/json','Authorization','Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jZnRrdXV4ZmxseW9oaXhpdXNiIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NzcyMjUxMCwiZXhwIjoyMDgzMjk4NTEwfQ.pJ_jm9sVzbGUt3g_VN4Wq4IKCSrFv_KnAUngngPfnY8'),
    body := jsonb_build_object('record', row_to_json(NEW))
  );
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.notify_ticket_update()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE ct_tickets SET updated_at = now() WHERE id = NEW.ticket_id;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.on_message_check_profanity()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  body text;
BEGIN
  body := COALESCE(NEW.message_text, NEW.content, '');
  -- Skip system messages and empty content
  IF NEW.is_system_message OR body = '' OR body IS NULL THEN
    RETURN NEW;
  END IF;
  -- Skip non-text messages (voice notes, images, files)
  IF body LIKE '[voice]%' OR body LIKE '[image]%' OR body LIKE '[file]%' OR body LIKE '[call]%' THEN
    RETURN NEW;
  END IF;

  IF public.text_has_profanity(body) THEN
    NEW.is_flagged := true;
    NEW.flag_reason := 'profanity';
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.on_profile_update_check_profanity()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  combined text;
BEGIN
  combined := COALESCE(NEW.bio, '') || ' ' || COALESCE(NEW.headline, '') || ' ' || COALESCE(NEW.full_name, '');
  IF public.text_has_profanity(combined) THEN
    NEW.bio_flagged := true;
  ELSE
    NEW.bio_flagged := false;
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.on_review_submit_moderate_and_reveal()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  reasons       text[] := '{}';
  word_count    int;
  caps_ratio    float;
BEGIN
  IF NEW.status <> 'submitted' THEN
    RETURN NEW;
  END IF;

  -- Only run on transition from draft -> submitted
  IF OLD.status = 'submitted' THEN
    RETURN NEW;
  END IF;

  NEW.submitted_at   := COALESCE(NEW.submitted_at, now());
  NEW.counts_toward_rating := true;

  -- ---- Moderation checks ----
  IF NEW.body IS NOT NULL THEN
    word_count := array_length(regexp_split_to_array(trim(NEW.body), '\s+'), 1);

    -- Too short (< 3 words after whitespace normalization)
    IF word_count < 3 THEN
      reasons := array_append(reasons, 'too_short');
    END IF;

    -- Profanity check
    IF EXISTS (
      SELECT 1 FROM public.profanity_terms pt
      WHERE NEW.body ILIKE '%' || pt.term || '%'
    ) THEN
      reasons := array_append(reasons, 'profanity');
    END IF;

    -- Excessive caps (>30% of alphabetic characters)
    IF length(NEW.body) > 0 THEN
      caps_ratio := (
        length(regexp_replace(NEW.body, '[^A-Z]', '', 'g'))::float /
        GREATEST(length(regexp_replace(NEW.body, '[^A-Za-z]', '', 'g')), 1)
      );
      IF caps_ratio > 0.30 THEN
        reasons := array_append(reasons, 'excessive_caps');
      END IF;
    END IF;
  END IF;

  NEW.moderation_reasons := reasons;

  -- Auto-approve if no flags detected
  IF array_length(reasons, 1) IS NULL THEN
    NEW.moderation_status := 'approved';
  ELSE
    NEW.moderation_status := 'flagged';
  END IF;

  NEW.moderated_at := now();

  -- Reveal immediately on submit
  NEW.revealed_at := COALESCE(NEW.revealed_at, now());
  NEW.status      := 'revealed';

  INSERT INTO public.booking_review_audit_log(entity_type, entity_id, action, actor_profile_id, new_row)
  VALUES ('review', NEW.id, 'submit', NEW.reviewer_profile_id, to_jsonb(NEW));

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.on_subscription_change_refresh_payouts()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.product = 'core' THEN
    PERFORM refresh_activity_payout_locks_for_host(NEW.profile_id);
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.prevent_payment_status_bypass()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Only superadmins and service role can upgrade payment_status to 'active'
  IF NEW.payment_status = 'active' AND OLD.payment_status != 'active' THEN
    IF NOT is_superadmin() THEN
      -- Check if it's a service-role context (no auth.uid = service role)
      IF auth.uid() IS NOT NULL THEN
        RAISE EXCEPTION 'Payment status can only be activated by platform administrators';
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.prevent_self_role_escalation()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- If this is the user updating their own row, they cannot change role or roles
  IF NEW.id = auth.uid() AND NOT is_superadmin() THEN
    -- Check if the updater is NOT an admin/IT in their institution
    IF NOT EXISTS (
      SELECT 1 FROM ct_users u 
      WHERE u.id = auth.uid() 
        AND u.role IN ('admin', 'it_director')
        AND u.institution_id = NEW.institution_id
    ) THEN
      -- Non-admin updating self: preserve old role values
      NEW.role := OLD.role;
      NEW.roles := OLD.roles;
    END IF;
  END IF;
  RETURN NEW;
END;
$function$
;

create or replace view "public"."profile_entitlements" as  WITH core AS (
         SELECT s.profile_id,
            s.tier,
            s.status,
            s.current_period_end
           FROM public.subscriptions s
          WHERE ((s.product = 'core'::text) AND ((s.status)::text = 'active'::text))
        ), core_ranked AS (
         SELECT c.profile_id,
            c.tier,
            c.status,
            c.current_period_end,
            row_number() OVER (PARTITION BY c.profile_id ORDER BY c.current_period_end DESC) AS rn
           FROM core c
        )
 SELECT id AS profile_id,
    COALESCE(( SELECT core_ranked.tier
           FROM core_ranked
          WHERE ((core_ranked.profile_id = p.id) AND (core_ranked.rn = 1))), 'free'::text) AS core_tier,
    NULL::text AS bouncer_tier,
    (COALESCE(( SELECT core_ranked.tier
           FROM core_ranked
          WHERE ((core_ranked.profile_id = p.id) AND (core_ranked.rn = 1))), 'free'::text) = ANY (ARRAY['base'::text, 'premium'::text])) AS can_access_chat,
    (COALESCE(( SELECT core_ranked.tier
           FROM core_ranked
          WHERE ((core_ranked.profile_id = p.id) AND (core_ranked.rn = 1))), 'free'::text) = 'premium'::text) AS can_access_feed,
    (COALESCE(( SELECT core_ranked.tier
           FROM core_ranked
          WHERE ((core_ranked.profile_id = p.id) AND (core_ranked.rn = 1))), 'free'::text) = ANY (ARRAY['base'::text, 'premium'::text])) AS can_receive_activity_payouts,
    (COALESCE(( SELECT core_ranked.tier
           FROM core_ranked
          WHERE ((core_ranked.profile_id = p.id) AND (core_ranked.rn = 1))), 'free'::text) = 'premium'::text) AS can_be_companion,
    (COALESCE(( SELECT core_ranked.tier
           FROM core_ranked
          WHERE ((core_ranked.profile_id = p.id) AND (core_ranked.rn = 1))), 'free'::text) = ANY (ARRAY['base'::text, 'premium'::text])) AS can_be_bouncer
   FROM public.profiles p;


create or replace view "public"."profile_review_summary" as  SELECT reviewee_profile_id AS profile_id,
    count(*) FILTER (WHERE ((status = 'revealed'::text) AND (moderation_status = ANY (ARRAY['approved'::text, 'pending'::text])) AND counts_toward_rating)) AS review_count,
    COALESCE(avg(rating) FILTER (WHERE ((status = 'revealed'::text) AND (moderation_status = ANY (ARRAY['approved'::text, 'pending'::text])) AND counts_toward_rating)), (0)::numeric) AS avg_rating
   FROM public.booking_reviews
  GROUP BY reviewee_profile_id;


create or replace view "public"."profile_review_trend_30d" as  SELECT reviewee_profile_id AS profile_id,
    date_trunc('day'::text, created_at) AS day,
    count(*) FILTER (WHERE ((moderation_status = 'approved'::text) AND (status = 'revealed'::text) AND counts_toward_rating)) AS review_count,
    COALESCE(avg(rating) FILTER (WHERE ((moderation_status = 'approved'::text) AND (status = 'revealed'::text) AND counts_toward_rating)), (0)::numeric) AS avg_rating
   FROM public.booking_reviews
  WHERE (created_at >= (now() - '30 days'::interval))
  GROUP BY reviewee_profile_id, (date_trunc('day'::text, created_at));


CREATE OR REPLACE FUNCTION public.promo_premium_until_20260301_is_active()
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  SELECT now() < '2026-03-01T00:00:00Z'::timestamptz;
$function$
;

create or replace view "public"."provider_booking_earnings" as  SELECT (b.id)::text AS booking_id,
    (b.companion_id)::bigint AS profile_id,
    'companion'::text AS role,
    b.start_time AS booking_start,
    COALESCE(b.end_time, (b.start_time + ((COALESCE(b.duration_hours, (1)::numeric))::double precision * '01:00:00'::interval))) AS booking_end,
    b.status,
    b.payment_status,
    GREATEST((0)::numeric, (COALESCE(b.subtotal_amount, (0)::numeric) - COALESCE(b.platform_fee_companion_amount, (0)::numeric))) AS net_amount,
    COALESCE(b.subtotal_amount, (0)::numeric) AS gross_amount,
    COALESCE(b.platform_fee_companion_amount, (0)::numeric) AS fee_amount
   FROM public.bookings b
  WHERE (b.companion_id IS NOT NULL)
UNION ALL
 SELECT (b.id)::text AS booking_id,
    (b.bouncer_id)::bigint AS profile_id,
    'bouncer'::text AS role,
    b.start_time AS booking_start,
    COALESCE(b.end_time, (b.start_time + ((COALESCE(b.duration_hours, (1)::numeric))::double precision * '01:00:00'::interval))) AS booking_end,
    b.status,
    b.payment_status,
    GREATEST((0)::numeric, (COALESCE(b.subtotal_amount, (0)::numeric) - COALESCE(b.platform_fee_bouncer_amount, (0)::numeric))) AS net_amount,
    COALESCE(b.subtotal_amount, (0)::numeric) AS gross_amount,
    COALESCE(b.platform_fee_bouncer_amount, (0)::numeric) AS fee_amount
   FROM public.bookings b
  WHERE (b.bouncer_id IS NOT NULL);


CREATE OR REPLACE FUNCTION public.refresh_activity_payout_locks_for_host(host_id bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  eligible BOOLEAN;
BEGIN
  SELECT COALESCE(pe.can_receive_activity_payouts, false)
  INTO eligible
  FROM profile_entitlements pe
  WHERE pe.profile_id = host_id;

  IF eligible THEN
    UPDATE activity_bookings
    SET host_payout_eligible = true,
        host_payout_status = 'eligible',
        host_payout_locked_reason = NULL
    WHERE host_profile_id = host_id
      AND (host_payout_status = 'locked' OR host_payout_eligible IS DISTINCT FROM true)
      AND COALESCE(host_payout_locked_reason, '') IN ('', 'requires_base_subscription');
  ELSE
    UPDATE activity_bookings
    SET host_payout_eligible = false,
        host_payout_status = 'locked',
        host_payout_locked_reason = 'requires_base_subscription'
    WHERE host_profile_id = host_id
      AND (host_payout_status <> 'paid');
  END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.reset_bud_monthly_usage()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  UPDATE api_keys
  SET current_month_usage = 0,
      usage_reset_at = DATE_TRUNC('month', NOW()) + INTERVAL '1 month'
  WHERE usage_reset_at <= NOW();
END;
$function$
;

CREATE OR REPLACE FUNCTION public.review_contains_contact_info(content text)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  SELECT
    content ~* '([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,})'
    OR content ~* '(https?:\/\/|www\.)'
    OR content ~* '(\+?\d[\d\s().-]{8,}\d)';
$function$
;

CREATE OR REPLACE FUNCTION public.review_contains_profanity(content text)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.profanity_terms t
    WHERE content ILIKE '%' || t.term || '%'
  );
$function$
;

CREATE OR REPLACE FUNCTION public.review_uppercase_ratio(content text)
 RETURNS numeric
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  letters text;
  upper text;
  total_count int;
  upper_count int;
BEGIN
  IF content IS NULL THEN
    RETURN 0;
  END IF;
  letters := regexp_replace(content, '[^A-Za-z]', '', 'g');
  upper := regexp_replace(content, '[^A-Z]', '', 'g');
  total_count := char_length(letters);
  upper_count := char_length(upper);
  IF total_count = 0 THEN
    RETURN 0;
  END IF;
  RETURN upper_count::numeric / total_count::numeric;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.safe_to_numeric(v text)
 RETURNS numeric
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
BEGIN
  IF v IS NULL OR btrim(v) = '' THEN
    RETURN NULL;
  END IF;
  RETURN v::numeric;
EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.safe_to_timestamptz(v text)
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
BEGIN
  IF v IS NULL OR btrim(v) = '' THEN
    RETURN NULL;
  END IF;
  RETURN v::timestamptz;
EXCEPTION WHEN others THEN
  RETURN NULL;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.set_activity_booking_host_and_payout_lock()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  host_id BIGINT;
  eligible BOOLEAN;
BEGIN
  SELECT created_by INTO host_id
  FROM companion_activities
  WHERE id = NEW.activity_id;

  NEW.host_profile_id := host_id;

  IF host_id IS NULL THEN
    NEW.host_payout_eligible := false;
    NEW.host_payout_status := 'locked';
    NEW.host_payout_locked_reason := 'missing_host';
    RETURN NEW;
  END IF;

  SELECT COALESCE(pe.can_receive_activity_payouts, false)
  INTO eligible
  FROM profile_entitlements pe
  WHERE pe.profile_id = host_id;

  NEW.host_payout_eligible := eligible;

  IF eligible THEN
    NEW.host_payout_status := 'eligible';
    NEW.host_payout_locked_reason := NULL;
  ELSE
    NEW.host_payout_status := 'locked';
    NEW.host_payout_locked_reason := 'requires_base_subscription';
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.set_updated_at_timestamp()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.submit_activity_host_review(p_booking_id bigint, p_activity_id bigint, p_rating integer, p_review text DEFAULT NULL::text)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  reviewer_id bigint;
  host_id bigint;
  existing_id bigint;
  result_id bigint;
BEGIN
  reviewer_id := public.current_profile_id();
  IF reviewer_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF p_rating < 1 OR p_rating > 5 THEN
    RAISE EXCEPTION 'Rating must be between 1 and 5';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.activity_bookings ab
    WHERE ab.id = p_booking_id
      AND ab.activity_id = p_activity_id
      AND ab.user_id = reviewer_id
      AND lower(COALESCE(ab.status, '')) NOT IN ('denied', 'cancelled', 'canceled')
  ) THEN
    RAISE EXCEPTION 'You can only review hosts for your own valid activity booking';
  END IF;

  SELECT ca.created_by INTO host_id
  FROM public.companion_activities ca
  WHERE ca.id = p_activity_id
  LIMIT 1;

  IF host_id IS NULL THEN
    RAISE EXCEPTION 'Activity host not found';
  END IF;

  SELECT ar.id INTO existing_id
  FROM public.activity_reviews ar
  WHERE ar.booking_id = p_booking_id
    AND ar.activity_id = p_activity_id
    AND ar.reviewer_id = reviewer_id
  LIMIT 1;

  IF existing_id IS NOT NULL THEN
    UPDATE public.activity_reviews
    SET rating = p_rating,
        review = NULLIF(BTRIM(COALESCE(p_review, '')), ''),
        companion_id = host_id,
        updated_at = now()
    WHERE id = existing_id
    RETURNING id INTO result_id;
  ELSE
    INSERT INTO public.activity_reviews (
      booking_id,
      activity_id,
      reviewer_id,
      companion_id,
      rating,
      review
    ) VALUES (
      p_booking_id,
      p_activity_id,
      reviewer_id,
      host_id,
      p_rating,
      NULLIF(BTRIM(COALESCE(p_review, '')), '')
    )
    RETURNING id INTO result_id;
  END IF;

  RETURN result_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.sync_approved_booking_to_availability()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  companion_profile_id integer;
  bouncer_profile_id integer;
  booking_day text;
  booking_start text;
  booking_end text;
  resolved_start TIMESTAMPTZ;
  resolved_end TIMESTAMPTZ;
BEGIN
  IF NEW.status = 'approved' AND COALESCE(OLD.status, '') <> 'approved' THEN
    companion_profile_id := COALESCE(NEW."providerId", NEW.companion_id);
    bouncer_profile_id := COALESCE(NEW."bouncerId", NEW.bouncer_id);
    resolved_start := COALESCE(NEW.start_time, NEW."startTime");
    resolved_end := COALESCE(NEW.end_time, NEW."endTime", resolved_start);

    IF resolved_start IS NOT NULL THEN
      booking_day := 'date:' || to_char(resolved_start, 'YYYY-MM-DD');
      booking_start := to_char(resolved_start, 'HH12:MI AM');
      booking_end := to_char(resolved_end, 'HH12:MI AM');

      IF companion_profile_id IS NOT NULL THEN
        INSERT INTO availability_slots (profile_id, day_of_week, start_time, end_time)
        VALUES (companion_profile_id, booking_day, booking_start, booking_end)
        ON CONFLICT (profile_id, day_of_week, start_time, end_time) DO NOTHING;
      END IF;

      IF bouncer_profile_id IS NOT NULL THEN
        INSERT INTO availability_slots (profile_id, day_of_week, start_time, end_time)
        VALUES (bouncer_profile_id, booking_day, booking_start, booking_end)
        ON CONFLICT (profile_id, day_of_week, start_time, end_time) DO NOTHING;
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.sync_booking_hours_duration()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.hours IS NULL AND NEW.duration IS NOT NULL THEN
    NEW.hours := NEW.duration;
  ELSIF NEW.duration IS NULL AND NEW.hours IS NOT NULL THEN
    NEW.duration := NEW.hours;
  ELSIF NEW.hours IS DISTINCT FROM NEW.duration THEN
    NEW.duration := NEW.hours;
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.sync_messages_legacy_columns()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
      BEGIN
        -- conversationId <-> conversation_id
        IF EXISTS (
          SELECT 1 FROM information_schema.columns
          WHERE table_schema='public' AND table_name='messages' AND column_name='conversationId'
        ) THEN
          IF NEW.conversation_id IS NULL AND NEW."conversationId" IS NOT NULL THEN
            NEW.conversation_id := NEW."conversationId";
          ELSIF NEW."conversationId" IS NULL AND NEW.conversation_id IS NOT NULL THEN
            NEW."conversationId" := NEW.conversation_id;
          END IF;
        END IF;

        -- senderId <-> sender_id
        IF EXISTS (
          SELECT 1 FROM information_schema.columns
          WHERE table_schema='public' AND table_name='messages' AND column_name='senderId'
        ) THEN
          IF NEW.sender_id IS NULL AND NEW."senderId" IS NOT NULL THEN
            NEW.sender_id := NEW."senderId";
          ELSIF NEW."senderId" IS NULL AND NEW.sender_id IS NOT NULL THEN
            NEW."senderId" := NEW.sender_id;
          END IF;
        END IF;

        -- recipientId (only if snake_case exists too)
        IF EXISTS (
          SELECT 1 FROM information_schema.columns
          WHERE table_schema='public' AND table_name='messages' AND column_name='recipientId'
        ) THEN
          IF EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_schema='public' AND table_name='messages' AND column_name='recipient_id'
          ) THEN
            IF NEW.recipient_id IS NULL AND NEW."recipientId" IS NOT NULL THEN
              NEW.recipient_id := NEW."recipientId";
            ELSIF NEW."recipientId" IS NULL AND NEW.recipient_id IS NOT NULL THEN
              NEW."recipientId" := NEW.recipient_id;
            END IF;
          END IF;
        END IF;

        RETURN NEW;
      END;
      $function$
;

CREATE OR REPLACE FUNCTION public.sync_messages_legacy_fields()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
      BEGIN
        IF NEW.sender_id IS NULL AND NEW."senderId" IS NOT NULL THEN
          NEW.sender_id := NEW."senderId";
        ELSIF NEW."senderId" IS NULL AND NEW.sender_id IS NOT NULL THEN
          NEW."senderId" := NEW.sender_id;
        END IF;

        IF NEW.message_text IS NULL AND NEW."content" IS NOT NULL THEN
          NEW.message_text := NEW."content";
        ELSIF NEW."content" IS NULL AND NEW.message_text IS NOT NULL THEN
          NEW."content" := NEW.message_text;
        END IF;

        IF NEW.conversation_id IS NULL AND NEW."conversationId" IS NOT NULL THEN
          NEW.conversation_id := NEW."conversationId";
        ELSIF NEW."conversationId" IS NULL AND NEW.conversation_id IS NOT NULL THEN
          NEW."conversationId" := NEW.conversation_id;
        END IF;

        IF NEW."recipientId" IS NULL AND NEW.conversation_id IS NOT NULL AND NEW.sender_id IS NOT NULL THEN
          SELECT CASE
            WHEN c.participant1_id = NEW.sender_id THEN c.participant2_id
            ELSE c.participant1_id
          END
          INTO NEW."recipientId"
          FROM conversations c
          WHERE c.id = NEW.conversation_id;
        END IF;

        RETURN NEW;
      END;
      $function$
;

CREATE OR REPLACE FUNCTION public.text_contains_profanity(content text)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  SELECT public.review_contains_profanity(COALESCE(content, ''));
$function$
;

CREATE OR REPLACE FUNCTION public.text_has_profanity(txt text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT EXISTS (
    SELECT 1 FROM public.profanity_terms pt
    WHERE txt ILIKE '%' || pt.term || '%'
  );
$function$
;

CREATE OR REPLACE FUNCTION public.trg_profiles_grant_promo_premium()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF public.promo_premium_until_20260301_is_active() THEN
    INSERT INTO public.subscriptions (
      "userId",
      profile_id,
      product,
      tier,
      status,
      currency_code,
      price_cents,
      discount_percent,
      promo_ends_at,
      current_period_start,
      current_period_end,
      metadata
    )
    VALUES (
      NEW.id::integer,
      NEW.id,
      'core',
      'premium',
      'active',
      'USD',
      0,
      100,
      '2026-03-01T00:00:00Z'::timestamptz,
      now(),
      GREATEST(now() + interval '1 day', '2026-03-01T00:00:00Z'::timestamptz),
      jsonb_build_object('promo', true, 'promo_name', 'premium_free_until_20260301', 'granted_at', now(), 'source', 'profiles_trigger')
    )
    ON CONFLICT (profile_id, product)
    DO UPDATE SET
      tier = 'premium',
      status = 'active',
      price_cents = 0,
      discount_percent = 100,
      promo_ends_at = EXCLUDED.promo_ends_at,
      current_period_end = GREATEST(public.subscriptions.current_period_end, EXCLUDED.current_period_end),
      metadata = (public.subscriptions.metadata || EXCLUDED.metadata);
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_activity_booking_payment(p_booking_id bigint, p_payment_status text, p_payment_intent_id text, p_total_amount numeric)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  UPDATE activity_bookings
  SET payment_status = p_payment_status,
      payment_intent_id = p_payment_intent_id,
      total_amount = p_total_amount
  WHERE id = p_booking_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_activity_booking_payment(p_booking_id uuid, p_payment_status text, p_payment_intent_id text, p_total_amount numeric)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  UPDATE activity_bookings
  SET payment_status = p_payment_status,
      payment_intent_id = p_payment_intent_id,
      total_amount = p_total_amount
  WHERE id = p_booking_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_booking_payment(p_booking_id bigint, p_payment_status text, p_payment_intent_id text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  UPDATE service_bookings
  SET payment_status = p_payment_status,
      payment_intent_id = p_payment_intent_id,
      updated_at = NOW()
  WHERE id = p_booking_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_booking_payment(p_booking_id uuid, p_payment_status text, p_payment_intent_id text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  UPDATE service_bookings
  SET payment_status = p_payment_status,
      payment_intent_id = p_payment_intent_id,
      updated_at = NOW()
  WHERE id = p_booking_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_profiles_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_services_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$
;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t
    JOIN pg_namespace n ON t.typnamespace = n.oid
    WHERE t.typname = 'valid_detail' AND n.nspname = 'public'
  ) THEN
    CREATE TYPE public.valid_detail AS (valid boolean, reason character varying, location public.geometry);
  END IF;
END$$;

grant delete on table "public"."account_activity_log" to "anon";

grant insert on table "public"."account_activity_log" to "anon";

grant references on table "public"."account_activity_log" to "anon";

grant select on table "public"."account_activity_log" to "anon";

grant trigger on table "public"."account_activity_log" to "anon";

grant truncate on table "public"."account_activity_log" to "anon";

grant update on table "public"."account_activity_log" to "anon";

grant delete on table "public"."account_activity_log" to "authenticated";

grant insert on table "public"."account_activity_log" to "authenticated";

grant references on table "public"."account_activity_log" to "authenticated";

grant select on table "public"."account_activity_log" to "authenticated";

grant trigger on table "public"."account_activity_log" to "authenticated";

grant truncate on table "public"."account_activity_log" to "authenticated";

grant update on table "public"."account_activity_log" to "authenticated";

grant delete on table "public"."account_activity_log" to "service_role";

grant insert on table "public"."account_activity_log" to "service_role";

grant references on table "public"."account_activity_log" to "service_role";

grant select on table "public"."account_activity_log" to "service_role";

grant trigger on table "public"."account_activity_log" to "service_role";

grant truncate on table "public"."account_activity_log" to "service_role";

grant update on table "public"."account_activity_log" to "service_role";

grant delete on table "public"."activities" to "anon";

grant insert on table "public"."activities" to "anon";

grant references on table "public"."activities" to "anon";

grant select on table "public"."activities" to "anon";

grant trigger on table "public"."activities" to "anon";

grant truncate on table "public"."activities" to "anon";

grant update on table "public"."activities" to "anon";

grant delete on table "public"."activities" to "authenticated";

grant insert on table "public"."activities" to "authenticated";

grant references on table "public"."activities" to "authenticated";

grant select on table "public"."activities" to "authenticated";

grant trigger on table "public"."activities" to "authenticated";

grant truncate on table "public"."activities" to "authenticated";

grant update on table "public"."activities" to "authenticated";

grant delete on table "public"."activities" to "service_role";

grant insert on table "public"."activities" to "service_role";

grant references on table "public"."activities" to "service_role";

grant select on table "public"."activities" to "service_role";

grant trigger on table "public"."activities" to "service_role";

grant truncate on table "public"."activities" to "service_role";

grant update on table "public"."activities" to "service_role";

grant delete on table "public"."activities_media" to "anon";

grant insert on table "public"."activities_media" to "anon";

grant references on table "public"."activities_media" to "anon";

grant select on table "public"."activities_media" to "anon";

grant trigger on table "public"."activities_media" to "anon";

grant truncate on table "public"."activities_media" to "anon";

grant update on table "public"."activities_media" to "anon";

grant delete on table "public"."activities_media" to "authenticated";

grant insert on table "public"."activities_media" to "authenticated";

grant references on table "public"."activities_media" to "authenticated";

grant select on table "public"."activities_media" to "authenticated";

grant trigger on table "public"."activities_media" to "authenticated";

grant truncate on table "public"."activities_media" to "authenticated";

grant update on table "public"."activities_media" to "authenticated";

grant delete on table "public"."activities_media" to "service_role";

grant insert on table "public"."activities_media" to "service_role";

grant references on table "public"."activities_media" to "service_role";

grant select on table "public"."activities_media" to "service_role";

grant trigger on table "public"."activities_media" to "service_role";

grant truncate on table "public"."activities_media" to "service_role";

grant update on table "public"."activities_media" to "service_role";

grant delete on table "public"."activity_bookings" to "anon";

grant insert on table "public"."activity_bookings" to "anon";

grant references on table "public"."activity_bookings" to "anon";

grant select on table "public"."activity_bookings" to "anon";

grant trigger on table "public"."activity_bookings" to "anon";

grant truncate on table "public"."activity_bookings" to "anon";

grant update on table "public"."activity_bookings" to "anon";

grant delete on table "public"."activity_bookings" to "authenticated";

grant insert on table "public"."activity_bookings" to "authenticated";

grant references on table "public"."activity_bookings" to "authenticated";

grant select on table "public"."activity_bookings" to "authenticated";

grant trigger on table "public"."activity_bookings" to "authenticated";

grant truncate on table "public"."activity_bookings" to "authenticated";

grant update on table "public"."activity_bookings" to "authenticated";

grant delete on table "public"."activity_bookings" to "service_role";

grant insert on table "public"."activity_bookings" to "service_role";

grant references on table "public"."activity_bookings" to "service_role";

grant select on table "public"."activity_bookings" to "service_role";

grant trigger on table "public"."activity_bookings" to "service_role";

grant truncate on table "public"."activity_bookings" to "service_role";

grant update on table "public"."activity_bookings" to "service_role";

grant delete on table "public"."activity_reviews" to "anon";

grant insert on table "public"."activity_reviews" to "anon";

grant references on table "public"."activity_reviews" to "anon";

grant select on table "public"."activity_reviews" to "anon";

grant trigger on table "public"."activity_reviews" to "anon";

grant truncate on table "public"."activity_reviews" to "anon";

grant update on table "public"."activity_reviews" to "anon";

grant delete on table "public"."activity_reviews" to "authenticated";

grant insert on table "public"."activity_reviews" to "authenticated";

grant references on table "public"."activity_reviews" to "authenticated";

grant select on table "public"."activity_reviews" to "authenticated";

grant trigger on table "public"."activity_reviews" to "authenticated";

grant truncate on table "public"."activity_reviews" to "authenticated";

grant update on table "public"."activity_reviews" to "authenticated";

grant delete on table "public"."activity_reviews" to "service_role";

grant insert on table "public"."activity_reviews" to "service_role";

grant references on table "public"."activity_reviews" to "service_role";

grant select on table "public"."activity_reviews" to "service_role";

grant trigger on table "public"."activity_reviews" to "service_role";

grant truncate on table "public"."activity_reviews" to "service_role";

grant update on table "public"."activity_reviews" to "service_role";

grant delete on table "public"."activity_shares" to "anon";

grant insert on table "public"."activity_shares" to "anon";

grant references on table "public"."activity_shares" to "anon";

grant select on table "public"."activity_shares" to "anon";

grant trigger on table "public"."activity_shares" to "anon";

grant truncate on table "public"."activity_shares" to "anon";

grant update on table "public"."activity_shares" to "anon";

grant delete on table "public"."activity_shares" to "authenticated";

grant insert on table "public"."activity_shares" to "authenticated";

grant references on table "public"."activity_shares" to "authenticated";

grant select on table "public"."activity_shares" to "authenticated";

grant trigger on table "public"."activity_shares" to "authenticated";

grant truncate on table "public"."activity_shares" to "authenticated";

grant update on table "public"."activity_shares" to "authenticated";

grant delete on table "public"."activity_shares" to "service_role";

grant insert on table "public"."activity_shares" to "service_role";

grant references on table "public"."activity_shares" to "service_role";

grant select on table "public"."activity_shares" to "service_role";

grant trigger on table "public"."activity_shares" to "service_role";

grant truncate on table "public"."activity_shares" to "service_role";

grant update on table "public"."activity_shares" to "service_role";

grant delete on table "public"."activity_views" to "anon";

grant insert on table "public"."activity_views" to "anon";

grant references on table "public"."activity_views" to "anon";

grant select on table "public"."activity_views" to "anon";

grant trigger on table "public"."activity_views" to "anon";

grant truncate on table "public"."activity_views" to "anon";

grant update on table "public"."activity_views" to "anon";

grant delete on table "public"."activity_views" to "authenticated";

grant insert on table "public"."activity_views" to "authenticated";

grant references on table "public"."activity_views" to "authenticated";

grant select on table "public"."activity_views" to "authenticated";

grant trigger on table "public"."activity_views" to "authenticated";

grant truncate on table "public"."activity_views" to "authenticated";

grant update on table "public"."activity_views" to "authenticated";

grant delete on table "public"."activity_views" to "service_role";

grant insert on table "public"."activity_views" to "service_role";

grant references on table "public"."activity_views" to "service_role";

grant select on table "public"."activity_views" to "service_role";

grant trigger on table "public"."activity_views" to "service_role";

grant truncate on table "public"."activity_views" to "service_role";

grant update on table "public"."activity_views" to "service_role";

grant delete on table "public"."adminLogs" to "anon";

grant insert on table "public"."adminLogs" to "anon";

grant references on table "public"."adminLogs" to "anon";

grant select on table "public"."adminLogs" to "anon";

grant trigger on table "public"."adminLogs" to "anon";

grant truncate on table "public"."adminLogs" to "anon";

grant update on table "public"."adminLogs" to "anon";

grant delete on table "public"."adminLogs" to "authenticated";

grant insert on table "public"."adminLogs" to "authenticated";

grant references on table "public"."adminLogs" to "authenticated";

grant select on table "public"."adminLogs" to "authenticated";

grant trigger on table "public"."adminLogs" to "authenticated";

grant truncate on table "public"."adminLogs" to "authenticated";

grant update on table "public"."adminLogs" to "authenticated";

grant delete on table "public"."adminLogs" to "service_role";

grant insert on table "public"."adminLogs" to "service_role";

grant references on table "public"."adminLogs" to "service_role";

grant select on table "public"."adminLogs" to "service_role";

grant trigger on table "public"."adminLogs" to "service_role";

grant truncate on table "public"."adminLogs" to "service_role";

grant update on table "public"."adminLogs" to "service_role";

grant delete on table "public"."admin_access_emails" to "anon";

grant insert on table "public"."admin_access_emails" to "anon";

grant references on table "public"."admin_access_emails" to "anon";

grant select on table "public"."admin_access_emails" to "anon";

grant trigger on table "public"."admin_access_emails" to "anon";

grant truncate on table "public"."admin_access_emails" to "anon";

grant update on table "public"."admin_access_emails" to "anon";

grant delete on table "public"."admin_access_emails" to "authenticated";

grant insert on table "public"."admin_access_emails" to "authenticated";

grant references on table "public"."admin_access_emails" to "authenticated";

grant select on table "public"."admin_access_emails" to "authenticated";

grant trigger on table "public"."admin_access_emails" to "authenticated";

grant truncate on table "public"."admin_access_emails" to "authenticated";

grant update on table "public"."admin_access_emails" to "authenticated";

grant delete on table "public"."admin_access_emails" to "service_role";

grant insert on table "public"."admin_access_emails" to "service_role";

grant references on table "public"."admin_access_emails" to "service_role";

grant select on table "public"."admin_access_emails" to "service_role";

grant trigger on table "public"."admin_access_emails" to "service_role";

grant truncate on table "public"."admin_access_emails" to "service_role";

grant update on table "public"."admin_access_emails" to "service_role";

grant delete on table "public"."api_keys" to "anon";

grant insert on table "public"."api_keys" to "anon";

grant references on table "public"."api_keys" to "anon";

grant select on table "public"."api_keys" to "anon";

grant trigger on table "public"."api_keys" to "anon";

grant truncate on table "public"."api_keys" to "anon";

grant update on table "public"."api_keys" to "anon";

grant delete on table "public"."api_keys" to "authenticated";

grant insert on table "public"."api_keys" to "authenticated";

grant references on table "public"."api_keys" to "authenticated";

grant select on table "public"."api_keys" to "authenticated";

grant trigger on table "public"."api_keys" to "authenticated";

grant truncate on table "public"."api_keys" to "authenticated";

grant update on table "public"."api_keys" to "authenticated";

grant delete on table "public"."api_keys" to "service_role";

grant insert on table "public"."api_keys" to "service_role";

grant references on table "public"."api_keys" to "service_role";

grant select on table "public"."api_keys" to "service_role";

grant trigger on table "public"."api_keys" to "service_role";

grant truncate on table "public"."api_keys" to "service_role";

grant update on table "public"."api_keys" to "service_role";

grant delete on table "public"."availability" to "anon";

grant insert on table "public"."availability" to "anon";

grant references on table "public"."availability" to "anon";

grant select on table "public"."availability" to "anon";

grant trigger on table "public"."availability" to "anon";

grant truncate on table "public"."availability" to "anon";

grant update on table "public"."availability" to "anon";

grant delete on table "public"."availability" to "authenticated";

grant insert on table "public"."availability" to "authenticated";

grant references on table "public"."availability" to "authenticated";

grant select on table "public"."availability" to "authenticated";

grant trigger on table "public"."availability" to "authenticated";

grant truncate on table "public"."availability" to "authenticated";

grant update on table "public"."availability" to "authenticated";

grant delete on table "public"."availability" to "service_role";

grant insert on table "public"."availability" to "service_role";

grant references on table "public"."availability" to "service_role";

grant select on table "public"."availability" to "service_role";

grant trigger on table "public"."availability" to "service_role";

grant truncate on table "public"."availability" to "service_role";

grant update on table "public"."availability" to "service_role";

grant delete on table "public"."availability_slots" to "anon";

grant insert on table "public"."availability_slots" to "anon";

grant references on table "public"."availability_slots" to "anon";

grant select on table "public"."availability_slots" to "anon";

grant trigger on table "public"."availability_slots" to "anon";

grant truncate on table "public"."availability_slots" to "anon";

grant update on table "public"."availability_slots" to "anon";

grant delete on table "public"."availability_slots" to "authenticated";

grant insert on table "public"."availability_slots" to "authenticated";

grant references on table "public"."availability_slots" to "authenticated";

grant select on table "public"."availability_slots" to "authenticated";

grant trigger on table "public"."availability_slots" to "authenticated";

grant truncate on table "public"."availability_slots" to "authenticated";

grant update on table "public"."availability_slots" to "authenticated";

grant delete on table "public"."availability_slots" to "service_role";

grant insert on table "public"."availability_slots" to "service_role";

grant references on table "public"."availability_slots" to "service_role";

grant select on table "public"."availability_slots" to "service_role";

grant trigger on table "public"."availability_slots" to "service_role";

grant truncate on table "public"."availability_slots" to "service_role";

grant update on table "public"."availability_slots" to "service_role";

grant delete on table "public"."blocked_dates" to "anon";

grant insert on table "public"."blocked_dates" to "anon";

grant references on table "public"."blocked_dates" to "anon";

grant select on table "public"."blocked_dates" to "anon";

grant trigger on table "public"."blocked_dates" to "anon";

grant truncate on table "public"."blocked_dates" to "anon";

grant update on table "public"."blocked_dates" to "anon";

grant delete on table "public"."blocked_dates" to "authenticated";

grant insert on table "public"."blocked_dates" to "authenticated";

grant references on table "public"."blocked_dates" to "authenticated";

grant select on table "public"."blocked_dates" to "authenticated";

grant trigger on table "public"."blocked_dates" to "authenticated";

grant truncate on table "public"."blocked_dates" to "authenticated";

grant update on table "public"."blocked_dates" to "authenticated";

grant delete on table "public"."blocked_dates" to "service_role";

grant insert on table "public"."blocked_dates" to "service_role";

grant references on table "public"."blocked_dates" to "service_role";

grant select on table "public"."blocked_dates" to "service_role";

grant trigger on table "public"."blocked_dates" to "service_role";

grant truncate on table "public"."blocked_dates" to "service_role";

grant update on table "public"."blocked_dates" to "service_role";

grant delete on table "public"."bookingBouncers" to "anon";

grant insert on table "public"."bookingBouncers" to "anon";

grant references on table "public"."bookingBouncers" to "anon";

grant select on table "public"."bookingBouncers" to "anon";

grant trigger on table "public"."bookingBouncers" to "anon";

grant truncate on table "public"."bookingBouncers" to "anon";

grant update on table "public"."bookingBouncers" to "anon";

grant delete on table "public"."bookingBouncers" to "authenticated";

grant insert on table "public"."bookingBouncers" to "authenticated";

grant references on table "public"."bookingBouncers" to "authenticated";

grant select on table "public"."bookingBouncers" to "authenticated";

grant trigger on table "public"."bookingBouncers" to "authenticated";

grant truncate on table "public"."bookingBouncers" to "authenticated";

grant update on table "public"."bookingBouncers" to "authenticated";

grant delete on table "public"."bookingBouncers" to "service_role";

grant insert on table "public"."bookingBouncers" to "service_role";

grant references on table "public"."bookingBouncers" to "service_role";

grant select on table "public"."bookingBouncers" to "service_role";

grant trigger on table "public"."bookingBouncers" to "service_role";

grant truncate on table "public"."bookingBouncers" to "service_role";

grant update on table "public"."bookingBouncers" to "service_role";

grant delete on table "public"."booking_review_audit_log" to "anon";

grant insert on table "public"."booking_review_audit_log" to "anon";

grant references on table "public"."booking_review_audit_log" to "anon";

grant select on table "public"."booking_review_audit_log" to "anon";

grant trigger on table "public"."booking_review_audit_log" to "anon";

grant truncate on table "public"."booking_review_audit_log" to "anon";

grant update on table "public"."booking_review_audit_log" to "anon";

grant delete on table "public"."booking_review_audit_log" to "authenticated";

grant insert on table "public"."booking_review_audit_log" to "authenticated";

grant references on table "public"."booking_review_audit_log" to "authenticated";

grant select on table "public"."booking_review_audit_log" to "authenticated";

grant trigger on table "public"."booking_review_audit_log" to "authenticated";

grant truncate on table "public"."booking_review_audit_log" to "authenticated";

grant update on table "public"."booking_review_audit_log" to "authenticated";

grant delete on table "public"."booking_review_audit_log" to "service_role";

grant insert on table "public"."booking_review_audit_log" to "service_role";

grant references on table "public"."booking_review_audit_log" to "service_role";

grant select on table "public"."booking_review_audit_log" to "service_role";

grant trigger on table "public"."booking_review_audit_log" to "service_role";

grant truncate on table "public"."booking_review_audit_log" to "service_role";

grant update on table "public"."booking_review_audit_log" to "service_role";

grant delete on table "public"."booking_review_flags" to "anon";

grant insert on table "public"."booking_review_flags" to "anon";

grant references on table "public"."booking_review_flags" to "anon";

grant select on table "public"."booking_review_flags" to "anon";

grant trigger on table "public"."booking_review_flags" to "anon";

grant truncate on table "public"."booking_review_flags" to "anon";

grant update on table "public"."booking_review_flags" to "anon";

grant delete on table "public"."booking_review_flags" to "authenticated";

grant insert on table "public"."booking_review_flags" to "authenticated";

grant references on table "public"."booking_review_flags" to "authenticated";

grant select on table "public"."booking_review_flags" to "authenticated";

grant trigger on table "public"."booking_review_flags" to "authenticated";

grant truncate on table "public"."booking_review_flags" to "authenticated";

grant update on table "public"."booking_review_flags" to "authenticated";

grant delete on table "public"."booking_review_flags" to "service_role";

grant insert on table "public"."booking_review_flags" to "service_role";

grant references on table "public"."booking_review_flags" to "service_role";

grant select on table "public"."booking_review_flags" to "service_role";

grant trigger on table "public"."booking_review_flags" to "service_role";

grant truncate on table "public"."booking_review_flags" to "service_role";

grant update on table "public"."booking_review_flags" to "service_role";

grant delete on table "public"."booking_review_helpful_votes" to "anon";

grant insert on table "public"."booking_review_helpful_votes" to "anon";

grant references on table "public"."booking_review_helpful_votes" to "anon";

grant select on table "public"."booking_review_helpful_votes" to "anon";

grant trigger on table "public"."booking_review_helpful_votes" to "anon";

grant truncate on table "public"."booking_review_helpful_votes" to "anon";

grant update on table "public"."booking_review_helpful_votes" to "anon";

grant delete on table "public"."booking_review_helpful_votes" to "authenticated";

grant insert on table "public"."booking_review_helpful_votes" to "authenticated";

grant references on table "public"."booking_review_helpful_votes" to "authenticated";

grant select on table "public"."booking_review_helpful_votes" to "authenticated";

grant trigger on table "public"."booking_review_helpful_votes" to "authenticated";

grant truncate on table "public"."booking_review_helpful_votes" to "authenticated";

grant update on table "public"."booking_review_helpful_votes" to "authenticated";

grant delete on table "public"."booking_review_helpful_votes" to "service_role";

grant insert on table "public"."booking_review_helpful_votes" to "service_role";

grant references on table "public"."booking_review_helpful_votes" to "service_role";

grant select on table "public"."booking_review_helpful_votes" to "service_role";

grant trigger on table "public"."booking_review_helpful_votes" to "service_role";

grant truncate on table "public"."booking_review_helpful_votes" to "service_role";

grant update on table "public"."booking_review_helpful_votes" to "service_role";

grant delete on table "public"."booking_review_media" to "anon";

grant insert on table "public"."booking_review_media" to "anon";

grant references on table "public"."booking_review_media" to "anon";

grant select on table "public"."booking_review_media" to "anon";

grant trigger on table "public"."booking_review_media" to "anon";

grant truncate on table "public"."booking_review_media" to "anon";

grant update on table "public"."booking_review_media" to "anon";

grant delete on table "public"."booking_review_media" to "authenticated";

grant insert on table "public"."booking_review_media" to "authenticated";

grant references on table "public"."booking_review_media" to "authenticated";

grant select on table "public"."booking_review_media" to "authenticated";

grant trigger on table "public"."booking_review_media" to "authenticated";

grant truncate on table "public"."booking_review_media" to "authenticated";

grant update on table "public"."booking_review_media" to "authenticated";

grant delete on table "public"."booking_review_media" to "service_role";

grant insert on table "public"."booking_review_media" to "service_role";

grant references on table "public"."booking_review_media" to "service_role";

grant select on table "public"."booking_review_media" to "service_role";

grant trigger on table "public"."booking_review_media" to "service_role";

grant truncate on table "public"."booking_review_media" to "service_role";

grant update on table "public"."booking_review_media" to "service_role";

grant delete on table "public"."booking_review_responses" to "anon";

grant insert on table "public"."booking_review_responses" to "anon";

grant references on table "public"."booking_review_responses" to "anon";

grant select on table "public"."booking_review_responses" to "anon";

grant trigger on table "public"."booking_review_responses" to "anon";

grant truncate on table "public"."booking_review_responses" to "anon";

grant update on table "public"."booking_review_responses" to "anon";

grant delete on table "public"."booking_review_responses" to "authenticated";

grant insert on table "public"."booking_review_responses" to "authenticated";

grant references on table "public"."booking_review_responses" to "authenticated";

grant select on table "public"."booking_review_responses" to "authenticated";

grant trigger on table "public"."booking_review_responses" to "authenticated";

grant truncate on table "public"."booking_review_responses" to "authenticated";

grant update on table "public"."booking_review_responses" to "authenticated";

grant delete on table "public"."booking_review_responses" to "service_role";

grant insert on table "public"."booking_review_responses" to "service_role";

grant references on table "public"."booking_review_responses" to "service_role";

grant select on table "public"."booking_review_responses" to "service_role";

grant trigger on table "public"."booking_review_responses" to "service_role";

grant truncate on table "public"."booking_review_responses" to "service_role";

grant update on table "public"."booking_review_responses" to "service_role";

grant delete on table "public"."booking_reviews" to "anon";

grant insert on table "public"."booking_reviews" to "anon";

grant references on table "public"."booking_reviews" to "anon";

grant select on table "public"."booking_reviews" to "anon";

grant trigger on table "public"."booking_reviews" to "anon";

grant truncate on table "public"."booking_reviews" to "anon";

grant update on table "public"."booking_reviews" to "anon";

grant delete on table "public"."booking_reviews" to "authenticated";

grant insert on table "public"."booking_reviews" to "authenticated";

grant references on table "public"."booking_reviews" to "authenticated";

grant select on table "public"."booking_reviews" to "authenticated";

grant trigger on table "public"."booking_reviews" to "authenticated";

grant truncate on table "public"."booking_reviews" to "authenticated";

grant update on table "public"."booking_reviews" to "authenticated";

grant delete on table "public"."booking_reviews" to "service_role";

grant insert on table "public"."booking_reviews" to "service_role";

grant references on table "public"."booking_reviews" to "service_role";

grant select on table "public"."booking_reviews" to "service_role";

grant trigger on table "public"."booking_reviews" to "service_role";

grant truncate on table "public"."booking_reviews" to "service_role";

grant update on table "public"."booking_reviews" to "service_role";

grant delete on table "public"."booking_status_history" to "anon";

grant insert on table "public"."booking_status_history" to "anon";

grant references on table "public"."booking_status_history" to "anon";

grant select on table "public"."booking_status_history" to "anon";

grant trigger on table "public"."booking_status_history" to "anon";

grant truncate on table "public"."booking_status_history" to "anon";

grant update on table "public"."booking_status_history" to "anon";

grant delete on table "public"."booking_status_history" to "authenticated";

grant insert on table "public"."booking_status_history" to "authenticated";

grant references on table "public"."booking_status_history" to "authenticated";

grant select on table "public"."booking_status_history" to "authenticated";

grant trigger on table "public"."booking_status_history" to "authenticated";

grant truncate on table "public"."booking_status_history" to "authenticated";

grant update on table "public"."booking_status_history" to "authenticated";

grant delete on table "public"."booking_status_history" to "service_role";

grant insert on table "public"."booking_status_history" to "service_role";

grant references on table "public"."booking_status_history" to "service_role";

grant select on table "public"."booking_status_history" to "service_role";

grant trigger on table "public"."booking_status_history" to "service_role";

grant truncate on table "public"."booking_status_history" to "service_role";

grant update on table "public"."booking_status_history" to "service_role";

grant delete on table "public"."bookings" to "anon";

grant insert on table "public"."bookings" to "anon";

grant references on table "public"."bookings" to "anon";

grant select on table "public"."bookings" to "anon";

grant trigger on table "public"."bookings" to "anon";

grant truncate on table "public"."bookings" to "anon";

grant update on table "public"."bookings" to "anon";

grant delete on table "public"."bookings" to "authenticated";

grant insert on table "public"."bookings" to "authenticated";

grant references on table "public"."bookings" to "authenticated";

grant select on table "public"."bookings" to "authenticated";

grant trigger on table "public"."bookings" to "authenticated";

grant truncate on table "public"."bookings" to "authenticated";

grant update on table "public"."bookings" to "authenticated";

grant delete on table "public"."bookings" to "service_role";

grant insert on table "public"."bookings" to "service_role";

grant references on table "public"."bookings" to "service_role";

grant select on table "public"."bookings" to "service_role";

grant trigger on table "public"."bookings" to "service_role";

grant truncate on table "public"."bookings" to "service_role";

grant update on table "public"."bookings" to "service_role";

grant delete on table "public"."bookings_v2" to "anon";

grant insert on table "public"."bookings_v2" to "anon";

grant references on table "public"."bookings_v2" to "anon";

grant select on table "public"."bookings_v2" to "anon";

grant trigger on table "public"."bookings_v2" to "anon";

grant truncate on table "public"."bookings_v2" to "anon";

grant update on table "public"."bookings_v2" to "anon";

grant delete on table "public"."bookings_v2" to "authenticated";

grant insert on table "public"."bookings_v2" to "authenticated";

grant references on table "public"."bookings_v2" to "authenticated";

grant select on table "public"."bookings_v2" to "authenticated";

grant trigger on table "public"."bookings_v2" to "authenticated";

grant truncate on table "public"."bookings_v2" to "authenticated";

grant update on table "public"."bookings_v2" to "authenticated";

grant delete on table "public"."bookings_v2" to "service_role";

grant insert on table "public"."bookings_v2" to "service_role";

grant references on table "public"."bookings_v2" to "service_role";

grant select on table "public"."bookings_v2" to "service_role";

grant trigger on table "public"."bookings_v2" to "service_role";

grant truncate on table "public"."bookings_v2" to "service_role";

grant update on table "public"."bookings_v2" to "service_role";

grant delete on table "public"."bouncer_services" to "anon";

grant insert on table "public"."bouncer_services" to "anon";

grant references on table "public"."bouncer_services" to "anon";

grant select on table "public"."bouncer_services" to "anon";

grant trigger on table "public"."bouncer_services" to "anon";

grant truncate on table "public"."bouncer_services" to "anon";

grant update on table "public"."bouncer_services" to "anon";

grant delete on table "public"."bouncer_services" to "authenticated";

grant insert on table "public"."bouncer_services" to "authenticated";

grant references on table "public"."bouncer_services" to "authenticated";

grant select on table "public"."bouncer_services" to "authenticated";

grant trigger on table "public"."bouncer_services" to "authenticated";

grant truncate on table "public"."bouncer_services" to "authenticated";

grant update on table "public"."bouncer_services" to "authenticated";

grant delete on table "public"."bouncer_services" to "service_role";

grant insert on table "public"."bouncer_services" to "service_role";

grant references on table "public"."bouncer_services" to "service_role";

grant select on table "public"."bouncer_services" to "service_role";

grant trigger on table "public"."bouncer_services" to "service_role";

grant truncate on table "public"."bouncer_services" to "service_role";

grant update on table "public"."bouncer_services" to "service_role";

grant delete on table "public"."bud_api_keys" to "anon";

grant insert on table "public"."bud_api_keys" to "anon";

grant references on table "public"."bud_api_keys" to "anon";

grant select on table "public"."bud_api_keys" to "anon";

grant trigger on table "public"."bud_api_keys" to "anon";

grant truncate on table "public"."bud_api_keys" to "anon";

grant update on table "public"."bud_api_keys" to "anon";

grant delete on table "public"."bud_api_keys" to "authenticated";

grant insert on table "public"."bud_api_keys" to "authenticated";

grant references on table "public"."bud_api_keys" to "authenticated";

grant select on table "public"."bud_api_keys" to "authenticated";

grant trigger on table "public"."bud_api_keys" to "authenticated";

grant truncate on table "public"."bud_api_keys" to "authenticated";

grant update on table "public"."bud_api_keys" to "authenticated";

grant delete on table "public"."bud_api_keys" to "service_role";

grant insert on table "public"."bud_api_keys" to "service_role";

grant references on table "public"."bud_api_keys" to "service_role";

grant select on table "public"."bud_api_keys" to "service_role";

grant trigger on table "public"."bud_api_keys" to "service_role";

grant truncate on table "public"."bud_api_keys" to "service_role";

grant update on table "public"."bud_api_keys" to "service_role";

grant delete on table "public"."bud_conversations" to "anon";

grant insert on table "public"."bud_conversations" to "anon";

grant references on table "public"."bud_conversations" to "anon";

grant select on table "public"."bud_conversations" to "anon";

grant trigger on table "public"."bud_conversations" to "anon";

grant truncate on table "public"."bud_conversations" to "anon";

grant update on table "public"."bud_conversations" to "anon";

grant delete on table "public"."bud_conversations" to "authenticated";

grant insert on table "public"."bud_conversations" to "authenticated";

grant references on table "public"."bud_conversations" to "authenticated";

grant select on table "public"."bud_conversations" to "authenticated";

grant trigger on table "public"."bud_conversations" to "authenticated";

grant truncate on table "public"."bud_conversations" to "authenticated";

grant update on table "public"."bud_conversations" to "authenticated";

grant delete on table "public"."bud_conversations" to "service_role";

grant insert on table "public"."bud_conversations" to "service_role";

grant references on table "public"."bud_conversations" to "service_role";

grant select on table "public"."bud_conversations" to "service_role";

grant trigger on table "public"."bud_conversations" to "service_role";

grant truncate on table "public"."bud_conversations" to "service_role";

grant update on table "public"."bud_conversations" to "service_role";

grant delete on table "public"."bud_conversations_v2" to "anon";

grant insert on table "public"."bud_conversations_v2" to "anon";

grant references on table "public"."bud_conversations_v2" to "anon";

grant select on table "public"."bud_conversations_v2" to "anon";

grant trigger on table "public"."bud_conversations_v2" to "anon";

grant truncate on table "public"."bud_conversations_v2" to "anon";

grant update on table "public"."bud_conversations_v2" to "anon";

grant delete on table "public"."bud_conversations_v2" to "authenticated";

grant insert on table "public"."bud_conversations_v2" to "authenticated";

grant references on table "public"."bud_conversations_v2" to "authenticated";

grant select on table "public"."bud_conversations_v2" to "authenticated";

grant trigger on table "public"."bud_conversations_v2" to "authenticated";

grant truncate on table "public"."bud_conversations_v2" to "authenticated";

grant update on table "public"."bud_conversations_v2" to "authenticated";

grant delete on table "public"."bud_conversations_v2" to "service_role";

grant insert on table "public"."bud_conversations_v2" to "service_role";

grant references on table "public"."bud_conversations_v2" to "service_role";

grant select on table "public"."bud_conversations_v2" to "service_role";

grant trigger on table "public"."bud_conversations_v2" to "service_role";

grant truncate on table "public"."bud_conversations_v2" to "service_role";

grant update on table "public"."bud_conversations_v2" to "service_role";

grant delete on table "public"."call_ice_candidates" to "anon";

grant insert on table "public"."call_ice_candidates" to "anon";

grant references on table "public"."call_ice_candidates" to "anon";

grant select on table "public"."call_ice_candidates" to "anon";

grant trigger on table "public"."call_ice_candidates" to "anon";

grant truncate on table "public"."call_ice_candidates" to "anon";

grant update on table "public"."call_ice_candidates" to "anon";

grant delete on table "public"."call_ice_candidates" to "authenticated";

grant insert on table "public"."call_ice_candidates" to "authenticated";

grant references on table "public"."call_ice_candidates" to "authenticated";

grant select on table "public"."call_ice_candidates" to "authenticated";

grant trigger on table "public"."call_ice_candidates" to "authenticated";

grant truncate on table "public"."call_ice_candidates" to "authenticated";

grant update on table "public"."call_ice_candidates" to "authenticated";

grant delete on table "public"."call_ice_candidates" to "service_role";

grant insert on table "public"."call_ice_candidates" to "service_role";

grant references on table "public"."call_ice_candidates" to "service_role";

grant select on table "public"."call_ice_candidates" to "service_role";

grant trigger on table "public"."call_ice_candidates" to "service_role";

grant truncate on table "public"."call_ice_candidates" to "service_role";

grant update on table "public"."call_ice_candidates" to "service_role";

grant delete on table "public"."call_logs" to "anon";

grant insert on table "public"."call_logs" to "anon";

grant references on table "public"."call_logs" to "anon";

grant select on table "public"."call_logs" to "anon";

grant trigger on table "public"."call_logs" to "anon";

grant truncate on table "public"."call_logs" to "anon";

grant update on table "public"."call_logs" to "anon";

grant delete on table "public"."call_logs" to "authenticated";

grant insert on table "public"."call_logs" to "authenticated";

grant references on table "public"."call_logs" to "authenticated";

grant select on table "public"."call_logs" to "authenticated";

grant trigger on table "public"."call_logs" to "authenticated";

grant truncate on table "public"."call_logs" to "authenticated";

grant update on table "public"."call_logs" to "authenticated";

grant delete on table "public"."call_logs" to "service_role";

grant insert on table "public"."call_logs" to "service_role";

grant references on table "public"."call_logs" to "service_role";

grant select on table "public"."call_logs" to "service_role";

grant trigger on table "public"."call_logs" to "service_role";

grant truncate on table "public"."call_logs" to "service_role";

grant update on table "public"."call_logs" to "service_role";

grant delete on table "public"."call_transcripts" to "anon";

grant insert on table "public"."call_transcripts" to "anon";

grant references on table "public"."call_transcripts" to "anon";

grant select on table "public"."call_transcripts" to "anon";

grant trigger on table "public"."call_transcripts" to "anon";

grant truncate on table "public"."call_transcripts" to "anon";

grant update on table "public"."call_transcripts" to "anon";

grant delete on table "public"."call_transcripts" to "authenticated";

grant insert on table "public"."call_transcripts" to "authenticated";

grant references on table "public"."call_transcripts" to "authenticated";

grant select on table "public"."call_transcripts" to "authenticated";

grant trigger on table "public"."call_transcripts" to "authenticated";

grant truncate on table "public"."call_transcripts" to "authenticated";

grant update on table "public"."call_transcripts" to "authenticated";

grant delete on table "public"."call_transcripts" to "service_role";

grant insert on table "public"."call_transcripts" to "service_role";

grant references on table "public"."call_transcripts" to "service_role";

grant select on table "public"."call_transcripts" to "service_role";

grant trigger on table "public"."call_transcripts" to "service_role";

grant truncate on table "public"."call_transcripts" to "service_role";

grant update on table "public"."call_transcripts" to "service_role";

grant delete on table "public"."campaigns" to "anon";

grant insert on table "public"."campaigns" to "anon";

grant references on table "public"."campaigns" to "anon";

grant select on table "public"."campaigns" to "anon";

grant trigger on table "public"."campaigns" to "anon";

grant truncate on table "public"."campaigns" to "anon";

grant update on table "public"."campaigns" to "anon";

grant delete on table "public"."campaigns" to "authenticated";

grant insert on table "public"."campaigns" to "authenticated";

grant references on table "public"."campaigns" to "authenticated";

grant select on table "public"."campaigns" to "authenticated";

grant trigger on table "public"."campaigns" to "authenticated";

grant truncate on table "public"."campaigns" to "authenticated";

grant update on table "public"."campaigns" to "authenticated";

grant delete on table "public"."campaigns" to "service_role";

grant insert on table "public"."campaigns" to "service_role";

grant references on table "public"."campaigns" to "service_role";

grant select on table "public"."campaigns" to "service_role";

grant trigger on table "public"."campaigns" to "service_role";

grant truncate on table "public"."campaigns" to "service_role";

grant update on table "public"."campaigns" to "service_role";

grant delete on table "public"."cc_activities" to "anon";

grant insert on table "public"."cc_activities" to "anon";

grant references on table "public"."cc_activities" to "anon";

grant select on table "public"."cc_activities" to "anon";

grant trigger on table "public"."cc_activities" to "anon";

grant truncate on table "public"."cc_activities" to "anon";

grant update on table "public"."cc_activities" to "anon";

grant delete on table "public"."cc_activities" to "authenticated";

grant insert on table "public"."cc_activities" to "authenticated";

grant references on table "public"."cc_activities" to "authenticated";

grant select on table "public"."cc_activities" to "authenticated";

grant trigger on table "public"."cc_activities" to "authenticated";

grant truncate on table "public"."cc_activities" to "authenticated";

grant update on table "public"."cc_activities" to "authenticated";

grant delete on table "public"."cc_activities" to "service_role";

grant insert on table "public"."cc_activities" to "service_role";

grant references on table "public"."cc_activities" to "service_role";

grant select on table "public"."cc_activities" to "service_role";

grant trigger on table "public"."cc_activities" to "service_role";

grant truncate on table "public"."cc_activities" to "service_role";

grant update on table "public"."cc_activities" to "service_role";

grant delete on table "public"."cc_activity_attendance" to "anon";

grant insert on table "public"."cc_activity_attendance" to "anon";

grant references on table "public"."cc_activity_attendance" to "anon";

grant select on table "public"."cc_activity_attendance" to "anon";

grant trigger on table "public"."cc_activity_attendance" to "anon";

grant truncate on table "public"."cc_activity_attendance" to "anon";

grant update on table "public"."cc_activity_attendance" to "anon";

grant delete on table "public"."cc_activity_attendance" to "authenticated";

grant insert on table "public"."cc_activity_attendance" to "authenticated";

grant references on table "public"."cc_activity_attendance" to "authenticated";

grant select on table "public"."cc_activity_attendance" to "authenticated";

grant trigger on table "public"."cc_activity_attendance" to "authenticated";

grant truncate on table "public"."cc_activity_attendance" to "authenticated";

grant update on table "public"."cc_activity_attendance" to "authenticated";

grant delete on table "public"."cc_activity_attendance" to "service_role";

grant insert on table "public"."cc_activity_attendance" to "service_role";

grant references on table "public"."cc_activity_attendance" to "service_role";

grant select on table "public"."cc_activity_attendance" to "service_role";

grant trigger on table "public"."cc_activity_attendance" to "service_role";

grant truncate on table "public"."cc_activity_attendance" to "service_role";

grant update on table "public"."cc_activity_attendance" to "service_role";

grant delete on table "public"."cc_activity_templates" to "anon";

grant insert on table "public"."cc_activity_templates" to "anon";

grant references on table "public"."cc_activity_templates" to "anon";

grant select on table "public"."cc_activity_templates" to "anon";

grant trigger on table "public"."cc_activity_templates" to "anon";

grant truncate on table "public"."cc_activity_templates" to "anon";

grant update on table "public"."cc_activity_templates" to "anon";

grant delete on table "public"."cc_activity_templates" to "authenticated";

grant insert on table "public"."cc_activity_templates" to "authenticated";

grant references on table "public"."cc_activity_templates" to "authenticated";

grant select on table "public"."cc_activity_templates" to "authenticated";

grant trigger on table "public"."cc_activity_templates" to "authenticated";

grant truncate on table "public"."cc_activity_templates" to "authenticated";

grant update on table "public"."cc_activity_templates" to "authenticated";

grant delete on table "public"."cc_activity_templates" to "service_role";

grant insert on table "public"."cc_activity_templates" to "service_role";

grant references on table "public"."cc_activity_templates" to "service_role";

grant select on table "public"."cc_activity_templates" to "service_role";

grant trigger on table "public"."cc_activity_templates" to "service_role";

grant truncate on table "public"."cc_activity_templates" to "service_role";

grant update on table "public"."cc_activity_templates" to "service_role";

grant delete on table "public"."cc_admin_users" to "anon";

grant insert on table "public"."cc_admin_users" to "anon";

grant references on table "public"."cc_admin_users" to "anon";

grant select on table "public"."cc_admin_users" to "anon";

grant trigger on table "public"."cc_admin_users" to "anon";

grant truncate on table "public"."cc_admin_users" to "anon";

grant update on table "public"."cc_admin_users" to "anon";

grant delete on table "public"."cc_admin_users" to "authenticated";

grant insert on table "public"."cc_admin_users" to "authenticated";

grant references on table "public"."cc_admin_users" to "authenticated";

grant select on table "public"."cc_admin_users" to "authenticated";

grant trigger on table "public"."cc_admin_users" to "authenticated";

grant truncate on table "public"."cc_admin_users" to "authenticated";

grant update on table "public"."cc_admin_users" to "authenticated";

grant delete on table "public"."cc_admin_users" to "service_role";

grant insert on table "public"."cc_admin_users" to "service_role";

grant references on table "public"."cc_admin_users" to "service_role";

grant select on table "public"."cc_admin_users" to "service_role";

grant trigger on table "public"."cc_admin_users" to "service_role";

grant truncate on table "public"."cc_admin_users" to "service_role";

grant update on table "public"."cc_admin_users" to "service_role";

grant delete on table "public"."cc_audit_log" to "anon";

grant insert on table "public"."cc_audit_log" to "anon";

grant references on table "public"."cc_audit_log" to "anon";

grant select on table "public"."cc_audit_log" to "anon";

grant trigger on table "public"."cc_audit_log" to "anon";

grant truncate on table "public"."cc_audit_log" to "anon";

grant update on table "public"."cc_audit_log" to "anon";

grant delete on table "public"."cc_audit_log" to "authenticated";

grant insert on table "public"."cc_audit_log" to "authenticated";

grant references on table "public"."cc_audit_log" to "authenticated";

grant select on table "public"."cc_audit_log" to "authenticated";

grant trigger on table "public"."cc_audit_log" to "authenticated";

grant truncate on table "public"."cc_audit_log" to "authenticated";

grant update on table "public"."cc_audit_log" to "authenticated";

grant delete on table "public"."cc_audit_log" to "service_role";

grant insert on table "public"."cc_audit_log" to "service_role";

grant references on table "public"."cc_audit_log" to "service_role";

grant select on table "public"."cc_audit_log" to "service_role";

grant trigger on table "public"."cc_audit_log" to "service_role";

grant truncate on table "public"."cc_audit_log" to "service_role";

grant update on table "public"."cc_audit_log" to "service_role";

grant delete on table "public"."cc_billing_info" to "anon";

grant insert on table "public"."cc_billing_info" to "anon";

grant references on table "public"."cc_billing_info" to "anon";

grant select on table "public"."cc_billing_info" to "anon";

grant trigger on table "public"."cc_billing_info" to "anon";

grant truncate on table "public"."cc_billing_info" to "anon";

grant update on table "public"."cc_billing_info" to "anon";

grant delete on table "public"."cc_billing_info" to "authenticated";

grant insert on table "public"."cc_billing_info" to "authenticated";

grant references on table "public"."cc_billing_info" to "authenticated";

grant select on table "public"."cc_billing_info" to "authenticated";

grant trigger on table "public"."cc_billing_info" to "authenticated";

grant truncate on table "public"."cc_billing_info" to "authenticated";

grant update on table "public"."cc_billing_info" to "authenticated";

grant delete on table "public"."cc_billing_info" to "service_role";

grant insert on table "public"."cc_billing_info" to "service_role";

grant references on table "public"."cc_billing_info" to "service_role";

grant select on table "public"."cc_billing_info" to "service_role";

grant trigger on table "public"."cc_billing_info" to "service_role";

grant truncate on table "public"."cc_billing_info" to "service_role";

grant update on table "public"."cc_billing_info" to "service_role";

grant delete on table "public"."cc_companion_assignments" to "anon";

grant insert on table "public"."cc_companion_assignments" to "anon";

grant references on table "public"."cc_companion_assignments" to "anon";

grant select on table "public"."cc_companion_assignments" to "anon";

grant trigger on table "public"."cc_companion_assignments" to "anon";

grant truncate on table "public"."cc_companion_assignments" to "anon";

grant update on table "public"."cc_companion_assignments" to "anon";

grant delete on table "public"."cc_companion_assignments" to "authenticated";

grant insert on table "public"."cc_companion_assignments" to "authenticated";

grant references on table "public"."cc_companion_assignments" to "authenticated";

grant select on table "public"."cc_companion_assignments" to "authenticated";

grant trigger on table "public"."cc_companion_assignments" to "authenticated";

grant truncate on table "public"."cc_companion_assignments" to "authenticated";

grant update on table "public"."cc_companion_assignments" to "authenticated";

grant delete on table "public"."cc_companion_assignments" to "service_role";

grant insert on table "public"."cc_companion_assignments" to "service_role";

grant references on table "public"."cc_companion_assignments" to "service_role";

grant select on table "public"."cc_companion_assignments" to "service_role";

grant trigger on table "public"."cc_companion_assignments" to "service_role";

grant truncate on table "public"."cc_companion_assignments" to "service_role";

grant update on table "public"."cc_companion_assignments" to "service_role";

grant delete on table "public"."cc_companion_bookings" to "anon";

grant insert on table "public"."cc_companion_bookings" to "anon";

grant references on table "public"."cc_companion_bookings" to "anon";

grant select on table "public"."cc_companion_bookings" to "anon";

grant trigger on table "public"."cc_companion_bookings" to "anon";

grant truncate on table "public"."cc_companion_bookings" to "anon";

grant update on table "public"."cc_companion_bookings" to "anon";

grant delete on table "public"."cc_companion_bookings" to "authenticated";

grant insert on table "public"."cc_companion_bookings" to "authenticated";

grant references on table "public"."cc_companion_bookings" to "authenticated";

grant select on table "public"."cc_companion_bookings" to "authenticated";

grant trigger on table "public"."cc_companion_bookings" to "authenticated";

grant truncate on table "public"."cc_companion_bookings" to "authenticated";

grant update on table "public"."cc_companion_bookings" to "authenticated";

grant delete on table "public"."cc_companion_bookings" to "service_role";

grant insert on table "public"."cc_companion_bookings" to "service_role";

grant references on table "public"."cc_companion_bookings" to "service_role";

grant select on table "public"."cc_companion_bookings" to "service_role";

grant trigger on table "public"."cc_companion_bookings" to "service_role";

grant truncate on table "public"."cc_companion_bookings" to "service_role";

grant update on table "public"."cc_companion_bookings" to "service_role";

grant delete on table "public"."cc_companions" to "anon";

grant insert on table "public"."cc_companions" to "anon";

grant references on table "public"."cc_companions" to "anon";

grant select on table "public"."cc_companions" to "anon";

grant trigger on table "public"."cc_companions" to "anon";

grant truncate on table "public"."cc_companions" to "anon";

grant update on table "public"."cc_companions" to "anon";

grant delete on table "public"."cc_companions" to "authenticated";

grant insert on table "public"."cc_companions" to "authenticated";

grant references on table "public"."cc_companions" to "authenticated";

grant select on table "public"."cc_companions" to "authenticated";

grant trigger on table "public"."cc_companions" to "authenticated";

grant truncate on table "public"."cc_companions" to "authenticated";

grant update on table "public"."cc_companions" to "authenticated";

grant delete on table "public"."cc_companions" to "service_role";

grant insert on table "public"."cc_companions" to "service_role";

grant references on table "public"."cc_companions" to "service_role";

grant select on table "public"."cc_companions" to "service_role";

grant trigger on table "public"."cc_companions" to "service_role";

grant truncate on table "public"."cc_companions" to "service_role";

grant update on table "public"."cc_companions" to "service_role";

grant delete on table "public"."cc_facilities" to "anon";

grant insert on table "public"."cc_facilities" to "anon";

grant references on table "public"."cc_facilities" to "anon";

grant select on table "public"."cc_facilities" to "anon";

grant trigger on table "public"."cc_facilities" to "anon";

grant truncate on table "public"."cc_facilities" to "anon";

grant update on table "public"."cc_facilities" to "anon";

grant delete on table "public"."cc_facilities" to "authenticated";

grant insert on table "public"."cc_facilities" to "authenticated";

grant references on table "public"."cc_facilities" to "authenticated";

grant select on table "public"."cc_facilities" to "authenticated";

grant trigger on table "public"."cc_facilities" to "authenticated";

grant truncate on table "public"."cc_facilities" to "authenticated";

grant update on table "public"."cc_facilities" to "authenticated";

grant delete on table "public"."cc_facilities" to "service_role";

grant insert on table "public"."cc_facilities" to "service_role";

grant references on table "public"."cc_facilities" to "service_role";

grant select on table "public"."cc_facilities" to "service_role";

grant trigger on table "public"."cc_facilities" to "service_role";

grant truncate on table "public"."cc_facilities" to "service_role";

grant update on table "public"."cc_facilities" to "service_role";

grant delete on table "public"."cc_facility_members" to "anon";

grant insert on table "public"."cc_facility_members" to "anon";

grant references on table "public"."cc_facility_members" to "anon";

grant select on table "public"."cc_facility_members" to "anon";

grant trigger on table "public"."cc_facility_members" to "anon";

grant truncate on table "public"."cc_facility_members" to "anon";

grant update on table "public"."cc_facility_members" to "anon";

grant delete on table "public"."cc_facility_members" to "authenticated";

grant insert on table "public"."cc_facility_members" to "authenticated";

grant references on table "public"."cc_facility_members" to "authenticated";

grant select on table "public"."cc_facility_members" to "authenticated";

grant trigger on table "public"."cc_facility_members" to "authenticated";

grant truncate on table "public"."cc_facility_members" to "authenticated";

grant update on table "public"."cc_facility_members" to "authenticated";

grant delete on table "public"."cc_facility_members" to "service_role";

grant insert on table "public"."cc_facility_members" to "service_role";

grant references on table "public"."cc_facility_members" to "service_role";

grant select on table "public"."cc_facility_members" to "service_role";

grant trigger on table "public"."cc_facility_members" to "service_role";

grant truncate on table "public"."cc_facility_members" to "service_role";

grant update on table "public"."cc_facility_members" to "service_role";

grant delete on table "public"."cc_family_connections" to "anon";

grant insert on table "public"."cc_family_connections" to "anon";

grant references on table "public"."cc_family_connections" to "anon";

grant select on table "public"."cc_family_connections" to "anon";

grant trigger on table "public"."cc_family_connections" to "anon";

grant truncate on table "public"."cc_family_connections" to "anon";

grant update on table "public"."cc_family_connections" to "anon";

grant delete on table "public"."cc_family_connections" to "authenticated";

grant insert on table "public"."cc_family_connections" to "authenticated";

grant references on table "public"."cc_family_connections" to "authenticated";

grant select on table "public"."cc_family_connections" to "authenticated";

grant trigger on table "public"."cc_family_connections" to "authenticated";

grant truncate on table "public"."cc_family_connections" to "authenticated";

grant update on table "public"."cc_family_connections" to "authenticated";

grant delete on table "public"."cc_family_connections" to "service_role";

grant insert on table "public"."cc_family_connections" to "service_role";

grant references on table "public"."cc_family_connections" to "service_role";

grant select on table "public"."cc_family_connections" to "service_role";

grant trigger on table "public"."cc_family_connections" to "service_role";

grant truncate on table "public"."cc_family_connections" to "service_role";

grant update on table "public"."cc_family_connections" to "service_role";

grant delete on table "public"."cc_family_members" to "anon";

grant insert on table "public"."cc_family_members" to "anon";

grant references on table "public"."cc_family_members" to "anon";

grant select on table "public"."cc_family_members" to "anon";

grant trigger on table "public"."cc_family_members" to "anon";

grant truncate on table "public"."cc_family_members" to "anon";

grant update on table "public"."cc_family_members" to "anon";

grant delete on table "public"."cc_family_members" to "authenticated";

grant insert on table "public"."cc_family_members" to "authenticated";

grant references on table "public"."cc_family_members" to "authenticated";

grant select on table "public"."cc_family_members" to "authenticated";

grant trigger on table "public"."cc_family_members" to "authenticated";

grant truncate on table "public"."cc_family_members" to "authenticated";

grant update on table "public"."cc_family_members" to "authenticated";

grant delete on table "public"."cc_family_members" to "service_role";

grant insert on table "public"."cc_family_members" to "service_role";

grant references on table "public"."cc_family_members" to "service_role";

grant select on table "public"."cc_family_members" to "service_role";

grant trigger on table "public"."cc_family_members" to "service_role";

grant truncate on table "public"."cc_family_members" to "service_role";

grant update on table "public"."cc_family_members" to "service_role";

grant delete on table "public"."cc_family_messages" to "anon";

grant insert on table "public"."cc_family_messages" to "anon";

grant references on table "public"."cc_family_messages" to "anon";

grant select on table "public"."cc_family_messages" to "anon";

grant trigger on table "public"."cc_family_messages" to "anon";

grant truncate on table "public"."cc_family_messages" to "anon";

grant update on table "public"."cc_family_messages" to "anon";

grant delete on table "public"."cc_family_messages" to "authenticated";

grant insert on table "public"."cc_family_messages" to "authenticated";

grant references on table "public"."cc_family_messages" to "authenticated";

grant select on table "public"."cc_family_messages" to "authenticated";

grant trigger on table "public"."cc_family_messages" to "authenticated";

grant truncate on table "public"."cc_family_messages" to "authenticated";

grant update on table "public"."cc_family_messages" to "authenticated";

grant delete on table "public"."cc_family_messages" to "service_role";

grant insert on table "public"."cc_family_messages" to "service_role";

grant references on table "public"."cc_family_messages" to "service_role";

grant select on table "public"."cc_family_messages" to "service_role";

grant trigger on table "public"."cc_family_messages" to "service_role";

grant truncate on table "public"."cc_family_messages" to "service_role";

grant update on table "public"."cc_family_messages" to "service_role";

grant delete on table "public"."cc_family_users" to "anon";

grant insert on table "public"."cc_family_users" to "anon";

grant references on table "public"."cc_family_users" to "anon";

grant select on table "public"."cc_family_users" to "anon";

grant trigger on table "public"."cc_family_users" to "anon";

grant truncate on table "public"."cc_family_users" to "anon";

grant update on table "public"."cc_family_users" to "anon";

grant delete on table "public"."cc_family_users" to "authenticated";

grant insert on table "public"."cc_family_users" to "authenticated";

grant references on table "public"."cc_family_users" to "authenticated";

grant select on table "public"."cc_family_users" to "authenticated";

grant trigger on table "public"."cc_family_users" to "authenticated";

grant truncate on table "public"."cc_family_users" to "authenticated";

grant update on table "public"."cc_family_users" to "authenticated";

grant delete on table "public"."cc_family_users" to "service_role";

grant insert on table "public"."cc_family_users" to "service_role";

grant references on table "public"."cc_family_users" to "service_role";

grant select on table "public"."cc_family_users" to "service_role";

grant trigger on table "public"."cc_family_users" to "service_role";

grant truncate on table "public"."cc_family_users" to "service_role";

grant update on table "public"."cc_family_users" to "service_role";

grant delete on table "public"."cc_marketplace_companions" to "anon";

grant insert on table "public"."cc_marketplace_companions" to "anon";

grant references on table "public"."cc_marketplace_companions" to "anon";

grant select on table "public"."cc_marketplace_companions" to "anon";

grant trigger on table "public"."cc_marketplace_companions" to "anon";

grant truncate on table "public"."cc_marketplace_companions" to "anon";

grant update on table "public"."cc_marketplace_companions" to "anon";

grant delete on table "public"."cc_marketplace_companions" to "authenticated";

grant insert on table "public"."cc_marketplace_companions" to "authenticated";

grant references on table "public"."cc_marketplace_companions" to "authenticated";

grant select on table "public"."cc_marketplace_companions" to "authenticated";

grant trigger on table "public"."cc_marketplace_companions" to "authenticated";

grant truncate on table "public"."cc_marketplace_companions" to "authenticated";

grant update on table "public"."cc_marketplace_companions" to "authenticated";

grant delete on table "public"."cc_marketplace_companions" to "service_role";

grant insert on table "public"."cc_marketplace_companions" to "service_role";

grant references on table "public"."cc_marketplace_companions" to "service_role";

grant select on table "public"."cc_marketplace_companions" to "service_role";

grant trigger on table "public"."cc_marketplace_companions" to "service_role";

grant truncate on table "public"."cc_marketplace_companions" to "service_role";

grant update on table "public"."cc_marketplace_companions" to "service_role";

grant delete on table "public"."cc_messages" to "anon";

grant insert on table "public"."cc_messages" to "anon";

grant references on table "public"."cc_messages" to "anon";

grant select on table "public"."cc_messages" to "anon";

grant trigger on table "public"."cc_messages" to "anon";

grant truncate on table "public"."cc_messages" to "anon";

grant update on table "public"."cc_messages" to "anon";

grant delete on table "public"."cc_messages" to "authenticated";

grant insert on table "public"."cc_messages" to "authenticated";

grant references on table "public"."cc_messages" to "authenticated";

grant select on table "public"."cc_messages" to "authenticated";

grant trigger on table "public"."cc_messages" to "authenticated";

grant truncate on table "public"."cc_messages" to "authenticated";

grant update on table "public"."cc_messages" to "authenticated";

grant delete on table "public"."cc_messages" to "service_role";

grant insert on table "public"."cc_messages" to "service_role";

grant references on table "public"."cc_messages" to "service_role";

grant select on table "public"."cc_messages" to "service_role";

grant trigger on table "public"."cc_messages" to "service_role";

grant truncate on table "public"."cc_messages" to "service_role";

grant update on table "public"."cc_messages" to "service_role";

grant delete on table "public"."cc_mood_checkins" to "anon";

grant insert on table "public"."cc_mood_checkins" to "anon";

grant references on table "public"."cc_mood_checkins" to "anon";

grant select on table "public"."cc_mood_checkins" to "anon";

grant trigger on table "public"."cc_mood_checkins" to "anon";

grant truncate on table "public"."cc_mood_checkins" to "anon";

grant update on table "public"."cc_mood_checkins" to "anon";

grant delete on table "public"."cc_mood_checkins" to "authenticated";

grant insert on table "public"."cc_mood_checkins" to "authenticated";

grant references on table "public"."cc_mood_checkins" to "authenticated";

grant select on table "public"."cc_mood_checkins" to "authenticated";

grant trigger on table "public"."cc_mood_checkins" to "authenticated";

grant truncate on table "public"."cc_mood_checkins" to "authenticated";

grant update on table "public"."cc_mood_checkins" to "authenticated";

grant delete on table "public"."cc_mood_checkins" to "service_role";

grant insert on table "public"."cc_mood_checkins" to "service_role";

grant references on table "public"."cc_mood_checkins" to "service_role";

grant select on table "public"."cc_mood_checkins" to "service_role";

grant trigger on table "public"."cc_mood_checkins" to "service_role";

grant truncate on table "public"."cc_mood_checkins" to "service_role";

grant update on table "public"."cc_mood_checkins" to "service_role";

grant delete on table "public"."cc_org_users" to "anon";

grant insert on table "public"."cc_org_users" to "anon";

grant references on table "public"."cc_org_users" to "anon";

grant select on table "public"."cc_org_users" to "anon";

grant trigger on table "public"."cc_org_users" to "anon";

grant truncate on table "public"."cc_org_users" to "anon";

grant update on table "public"."cc_org_users" to "anon";

grant delete on table "public"."cc_org_users" to "authenticated";

grant insert on table "public"."cc_org_users" to "authenticated";

grant references on table "public"."cc_org_users" to "authenticated";

grant select on table "public"."cc_org_users" to "authenticated";

grant trigger on table "public"."cc_org_users" to "authenticated";

grant truncate on table "public"."cc_org_users" to "authenticated";

grant update on table "public"."cc_org_users" to "authenticated";

grant delete on table "public"."cc_org_users" to "service_role";

grant insert on table "public"."cc_org_users" to "service_role";

grant references on table "public"."cc_org_users" to "service_role";

grant select on table "public"."cc_org_users" to "service_role";

grant trigger on table "public"."cc_org_users" to "service_role";

grant truncate on table "public"."cc_org_users" to "service_role";

grant update on table "public"."cc_org_users" to "service_role";

grant delete on table "public"."cc_residents" to "anon";

grant insert on table "public"."cc_residents" to "anon";

grant references on table "public"."cc_residents" to "anon";

grant select on table "public"."cc_residents" to "anon";

grant trigger on table "public"."cc_residents" to "anon";

grant truncate on table "public"."cc_residents" to "anon";

grant update on table "public"."cc_residents" to "anon";

grant delete on table "public"."cc_residents" to "authenticated";

grant insert on table "public"."cc_residents" to "authenticated";

grant references on table "public"."cc_residents" to "authenticated";

grant select on table "public"."cc_residents" to "authenticated";

grant trigger on table "public"."cc_residents" to "authenticated";

grant truncate on table "public"."cc_residents" to "authenticated";

grant update on table "public"."cc_residents" to "authenticated";

grant delete on table "public"."cc_residents" to "service_role";

grant insert on table "public"."cc_residents" to "service_role";

grant references on table "public"."cc_residents" to "service_role";

grant select on table "public"."cc_residents" to "service_role";

grant trigger on table "public"."cc_residents" to "service_role";

grant truncate on table "public"."cc_residents" to "service_role";

grant update on table "public"."cc_residents" to "service_role";

grant delete on table "public"."cc_security_settings" to "anon";

grant insert on table "public"."cc_security_settings" to "anon";

grant references on table "public"."cc_security_settings" to "anon";

grant select on table "public"."cc_security_settings" to "anon";

grant trigger on table "public"."cc_security_settings" to "anon";

grant truncate on table "public"."cc_security_settings" to "anon";

grant update on table "public"."cc_security_settings" to "anon";

grant delete on table "public"."cc_security_settings" to "authenticated";

grant insert on table "public"."cc_security_settings" to "authenticated";

grant references on table "public"."cc_security_settings" to "authenticated";

grant select on table "public"."cc_security_settings" to "authenticated";

grant trigger on table "public"."cc_security_settings" to "authenticated";

grant truncate on table "public"."cc_security_settings" to "authenticated";

grant update on table "public"."cc_security_settings" to "authenticated";

grant delete on table "public"."cc_security_settings" to "service_role";

grant insert on table "public"."cc_security_settings" to "service_role";

grant references on table "public"."cc_security_settings" to "service_role";

grant select on table "public"."cc_security_settings" to "service_role";

grant trigger on table "public"."cc_security_settings" to "service_role";

grant truncate on table "public"."cc_security_settings" to "service_role";

grant update on table "public"."cc_security_settings" to "service_role";

grant delete on table "public"."cc_session_notes" to "anon";

grant insert on table "public"."cc_session_notes" to "anon";

grant references on table "public"."cc_session_notes" to "anon";

grant select on table "public"."cc_session_notes" to "anon";

grant trigger on table "public"."cc_session_notes" to "anon";

grant truncate on table "public"."cc_session_notes" to "anon";

grant update on table "public"."cc_session_notes" to "anon";

grant delete on table "public"."cc_session_notes" to "authenticated";

grant insert on table "public"."cc_session_notes" to "authenticated";

grant references on table "public"."cc_session_notes" to "authenticated";

grant select on table "public"."cc_session_notes" to "authenticated";

grant trigger on table "public"."cc_session_notes" to "authenticated";

grant truncate on table "public"."cc_session_notes" to "authenticated";

grant update on table "public"."cc_session_notes" to "authenticated";

grant delete on table "public"."cc_session_notes" to "service_role";

grant insert on table "public"."cc_session_notes" to "service_role";

grant references on table "public"."cc_session_notes" to "service_role";

grant select on table "public"."cc_session_notes" to "service_role";

grant trigger on table "public"."cc_session_notes" to "service_role";

grant truncate on table "public"."cc_session_notes" to "service_role";

grant update on table "public"."cc_session_notes" to "service_role";

grant delete on table "public"."cc_staff" to "anon";

grant insert on table "public"."cc_staff" to "anon";

grant references on table "public"."cc_staff" to "anon";

grant select on table "public"."cc_staff" to "anon";

grant trigger on table "public"."cc_staff" to "anon";

grant truncate on table "public"."cc_staff" to "anon";

grant update on table "public"."cc_staff" to "anon";

grant delete on table "public"."cc_staff" to "authenticated";

grant insert on table "public"."cc_staff" to "authenticated";

grant references on table "public"."cc_staff" to "authenticated";

grant select on table "public"."cc_staff" to "authenticated";

grant trigger on table "public"."cc_staff" to "authenticated";

grant truncate on table "public"."cc_staff" to "authenticated";

grant update on table "public"."cc_staff" to "authenticated";

grant delete on table "public"."cc_staff" to "service_role";

grant insert on table "public"."cc_staff" to "service_role";

grant references on table "public"."cc_staff" to "service_role";

grant select on table "public"."cc_staff" to "service_role";

grant trigger on table "public"."cc_staff" to "service_role";

grant truncate on table "public"."cc_staff" to "service_role";

grant update on table "public"."cc_staff" to "service_role";

grant delete on table "public"."companion_activities" to "anon";

grant insert on table "public"."companion_activities" to "anon";

grant references on table "public"."companion_activities" to "anon";

grant select on table "public"."companion_activities" to "anon";

grant trigger on table "public"."companion_activities" to "anon";

grant truncate on table "public"."companion_activities" to "anon";

grant update on table "public"."companion_activities" to "anon";

grant delete on table "public"."companion_activities" to "authenticated";

grant insert on table "public"."companion_activities" to "authenticated";

grant references on table "public"."companion_activities" to "authenticated";

grant select on table "public"."companion_activities" to "authenticated";

grant trigger on table "public"."companion_activities" to "authenticated";

grant truncate on table "public"."companion_activities" to "authenticated";

grant update on table "public"."companion_activities" to "authenticated";

grant delete on table "public"."companion_activities" to "service_role";

grant insert on table "public"."companion_activities" to "service_role";

grant references on table "public"."companion_activities" to "service_role";

grant select on table "public"."companion_activities" to "service_role";

grant trigger on table "public"."companion_activities" to "service_role";

grant truncate on table "public"."companion_activities" to "service_role";

grant update on table "public"."companion_activities" to "service_role";

grant delete on table "public"."companion_services" to "anon";

grant insert on table "public"."companion_services" to "anon";

grant references on table "public"."companion_services" to "anon";

grant select on table "public"."companion_services" to "anon";

grant trigger on table "public"."companion_services" to "anon";

grant truncate on table "public"."companion_services" to "anon";

grant update on table "public"."companion_services" to "anon";

grant delete on table "public"."companion_services" to "authenticated";

grant insert on table "public"."companion_services" to "authenticated";

grant references on table "public"."companion_services" to "authenticated";

grant select on table "public"."companion_services" to "authenticated";

grant trigger on table "public"."companion_services" to "authenticated";

grant truncate on table "public"."companion_services" to "authenticated";

grant update on table "public"."companion_services" to "authenticated";

grant delete on table "public"."companion_services" to "service_role";

grant insert on table "public"."companion_services" to "service_role";

grant references on table "public"."companion_services" to "service_role";

grant select on table "public"."companion_services" to "service_role";

grant trigger on table "public"."companion_services" to "service_role";

grant truncate on table "public"."companion_services" to "service_role";

grant update on table "public"."companion_services" to "service_role";

grant delete on table "public"."companions" to "anon";

grant insert on table "public"."companions" to "anon";

grant references on table "public"."companions" to "anon";

grant select on table "public"."companions" to "anon";

grant trigger on table "public"."companions" to "anon";

grant truncate on table "public"."companions" to "anon";

grant update on table "public"."companions" to "anon";

grant delete on table "public"."companions" to "authenticated";

grant insert on table "public"."companions" to "authenticated";

grant references on table "public"."companions" to "authenticated";

grant select on table "public"."companions" to "authenticated";

grant trigger on table "public"."companions" to "authenticated";

grant truncate on table "public"."companions" to "authenticated";

grant update on table "public"."companions" to "authenticated";

grant delete on table "public"."companions" to "service_role";

grant insert on table "public"."companions" to "service_role";

grant references on table "public"."companions" to "service_role";

grant select on table "public"."companions" to "service_role";

grant trigger on table "public"."companions" to "service_role";

grant truncate on table "public"."companions" to "service_role";

grant update on table "public"."companions" to "service_role";

grant delete on table "public"."companions_v2" to "anon";

grant insert on table "public"."companions_v2" to "anon";

grant references on table "public"."companions_v2" to "anon";

grant select on table "public"."companions_v2" to "anon";

grant trigger on table "public"."companions_v2" to "anon";

grant truncate on table "public"."companions_v2" to "anon";

grant update on table "public"."companions_v2" to "anon";

grant delete on table "public"."companions_v2" to "authenticated";

grant insert on table "public"."companions_v2" to "authenticated";

grant references on table "public"."companions_v2" to "authenticated";

grant select on table "public"."companions_v2" to "authenticated";

grant trigger on table "public"."companions_v2" to "authenticated";

grant truncate on table "public"."companions_v2" to "authenticated";

grant update on table "public"."companions_v2" to "authenticated";

grant delete on table "public"."companions_v2" to "service_role";

grant insert on table "public"."companions_v2" to "service_role";

grant references on table "public"."companions_v2" to "service_role";

grant select on table "public"."companions_v2" to "service_role";

grant trigger on table "public"."companions_v2" to "service_role";

grant truncate on table "public"."companions_v2" to "service_role";

grant update on table "public"."companions_v2" to "service_role";

grant delete on table "public"."conversations" to "anon";

grant insert on table "public"."conversations" to "anon";

grant references on table "public"."conversations" to "anon";

grant select on table "public"."conversations" to "anon";

grant trigger on table "public"."conversations" to "anon";

grant truncate on table "public"."conversations" to "anon";

grant update on table "public"."conversations" to "anon";

grant delete on table "public"."conversations" to "authenticated";

grant insert on table "public"."conversations" to "authenticated";

grant references on table "public"."conversations" to "authenticated";

grant select on table "public"."conversations" to "authenticated";

grant trigger on table "public"."conversations" to "authenticated";

grant truncate on table "public"."conversations" to "authenticated";

grant update on table "public"."conversations" to "authenticated";

grant delete on table "public"."conversations" to "service_role";

grant insert on table "public"."conversations" to "service_role";

grant references on table "public"."conversations" to "service_role";

grant select on table "public"."conversations" to "service_role";

grant trigger on table "public"."conversations" to "service_role";

grant truncate on table "public"."conversations" to "service_role";

grant update on table "public"."conversations" to "service_role";

grant delete on table "public"."ct_admissions" to "anon";

grant insert on table "public"."ct_admissions" to "anon";

grant references on table "public"."ct_admissions" to "anon";

grant select on table "public"."ct_admissions" to "anon";

grant trigger on table "public"."ct_admissions" to "anon";

grant truncate on table "public"."ct_admissions" to "anon";

grant update on table "public"."ct_admissions" to "anon";

grant delete on table "public"."ct_admissions" to "authenticated";

grant insert on table "public"."ct_admissions" to "authenticated";

grant references on table "public"."ct_admissions" to "authenticated";

grant select on table "public"."ct_admissions" to "authenticated";

grant trigger on table "public"."ct_admissions" to "authenticated";

grant truncate on table "public"."ct_admissions" to "authenticated";

grant update on table "public"."ct_admissions" to "authenticated";

grant delete on table "public"."ct_admissions" to "service_role";

grant insert on table "public"."ct_admissions" to "service_role";

grant references on table "public"."ct_admissions" to "service_role";

grant select on table "public"."ct_admissions" to "service_role";

grant trigger on table "public"."ct_admissions" to "service_role";

grant truncate on table "public"."ct_admissions" to "service_role";

grant update on table "public"."ct_admissions" to "service_role";

grant delete on table "public"."ct_ai_insights" to "anon";

grant insert on table "public"."ct_ai_insights" to "anon";

grant references on table "public"."ct_ai_insights" to "anon";

grant select on table "public"."ct_ai_insights" to "anon";

grant trigger on table "public"."ct_ai_insights" to "anon";

grant truncate on table "public"."ct_ai_insights" to "anon";

grant update on table "public"."ct_ai_insights" to "anon";

grant delete on table "public"."ct_ai_insights" to "authenticated";

grant insert on table "public"."ct_ai_insights" to "authenticated";

grant references on table "public"."ct_ai_insights" to "authenticated";

grant select on table "public"."ct_ai_insights" to "authenticated";

grant trigger on table "public"."ct_ai_insights" to "authenticated";

grant truncate on table "public"."ct_ai_insights" to "authenticated";

grant update on table "public"."ct_ai_insights" to "authenticated";

grant delete on table "public"."ct_ai_insights" to "service_role";

grant insert on table "public"."ct_ai_insights" to "service_role";

grant references on table "public"."ct_ai_insights" to "service_role";

grant select on table "public"."ct_ai_insights" to "service_role";

grant trigger on table "public"."ct_ai_insights" to "service_role";

grant truncate on table "public"."ct_ai_insights" to "service_role";

grant update on table "public"."ct_ai_insights" to "service_role";

grant delete on table "public"."ct_announcements" to "anon";

grant insert on table "public"."ct_announcements" to "anon";

grant references on table "public"."ct_announcements" to "anon";

grant select on table "public"."ct_announcements" to "anon";

grant trigger on table "public"."ct_announcements" to "anon";

grant truncate on table "public"."ct_announcements" to "anon";

grant update on table "public"."ct_announcements" to "anon";

grant delete on table "public"."ct_announcements" to "authenticated";

grant insert on table "public"."ct_announcements" to "authenticated";

grant references on table "public"."ct_announcements" to "authenticated";

grant select on table "public"."ct_announcements" to "authenticated";

grant trigger on table "public"."ct_announcements" to "authenticated";

grant truncate on table "public"."ct_announcements" to "authenticated";

grant update on table "public"."ct_announcements" to "authenticated";

grant delete on table "public"."ct_announcements" to "service_role";

grant insert on table "public"."ct_announcements" to "service_role";

grant references on table "public"."ct_announcements" to "service_role";

grant select on table "public"."ct_announcements" to "service_role";

grant trigger on table "public"."ct_announcements" to "service_role";

grant truncate on table "public"."ct_announcements" to "service_role";

grant update on table "public"."ct_announcements" to "service_role";

grant delete on table "public"."ct_api_keys" to "anon";

grant insert on table "public"."ct_api_keys" to "anon";

grant references on table "public"."ct_api_keys" to "anon";

grant select on table "public"."ct_api_keys" to "anon";

grant trigger on table "public"."ct_api_keys" to "anon";

grant truncate on table "public"."ct_api_keys" to "anon";

grant update on table "public"."ct_api_keys" to "anon";

grant delete on table "public"."ct_api_keys" to "authenticated";

grant insert on table "public"."ct_api_keys" to "authenticated";

grant references on table "public"."ct_api_keys" to "authenticated";

grant select on table "public"."ct_api_keys" to "authenticated";

grant trigger on table "public"."ct_api_keys" to "authenticated";

grant truncate on table "public"."ct_api_keys" to "authenticated";

grant update on table "public"."ct_api_keys" to "authenticated";

grant delete on table "public"."ct_api_keys" to "service_role";

grant insert on table "public"."ct_api_keys" to "service_role";

grant references on table "public"."ct_api_keys" to "service_role";

grant select on table "public"."ct_api_keys" to "service_role";

grant trigger on table "public"."ct_api_keys" to "service_role";

grant truncate on table "public"."ct_api_keys" to "service_role";

grant update on table "public"."ct_api_keys" to "service_role";

grant delete on table "public"."ct_assignment_documents" to "anon";

grant insert on table "public"."ct_assignment_documents" to "anon";

grant references on table "public"."ct_assignment_documents" to "anon";

grant select on table "public"."ct_assignment_documents" to "anon";

grant trigger on table "public"."ct_assignment_documents" to "anon";

grant truncate on table "public"."ct_assignment_documents" to "anon";

grant update on table "public"."ct_assignment_documents" to "anon";

grant delete on table "public"."ct_assignment_documents" to "authenticated";

grant insert on table "public"."ct_assignment_documents" to "authenticated";

grant references on table "public"."ct_assignment_documents" to "authenticated";

grant select on table "public"."ct_assignment_documents" to "authenticated";

grant trigger on table "public"."ct_assignment_documents" to "authenticated";

grant truncate on table "public"."ct_assignment_documents" to "authenticated";

grant update on table "public"."ct_assignment_documents" to "authenticated";

grant delete on table "public"."ct_assignment_documents" to "service_role";

grant insert on table "public"."ct_assignment_documents" to "service_role";

grant references on table "public"."ct_assignment_documents" to "service_role";

grant select on table "public"."ct_assignment_documents" to "service_role";

grant trigger on table "public"."ct_assignment_documents" to "service_role";

grant truncate on table "public"."ct_assignment_documents" to "service_role";

grant update on table "public"."ct_assignment_documents" to "service_role";

grant delete on table "public"."ct_assignment_submissions" to "anon";

grant insert on table "public"."ct_assignment_submissions" to "anon";

grant references on table "public"."ct_assignment_submissions" to "anon";

grant select on table "public"."ct_assignment_submissions" to "anon";

grant trigger on table "public"."ct_assignment_submissions" to "anon";

grant truncate on table "public"."ct_assignment_submissions" to "anon";

grant update on table "public"."ct_assignment_submissions" to "anon";

grant delete on table "public"."ct_assignment_submissions" to "authenticated";

grant insert on table "public"."ct_assignment_submissions" to "authenticated";

grant references on table "public"."ct_assignment_submissions" to "authenticated";

grant select on table "public"."ct_assignment_submissions" to "authenticated";

grant trigger on table "public"."ct_assignment_submissions" to "authenticated";

grant truncate on table "public"."ct_assignment_submissions" to "authenticated";

grant update on table "public"."ct_assignment_submissions" to "authenticated";

grant delete on table "public"."ct_assignment_submissions" to "service_role";

grant insert on table "public"."ct_assignment_submissions" to "service_role";

grant references on table "public"."ct_assignment_submissions" to "service_role";

grant select on table "public"."ct_assignment_submissions" to "service_role";

grant trigger on table "public"."ct_assignment_submissions" to "service_role";

grant truncate on table "public"."ct_assignment_submissions" to "service_role";

grant update on table "public"."ct_assignment_submissions" to "service_role";

grant delete on table "public"."ct_assignments" to "anon";

grant insert on table "public"."ct_assignments" to "anon";

grant references on table "public"."ct_assignments" to "anon";

grant select on table "public"."ct_assignments" to "anon";

grant trigger on table "public"."ct_assignments" to "anon";

grant truncate on table "public"."ct_assignments" to "anon";

grant update on table "public"."ct_assignments" to "anon";

grant delete on table "public"."ct_assignments" to "authenticated";

grant insert on table "public"."ct_assignments" to "authenticated";

grant references on table "public"."ct_assignments" to "authenticated";

grant select on table "public"."ct_assignments" to "authenticated";

grant trigger on table "public"."ct_assignments" to "authenticated";

grant truncate on table "public"."ct_assignments" to "authenticated";

grant update on table "public"."ct_assignments" to "authenticated";

grant delete on table "public"."ct_assignments" to "service_role";

grant insert on table "public"."ct_assignments" to "service_role";

grant references on table "public"."ct_assignments" to "service_role";

grant select on table "public"."ct_assignments" to "service_role";

grant trigger on table "public"."ct_assignments" to "service_role";

grant truncate on table "public"."ct_assignments" to "service_role";

grant update on table "public"."ct_assignments" to "service_role";

grant delete on table "public"."ct_athletes" to "anon";

grant insert on table "public"."ct_athletes" to "anon";

grant references on table "public"."ct_athletes" to "anon";

grant select on table "public"."ct_athletes" to "anon";

grant trigger on table "public"."ct_athletes" to "anon";

grant truncate on table "public"."ct_athletes" to "anon";

grant update on table "public"."ct_athletes" to "anon";

grant delete on table "public"."ct_athletes" to "authenticated";

grant insert on table "public"."ct_athletes" to "authenticated";

grant references on table "public"."ct_athletes" to "authenticated";

grant select on table "public"."ct_athletes" to "authenticated";

grant trigger on table "public"."ct_athletes" to "authenticated";

grant truncate on table "public"."ct_athletes" to "authenticated";

grant update on table "public"."ct_athletes" to "authenticated";

grant delete on table "public"."ct_athletes" to "service_role";

grant insert on table "public"."ct_athletes" to "service_role";

grant references on table "public"."ct_athletes" to "service_role";

grant select on table "public"."ct_athletes" to "service_role";

grant trigger on table "public"."ct_athletes" to "service_role";

grant truncate on table "public"."ct_athletes" to "service_role";

grant update on table "public"."ct_athletes" to "service_role";

grant delete on table "public"."ct_attendance" to "anon";

grant insert on table "public"."ct_attendance" to "anon";

grant references on table "public"."ct_attendance" to "anon";

grant select on table "public"."ct_attendance" to "anon";

grant trigger on table "public"."ct_attendance" to "anon";

grant truncate on table "public"."ct_attendance" to "anon";

grant update on table "public"."ct_attendance" to "anon";

grant delete on table "public"."ct_attendance" to "authenticated";

grant insert on table "public"."ct_attendance" to "authenticated";

grant references on table "public"."ct_attendance" to "authenticated";

grant select on table "public"."ct_attendance" to "authenticated";

grant trigger on table "public"."ct_attendance" to "authenticated";

grant truncate on table "public"."ct_attendance" to "authenticated";

grant update on table "public"."ct_attendance" to "authenticated";

grant delete on table "public"."ct_attendance" to "service_role";

grant insert on table "public"."ct_attendance" to "service_role";

grant references on table "public"."ct_attendance" to "service_role";

grant select on table "public"."ct_attendance" to "service_role";

grant trigger on table "public"."ct_attendance" to "service_role";

grant truncate on table "public"."ct_attendance" to "service_role";

grant update on table "public"."ct_attendance" to "service_role";

grant delete on table "public"."ct_audit_logs" to "anon";

grant insert on table "public"."ct_audit_logs" to "anon";

grant references on table "public"."ct_audit_logs" to "anon";

grant select on table "public"."ct_audit_logs" to "anon";

grant trigger on table "public"."ct_audit_logs" to "anon";

grant truncate on table "public"."ct_audit_logs" to "anon";

grant update on table "public"."ct_audit_logs" to "anon";

grant delete on table "public"."ct_audit_logs" to "authenticated";

grant insert on table "public"."ct_audit_logs" to "authenticated";

grant references on table "public"."ct_audit_logs" to "authenticated";

grant select on table "public"."ct_audit_logs" to "authenticated";

grant trigger on table "public"."ct_audit_logs" to "authenticated";

grant truncate on table "public"."ct_audit_logs" to "authenticated";

grant update on table "public"."ct_audit_logs" to "authenticated";

grant delete on table "public"."ct_audit_logs" to "service_role";

grant insert on table "public"."ct_audit_logs" to "service_role";

grant references on table "public"."ct_audit_logs" to "service_role";

grant select on table "public"."ct_audit_logs" to "service_role";

grant trigger on table "public"."ct_audit_logs" to "service_role";

grant truncate on table "public"."ct_audit_logs" to "service_role";

grant update on table "public"."ct_audit_logs" to "service_role";

grant delete on table "public"."ct_billing_invoices" to "anon";

grant insert on table "public"."ct_billing_invoices" to "anon";

grant references on table "public"."ct_billing_invoices" to "anon";

grant select on table "public"."ct_billing_invoices" to "anon";

grant trigger on table "public"."ct_billing_invoices" to "anon";

grant truncate on table "public"."ct_billing_invoices" to "anon";

grant update on table "public"."ct_billing_invoices" to "anon";

grant delete on table "public"."ct_billing_invoices" to "authenticated";

grant insert on table "public"."ct_billing_invoices" to "authenticated";

grant references on table "public"."ct_billing_invoices" to "authenticated";

grant select on table "public"."ct_billing_invoices" to "authenticated";

grant trigger on table "public"."ct_billing_invoices" to "authenticated";

grant truncate on table "public"."ct_billing_invoices" to "authenticated";

grant update on table "public"."ct_billing_invoices" to "authenticated";

grant delete on table "public"."ct_billing_invoices" to "service_role";

grant insert on table "public"."ct_billing_invoices" to "service_role";

grant references on table "public"."ct_billing_invoices" to "service_role";

grant select on table "public"."ct_billing_invoices" to "service_role";

grant trigger on table "public"."ct_billing_invoices" to "service_role";

grant truncate on table "public"."ct_billing_invoices" to "service_role";

grant update on table "public"."ct_billing_invoices" to "service_role";

grant delete on table "public"."ct_billing_plans" to "anon";

grant insert on table "public"."ct_billing_plans" to "anon";

grant references on table "public"."ct_billing_plans" to "anon";

grant select on table "public"."ct_billing_plans" to "anon";

grant trigger on table "public"."ct_billing_plans" to "anon";

grant truncate on table "public"."ct_billing_plans" to "anon";

grant update on table "public"."ct_billing_plans" to "anon";

grant delete on table "public"."ct_billing_plans" to "authenticated";

grant insert on table "public"."ct_billing_plans" to "authenticated";

grant references on table "public"."ct_billing_plans" to "authenticated";

grant select on table "public"."ct_billing_plans" to "authenticated";

grant trigger on table "public"."ct_billing_plans" to "authenticated";

grant truncate on table "public"."ct_billing_plans" to "authenticated";

grant update on table "public"."ct_billing_plans" to "authenticated";

grant delete on table "public"."ct_billing_plans" to "service_role";

grant insert on table "public"."ct_billing_plans" to "service_role";

grant references on table "public"."ct_billing_plans" to "service_role";

grant select on table "public"."ct_billing_plans" to "service_role";

grant trigger on table "public"."ct_billing_plans" to "service_role";

grant truncate on table "public"."ct_billing_plans" to "service_role";

grant update on table "public"."ct_billing_plans" to "service_role";

grant delete on table "public"."ct_blog_posts" to "anon";

grant insert on table "public"."ct_blog_posts" to "anon";

grant references on table "public"."ct_blog_posts" to "anon";

grant select on table "public"."ct_blog_posts" to "anon";

grant trigger on table "public"."ct_blog_posts" to "anon";

grant truncate on table "public"."ct_blog_posts" to "anon";

grant update on table "public"."ct_blog_posts" to "anon";

grant delete on table "public"."ct_blog_posts" to "authenticated";

grant insert on table "public"."ct_blog_posts" to "authenticated";

grant references on table "public"."ct_blog_posts" to "authenticated";

grant select on table "public"."ct_blog_posts" to "authenticated";

grant trigger on table "public"."ct_blog_posts" to "authenticated";

grant truncate on table "public"."ct_blog_posts" to "authenticated";

grant update on table "public"."ct_blog_posts" to "authenticated";

grant delete on table "public"."ct_blog_posts" to "service_role";

grant insert on table "public"."ct_blog_posts" to "service_role";

grant references on table "public"."ct_blog_posts" to "service_role";

grant select on table "public"."ct_blog_posts" to "service_role";

grant trigger on table "public"."ct_blog_posts" to "service_role";

grant truncate on table "public"."ct_blog_posts" to "service_role";

grant update on table "public"."ct_blog_posts" to "service_role";

grant delete on table "public"."ct_broadcast_notifications" to "anon";

grant insert on table "public"."ct_broadcast_notifications" to "anon";

grant references on table "public"."ct_broadcast_notifications" to "anon";

grant select on table "public"."ct_broadcast_notifications" to "anon";

grant trigger on table "public"."ct_broadcast_notifications" to "anon";

grant truncate on table "public"."ct_broadcast_notifications" to "anon";

grant update on table "public"."ct_broadcast_notifications" to "anon";

grant delete on table "public"."ct_broadcast_notifications" to "authenticated";

grant insert on table "public"."ct_broadcast_notifications" to "authenticated";

grant references on table "public"."ct_broadcast_notifications" to "authenticated";

grant select on table "public"."ct_broadcast_notifications" to "authenticated";

grant trigger on table "public"."ct_broadcast_notifications" to "authenticated";

grant truncate on table "public"."ct_broadcast_notifications" to "authenticated";

grant update on table "public"."ct_broadcast_notifications" to "authenticated";

grant delete on table "public"."ct_broadcast_notifications" to "service_role";

grant insert on table "public"."ct_broadcast_notifications" to "service_role";

grant references on table "public"."ct_broadcast_notifications" to "service_role";

grant select on table "public"."ct_broadcast_notifications" to "service_role";

grant trigger on table "public"."ct_broadcast_notifications" to "service_role";

grant truncate on table "public"."ct_broadcast_notifications" to "service_role";

grant update on table "public"."ct_broadcast_notifications" to "service_role";

grant delete on table "public"."ct_budget_items" to "anon";

grant insert on table "public"."ct_budget_items" to "anon";

grant references on table "public"."ct_budget_items" to "anon";

grant select on table "public"."ct_budget_items" to "anon";

grant trigger on table "public"."ct_budget_items" to "anon";

grant truncate on table "public"."ct_budget_items" to "anon";

grant update on table "public"."ct_budget_items" to "anon";

grant delete on table "public"."ct_budget_items" to "authenticated";

grant insert on table "public"."ct_budget_items" to "authenticated";

grant references on table "public"."ct_budget_items" to "authenticated";

grant select on table "public"."ct_budget_items" to "authenticated";

grant trigger on table "public"."ct_budget_items" to "authenticated";

grant truncate on table "public"."ct_budget_items" to "authenticated";

grant update on table "public"."ct_budget_items" to "authenticated";

grant delete on table "public"."ct_budget_items" to "service_role";

grant insert on table "public"."ct_budget_items" to "service_role";

grant references on table "public"."ct_budget_items" to "service_role";

grant select on table "public"."ct_budget_items" to "service_role";

grant trigger on table "public"."ct_budget_items" to "service_role";

grant truncate on table "public"."ct_budget_items" to "service_role";

grant update on table "public"."ct_budget_items" to "service_role";

grant delete on table "public"."ct_budgets" to "anon";

grant insert on table "public"."ct_budgets" to "anon";

grant references on table "public"."ct_budgets" to "anon";

grant select on table "public"."ct_budgets" to "anon";

grant trigger on table "public"."ct_budgets" to "anon";

grant truncate on table "public"."ct_budgets" to "anon";

grant update on table "public"."ct_budgets" to "anon";

grant delete on table "public"."ct_budgets" to "authenticated";

grant insert on table "public"."ct_budgets" to "authenticated";

grant references on table "public"."ct_budgets" to "authenticated";

grant select on table "public"."ct_budgets" to "authenticated";

grant trigger on table "public"."ct_budgets" to "authenticated";

grant truncate on table "public"."ct_budgets" to "authenticated";

grant update on table "public"."ct_budgets" to "authenticated";

grant delete on table "public"."ct_budgets" to "service_role";

grant insert on table "public"."ct_budgets" to "service_role";

grant references on table "public"."ct_budgets" to "service_role";

grant select on table "public"."ct_budgets" to "service_role";

grant trigger on table "public"."ct_budgets" to "service_role";

grant truncate on table "public"."ct_budgets" to "service_role";

grant update on table "public"."ct_budgets" to "service_role";

grant delete on table "public"."ct_challenge_entries" to "anon";

grant insert on table "public"."ct_challenge_entries" to "anon";

grant references on table "public"."ct_challenge_entries" to "anon";

grant select on table "public"."ct_challenge_entries" to "anon";

grant trigger on table "public"."ct_challenge_entries" to "anon";

grant truncate on table "public"."ct_challenge_entries" to "anon";

grant update on table "public"."ct_challenge_entries" to "anon";

grant delete on table "public"."ct_challenge_entries" to "authenticated";

grant insert on table "public"."ct_challenge_entries" to "authenticated";

grant references on table "public"."ct_challenge_entries" to "authenticated";

grant select on table "public"."ct_challenge_entries" to "authenticated";

grant trigger on table "public"."ct_challenge_entries" to "authenticated";

grant truncate on table "public"."ct_challenge_entries" to "authenticated";

grant update on table "public"."ct_challenge_entries" to "authenticated";

grant delete on table "public"."ct_challenge_entries" to "service_role";

grant insert on table "public"."ct_challenge_entries" to "service_role";

grant references on table "public"."ct_challenge_entries" to "service_role";

grant select on table "public"."ct_challenge_entries" to "service_role";

grant trigger on table "public"."ct_challenge_entries" to "service_role";

grant truncate on table "public"."ct_challenge_entries" to "service_role";

grant update on table "public"."ct_challenge_entries" to "service_role";

grant delete on table "public"."ct_challenge_scores" to "anon";

grant insert on table "public"."ct_challenge_scores" to "anon";

grant references on table "public"."ct_challenge_scores" to "anon";

grant select on table "public"."ct_challenge_scores" to "anon";

grant trigger on table "public"."ct_challenge_scores" to "anon";

grant truncate on table "public"."ct_challenge_scores" to "anon";

grant update on table "public"."ct_challenge_scores" to "anon";

grant delete on table "public"."ct_challenge_scores" to "authenticated";

grant insert on table "public"."ct_challenge_scores" to "authenticated";

grant references on table "public"."ct_challenge_scores" to "authenticated";

grant select on table "public"."ct_challenge_scores" to "authenticated";

grant trigger on table "public"."ct_challenge_scores" to "authenticated";

grant truncate on table "public"."ct_challenge_scores" to "authenticated";

grant update on table "public"."ct_challenge_scores" to "authenticated";

grant delete on table "public"."ct_challenge_scores" to "service_role";

grant insert on table "public"."ct_challenge_scores" to "service_role";

grant references on table "public"."ct_challenge_scores" to "service_role";

grant select on table "public"."ct_challenge_scores" to "service_role";

grant trigger on table "public"."ct_challenge_scores" to "service_role";

grant truncate on table "public"."ct_challenge_scores" to "service_role";

grant update on table "public"."ct_challenge_scores" to "service_role";

grant delete on table "public"."ct_children" to "anon";

grant insert on table "public"."ct_children" to "anon";

grant references on table "public"."ct_children" to "anon";

grant select on table "public"."ct_children" to "anon";

grant trigger on table "public"."ct_children" to "anon";

grant truncate on table "public"."ct_children" to "anon";

grant update on table "public"."ct_children" to "anon";

grant delete on table "public"."ct_children" to "authenticated";

grant insert on table "public"."ct_children" to "authenticated";

grant references on table "public"."ct_children" to "authenticated";

grant select on table "public"."ct_children" to "authenticated";

grant trigger on table "public"."ct_children" to "authenticated";

grant truncate on table "public"."ct_children" to "authenticated";

grant update on table "public"."ct_children" to "authenticated";

grant delete on table "public"."ct_children" to "service_role";

grant insert on table "public"."ct_children" to "service_role";

grant references on table "public"."ct_children" to "service_role";

grant select on table "public"."ct_children" to "service_role";

grant trigger on table "public"."ct_children" to "service_role";

grant truncate on table "public"."ct_children" to "service_role";

grant update on table "public"."ct_children" to "service_role";

grant delete on table "public"."ct_classes" to "anon";

grant insert on table "public"."ct_classes" to "anon";

grant references on table "public"."ct_classes" to "anon";

grant select on table "public"."ct_classes" to "anon";

grant trigger on table "public"."ct_classes" to "anon";

grant truncate on table "public"."ct_classes" to "anon";

grant update on table "public"."ct_classes" to "anon";

grant delete on table "public"."ct_classes" to "authenticated";

grant insert on table "public"."ct_classes" to "authenticated";

grant references on table "public"."ct_classes" to "authenticated";

grant select on table "public"."ct_classes" to "authenticated";

grant trigger on table "public"."ct_classes" to "authenticated";

grant truncate on table "public"."ct_classes" to "authenticated";

grant update on table "public"."ct_classes" to "authenticated";

grant delete on table "public"."ct_classes" to "service_role";

grant insert on table "public"."ct_classes" to "service_role";

grant references on table "public"."ct_classes" to "service_role";

grant select on table "public"."ct_classes" to "service_role";

grant trigger on table "public"."ct_classes" to "service_role";

grant truncate on table "public"."ct_classes" to "service_role";

grant update on table "public"."ct_classes" to "service_role";

grant delete on table "public"."ct_club_election_candidates" to "anon";

grant insert on table "public"."ct_club_election_candidates" to "anon";

grant references on table "public"."ct_club_election_candidates" to "anon";

grant select on table "public"."ct_club_election_candidates" to "anon";

grant trigger on table "public"."ct_club_election_candidates" to "anon";

grant truncate on table "public"."ct_club_election_candidates" to "anon";

grant update on table "public"."ct_club_election_candidates" to "anon";

grant delete on table "public"."ct_club_election_candidates" to "authenticated";

grant insert on table "public"."ct_club_election_candidates" to "authenticated";

grant references on table "public"."ct_club_election_candidates" to "authenticated";

grant select on table "public"."ct_club_election_candidates" to "authenticated";

grant trigger on table "public"."ct_club_election_candidates" to "authenticated";

grant truncate on table "public"."ct_club_election_candidates" to "authenticated";

grant update on table "public"."ct_club_election_candidates" to "authenticated";

grant delete on table "public"."ct_club_election_candidates" to "service_role";

grant insert on table "public"."ct_club_election_candidates" to "service_role";

grant references on table "public"."ct_club_election_candidates" to "service_role";

grant select on table "public"."ct_club_election_candidates" to "service_role";

grant trigger on table "public"."ct_club_election_candidates" to "service_role";

grant truncate on table "public"."ct_club_election_candidates" to "service_role";

grant update on table "public"."ct_club_election_candidates" to "service_role";

grant delete on table "public"."ct_club_election_votes" to "anon";

grant insert on table "public"."ct_club_election_votes" to "anon";

grant references on table "public"."ct_club_election_votes" to "anon";

grant select on table "public"."ct_club_election_votes" to "anon";

grant trigger on table "public"."ct_club_election_votes" to "anon";

grant truncate on table "public"."ct_club_election_votes" to "anon";

grant update on table "public"."ct_club_election_votes" to "anon";

grant delete on table "public"."ct_club_election_votes" to "authenticated";

grant insert on table "public"."ct_club_election_votes" to "authenticated";

grant references on table "public"."ct_club_election_votes" to "authenticated";

grant select on table "public"."ct_club_election_votes" to "authenticated";

grant trigger on table "public"."ct_club_election_votes" to "authenticated";

grant truncate on table "public"."ct_club_election_votes" to "authenticated";

grant update on table "public"."ct_club_election_votes" to "authenticated";

grant delete on table "public"."ct_club_election_votes" to "service_role";

grant insert on table "public"."ct_club_election_votes" to "service_role";

grant references on table "public"."ct_club_election_votes" to "service_role";

grant select on table "public"."ct_club_election_votes" to "service_role";

grant trigger on table "public"."ct_club_election_votes" to "service_role";

grant truncate on table "public"."ct_club_election_votes" to "service_role";

grant update on table "public"."ct_club_election_votes" to "service_role";

grant delete on table "public"."ct_club_elections" to "anon";

grant insert on table "public"."ct_club_elections" to "anon";

grant references on table "public"."ct_club_elections" to "anon";

grant select on table "public"."ct_club_elections" to "anon";

grant trigger on table "public"."ct_club_elections" to "anon";

grant truncate on table "public"."ct_club_elections" to "anon";

grant update on table "public"."ct_club_elections" to "anon";

grant delete on table "public"."ct_club_elections" to "authenticated";

grant insert on table "public"."ct_club_elections" to "authenticated";

grant references on table "public"."ct_club_elections" to "authenticated";

grant select on table "public"."ct_club_elections" to "authenticated";

grant trigger on table "public"."ct_club_elections" to "authenticated";

grant truncate on table "public"."ct_club_elections" to "authenticated";

grant update on table "public"."ct_club_elections" to "authenticated";

grant delete on table "public"."ct_club_elections" to "service_role";

grant insert on table "public"."ct_club_elections" to "service_role";

grant references on table "public"."ct_club_elections" to "service_role";

grant select on table "public"."ct_club_elections" to "service_role";

grant trigger on table "public"."ct_club_elections" to "service_role";

grant truncate on table "public"."ct_club_elections" to "service_role";

grant update on table "public"."ct_club_elections" to "service_role";

grant delete on table "public"."ct_club_events" to "anon";

grant insert on table "public"."ct_club_events" to "anon";

grant references on table "public"."ct_club_events" to "anon";

grant select on table "public"."ct_club_events" to "anon";

grant trigger on table "public"."ct_club_events" to "anon";

grant truncate on table "public"."ct_club_events" to "anon";

grant update on table "public"."ct_club_events" to "anon";

grant delete on table "public"."ct_club_events" to "authenticated";

grant insert on table "public"."ct_club_events" to "authenticated";

grant references on table "public"."ct_club_events" to "authenticated";

grant select on table "public"."ct_club_events" to "authenticated";

grant trigger on table "public"."ct_club_events" to "authenticated";

grant truncate on table "public"."ct_club_events" to "authenticated";

grant update on table "public"."ct_club_events" to "authenticated";

grant delete on table "public"."ct_club_events" to "service_role";

grant insert on table "public"."ct_club_events" to "service_role";

grant references on table "public"."ct_club_events" to "service_role";

grant select on table "public"."ct_club_events" to "service_role";

grant trigger on table "public"."ct_club_events" to "service_role";

grant truncate on table "public"."ct_club_events" to "service_role";

grant update on table "public"."ct_club_events" to "service_role";

grant delete on table "public"."ct_club_members" to "anon";

grant insert on table "public"."ct_club_members" to "anon";

grant references on table "public"."ct_club_members" to "anon";

grant select on table "public"."ct_club_members" to "anon";

grant trigger on table "public"."ct_club_members" to "anon";

grant truncate on table "public"."ct_club_members" to "anon";

grant update on table "public"."ct_club_members" to "anon";

grant delete on table "public"."ct_club_members" to "authenticated";

grant insert on table "public"."ct_club_members" to "authenticated";

grant references on table "public"."ct_club_members" to "authenticated";

grant select on table "public"."ct_club_members" to "authenticated";

grant trigger on table "public"."ct_club_members" to "authenticated";

grant truncate on table "public"."ct_club_members" to "authenticated";

grant update on table "public"."ct_club_members" to "authenticated";

grant delete on table "public"."ct_club_members" to "service_role";

grant insert on table "public"."ct_club_members" to "service_role";

grant references on table "public"."ct_club_members" to "service_role";

grant select on table "public"."ct_club_members" to "service_role";

grant trigger on table "public"."ct_club_members" to "service_role";

grant truncate on table "public"."ct_club_members" to "service_role";

grant update on table "public"."ct_club_members" to "service_role";

grant delete on table "public"."ct_club_memberships" to "anon";

grant insert on table "public"."ct_club_memberships" to "anon";

grant references on table "public"."ct_club_memberships" to "anon";

grant select on table "public"."ct_club_memberships" to "anon";

grant trigger on table "public"."ct_club_memberships" to "anon";

grant truncate on table "public"."ct_club_memberships" to "anon";

grant update on table "public"."ct_club_memberships" to "anon";

grant delete on table "public"."ct_club_memberships" to "authenticated";

grant insert on table "public"."ct_club_memberships" to "authenticated";

grant references on table "public"."ct_club_memberships" to "authenticated";

grant select on table "public"."ct_club_memberships" to "authenticated";

grant trigger on table "public"."ct_club_memberships" to "authenticated";

grant truncate on table "public"."ct_club_memberships" to "authenticated";

grant update on table "public"."ct_club_memberships" to "authenticated";

grant delete on table "public"."ct_club_memberships" to "service_role";

grant insert on table "public"."ct_club_memberships" to "service_role";

grant references on table "public"."ct_club_memberships" to "service_role";

grant select on table "public"."ct_club_memberships" to "service_role";

grant trigger on table "public"."ct_club_memberships" to "service_role";

grant truncate on table "public"."ct_club_memberships" to "service_role";

grant update on table "public"."ct_club_memberships" to "service_role";

grant delete on table "public"."ct_club_posts" to "anon";

grant insert on table "public"."ct_club_posts" to "anon";

grant references on table "public"."ct_club_posts" to "anon";

grant select on table "public"."ct_club_posts" to "anon";

grant trigger on table "public"."ct_club_posts" to "anon";

grant truncate on table "public"."ct_club_posts" to "anon";

grant update on table "public"."ct_club_posts" to "anon";

grant delete on table "public"."ct_club_posts" to "authenticated";

grant insert on table "public"."ct_club_posts" to "authenticated";

grant references on table "public"."ct_club_posts" to "authenticated";

grant select on table "public"."ct_club_posts" to "authenticated";

grant trigger on table "public"."ct_club_posts" to "authenticated";

grant truncate on table "public"."ct_club_posts" to "authenticated";

grant update on table "public"."ct_club_posts" to "authenticated";

grant delete on table "public"."ct_club_posts" to "service_role";

grant insert on table "public"."ct_club_posts" to "service_role";

grant references on table "public"."ct_club_posts" to "service_role";

grant select on table "public"."ct_club_posts" to "service_role";

grant trigger on table "public"."ct_club_posts" to "service_role";

grant truncate on table "public"."ct_club_posts" to "service_role";

grant update on table "public"."ct_club_posts" to "service_role";

grant delete on table "public"."ct_club_recognition_requests" to "anon";

grant insert on table "public"."ct_club_recognition_requests" to "anon";

grant references on table "public"."ct_club_recognition_requests" to "anon";

grant select on table "public"."ct_club_recognition_requests" to "anon";

grant trigger on table "public"."ct_club_recognition_requests" to "anon";

grant truncate on table "public"."ct_club_recognition_requests" to "anon";

grant update on table "public"."ct_club_recognition_requests" to "anon";

grant delete on table "public"."ct_club_recognition_requests" to "authenticated";

grant insert on table "public"."ct_club_recognition_requests" to "authenticated";

grant references on table "public"."ct_club_recognition_requests" to "authenticated";

grant select on table "public"."ct_club_recognition_requests" to "authenticated";

grant trigger on table "public"."ct_club_recognition_requests" to "authenticated";

grant truncate on table "public"."ct_club_recognition_requests" to "authenticated";

grant update on table "public"."ct_club_recognition_requests" to "authenticated";

grant delete on table "public"."ct_club_recognition_requests" to "service_role";

grant insert on table "public"."ct_club_recognition_requests" to "service_role";

grant references on table "public"."ct_club_recognition_requests" to "service_role";

grant select on table "public"."ct_club_recognition_requests" to "service_role";

grant trigger on table "public"."ct_club_recognition_requests" to "service_role";

grant truncate on table "public"."ct_club_recognition_requests" to "service_role";

grant update on table "public"."ct_club_recognition_requests" to "service_role";

grant delete on table "public"."ct_clubs" to "anon";

grant insert on table "public"."ct_clubs" to "anon";

grant references on table "public"."ct_clubs" to "anon";

grant select on table "public"."ct_clubs" to "anon";

grant trigger on table "public"."ct_clubs" to "anon";

grant truncate on table "public"."ct_clubs" to "anon";

grant update on table "public"."ct_clubs" to "anon";

grant delete on table "public"."ct_clubs" to "authenticated";

grant insert on table "public"."ct_clubs" to "authenticated";

grant references on table "public"."ct_clubs" to "authenticated";

grant select on table "public"."ct_clubs" to "authenticated";

grant trigger on table "public"."ct_clubs" to "authenticated";

grant truncate on table "public"."ct_clubs" to "authenticated";

grant update on table "public"."ct_clubs" to "authenticated";

grant delete on table "public"."ct_clubs" to "service_role";

grant insert on table "public"."ct_clubs" to "service_role";

grant references on table "public"."ct_clubs" to "service_role";

grant select on table "public"."ct_clubs" to "service_role";

grant trigger on table "public"."ct_clubs" to "service_role";

grant truncate on table "public"."ct_clubs" to "service_role";

grant update on table "public"."ct_clubs" to "service_role";

grant delete on table "public"."ct_course_enrollments" to "anon";

grant insert on table "public"."ct_course_enrollments" to "anon";

grant references on table "public"."ct_course_enrollments" to "anon";

grant select on table "public"."ct_course_enrollments" to "anon";

grant trigger on table "public"."ct_course_enrollments" to "anon";

grant truncate on table "public"."ct_course_enrollments" to "anon";

grant update on table "public"."ct_course_enrollments" to "anon";

grant delete on table "public"."ct_course_enrollments" to "authenticated";

grant insert on table "public"."ct_course_enrollments" to "authenticated";

grant references on table "public"."ct_course_enrollments" to "authenticated";

grant select on table "public"."ct_course_enrollments" to "authenticated";

grant trigger on table "public"."ct_course_enrollments" to "authenticated";

grant truncate on table "public"."ct_course_enrollments" to "authenticated";

grant update on table "public"."ct_course_enrollments" to "authenticated";

grant delete on table "public"."ct_course_enrollments" to "service_role";

grant insert on table "public"."ct_course_enrollments" to "service_role";

grant references on table "public"."ct_course_enrollments" to "service_role";

grant select on table "public"."ct_course_enrollments" to "service_role";

grant trigger on table "public"."ct_course_enrollments" to "service_role";

grant truncate on table "public"."ct_course_enrollments" to "service_role";

grant update on table "public"."ct_course_enrollments" to "service_role";

grant delete on table "public"."ct_courses" to "anon";

grant insert on table "public"."ct_courses" to "anon";

grant references on table "public"."ct_courses" to "anon";

grant select on table "public"."ct_courses" to "anon";

grant trigger on table "public"."ct_courses" to "anon";

grant truncate on table "public"."ct_courses" to "anon";

grant update on table "public"."ct_courses" to "anon";

grant delete on table "public"."ct_courses" to "authenticated";

grant insert on table "public"."ct_courses" to "authenticated";

grant references on table "public"."ct_courses" to "authenticated";

grant select on table "public"."ct_courses" to "authenticated";

grant trigger on table "public"."ct_courses" to "authenticated";

grant truncate on table "public"."ct_courses" to "authenticated";

grant update on table "public"."ct_courses" to "authenticated";

grant delete on table "public"."ct_courses" to "service_role";

grant insert on table "public"."ct_courses" to "service_role";

grant references on table "public"."ct_courses" to "service_role";

grant select on table "public"."ct_courses" to "service_role";

grant trigger on table "public"."ct_courses" to "service_role";

grant truncate on table "public"."ct_courses" to "service_role";

grant update on table "public"."ct_courses" to "service_role";

grant delete on table "public"."ct_daily_reports" to "anon";

grant insert on table "public"."ct_daily_reports" to "anon";

grant references on table "public"."ct_daily_reports" to "anon";

grant select on table "public"."ct_daily_reports" to "anon";

grant trigger on table "public"."ct_daily_reports" to "anon";

grant truncate on table "public"."ct_daily_reports" to "anon";

grant update on table "public"."ct_daily_reports" to "anon";

grant delete on table "public"."ct_daily_reports" to "authenticated";

grant insert on table "public"."ct_daily_reports" to "authenticated";

grant references on table "public"."ct_daily_reports" to "authenticated";

grant select on table "public"."ct_daily_reports" to "authenticated";

grant trigger on table "public"."ct_daily_reports" to "authenticated";

grant truncate on table "public"."ct_daily_reports" to "authenticated";

grant update on table "public"."ct_daily_reports" to "authenticated";

grant delete on table "public"."ct_daily_reports" to "service_role";

grant insert on table "public"."ct_daily_reports" to "service_role";

grant references on table "public"."ct_daily_reports" to "service_role";

grant select on table "public"."ct_daily_reports" to "service_role";

grant trigger on table "public"."ct_daily_reports" to "service_role";

grant truncate on table "public"."ct_daily_reports" to "service_role";

grant update on table "public"."ct_daily_reports" to "service_role";

grant delete on table "public"."ct_demo_requests" to "anon";

grant insert on table "public"."ct_demo_requests" to "anon";

grant references on table "public"."ct_demo_requests" to "anon";

grant select on table "public"."ct_demo_requests" to "anon";

grant trigger on table "public"."ct_demo_requests" to "anon";

grant truncate on table "public"."ct_demo_requests" to "anon";

grant update on table "public"."ct_demo_requests" to "anon";

grant delete on table "public"."ct_demo_requests" to "authenticated";

grant insert on table "public"."ct_demo_requests" to "authenticated";

grant references on table "public"."ct_demo_requests" to "authenticated";

grant select on table "public"."ct_demo_requests" to "authenticated";

grant trigger on table "public"."ct_demo_requests" to "authenticated";

grant truncate on table "public"."ct_demo_requests" to "authenticated";

grant update on table "public"."ct_demo_requests" to "authenticated";

grant delete on table "public"."ct_demo_requests" to "service_role";

grant insert on table "public"."ct_demo_requests" to "service_role";

grant references on table "public"."ct_demo_requests" to "service_role";

grant select on table "public"."ct_demo_requests" to "service_role";

grant trigger on table "public"."ct_demo_requests" to "service_role";

grant truncate on table "public"."ct_demo_requests" to "service_role";

grant update on table "public"."ct_demo_requests" to "service_role";

grant delete on table "public"."ct_direct_messages" to "anon";

grant insert on table "public"."ct_direct_messages" to "anon";

grant references on table "public"."ct_direct_messages" to "anon";

grant select on table "public"."ct_direct_messages" to "anon";

grant trigger on table "public"."ct_direct_messages" to "anon";

grant truncate on table "public"."ct_direct_messages" to "anon";

grant update on table "public"."ct_direct_messages" to "anon";

grant delete on table "public"."ct_direct_messages" to "authenticated";

grant insert on table "public"."ct_direct_messages" to "authenticated";

grant references on table "public"."ct_direct_messages" to "authenticated";

grant select on table "public"."ct_direct_messages" to "authenticated";

grant trigger on table "public"."ct_direct_messages" to "authenticated";

grant truncate on table "public"."ct_direct_messages" to "authenticated";

grant update on table "public"."ct_direct_messages" to "authenticated";

grant delete on table "public"."ct_direct_messages" to "service_role";

grant insert on table "public"."ct_direct_messages" to "service_role";

grant references on table "public"."ct_direct_messages" to "service_role";

grant select on table "public"."ct_direct_messages" to "service_role";

grant trigger on table "public"."ct_direct_messages" to "service_role";

grant truncate on table "public"."ct_direct_messages" to "service_role";

grant update on table "public"."ct_direct_messages" to "service_role";

grant delete on table "public"."ct_discovery_profiles" to "anon";

grant insert on table "public"."ct_discovery_profiles" to "anon";

grant references on table "public"."ct_discovery_profiles" to "anon";

grant select on table "public"."ct_discovery_profiles" to "anon";

grant trigger on table "public"."ct_discovery_profiles" to "anon";

grant truncate on table "public"."ct_discovery_profiles" to "anon";

grant update on table "public"."ct_discovery_profiles" to "anon";

grant delete on table "public"."ct_discovery_profiles" to "authenticated";

grant insert on table "public"."ct_discovery_profiles" to "authenticated";

grant references on table "public"."ct_discovery_profiles" to "authenticated";

grant select on table "public"."ct_discovery_profiles" to "authenticated";

grant trigger on table "public"."ct_discovery_profiles" to "authenticated";

grant truncate on table "public"."ct_discovery_profiles" to "authenticated";

grant update on table "public"."ct_discovery_profiles" to "authenticated";

grant delete on table "public"."ct_discovery_profiles" to "service_role";

grant insert on table "public"."ct_discovery_profiles" to "service_role";

grant references on table "public"."ct_discovery_profiles" to "service_role";

grant select on table "public"."ct_discovery_profiles" to "service_role";

grant trigger on table "public"."ct_discovery_profiles" to "service_role";

grant truncate on table "public"."ct_discovery_profiles" to "service_role";

grant update on table "public"."ct_discovery_profiles" to "service_role";

grant delete on table "public"."ct_email_rate_limits" to "anon";

grant insert on table "public"."ct_email_rate_limits" to "anon";

grant references on table "public"."ct_email_rate_limits" to "anon";

grant select on table "public"."ct_email_rate_limits" to "anon";

grant trigger on table "public"."ct_email_rate_limits" to "anon";

grant truncate on table "public"."ct_email_rate_limits" to "anon";

grant update on table "public"."ct_email_rate_limits" to "anon";

grant delete on table "public"."ct_email_rate_limits" to "authenticated";

grant insert on table "public"."ct_email_rate_limits" to "authenticated";

grant references on table "public"."ct_email_rate_limits" to "authenticated";

grant select on table "public"."ct_email_rate_limits" to "authenticated";

grant trigger on table "public"."ct_email_rate_limits" to "authenticated";

grant truncate on table "public"."ct_email_rate_limits" to "authenticated";

grant update on table "public"."ct_email_rate_limits" to "authenticated";

grant delete on table "public"."ct_email_rate_limits" to "service_role";

grant insert on table "public"."ct_email_rate_limits" to "service_role";

grant references on table "public"."ct_email_rate_limits" to "service_role";

grant select on table "public"."ct_email_rate_limits" to "service_role";

grant trigger on table "public"."ct_email_rate_limits" to "service_role";

grant truncate on table "public"."ct_email_rate_limits" to "service_role";

grant update on table "public"."ct_email_rate_limits" to "service_role";

grant delete on table "public"."ct_email_verifications" to "anon";

grant insert on table "public"."ct_email_verifications" to "anon";

grant references on table "public"."ct_email_verifications" to "anon";

grant select on table "public"."ct_email_verifications" to "anon";

grant trigger on table "public"."ct_email_verifications" to "anon";

grant truncate on table "public"."ct_email_verifications" to "anon";

grant update on table "public"."ct_email_verifications" to "anon";

grant delete on table "public"."ct_email_verifications" to "authenticated";

grant insert on table "public"."ct_email_verifications" to "authenticated";

grant references on table "public"."ct_email_verifications" to "authenticated";

grant select on table "public"."ct_email_verifications" to "authenticated";

grant trigger on table "public"."ct_email_verifications" to "authenticated";

grant truncate on table "public"."ct_email_verifications" to "authenticated";

grant update on table "public"."ct_email_verifications" to "authenticated";

grant delete on table "public"."ct_email_verifications" to "service_role";

grant insert on table "public"."ct_email_verifications" to "service_role";

grant references on table "public"."ct_email_verifications" to "service_role";

grant select on table "public"."ct_email_verifications" to "service_role";

grant trigger on table "public"."ct_email_verifications" to "service_role";

grant truncate on table "public"."ct_email_verifications" to "service_role";

grant update on table "public"."ct_email_verifications" to "service_role";

grant delete on table "public"."ct_engagement_points" to "anon";

grant insert on table "public"."ct_engagement_points" to "anon";

grant references on table "public"."ct_engagement_points" to "anon";

grant select on table "public"."ct_engagement_points" to "anon";

grant trigger on table "public"."ct_engagement_points" to "anon";

grant truncate on table "public"."ct_engagement_points" to "anon";

grant update on table "public"."ct_engagement_points" to "anon";

grant delete on table "public"."ct_engagement_points" to "authenticated";

grant insert on table "public"."ct_engagement_points" to "authenticated";

grant references on table "public"."ct_engagement_points" to "authenticated";

grant select on table "public"."ct_engagement_points" to "authenticated";

grant trigger on table "public"."ct_engagement_points" to "authenticated";

grant truncate on table "public"."ct_engagement_points" to "authenticated";

grant update on table "public"."ct_engagement_points" to "authenticated";

grant delete on table "public"."ct_engagement_points" to "service_role";

grant insert on table "public"."ct_engagement_points" to "service_role";

grant references on table "public"."ct_engagement_points" to "service_role";

grant select on table "public"."ct_engagement_points" to "service_role";

grant trigger on table "public"."ct_engagement_points" to "service_role";

grant truncate on table "public"."ct_engagement_points" to "service_role";

grant update on table "public"."ct_engagement_points" to "service_role";

grant delete on table "public"."ct_engagement_scores" to "anon";

grant insert on table "public"."ct_engagement_scores" to "anon";

grant references on table "public"."ct_engagement_scores" to "anon";

grant select on table "public"."ct_engagement_scores" to "anon";

grant trigger on table "public"."ct_engagement_scores" to "anon";

grant truncate on table "public"."ct_engagement_scores" to "anon";

grant update on table "public"."ct_engagement_scores" to "anon";

grant delete on table "public"."ct_engagement_scores" to "authenticated";

grant insert on table "public"."ct_engagement_scores" to "authenticated";

grant references on table "public"."ct_engagement_scores" to "authenticated";

grant select on table "public"."ct_engagement_scores" to "authenticated";

grant trigger on table "public"."ct_engagement_scores" to "authenticated";

grant truncate on table "public"."ct_engagement_scores" to "authenticated";

grant update on table "public"."ct_engagement_scores" to "authenticated";

grant delete on table "public"."ct_engagement_scores" to "service_role";

grant insert on table "public"."ct_engagement_scores" to "service_role";

grant references on table "public"."ct_engagement_scores" to "service_role";

grant select on table "public"."ct_engagement_scores" to "service_role";

grant trigger on table "public"."ct_engagement_scores" to "service_role";

grant truncate on table "public"."ct_engagement_scores" to "service_role";

grant update on table "public"."ct_engagement_scores" to "service_role";

grant delete on table "public"."ct_enrollments" to "anon";

grant insert on table "public"."ct_enrollments" to "anon";

grant references on table "public"."ct_enrollments" to "anon";

grant select on table "public"."ct_enrollments" to "anon";

grant trigger on table "public"."ct_enrollments" to "anon";

grant truncate on table "public"."ct_enrollments" to "anon";

grant update on table "public"."ct_enrollments" to "anon";

grant delete on table "public"."ct_enrollments" to "authenticated";

grant insert on table "public"."ct_enrollments" to "authenticated";

grant references on table "public"."ct_enrollments" to "authenticated";

grant select on table "public"."ct_enrollments" to "authenticated";

grant trigger on table "public"."ct_enrollments" to "authenticated";

grant truncate on table "public"."ct_enrollments" to "authenticated";

grant update on table "public"."ct_enrollments" to "authenticated";

grant delete on table "public"."ct_enrollments" to "service_role";

grant insert on table "public"."ct_enrollments" to "service_role";

grant references on table "public"."ct_enrollments" to "service_role";

grant select on table "public"."ct_enrollments" to "service_role";

grant trigger on table "public"."ct_enrollments" to "service_role";

grant truncate on table "public"."ct_enrollments" to "service_role";

grant update on table "public"."ct_enrollments" to "service_role";

grant delete on table "public"."ct_error_logs" to "anon";

grant insert on table "public"."ct_error_logs" to "anon";

grant references on table "public"."ct_error_logs" to "anon";

grant select on table "public"."ct_error_logs" to "anon";

grant trigger on table "public"."ct_error_logs" to "anon";

grant truncate on table "public"."ct_error_logs" to "anon";

grant update on table "public"."ct_error_logs" to "anon";

grant delete on table "public"."ct_error_logs" to "authenticated";

grant insert on table "public"."ct_error_logs" to "authenticated";

grant references on table "public"."ct_error_logs" to "authenticated";

grant select on table "public"."ct_error_logs" to "authenticated";

grant trigger on table "public"."ct_error_logs" to "authenticated";

grant truncate on table "public"."ct_error_logs" to "authenticated";

grant update on table "public"."ct_error_logs" to "authenticated";

grant delete on table "public"."ct_error_logs" to "service_role";

grant insert on table "public"."ct_error_logs" to "service_role";

grant references on table "public"."ct_error_logs" to "service_role";

grant select on table "public"."ct_error_logs" to "service_role";

grant trigger on table "public"."ct_error_logs" to "service_role";

grant truncate on table "public"."ct_error_logs" to "service_role";

grant update on table "public"."ct_error_logs" to "service_role";

grant delete on table "public"."ct_event_rsvps" to "anon";

grant insert on table "public"."ct_event_rsvps" to "anon";

grant references on table "public"."ct_event_rsvps" to "anon";

grant select on table "public"."ct_event_rsvps" to "anon";

grant trigger on table "public"."ct_event_rsvps" to "anon";

grant truncate on table "public"."ct_event_rsvps" to "anon";

grant update on table "public"."ct_event_rsvps" to "anon";

grant delete on table "public"."ct_event_rsvps" to "authenticated";

grant insert on table "public"."ct_event_rsvps" to "authenticated";

grant references on table "public"."ct_event_rsvps" to "authenticated";

grant select on table "public"."ct_event_rsvps" to "authenticated";

grant trigger on table "public"."ct_event_rsvps" to "authenticated";

grant truncate on table "public"."ct_event_rsvps" to "authenticated";

grant update on table "public"."ct_event_rsvps" to "authenticated";

grant delete on table "public"."ct_event_rsvps" to "service_role";

grant insert on table "public"."ct_event_rsvps" to "service_role";

grant references on table "public"."ct_event_rsvps" to "service_role";

grant select on table "public"."ct_event_rsvps" to "service_role";

grant trigger on table "public"."ct_event_rsvps" to "service_role";

grant truncate on table "public"."ct_event_rsvps" to "service_role";

grant update on table "public"."ct_event_rsvps" to "service_role";

grant delete on table "public"."ct_events" to "anon";

grant insert on table "public"."ct_events" to "anon";

grant references on table "public"."ct_events" to "anon";

grant select on table "public"."ct_events" to "anon";

grant trigger on table "public"."ct_events" to "anon";

grant truncate on table "public"."ct_events" to "anon";

grant update on table "public"."ct_events" to "anon";

grant delete on table "public"."ct_events" to "authenticated";

grant insert on table "public"."ct_events" to "authenticated";

grant references on table "public"."ct_events" to "authenticated";

grant select on table "public"."ct_events" to "authenticated";

grant trigger on table "public"."ct_events" to "authenticated";

grant truncate on table "public"."ct_events" to "authenticated";

grant update on table "public"."ct_events" to "authenticated";

grant delete on table "public"."ct_events" to "service_role";

grant insert on table "public"."ct_events" to "service_role";

grant references on table "public"."ct_events" to "service_role";

grant select on table "public"."ct_events" to "service_role";

grant trigger on table "public"."ct_events" to "service_role";

grant truncate on table "public"."ct_events" to "service_role";

grant update on table "public"."ct_events" to "service_role";

grant delete on table "public"."ct_feature_events" to "anon";

grant insert on table "public"."ct_feature_events" to "anon";

grant references on table "public"."ct_feature_events" to "anon";

grant select on table "public"."ct_feature_events" to "anon";

grant trigger on table "public"."ct_feature_events" to "anon";

grant truncate on table "public"."ct_feature_events" to "anon";

grant update on table "public"."ct_feature_events" to "anon";

grant delete on table "public"."ct_feature_events" to "authenticated";

grant insert on table "public"."ct_feature_events" to "authenticated";

grant references on table "public"."ct_feature_events" to "authenticated";

grant select on table "public"."ct_feature_events" to "authenticated";

grant trigger on table "public"."ct_feature_events" to "authenticated";

grant truncate on table "public"."ct_feature_events" to "authenticated";

grant update on table "public"."ct_feature_events" to "authenticated";

grant delete on table "public"."ct_feature_events" to "service_role";

grant insert on table "public"."ct_feature_events" to "service_role";

grant references on table "public"."ct_feature_events" to "service_role";

grant select on table "public"."ct_feature_events" to "service_role";

grant trigger on table "public"."ct_feature_events" to "service_role";

grant truncate on table "public"."ct_feature_events" to "service_role";

grant update on table "public"."ct_feature_events" to "service_role";

grant delete on table "public"."ct_free_trial_requests" to "anon";

grant insert on table "public"."ct_free_trial_requests" to "anon";

grant references on table "public"."ct_free_trial_requests" to "anon";

grant select on table "public"."ct_free_trial_requests" to "anon";

grant trigger on table "public"."ct_free_trial_requests" to "anon";

grant truncate on table "public"."ct_free_trial_requests" to "anon";

grant update on table "public"."ct_free_trial_requests" to "anon";

grant delete on table "public"."ct_free_trial_requests" to "authenticated";

grant insert on table "public"."ct_free_trial_requests" to "authenticated";

grant references on table "public"."ct_free_trial_requests" to "authenticated";

grant select on table "public"."ct_free_trial_requests" to "authenticated";

grant trigger on table "public"."ct_free_trial_requests" to "authenticated";

grant truncate on table "public"."ct_free_trial_requests" to "authenticated";

grant update on table "public"."ct_free_trial_requests" to "authenticated";

grant delete on table "public"."ct_free_trial_requests" to "service_role";

grant insert on table "public"."ct_free_trial_requests" to "service_role";

grant references on table "public"."ct_free_trial_requests" to "service_role";

grant select on table "public"."ct_free_trial_requests" to "service_role";

grant trigger on table "public"."ct_free_trial_requests" to "service_role";

grant truncate on table "public"."ct_free_trial_requests" to "service_role";

grant update on table "public"."ct_free_trial_requests" to "service_role";

grant delete on table "public"."ct_funding_requests" to "anon";

grant insert on table "public"."ct_funding_requests" to "anon";

grant references on table "public"."ct_funding_requests" to "anon";

grant select on table "public"."ct_funding_requests" to "anon";

grant trigger on table "public"."ct_funding_requests" to "anon";

grant truncate on table "public"."ct_funding_requests" to "anon";

grant update on table "public"."ct_funding_requests" to "anon";

grant delete on table "public"."ct_funding_requests" to "authenticated";

grant insert on table "public"."ct_funding_requests" to "authenticated";

grant references on table "public"."ct_funding_requests" to "authenticated";

grant select on table "public"."ct_funding_requests" to "authenticated";

grant trigger on table "public"."ct_funding_requests" to "authenticated";

grant truncate on table "public"."ct_funding_requests" to "authenticated";

grant update on table "public"."ct_funding_requests" to "authenticated";

grant delete on table "public"."ct_funding_requests" to "service_role";

grant insert on table "public"."ct_funding_requests" to "service_role";

grant references on table "public"."ct_funding_requests" to "service_role";

grant select on table "public"."ct_funding_requests" to "service_role";

grant trigger on table "public"."ct_funding_requests" to "service_role";

grant truncate on table "public"."ct_funding_requests" to "service_role";

grant update on table "public"."ct_funding_requests" to "service_role";

grant delete on table "public"."ct_games" to "anon";

grant insert on table "public"."ct_games" to "anon";

grant references on table "public"."ct_games" to "anon";

grant select on table "public"."ct_games" to "anon";

grant trigger on table "public"."ct_games" to "anon";

grant truncate on table "public"."ct_games" to "anon";

grant update on table "public"."ct_games" to "anon";

grant delete on table "public"."ct_games" to "authenticated";

grant insert on table "public"."ct_games" to "authenticated";

grant references on table "public"."ct_games" to "authenticated";

grant select on table "public"."ct_games" to "authenticated";

grant trigger on table "public"."ct_games" to "authenticated";

grant truncate on table "public"."ct_games" to "authenticated";

grant update on table "public"."ct_games" to "authenticated";

grant delete on table "public"."ct_games" to "service_role";

grant insert on table "public"."ct_games" to "service_role";

grant references on table "public"."ct_games" to "service_role";

grant select on table "public"."ct_games" to "service_role";

grant trigger on table "public"."ct_games" to "service_role";

grant truncate on table "public"."ct_games" to "service_role";

grant update on table "public"."ct_games" to "service_role";

grant delete on table "public"."ct_grades" to "anon";

grant insert on table "public"."ct_grades" to "anon";

grant references on table "public"."ct_grades" to "anon";

grant select on table "public"."ct_grades" to "anon";

grant trigger on table "public"."ct_grades" to "anon";

grant truncate on table "public"."ct_grades" to "anon";

grant update on table "public"."ct_grades" to "anon";

grant delete on table "public"."ct_grades" to "authenticated";

grant insert on table "public"."ct_grades" to "authenticated";

grant references on table "public"."ct_grades" to "authenticated";

grant select on table "public"."ct_grades" to "authenticated";

grant trigger on table "public"."ct_grades" to "authenticated";

grant truncate on table "public"."ct_grades" to "authenticated";

grant update on table "public"."ct_grades" to "authenticated";

grant delete on table "public"."ct_grades" to "service_role";

grant insert on table "public"."ct_grades" to "service_role";

grant references on table "public"."ct_grades" to "service_role";

grant select on table "public"."ct_grades" to "service_role";

grant trigger on table "public"."ct_grades" to "service_role";

grant truncate on table "public"."ct_grades" to "service_role";

grant update on table "public"."ct_grades" to "service_role";

grant delete on table "public"."ct_group_activities" to "anon";

grant insert on table "public"."ct_group_activities" to "anon";

grant references on table "public"."ct_group_activities" to "anon";

grant select on table "public"."ct_group_activities" to "anon";

grant trigger on table "public"."ct_group_activities" to "anon";

grant truncate on table "public"."ct_group_activities" to "anon";

grant update on table "public"."ct_group_activities" to "anon";

grant delete on table "public"."ct_group_activities" to "authenticated";

grant insert on table "public"."ct_group_activities" to "authenticated";

grant references on table "public"."ct_group_activities" to "authenticated";

grant select on table "public"."ct_group_activities" to "authenticated";

grant trigger on table "public"."ct_group_activities" to "authenticated";

grant truncate on table "public"."ct_group_activities" to "authenticated";

grant update on table "public"."ct_group_activities" to "authenticated";

grant delete on table "public"."ct_group_activities" to "service_role";

grant insert on table "public"."ct_group_activities" to "service_role";

grant references on table "public"."ct_group_activities" to "service_role";

grant select on table "public"."ct_group_activities" to "service_role";

grant trigger on table "public"."ct_group_activities" to "service_role";

grant truncate on table "public"."ct_group_activities" to "service_role";

grant update on table "public"."ct_group_activities" to "service_role";

grant delete on table "public"."ct_group_activity_members" to "anon";

grant insert on table "public"."ct_group_activity_members" to "anon";

grant references on table "public"."ct_group_activity_members" to "anon";

grant select on table "public"."ct_group_activity_members" to "anon";

grant trigger on table "public"."ct_group_activity_members" to "anon";

grant truncate on table "public"."ct_group_activity_members" to "anon";

grant update on table "public"."ct_group_activity_members" to "anon";

grant delete on table "public"."ct_group_activity_members" to "authenticated";

grant insert on table "public"."ct_group_activity_members" to "authenticated";

grant references on table "public"."ct_group_activity_members" to "authenticated";

grant select on table "public"."ct_group_activity_members" to "authenticated";

grant trigger on table "public"."ct_group_activity_members" to "authenticated";

grant truncate on table "public"."ct_group_activity_members" to "authenticated";

grant update on table "public"."ct_group_activity_members" to "authenticated";

grant delete on table "public"."ct_group_activity_members" to "service_role";

grant insert on table "public"."ct_group_activity_members" to "service_role";

grant references on table "public"."ct_group_activity_members" to "service_role";

grant select on table "public"."ct_group_activity_members" to "service_role";

grant trigger on table "public"."ct_group_activity_members" to "service_role";

grant truncate on table "public"."ct_group_activity_members" to "service_role";

grant update on table "public"."ct_group_activity_members" to "service_role";

grant delete on table "public"."ct_institution_requests" to "anon";

grant insert on table "public"."ct_institution_requests" to "anon";

grant references on table "public"."ct_institution_requests" to "anon";

grant select on table "public"."ct_institution_requests" to "anon";

grant trigger on table "public"."ct_institution_requests" to "anon";

grant truncate on table "public"."ct_institution_requests" to "anon";

grant update on table "public"."ct_institution_requests" to "anon";

grant delete on table "public"."ct_institution_requests" to "authenticated";

grant insert on table "public"."ct_institution_requests" to "authenticated";

grant references on table "public"."ct_institution_requests" to "authenticated";

grant select on table "public"."ct_institution_requests" to "authenticated";

grant trigger on table "public"."ct_institution_requests" to "authenticated";

grant truncate on table "public"."ct_institution_requests" to "authenticated";

grant update on table "public"."ct_institution_requests" to "authenticated";

grant delete on table "public"."ct_institution_requests" to "service_role";

grant insert on table "public"."ct_institution_requests" to "service_role";

grant references on table "public"."ct_institution_requests" to "service_role";

grant select on table "public"."ct_institution_requests" to "service_role";

grant trigger on table "public"."ct_institution_requests" to "service_role";

grant truncate on table "public"."ct_institution_requests" to "service_role";

grant update on table "public"."ct_institution_requests" to "service_role";

grant delete on table "public"."ct_institution_settings" to "anon";

grant insert on table "public"."ct_institution_settings" to "anon";

grant references on table "public"."ct_institution_settings" to "anon";

grant select on table "public"."ct_institution_settings" to "anon";

grant trigger on table "public"."ct_institution_settings" to "anon";

grant truncate on table "public"."ct_institution_settings" to "anon";

grant update on table "public"."ct_institution_settings" to "anon";

grant delete on table "public"."ct_institution_settings" to "authenticated";

grant insert on table "public"."ct_institution_settings" to "authenticated";

grant references on table "public"."ct_institution_settings" to "authenticated";

grant select on table "public"."ct_institution_settings" to "authenticated";

grant trigger on table "public"."ct_institution_settings" to "authenticated";

grant truncate on table "public"."ct_institution_settings" to "authenticated";

grant update on table "public"."ct_institution_settings" to "authenticated";

grant delete on table "public"."ct_institution_settings" to "service_role";

grant insert on table "public"."ct_institution_settings" to "service_role";

grant references on table "public"."ct_institution_settings" to "service_role";

grant select on table "public"."ct_institution_settings" to "service_role";

grant trigger on table "public"."ct_institution_settings" to "service_role";

grant truncate on table "public"."ct_institution_settings" to "service_role";

grant update on table "public"."ct_institution_settings" to "service_role";

grant delete on table "public"."ct_institution_subscriptions" to "anon";

grant insert on table "public"."ct_institution_subscriptions" to "anon";

grant references on table "public"."ct_institution_subscriptions" to "anon";

grant select on table "public"."ct_institution_subscriptions" to "anon";

grant trigger on table "public"."ct_institution_subscriptions" to "anon";

grant truncate on table "public"."ct_institution_subscriptions" to "anon";

grant update on table "public"."ct_institution_subscriptions" to "anon";

grant delete on table "public"."ct_institution_subscriptions" to "authenticated";

grant insert on table "public"."ct_institution_subscriptions" to "authenticated";

grant references on table "public"."ct_institution_subscriptions" to "authenticated";

grant select on table "public"."ct_institution_subscriptions" to "authenticated";

grant trigger on table "public"."ct_institution_subscriptions" to "authenticated";

grant truncate on table "public"."ct_institution_subscriptions" to "authenticated";

grant update on table "public"."ct_institution_subscriptions" to "authenticated";

grant delete on table "public"."ct_institution_subscriptions" to "service_role";

grant insert on table "public"."ct_institution_subscriptions" to "service_role";

grant references on table "public"."ct_institution_subscriptions" to "service_role";

grant select on table "public"."ct_institution_subscriptions" to "service_role";

grant trigger on table "public"."ct_institution_subscriptions" to "service_role";

grant truncate on table "public"."ct_institution_subscriptions" to "service_role";

grant update on table "public"."ct_institution_subscriptions" to "service_role";

grant delete on table "public"."ct_institutions" to "anon";

grant insert on table "public"."ct_institutions" to "anon";

grant references on table "public"."ct_institutions" to "anon";

grant select on table "public"."ct_institutions" to "anon";

grant trigger on table "public"."ct_institutions" to "anon";

grant truncate on table "public"."ct_institutions" to "anon";

grant update on table "public"."ct_institutions" to "anon";

grant delete on table "public"."ct_institutions" to "authenticated";

grant insert on table "public"."ct_institutions" to "authenticated";

grant references on table "public"."ct_institutions" to "authenticated";

grant select on table "public"."ct_institutions" to "authenticated";

grant trigger on table "public"."ct_institutions" to "authenticated";

grant truncate on table "public"."ct_institutions" to "authenticated";

grant update on table "public"."ct_institutions" to "authenticated";

grant delete on table "public"."ct_institutions" to "service_role";

grant insert on table "public"."ct_institutions" to "service_role";

grant references on table "public"."ct_institutions" to "service_role";

grant select on table "public"."ct_institutions" to "service_role";

grant trigger on table "public"."ct_institutions" to "service_role";

grant truncate on table "public"."ct_institutions" to "service_role";

grant update on table "public"."ct_institutions" to "service_role";

grant delete on table "public"."ct_interest_onboarding" to "anon";

grant insert on table "public"."ct_interest_onboarding" to "anon";

grant references on table "public"."ct_interest_onboarding" to "anon";

grant select on table "public"."ct_interest_onboarding" to "anon";

grant trigger on table "public"."ct_interest_onboarding" to "anon";

grant truncate on table "public"."ct_interest_onboarding" to "anon";

grant update on table "public"."ct_interest_onboarding" to "anon";

grant delete on table "public"."ct_interest_onboarding" to "authenticated";

grant insert on table "public"."ct_interest_onboarding" to "authenticated";

grant references on table "public"."ct_interest_onboarding" to "authenticated";

grant select on table "public"."ct_interest_onboarding" to "authenticated";

grant trigger on table "public"."ct_interest_onboarding" to "authenticated";

grant truncate on table "public"."ct_interest_onboarding" to "authenticated";

grant update on table "public"."ct_interest_onboarding" to "authenticated";

grant delete on table "public"."ct_interest_onboarding" to "service_role";

grant insert on table "public"."ct_interest_onboarding" to "service_role";

grant references on table "public"."ct_interest_onboarding" to "service_role";

grant select on table "public"."ct_interest_onboarding" to "service_role";

grant trigger on table "public"."ct_interest_onboarding" to "service_role";

grant truncate on table "public"."ct_interest_onboarding" to "service_role";

grant update on table "public"."ct_interest_onboarding" to "service_role";

grant delete on table "public"."ct_match_participants" to "anon";

grant insert on table "public"."ct_match_participants" to "anon";

grant references on table "public"."ct_match_participants" to "anon";

grant select on table "public"."ct_match_participants" to "anon";

grant trigger on table "public"."ct_match_participants" to "anon";

grant truncate on table "public"."ct_match_participants" to "anon";

grant update on table "public"."ct_match_participants" to "anon";

grant delete on table "public"."ct_match_participants" to "authenticated";

grant insert on table "public"."ct_match_participants" to "authenticated";

grant references on table "public"."ct_match_participants" to "authenticated";

grant select on table "public"."ct_match_participants" to "authenticated";

grant trigger on table "public"."ct_match_participants" to "authenticated";

grant truncate on table "public"."ct_match_participants" to "authenticated";

grant update on table "public"."ct_match_participants" to "authenticated";

grant delete on table "public"."ct_match_participants" to "service_role";

grant insert on table "public"."ct_match_participants" to "service_role";

grant references on table "public"."ct_match_participants" to "service_role";

grant select on table "public"."ct_match_participants" to "service_role";

grant trigger on table "public"."ct_match_participants" to "service_role";

grant truncate on table "public"."ct_match_participants" to "service_role";

grant update on table "public"."ct_match_participants" to "service_role";

grant delete on table "public"."ct_match_results" to "anon";

grant insert on table "public"."ct_match_results" to "anon";

grant references on table "public"."ct_match_results" to "anon";

grant select on table "public"."ct_match_results" to "anon";

grant trigger on table "public"."ct_match_results" to "anon";

grant truncate on table "public"."ct_match_results" to "anon";

grant update on table "public"."ct_match_results" to "anon";

grant delete on table "public"."ct_match_results" to "authenticated";

grant insert on table "public"."ct_match_results" to "authenticated";

grant references on table "public"."ct_match_results" to "authenticated";

grant select on table "public"."ct_match_results" to "authenticated";

grant trigger on table "public"."ct_match_results" to "authenticated";

grant truncate on table "public"."ct_match_results" to "authenticated";

grant update on table "public"."ct_match_results" to "authenticated";

grant delete on table "public"."ct_match_results" to "service_role";

grant insert on table "public"."ct_match_results" to "service_role";

grant references on table "public"."ct_match_results" to "service_role";

grant select on table "public"."ct_match_results" to "service_role";

grant trigger on table "public"."ct_match_results" to "service_role";

grant truncate on table "public"."ct_match_results" to "service_role";

grant update on table "public"."ct_match_results" to "service_role";

grant delete on table "public"."ct_note_requests" to "anon";

grant insert on table "public"."ct_note_requests" to "anon";

grant references on table "public"."ct_note_requests" to "anon";

grant select on table "public"."ct_note_requests" to "anon";

grant trigger on table "public"."ct_note_requests" to "anon";

grant truncate on table "public"."ct_note_requests" to "anon";

grant update on table "public"."ct_note_requests" to "anon";

grant delete on table "public"."ct_note_requests" to "authenticated";

grant insert on table "public"."ct_note_requests" to "authenticated";

grant references on table "public"."ct_note_requests" to "authenticated";

grant select on table "public"."ct_note_requests" to "authenticated";

grant trigger on table "public"."ct_note_requests" to "authenticated";

grant truncate on table "public"."ct_note_requests" to "authenticated";

grant update on table "public"."ct_note_requests" to "authenticated";

grant delete on table "public"."ct_note_requests" to "service_role";

grant insert on table "public"."ct_note_requests" to "service_role";

grant references on table "public"."ct_note_requests" to "service_role";

grant select on table "public"."ct_note_requests" to "service_role";

grant trigger on table "public"."ct_note_requests" to "service_role";

grant truncate on table "public"."ct_note_requests" to "service_role";

grant update on table "public"."ct_note_requests" to "service_role";

grant delete on table "public"."ct_notification_preferences" to "anon";

grant insert on table "public"."ct_notification_preferences" to "anon";

grant references on table "public"."ct_notification_preferences" to "anon";

grant select on table "public"."ct_notification_preferences" to "anon";

grant trigger on table "public"."ct_notification_preferences" to "anon";

grant truncate on table "public"."ct_notification_preferences" to "anon";

grant update on table "public"."ct_notification_preferences" to "anon";

grant delete on table "public"."ct_notification_preferences" to "authenticated";

grant insert on table "public"."ct_notification_preferences" to "authenticated";

grant references on table "public"."ct_notification_preferences" to "authenticated";

grant select on table "public"."ct_notification_preferences" to "authenticated";

grant trigger on table "public"."ct_notification_preferences" to "authenticated";

grant truncate on table "public"."ct_notification_preferences" to "authenticated";

grant update on table "public"."ct_notification_preferences" to "authenticated";

grant delete on table "public"."ct_notification_preferences" to "service_role";

grant insert on table "public"."ct_notification_preferences" to "service_role";

grant references on table "public"."ct_notification_preferences" to "service_role";

grant select on table "public"."ct_notification_preferences" to "service_role";

grant trigger on table "public"."ct_notification_preferences" to "service_role";

grant truncate on table "public"."ct_notification_preferences" to "service_role";

grant update on table "public"."ct_notification_preferences" to "service_role";

grant delete on table "public"."ct_notification_prefs" to "anon";

grant insert on table "public"."ct_notification_prefs" to "anon";

grant references on table "public"."ct_notification_prefs" to "anon";

grant select on table "public"."ct_notification_prefs" to "anon";

grant trigger on table "public"."ct_notification_prefs" to "anon";

grant truncate on table "public"."ct_notification_prefs" to "anon";

grant update on table "public"."ct_notification_prefs" to "anon";

grant delete on table "public"."ct_notification_prefs" to "authenticated";

grant insert on table "public"."ct_notification_prefs" to "authenticated";

grant references on table "public"."ct_notification_prefs" to "authenticated";

grant select on table "public"."ct_notification_prefs" to "authenticated";

grant trigger on table "public"."ct_notification_prefs" to "authenticated";

grant truncate on table "public"."ct_notification_prefs" to "authenticated";

grant update on table "public"."ct_notification_prefs" to "authenticated";

grant delete on table "public"."ct_notification_prefs" to "service_role";

grant insert on table "public"."ct_notification_prefs" to "service_role";

grant references on table "public"."ct_notification_prefs" to "service_role";

grant select on table "public"."ct_notification_prefs" to "service_role";

grant trigger on table "public"."ct_notification_prefs" to "service_role";

grant truncate on table "public"."ct_notification_prefs" to "service_role";

grant update on table "public"."ct_notification_prefs" to "service_role";

grant delete on table "public"."ct_notifications" to "anon";

grant insert on table "public"."ct_notifications" to "anon";

grant references on table "public"."ct_notifications" to "anon";

grant select on table "public"."ct_notifications" to "anon";

grant trigger on table "public"."ct_notifications" to "anon";

grant truncate on table "public"."ct_notifications" to "anon";

grant update on table "public"."ct_notifications" to "anon";

grant delete on table "public"."ct_notifications" to "authenticated";

grant insert on table "public"."ct_notifications" to "authenticated";

grant references on table "public"."ct_notifications" to "authenticated";

grant select on table "public"."ct_notifications" to "authenticated";

grant trigger on table "public"."ct_notifications" to "authenticated";

grant truncate on table "public"."ct_notifications" to "authenticated";

grant update on table "public"."ct_notifications" to "authenticated";

grant delete on table "public"."ct_notifications" to "service_role";

grant insert on table "public"."ct_notifications" to "service_role";

grant references on table "public"."ct_notifications" to "service_role";

grant select on table "public"."ct_notifications" to "service_role";

grant trigger on table "public"."ct_notifications" to "service_role";

grant truncate on table "public"."ct_notifications" to "service_role";

grant update on table "public"."ct_notifications" to "service_role";

grant delete on table "public"."ct_onboarding" to "anon";

grant insert on table "public"."ct_onboarding" to "anon";

grant references on table "public"."ct_onboarding" to "anon";

grant select on table "public"."ct_onboarding" to "anon";

grant trigger on table "public"."ct_onboarding" to "anon";

grant truncate on table "public"."ct_onboarding" to "anon";

grant update on table "public"."ct_onboarding" to "anon";

grant delete on table "public"."ct_onboarding" to "authenticated";

grant insert on table "public"."ct_onboarding" to "authenticated";

grant references on table "public"."ct_onboarding" to "authenticated";

grant select on table "public"."ct_onboarding" to "authenticated";

grant trigger on table "public"."ct_onboarding" to "authenticated";

grant truncate on table "public"."ct_onboarding" to "authenticated";

grant update on table "public"."ct_onboarding" to "authenticated";

grant delete on table "public"."ct_onboarding" to "service_role";

grant insert on table "public"."ct_onboarding" to "service_role";

grant references on table "public"."ct_onboarding" to "service_role";

grant select on table "public"."ct_onboarding" to "service_role";

grant trigger on table "public"."ct_onboarding" to "service_role";

grant truncate on table "public"."ct_onboarding" to "service_role";

grant update on table "public"."ct_onboarding" to "service_role";

grant delete on table "public"."ct_org_members" to "anon";

grant insert on table "public"."ct_org_members" to "anon";

grant references on table "public"."ct_org_members" to "anon";

grant select on table "public"."ct_org_members" to "anon";

grant trigger on table "public"."ct_org_members" to "anon";

grant truncate on table "public"."ct_org_members" to "anon";

grant update on table "public"."ct_org_members" to "anon";

grant delete on table "public"."ct_org_members" to "authenticated";

grant insert on table "public"."ct_org_members" to "authenticated";

grant references on table "public"."ct_org_members" to "authenticated";

grant select on table "public"."ct_org_members" to "authenticated";

grant trigger on table "public"."ct_org_members" to "authenticated";

grant truncate on table "public"."ct_org_members" to "authenticated";

grant update on table "public"."ct_org_members" to "authenticated";

grant delete on table "public"."ct_org_members" to "service_role";

grant insert on table "public"."ct_org_members" to "service_role";

grant references on table "public"."ct_org_members" to "service_role";

grant select on table "public"."ct_org_members" to "service_role";

grant trigger on table "public"."ct_org_members" to "service_role";

grant truncate on table "public"."ct_org_members" to "service_role";

grant update on table "public"."ct_org_members" to "service_role";

grant delete on table "public"."ct_org_users" to "anon";

grant insert on table "public"."ct_org_users" to "anon";

grant references on table "public"."ct_org_users" to "anon";

grant select on table "public"."ct_org_users" to "anon";

grant trigger on table "public"."ct_org_users" to "anon";

grant truncate on table "public"."ct_org_users" to "anon";

grant update on table "public"."ct_org_users" to "anon";

grant delete on table "public"."ct_org_users" to "authenticated";

grant insert on table "public"."ct_org_users" to "authenticated";

grant references on table "public"."ct_org_users" to "authenticated";

grant select on table "public"."ct_org_users" to "authenticated";

grant trigger on table "public"."ct_org_users" to "authenticated";

grant truncate on table "public"."ct_org_users" to "authenticated";

grant update on table "public"."ct_org_users" to "authenticated";

grant delete on table "public"."ct_org_users" to "service_role";

grant insert on table "public"."ct_org_users" to "service_role";

grant references on table "public"."ct_org_users" to "service_role";

grant select on table "public"."ct_org_users" to "service_role";

grant trigger on table "public"."ct_org_users" to "service_role";

grant truncate on table "public"."ct_org_users" to "service_role";

grant update on table "public"."ct_org_users" to "service_role";

grant delete on table "public"."ct_organizations" to "anon";

grant insert on table "public"."ct_organizations" to "anon";

grant references on table "public"."ct_organizations" to "anon";

grant select on table "public"."ct_organizations" to "anon";

grant trigger on table "public"."ct_organizations" to "anon";

grant truncate on table "public"."ct_organizations" to "anon";

grant update on table "public"."ct_organizations" to "anon";

grant delete on table "public"."ct_organizations" to "authenticated";

grant insert on table "public"."ct_organizations" to "authenticated";

grant references on table "public"."ct_organizations" to "authenticated";

grant select on table "public"."ct_organizations" to "authenticated";

grant trigger on table "public"."ct_organizations" to "authenticated";

grant truncate on table "public"."ct_organizations" to "authenticated";

grant update on table "public"."ct_organizations" to "authenticated";

grant delete on table "public"."ct_organizations" to "service_role";

grant insert on table "public"."ct_organizations" to "service_role";

grant references on table "public"."ct_organizations" to "service_role";

grant select on table "public"."ct_organizations" to "service_role";

grant trigger on table "public"."ct_organizations" to "service_role";

grant truncate on table "public"."ct_organizations" to "service_role";

grant update on table "public"."ct_organizations" to "service_role";

grant delete on table "public"."ct_parent_links" to "anon";

grant insert on table "public"."ct_parent_links" to "anon";

grant references on table "public"."ct_parent_links" to "anon";

grant select on table "public"."ct_parent_links" to "anon";

grant trigger on table "public"."ct_parent_links" to "anon";

grant truncate on table "public"."ct_parent_links" to "anon";

grant update on table "public"."ct_parent_links" to "anon";

grant delete on table "public"."ct_parent_links" to "authenticated";

grant insert on table "public"."ct_parent_links" to "authenticated";

grant references on table "public"."ct_parent_links" to "authenticated";

grant select on table "public"."ct_parent_links" to "authenticated";

grant trigger on table "public"."ct_parent_links" to "authenticated";

grant truncate on table "public"."ct_parent_links" to "authenticated";

grant update on table "public"."ct_parent_links" to "authenticated";

grant delete on table "public"."ct_parent_links" to "service_role";

grant insert on table "public"."ct_parent_links" to "service_role";

grant references on table "public"."ct_parent_links" to "service_role";

grant select on table "public"."ct_parent_links" to "service_role";

grant trigger on table "public"."ct_parent_links" to "service_role";

grant truncate on table "public"."ct_parent_links" to "service_role";

grant update on table "public"."ct_parent_links" to "service_role";

grant delete on table "public"."ct_parent_updates" to "anon";

grant insert on table "public"."ct_parent_updates" to "anon";

grant references on table "public"."ct_parent_updates" to "anon";

grant select on table "public"."ct_parent_updates" to "anon";

grant trigger on table "public"."ct_parent_updates" to "anon";

grant truncate on table "public"."ct_parent_updates" to "anon";

grant update on table "public"."ct_parent_updates" to "anon";

grant delete on table "public"."ct_parent_updates" to "authenticated";

grant insert on table "public"."ct_parent_updates" to "authenticated";

grant references on table "public"."ct_parent_updates" to "authenticated";

grant select on table "public"."ct_parent_updates" to "authenticated";

grant trigger on table "public"."ct_parent_updates" to "authenticated";

grant truncate on table "public"."ct_parent_updates" to "authenticated";

grant update on table "public"."ct_parent_updates" to "authenticated";

grant delete on table "public"."ct_parent_updates" to "service_role";

grant insert on table "public"."ct_parent_updates" to "service_role";

grant references on table "public"."ct_parent_updates" to "service_role";

grant select on table "public"."ct_parent_updates" to "service_role";

grant trigger on table "public"."ct_parent_updates" to "service_role";

grant truncate on table "public"."ct_parent_updates" to "service_role";

grant update on table "public"."ct_parent_updates" to "service_role";

grant delete on table "public"."ct_payment_methods" to "anon";

grant insert on table "public"."ct_payment_methods" to "anon";

grant references on table "public"."ct_payment_methods" to "anon";

grant select on table "public"."ct_payment_methods" to "anon";

grant trigger on table "public"."ct_payment_methods" to "anon";

grant truncate on table "public"."ct_payment_methods" to "anon";

grant update on table "public"."ct_payment_methods" to "anon";

grant delete on table "public"."ct_payment_methods" to "authenticated";

grant insert on table "public"."ct_payment_methods" to "authenticated";

grant references on table "public"."ct_payment_methods" to "authenticated";

grant select on table "public"."ct_payment_methods" to "authenticated";

grant trigger on table "public"."ct_payment_methods" to "authenticated";

grant truncate on table "public"."ct_payment_methods" to "authenticated";

grant update on table "public"."ct_payment_methods" to "authenticated";

grant delete on table "public"."ct_payment_methods" to "service_role";

grant insert on table "public"."ct_payment_methods" to "service_role";

grant references on table "public"."ct_payment_methods" to "service_role";

grant select on table "public"."ct_payment_methods" to "service_role";

grant trigger on table "public"."ct_payment_methods" to "service_role";

grant truncate on table "public"."ct_payment_methods" to "service_role";

grant update on table "public"."ct_payment_methods" to "service_role";

grant delete on table "public"."ct_peer_connections" to "anon";

grant insert on table "public"."ct_peer_connections" to "anon";

grant references on table "public"."ct_peer_connections" to "anon";

grant select on table "public"."ct_peer_connections" to "anon";

grant trigger on table "public"."ct_peer_connections" to "anon";

grant truncate on table "public"."ct_peer_connections" to "anon";

grant update on table "public"."ct_peer_connections" to "anon";

grant delete on table "public"."ct_peer_connections" to "authenticated";

grant insert on table "public"."ct_peer_connections" to "authenticated";

grant references on table "public"."ct_peer_connections" to "authenticated";

grant select on table "public"."ct_peer_connections" to "authenticated";

grant trigger on table "public"."ct_peer_connections" to "authenticated";

grant truncate on table "public"."ct_peer_connections" to "authenticated";

grant update on table "public"."ct_peer_connections" to "authenticated";

grant delete on table "public"."ct_peer_connections" to "service_role";

grant insert on table "public"."ct_peer_connections" to "service_role";

grant references on table "public"."ct_peer_connections" to "service_role";

grant select on table "public"."ct_peer_connections" to "service_role";

grant trigger on table "public"."ct_peer_connections" to "service_role";

grant truncate on table "public"."ct_peer_connections" to "service_role";

grant update on table "public"."ct_peer_connections" to "service_role";

grant delete on table "public"."ct_performance_notes" to "anon";

grant insert on table "public"."ct_performance_notes" to "anon";

grant references on table "public"."ct_performance_notes" to "anon";

grant select on table "public"."ct_performance_notes" to "anon";

grant trigger on table "public"."ct_performance_notes" to "anon";

grant truncate on table "public"."ct_performance_notes" to "anon";

grant update on table "public"."ct_performance_notes" to "anon";

grant delete on table "public"."ct_performance_notes" to "authenticated";

grant insert on table "public"."ct_performance_notes" to "authenticated";

grant references on table "public"."ct_performance_notes" to "authenticated";

grant select on table "public"."ct_performance_notes" to "authenticated";

grant trigger on table "public"."ct_performance_notes" to "authenticated";

grant truncate on table "public"."ct_performance_notes" to "authenticated";

grant update on table "public"."ct_performance_notes" to "authenticated";

grant delete on table "public"."ct_performance_notes" to "service_role";

grant insert on table "public"."ct_performance_notes" to "service_role";

grant references on table "public"."ct_performance_notes" to "service_role";

grant select on table "public"."ct_performance_notes" to "service_role";

grant trigger on table "public"."ct_performance_notes" to "service_role";

grant truncate on table "public"."ct_performance_notes" to "service_role";

grant update on table "public"."ct_performance_notes" to "service_role";

grant delete on table "public"."ct_platform_settings" to "anon";

grant insert on table "public"."ct_platform_settings" to "anon";

grant references on table "public"."ct_platform_settings" to "anon";

grant select on table "public"."ct_platform_settings" to "anon";

grant trigger on table "public"."ct_platform_settings" to "anon";

grant truncate on table "public"."ct_platform_settings" to "anon";

grant update on table "public"."ct_platform_settings" to "anon";

grant delete on table "public"."ct_platform_settings" to "authenticated";

grant insert on table "public"."ct_platform_settings" to "authenticated";

grant references on table "public"."ct_platform_settings" to "authenticated";

grant select on table "public"."ct_platform_settings" to "authenticated";

grant trigger on table "public"."ct_platform_settings" to "authenticated";

grant truncate on table "public"."ct_platform_settings" to "authenticated";

grant update on table "public"."ct_platform_settings" to "authenticated";

grant delete on table "public"."ct_platform_settings" to "service_role";

grant insert on table "public"."ct_platform_settings" to "service_role";

grant references on table "public"."ct_platform_settings" to "service_role";

grant select on table "public"."ct_platform_settings" to "service_role";

grant trigger on table "public"."ct_platform_settings" to "service_role";

grant truncate on table "public"."ct_platform_settings" to "service_role";

grant update on table "public"."ct_platform_settings" to "service_role";

grant delete on table "public"."ct_sport_challenge_participants" to "anon";

grant insert on table "public"."ct_sport_challenge_participants" to "anon";

grant references on table "public"."ct_sport_challenge_participants" to "anon";

grant select on table "public"."ct_sport_challenge_participants" to "anon";

grant trigger on table "public"."ct_sport_challenge_participants" to "anon";

grant truncate on table "public"."ct_sport_challenge_participants" to "anon";

grant update on table "public"."ct_sport_challenge_participants" to "anon";

grant delete on table "public"."ct_sport_challenge_participants" to "authenticated";

grant insert on table "public"."ct_sport_challenge_participants" to "authenticated";

grant references on table "public"."ct_sport_challenge_participants" to "authenticated";

grant select on table "public"."ct_sport_challenge_participants" to "authenticated";

grant trigger on table "public"."ct_sport_challenge_participants" to "authenticated";

grant truncate on table "public"."ct_sport_challenge_participants" to "authenticated";

grant update on table "public"."ct_sport_challenge_participants" to "authenticated";

grant delete on table "public"."ct_sport_challenge_participants" to "service_role";

grant insert on table "public"."ct_sport_challenge_participants" to "service_role";

grant references on table "public"."ct_sport_challenge_participants" to "service_role";

grant select on table "public"."ct_sport_challenge_participants" to "service_role";

grant trigger on table "public"."ct_sport_challenge_participants" to "service_role";

grant truncate on table "public"."ct_sport_challenge_participants" to "service_role";

grant update on table "public"."ct_sport_challenge_participants" to "service_role";

grant delete on table "public"."ct_sport_challenges" to "anon";

grant insert on table "public"."ct_sport_challenges" to "anon";

grant references on table "public"."ct_sport_challenges" to "anon";

grant select on table "public"."ct_sport_challenges" to "anon";

grant trigger on table "public"."ct_sport_challenges" to "anon";

grant truncate on table "public"."ct_sport_challenges" to "anon";

grant update on table "public"."ct_sport_challenges" to "anon";

grant delete on table "public"."ct_sport_challenges" to "authenticated";

grant insert on table "public"."ct_sport_challenges" to "authenticated";

grant references on table "public"."ct_sport_challenges" to "authenticated";

grant select on table "public"."ct_sport_challenges" to "authenticated";

grant trigger on table "public"."ct_sport_challenges" to "authenticated";

grant truncate on table "public"."ct_sport_challenges" to "authenticated";

grant update on table "public"."ct_sport_challenges" to "authenticated";

grant delete on table "public"."ct_sport_challenges" to "service_role";

grant insert on table "public"."ct_sport_challenges" to "service_role";

grant references on table "public"."ct_sport_challenges" to "service_role";

grant select on table "public"."ct_sport_challenges" to "service_role";

grant trigger on table "public"."ct_sport_challenges" to "service_role";

grant truncate on table "public"."ct_sport_challenges" to "service_role";

grant update on table "public"."ct_sport_challenges" to "service_role";

grant delete on table "public"."ct_sport_participants" to "anon";

grant insert on table "public"."ct_sport_participants" to "anon";

grant references on table "public"."ct_sport_participants" to "anon";

grant select on table "public"."ct_sport_participants" to "anon";

grant trigger on table "public"."ct_sport_participants" to "anon";

grant truncate on table "public"."ct_sport_participants" to "anon";

grant update on table "public"."ct_sport_participants" to "anon";

grant delete on table "public"."ct_sport_participants" to "authenticated";

grant insert on table "public"."ct_sport_participants" to "authenticated";

grant references on table "public"."ct_sport_participants" to "authenticated";

grant select on table "public"."ct_sport_participants" to "authenticated";

grant trigger on table "public"."ct_sport_participants" to "authenticated";

grant truncate on table "public"."ct_sport_participants" to "authenticated";

grant update on table "public"."ct_sport_participants" to "authenticated";

grant delete on table "public"."ct_sport_participants" to "service_role";

grant insert on table "public"."ct_sport_participants" to "service_role";

grant references on table "public"."ct_sport_participants" to "service_role";

grant select on table "public"."ct_sport_participants" to "service_role";

grant trigger on table "public"."ct_sport_participants" to "service_role";

grant truncate on table "public"."ct_sport_participants" to "service_role";

grant update on table "public"."ct_sport_participants" to "service_role";

grant delete on table "public"."ct_sport_rankings" to "anon";

grant insert on table "public"."ct_sport_rankings" to "anon";

grant references on table "public"."ct_sport_rankings" to "anon";

grant select on table "public"."ct_sport_rankings" to "anon";

grant trigger on table "public"."ct_sport_rankings" to "anon";

grant truncate on table "public"."ct_sport_rankings" to "anon";

grant update on table "public"."ct_sport_rankings" to "anon";

grant delete on table "public"."ct_sport_rankings" to "authenticated";

grant insert on table "public"."ct_sport_rankings" to "authenticated";

grant references on table "public"."ct_sport_rankings" to "authenticated";

grant select on table "public"."ct_sport_rankings" to "authenticated";

grant trigger on table "public"."ct_sport_rankings" to "authenticated";

grant truncate on table "public"."ct_sport_rankings" to "authenticated";

grant update on table "public"."ct_sport_rankings" to "authenticated";

grant delete on table "public"."ct_sport_rankings" to "service_role";

grant insert on table "public"."ct_sport_rankings" to "service_role";

grant references on table "public"."ct_sport_rankings" to "service_role";

grant select on table "public"."ct_sport_rankings" to "service_role";

grant trigger on table "public"."ct_sport_rankings" to "service_role";

grant truncate on table "public"."ct_sport_rankings" to "service_role";

grant update on table "public"."ct_sport_rankings" to "service_role";

grant delete on table "public"."ct_sports_challenges" to "anon";

grant insert on table "public"."ct_sports_challenges" to "anon";

grant references on table "public"."ct_sports_challenges" to "anon";

grant select on table "public"."ct_sports_challenges" to "anon";

grant trigger on table "public"."ct_sports_challenges" to "anon";

grant truncate on table "public"."ct_sports_challenges" to "anon";

grant update on table "public"."ct_sports_challenges" to "anon";

grant delete on table "public"."ct_sports_challenges" to "authenticated";

grant insert on table "public"."ct_sports_challenges" to "authenticated";

grant references on table "public"."ct_sports_challenges" to "authenticated";

grant select on table "public"."ct_sports_challenges" to "authenticated";

grant trigger on table "public"."ct_sports_challenges" to "authenticated";

grant truncate on table "public"."ct_sports_challenges" to "authenticated";

grant update on table "public"."ct_sports_challenges" to "authenticated";

grant delete on table "public"."ct_sports_challenges" to "service_role";

grant insert on table "public"."ct_sports_challenges" to "service_role";

grant references on table "public"."ct_sports_challenges" to "service_role";

grant select on table "public"."ct_sports_challenges" to "service_role";

grant trigger on table "public"."ct_sports_challenges" to "service_role";

grant truncate on table "public"."ct_sports_challenges" to "service_role";

grant update on table "public"."ct_sports_challenges" to "service_role";

grant delete on table "public"."ct_sports_games" to "anon";

grant insert on table "public"."ct_sports_games" to "anon";

grant references on table "public"."ct_sports_games" to "anon";

grant select on table "public"."ct_sports_games" to "anon";

grant trigger on table "public"."ct_sports_games" to "anon";

grant truncate on table "public"."ct_sports_games" to "anon";

grant update on table "public"."ct_sports_games" to "anon";

grant delete on table "public"."ct_sports_games" to "authenticated";

grant insert on table "public"."ct_sports_games" to "authenticated";

grant references on table "public"."ct_sports_games" to "authenticated";

grant select on table "public"."ct_sports_games" to "authenticated";

grant trigger on table "public"."ct_sports_games" to "authenticated";

grant truncate on table "public"."ct_sports_games" to "authenticated";

grant update on table "public"."ct_sports_games" to "authenticated";

grant delete on table "public"."ct_sports_games" to "service_role";

grant insert on table "public"."ct_sports_games" to "service_role";

grant references on table "public"."ct_sports_games" to "service_role";

grant select on table "public"."ct_sports_games" to "service_role";

grant trigger on table "public"."ct_sports_games" to "service_role";

grant truncate on table "public"."ct_sports_games" to "service_role";

grant update on table "public"."ct_sports_games" to "service_role";

grant delete on table "public"."ct_sports_leagues" to "anon";

grant insert on table "public"."ct_sports_leagues" to "anon";

grant references on table "public"."ct_sports_leagues" to "anon";

grant select on table "public"."ct_sports_leagues" to "anon";

grant trigger on table "public"."ct_sports_leagues" to "anon";

grant truncate on table "public"."ct_sports_leagues" to "anon";

grant update on table "public"."ct_sports_leagues" to "anon";

grant delete on table "public"."ct_sports_leagues" to "authenticated";

grant insert on table "public"."ct_sports_leagues" to "authenticated";

grant references on table "public"."ct_sports_leagues" to "authenticated";

grant select on table "public"."ct_sports_leagues" to "authenticated";

grant trigger on table "public"."ct_sports_leagues" to "authenticated";

grant truncate on table "public"."ct_sports_leagues" to "authenticated";

grant update on table "public"."ct_sports_leagues" to "authenticated";

grant delete on table "public"."ct_sports_leagues" to "service_role";

grant insert on table "public"."ct_sports_leagues" to "service_role";

grant references on table "public"."ct_sports_leagues" to "service_role";

grant select on table "public"."ct_sports_leagues" to "service_role";

grant trigger on table "public"."ct_sports_leagues" to "service_role";

grant truncate on table "public"."ct_sports_leagues" to "service_role";

grant update on table "public"."ct_sports_leagues" to "service_role";

grant delete on table "public"."ct_sports_teams" to "anon";

grant insert on table "public"."ct_sports_teams" to "anon";

grant references on table "public"."ct_sports_teams" to "anon";

grant select on table "public"."ct_sports_teams" to "anon";

grant trigger on table "public"."ct_sports_teams" to "anon";

grant truncate on table "public"."ct_sports_teams" to "anon";

grant update on table "public"."ct_sports_teams" to "anon";

grant delete on table "public"."ct_sports_teams" to "authenticated";

grant insert on table "public"."ct_sports_teams" to "authenticated";

grant references on table "public"."ct_sports_teams" to "authenticated";

grant select on table "public"."ct_sports_teams" to "authenticated";

grant trigger on table "public"."ct_sports_teams" to "authenticated";

grant truncate on table "public"."ct_sports_teams" to "authenticated";

grant update on table "public"."ct_sports_teams" to "authenticated";

grant delete on table "public"."ct_sports_teams" to "service_role";

grant insert on table "public"."ct_sports_teams" to "service_role";

grant references on table "public"."ct_sports_teams" to "service_role";

grant select on table "public"."ct_sports_teams" to "service_role";

grant trigger on table "public"."ct_sports_teams" to "service_role";

grant truncate on table "public"."ct_sports_teams" to "service_role";

grant update on table "public"."ct_sports_teams" to "service_role";

grant delete on table "public"."ct_staff_registrations" to "anon";

grant insert on table "public"."ct_staff_registrations" to "anon";

grant references on table "public"."ct_staff_registrations" to "anon";

grant select on table "public"."ct_staff_registrations" to "anon";

grant trigger on table "public"."ct_staff_registrations" to "anon";

grant truncate on table "public"."ct_staff_registrations" to "anon";

grant update on table "public"."ct_staff_registrations" to "anon";

grant delete on table "public"."ct_staff_registrations" to "authenticated";

grant insert on table "public"."ct_staff_registrations" to "authenticated";

grant references on table "public"."ct_staff_registrations" to "authenticated";

grant select on table "public"."ct_staff_registrations" to "authenticated";

grant trigger on table "public"."ct_staff_registrations" to "authenticated";

grant truncate on table "public"."ct_staff_registrations" to "authenticated";

grant update on table "public"."ct_staff_registrations" to "authenticated";

grant delete on table "public"."ct_staff_registrations" to "service_role";

grant insert on table "public"."ct_staff_registrations" to "service_role";

grant references on table "public"."ct_staff_registrations" to "service_role";

grant select on table "public"."ct_staff_registrations" to "service_role";

grant trigger on table "public"."ct_staff_registrations" to "service_role";

grant truncate on table "public"."ct_staff_registrations" to "service_role";

grant update on table "public"."ct_staff_registrations" to "service_role";

grant delete on table "public"."ct_stealth_sessions" to "anon";

grant insert on table "public"."ct_stealth_sessions" to "anon";

grant references on table "public"."ct_stealth_sessions" to "anon";

grant select on table "public"."ct_stealth_sessions" to "anon";

grant trigger on table "public"."ct_stealth_sessions" to "anon";

grant truncate on table "public"."ct_stealth_sessions" to "anon";

grant update on table "public"."ct_stealth_sessions" to "anon";

grant delete on table "public"."ct_stealth_sessions" to "authenticated";

grant insert on table "public"."ct_stealth_sessions" to "authenticated";

grant references on table "public"."ct_stealth_sessions" to "authenticated";

grant select on table "public"."ct_stealth_sessions" to "authenticated";

grant trigger on table "public"."ct_stealth_sessions" to "authenticated";

grant truncate on table "public"."ct_stealth_sessions" to "authenticated";

grant update on table "public"."ct_stealth_sessions" to "authenticated";

grant delete on table "public"."ct_stealth_sessions" to "service_role";

grant insert on table "public"."ct_stealth_sessions" to "service_role";

grant references on table "public"."ct_stealth_sessions" to "service_role";

grant select on table "public"."ct_stealth_sessions" to "service_role";

grant trigger on table "public"."ct_stealth_sessions" to "service_role";

grant truncate on table "public"."ct_stealth_sessions" to "service_role";

grant update on table "public"."ct_stealth_sessions" to "service_role";

grant delete on table "public"."ct_student_journey" to "anon";

grant insert on table "public"."ct_student_journey" to "anon";

grant references on table "public"."ct_student_journey" to "anon";

grant select on table "public"."ct_student_journey" to "anon";

grant trigger on table "public"."ct_student_journey" to "anon";

grant truncate on table "public"."ct_student_journey" to "anon";

grant update on table "public"."ct_student_journey" to "anon";

grant delete on table "public"."ct_student_journey" to "authenticated";

grant insert on table "public"."ct_student_journey" to "authenticated";

grant references on table "public"."ct_student_journey" to "authenticated";

grant select on table "public"."ct_student_journey" to "authenticated";

grant trigger on table "public"."ct_student_journey" to "authenticated";

grant truncate on table "public"."ct_student_journey" to "authenticated";

grant update on table "public"."ct_student_journey" to "authenticated";

grant delete on table "public"."ct_student_journey" to "service_role";

grant insert on table "public"."ct_student_journey" to "service_role";

grant references on table "public"."ct_student_journey" to "service_role";

grant select on table "public"."ct_student_journey" to "service_role";

grant trigger on table "public"."ct_student_journey" to "service_role";

grant truncate on table "public"."ct_student_journey" to "service_role";

grant update on table "public"."ct_student_journey" to "service_role";

grant delete on table "public"."ct_student_notes" to "anon";

grant insert on table "public"."ct_student_notes" to "anon";

grant references on table "public"."ct_student_notes" to "anon";

grant select on table "public"."ct_student_notes" to "anon";

grant trigger on table "public"."ct_student_notes" to "anon";

grant truncate on table "public"."ct_student_notes" to "anon";

grant update on table "public"."ct_student_notes" to "anon";

grant delete on table "public"."ct_student_notes" to "authenticated";

grant insert on table "public"."ct_student_notes" to "authenticated";

grant references on table "public"."ct_student_notes" to "authenticated";

grant select on table "public"."ct_student_notes" to "authenticated";

grant trigger on table "public"."ct_student_notes" to "authenticated";

grant truncate on table "public"."ct_student_notes" to "authenticated";

grant update on table "public"."ct_student_notes" to "authenticated";

grant delete on table "public"."ct_student_notes" to "service_role";

grant insert on table "public"."ct_student_notes" to "service_role";

grant references on table "public"."ct_student_notes" to "service_role";

grant select on table "public"."ct_student_notes" to "service_role";

grant trigger on table "public"."ct_student_notes" to "service_role";

grant truncate on table "public"."ct_student_notes" to "service_role";

grant update on table "public"."ct_student_notes" to "service_role";

grant delete on table "public"."ct_student_registrations" to "anon";

grant insert on table "public"."ct_student_registrations" to "anon";

grant references on table "public"."ct_student_registrations" to "anon";

grant select on table "public"."ct_student_registrations" to "anon";

grant trigger on table "public"."ct_student_registrations" to "anon";

grant truncate on table "public"."ct_student_registrations" to "anon";

grant update on table "public"."ct_student_registrations" to "anon";

grant delete on table "public"."ct_student_registrations" to "authenticated";

grant insert on table "public"."ct_student_registrations" to "authenticated";

grant references on table "public"."ct_student_registrations" to "authenticated";

grant select on table "public"."ct_student_registrations" to "authenticated";

grant trigger on table "public"."ct_student_registrations" to "authenticated";

grant truncate on table "public"."ct_student_registrations" to "authenticated";

grant update on table "public"."ct_student_registrations" to "authenticated";

grant delete on table "public"."ct_student_registrations" to "service_role";

grant insert on table "public"."ct_student_registrations" to "service_role";

grant references on table "public"."ct_student_registrations" to "service_role";

grant select on table "public"."ct_student_registrations" to "service_role";

grant trigger on table "public"."ct_student_registrations" to "service_role";

grant truncate on table "public"."ct_student_registrations" to "service_role";

grant update on table "public"."ct_student_registrations" to "service_role";

grant delete on table "public"."ct_students" to "anon";

grant insert on table "public"."ct_students" to "anon";

grant references on table "public"."ct_students" to "anon";

grant select on table "public"."ct_students" to "anon";

grant trigger on table "public"."ct_students" to "anon";

grant truncate on table "public"."ct_students" to "anon";

grant update on table "public"."ct_students" to "anon";

grant delete on table "public"."ct_students" to "authenticated";

grant insert on table "public"."ct_students" to "authenticated";

grant references on table "public"."ct_students" to "authenticated";

grant select on table "public"."ct_students" to "authenticated";

grant trigger on table "public"."ct_students" to "authenticated";

grant truncate on table "public"."ct_students" to "authenticated";

grant update on table "public"."ct_students" to "authenticated";

grant delete on table "public"."ct_students" to "service_role";

grant insert on table "public"."ct_students" to "service_role";

grant references on table "public"."ct_students" to "service_role";

grant select on table "public"."ct_students" to "service_role";

grant trigger on table "public"."ct_students" to "service_role";

grant truncate on table "public"."ct_students" to "service_role";

grant update on table "public"."ct_students" to "service_role";

grant delete on table "public"."ct_submission_files" to "anon";

grant insert on table "public"."ct_submission_files" to "anon";

grant references on table "public"."ct_submission_files" to "anon";

grant select on table "public"."ct_submission_files" to "anon";

grant trigger on table "public"."ct_submission_files" to "anon";

grant truncate on table "public"."ct_submission_files" to "anon";

grant update on table "public"."ct_submission_files" to "anon";

grant delete on table "public"."ct_submission_files" to "authenticated";

grant insert on table "public"."ct_submission_files" to "authenticated";

grant references on table "public"."ct_submission_files" to "authenticated";

grant select on table "public"."ct_submission_files" to "authenticated";

grant trigger on table "public"."ct_submission_files" to "authenticated";

grant truncate on table "public"."ct_submission_files" to "authenticated";

grant update on table "public"."ct_submission_files" to "authenticated";

grant delete on table "public"."ct_submission_files" to "service_role";

grant insert on table "public"."ct_submission_files" to "service_role";

grant references on table "public"."ct_submission_files" to "service_role";

grant select on table "public"."ct_submission_files" to "service_role";

grant trigger on table "public"."ct_submission_files" to "service_role";

grant truncate on table "public"."ct_submission_files" to "service_role";

grant update on table "public"."ct_submission_files" to "service_role";

grant delete on table "public"."ct_submissions" to "anon";

grant insert on table "public"."ct_submissions" to "anon";

grant references on table "public"."ct_submissions" to "anon";

grant select on table "public"."ct_submissions" to "anon";

grant trigger on table "public"."ct_submissions" to "anon";

grant truncate on table "public"."ct_submissions" to "anon";

grant update on table "public"."ct_submissions" to "anon";

grant delete on table "public"."ct_submissions" to "authenticated";

grant insert on table "public"."ct_submissions" to "authenticated";

grant references on table "public"."ct_submissions" to "authenticated";

grant select on table "public"."ct_submissions" to "authenticated";

grant trigger on table "public"."ct_submissions" to "authenticated";

grant truncate on table "public"."ct_submissions" to "authenticated";

grant update on table "public"."ct_submissions" to "authenticated";

grant delete on table "public"."ct_submissions" to "service_role";

grant insert on table "public"."ct_submissions" to "service_role";

grant references on table "public"."ct_submissions" to "service_role";

grant select on table "public"."ct_submissions" to "service_role";

grant trigger on table "public"."ct_submissions" to "service_role";

grant truncate on table "public"."ct_submissions" to "service_role";

grant update on table "public"."ct_submissions" to "service_role";

grant delete on table "public"."ct_superadmins" to "anon";

grant insert on table "public"."ct_superadmins" to "anon";

grant references on table "public"."ct_superadmins" to "anon";

grant select on table "public"."ct_superadmins" to "anon";

grant trigger on table "public"."ct_superadmins" to "anon";

grant truncate on table "public"."ct_superadmins" to "anon";

grant update on table "public"."ct_superadmins" to "anon";

grant delete on table "public"."ct_superadmins" to "authenticated";

grant insert on table "public"."ct_superadmins" to "authenticated";

grant references on table "public"."ct_superadmins" to "authenticated";

grant select on table "public"."ct_superadmins" to "authenticated";

grant trigger on table "public"."ct_superadmins" to "authenticated";

grant truncate on table "public"."ct_superadmins" to "authenticated";

grant update on table "public"."ct_superadmins" to "authenticated";

grant delete on table "public"."ct_superadmins" to "service_role";

grant insert on table "public"."ct_superadmins" to "service_role";

grant references on table "public"."ct_superadmins" to "service_role";

grant select on table "public"."ct_superadmins" to "service_role";

grant trigger on table "public"."ct_superadmins" to "service_role";

grant truncate on table "public"."ct_superadmins" to "service_role";

grant update on table "public"."ct_superadmins" to "service_role";

grant delete on table "public"."ct_survey_questions" to "anon";

grant insert on table "public"."ct_survey_questions" to "anon";

grant references on table "public"."ct_survey_questions" to "anon";

grant select on table "public"."ct_survey_questions" to "anon";

grant trigger on table "public"."ct_survey_questions" to "anon";

grant truncate on table "public"."ct_survey_questions" to "anon";

grant update on table "public"."ct_survey_questions" to "anon";

grant delete on table "public"."ct_survey_questions" to "authenticated";

grant insert on table "public"."ct_survey_questions" to "authenticated";

grant references on table "public"."ct_survey_questions" to "authenticated";

grant select on table "public"."ct_survey_questions" to "authenticated";

grant trigger on table "public"."ct_survey_questions" to "authenticated";

grant truncate on table "public"."ct_survey_questions" to "authenticated";

grant update on table "public"."ct_survey_questions" to "authenticated";

grant delete on table "public"."ct_survey_questions" to "service_role";

grant insert on table "public"."ct_survey_questions" to "service_role";

grant references on table "public"."ct_survey_questions" to "service_role";

grant select on table "public"."ct_survey_questions" to "service_role";

grant trigger on table "public"."ct_survey_questions" to "service_role";

grant truncate on table "public"."ct_survey_questions" to "service_role";

grant update on table "public"."ct_survey_questions" to "service_role";

grant delete on table "public"."ct_survey_responses" to "anon";

grant insert on table "public"."ct_survey_responses" to "anon";

grant references on table "public"."ct_survey_responses" to "anon";

grant select on table "public"."ct_survey_responses" to "anon";

grant trigger on table "public"."ct_survey_responses" to "anon";

grant truncate on table "public"."ct_survey_responses" to "anon";

grant update on table "public"."ct_survey_responses" to "anon";

grant delete on table "public"."ct_survey_responses" to "authenticated";

grant insert on table "public"."ct_survey_responses" to "authenticated";

grant references on table "public"."ct_survey_responses" to "authenticated";

grant select on table "public"."ct_survey_responses" to "authenticated";

grant trigger on table "public"."ct_survey_responses" to "authenticated";

grant truncate on table "public"."ct_survey_responses" to "authenticated";

grant update on table "public"."ct_survey_responses" to "authenticated";

grant delete on table "public"."ct_survey_responses" to "service_role";

grant insert on table "public"."ct_survey_responses" to "service_role";

grant references on table "public"."ct_survey_responses" to "service_role";

grant select on table "public"."ct_survey_responses" to "service_role";

grant trigger on table "public"."ct_survey_responses" to "service_role";

grant truncate on table "public"."ct_survey_responses" to "service_role";

grant update on table "public"."ct_survey_responses" to "service_role";

grant delete on table "public"."ct_surveys" to "anon";

grant insert on table "public"."ct_surveys" to "anon";

grant references on table "public"."ct_surveys" to "anon";

grant select on table "public"."ct_surveys" to "anon";

grant trigger on table "public"."ct_surveys" to "anon";

grant truncate on table "public"."ct_surveys" to "anon";

grant update on table "public"."ct_surveys" to "anon";

grant delete on table "public"."ct_surveys" to "authenticated";

grant insert on table "public"."ct_surveys" to "authenticated";

grant references on table "public"."ct_surveys" to "authenticated";

grant select on table "public"."ct_surveys" to "authenticated";

grant trigger on table "public"."ct_surveys" to "authenticated";

grant truncate on table "public"."ct_surveys" to "authenticated";

grant update on table "public"."ct_surveys" to "authenticated";

grant delete on table "public"."ct_surveys" to "service_role";

grant insert on table "public"."ct_surveys" to "service_role";

grant references on table "public"."ct_surveys" to "service_role";

grant select on table "public"."ct_surveys" to "service_role";

grant trigger on table "public"."ct_surveys" to "service_role";

grant truncate on table "public"."ct_surveys" to "service_role";

grant update on table "public"."ct_surveys" to "service_role";

grant delete on table "public"."ct_teams" to "anon";

grant insert on table "public"."ct_teams" to "anon";

grant references on table "public"."ct_teams" to "anon";

grant select on table "public"."ct_teams" to "anon";

grant trigger on table "public"."ct_teams" to "anon";

grant truncate on table "public"."ct_teams" to "anon";

grant update on table "public"."ct_teams" to "anon";

grant delete on table "public"."ct_teams" to "authenticated";

grant insert on table "public"."ct_teams" to "authenticated";

grant references on table "public"."ct_teams" to "authenticated";

grant select on table "public"."ct_teams" to "authenticated";

grant trigger on table "public"."ct_teams" to "authenticated";

grant truncate on table "public"."ct_teams" to "authenticated";

grant update on table "public"."ct_teams" to "authenticated";

grant delete on table "public"."ct_teams" to "service_role";

grant insert on table "public"."ct_teams" to "service_role";

grant references on table "public"."ct_teams" to "service_role";

grant select on table "public"."ct_teams" to "service_role";

grant trigger on table "public"."ct_teams" to "service_role";

grant truncate on table "public"."ct_teams" to "service_role";

grant update on table "public"."ct_teams" to "service_role";

grant delete on table "public"."ct_ticket_messages" to "anon";

grant insert on table "public"."ct_ticket_messages" to "anon";

grant references on table "public"."ct_ticket_messages" to "anon";

grant select on table "public"."ct_ticket_messages" to "anon";

grant trigger on table "public"."ct_ticket_messages" to "anon";

grant truncate on table "public"."ct_ticket_messages" to "anon";

grant update on table "public"."ct_ticket_messages" to "anon";

grant delete on table "public"."ct_ticket_messages" to "authenticated";

grant insert on table "public"."ct_ticket_messages" to "authenticated";

grant references on table "public"."ct_ticket_messages" to "authenticated";

grant select on table "public"."ct_ticket_messages" to "authenticated";

grant trigger on table "public"."ct_ticket_messages" to "authenticated";

grant truncate on table "public"."ct_ticket_messages" to "authenticated";

grant update on table "public"."ct_ticket_messages" to "authenticated";

grant delete on table "public"."ct_ticket_messages" to "service_role";

grant insert on table "public"."ct_ticket_messages" to "service_role";

grant references on table "public"."ct_ticket_messages" to "service_role";

grant select on table "public"."ct_ticket_messages" to "service_role";

grant trigger on table "public"."ct_ticket_messages" to "service_role";

grant truncate on table "public"."ct_ticket_messages" to "service_role";

grant update on table "public"."ct_ticket_messages" to "service_role";

grant delete on table "public"."ct_tickets" to "anon";

grant insert on table "public"."ct_tickets" to "anon";

grant references on table "public"."ct_tickets" to "anon";

grant select on table "public"."ct_tickets" to "anon";

grant trigger on table "public"."ct_tickets" to "anon";

grant truncate on table "public"."ct_tickets" to "anon";

grant update on table "public"."ct_tickets" to "anon";

grant delete on table "public"."ct_tickets" to "authenticated";

grant insert on table "public"."ct_tickets" to "authenticated";

grant references on table "public"."ct_tickets" to "authenticated";

grant select on table "public"."ct_tickets" to "authenticated";

grant trigger on table "public"."ct_tickets" to "authenticated";

grant truncate on table "public"."ct_tickets" to "authenticated";

grant update on table "public"."ct_tickets" to "authenticated";

grant delete on table "public"."ct_tickets" to "service_role";

grant insert on table "public"."ct_tickets" to "service_role";

grant references on table "public"."ct_tickets" to "service_role";

grant select on table "public"."ct_tickets" to "service_role";

grant trigger on table "public"."ct_tickets" to "service_role";

grant truncate on table "public"."ct_tickets" to "service_role";

grant update on table "public"."ct_tickets" to "service_role";

grant delete on table "public"."ct_tournament_matches" to "anon";

grant insert on table "public"."ct_tournament_matches" to "anon";

grant references on table "public"."ct_tournament_matches" to "anon";

grant select on table "public"."ct_tournament_matches" to "anon";

grant trigger on table "public"."ct_tournament_matches" to "anon";

grant truncate on table "public"."ct_tournament_matches" to "anon";

grant update on table "public"."ct_tournament_matches" to "anon";

grant delete on table "public"."ct_tournament_matches" to "authenticated";

grant insert on table "public"."ct_tournament_matches" to "authenticated";

grant references on table "public"."ct_tournament_matches" to "authenticated";

grant select on table "public"."ct_tournament_matches" to "authenticated";

grant trigger on table "public"."ct_tournament_matches" to "authenticated";

grant truncate on table "public"."ct_tournament_matches" to "authenticated";

grant update on table "public"."ct_tournament_matches" to "authenticated";

grant delete on table "public"."ct_tournament_matches" to "service_role";

grant insert on table "public"."ct_tournament_matches" to "service_role";

grant references on table "public"."ct_tournament_matches" to "service_role";

grant select on table "public"."ct_tournament_matches" to "service_role";

grant trigger on table "public"."ct_tournament_matches" to "service_role";

grant truncate on table "public"."ct_tournament_matches" to "service_role";

grant update on table "public"."ct_tournament_matches" to "service_role";

grant delete on table "public"."ct_tournament_teams" to "anon";

grant insert on table "public"."ct_tournament_teams" to "anon";

grant references on table "public"."ct_tournament_teams" to "anon";

grant select on table "public"."ct_tournament_teams" to "anon";

grant trigger on table "public"."ct_tournament_teams" to "anon";

grant truncate on table "public"."ct_tournament_teams" to "anon";

grant update on table "public"."ct_tournament_teams" to "anon";

grant delete on table "public"."ct_tournament_teams" to "authenticated";

grant insert on table "public"."ct_tournament_teams" to "authenticated";

grant references on table "public"."ct_tournament_teams" to "authenticated";

grant select on table "public"."ct_tournament_teams" to "authenticated";

grant trigger on table "public"."ct_tournament_teams" to "authenticated";

grant truncate on table "public"."ct_tournament_teams" to "authenticated";

grant update on table "public"."ct_tournament_teams" to "authenticated";

grant delete on table "public"."ct_tournament_teams" to "service_role";

grant insert on table "public"."ct_tournament_teams" to "service_role";

grant references on table "public"."ct_tournament_teams" to "service_role";

grant select on table "public"."ct_tournament_teams" to "service_role";

grant trigger on table "public"."ct_tournament_teams" to "service_role";

grant truncate on table "public"."ct_tournament_teams" to "service_role";

grant update on table "public"."ct_tournament_teams" to "service_role";

grant delete on table "public"."ct_tournaments" to "anon";

grant insert on table "public"."ct_tournaments" to "anon";

grant references on table "public"."ct_tournaments" to "anon";

grant select on table "public"."ct_tournaments" to "anon";

grant trigger on table "public"."ct_tournaments" to "anon";

grant truncate on table "public"."ct_tournaments" to "anon";

grant update on table "public"."ct_tournaments" to "anon";

grant delete on table "public"."ct_tournaments" to "authenticated";

grant insert on table "public"."ct_tournaments" to "authenticated";

grant references on table "public"."ct_tournaments" to "authenticated";

grant select on table "public"."ct_tournaments" to "authenticated";

grant trigger on table "public"."ct_tournaments" to "authenticated";

grant truncate on table "public"."ct_tournaments" to "authenticated";

grant update on table "public"."ct_tournaments" to "authenticated";

grant delete on table "public"."ct_tournaments" to "service_role";

grant insert on table "public"."ct_tournaments" to "service_role";

grant references on table "public"."ct_tournaments" to "service_role";

grant select on table "public"."ct_tournaments" to "service_role";

grant trigger on table "public"."ct_tournaments" to "service_role";

grant truncate on table "public"."ct_tournaments" to "service_role";

grant update on table "public"."ct_tournaments" to "service_role";

grant delete on table "public"."ct_training_sessions" to "anon";

grant insert on table "public"."ct_training_sessions" to "anon";

grant references on table "public"."ct_training_sessions" to "anon";

grant select on table "public"."ct_training_sessions" to "anon";

grant trigger on table "public"."ct_training_sessions" to "anon";

grant truncate on table "public"."ct_training_sessions" to "anon";

grant update on table "public"."ct_training_sessions" to "anon";

grant delete on table "public"."ct_training_sessions" to "authenticated";

grant insert on table "public"."ct_training_sessions" to "authenticated";

grant references on table "public"."ct_training_sessions" to "authenticated";

grant select on table "public"."ct_training_sessions" to "authenticated";

grant trigger on table "public"."ct_training_sessions" to "authenticated";

grant truncate on table "public"."ct_training_sessions" to "authenticated";

grant update on table "public"."ct_training_sessions" to "authenticated";

grant delete on table "public"."ct_training_sessions" to "service_role";

grant insert on table "public"."ct_training_sessions" to "service_role";

grant references on table "public"."ct_training_sessions" to "service_role";

grant select on table "public"."ct_training_sessions" to "service_role";

grant trigger on table "public"."ct_training_sessions" to "service_role";

grant truncate on table "public"."ct_training_sessions" to "service_role";

grant update on table "public"."ct_training_sessions" to "service_role";

grant delete on table "public"."ct_trial_requests" to "anon";

grant insert on table "public"."ct_trial_requests" to "anon";

grant references on table "public"."ct_trial_requests" to "anon";

grant select on table "public"."ct_trial_requests" to "anon";

grant trigger on table "public"."ct_trial_requests" to "anon";

grant truncate on table "public"."ct_trial_requests" to "anon";

grant update on table "public"."ct_trial_requests" to "anon";

grant delete on table "public"."ct_trial_requests" to "authenticated";

grant insert on table "public"."ct_trial_requests" to "authenticated";

grant references on table "public"."ct_trial_requests" to "authenticated";

grant select on table "public"."ct_trial_requests" to "authenticated";

grant trigger on table "public"."ct_trial_requests" to "authenticated";

grant truncate on table "public"."ct_trial_requests" to "authenticated";

grant update on table "public"."ct_trial_requests" to "authenticated";

grant delete on table "public"."ct_trial_requests" to "service_role";

grant insert on table "public"."ct_trial_requests" to "service_role";

grant references on table "public"."ct_trial_requests" to "service_role";

grant select on table "public"."ct_trial_requests" to "service_role";

grant trigger on table "public"."ct_trial_requests" to "service_role";

grant truncate on table "public"."ct_trial_requests" to "service_role";

grant update on table "public"."ct_trial_requests" to "service_role";

grant delete on table "public"."ct_user_notifications" to "anon";

grant insert on table "public"."ct_user_notifications" to "anon";

grant references on table "public"."ct_user_notifications" to "anon";

grant select on table "public"."ct_user_notifications" to "anon";

grant trigger on table "public"."ct_user_notifications" to "anon";

grant truncate on table "public"."ct_user_notifications" to "anon";

grant update on table "public"."ct_user_notifications" to "anon";

grant delete on table "public"."ct_user_notifications" to "authenticated";

grant insert on table "public"."ct_user_notifications" to "authenticated";

grant references on table "public"."ct_user_notifications" to "authenticated";

grant select on table "public"."ct_user_notifications" to "authenticated";

grant trigger on table "public"."ct_user_notifications" to "authenticated";

grant truncate on table "public"."ct_user_notifications" to "authenticated";

grant update on table "public"."ct_user_notifications" to "authenticated";

grant delete on table "public"."ct_user_notifications" to "service_role";

grant insert on table "public"."ct_user_notifications" to "service_role";

grant references on table "public"."ct_user_notifications" to "service_role";

grant select on table "public"."ct_user_notifications" to "service_role";

grant trigger on table "public"."ct_user_notifications" to "service_role";

grant truncate on table "public"."ct_user_notifications" to "service_role";

grant update on table "public"."ct_user_notifications" to "service_role";

grant delete on table "public"."ct_user_seat_billing" to "anon";

grant insert on table "public"."ct_user_seat_billing" to "anon";

grant references on table "public"."ct_user_seat_billing" to "anon";

grant select on table "public"."ct_user_seat_billing" to "anon";

grant trigger on table "public"."ct_user_seat_billing" to "anon";

grant truncate on table "public"."ct_user_seat_billing" to "anon";

grant update on table "public"."ct_user_seat_billing" to "anon";

grant delete on table "public"."ct_user_seat_billing" to "authenticated";

grant insert on table "public"."ct_user_seat_billing" to "authenticated";

grant references on table "public"."ct_user_seat_billing" to "authenticated";

grant select on table "public"."ct_user_seat_billing" to "authenticated";

grant trigger on table "public"."ct_user_seat_billing" to "authenticated";

grant truncate on table "public"."ct_user_seat_billing" to "authenticated";

grant update on table "public"."ct_user_seat_billing" to "authenticated";

grant delete on table "public"."ct_user_seat_billing" to "service_role";

grant insert on table "public"."ct_user_seat_billing" to "service_role";

grant references on table "public"."ct_user_seat_billing" to "service_role";

grant select on table "public"."ct_user_seat_billing" to "service_role";

grant trigger on table "public"."ct_user_seat_billing" to "service_role";

grant truncate on table "public"."ct_user_seat_billing" to "service_role";

grant update on table "public"."ct_user_seat_billing" to "service_role";

grant delete on table "public"."ct_users" to "anon";

grant insert on table "public"."ct_users" to "anon";

grant references on table "public"."ct_users" to "anon";

grant select on table "public"."ct_users" to "anon";

grant trigger on table "public"."ct_users" to "anon";

grant truncate on table "public"."ct_users" to "anon";

grant update on table "public"."ct_users" to "anon";

grant delete on table "public"."ct_users" to "authenticated";

grant insert on table "public"."ct_users" to "authenticated";

grant references on table "public"."ct_users" to "authenticated";

grant select on table "public"."ct_users" to "authenticated";

grant trigger on table "public"."ct_users" to "authenticated";

grant truncate on table "public"."ct_users" to "authenticated";

grant update on table "public"."ct_users" to "authenticated";

grant delete on table "public"."ct_users" to "service_role";

grant insert on table "public"."ct_users" to "service_role";

grant references on table "public"."ct_users" to "service_role";

grant select on table "public"."ct_users" to "service_role";

grant trigger on table "public"."ct_users" to "service_role";

grant truncate on table "public"."ct_users" to "service_role";

grant update on table "public"."ct_users" to "service_role";

grant delete on table "public"."ct_venue_booking_history" to "anon";

grant insert on table "public"."ct_venue_booking_history" to "anon";

grant references on table "public"."ct_venue_booking_history" to "anon";

grant select on table "public"."ct_venue_booking_history" to "anon";

grant trigger on table "public"."ct_venue_booking_history" to "anon";

grant truncate on table "public"."ct_venue_booking_history" to "anon";

grant update on table "public"."ct_venue_booking_history" to "anon";

grant delete on table "public"."ct_venue_booking_history" to "authenticated";

grant insert on table "public"."ct_venue_booking_history" to "authenticated";

grant references on table "public"."ct_venue_booking_history" to "authenticated";

grant select on table "public"."ct_venue_booking_history" to "authenticated";

grant trigger on table "public"."ct_venue_booking_history" to "authenticated";

grant truncate on table "public"."ct_venue_booking_history" to "authenticated";

grant update on table "public"."ct_venue_booking_history" to "authenticated";

grant delete on table "public"."ct_venue_booking_history" to "service_role";

grant insert on table "public"."ct_venue_booking_history" to "service_role";

grant references on table "public"."ct_venue_booking_history" to "service_role";

grant select on table "public"."ct_venue_booking_history" to "service_role";

grant trigger on table "public"."ct_venue_booking_history" to "service_role";

grant truncate on table "public"."ct_venue_booking_history" to "service_role";

grant update on table "public"."ct_venue_booking_history" to "service_role";

grant delete on table "public"."ct_venue_bookings" to "anon";

grant insert on table "public"."ct_venue_bookings" to "anon";

grant references on table "public"."ct_venue_bookings" to "anon";

grant select on table "public"."ct_venue_bookings" to "anon";

grant trigger on table "public"."ct_venue_bookings" to "anon";

grant truncate on table "public"."ct_venue_bookings" to "anon";

grant update on table "public"."ct_venue_bookings" to "anon";

grant delete on table "public"."ct_venue_bookings" to "authenticated";

grant insert on table "public"."ct_venue_bookings" to "authenticated";

grant references on table "public"."ct_venue_bookings" to "authenticated";

grant select on table "public"."ct_venue_bookings" to "authenticated";

grant trigger on table "public"."ct_venue_bookings" to "authenticated";

grant truncate on table "public"."ct_venue_bookings" to "authenticated";

grant update on table "public"."ct_venue_bookings" to "authenticated";

grant delete on table "public"."ct_venue_bookings" to "service_role";

grant insert on table "public"."ct_venue_bookings" to "service_role";

grant references on table "public"."ct_venue_bookings" to "service_role";

grant select on table "public"."ct_venue_bookings" to "service_role";

grant trigger on table "public"."ct_venue_bookings" to "service_role";

grant truncate on table "public"."ct_venue_bookings" to "service_role";

grant update on table "public"."ct_venue_bookings" to "service_role";

grant delete on table "public"."ct_venues" to "anon";

grant insert on table "public"."ct_venues" to "anon";

grant references on table "public"."ct_venues" to "anon";

grant select on table "public"."ct_venues" to "anon";

grant trigger on table "public"."ct_venues" to "anon";

grant truncate on table "public"."ct_venues" to "anon";

grant update on table "public"."ct_venues" to "anon";

grant delete on table "public"."ct_venues" to "authenticated";

grant insert on table "public"."ct_venues" to "authenticated";

grant references on table "public"."ct_venues" to "authenticated";

grant select on table "public"."ct_venues" to "authenticated";

grant trigger on table "public"."ct_venues" to "authenticated";

grant truncate on table "public"."ct_venues" to "authenticated";

grant update on table "public"."ct_venues" to "authenticated";

grant delete on table "public"."ct_venues" to "service_role";

grant insert on table "public"."ct_venues" to "service_role";

grant references on table "public"."ct_venues" to "service_role";

grant select on table "public"."ct_venues" to "service_role";

grant trigger on table "public"."ct_venues" to "service_role";

grant truncate on table "public"."ct_venues" to "service_role";

grant update on table "public"."ct_venues" to "service_role";

grant delete on table "public"."ct_wellbeing_checkins" to "anon";

grant insert on table "public"."ct_wellbeing_checkins" to "anon";

grant references on table "public"."ct_wellbeing_checkins" to "anon";

grant select on table "public"."ct_wellbeing_checkins" to "anon";

grant trigger on table "public"."ct_wellbeing_checkins" to "anon";

grant truncate on table "public"."ct_wellbeing_checkins" to "anon";

grant update on table "public"."ct_wellbeing_checkins" to "anon";

grant delete on table "public"."ct_wellbeing_checkins" to "authenticated";

grant insert on table "public"."ct_wellbeing_checkins" to "authenticated";

grant references on table "public"."ct_wellbeing_checkins" to "authenticated";

grant select on table "public"."ct_wellbeing_checkins" to "authenticated";

grant trigger on table "public"."ct_wellbeing_checkins" to "authenticated";

grant truncate on table "public"."ct_wellbeing_checkins" to "authenticated";

grant update on table "public"."ct_wellbeing_checkins" to "authenticated";

grant delete on table "public"."ct_wellbeing_checkins" to "service_role";

grant insert on table "public"."ct_wellbeing_checkins" to "service_role";

grant references on table "public"."ct_wellbeing_checkins" to "service_role";

grant select on table "public"."ct_wellbeing_checkins" to "service_role";

grant trigger on table "public"."ct_wellbeing_checkins" to "service_role";

grant truncate on table "public"."ct_wellbeing_checkins" to "service_role";

grant update on table "public"."ct_wellbeing_checkins" to "service_role";

grant delete on table "public"."ct_wellbeing_checks" to "anon";

grant insert on table "public"."ct_wellbeing_checks" to "anon";

grant references on table "public"."ct_wellbeing_checks" to "anon";

grant select on table "public"."ct_wellbeing_checks" to "anon";

grant trigger on table "public"."ct_wellbeing_checks" to "anon";

grant truncate on table "public"."ct_wellbeing_checks" to "anon";

grant update on table "public"."ct_wellbeing_checks" to "anon";

grant delete on table "public"."ct_wellbeing_checks" to "authenticated";

grant insert on table "public"."ct_wellbeing_checks" to "authenticated";

grant references on table "public"."ct_wellbeing_checks" to "authenticated";

grant select on table "public"."ct_wellbeing_checks" to "authenticated";

grant trigger on table "public"."ct_wellbeing_checks" to "authenticated";

grant truncate on table "public"."ct_wellbeing_checks" to "authenticated";

grant update on table "public"."ct_wellbeing_checks" to "authenticated";

grant delete on table "public"."ct_wellbeing_checks" to "service_role";

grant insert on table "public"."ct_wellbeing_checks" to "service_role";

grant references on table "public"."ct_wellbeing_checks" to "service_role";

grant select on table "public"."ct_wellbeing_checks" to "service_role";

grant trigger on table "public"."ct_wellbeing_checks" to "service_role";

grant truncate on table "public"."ct_wellbeing_checks" to "service_role";

grant update on table "public"."ct_wellbeing_checks" to "service_role";

grant delete on table "public"."ct_wellness_checkins" to "anon";

grant insert on table "public"."ct_wellness_checkins" to "anon";

grant references on table "public"."ct_wellness_checkins" to "anon";

grant select on table "public"."ct_wellness_checkins" to "anon";

grant trigger on table "public"."ct_wellness_checkins" to "anon";

grant truncate on table "public"."ct_wellness_checkins" to "anon";

grant update on table "public"."ct_wellness_checkins" to "anon";

grant delete on table "public"."ct_wellness_checkins" to "authenticated";

grant insert on table "public"."ct_wellness_checkins" to "authenticated";

grant references on table "public"."ct_wellness_checkins" to "authenticated";

grant select on table "public"."ct_wellness_checkins" to "authenticated";

grant trigger on table "public"."ct_wellness_checkins" to "authenticated";

grant truncate on table "public"."ct_wellness_checkins" to "authenticated";

grant update on table "public"."ct_wellness_checkins" to "authenticated";

grant delete on table "public"."ct_wellness_checkins" to "service_role";

grant insert on table "public"."ct_wellness_checkins" to "service_role";

grant references on table "public"."ct_wellness_checkins" to "service_role";

grant select on table "public"."ct_wellness_checkins" to "service_role";

grant trigger on table "public"."ct_wellness_checkins" to "service_role";

grant truncate on table "public"."ct_wellness_checkins" to "service_role";

grant update on table "public"."ct_wellness_checkins" to "service_role";

grant delete on table "public"."demo_requests" to "anon";

grant insert on table "public"."demo_requests" to "anon";

grant references on table "public"."demo_requests" to "anon";

grant select on table "public"."demo_requests" to "anon";

grant trigger on table "public"."demo_requests" to "anon";

grant truncate on table "public"."demo_requests" to "anon";

grant update on table "public"."demo_requests" to "anon";

grant delete on table "public"."demo_requests" to "authenticated";

grant insert on table "public"."demo_requests" to "authenticated";

grant references on table "public"."demo_requests" to "authenticated";

grant select on table "public"."demo_requests" to "authenticated";

grant trigger on table "public"."demo_requests" to "authenticated";

grant truncate on table "public"."demo_requests" to "authenticated";

grant update on table "public"."demo_requests" to "authenticated";

grant delete on table "public"."demo_requests" to "service_role";

grant insert on table "public"."demo_requests" to "service_role";

grant references on table "public"."demo_requests" to "service_role";

grant select on table "public"."demo_requests" to "service_role";

grant trigger on table "public"."demo_requests" to "service_role";

grant truncate on table "public"."demo_requests" to "service_role";

grant update on table "public"."demo_requests" to "service_role";

grant delete on table "public"."earnings" to "anon";

grant insert on table "public"."earnings" to "anon";

grant references on table "public"."earnings" to "anon";

grant select on table "public"."earnings" to "anon";

grant trigger on table "public"."earnings" to "anon";

grant truncate on table "public"."earnings" to "anon";

grant update on table "public"."earnings" to "anon";

grant delete on table "public"."earnings" to "authenticated";

grant insert on table "public"."earnings" to "authenticated";

grant references on table "public"."earnings" to "authenticated";

grant select on table "public"."earnings" to "authenticated";

grant trigger on table "public"."earnings" to "authenticated";

grant truncate on table "public"."earnings" to "authenticated";

grant update on table "public"."earnings" to "authenticated";

grant delete on table "public"."earnings" to "service_role";

grant insert on table "public"."earnings" to "service_role";

grant references on table "public"."earnings" to "service_role";

grant select on table "public"."earnings" to "service_role";

grant trigger on table "public"."earnings" to "service_role";

grant truncate on table "public"."earnings" to "service_role";

grant update on table "public"."earnings" to "service_role";

grant delete on table "public"."enterprise_invoices" to "anon";

grant insert on table "public"."enterprise_invoices" to "anon";

grant references on table "public"."enterprise_invoices" to "anon";

grant select on table "public"."enterprise_invoices" to "anon";

grant trigger on table "public"."enterprise_invoices" to "anon";

grant truncate on table "public"."enterprise_invoices" to "anon";

grant update on table "public"."enterprise_invoices" to "anon";

grant delete on table "public"."enterprise_invoices" to "authenticated";

grant insert on table "public"."enterprise_invoices" to "authenticated";

grant references on table "public"."enterprise_invoices" to "authenticated";

grant select on table "public"."enterprise_invoices" to "authenticated";

grant trigger on table "public"."enterprise_invoices" to "authenticated";

grant truncate on table "public"."enterprise_invoices" to "authenticated";

grant update on table "public"."enterprise_invoices" to "authenticated";

grant delete on table "public"."enterprise_invoices" to "service_role";

grant insert on table "public"."enterprise_invoices" to "service_role";

grant references on table "public"."enterprise_invoices" to "service_role";

grant select on table "public"."enterprise_invoices" to "service_role";

grant trigger on table "public"."enterprise_invoices" to "service_role";

grant truncate on table "public"."enterprise_invoices" to "service_role";

grant update on table "public"."enterprise_invoices" to "service_role";

grant delete on table "public"."event_news_comments" to "anon";

grant insert on table "public"."event_news_comments" to "anon";

grant references on table "public"."event_news_comments" to "anon";

grant select on table "public"."event_news_comments" to "anon";

grant trigger on table "public"."event_news_comments" to "anon";

grant truncate on table "public"."event_news_comments" to "anon";

grant update on table "public"."event_news_comments" to "anon";

grant delete on table "public"."event_news_comments" to "authenticated";

grant insert on table "public"."event_news_comments" to "authenticated";

grant references on table "public"."event_news_comments" to "authenticated";

grant select on table "public"."event_news_comments" to "authenticated";

grant trigger on table "public"."event_news_comments" to "authenticated";

grant truncate on table "public"."event_news_comments" to "authenticated";

grant update on table "public"."event_news_comments" to "authenticated";

grant delete on table "public"."event_news_comments" to "service_role";

grant insert on table "public"."event_news_comments" to "service_role";

grant references on table "public"."event_news_comments" to "service_role";

grant select on table "public"."event_news_comments" to "service_role";

grant trigger on table "public"."event_news_comments" to "service_role";

grant truncate on table "public"."event_news_comments" to "service_role";

grant update on table "public"."event_news_comments" to "service_role";

grant delete on table "public"."event_news_likes" to "anon";

grant insert on table "public"."event_news_likes" to "anon";

grant references on table "public"."event_news_likes" to "anon";

grant select on table "public"."event_news_likes" to "anon";

grant trigger on table "public"."event_news_likes" to "anon";

grant truncate on table "public"."event_news_likes" to "anon";

grant update on table "public"."event_news_likes" to "anon";

grant delete on table "public"."event_news_likes" to "authenticated";

grant insert on table "public"."event_news_likes" to "authenticated";

grant references on table "public"."event_news_likes" to "authenticated";

grant select on table "public"."event_news_likes" to "authenticated";

grant trigger on table "public"."event_news_likes" to "authenticated";

grant truncate on table "public"."event_news_likes" to "authenticated";

grant update on table "public"."event_news_likes" to "authenticated";

grant delete on table "public"."event_news_likes" to "service_role";

grant insert on table "public"."event_news_likes" to "service_role";

grant references on table "public"."event_news_likes" to "service_role";

grant select on table "public"."event_news_likes" to "service_role";

grant trigger on table "public"."event_news_likes" to "service_role";

grant truncate on table "public"."event_news_likes" to "service_role";

grant update on table "public"."event_news_likes" to "service_role";

grant delete on table "public"."event_news_posts" to "anon";

grant insert on table "public"."event_news_posts" to "anon";

grant references on table "public"."event_news_posts" to "anon";

grant select on table "public"."event_news_posts" to "anon";

grant trigger on table "public"."event_news_posts" to "anon";

grant truncate on table "public"."event_news_posts" to "anon";

grant update on table "public"."event_news_posts" to "anon";

grant delete on table "public"."event_news_posts" to "authenticated";

grant insert on table "public"."event_news_posts" to "authenticated";

grant references on table "public"."event_news_posts" to "authenticated";

grant select on table "public"."event_news_posts" to "authenticated";

grant trigger on table "public"."event_news_posts" to "authenticated";

grant truncate on table "public"."event_news_posts" to "authenticated";

grant update on table "public"."event_news_posts" to "authenticated";

grant delete on table "public"."event_news_posts" to "service_role";

grant insert on table "public"."event_news_posts" to "service_role";

grant references on table "public"."event_news_posts" to "service_role";

grant select on table "public"."event_news_posts" to "service_role";

grant trigger on table "public"."event_news_posts" to "service_role";

grant truncate on table "public"."event_news_posts" to "service_role";

grant update on table "public"."event_news_posts" to "service_role";

grant delete on table "public"."event_registrations" to "anon";

grant insert on table "public"."event_registrations" to "anon";

grant references on table "public"."event_registrations" to "anon";

grant select on table "public"."event_registrations" to "anon";

grant trigger on table "public"."event_registrations" to "anon";

grant truncate on table "public"."event_registrations" to "anon";

grant update on table "public"."event_registrations" to "anon";

grant delete on table "public"."event_registrations" to "authenticated";

grant insert on table "public"."event_registrations" to "authenticated";

grant references on table "public"."event_registrations" to "authenticated";

grant select on table "public"."event_registrations" to "authenticated";

grant trigger on table "public"."event_registrations" to "authenticated";

grant truncate on table "public"."event_registrations" to "authenticated";

grant update on table "public"."event_registrations" to "authenticated";

grant delete on table "public"."event_registrations" to "service_role";

grant insert on table "public"."event_registrations" to "service_role";

grant references on table "public"."event_registrations" to "service_role";

grant select on table "public"."event_registrations" to "service_role";

grant trigger on table "public"."event_registrations" to "service_role";

grant truncate on table "public"."event_registrations" to "service_role";

grant update on table "public"."event_registrations" to "service_role";

grant delete on table "public"."events" to "anon";

grant insert on table "public"."events" to "anon";

grant references on table "public"."events" to "anon";

grant select on table "public"."events" to "anon";

grant trigger on table "public"."events" to "anon";

grant truncate on table "public"."events" to "anon";

grant update on table "public"."events" to "anon";

grant delete on table "public"."events" to "authenticated";

grant insert on table "public"."events" to "authenticated";

grant references on table "public"."events" to "authenticated";

grant select on table "public"."events" to "authenticated";

grant trigger on table "public"."events" to "authenticated";

grant truncate on table "public"."events" to "authenticated";

grant update on table "public"."events" to "authenticated";

grant delete on table "public"."events" to "service_role";

grant insert on table "public"."events" to "service_role";

grant references on table "public"."events" to "service_role";

grant select on table "public"."events" to "service_role";

grant trigger on table "public"."events" to "service_role";

grant truncate on table "public"."events" to "service_role";

grant update on table "public"."events" to "service_role";

grant delete on table "public"."events_v2" to "anon";

grant insert on table "public"."events_v2" to "anon";

grant references on table "public"."events_v2" to "anon";

grant select on table "public"."events_v2" to "anon";

grant trigger on table "public"."events_v2" to "anon";

grant truncate on table "public"."events_v2" to "anon";

grant update on table "public"."events_v2" to "anon";

grant delete on table "public"."events_v2" to "authenticated";

grant insert on table "public"."events_v2" to "authenticated";

grant references on table "public"."events_v2" to "authenticated";

grant select on table "public"."events_v2" to "authenticated";

grant trigger on table "public"."events_v2" to "authenticated";

grant truncate on table "public"."events_v2" to "authenticated";

grant update on table "public"."events_v2" to "authenticated";

grant delete on table "public"."events_v2" to "service_role";

grant insert on table "public"."events_v2" to "service_role";

grant references on table "public"."events_v2" to "service_role";

grant select on table "public"."events_v2" to "service_role";

grant trigger on table "public"."events_v2" to "service_role";

grant truncate on table "public"."events_v2" to "service_role";

grant update on table "public"."events_v2" to "service_role";

grant delete on table "public"."favorites" to "anon";

grant insert on table "public"."favorites" to "anon";

grant references on table "public"."favorites" to "anon";

grant select on table "public"."favorites" to "anon";

grant trigger on table "public"."favorites" to "anon";

grant truncate on table "public"."favorites" to "anon";

grant update on table "public"."favorites" to "anon";

grant delete on table "public"."favorites" to "authenticated";

grant insert on table "public"."favorites" to "authenticated";

grant references on table "public"."favorites" to "authenticated";

grant select on table "public"."favorites" to "authenticated";

grant trigger on table "public"."favorites" to "authenticated";

grant truncate on table "public"."favorites" to "authenticated";

grant update on table "public"."favorites" to "authenticated";

grant delete on table "public"."favorites" to "service_role";

grant insert on table "public"."favorites" to "service_role";

grant references on table "public"."favorites" to "service_role";

grant select on table "public"."favorites" to "service_role";

grant trigger on table "public"."favorites" to "service_role";

grant truncate on table "public"."favorites" to "service_role";

grant update on table "public"."favorites" to "service_role";

grant delete on table "public"."group_conversation_members" to "anon";

grant insert on table "public"."group_conversation_members" to "anon";

grant references on table "public"."group_conversation_members" to "anon";

grant select on table "public"."group_conversation_members" to "anon";

grant trigger on table "public"."group_conversation_members" to "anon";

grant truncate on table "public"."group_conversation_members" to "anon";

grant update on table "public"."group_conversation_members" to "anon";

grant delete on table "public"."group_conversation_members" to "authenticated";

grant insert on table "public"."group_conversation_members" to "authenticated";

grant references on table "public"."group_conversation_members" to "authenticated";

grant select on table "public"."group_conversation_members" to "authenticated";

grant trigger on table "public"."group_conversation_members" to "authenticated";

grant truncate on table "public"."group_conversation_members" to "authenticated";

grant update on table "public"."group_conversation_members" to "authenticated";

grant delete on table "public"."group_conversation_members" to "service_role";

grant insert on table "public"."group_conversation_members" to "service_role";

grant references on table "public"."group_conversation_members" to "service_role";

grant select on table "public"."group_conversation_members" to "service_role";

grant trigger on table "public"."group_conversation_members" to "service_role";

grant truncate on table "public"."group_conversation_members" to "service_role";

grant update on table "public"."group_conversation_members" to "service_role";

grant delete on table "public"."group_conversations" to "anon";

grant insert on table "public"."group_conversations" to "anon";

grant references on table "public"."group_conversations" to "anon";

grant select on table "public"."group_conversations" to "anon";

grant trigger on table "public"."group_conversations" to "anon";

grant truncate on table "public"."group_conversations" to "anon";

grant update on table "public"."group_conversations" to "anon";

grant delete on table "public"."group_conversations" to "authenticated";

grant insert on table "public"."group_conversations" to "authenticated";

grant references on table "public"."group_conversations" to "authenticated";

grant select on table "public"."group_conversations" to "authenticated";

grant trigger on table "public"."group_conversations" to "authenticated";

grant truncate on table "public"."group_conversations" to "authenticated";

grant update on table "public"."group_conversations" to "authenticated";

grant delete on table "public"."group_conversations" to "service_role";

grant insert on table "public"."group_conversations" to "service_role";

grant references on table "public"."group_conversations" to "service_role";

grant select on table "public"."group_conversations" to "service_role";

grant trigger on table "public"."group_conversations" to "service_role";

grant truncate on table "public"."group_conversations" to "service_role";

grant update on table "public"."group_conversations" to "service_role";

grant delete on table "public"."group_messages" to "anon";

grant insert on table "public"."group_messages" to "anon";

grant references on table "public"."group_messages" to "anon";

grant select on table "public"."group_messages" to "anon";

grant trigger on table "public"."group_messages" to "anon";

grant truncate on table "public"."group_messages" to "anon";

grant update on table "public"."group_messages" to "anon";

grant delete on table "public"."group_messages" to "authenticated";

grant insert on table "public"."group_messages" to "authenticated";

grant references on table "public"."group_messages" to "authenticated";

grant select on table "public"."group_messages" to "authenticated";

grant trigger on table "public"."group_messages" to "authenticated";

grant truncate on table "public"."group_messages" to "authenticated";

grant update on table "public"."group_messages" to "authenticated";

grant delete on table "public"."group_messages" to "service_role";

grant insert on table "public"."group_messages" to "service_role";

grant references on table "public"."group_messages" to "service_role";

grant select on table "public"."group_messages" to "service_role";

grant trigger on table "public"."group_messages" to "service_role";

grant truncate on table "public"."group_messages" to "service_role";

grant update on table "public"."group_messages" to "service_role";

grant delete on table "public"."interests" to "anon";

grant insert on table "public"."interests" to "anon";

grant references on table "public"."interests" to "anon";

grant select on table "public"."interests" to "anon";

grant trigger on table "public"."interests" to "anon";

grant truncate on table "public"."interests" to "anon";

grant update on table "public"."interests" to "anon";

grant delete on table "public"."interests" to "authenticated";

grant insert on table "public"."interests" to "authenticated";

grant references on table "public"."interests" to "authenticated";

grant select on table "public"."interests" to "authenticated";

grant trigger on table "public"."interests" to "authenticated";

grant truncate on table "public"."interests" to "authenticated";

grant update on table "public"."interests" to "authenticated";

grant delete on table "public"."interests" to "service_role";

grant insert on table "public"."interests" to "service_role";

grant references on table "public"."interests" to "service_role";

grant select on table "public"."interests" to "service_role";

grant trigger on table "public"."interests" to "service_role";

grant truncate on table "public"."interests" to "service_role";

grant update on table "public"."interests" to "service_role";

grant delete on table "public"."media_comments" to "anon";

grant insert on table "public"."media_comments" to "anon";

grant references on table "public"."media_comments" to "anon";

grant select on table "public"."media_comments" to "anon";

grant trigger on table "public"."media_comments" to "anon";

grant truncate on table "public"."media_comments" to "anon";

grant update on table "public"."media_comments" to "anon";

grant delete on table "public"."media_comments" to "authenticated";

grant insert on table "public"."media_comments" to "authenticated";

grant references on table "public"."media_comments" to "authenticated";

grant select on table "public"."media_comments" to "authenticated";

grant trigger on table "public"."media_comments" to "authenticated";

grant truncate on table "public"."media_comments" to "authenticated";

grant update on table "public"."media_comments" to "authenticated";

grant delete on table "public"."media_comments" to "service_role";

grant insert on table "public"."media_comments" to "service_role";

grant references on table "public"."media_comments" to "service_role";

grant select on table "public"."media_comments" to "service_role";

grant trigger on table "public"."media_comments" to "service_role";

grant truncate on table "public"."media_comments" to "service_role";

grant update on table "public"."media_comments" to "service_role";

grant delete on table "public"."media_likes" to "anon";

grant insert on table "public"."media_likes" to "anon";

grant references on table "public"."media_likes" to "anon";

grant select on table "public"."media_likes" to "anon";

grant trigger on table "public"."media_likes" to "anon";

grant truncate on table "public"."media_likes" to "anon";

grant update on table "public"."media_likes" to "anon";

grant delete on table "public"."media_likes" to "authenticated";

grant insert on table "public"."media_likes" to "authenticated";

grant references on table "public"."media_likes" to "authenticated";

grant select on table "public"."media_likes" to "authenticated";

grant trigger on table "public"."media_likes" to "authenticated";

grant truncate on table "public"."media_likes" to "authenticated";

grant update on table "public"."media_likes" to "authenticated";

grant delete on table "public"."media_likes" to "service_role";

grant insert on table "public"."media_likes" to "service_role";

grant references on table "public"."media_likes" to "service_role";

grant select on table "public"."media_likes" to "service_role";

grant trigger on table "public"."media_likes" to "service_role";

grant truncate on table "public"."media_likes" to "service_role";

grant update on table "public"."media_likes" to "service_role";

grant delete on table "public"."media_uploads" to "anon";

grant insert on table "public"."media_uploads" to "anon";

grant references on table "public"."media_uploads" to "anon";

grant select on table "public"."media_uploads" to "anon";

grant trigger on table "public"."media_uploads" to "anon";

grant truncate on table "public"."media_uploads" to "anon";

grant update on table "public"."media_uploads" to "anon";

grant delete on table "public"."media_uploads" to "authenticated";

grant insert on table "public"."media_uploads" to "authenticated";

grant references on table "public"."media_uploads" to "authenticated";

grant select on table "public"."media_uploads" to "authenticated";

grant trigger on table "public"."media_uploads" to "authenticated";

grant truncate on table "public"."media_uploads" to "authenticated";

grant update on table "public"."media_uploads" to "authenticated";

grant delete on table "public"."media_uploads" to "service_role";

grant insert on table "public"."media_uploads" to "service_role";

grant references on table "public"."media_uploads" to "service_role";

grant select on table "public"."media_uploads" to "service_role";

grant trigger on table "public"."media_uploads" to "service_role";

grant truncate on table "public"."media_uploads" to "service_role";

grant update on table "public"."media_uploads" to "service_role";

grant delete on table "public"."messages" to "anon";

grant insert on table "public"."messages" to "anon";

grant references on table "public"."messages" to "anon";

grant select on table "public"."messages" to "anon";

grant trigger on table "public"."messages" to "anon";

grant truncate on table "public"."messages" to "anon";

grant update on table "public"."messages" to "anon";

grant delete on table "public"."messages" to "authenticated";

grant insert on table "public"."messages" to "authenticated";

grant references on table "public"."messages" to "authenticated";

grant select on table "public"."messages" to "authenticated";

grant trigger on table "public"."messages" to "authenticated";

grant truncate on table "public"."messages" to "authenticated";

grant update on table "public"."messages" to "authenticated";

grant delete on table "public"."messages" to "service_role";

grant insert on table "public"."messages" to "service_role";

grant references on table "public"."messages" to "service_role";

grant select on table "public"."messages" to "service_role";

grant trigger on table "public"."messages" to "service_role";

grant truncate on table "public"."messages" to "service_role";

grant update on table "public"."messages" to "service_role";

grant delete on table "public"."notifications" to "anon";

grant insert on table "public"."notifications" to "anon";

grant references on table "public"."notifications" to "anon";

grant select on table "public"."notifications" to "anon";

grant trigger on table "public"."notifications" to "anon";

grant truncate on table "public"."notifications" to "anon";

grant update on table "public"."notifications" to "anon";

grant delete on table "public"."notifications" to "authenticated";

grant insert on table "public"."notifications" to "authenticated";

grant references on table "public"."notifications" to "authenticated";

grant select on table "public"."notifications" to "authenticated";

grant trigger on table "public"."notifications" to "authenticated";

grant truncate on table "public"."notifications" to "authenticated";

grant update on table "public"."notifications" to "authenticated";

grant delete on table "public"."notifications" to "service_role";

grant insert on table "public"."notifications" to "service_role";

grant references on table "public"."notifications" to "service_role";

grant select on table "public"."notifications" to "service_role";

grant trigger on table "public"."notifications" to "service_role";

grant truncate on table "public"."notifications" to "service_role";

grant update on table "public"."notifications" to "service_role";

grant delete on table "public"."panicEvents" to "anon";

grant insert on table "public"."panicEvents" to "anon";

grant references on table "public"."panicEvents" to "anon";

grant select on table "public"."panicEvents" to "anon";

grant trigger on table "public"."panicEvents" to "anon";

grant truncate on table "public"."panicEvents" to "anon";

grant update on table "public"."panicEvents" to "anon";

grant delete on table "public"."panicEvents" to "authenticated";

grant insert on table "public"."panicEvents" to "authenticated";

grant references on table "public"."panicEvents" to "authenticated";

grant select on table "public"."panicEvents" to "authenticated";

grant trigger on table "public"."panicEvents" to "authenticated";

grant truncate on table "public"."panicEvents" to "authenticated";

grant update on table "public"."panicEvents" to "authenticated";

grant delete on table "public"."panicEvents" to "service_role";

grant insert on table "public"."panicEvents" to "service_role";

grant references on table "public"."panicEvents" to "service_role";

grant select on table "public"."panicEvents" to "service_role";

grant trigger on table "public"."panicEvents" to "service_role";

grant truncate on table "public"."panicEvents" to "service_role";

grant update on table "public"."panicEvents" to "service_role";

grant delete on table "public"."payment_methods" to "anon";

grant insert on table "public"."payment_methods" to "anon";

grant references on table "public"."payment_methods" to "anon";

grant select on table "public"."payment_methods" to "anon";

grant trigger on table "public"."payment_methods" to "anon";

grant truncate on table "public"."payment_methods" to "anon";

grant update on table "public"."payment_methods" to "anon";

grant delete on table "public"."payment_methods" to "authenticated";

grant insert on table "public"."payment_methods" to "authenticated";

grant references on table "public"."payment_methods" to "authenticated";

grant select on table "public"."payment_methods" to "authenticated";

grant trigger on table "public"."payment_methods" to "authenticated";

grant truncate on table "public"."payment_methods" to "authenticated";

grant update on table "public"."payment_methods" to "authenticated";

grant delete on table "public"."payment_methods" to "service_role";

grant insert on table "public"."payment_methods" to "service_role";

grant references on table "public"."payment_methods" to "service_role";

grant select on table "public"."payment_methods" to "service_role";

grant trigger on table "public"."payment_methods" to "service_role";

grant truncate on table "public"."payment_methods" to "service_role";

grant update on table "public"."payment_methods" to "service_role";

grant delete on table "public"."payments" to "anon";

grant insert on table "public"."payments" to "anon";

grant references on table "public"."payments" to "anon";

grant select on table "public"."payments" to "anon";

grant trigger on table "public"."payments" to "anon";

grant truncate on table "public"."payments" to "anon";

grant update on table "public"."payments" to "anon";

grant delete on table "public"."payments" to "authenticated";

grant insert on table "public"."payments" to "authenticated";

grant references on table "public"."payments" to "authenticated";

grant select on table "public"."payments" to "authenticated";

grant trigger on table "public"."payments" to "authenticated";

grant truncate on table "public"."payments" to "authenticated";

grant update on table "public"."payments" to "authenticated";

grant delete on table "public"."payments" to "service_role";

grant insert on table "public"."payments" to "service_role";

grant references on table "public"."payments" to "service_role";

grant select on table "public"."payments" to "service_role";

grant trigger on table "public"."payments" to "service_role";

grant truncate on table "public"."payments" to "service_role";

grant update on table "public"."payments" to "service_role";

grant delete on table "public"."photos" to "anon";

grant insert on table "public"."photos" to "anon";

grant references on table "public"."photos" to "anon";

grant select on table "public"."photos" to "anon";

grant trigger on table "public"."photos" to "anon";

grant truncate on table "public"."photos" to "anon";

grant update on table "public"."photos" to "anon";

grant delete on table "public"."photos" to "authenticated";

grant insert on table "public"."photos" to "authenticated";

grant references on table "public"."photos" to "authenticated";

grant select on table "public"."photos" to "authenticated";

grant trigger on table "public"."photos" to "authenticated";

grant truncate on table "public"."photos" to "authenticated";

grant update on table "public"."photos" to "authenticated";

grant delete on table "public"."photos" to "service_role";

grant insert on table "public"."photos" to "service_role";

grant references on table "public"."photos" to "service_role";

grant select on table "public"."photos" to "service_role";

grant trigger on table "public"."photos" to "service_role";

grant truncate on table "public"."photos" to "service_role";

grant update on table "public"."photos" to "service_role";

grant delete on table "public"."profanity_terms" to "anon";

grant insert on table "public"."profanity_terms" to "anon";

grant references on table "public"."profanity_terms" to "anon";

grant select on table "public"."profanity_terms" to "anon";

grant trigger on table "public"."profanity_terms" to "anon";

grant truncate on table "public"."profanity_terms" to "anon";

grant update on table "public"."profanity_terms" to "anon";

grant delete on table "public"."profanity_terms" to "authenticated";

grant insert on table "public"."profanity_terms" to "authenticated";

grant references on table "public"."profanity_terms" to "authenticated";

grant select on table "public"."profanity_terms" to "authenticated";

grant trigger on table "public"."profanity_terms" to "authenticated";

grant truncate on table "public"."profanity_terms" to "authenticated";

grant update on table "public"."profanity_terms" to "authenticated";

grant delete on table "public"."profanity_terms" to "service_role";

grant insert on table "public"."profanity_terms" to "service_role";

grant references on table "public"."profanity_terms" to "service_role";

grant select on table "public"."profanity_terms" to "service_role";

grant trigger on table "public"."profanity_terms" to "service_role";

grant truncate on table "public"."profanity_terms" to "service_role";

grant update on table "public"."profanity_terms" to "service_role";

grant delete on table "public"."profile_delete_backups" to "anon";

grant insert on table "public"."profile_delete_backups" to "anon";

grant references on table "public"."profile_delete_backups" to "anon";

grant select on table "public"."profile_delete_backups" to "anon";

grant trigger on table "public"."profile_delete_backups" to "anon";

grant truncate on table "public"."profile_delete_backups" to "anon";

grant update on table "public"."profile_delete_backups" to "anon";

grant delete on table "public"."profile_delete_backups" to "authenticated";

grant insert on table "public"."profile_delete_backups" to "authenticated";

grant references on table "public"."profile_delete_backups" to "authenticated";

grant select on table "public"."profile_delete_backups" to "authenticated";

grant trigger on table "public"."profile_delete_backups" to "authenticated";

grant truncate on table "public"."profile_delete_backups" to "authenticated";

grant update on table "public"."profile_delete_backups" to "authenticated";

grant delete on table "public"."profile_delete_backups" to "service_role";

grant insert on table "public"."profile_delete_backups" to "service_role";

grant references on table "public"."profile_delete_backups" to "service_role";

grant select on table "public"."profile_delete_backups" to "service_role";

grant trigger on table "public"."profile_delete_backups" to "service_role";

grant truncate on table "public"."profile_delete_backups" to "service_role";

grant update on table "public"."profile_delete_backups" to "service_role";

grant delete on table "public"."profile_likes" to "anon";

grant insert on table "public"."profile_likes" to "anon";

grant references on table "public"."profile_likes" to "anon";

grant select on table "public"."profile_likes" to "anon";

grant trigger on table "public"."profile_likes" to "anon";

grant truncate on table "public"."profile_likes" to "anon";

grant update on table "public"."profile_likes" to "anon";

grant delete on table "public"."profile_likes" to "authenticated";

grant insert on table "public"."profile_likes" to "authenticated";

grant references on table "public"."profile_likes" to "authenticated";

grant select on table "public"."profile_likes" to "authenticated";

grant trigger on table "public"."profile_likes" to "authenticated";

grant truncate on table "public"."profile_likes" to "authenticated";

grant update on table "public"."profile_likes" to "authenticated";

grant delete on table "public"."profile_likes" to "service_role";

grant insert on table "public"."profile_likes" to "service_role";

grant references on table "public"."profile_likes" to "service_role";

grant select on table "public"."profile_likes" to "service_role";

grant trigger on table "public"."profile_likes" to "service_role";

grant truncate on table "public"."profile_likes" to "service_role";

grant update on table "public"."profile_likes" to "service_role";

grant delete on table "public"."profile_media" to "anon";

grant insert on table "public"."profile_media" to "anon";

grant references on table "public"."profile_media" to "anon";

grant select on table "public"."profile_media" to "anon";

grant trigger on table "public"."profile_media" to "anon";

grant truncate on table "public"."profile_media" to "anon";

grant update on table "public"."profile_media" to "anon";

grant delete on table "public"."profile_media" to "authenticated";

grant insert on table "public"."profile_media" to "authenticated";

grant references on table "public"."profile_media" to "authenticated";

grant select on table "public"."profile_media" to "authenticated";

grant trigger on table "public"."profile_media" to "authenticated";

grant truncate on table "public"."profile_media" to "authenticated";

grant update on table "public"."profile_media" to "authenticated";

grant delete on table "public"."profile_media" to "service_role";

grant insert on table "public"."profile_media" to "service_role";

grant references on table "public"."profile_media" to "service_role";

grant select on table "public"."profile_media" to "service_role";

grant trigger on table "public"."profile_media" to "service_role";

grant truncate on table "public"."profile_media" to "service_role";

grant update on table "public"."profile_media" to "service_role";

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

grant delete on table "public"."profiles_backup" to "anon";

grant insert on table "public"."profiles_backup" to "anon";

grant references on table "public"."profiles_backup" to "anon";

grant select on table "public"."profiles_backup" to "anon";

grant trigger on table "public"."profiles_backup" to "anon";

grant truncate on table "public"."profiles_backup" to "anon";

grant update on table "public"."profiles_backup" to "anon";

grant delete on table "public"."profiles_backup" to "authenticated";

grant insert on table "public"."profiles_backup" to "authenticated";

grant references on table "public"."profiles_backup" to "authenticated";

grant select on table "public"."profiles_backup" to "authenticated";

grant trigger on table "public"."profiles_backup" to "authenticated";

grant truncate on table "public"."profiles_backup" to "authenticated";

grant update on table "public"."profiles_backup" to "authenticated";

grant delete on table "public"."profiles_backup" to "service_role";

grant insert on table "public"."profiles_backup" to "service_role";

grant references on table "public"."profiles_backup" to "service_role";

grant select on table "public"."profiles_backup" to "service_role";

grant trigger on table "public"."profiles_backup" to "service_role";

grant truncate on table "public"."profiles_backup" to "service_role";

grant update on table "public"."profiles_backup" to "service_role";

grant delete on table "public"."push_tokens" to "anon";

grant insert on table "public"."push_tokens" to "anon";

grant references on table "public"."push_tokens" to "anon";

grant select on table "public"."push_tokens" to "anon";

grant trigger on table "public"."push_tokens" to "anon";

grant truncate on table "public"."push_tokens" to "anon";

grant update on table "public"."push_tokens" to "anon";

grant delete on table "public"."push_tokens" to "authenticated";

grant insert on table "public"."push_tokens" to "authenticated";

grant references on table "public"."push_tokens" to "authenticated";

grant select on table "public"."push_tokens" to "authenticated";

grant trigger on table "public"."push_tokens" to "authenticated";

grant truncate on table "public"."push_tokens" to "authenticated";

grant update on table "public"."push_tokens" to "authenticated";

grant delete on table "public"."push_tokens" to "service_role";

grant insert on table "public"."push_tokens" to "service_role";

grant references on table "public"."push_tokens" to "service_role";

grant select on table "public"."push_tokens" to "service_role";

grant trigger on table "public"."push_tokens" to "service_role";

grant truncate on table "public"."push_tokens" to "service_role";

grant update on table "public"."push_tokens" to "service_role";

grant delete on table "public"."reports" to "anon";

grant insert on table "public"."reports" to "anon";

grant references on table "public"."reports" to "anon";

grant select on table "public"."reports" to "anon";

grant trigger on table "public"."reports" to "anon";

grant truncate on table "public"."reports" to "anon";

grant update on table "public"."reports" to "anon";

grant delete on table "public"."reports" to "authenticated";

grant insert on table "public"."reports" to "authenticated";

grant references on table "public"."reports" to "authenticated";

grant select on table "public"."reports" to "authenticated";

grant trigger on table "public"."reports" to "authenticated";

grant truncate on table "public"."reports" to "authenticated";

grant update on table "public"."reports" to "authenticated";

grant delete on table "public"."reports" to "service_role";

grant insert on table "public"."reports" to "service_role";

grant references on table "public"."reports" to "service_role";

grant select on table "public"."reports" to "service_role";

grant trigger on table "public"."reports" to "service_role";

grant truncate on table "public"."reports" to "service_role";

grant update on table "public"."reports" to "service_role";

grant delete on table "public"."review_notification_outbox" to "anon";

grant insert on table "public"."review_notification_outbox" to "anon";

grant references on table "public"."review_notification_outbox" to "anon";

grant select on table "public"."review_notification_outbox" to "anon";

grant trigger on table "public"."review_notification_outbox" to "anon";

grant truncate on table "public"."review_notification_outbox" to "anon";

grant update on table "public"."review_notification_outbox" to "anon";

grant delete on table "public"."review_notification_outbox" to "authenticated";

grant insert on table "public"."review_notification_outbox" to "authenticated";

grant references on table "public"."review_notification_outbox" to "authenticated";

grant select on table "public"."review_notification_outbox" to "authenticated";

grant trigger on table "public"."review_notification_outbox" to "authenticated";

grant truncate on table "public"."review_notification_outbox" to "authenticated";

grant update on table "public"."review_notification_outbox" to "authenticated";

grant delete on table "public"."review_notification_outbox" to "service_role";

grant insert on table "public"."review_notification_outbox" to "service_role";

grant references on table "public"."review_notification_outbox" to "service_role";

grant select on table "public"."review_notification_outbox" to "service_role";

grant trigger on table "public"."review_notification_outbox" to "service_role";

grant truncate on table "public"."review_notification_outbox" to "service_role";

grant update on table "public"."review_notification_outbox" to "service_role";

grant delete on table "public"."reviews" to "anon";

grant insert on table "public"."reviews" to "anon";

grant references on table "public"."reviews" to "anon";

grant select on table "public"."reviews" to "anon";

grant trigger on table "public"."reviews" to "anon";

grant truncate on table "public"."reviews" to "anon";

grant update on table "public"."reviews" to "anon";

grant delete on table "public"."reviews" to "authenticated";

grant insert on table "public"."reviews" to "authenticated";

grant references on table "public"."reviews" to "authenticated";

grant select on table "public"."reviews" to "authenticated";

grant trigger on table "public"."reviews" to "authenticated";

grant truncate on table "public"."reviews" to "authenticated";

grant update on table "public"."reviews" to "authenticated";

grant delete on table "public"."reviews" to "service_role";

grant insert on table "public"."reviews" to "service_role";

grant references on table "public"."reviews" to "service_role";

grant select on table "public"."reviews" to "service_role";

grant trigger on table "public"."reviews" to "service_role";

grant truncate on table "public"."reviews" to "service_role";

grant update on table "public"."reviews" to "service_role";

grant delete on table "public"."reviews_v2" to "anon";

grant insert on table "public"."reviews_v2" to "anon";

grant references on table "public"."reviews_v2" to "anon";

grant select on table "public"."reviews_v2" to "anon";

grant trigger on table "public"."reviews_v2" to "anon";

grant truncate on table "public"."reviews_v2" to "anon";

grant update on table "public"."reviews_v2" to "anon";

grant delete on table "public"."reviews_v2" to "authenticated";

grant insert on table "public"."reviews_v2" to "authenticated";

grant references on table "public"."reviews_v2" to "authenticated";

grant select on table "public"."reviews_v2" to "authenticated";

grant trigger on table "public"."reviews_v2" to "authenticated";

grant truncate on table "public"."reviews_v2" to "authenticated";

grant update on table "public"."reviews_v2" to "authenticated";

grant delete on table "public"."reviews_v2" to "service_role";

grant insert on table "public"."reviews_v2" to "service_role";

grant references on table "public"."reviews_v2" to "service_role";

grant select on table "public"."reviews_v2" to "service_role";

grant trigger on table "public"."reviews_v2" to "service_role";

grant truncate on table "public"."reviews_v2" to "service_role";

grant update on table "public"."reviews_v2" to "service_role";

grant delete on table "public"."roles" to "anon";

grant insert on table "public"."roles" to "anon";

grant references on table "public"."roles" to "anon";

grant select on table "public"."roles" to "anon";

grant trigger on table "public"."roles" to "anon";

grant truncate on table "public"."roles" to "anon";

grant update on table "public"."roles" to "anon";

grant delete on table "public"."roles" to "authenticated";

grant insert on table "public"."roles" to "authenticated";

grant references on table "public"."roles" to "authenticated";

grant select on table "public"."roles" to "authenticated";

grant trigger on table "public"."roles" to "authenticated";

grant truncate on table "public"."roles" to "authenticated";

grant update on table "public"."roles" to "authenticated";

grant delete on table "public"."roles" to "service_role";

grant insert on table "public"."roles" to "service_role";

grant references on table "public"."roles" to "service_role";

grant select on table "public"."roles" to "service_role";

grant trigger on table "public"."roles" to "service_role";

grant truncate on table "public"."roles" to "service_role";

grant update on table "public"."roles" to "service_role";

grant delete on table "public"."safetyFlags" to "anon";

grant insert on table "public"."safetyFlags" to "anon";

grant references on table "public"."safetyFlags" to "anon";

grant select on table "public"."safetyFlags" to "anon";

grant trigger on table "public"."safetyFlags" to "anon";

grant truncate on table "public"."safetyFlags" to "anon";

grant update on table "public"."safetyFlags" to "anon";

grant delete on table "public"."safetyFlags" to "authenticated";

grant insert on table "public"."safetyFlags" to "authenticated";

grant references on table "public"."safetyFlags" to "authenticated";

grant select on table "public"."safetyFlags" to "authenticated";

grant trigger on table "public"."safetyFlags" to "authenticated";

grant truncate on table "public"."safetyFlags" to "authenticated";

grant update on table "public"."safetyFlags" to "authenticated";

grant delete on table "public"."safetyFlags" to "service_role";

grant insert on table "public"."safetyFlags" to "service_role";

grant references on table "public"."safetyFlags" to "service_role";

grant select on table "public"."safetyFlags" to "service_role";

grant trigger on table "public"."safetyFlags" to "service_role";

grant truncate on table "public"."safetyFlags" to "service_role";

grant update on table "public"."safetyFlags" to "service_role";

grant delete on table "public"."seo_ai_rank_snapshots" to "anon";

grant insert on table "public"."seo_ai_rank_snapshots" to "anon";

grant references on table "public"."seo_ai_rank_snapshots" to "anon";

grant select on table "public"."seo_ai_rank_snapshots" to "anon";

grant trigger on table "public"."seo_ai_rank_snapshots" to "anon";

grant truncate on table "public"."seo_ai_rank_snapshots" to "anon";

grant update on table "public"."seo_ai_rank_snapshots" to "anon";

grant delete on table "public"."seo_ai_rank_snapshots" to "authenticated";

grant insert on table "public"."seo_ai_rank_snapshots" to "authenticated";

grant references on table "public"."seo_ai_rank_snapshots" to "authenticated";

grant select on table "public"."seo_ai_rank_snapshots" to "authenticated";

grant trigger on table "public"."seo_ai_rank_snapshots" to "authenticated";

grant truncate on table "public"."seo_ai_rank_snapshots" to "authenticated";

grant update on table "public"."seo_ai_rank_snapshots" to "authenticated";

grant delete on table "public"."seo_ai_rank_snapshots" to "service_role";

grant insert on table "public"."seo_ai_rank_snapshots" to "service_role";

grant references on table "public"."seo_ai_rank_snapshots" to "service_role";

grant select on table "public"."seo_ai_rank_snapshots" to "service_role";

grant trigger on table "public"."seo_ai_rank_snapshots" to "service_role";

grant truncate on table "public"."seo_ai_rank_snapshots" to "service_role";

grant update on table "public"."seo_ai_rank_snapshots" to "service_role";

grant delete on table "public"."seo_ai_tracking_queries" to "anon";

grant insert on table "public"."seo_ai_tracking_queries" to "anon";

grant references on table "public"."seo_ai_tracking_queries" to "anon";

grant select on table "public"."seo_ai_tracking_queries" to "anon";

grant trigger on table "public"."seo_ai_tracking_queries" to "anon";

grant truncate on table "public"."seo_ai_tracking_queries" to "anon";

grant update on table "public"."seo_ai_tracking_queries" to "anon";

grant delete on table "public"."seo_ai_tracking_queries" to "authenticated";

grant insert on table "public"."seo_ai_tracking_queries" to "authenticated";

grant references on table "public"."seo_ai_tracking_queries" to "authenticated";

grant select on table "public"."seo_ai_tracking_queries" to "authenticated";

grant trigger on table "public"."seo_ai_tracking_queries" to "authenticated";

grant truncate on table "public"."seo_ai_tracking_queries" to "authenticated";

grant update on table "public"."seo_ai_tracking_queries" to "authenticated";

grant delete on table "public"."seo_ai_tracking_queries" to "service_role";

grant insert on table "public"."seo_ai_tracking_queries" to "service_role";

grant references on table "public"."seo_ai_tracking_queries" to "service_role";

grant select on table "public"."seo_ai_tracking_queries" to "service_role";

grant trigger on table "public"."seo_ai_tracking_queries" to "service_role";

grant truncate on table "public"."seo_ai_tracking_queries" to "service_role";

grant update on table "public"."seo_ai_tracking_queries" to "service_role";

grant delete on table "public"."service_availability" to "anon";

grant insert on table "public"."service_availability" to "anon";

grant references on table "public"."service_availability" to "anon";

grant select on table "public"."service_availability" to "anon";

grant trigger on table "public"."service_availability" to "anon";

grant truncate on table "public"."service_availability" to "anon";

grant update on table "public"."service_availability" to "anon";

grant delete on table "public"."service_availability" to "authenticated";

grant insert on table "public"."service_availability" to "authenticated";

grant references on table "public"."service_availability" to "authenticated";

grant select on table "public"."service_availability" to "authenticated";

grant trigger on table "public"."service_availability" to "authenticated";

grant truncate on table "public"."service_availability" to "authenticated";

grant update on table "public"."service_availability" to "authenticated";

grant delete on table "public"."service_availability" to "service_role";

grant insert on table "public"."service_availability" to "service_role";

grant references on table "public"."service_availability" to "service_role";

grant select on table "public"."service_availability" to "service_role";

grant trigger on table "public"."service_availability" to "service_role";

grant truncate on table "public"."service_availability" to "service_role";

grant update on table "public"."service_availability" to "service_role";

grant delete on table "public"."service_bookings" to "anon";

grant insert on table "public"."service_bookings" to "anon";

grant references on table "public"."service_bookings" to "anon";

grant select on table "public"."service_bookings" to "anon";

grant trigger on table "public"."service_bookings" to "anon";

grant truncate on table "public"."service_bookings" to "anon";

grant update on table "public"."service_bookings" to "anon";

grant delete on table "public"."service_bookings" to "authenticated";

grant insert on table "public"."service_bookings" to "authenticated";

grant references on table "public"."service_bookings" to "authenticated";

grant select on table "public"."service_bookings" to "authenticated";

grant trigger on table "public"."service_bookings" to "authenticated";

grant truncate on table "public"."service_bookings" to "authenticated";

grant update on table "public"."service_bookings" to "authenticated";

grant delete on table "public"."service_bookings" to "service_role";

grant insert on table "public"."service_bookings" to "service_role";

grant references on table "public"."service_bookings" to "service_role";

grant select on table "public"."service_bookings" to "service_role";

grant trigger on table "public"."service_bookings" to "service_role";

grant truncate on table "public"."service_bookings" to "service_role";

grant update on table "public"."service_bookings" to "service_role";

grant delete on table "public"."service_providers_v2" to "anon";

grant insert on table "public"."service_providers_v2" to "anon";

grant references on table "public"."service_providers_v2" to "anon";

grant select on table "public"."service_providers_v2" to "anon";

grant trigger on table "public"."service_providers_v2" to "anon";

grant truncate on table "public"."service_providers_v2" to "anon";

grant update on table "public"."service_providers_v2" to "anon";

grant delete on table "public"."service_providers_v2" to "authenticated";

grant insert on table "public"."service_providers_v2" to "authenticated";

grant references on table "public"."service_providers_v2" to "authenticated";

grant select on table "public"."service_providers_v2" to "authenticated";

grant trigger on table "public"."service_providers_v2" to "authenticated";

grant truncate on table "public"."service_providers_v2" to "authenticated";

grant update on table "public"."service_providers_v2" to "authenticated";

grant delete on table "public"."service_providers_v2" to "service_role";

grant insert on table "public"."service_providers_v2" to "service_role";

grant references on table "public"."service_providers_v2" to "service_role";

grant select on table "public"."service_providers_v2" to "service_role";

grant trigger on table "public"."service_providers_v2" to "service_role";

grant truncate on table "public"."service_providers_v2" to "service_role";

grant update on table "public"."service_providers_v2" to "service_role";

grant delete on table "public"."service_reviews" to "anon";

grant insert on table "public"."service_reviews" to "anon";

grant references on table "public"."service_reviews" to "anon";

grant select on table "public"."service_reviews" to "anon";

grant trigger on table "public"."service_reviews" to "anon";

grant truncate on table "public"."service_reviews" to "anon";

grant update on table "public"."service_reviews" to "anon";

grant delete on table "public"."service_reviews" to "authenticated";

grant insert on table "public"."service_reviews" to "authenticated";

grant references on table "public"."service_reviews" to "authenticated";

grant select on table "public"."service_reviews" to "authenticated";

grant trigger on table "public"."service_reviews" to "authenticated";

grant truncate on table "public"."service_reviews" to "authenticated";

grant update on table "public"."service_reviews" to "authenticated";

grant delete on table "public"."service_reviews" to "service_role";

grant insert on table "public"."service_reviews" to "service_role";

grant references on table "public"."service_reviews" to "service_role";

grant select on table "public"."service_reviews" to "service_role";

grant trigger on table "public"."service_reviews" to "service_role";

grant truncate on table "public"."service_reviews" to "service_role";

grant update on table "public"."service_reviews" to "service_role";

grant delete on table "public"."services" to "anon";

grant insert on table "public"."services" to "anon";

grant references on table "public"."services" to "anon";

grant select on table "public"."services" to "anon";

grant trigger on table "public"."services" to "anon";

grant truncate on table "public"."services" to "anon";

grant update on table "public"."services" to "anon";

grant delete on table "public"."services" to "authenticated";

grant insert on table "public"."services" to "authenticated";

grant references on table "public"."services" to "authenticated";

grant select on table "public"."services" to "authenticated";

grant trigger on table "public"."services" to "authenticated";

grant truncate on table "public"."services" to "authenticated";

grant update on table "public"."services" to "authenticated";

grant delete on table "public"."services" to "service_role";

grant insert on table "public"."services" to "service_role";

grant references on table "public"."services" to "service_role";

grant select on table "public"."services" to "service_role";

grant trigger on table "public"."services" to "service_role";

grant truncate on table "public"."services" to "service_role";

grant update on table "public"."services" to "service_role";

grant delete on table "public"."spatial_ref_sys" to "anon";

grant insert on table "public"."spatial_ref_sys" to "anon";

grant references on table "public"."spatial_ref_sys" to "anon";

grant select on table "public"."spatial_ref_sys" to "anon";

grant trigger on table "public"."spatial_ref_sys" to "anon";

grant truncate on table "public"."spatial_ref_sys" to "anon";

grant update on table "public"."spatial_ref_sys" to "anon";

grant delete on table "public"."spatial_ref_sys" to "authenticated";

grant insert on table "public"."spatial_ref_sys" to "authenticated";

grant references on table "public"."spatial_ref_sys" to "authenticated";

grant select on table "public"."spatial_ref_sys" to "authenticated";

grant trigger on table "public"."spatial_ref_sys" to "authenticated";

grant truncate on table "public"."spatial_ref_sys" to "authenticated";

grant update on table "public"."spatial_ref_sys" to "authenticated";

grant delete on table "public"."spatial_ref_sys" to "postgres";

grant insert on table "public"."spatial_ref_sys" to "postgres";

grant references on table "public"."spatial_ref_sys" to "postgres";

grant select on table "public"."spatial_ref_sys" to "postgres";

grant trigger on table "public"."spatial_ref_sys" to "postgres";

grant truncate on table "public"."spatial_ref_sys" to "postgres";

grant update on table "public"."spatial_ref_sys" to "postgres";

grant delete on table "public"."spatial_ref_sys" to "service_role";

grant insert on table "public"."spatial_ref_sys" to "service_role";

grant references on table "public"."spatial_ref_sys" to "service_role";

grant select on table "public"."spatial_ref_sys" to "service_role";

grant trigger on table "public"."spatial_ref_sys" to "service_role";

grant truncate on table "public"."spatial_ref_sys" to "service_role";

grant update on table "public"."spatial_ref_sys" to "service_role";

grant delete on table "public"."subscriptions" to "anon";

grant insert on table "public"."subscriptions" to "anon";

grant references on table "public"."subscriptions" to "anon";

grant select on table "public"."subscriptions" to "anon";

grant trigger on table "public"."subscriptions" to "anon";

grant truncate on table "public"."subscriptions" to "anon";

grant update on table "public"."subscriptions" to "anon";

grant delete on table "public"."subscriptions" to "authenticated";

grant insert on table "public"."subscriptions" to "authenticated";

grant references on table "public"."subscriptions" to "authenticated";

grant select on table "public"."subscriptions" to "authenticated";

grant trigger on table "public"."subscriptions" to "authenticated";

grant truncate on table "public"."subscriptions" to "authenticated";

grant update on table "public"."subscriptions" to "authenticated";

grant delete on table "public"."subscriptions" to "service_role";

grant insert on table "public"."subscriptions" to "service_role";

grant references on table "public"."subscriptions" to "service_role";

grant select on table "public"."subscriptions" to "service_role";

grant trigger on table "public"."subscriptions" to "service_role";

grant truncate on table "public"."subscriptions" to "service_role";

grant update on table "public"."subscriptions" to "service_role";

grant delete on table "public"."transactions" to "anon";

grant insert on table "public"."transactions" to "anon";

grant references on table "public"."transactions" to "anon";

grant select on table "public"."transactions" to "anon";

grant trigger on table "public"."transactions" to "anon";

grant truncate on table "public"."transactions" to "anon";

grant update on table "public"."transactions" to "anon";

grant delete on table "public"."transactions" to "authenticated";

grant insert on table "public"."transactions" to "authenticated";

grant references on table "public"."transactions" to "authenticated";

grant select on table "public"."transactions" to "authenticated";

grant trigger on table "public"."transactions" to "authenticated";

grant truncate on table "public"."transactions" to "authenticated";

grant update on table "public"."transactions" to "authenticated";

grant delete on table "public"."transactions" to "service_role";

grant insert on table "public"."transactions" to "service_role";

grant references on table "public"."transactions" to "service_role";

grant select on table "public"."transactions" to "service_role";

grant trigger on table "public"."transactions" to "service_role";

grant truncate on table "public"."transactions" to "service_role";

grant update on table "public"."transactions" to "service_role";

grant delete on table "public"."transactions_v2" to "anon";

grant insert on table "public"."transactions_v2" to "anon";

grant references on table "public"."transactions_v2" to "anon";

grant select on table "public"."transactions_v2" to "anon";

grant trigger on table "public"."transactions_v2" to "anon";

grant truncate on table "public"."transactions_v2" to "anon";

grant update on table "public"."transactions_v2" to "anon";

grant delete on table "public"."transactions_v2" to "authenticated";

grant insert on table "public"."transactions_v2" to "authenticated";

grant references on table "public"."transactions_v2" to "authenticated";

grant select on table "public"."transactions_v2" to "authenticated";

grant trigger on table "public"."transactions_v2" to "authenticated";

grant truncate on table "public"."transactions_v2" to "authenticated";

grant update on table "public"."transactions_v2" to "authenticated";

grant delete on table "public"."transactions_v2" to "service_role";

grant insert on table "public"."transactions_v2" to "service_role";

grant references on table "public"."transactions_v2" to "service_role";

grant select on table "public"."transactions_v2" to "service_role";

grant trigger on table "public"."transactions_v2" to "service_role";

grant truncate on table "public"."transactions_v2" to "service_role";

grant update on table "public"."transactions_v2" to "service_role";

grant delete on table "public"."user_interests" to "anon";

grant insert on table "public"."user_interests" to "anon";

grant references on table "public"."user_interests" to "anon";

grant select on table "public"."user_interests" to "anon";

grant trigger on table "public"."user_interests" to "anon";

grant truncate on table "public"."user_interests" to "anon";

grant update on table "public"."user_interests" to "anon";

grant delete on table "public"."user_interests" to "authenticated";

grant insert on table "public"."user_interests" to "authenticated";

grant references on table "public"."user_interests" to "authenticated";

grant select on table "public"."user_interests" to "authenticated";

grant trigger on table "public"."user_interests" to "authenticated";

grant truncate on table "public"."user_interests" to "authenticated";

grant update on table "public"."user_interests" to "authenticated";

grant delete on table "public"."user_interests" to "service_role";

grant insert on table "public"."user_interests" to "service_role";

grant references on table "public"."user_interests" to "service_role";

grant select on table "public"."user_interests" to "service_role";

grant trigger on table "public"."user_interests" to "service_role";

grant truncate on table "public"."user_interests" to "service_role";

grant update on table "public"."user_interests" to "service_role";

grant delete on table "public"."users" to "anon";

grant insert on table "public"."users" to "anon";

grant references on table "public"."users" to "anon";

grant select on table "public"."users" to "anon";

grant trigger on table "public"."users" to "anon";

grant truncate on table "public"."users" to "anon";

grant update on table "public"."users" to "anon";

grant delete on table "public"."users" to "authenticated";

grant insert on table "public"."users" to "authenticated";

grant references on table "public"."users" to "authenticated";

grant select on table "public"."users" to "authenticated";

grant trigger on table "public"."users" to "authenticated";

grant truncate on table "public"."users" to "authenticated";

grant update on table "public"."users" to "authenticated";

grant delete on table "public"."users" to "service_role";

grant insert on table "public"."users" to "service_role";

grant references on table "public"."users" to "service_role";

grant select on table "public"."users" to "service_role";

grant trigger on table "public"."users" to "service_role";

grant truncate on table "public"."users" to "service_role";

grant update on table "public"."users" to "service_role";

grant delete on table "public"."users_v2" to "anon";

grant insert on table "public"."users_v2" to "anon";

grant references on table "public"."users_v2" to "anon";

grant select on table "public"."users_v2" to "anon";

grant trigger on table "public"."users_v2" to "anon";

grant truncate on table "public"."users_v2" to "anon";

grant update on table "public"."users_v2" to "anon";

grant delete on table "public"."users_v2" to "authenticated";

grant insert on table "public"."users_v2" to "authenticated";

grant references on table "public"."users_v2" to "authenticated";

grant select on table "public"."users_v2" to "authenticated";

grant trigger on table "public"."users_v2" to "authenticated";

grant truncate on table "public"."users_v2" to "authenticated";

grant update on table "public"."users_v2" to "authenticated";

grant delete on table "public"."users_v2" to "service_role";

grant insert on table "public"."users_v2" to "service_role";

grant references on table "public"."users_v2" to "service_role";

grant select on table "public"."users_v2" to "service_role";

grant trigger on table "public"."users_v2" to "service_role";

grant truncate on table "public"."users_v2" to "service_role";

grant update on table "public"."users_v2" to "service_role";

grant delete on table "public"."verificationAudits" to "anon";

grant insert on table "public"."verificationAudits" to "anon";

grant references on table "public"."verificationAudits" to "anon";

grant select on table "public"."verificationAudits" to "anon";

grant trigger on table "public"."verificationAudits" to "anon";

grant truncate on table "public"."verificationAudits" to "anon";

grant update on table "public"."verificationAudits" to "anon";

grant delete on table "public"."verificationAudits" to "authenticated";

grant insert on table "public"."verificationAudits" to "authenticated";

grant references on table "public"."verificationAudits" to "authenticated";

grant select on table "public"."verificationAudits" to "authenticated";

grant trigger on table "public"."verificationAudits" to "authenticated";

grant truncate on table "public"."verificationAudits" to "authenticated";

grant update on table "public"."verificationAudits" to "authenticated";

grant delete on table "public"."verificationAudits" to "service_role";

grant insert on table "public"."verificationAudits" to "service_role";

grant references on table "public"."verificationAudits" to "service_role";

grant select on table "public"."verificationAudits" to "service_role";

grant trigger on table "public"."verificationAudits" to "service_role";

grant truncate on table "public"."verificationAudits" to "service_role";

grant update on table "public"."verificationAudits" to "service_role";

grant delete on table "public"."verificationRequests" to "anon";

grant insert on table "public"."verificationRequests" to "anon";

grant references on table "public"."verificationRequests" to "anon";

grant select on table "public"."verificationRequests" to "anon";

grant trigger on table "public"."verificationRequests" to "anon";

grant truncate on table "public"."verificationRequests" to "anon";

grant update on table "public"."verificationRequests" to "anon";

grant delete on table "public"."verificationRequests" to "authenticated";

grant insert on table "public"."verificationRequests" to "authenticated";

grant references on table "public"."verificationRequests" to "authenticated";

grant select on table "public"."verificationRequests" to "authenticated";

grant trigger on table "public"."verificationRequests" to "authenticated";

grant truncate on table "public"."verificationRequests" to "authenticated";

grant update on table "public"."verificationRequests" to "authenticated";

grant delete on table "public"."verificationRequests" to "service_role";

grant insert on table "public"."verificationRequests" to "service_role";

grant references on table "public"."verificationRequests" to "service_role";

grant select on table "public"."verificationRequests" to "service_role";

grant trigger on table "public"."verificationRequests" to "service_role";

grant truncate on table "public"."verificationRequests" to "service_role";

grant update on table "public"."verificationRequests" to "service_role";

grant delete on table "public"."vip_accounts" to "anon";

grant insert on table "public"."vip_accounts" to "anon";

grant references on table "public"."vip_accounts" to "anon";

grant select on table "public"."vip_accounts" to "anon";

grant trigger on table "public"."vip_accounts" to "anon";

grant truncate on table "public"."vip_accounts" to "anon";

grant update on table "public"."vip_accounts" to "anon";

grant delete on table "public"."vip_accounts" to "authenticated";

grant insert on table "public"."vip_accounts" to "authenticated";

grant references on table "public"."vip_accounts" to "authenticated";

grant select on table "public"."vip_accounts" to "authenticated";

grant trigger on table "public"."vip_accounts" to "authenticated";

grant truncate on table "public"."vip_accounts" to "authenticated";

grant update on table "public"."vip_accounts" to "authenticated";

grant delete on table "public"."vip_accounts" to "service_role";

grant insert on table "public"."vip_accounts" to "service_role";

grant references on table "public"."vip_accounts" to "service_role";

grant select on table "public"."vip_accounts" to "service_role";

grant trigger on table "public"."vip_accounts" to "service_role";

grant truncate on table "public"."vip_accounts" to "service_role";

grant update on table "public"."vip_accounts" to "service_role";

grant delete on table "public"."voice_studio_clones" to "anon";

grant insert on table "public"."voice_studio_clones" to "anon";

grant references on table "public"."voice_studio_clones" to "anon";

grant select on table "public"."voice_studio_clones" to "anon";

grant trigger on table "public"."voice_studio_clones" to "anon";

grant truncate on table "public"."voice_studio_clones" to "anon";

grant update on table "public"."voice_studio_clones" to "anon";

grant delete on table "public"."voice_studio_clones" to "authenticated";

grant insert on table "public"."voice_studio_clones" to "authenticated";

grant references on table "public"."voice_studio_clones" to "authenticated";

grant select on table "public"."voice_studio_clones" to "authenticated";

grant trigger on table "public"."voice_studio_clones" to "authenticated";

grant truncate on table "public"."voice_studio_clones" to "authenticated";

grant update on table "public"."voice_studio_clones" to "authenticated";

grant delete on table "public"."voice_studio_clones" to "service_role";

grant insert on table "public"."voice_studio_clones" to "service_role";

grant references on table "public"."voice_studio_clones" to "service_role";

grant select on table "public"."voice_studio_clones" to "service_role";

grant trigger on table "public"."voice_studio_clones" to "service_role";

grant truncate on table "public"."voice_studio_clones" to "service_role";

grant update on table "public"."voice_studio_clones" to "service_role";

grant delete on table "public"."voice_studio_jobs" to "anon";

grant insert on table "public"."voice_studio_jobs" to "anon";

grant references on table "public"."voice_studio_jobs" to "anon";

grant select on table "public"."voice_studio_jobs" to "anon";

grant trigger on table "public"."voice_studio_jobs" to "anon";

grant truncate on table "public"."voice_studio_jobs" to "anon";

grant update on table "public"."voice_studio_jobs" to "anon";

grant delete on table "public"."voice_studio_jobs" to "authenticated";

grant insert on table "public"."voice_studio_jobs" to "authenticated";

grant references on table "public"."voice_studio_jobs" to "authenticated";

grant select on table "public"."voice_studio_jobs" to "authenticated";

grant trigger on table "public"."voice_studio_jobs" to "authenticated";

grant truncate on table "public"."voice_studio_jobs" to "authenticated";

grant update on table "public"."voice_studio_jobs" to "authenticated";

grant delete on table "public"."voice_studio_jobs" to "service_role";

grant insert on table "public"."voice_studio_jobs" to "service_role";

grant references on table "public"."voice_studio_jobs" to "service_role";

grant select on table "public"."voice_studio_jobs" to "service_role";

grant trigger on table "public"."voice_studio_jobs" to "service_role";

grant truncate on table "public"."voice_studio_jobs" to "service_role";

grant update on table "public"."voice_studio_jobs" to "service_role";

grant delete on table "public"."voice_studio_usage" to "anon";

grant insert on table "public"."voice_studio_usage" to "anon";

grant references on table "public"."voice_studio_usage" to "anon";

grant select on table "public"."voice_studio_usage" to "anon";

grant trigger on table "public"."voice_studio_usage" to "anon";

grant truncate on table "public"."voice_studio_usage" to "anon";

grant update on table "public"."voice_studio_usage" to "anon";

grant delete on table "public"."voice_studio_usage" to "authenticated";

grant insert on table "public"."voice_studio_usage" to "authenticated";

grant references on table "public"."voice_studio_usage" to "authenticated";

grant select on table "public"."voice_studio_usage" to "authenticated";

grant trigger on table "public"."voice_studio_usage" to "authenticated";

grant truncate on table "public"."voice_studio_usage" to "authenticated";

grant update on table "public"."voice_studio_usage" to "authenticated";

grant delete on table "public"."voice_studio_usage" to "service_role";

grant insert on table "public"."voice_studio_usage" to "service_role";

grant references on table "public"."voice_studio_usage" to "service_role";

grant select on table "public"."voice_studio_usage" to "service_role";

grant trigger on table "public"."voice_studio_usage" to "service_role";

grant truncate on table "public"."voice_studio_usage" to "service_role";

grant update on table "public"."voice_studio_usage" to "service_role";

grant delete on table "public"."waitlist" to "anon";

grant insert on table "public"."waitlist" to "anon";

grant references on table "public"."waitlist" to "anon";

grant select on table "public"."waitlist" to "anon";

grant trigger on table "public"."waitlist" to "anon";

grant truncate on table "public"."waitlist" to "anon";

grant update on table "public"."waitlist" to "anon";

grant delete on table "public"."waitlist" to "authenticated";

grant insert on table "public"."waitlist" to "authenticated";

grant references on table "public"."waitlist" to "authenticated";

grant select on table "public"."waitlist" to "authenticated";

grant trigger on table "public"."waitlist" to "authenticated";

grant truncate on table "public"."waitlist" to "authenticated";

grant update on table "public"."waitlist" to "authenticated";

grant delete on table "public"."waitlist" to "service_role";

grant insert on table "public"."waitlist" to "service_role";

grant references on table "public"."waitlist" to "service_role";

grant select on table "public"."waitlist" to "service_role";

grant trigger on table "public"."waitlist" to "service_role";

grant truncate on table "public"."waitlist" to "service_role";

grant update on table "public"."waitlist" to "service_role";

grant delete on table "public"."wallets" to "anon";

grant insert on table "public"."wallets" to "anon";

grant references on table "public"."wallets" to "anon";

grant select on table "public"."wallets" to "anon";

grant trigger on table "public"."wallets" to "anon";

grant truncate on table "public"."wallets" to "anon";

grant update on table "public"."wallets" to "anon";

grant delete on table "public"."wallets" to "authenticated";

grant insert on table "public"."wallets" to "authenticated";

grant references on table "public"."wallets" to "authenticated";

grant select on table "public"."wallets" to "authenticated";

grant trigger on table "public"."wallets" to "authenticated";

grant truncate on table "public"."wallets" to "authenticated";

grant update on table "public"."wallets" to "authenticated";

grant delete on table "public"."wallets" to "service_role";

grant insert on table "public"."wallets" to "service_role";

grant references on table "public"."wallets" to "service_role";

grant select on table "public"."wallets" to "service_role";

grant trigger on table "public"."wallets" to "service_role";

grant truncate on table "public"."wallets" to "service_role";

grant update on table "public"."wallets" to "service_role";

grant delete on table "public"."wallets_v2" to "anon";

grant insert on table "public"."wallets_v2" to "anon";

grant references on table "public"."wallets_v2" to "anon";

grant select on table "public"."wallets_v2" to "anon";

grant trigger on table "public"."wallets_v2" to "anon";

grant truncate on table "public"."wallets_v2" to "anon";

grant update on table "public"."wallets_v2" to "anon";

grant delete on table "public"."wallets_v2" to "authenticated";

grant insert on table "public"."wallets_v2" to "authenticated";

grant references on table "public"."wallets_v2" to "authenticated";

grant select on table "public"."wallets_v2" to "authenticated";

grant trigger on table "public"."wallets_v2" to "authenticated";

grant truncate on table "public"."wallets_v2" to "authenticated";

grant update on table "public"."wallets_v2" to "authenticated";

grant delete on table "public"."wallets_v2" to "service_role";

grant insert on table "public"."wallets_v2" to "service_role";

grant references on table "public"."wallets_v2" to "service_role";

grant select on table "public"."wallets_v2" to "service_role";

grant trigger on table "public"."wallets_v2" to "service_role";

grant truncate on table "public"."wallets_v2" to "service_role";

grant update on table "public"."wallets_v2" to "service_role";

grant delete on table "public"."wc_ai_agents" to "anon";

grant insert on table "public"."wc_ai_agents" to "anon";

grant references on table "public"."wc_ai_agents" to "anon";

grant select on table "public"."wc_ai_agents" to "anon";

grant trigger on table "public"."wc_ai_agents" to "anon";

grant truncate on table "public"."wc_ai_agents" to "anon";

grant update on table "public"."wc_ai_agents" to "anon";

grant delete on table "public"."wc_ai_agents" to "authenticated";

grant insert on table "public"."wc_ai_agents" to "authenticated";

grant references on table "public"."wc_ai_agents" to "authenticated";

grant select on table "public"."wc_ai_agents" to "authenticated";

grant trigger on table "public"."wc_ai_agents" to "authenticated";

grant truncate on table "public"."wc_ai_agents" to "authenticated";

grant update on table "public"."wc_ai_agents" to "authenticated";

grant delete on table "public"."wc_ai_agents" to "service_role";

grant insert on table "public"."wc_ai_agents" to "service_role";

grant references on table "public"."wc_ai_agents" to "service_role";

grant select on table "public"."wc_ai_agents" to "service_role";

grant trigger on table "public"."wc_ai_agents" to "service_role";

grant truncate on table "public"."wc_ai_agents" to "service_role";

grant update on table "public"."wc_ai_agents" to "service_role";

grant delete on table "public"."wc_ai_cases" to "anon";

grant insert on table "public"."wc_ai_cases" to "anon";

grant references on table "public"."wc_ai_cases" to "anon";

grant select on table "public"."wc_ai_cases" to "anon";

grant trigger on table "public"."wc_ai_cases" to "anon";

grant truncate on table "public"."wc_ai_cases" to "anon";

grant update on table "public"."wc_ai_cases" to "anon";

grant delete on table "public"."wc_ai_cases" to "authenticated";

grant insert on table "public"."wc_ai_cases" to "authenticated";

grant references on table "public"."wc_ai_cases" to "authenticated";

grant select on table "public"."wc_ai_cases" to "authenticated";

grant trigger on table "public"."wc_ai_cases" to "authenticated";

grant truncate on table "public"."wc_ai_cases" to "authenticated";

grant update on table "public"."wc_ai_cases" to "authenticated";

grant delete on table "public"."wc_ai_cases" to "service_role";

grant insert on table "public"."wc_ai_cases" to "service_role";

grant references on table "public"."wc_ai_cases" to "service_role";

grant select on table "public"."wc_ai_cases" to "service_role";

grant trigger on table "public"."wc_ai_cases" to "service_role";

grant truncate on table "public"."wc_ai_cases" to "service_role";

grant update on table "public"."wc_ai_cases" to "service_role";

grant delete on table "public"."wc_ai_employees" to "anon";

grant insert on table "public"."wc_ai_employees" to "anon";

grant references on table "public"."wc_ai_employees" to "anon";

grant select on table "public"."wc_ai_employees" to "anon";

grant trigger on table "public"."wc_ai_employees" to "anon";

grant truncate on table "public"."wc_ai_employees" to "anon";

grant update on table "public"."wc_ai_employees" to "anon";

grant delete on table "public"."wc_ai_employees" to "authenticated";

grant insert on table "public"."wc_ai_employees" to "authenticated";

grant references on table "public"."wc_ai_employees" to "authenticated";

grant select on table "public"."wc_ai_employees" to "authenticated";

grant trigger on table "public"."wc_ai_employees" to "authenticated";

grant truncate on table "public"."wc_ai_employees" to "authenticated";

grant update on table "public"."wc_ai_employees" to "authenticated";

grant delete on table "public"."wc_ai_employees" to "service_role";

grant insert on table "public"."wc_ai_employees" to "service_role";

grant references on table "public"."wc_ai_employees" to "service_role";

grant select on table "public"."wc_ai_employees" to "service_role";

grant trigger on table "public"."wc_ai_employees" to "service_role";

grant truncate on table "public"."wc_ai_employees" to "service_role";

grant update on table "public"."wc_ai_employees" to "service_role";

grant delete on table "public"."wc_ai_staff" to "anon";

grant insert on table "public"."wc_ai_staff" to "anon";

grant references on table "public"."wc_ai_staff" to "anon";

grant select on table "public"."wc_ai_staff" to "anon";

grant trigger on table "public"."wc_ai_staff" to "anon";

grant truncate on table "public"."wc_ai_staff" to "anon";

grant update on table "public"."wc_ai_staff" to "anon";

grant delete on table "public"."wc_ai_staff" to "authenticated";

grant insert on table "public"."wc_ai_staff" to "authenticated";

grant references on table "public"."wc_ai_staff" to "authenticated";

grant select on table "public"."wc_ai_staff" to "authenticated";

grant trigger on table "public"."wc_ai_staff" to "authenticated";

grant truncate on table "public"."wc_ai_staff" to "authenticated";

grant update on table "public"."wc_ai_staff" to "authenticated";

grant delete on table "public"."wc_ai_staff" to "service_role";

grant insert on table "public"."wc_ai_staff" to "service_role";

grant references on table "public"."wc_ai_staff" to "service_role";

grant select on table "public"."wc_ai_staff" to "service_role";

grant trigger on table "public"."wc_ai_staff" to "service_role";

grant truncate on table "public"."wc_ai_staff" to "service_role";

grant update on table "public"."wc_ai_staff" to "service_role";

grant delete on table "public"."wc_analytics" to "anon";

grant insert on table "public"."wc_analytics" to "anon";

grant references on table "public"."wc_analytics" to "anon";

grant select on table "public"."wc_analytics" to "anon";

grant trigger on table "public"."wc_analytics" to "anon";

grant truncate on table "public"."wc_analytics" to "anon";

grant update on table "public"."wc_analytics" to "anon";

grant delete on table "public"."wc_analytics" to "authenticated";

grant insert on table "public"."wc_analytics" to "authenticated";

grant references on table "public"."wc_analytics" to "authenticated";

grant select on table "public"."wc_analytics" to "authenticated";

grant trigger on table "public"."wc_analytics" to "authenticated";

grant truncate on table "public"."wc_analytics" to "authenticated";

grant update on table "public"."wc_analytics" to "authenticated";

grant delete on table "public"."wc_analytics" to "service_role";

grant insert on table "public"."wc_analytics" to "service_role";

grant references on table "public"."wc_analytics" to "service_role";

grant select on table "public"."wc_analytics" to "service_role";

grant trigger on table "public"."wc_analytics" to "service_role";

grant truncate on table "public"."wc_analytics" to "service_role";

grant update on table "public"."wc_analytics" to "service_role";

grant delete on table "public"."wc_call_sessions" to "anon";

grant insert on table "public"."wc_call_sessions" to "anon";

grant references on table "public"."wc_call_sessions" to "anon";

grant select on table "public"."wc_call_sessions" to "anon";

grant trigger on table "public"."wc_call_sessions" to "anon";

grant truncate on table "public"."wc_call_sessions" to "anon";

grant update on table "public"."wc_call_sessions" to "anon";

grant delete on table "public"."wc_call_sessions" to "authenticated";

grant insert on table "public"."wc_call_sessions" to "authenticated";

grant references on table "public"."wc_call_sessions" to "authenticated";

grant select on table "public"."wc_call_sessions" to "authenticated";

grant trigger on table "public"."wc_call_sessions" to "authenticated";

grant truncate on table "public"."wc_call_sessions" to "authenticated";

grant update on table "public"."wc_call_sessions" to "authenticated";

grant delete on table "public"."wc_call_sessions" to "service_role";

grant insert on table "public"."wc_call_sessions" to "service_role";

grant references on table "public"."wc_call_sessions" to "service_role";

grant select on table "public"."wc_call_sessions" to "service_role";

grant trigger on table "public"."wc_call_sessions" to "service_role";

grant truncate on table "public"."wc_call_sessions" to "service_role";

grant update on table "public"."wc_call_sessions" to "service_role";

grant delete on table "public"."wc_calls" to "anon";

grant insert on table "public"."wc_calls" to "anon";

grant references on table "public"."wc_calls" to "anon";

grant select on table "public"."wc_calls" to "anon";

grant trigger on table "public"."wc_calls" to "anon";

grant truncate on table "public"."wc_calls" to "anon";

grant update on table "public"."wc_calls" to "anon";

grant delete on table "public"."wc_calls" to "authenticated";

grant insert on table "public"."wc_calls" to "authenticated";

grant references on table "public"."wc_calls" to "authenticated";

grant select on table "public"."wc_calls" to "authenticated";

grant trigger on table "public"."wc_calls" to "authenticated";

grant truncate on table "public"."wc_calls" to "authenticated";

grant update on table "public"."wc_calls" to "authenticated";

grant delete on table "public"."wc_calls" to "service_role";

grant insert on table "public"."wc_calls" to "service_role";

grant references on table "public"."wc_calls" to "service_role";

grant select on table "public"."wc_calls" to "service_role";

grant trigger on table "public"."wc_calls" to "service_role";

grant truncate on table "public"."wc_calls" to "service_role";

grant update on table "public"."wc_calls" to "service_role";

grant delete on table "public"."wc_contacts" to "anon";

grant insert on table "public"."wc_contacts" to "anon";

grant references on table "public"."wc_contacts" to "anon";

grant select on table "public"."wc_contacts" to "anon";

grant trigger on table "public"."wc_contacts" to "anon";

grant truncate on table "public"."wc_contacts" to "anon";

grant update on table "public"."wc_contacts" to "anon";

grant delete on table "public"."wc_contacts" to "authenticated";

grant insert on table "public"."wc_contacts" to "authenticated";

grant references on table "public"."wc_contacts" to "authenticated";

grant select on table "public"."wc_contacts" to "authenticated";

grant trigger on table "public"."wc_contacts" to "authenticated";

grant truncate on table "public"."wc_contacts" to "authenticated";

grant update on table "public"."wc_contacts" to "authenticated";

grant delete on table "public"."wc_contacts" to "service_role";

grant insert on table "public"."wc_contacts" to "service_role";

grant references on table "public"."wc_contacts" to "service_role";

grant select on table "public"."wc_contacts" to "service_role";

grant trigger on table "public"."wc_contacts" to "service_role";

grant truncate on table "public"."wc_contacts" to "service_role";

grant update on table "public"."wc_contacts" to "service_role";

grant delete on table "public"."wc_departments" to "anon";

grant insert on table "public"."wc_departments" to "anon";

grant references on table "public"."wc_departments" to "anon";

grant select on table "public"."wc_departments" to "anon";

grant trigger on table "public"."wc_departments" to "anon";

grant truncate on table "public"."wc_departments" to "anon";

grant update on table "public"."wc_departments" to "anon";

grant delete on table "public"."wc_departments" to "authenticated";

grant insert on table "public"."wc_departments" to "authenticated";

grant references on table "public"."wc_departments" to "authenticated";

grant select on table "public"."wc_departments" to "authenticated";

grant trigger on table "public"."wc_departments" to "authenticated";

grant truncate on table "public"."wc_departments" to "authenticated";

grant update on table "public"."wc_departments" to "authenticated";

grant delete on table "public"."wc_departments" to "service_role";

grant insert on table "public"."wc_departments" to "service_role";

grant references on table "public"."wc_departments" to "service_role";

grant select on table "public"."wc_departments" to "service_role";

grant trigger on table "public"."wc_departments" to "service_role";

grant truncate on table "public"."wc_departments" to "service_role";

grant update on table "public"."wc_departments" to "service_role";

grant delete on table "public"."wc_entitlements" to "anon";

grant insert on table "public"."wc_entitlements" to "anon";

grant references on table "public"."wc_entitlements" to "anon";

grant select on table "public"."wc_entitlements" to "anon";

grant trigger on table "public"."wc_entitlements" to "anon";

grant truncate on table "public"."wc_entitlements" to "anon";

grant update on table "public"."wc_entitlements" to "anon";

grant delete on table "public"."wc_entitlements" to "authenticated";

grant insert on table "public"."wc_entitlements" to "authenticated";

grant references on table "public"."wc_entitlements" to "authenticated";

grant select on table "public"."wc_entitlements" to "authenticated";

grant trigger on table "public"."wc_entitlements" to "authenticated";

grant truncate on table "public"."wc_entitlements" to "authenticated";

grant update on table "public"."wc_entitlements" to "authenticated";

grant delete on table "public"."wc_entitlements" to "service_role";

grant insert on table "public"."wc_entitlements" to "service_role";

grant references on table "public"."wc_entitlements" to "service_role";

grant select on table "public"."wc_entitlements" to "service_role";

grant trigger on table "public"."wc_entitlements" to "service_role";

grant truncate on table "public"."wc_entitlements" to "service_role";

grant update on table "public"."wc_entitlements" to "service_role";

grant delete on table "public"."wc_followup_tasks" to "anon";

grant insert on table "public"."wc_followup_tasks" to "anon";

grant references on table "public"."wc_followup_tasks" to "anon";

grant select on table "public"."wc_followup_tasks" to "anon";

grant trigger on table "public"."wc_followup_tasks" to "anon";

grant truncate on table "public"."wc_followup_tasks" to "anon";

grant update on table "public"."wc_followup_tasks" to "anon";

grant delete on table "public"."wc_followup_tasks" to "authenticated";

grant insert on table "public"."wc_followup_tasks" to "authenticated";

grant references on table "public"."wc_followup_tasks" to "authenticated";

grant select on table "public"."wc_followup_tasks" to "authenticated";

grant trigger on table "public"."wc_followup_tasks" to "authenticated";

grant truncate on table "public"."wc_followup_tasks" to "authenticated";

grant update on table "public"."wc_followup_tasks" to "authenticated";

grant delete on table "public"."wc_followup_tasks" to "service_role";

grant insert on table "public"."wc_followup_tasks" to "service_role";

grant references on table "public"."wc_followup_tasks" to "service_role";

grant select on table "public"."wc_followup_tasks" to "service_role";

grant trigger on table "public"."wc_followup_tasks" to "service_role";

grant truncate on table "public"."wc_followup_tasks" to "service_role";

grant update on table "public"."wc_followup_tasks" to "service_role";

grant delete on table "public"."wc_messages" to "anon";

grant insert on table "public"."wc_messages" to "anon";

grant references on table "public"."wc_messages" to "anon";

grant select on table "public"."wc_messages" to "anon";

grant trigger on table "public"."wc_messages" to "anon";

grant truncate on table "public"."wc_messages" to "anon";

grant update on table "public"."wc_messages" to "anon";

grant delete on table "public"."wc_messages" to "authenticated";

grant insert on table "public"."wc_messages" to "authenticated";

grant references on table "public"."wc_messages" to "authenticated";

grant select on table "public"."wc_messages" to "authenticated";

grant trigger on table "public"."wc_messages" to "authenticated";

grant truncate on table "public"."wc_messages" to "authenticated";

grant update on table "public"."wc_messages" to "authenticated";

grant delete on table "public"."wc_messages" to "service_role";

grant insert on table "public"."wc_messages" to "service_role";

grant references on table "public"."wc_messages" to "service_role";

grant select on table "public"."wc_messages" to "service_role";

grant trigger on table "public"."wc_messages" to "service_role";

grant truncate on table "public"."wc_messages" to "service_role";

grant update on table "public"."wc_messages" to "service_role";

grant delete on table "public"."wc_number_requests" to "anon";

grant insert on table "public"."wc_number_requests" to "anon";

grant references on table "public"."wc_number_requests" to "anon";

grant select on table "public"."wc_number_requests" to "anon";

grant trigger on table "public"."wc_number_requests" to "anon";

grant truncate on table "public"."wc_number_requests" to "anon";

grant update on table "public"."wc_number_requests" to "anon";

grant delete on table "public"."wc_number_requests" to "authenticated";

grant insert on table "public"."wc_number_requests" to "authenticated";

grant references on table "public"."wc_number_requests" to "authenticated";

grant select on table "public"."wc_number_requests" to "authenticated";

grant trigger on table "public"."wc_number_requests" to "authenticated";

grant truncate on table "public"."wc_number_requests" to "authenticated";

grant update on table "public"."wc_number_requests" to "authenticated";

grant delete on table "public"."wc_number_requests" to "service_role";

grant insert on table "public"."wc_number_requests" to "service_role";

grant references on table "public"."wc_number_requests" to "service_role";

grant select on table "public"."wc_number_requests" to "service_role";

grant trigger on table "public"."wc_number_requests" to "service_role";

grant truncate on table "public"."wc_number_requests" to "service_role";

grant update on table "public"."wc_number_requests" to "service_role";

grant delete on table "public"."wc_org_settings" to "anon";

grant insert on table "public"."wc_org_settings" to "anon";

grant references on table "public"."wc_org_settings" to "anon";

grant select on table "public"."wc_org_settings" to "anon";

grant trigger on table "public"."wc_org_settings" to "anon";

grant truncate on table "public"."wc_org_settings" to "anon";

grant update on table "public"."wc_org_settings" to "anon";

grant delete on table "public"."wc_org_settings" to "authenticated";

grant insert on table "public"."wc_org_settings" to "authenticated";

grant references on table "public"."wc_org_settings" to "authenticated";

grant select on table "public"."wc_org_settings" to "authenticated";

grant trigger on table "public"."wc_org_settings" to "authenticated";

grant truncate on table "public"."wc_org_settings" to "authenticated";

grant update on table "public"."wc_org_settings" to "authenticated";

grant delete on table "public"."wc_org_settings" to "service_role";

grant insert on table "public"."wc_org_settings" to "service_role";

grant references on table "public"."wc_org_settings" to "service_role";

grant select on table "public"."wc_org_settings" to "service_role";

grant trigger on table "public"."wc_org_settings" to "service_role";

grant truncate on table "public"."wc_org_settings" to "service_role";

grant update on table "public"."wc_org_settings" to "service_role";

grant delete on table "public"."wc_org_users" to "anon";

grant insert on table "public"."wc_org_users" to "anon";

grant references on table "public"."wc_org_users" to "anon";

grant select on table "public"."wc_org_users" to "anon";

grant trigger on table "public"."wc_org_users" to "anon";

grant truncate on table "public"."wc_org_users" to "anon";

grant update on table "public"."wc_org_users" to "anon";

grant delete on table "public"."wc_org_users" to "authenticated";

grant insert on table "public"."wc_org_users" to "authenticated";

grant references on table "public"."wc_org_users" to "authenticated";

grant select on table "public"."wc_org_users" to "authenticated";

grant trigger on table "public"."wc_org_users" to "authenticated";

grant truncate on table "public"."wc_org_users" to "authenticated";

grant update on table "public"."wc_org_users" to "authenticated";

grant delete on table "public"."wc_org_users" to "service_role";

grant insert on table "public"."wc_org_users" to "service_role";

grant references on table "public"."wc_org_users" to "service_role";

grant select on table "public"."wc_org_users" to "service_role";

grant trigger on table "public"."wc_org_users" to "service_role";

grant truncate on table "public"."wc_org_users" to "service_role";

grant update on table "public"."wc_org_users" to "service_role";

grant delete on table "public"."wc_participants" to "anon";

grant insert on table "public"."wc_participants" to "anon";

grant references on table "public"."wc_participants" to "anon";

grant select on table "public"."wc_participants" to "anon";

grant trigger on table "public"."wc_participants" to "anon";

grant truncate on table "public"."wc_participants" to "anon";

grant update on table "public"."wc_participants" to "anon";

grant delete on table "public"."wc_participants" to "authenticated";

grant insert on table "public"."wc_participants" to "authenticated";

grant references on table "public"."wc_participants" to "authenticated";

grant select on table "public"."wc_participants" to "authenticated";

grant trigger on table "public"."wc_participants" to "authenticated";

grant truncate on table "public"."wc_participants" to "authenticated";

grant update on table "public"."wc_participants" to "authenticated";

grant delete on table "public"."wc_participants" to "service_role";

grant insert on table "public"."wc_participants" to "service_role";

grant references on table "public"."wc_participants" to "service_role";

grant select on table "public"."wc_participants" to "service_role";

grant trigger on table "public"."wc_participants" to "service_role";

grant truncate on table "public"."wc_participants" to "service_role";

grant update on table "public"."wc_participants" to "service_role";

grant delete on table "public"."wc_phone_numbers" to "anon";

grant insert on table "public"."wc_phone_numbers" to "anon";

grant references on table "public"."wc_phone_numbers" to "anon";

grant select on table "public"."wc_phone_numbers" to "anon";

grant trigger on table "public"."wc_phone_numbers" to "anon";

grant truncate on table "public"."wc_phone_numbers" to "anon";

grant update on table "public"."wc_phone_numbers" to "anon";

grant delete on table "public"."wc_phone_numbers" to "authenticated";

grant insert on table "public"."wc_phone_numbers" to "authenticated";

grant references on table "public"."wc_phone_numbers" to "authenticated";

grant select on table "public"."wc_phone_numbers" to "authenticated";

grant trigger on table "public"."wc_phone_numbers" to "authenticated";

grant truncate on table "public"."wc_phone_numbers" to "authenticated";

grant update on table "public"."wc_phone_numbers" to "authenticated";

grant delete on table "public"."wc_phone_numbers" to "service_role";

grant insert on table "public"."wc_phone_numbers" to "service_role";

grant references on table "public"."wc_phone_numbers" to "service_role";

grant select on table "public"."wc_phone_numbers" to "service_role";

grant trigger on table "public"."wc_phone_numbers" to "service_role";

grant truncate on table "public"."wc_phone_numbers" to "service_role";

grant update on table "public"."wc_phone_numbers" to "service_role";

grant delete on table "public"."wc_queue" to "anon";

grant insert on table "public"."wc_queue" to "anon";

grant references on table "public"."wc_queue" to "anon";

grant select on table "public"."wc_queue" to "anon";

grant trigger on table "public"."wc_queue" to "anon";

grant truncate on table "public"."wc_queue" to "anon";

grant update on table "public"."wc_queue" to "anon";

grant delete on table "public"."wc_queue" to "authenticated";

grant insert on table "public"."wc_queue" to "authenticated";

grant references on table "public"."wc_queue" to "authenticated";

grant select on table "public"."wc_queue" to "authenticated";

grant trigger on table "public"."wc_queue" to "authenticated";

grant truncate on table "public"."wc_queue" to "authenticated";

grant update on table "public"."wc_queue" to "authenticated";

grant delete on table "public"."wc_queue" to "service_role";

grant insert on table "public"."wc_queue" to "service_role";

grant references on table "public"."wc_queue" to "service_role";

grant select on table "public"."wc_queue" to "service_role";

grant trigger on table "public"."wc_queue" to "service_role";

grant truncate on table "public"."wc_queue" to "service_role";

grant update on table "public"."wc_queue" to "service_role";

grant delete on table "public"."wc_recordings" to "anon";

grant insert on table "public"."wc_recordings" to "anon";

grant references on table "public"."wc_recordings" to "anon";

grant select on table "public"."wc_recordings" to "anon";

grant trigger on table "public"."wc_recordings" to "anon";

grant truncate on table "public"."wc_recordings" to "anon";

grant update on table "public"."wc_recordings" to "anon";

grant delete on table "public"."wc_recordings" to "authenticated";

grant insert on table "public"."wc_recordings" to "authenticated";

grant references on table "public"."wc_recordings" to "authenticated";

grant select on table "public"."wc_recordings" to "authenticated";

grant trigger on table "public"."wc_recordings" to "authenticated";

grant truncate on table "public"."wc_recordings" to "authenticated";

grant update on table "public"."wc_recordings" to "authenticated";

grant delete on table "public"."wc_recordings" to "service_role";

grant insert on table "public"."wc_recordings" to "service_role";

grant references on table "public"."wc_recordings" to "service_role";

grant select on table "public"."wc_recordings" to "service_role";

grant trigger on table "public"."wc_recordings" to "service_role";

grant truncate on table "public"."wc_recordings" to "service_role";

grant update on table "public"."wc_recordings" to "service_role";

grant delete on table "public"."wc_roles" to "anon";

grant insert on table "public"."wc_roles" to "anon";

grant references on table "public"."wc_roles" to "anon";

grant select on table "public"."wc_roles" to "anon";

grant trigger on table "public"."wc_roles" to "anon";

grant truncate on table "public"."wc_roles" to "anon";

grant update on table "public"."wc_roles" to "anon";

grant delete on table "public"."wc_roles" to "authenticated";

grant insert on table "public"."wc_roles" to "authenticated";

grant references on table "public"."wc_roles" to "authenticated";

grant select on table "public"."wc_roles" to "authenticated";

grant trigger on table "public"."wc_roles" to "authenticated";

grant truncate on table "public"."wc_roles" to "authenticated";

grant update on table "public"."wc_roles" to "authenticated";

grant delete on table "public"."wc_roles" to "service_role";

grant insert on table "public"."wc_roles" to "service_role";

grant references on table "public"."wc_roles" to "service_role";

grant select on table "public"."wc_roles" to "service_role";

grant trigger on table "public"."wc_roles" to "service_role";

grant truncate on table "public"."wc_roles" to "service_role";

grant update on table "public"."wc_roles" to "service_role";

grant delete on table "public"."wc_rooms" to "anon";

grant insert on table "public"."wc_rooms" to "anon";

grant references on table "public"."wc_rooms" to "anon";

grant select on table "public"."wc_rooms" to "anon";

grant trigger on table "public"."wc_rooms" to "anon";

grant truncate on table "public"."wc_rooms" to "anon";

grant update on table "public"."wc_rooms" to "anon";

grant delete on table "public"."wc_rooms" to "authenticated";

grant insert on table "public"."wc_rooms" to "authenticated";

grant references on table "public"."wc_rooms" to "authenticated";

grant select on table "public"."wc_rooms" to "authenticated";

grant trigger on table "public"."wc_rooms" to "authenticated";

grant truncate on table "public"."wc_rooms" to "authenticated";

grant update on table "public"."wc_rooms" to "authenticated";

grant delete on table "public"."wc_rooms" to "service_role";

grant insert on table "public"."wc_rooms" to "service_role";

grant references on table "public"."wc_rooms" to "service_role";

grant select on table "public"."wc_rooms" to "service_role";

grant trigger on table "public"."wc_rooms" to "service_role";

grant truncate on table "public"."wc_rooms" to "service_role";

grant update on table "public"."wc_rooms" to "service_role";

grant delete on table "public"."wc_routing_edges" to "anon";

grant insert on table "public"."wc_routing_edges" to "anon";

grant references on table "public"."wc_routing_edges" to "anon";

grant select on table "public"."wc_routing_edges" to "anon";

grant trigger on table "public"."wc_routing_edges" to "anon";

grant truncate on table "public"."wc_routing_edges" to "anon";

grant update on table "public"."wc_routing_edges" to "anon";

grant delete on table "public"."wc_routing_edges" to "authenticated";

grant insert on table "public"."wc_routing_edges" to "authenticated";

grant references on table "public"."wc_routing_edges" to "authenticated";

grant select on table "public"."wc_routing_edges" to "authenticated";

grant trigger on table "public"."wc_routing_edges" to "authenticated";

grant truncate on table "public"."wc_routing_edges" to "authenticated";

grant update on table "public"."wc_routing_edges" to "authenticated";

grant delete on table "public"."wc_routing_edges" to "service_role";

grant insert on table "public"."wc_routing_edges" to "service_role";

grant references on table "public"."wc_routing_edges" to "service_role";

grant select on table "public"."wc_routing_edges" to "service_role";

grant trigger on table "public"."wc_routing_edges" to "service_role";

grant truncate on table "public"."wc_routing_edges" to "service_role";

grant update on table "public"."wc_routing_edges" to "service_role";

grant delete on table "public"."wc_routing_rules" to "anon";

grant insert on table "public"."wc_routing_rules" to "anon";

grant references on table "public"."wc_routing_rules" to "anon";

grant select on table "public"."wc_routing_rules" to "anon";

grant trigger on table "public"."wc_routing_rules" to "anon";

grant truncate on table "public"."wc_routing_rules" to "anon";

grant update on table "public"."wc_routing_rules" to "anon";

grant delete on table "public"."wc_routing_rules" to "authenticated";

grant insert on table "public"."wc_routing_rules" to "authenticated";

grant references on table "public"."wc_routing_rules" to "authenticated";

grant select on table "public"."wc_routing_rules" to "authenticated";

grant trigger on table "public"."wc_routing_rules" to "authenticated";

grant truncate on table "public"."wc_routing_rules" to "authenticated";

grant update on table "public"."wc_routing_rules" to "authenticated";

grant delete on table "public"."wc_routing_rules" to "service_role";

grant insert on table "public"."wc_routing_rules" to "service_role";

grant references on table "public"."wc_routing_rules" to "service_role";

grant select on table "public"."wc_routing_rules" to "service_role";

grant trigger on table "public"."wc_routing_rules" to "service_role";

grant truncate on table "public"."wc_routing_rules" to "service_role";

grant update on table "public"."wc_routing_rules" to "service_role";

grant delete on table "public"."wc_routing_steps" to "anon";

grant insert on table "public"."wc_routing_steps" to "anon";

grant references on table "public"."wc_routing_steps" to "anon";

grant select on table "public"."wc_routing_steps" to "anon";

grant trigger on table "public"."wc_routing_steps" to "anon";

grant truncate on table "public"."wc_routing_steps" to "anon";

grant update on table "public"."wc_routing_steps" to "anon";

grant delete on table "public"."wc_routing_steps" to "authenticated";

grant insert on table "public"."wc_routing_steps" to "authenticated";

grant references on table "public"."wc_routing_steps" to "authenticated";

grant select on table "public"."wc_routing_steps" to "authenticated";

grant trigger on table "public"."wc_routing_steps" to "authenticated";

grant truncate on table "public"."wc_routing_steps" to "authenticated";

grant update on table "public"."wc_routing_steps" to "authenticated";

grant delete on table "public"."wc_routing_steps" to "service_role";

grant insert on table "public"."wc_routing_steps" to "service_role";

grant references on table "public"."wc_routing_steps" to "service_role";

grant select on table "public"."wc_routing_steps" to "service_role";

grant trigger on table "public"."wc_routing_steps" to "service_role";

grant truncate on table "public"."wc_routing_steps" to "service_role";

grant update on table "public"."wc_routing_steps" to "service_role";

grant delete on table "public"."wc_signaling" to "anon";

grant insert on table "public"."wc_signaling" to "anon";

grant references on table "public"."wc_signaling" to "anon";

grant select on table "public"."wc_signaling" to "anon";

grant trigger on table "public"."wc_signaling" to "anon";

grant truncate on table "public"."wc_signaling" to "anon";

grant update on table "public"."wc_signaling" to "anon";

grant delete on table "public"."wc_signaling" to "authenticated";

grant insert on table "public"."wc_signaling" to "authenticated";

grant references on table "public"."wc_signaling" to "authenticated";

grant select on table "public"."wc_signaling" to "authenticated";

grant trigger on table "public"."wc_signaling" to "authenticated";

grant truncate on table "public"."wc_signaling" to "authenticated";

grant update on table "public"."wc_signaling" to "authenticated";

grant delete on table "public"."wc_signaling" to "service_role";

grant insert on table "public"."wc_signaling" to "service_role";

grant references on table "public"."wc_signaling" to "service_role";

grant select on table "public"."wc_signaling" to "service_role";

grant trigger on table "public"."wc_signaling" to "service_role";

grant truncate on table "public"."wc_signaling" to "service_role";

grant update on table "public"."wc_signaling" to "service_role";

grant delete on table "public"."wc_transcripts" to "anon";

grant insert on table "public"."wc_transcripts" to "anon";

grant references on table "public"."wc_transcripts" to "anon";

grant select on table "public"."wc_transcripts" to "anon";

grant trigger on table "public"."wc_transcripts" to "anon";

grant truncate on table "public"."wc_transcripts" to "anon";

grant update on table "public"."wc_transcripts" to "anon";

grant delete on table "public"."wc_transcripts" to "authenticated";

grant insert on table "public"."wc_transcripts" to "authenticated";

grant references on table "public"."wc_transcripts" to "authenticated";

grant select on table "public"."wc_transcripts" to "authenticated";

grant trigger on table "public"."wc_transcripts" to "authenticated";

grant truncate on table "public"."wc_transcripts" to "authenticated";

grant update on table "public"."wc_transcripts" to "authenticated";

grant delete on table "public"."wc_transcripts" to "service_role";

grant insert on table "public"."wc_transcripts" to "service_role";

grant references on table "public"."wc_transcripts" to "service_role";

grant select on table "public"."wc_transcripts" to "service_role";

grant trigger on table "public"."wc_transcripts" to "service_role";

grant truncate on table "public"."wc_transcripts" to "service_role";

grant update on table "public"."wc_transcripts" to "service_role";

grant delete on table "public"."wc_whatsapp_configs" to "anon";

grant insert on table "public"."wc_whatsapp_configs" to "anon";

grant references on table "public"."wc_whatsapp_configs" to "anon";

grant select on table "public"."wc_whatsapp_configs" to "anon";

grant trigger on table "public"."wc_whatsapp_configs" to "anon";

grant truncate on table "public"."wc_whatsapp_configs" to "anon";

grant update on table "public"."wc_whatsapp_configs" to "anon";

grant delete on table "public"."wc_whatsapp_configs" to "authenticated";

grant insert on table "public"."wc_whatsapp_configs" to "authenticated";

grant references on table "public"."wc_whatsapp_configs" to "authenticated";

grant select on table "public"."wc_whatsapp_configs" to "authenticated";

grant trigger on table "public"."wc_whatsapp_configs" to "authenticated";

grant truncate on table "public"."wc_whatsapp_configs" to "authenticated";

grant update on table "public"."wc_whatsapp_configs" to "authenticated";

grant delete on table "public"."wc_whatsapp_configs" to "service_role";

grant insert on table "public"."wc_whatsapp_configs" to "service_role";

grant references on table "public"."wc_whatsapp_configs" to "service_role";

grant select on table "public"."wc_whatsapp_configs" to "service_role";

grant trigger on table "public"."wc_whatsapp_configs" to "service_role";

grant truncate on table "public"."wc_whatsapp_configs" to "service_role";

grant update on table "public"."wc_whatsapp_configs" to "service_role";

grant delete on table "public"."wc_whatsapp_messages" to "anon";

grant insert on table "public"."wc_whatsapp_messages" to "anon";

grant references on table "public"."wc_whatsapp_messages" to "anon";

grant select on table "public"."wc_whatsapp_messages" to "anon";

grant trigger on table "public"."wc_whatsapp_messages" to "anon";

grant truncate on table "public"."wc_whatsapp_messages" to "anon";

grant update on table "public"."wc_whatsapp_messages" to "anon";

grant delete on table "public"."wc_whatsapp_messages" to "authenticated";

grant insert on table "public"."wc_whatsapp_messages" to "authenticated";

grant references on table "public"."wc_whatsapp_messages" to "authenticated";

grant select on table "public"."wc_whatsapp_messages" to "authenticated";

grant trigger on table "public"."wc_whatsapp_messages" to "authenticated";

grant truncate on table "public"."wc_whatsapp_messages" to "authenticated";

grant update on table "public"."wc_whatsapp_messages" to "authenticated";

grant delete on table "public"."wc_whatsapp_messages" to "service_role";

grant insert on table "public"."wc_whatsapp_messages" to "service_role";

grant references on table "public"."wc_whatsapp_messages" to "service_role";

grant select on table "public"."wc_whatsapp_messages" to "service_role";

grant trigger on table "public"."wc_whatsapp_messages" to "service_role";

grant truncate on table "public"."wc_whatsapp_messages" to "service_role";

grant update on table "public"."wc_whatsapp_messages" to "service_role";

grant delete on table "public"."webrtc_signals" to "anon";

grant insert on table "public"."webrtc_signals" to "anon";

grant references on table "public"."webrtc_signals" to "anon";

grant select on table "public"."webrtc_signals" to "anon";

grant trigger on table "public"."webrtc_signals" to "anon";

grant truncate on table "public"."webrtc_signals" to "anon";

grant update on table "public"."webrtc_signals" to "anon";

grant delete on table "public"."webrtc_signals" to "authenticated";

grant insert on table "public"."webrtc_signals" to "authenticated";

grant references on table "public"."webrtc_signals" to "authenticated";

grant select on table "public"."webrtc_signals" to "authenticated";

grant trigger on table "public"."webrtc_signals" to "authenticated";

grant truncate on table "public"."webrtc_signals" to "authenticated";

grant update on table "public"."webrtc_signals" to "authenticated";

grant delete on table "public"."webrtc_signals" to "service_role";

grant insert on table "public"."webrtc_signals" to "service_role";

grant references on table "public"."webrtc_signals" to "service_role";

grant select on table "public"."webrtc_signals" to "service_role";

grant trigger on table "public"."webrtc_signals" to "service_role";

grant truncate on table "public"."webrtc_signals" to "service_role";

grant update on table "public"."webrtc_signals" to "service_role";


  create policy "account_activity_log_insert_own"
  on "public"."account_activity_log"
  as permissive
  for insert
  to authenticated
with check ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "account_activity_log_select_own"
  on "public"."account_activity_log"
  as permissive
  for select
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "Activities legacy: public read"
  on "public"."activities"
  as permissive
  for select
  to public
using (true);



  create policy "activities_manage_host"
  on "public"."activities"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = activities.host_id) AND (p.auth_id = (auth.uid())::text)))))
with check ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = activities.host_id) AND (p.auth_id = (auth.uid())::text)))));



  create policy "activities_select_public"
  on "public"."activities"
  as permissive
  for select
  to public
using (true);



  create policy "activities_media_manage_host"
  on "public"."activities_media"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM (public.activities a
     JOIN public.profiles p ON ((p.id = a.host_id)))
  WHERE ((a.id = activities_media.activity_id) AND (p.auth_id = (auth.uid())::text)))))
with check ((EXISTS ( SELECT 1
   FROM (public.activities a
     JOIN public.profiles p ON ((p.id = a.host_id)))
  WHERE ((a.id = activities_media.activity_id) AND (p.auth_id = (auth.uid())::text)))));



  create policy "activities_media_select_public"
  on "public"."activities_media"
  as permissive
  for select
  to public
using (true);



  create policy "activity_bookings_insert_auth"
  on "public"."activity_bookings"
  as permissive
  for insert
  to authenticated
with check ((user_id = public.current_profile_id()));



  create policy "activity_bookings_manage_owner"
  on "public"."activity_bookings"
  as permissive
  for all
  to authenticated
using (((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (activity_id IN ( SELECT companion_activities.id
   FROM public.companion_activities
  WHERE (companion_activities.created_by IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.auth_id = (auth.uid())::text)))))))
with check (((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (activity_id IN ( SELECT companion_activities.id
   FROM public.companion_activities
  WHERE (companion_activities.created_by IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.auth_id = (auth.uid())::text)))))));



  create policy "activity_bookings_select_participants"
  on "public"."activity_bookings"
  as permissive
  for select
  to public
using (((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (host_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (activity_id IN ( SELECT companion_activities.id
   FROM public.companion_activities
  WHERE (companion_activities.created_by IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.auth_id = (auth.uid())::text)))))));



  create policy "activity_bookings_update_auth"
  on "public"."activity_bookings"
  as permissive
  for update
  to authenticated
using (((user_id = public.current_profile_id()) OR (activity_id IN ( SELECT companion_activities.id
   FROM public.companion_activities
  WHERE (companion_activities.created_by = public.current_profile_id())))));



  create policy "Reviews: public read"
  on "public"."activity_reviews"
  as permissive
  for select
  to public
using (true);



  create policy "activity_reviews_insert_auth"
  on "public"."activity_reviews"
  as permissive
  for insert
  to authenticated
with check ((reviewer_id = public.current_profile_id()));



  create policy "activity_reviews_manage_owner"
  on "public"."activity_reviews"
  as permissive
  for all
  to authenticated
using (((reviewer_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) AND public.can_review_activity_booking(booking_id, reviewer_id)))
with check (((reviewer_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) AND (booking_id IN ( SELECT activity_bookings.id
   FROM public.activity_bookings
  WHERE (activity_bookings.user_id = activity_reviews.reviewer_id))) AND public.can_review_activity_booking(booking_id, reviewer_id)));



  create policy "activity_reviews_select_public"
  on "public"."activity_reviews"
  as permissive
  for select
  to public
using (true);



  create policy "activity_reviews_update_auth"
  on "public"."activity_reviews"
  as permissive
  for update
  to authenticated
using ((reviewer_id = public.current_profile_id()));



  create policy "reviews_public_read"
  on "public"."activity_reviews"
  as permissive
  for select
  to public
using (true);



  create policy "activity_shares_insert_authenticated"
  on "public"."activity_shares"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "activity_shares_select_all"
  on "public"."activity_shares"
  as permissive
  for select
  to authenticated
using (true);



  create policy "activity_views_insert_authenticated"
  on "public"."activity_views"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "activity_views_select_all"
  on "public"."activity_views"
  as permissive
  for select
  to authenticated
using (true);



  create policy "adminlogs_actor_select"
  on "public"."adminLogs"
  as permissive
  for select
  to authenticated
using (("actorId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "adminlogs_admin_delete"
  on "public"."adminLogs"
  as permissive
  for delete
  to authenticated
using (public.is_admin_user());



  create policy "adminlogs_admin_read_all"
  on "public"."adminLogs"
  as permissive
  for select
  to authenticated
using (public.is_admin_user());



  create policy "adminlogs_insert"
  on "public"."adminLogs"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "admin_access_emails_admin_read"
  on "public"."admin_access_emails"
  as permissive
  for select
  to authenticated
using (public.is_admin_user());



  create policy "admin_access_emails_service_role_all"
  on "public"."admin_access_emails"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "service_role_only"
  on "public"."api_keys"
  as permissive
  for all
  to public
using ((auth.role() = 'service_role'::text));



  create policy "availability_all_authenticated"
  on "public"."availability"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "availability_all_service"
  on "public"."availability"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "availability_manage_owner"
  on "public"."availability"
  as permissive
  for all
  to authenticated
using (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "availability_select_all"
  on "public"."availability"
  as permissive
  for select
  to public
using (true);



  create policy "Avail: public read"
  on "public"."availability_slots"
  as permissive
  for select
  to public
using (true);



  create policy "availability_manage_self"
  on "public"."availability_slots"
  as permissive
  for all
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "availability_select_public"
  on "public"."availability_slots"
  as permissive
  for select
  to public
using (true);



  create policy "blocked_dates_delete_own"
  on "public"."blocked_dates"
  as permissive
  for delete
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "blocked_dates_insert_own"
  on "public"."blocked_dates"
  as permissive
  for insert
  to authenticated
with check ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "blocked_dates_select_own"
  on "public"."blocked_dates"
  as permissive
  for select
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "blocked_dates_update_own"
  on "public"."blocked_dates"
  as permissive
  for update
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "bookingbouncers_insert"
  on "public"."bookingBouncers"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "booking_review_audit_insert"
  on "public"."booking_review_audit_log"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "booking_review_audit_select"
  on "public"."booking_review_audit_log"
  as permissive
  for select
  to authenticated
using (false);



  create policy "booking_review_flags_select"
  on "public"."booking_review_flags"
  as permissive
  for select
  to authenticated
using (false);



  create policy "booking_review_helpful_delete"
  on "public"."booking_review_helpful_votes"
  as permissive
  for delete
  to authenticated
using ((voter_profile_id = public.current_profile_id()));



  create policy "booking_review_helpful_insert"
  on "public"."booking_review_helpful_votes"
  as permissive
  for insert
  to authenticated
with check ((voter_profile_id = public.current_profile_id()));



  create policy "booking_review_helpful_select"
  on "public"."booking_review_helpful_votes"
  as permissive
  for select
  to public
using (true);



  create policy "booking_review_media_admin_select"
  on "public"."booking_review_media"
  as permissive
  for select
  to authenticated
using (public.is_admin());



  create policy "booking_review_media_admin_update"
  on "public"."booking_review_media"
  as permissive
  for update
  to authenticated
using (public.is_admin())
with check (public.is_admin());



  create policy "booking_review_media_delete"
  on "public"."booking_review_media"
  as permissive
  for delete
  to authenticated
using ((reviewer_profile_id = public.current_profile_id()));



  create policy "booking_review_media_insert"
  on "public"."booking_review_media"
  as permissive
  for insert
  to authenticated
with check (((reviewer_profile_id = public.current_profile_id()) AND (review_id IN ( SELECT br.id
   FROM public.booking_reviews br
  WHERE ((br.id = booking_review_media.review_id) AND (br.reviewer_profile_id = booking_review_media.reviewer_profile_id) AND (br.status = 'draft'::text))))));



  create policy "booking_review_media_select"
  on "public"."booking_review_media"
  as permissive
  for select
  to public
using (((reviewer_profile_id = public.current_profile_id()) OR ((review_id IN ( SELECT br.id
   FROM public.booking_reviews br
  WHERE ((br.id = booking_review_media.review_id) AND (br.status = 'revealed'::text) AND (br.moderation_status = 'approved'::text)))) AND (moderation_status = 'approved'::text))));



  create policy "booking_review_responses_insert"
  on "public"."booking_review_responses"
  as permissive
  for insert
  to authenticated
with check (((responder_profile_id = public.current_profile_id()) AND (EXISTS ( SELECT 1
   FROM public.booking_reviews br
  WHERE ((br.id = booking_review_responses.review_id) AND (br.reviewee_profile_id = booking_review_responses.responder_profile_id) AND (br.status = 'revealed'::text) AND (br.moderation_status = 'approved'::text))))));



  create policy "booking_review_responses_select"
  on "public"."booking_review_responses"
  as permissive
  for select
  to public
using (true);



  create policy "booking_reviews_admin_select"
  on "public"."booking_reviews"
  as permissive
  for select
  to authenticated
using (public.is_admin());



  create policy "booking_reviews_admin_update"
  on "public"."booking_reviews"
  as permissive
  for update
  to authenticated
using (public.is_admin())
with check (public.is_admin());



  create policy "booking_reviews_insert_draft"
  on "public"."booking_reviews"
  as permissive
  for insert
  to authenticated
with check (((reviewer_profile_id = public.current_profile_id()) AND (status = 'draft'::text) AND public.can_review_booking(booking_id, reviewer_profile_id, reviewee_profile_id)));



  create policy "booking_reviews_select"
  on "public"."booking_reviews"
  as permissive
  for select
  to public
using (((reviewer_profile_id = public.current_profile_id()) OR ((reviewee_profile_id = public.current_profile_id()) AND (status = 'revealed'::text))));



  create policy "booking_reviews_update_draft"
  on "public"."booking_reviews"
  as permissive
  for update
  to authenticated
using ((reviewer_profile_id = public.current_profile_id()))
with check ((reviewer_profile_id = public.current_profile_id()));



  create policy "booking_status_history_insert_participants"
  on "public"."booking_status_history"
  as permissive
  for insert
  to authenticated
with check ((booking_id IN ( SELECT bookings.id
   FROM public.bookings
  WHERE ((bookings.client_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.auth_id = (auth.uid())::text))) OR (bookings.companion_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.auth_id = (auth.uid())::text))) OR (bookings.bouncer_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.auth_id = (auth.uid())::text)))))));



  create policy "booking_status_history_select_participants"
  on "public"."booking_status_history"
  as permissive
  for select
  to authenticated
using ((booking_id IN ( SELECT bookings.id
   FROM public.bookings
  WHERE ((bookings.client_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.auth_id = (auth.uid())::text))) OR (bookings.companion_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.auth_id = (auth.uid())::text))) OR (bookings.bouncer_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.auth_id = (auth.uid())::text)))))));



  create policy "Bookings: INSERT authenticated"
  on "public"."bookings"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "Bookings: SELECT own"
  on "public"."bookings"
  as permissive
  for select
  to authenticated
using ((("bookerId" IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR ("providerId" IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR ("bouncerId" IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)))));



  create policy "Bookings: UPDATE assigned"
  on "public"."bookings"
  as permissive
  for update
  to authenticated
using (((companion_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (bouncer_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (client_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)))))
with check (((companion_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (bouncer_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (client_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)))));



  create policy "bookings_delete_client"
  on "public"."bookings"
  as permissive
  for delete
  to authenticated
using ((client_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "bookings_insert_client"
  on "public"."bookings"
  as permissive
  for insert
  to authenticated
with check ((client_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "bookings_select_participants"
  on "public"."bookings"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.auth_id = (auth.uid())::text) AND (p.id = ANY (ARRAY[bookings.client_id, bookings.companion_id, bookings.bouncer_id]))))));



  create policy "bookings_update_participants"
  on "public"."bookings"
  as permissive
  for update
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.auth_id = (auth.uid())::text) AND (p.id = ANY (ARRAY[bookings.client_id, bookings.companion_id, bookings.bouncer_id]))))))
with check ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.auth_id = (auth.uid())::text) AND (p.id = ANY (ARRAY[bookings.client_id, bookings.companion_id, bookings.bouncer_id]))))));



  create policy "bouncer_services_delete_own"
  on "public"."bouncer_services"
  as permissive
  for delete
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = bouncer_services.profile_id) AND (profiles.auth_id = (auth.uid())::text)))));



  create policy "bouncer_services_insert_own"
  on "public"."bouncer_services"
  as permissive
  for insert
  to authenticated
with check ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = bouncer_services.profile_id) AND (profiles.auth_id = (auth.uid())::text)))));



  create policy "bouncer_services_select_all"
  on "public"."bouncer_services"
  as permissive
  for select
  to authenticated
using (true);



  create policy "bouncer_services_update_own"
  on "public"."bouncer_services"
  as permissive
  for update
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = bouncer_services.profile_id) AND (profiles.auth_id = (auth.uid())::text)))));



  create policy "Owner can insert bud conversations"
  on "public"."bud_conversations"
  as permissive
  for insert
  to public
with check ((user_id = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "Owner can read bud conversations"
  on "public"."bud_conversations"
  as permissive
  for select
  to public
using ((user_id = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "service_role_conv"
  on "public"."bud_conversations"
  as permissive
  for all
  to public
using ((auth.role() = 'service_role'::text));



  create policy "ice_insert"
  on "public"."call_ice_candidates"
  as permissive
  for insert
  to authenticated
with check (((sender_profile_id = public.current_profile_id()) AND (EXISTS ( SELECT 1
   FROM public.call_logs cl
  WHERE ((cl.id = call_ice_candidates.call_log_id) AND ((cl.caller_profile_id = public.current_profile_id()) OR (cl.callee_profile_id = public.current_profile_id())))))));



  create policy "ice_select"
  on "public"."call_ice_candidates"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.call_logs cl
  WHERE ((cl.id = call_ice_candidates.call_log_id) AND ((cl.caller_profile_id = public.current_profile_id()) OR (cl.callee_profile_id = public.current_profile_id()))))));



  create policy "call_logs_insert"
  on "public"."call_logs"
  as permissive
  for insert
  to authenticated
with check ((caller_profile_id = public.current_profile_id()));



  create policy "call_logs_select"
  on "public"."call_logs"
  as permissive
  for select
  to authenticated
using (((caller_profile_id = public.current_profile_id()) OR (callee_profile_id = public.current_profile_id())));



  create policy "call_logs_update"
  on "public"."call_logs"
  as permissive
  for update
  to authenticated
using (((caller_profile_id = public.current_profile_id()) OR (callee_profile_id = public.current_profile_id())));



  create policy "insert_own_transcript"
  on "public"."call_transcripts"
  as permissive
  for insert
  to authenticated
with check ((profile_id = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "select_own_transcript"
  on "public"."call_transcripts"
  as permissive
  for select
  to authenticated
using ((profile_id = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "campaigns_delete_own"
  on "public"."campaigns"
  as permissive
  for delete
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "campaigns_insert_own"
  on "public"."campaigns"
  as permissive
  for insert
  to authenticated
with check ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "campaigns_select_own"
  on "public"."campaigns"
  as permissive
  for select
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "campaigns_update_own"
  on "public"."campaigns"
  as permissive
  for update
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "cc_activities_read"
  on "public"."cc_activities"
  as permissive
  for select
  to authenticated
using (true);



  create policy "cc_activities_tenant"
  on "public"."cc_activities"
  as permissive
  for all
  to authenticated
using ((facility_id = public.auth_user_facility_id()))
with check ((facility_id = public.auth_user_facility_id()));



  create policy "cc_activities_write"
  on "public"."cc_activities"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "cc_attendance_all"
  on "public"."cc_activity_attendance"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "anon_read_cc_activity_templates"
  on "public"."cc_activity_templates"
  as permissive
  for select
  to authenticated, anon
using (true);



  create policy "cc_tmpl_all"
  on "public"."cc_activity_templates"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "cc_admin_users_tenant"
  on "public"."cc_admin_users"
  as permissive
  for all
  to authenticated
using ((facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1)))
with check ((facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "cc_audit_insert"
  on "public"."cc_audit_log"
  as permissive
  for insert
  to authenticated
with check ((facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "cc_audit_tenant"
  on "public"."cc_audit_log"
  as permissive
  for select
  to authenticated
using ((facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "cc_billing_tenant"
  on "public"."cc_billing_info"
  as permissive
  for all
  to authenticated
using ((facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1)))
with check ((facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "cc_assignments_all"
  on "public"."cc_companion_assignments"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "cc_assignments_tenant"
  on "public"."cc_companion_assignments"
  as permissive
  for all
  to authenticated
using (((facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1)) OR (resident_id IN ( SELECT cc_residents.id
   FROM public.cc_residents
  WHERE (cc_residents.facility_id = ( SELECT cc_org_users.facility_id
           FROM public.cc_org_users
          WHERE (cc_org_users.user_id = (auth.uid())::text)
         LIMIT 1))))))
with check ((resident_id IN ( SELECT cc_residents.id
   FROM public.cc_residents
  WHERE (cc_residents.facility_id = ( SELECT cc_org_users.facility_id
           FROM public.cc_org_users
          WHERE (cc_org_users.user_id = (auth.uid())::text)
         LIMIT 1)))));



  create policy "cc_bk_all"
  on "public"."cc_companion_bookings"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "cc_bk_anon_insert"
  on "public"."cc_companion_bookings"
  as permissive
  for insert
  to anon
with check (true);



  create policy "cc_bk_anon_read"
  on "public"."cc_companion_bookings"
  as permissive
  for select
  to anon
using (true);



  create policy "cc_bookings_tenant"
  on "public"."cc_companion_bookings"
  as permissive
  for all
  to authenticated
using ((facility_id = public.auth_user_facility_id()))
with check ((facility_id = public.auth_user_facility_id()));



  create policy "cc_comp_all"
  on "public"."cc_companions"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "cc_comp_anon_read"
  on "public"."cc_companions"
  as permissive
  for select
  to anon
using (true);



  create policy "cc_companions_read"
  on "public"."cc_companions"
  as permissive
  for select
  to authenticated
using (true);



  create policy "cc_companions_tenant"
  on "public"."cc_companions"
  as permissive
  for all
  to authenticated
using ((facility_id = public.auth_user_facility_id()))
with check ((facility_id = public.auth_user_facility_id()));



  create policy "cc_companions_update"
  on "public"."cc_companions"
  as permissive
  for update
  to authenticated
using (true);



  create policy "cc_companions_write"
  on "public"."cc_companions"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "companions_update_own"
  on "public"."cc_companions"
  as permissive
  for update
  to authenticated
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "cc_facilities_insert"
  on "public"."cc_facilities"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "cc_facilities_read"
  on "public"."cc_facilities"
  as permissive
  for select
  to authenticated
using (true);



  create policy "cc_facilities_tenant"
  on "public"."cc_facilities"
  as permissive
  for select
  to authenticated
using ((id = public.auth_user_facility_id()));



  create policy "cc_facilities_update"
  on "public"."cc_facilities"
  as permissive
  for update
  to authenticated
using ((id = public.auth_user_facility_id()));



  create policy "cc_fac_members_read"
  on "public"."cc_facility_members"
  as permissive
  for select
  to authenticated
using (true);



  create policy "cc_fac_members_write"
  on "public"."cc_facility_members"
  as permissive
  for insert
  to authenticated
with check ((user_id = auth.uid()));



  create policy "cc_family_all"
  on "public"."cc_family_connections"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "cc_family_connections_tenant"
  on "public"."cc_family_connections"
  as permissive
  for all
  to authenticated
using (((user_id = auth.uid()) OR (resident_id IN ( SELECT cc_residents.id
   FROM public.cc_residents
  WHERE (cc_residents.facility_id = ( SELECT cc_org_users.facility_id
           FROM public.cc_org_users
          WHERE (cc_org_users.user_id = (auth.uid())::text)
         LIMIT 1))))))
with check ((resident_id IN ( SELECT cc_residents.id
   FROM public.cc_residents
  WHERE (cc_residents.facility_id = ( SELECT cc_org_users.facility_id
           FROM public.cc_org_users
          WHERE (cc_org_users.user_id = (auth.uid())::text)
         LIMIT 1)))));



  create policy "auth_all_cc_family_members"
  on "public"."cc_family_members"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "cc_fm_all"
  on "public"."cc_family_members"
  as permissive
  for all
  to authenticated
using ((primary_user_id = auth.uid()))
with check ((primary_user_id = auth.uid()));



  create policy "cc_family_messages_rls"
  on "public"."cc_family_messages"
  as permissive
  for all
  to authenticated
using (((family_user_id = (auth.uid())::text) OR (facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1))))
with check (((family_user_id = (auth.uid())::text) OR (facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1))));



  create policy "cc_family_users_insert"
  on "public"."cc_family_users"
  as permissive
  for insert
  to authenticated
with check ((family_user_id = (auth.uid())::text));



  create policy "cc_family_users_self"
  on "public"."cc_family_users"
  as permissive
  for select
  to authenticated
using (((family_user_id = (auth.uid())::text) OR (facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1))));



  create policy "cc_family_users_update"
  on "public"."cc_family_users"
  as permissive
  for update
  to authenticated
using ((facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "cc_marketplace_delete_tenant"
  on "public"."cc_marketplace_companions"
  as permissive
  for delete
  to authenticated
using ((facility_id = public.auth_user_facility_id()));



  create policy "cc_marketplace_read_all"
  on "public"."cc_marketplace_companions"
  as permissive
  for select
  to authenticated, anon
using (true);



  create policy "cc_marketplace_update_tenant"
  on "public"."cc_marketplace_companions"
  as permissive
  for update
  to authenticated
using ((facility_id = public.auth_user_facility_id()));



  create policy "cc_marketplace_write_tenant"
  on "public"."cc_marketplace_companions"
  as permissive
  for insert
  to authenticated
with check ((facility_id = public.auth_user_facility_id()));



  create policy "cc_mktcomp_all"
  on "public"."cc_marketplace_companions"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "cc_mktcomp_anon_read"
  on "public"."cc_marketplace_companions"
  as permissive
  for select
  to anon
using (true);



  create policy "cc_messages_tenant"
  on "public"."cc_messages"
  as permissive
  for all
  to authenticated
using ((facility_id = public.auth_user_facility_id()))
with check ((facility_id = public.auth_user_facility_id()));



  create policy "cc_mood_all"
  on "public"."cc_mood_checkins"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "cc_mood_checkins_tenant"
  on "public"."cc_mood_checkins"
  as permissive
  for all
  to authenticated
using (((facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1)) OR (resident_id IN ( SELECT cc_residents.id
   FROM public.cc_residents
  WHERE (cc_residents.facility_id = ( SELECT cc_org_users.facility_id
           FROM public.cc_org_users
          WHERE (cc_org_users.user_id = (auth.uid())::text)
         LIMIT 1))))))
with check ((resident_id IN ( SELECT cc_residents.id
   FROM public.cc_residents
  WHERE (cc_residents.facility_id = ( SELECT cc_org_users.facility_id
           FROM public.cc_org_users
          WHERE (cc_org_users.user_id = (auth.uid())::text)
         LIMIT 1)))));



  create policy "cc_org_users_insert"
  on "public"."cc_org_users"
  as permissive
  for insert
  to authenticated
with check (((user_id = (auth.uid())::text) OR true));



  create policy "cc_org_users_same_facility"
  on "public"."cc_org_users"
  as permissive
  for select
  to authenticated
using ((facility_id = public.auth_user_facility_id()));



  create policy "cc_org_users_self"
  on "public"."cc_org_users"
  as permissive
  for select
  to authenticated
using ((user_id = (auth.uid())::text));



  create policy "cc_org_users_service"
  on "public"."cc_org_users"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "cc_residents_read"
  on "public"."cc_residents"
  as permissive
  for select
  to authenticated
using (true);



  create policy "cc_residents_tenant"
  on "public"."cc_residents"
  as permissive
  for all
  to authenticated
using ((facility_id = public.auth_user_facility_id()))
with check ((facility_id = public.auth_user_facility_id()));



  create policy "cc_residents_write"
  on "public"."cc_residents"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "cc_security_tenant"
  on "public"."cc_security_settings"
  as permissive
  for all
  to authenticated
using ((facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1)))
with check ((facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "cc_notes_all"
  on "public"."cc_session_notes"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "cc_session_notes_tenant"
  on "public"."cc_session_notes"
  as permissive
  for all
  to authenticated
using (((facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1)) OR (resident_id IN ( SELECT cc_residents.id
   FROM public.cc_residents
  WHERE (cc_residents.facility_id = ( SELECT cc_org_users.facility_id
           FROM public.cc_org_users
          WHERE (cc_org_users.user_id = (auth.uid())::text)
         LIMIT 1))))))
with check ((resident_id IN ( SELECT cc_residents.id
   FROM public.cc_residents
  WHERE (cc_residents.facility_id = ( SELECT cc_org_users.facility_id
           FROM public.cc_org_users
          WHERE (cc_org_users.user_id = (auth.uid())::text)
         LIMIT 1)))));



  create policy "cc_staff_tenant"
  on "public"."cc_staff"
  as permissive
  for all
  to authenticated
using ((facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1)))
with check ((facility_id = ( SELECT cc_org_users.facility_id
   FROM public.cc_org_users
  WHERE (cc_org_users.user_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "Activities: owner manage"
  on "public"."companion_activities"
  as permissive
  for all
  to public
using ((created_by IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = current_setting('request.jwt.claim.sub'::text, true)))))
with check ((created_by IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = current_setting('request.jwt.claim.sub'::text, true)))));



  create policy "Activities: public read active"
  on "public"."companion_activities"
  as permissive
  for select
  to public
using ((is_active = true));



  create policy "activities_anon_select_public"
  on "public"."companion_activities"
  as permissive
  for select
  to public
using ((is_active = true));



  create policy "companion_activities_delete"
  on "public"."companion_activities"
  as permissive
  for delete
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = companion_activities.created_by) AND (profiles.auth_id = (auth.uid())::text)))));



  create policy "companion_activities_insert"
  on "public"."companion_activities"
  as permissive
  for insert
  to authenticated
with check ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = companion_activities.created_by) AND (profiles.auth_id = (auth.uid())::text)))));



  create policy "companion_activities_manage_owner"
  on "public"."companion_activities"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = companion_activities.created_by) AND (p.auth_id = (auth.uid())::text)))))
with check ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = companion_activities.created_by) AND (p.auth_id = (auth.uid())::text)))));



  create policy "companion_activities_select"
  on "public"."companion_activities"
  as permissive
  for select
  to public
using (((is_active = true) OR (EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = companion_activities.created_by) AND (profiles.auth_id = (auth.uid())::text))))));



  create policy "companion_activities_select_public"
  on "public"."companion_activities"
  as permissive
  for select
  to public
using (((is_active = true) OR (EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = companion_activities.created_by) AND (p.auth_id = (auth.uid())::text))))));



  create policy "companion_activities_update"
  on "public"."companion_activities"
  as permissive
  for update
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = companion_activities.created_by) AND (profiles.auth_id = (auth.uid())::text)))));



  create policy "owner_manage_activities"
  on "public"."companion_activities"
  as permissive
  for all
  to public
using ((created_by IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = current_setting('request.jwt.claim.sub'::text, true)))))
with check ((created_by IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = current_setting('request.jwt.claim.sub'::text, true)))));



  create policy "public_active_activities"
  on "public"."companion_activities"
  as permissive
  for select
  to public
using ((is_active = true));



  create policy "companion_services_delete_own"
  on "public"."companion_services"
  as permissive
  for delete
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = companion_services.profile_id) AND (profiles.auth_id = (auth.uid())::text)))));



  create policy "companion_services_insert_own"
  on "public"."companion_services"
  as permissive
  for insert
  to authenticated
with check ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = companion_services.profile_id) AND (profiles.auth_id = (auth.uid())::text)))));



  create policy "companion_services_select_all"
  on "public"."companion_services"
  as permissive
  for select
  to authenticated
using (true);



  create policy "companion_services_update_own"
  on "public"."companion_services"
  as permissive
  for update
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = companion_services.profile_id) AND (profiles.auth_id = (auth.uid())::text)))));



  create policy "Anyone can read active companions"
  on "public"."companions"
  as permissive
  for select
  to public
using ((status = 'active'::text));



  create policy "Owner can insert companion profile"
  on "public"."companions"
  as permissive
  for insert
  to public
with check ((user_id = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "Owner can update companion profile"
  on "public"."companions"
  as permissive
  for update
  to public
using ((user_id = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "Conversations: INSERT participants"
  on "public"."conversations"
  as permissive
  for insert
  to authenticated
with check (((participant1_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (participant2_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)))));



  create policy "Conversations: SELECT participants"
  on "public"."conversations"
  as permissive
  for select
  to authenticated
using (((participant1_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (participant2_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)))));



  create policy "Conversations: UPDATE participants"
  on "public"."conversations"
  as permissive
  for update
  to authenticated
using (((participant1_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (participant2_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)))));



  create policy "conversations_delete_participant"
  on "public"."conversations"
  as permissive
  for delete
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = ANY (ARRAY[conversations.participant1_id, conversations.participant2_id])) AND (p.auth_id = (auth.uid())::text)))));



  create policy "conversations_insert_participant"
  on "public"."conversations"
  as permissive
  for insert
  to authenticated
with check (((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.auth_id = (auth.uid())::text) AND ((p.id = conversations.participant1_id) OR (p.id = conversations.participant2_id))))) AND public.can_message_between_profiles((participant1_id)::bigint, (participant2_id)::bigint)));



  create policy "conversations_select_participant"
  on "public"."conversations"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = ANY (ARRAY[conversations.participant1_id, conversations.participant2_id])) AND (p.auth_id = (auth.uid())::text)))));



  create policy "conversations_update_participant"
  on "public"."conversations"
  as permissive
  for update
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = ANY (ARRAY[conversations.participant1_id, conversations.participant2_id])) AND (p.auth_id = (auth.uid())::text)))))
with check ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = ANY (ARRAY[conversations.participant1_id, conversations.participant2_id])) AND (p.auth_id = (auth.uid())::text)))));



  create policy "admissions_institution_read"
  on "public"."ct_admissions"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "admissions_institution_write"
  on "public"."ct_admissions"
  as permissive
  for insert
  to public
with check (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "ct_ai_all"
  on "public"."ct_ai_insights"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "announcements_institution_read"
  on "public"."ct_announcements"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "announcements_institution_rls"
  on "public"."ct_announcements"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "ct_announcements_tenant"
  on "public"."ct_announcements"
  as permissive
  for all
  to authenticated
using ((org_id = public.auth_user_org_id()))
with check ((org_id = public.auth_user_org_id()));



  create policy "ct_ct_announcements_open"
  on "public"."ct_announcements"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "institution_select"
  on "public"."ct_announcements"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "read_institution_announcements"
  on "public"."ct_announcements"
  as permissive
  for select
  to public
using ((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))));



  create policy "staff_manage_announcements"
  on "public"."ct_announcements"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.institution_id = ct_announcements.institution_id) AND (ct_users.role = ANY (ARRAY['admin'::text, 'staff'::text, 'student_rep'::text, 'it_director'::text]))))));



  create policy "institution_select"
  on "public"."ct_api_keys"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "All authenticated read assignment docs"
  on "public"."ct_assignment_documents"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Teachers insert assignment docs"
  on "public"."ct_assignment_documents"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "Students manage own submissions"
  on "public"."ct_assignment_submissions"
  as permissive
  for all
  to authenticated
using ((student_id = auth.uid()))
with check ((student_id = auth.uid()));



  create policy "Teachers read all submissions"
  on "public"."ct_assignment_submissions"
  as permissive
  for select
  to authenticated
using (true);



  create policy "ct_ct_assignments_open"
  on "public"."ct_assignments"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "read_institution_assignments"
  on "public"."ct_assignments"
  as permissive
  for select
  to public
using ((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))));



  create policy "teachers_manage_assignments"
  on "public"."ct_assignments"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.institution_id = ct_assignments.institution_id) AND (ct_users.role = ANY (ARRAY['admin'::text, 'teacher'::text, 'it_director'::text]))))));



  create policy "coaches_manage_athletes"
  on "public"."ct_athletes"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'coach'::text, 'it_director'::text]))))));



  create policy "read_institution_athletes"
  on "public"."ct_athletes"
  as permissive
  for select
  to public
using ((team_id IN ( SELECT ct_sports_teams.id
   FROM public.ct_sports_teams
  WHERE (ct_sports_teams.institution_id = ( SELECT ct_users.institution_id
           FROM public.ct_users
          WHERE (ct_users.id = auth.uid()))))));



  create policy "ct_ct_attendance_open"
  on "public"."ct_attendance"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "admins_read_audit"
  on "public"."ct_audit_logs"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'it_director'::text]))))));



  create policy "institution_select"
  on "public"."ct_audit_logs"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "system_insert_audit"
  on "public"."ct_audit_logs"
  as permissive
  for insert
  to public
with check (true);



  create policy "institution_select"
  on "public"."ct_billing_invoices"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "invoices_institution_insert"
  on "public"."ct_billing_invoices"
  as permissive
  for insert
  to public
with check ((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))));



  create policy "invoices_read_institution"
  on "public"."ct_billing_invoices"
  as permissive
  for select
  to public
using (((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))) AND (EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'it_director'::text])))))));



  create policy "superadmin_read_all_invoices"
  on "public"."ct_billing_invoices"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_superadmins sa
  WHERE ((sa.email = (( SELECT users.email
           FROM auth.users
          WHERE (users.id = auth.uid())))::text) AND (sa.is_active = true)))));



  create policy "superadmins_full_invoices"
  on "public"."ct_billing_invoices"
  as permissive
  for all
  to public
using (public.is_superadmin());



  create policy "admins_manage_billing_plans"
  on "public"."ct_billing_plans"
  as permissive
  for all
  to public
using (((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))) AND (EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'it_director'::text])))))));



  create policy "admins_read_billing_plans"
  on "public"."ct_billing_plans"
  as permissive
  for select
  to public
using ((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))));



  create policy "institution_select"
  on "public"."ct_billing_plans"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "superadmins_full_billing_plans"
  on "public"."ct_billing_plans"
  as permissive
  for all
  to public
using (public.is_superadmin());



  create policy "ct_blog_posts_public_read"
  on "public"."ct_blog_posts"
  as permissive
  for select
  to public
using (true);



  create policy "broadcasts_insert"
  on "public"."ct_broadcast_notifications"
  as permissive
  for insert
  to public
with check ((public.is_superadmin() OR ((institution_id = public.get_my_institution_id()) AND (EXISTS ( SELECT 1
   FROM public.ct_users u
  WHERE ((u.id = auth.uid()) AND (u.role = ANY (ARRAY['admin'::text, 'it_director'::text]))))))));



  create policy "broadcasts_read"
  on "public"."ct_broadcast_notifications"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "club_leaders_manage_budget_items"
  on "public"."ct_budget_items"
  as permissive
  for all
  to public
using ((budget_id IN ( SELECT b.id
   FROM (public.ct_budgets b
     JOIN public.ct_clubs c ON ((c.id = b.club_id)))
  WHERE (c.institution_id = ( SELECT ct_users.institution_id
           FROM public.ct_users
          WHERE (ct_users.id = auth.uid()))))));



  create policy "club_leaders_manage_budgets"
  on "public"."ct_budgets"
  as permissive
  for all
  to public
using ((club_id IN ( SELECT ct_clubs.id
   FROM public.ct_clubs
  WHERE (ct_clubs.institution_id = ( SELECT ct_users.institution_id
           FROM public.ct_users
          WHERE (ct_users.id = auth.uid()))))));



  create policy "ct_budgets_open"
  on "public"."ct_budgets"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "institution_select"
  on "public"."ct_budgets"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "inst_challenge_entries"
  on "public"."ct_challenge_entries"
  as permissive
  for all
  to public
using (((institution_id = public.get_my_institution_id()) OR (user_id = auth.uid())));



  create policy "institution_select"
  on "public"."ct_challenge_entries"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "auth insert scores"
  on "public"."ct_challenge_scores"
  as permissive
  for insert
  to public
with check ((auth.uid() = posted_by));



  create policy "auth read scores"
  on "public"."ct_challenge_scores"
  as permissive
  for select
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "institution_select"
  on "public"."ct_children"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "ct_ct_classes_open"
  on "public"."ct_classes"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_cec_all"
  on "public"."ct_club_election_candidates"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_cev_all"
  on "public"."ct_club_election_votes"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_ce_all"
  on "public"."ct_club_elections"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "club_events_institution_read"
  on "public"."ct_club_events"
  as permissive
  for all
  to public
using (((EXISTS ( SELECT 1
   FROM public.ct_clubs c
  WHERE ((c.id = ct_club_events.club_id) AND (c.institution_id = public.get_my_institution_id())))) OR public.is_superadmin()));



  create policy "ct_ct_club_members_open"
  on "public"."ct_club_members"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "institution_select"
  on "public"."ct_club_members"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "manage_own_membership"
  on "public"."ct_club_members"
  as permissive
  for all
  to public
using (((user_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'it_director'::text, 'club_leader'::text])))))));



  create policy "read_club_members"
  on "public"."ct_club_members"
  as permissive
  for select
  to public
using ((club_id IN ( SELECT ct_clubs.id
   FROM public.ct_clubs
  WHERE (ct_clubs.institution_id = ( SELECT ct_users.institution_id
           FROM public.ct_users
          WHERE (ct_users.id = auth.uid()))))));



  create policy "ct_memberships_all"
  on "public"."ct_club_memberships"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_cp_all"
  on "public"."ct_club_posts"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_crr_all"
  on "public"."ct_club_recognition_requests"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_crr_anon"
  on "public"."ct_club_recognition_requests"
  as permissive
  for insert
  to anon
with check (true);



  create policy "clubs_institution_read"
  on "public"."ct_clubs"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "clubs_institution_rls"
  on "public"."ct_clubs"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "ct_clubs_delete"
  on "public"."ct_clubs"
  as permissive
  for delete
  to authenticated
using (true);



  create policy "ct_clubs_read"
  on "public"."ct_clubs"
  as permissive
  for select
  to authenticated
using (true);



  create policy "ct_clubs_tenant"
  on "public"."ct_clubs"
  as permissive
  for all
  to authenticated
using ((org_id = public.auth_user_org_id()))
with check ((org_id = public.auth_user_org_id()));



  create policy "ct_clubs_update"
  on "public"."ct_clubs"
  as permissive
  for update
  to authenticated
using (true);



  create policy "ct_clubs_write"
  on "public"."ct_clubs"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "ct_ct_clubs_open"
  on "public"."ct_clubs"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "institution_select"
  on "public"."ct_clubs"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "manage_institution_clubs"
  on "public"."ct_clubs"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.institution_id = ct_clubs.institution_id) AND (ct_users.role = ANY (ARRAY['admin'::text, 'it_director'::text, 'club_leader'::text]))))));



  create policy "read_institution_clubs"
  on "public"."ct_clubs"
  as permissive
  for select
  to public
using ((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))));



  create policy "All read enrollments"
  on "public"."ct_course_enrollments"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Students manage own enrollments"
  on "public"."ct_course_enrollments"
  as permissive
  for all
  to authenticated
using ((student_id = auth.uid()))
with check ((student_id = auth.uid()));



  create policy "courses_institution_read"
  on "public"."ct_courses"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "ct_ct_courses_open"
  on "public"."ct_courses"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "institution_select"
  on "public"."ct_courses"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "read_institution_courses"
  on "public"."ct_courses"
  as permissive
  for select
  to public
using ((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))));



  create policy "teachers_manage_courses"
  on "public"."ct_courses"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.institution_id = ct_courses.institution_id) AND (ct_users.role = ANY (ARRAY['admin'::text, 'teacher'::text, 'it_director'::text]))))));



  create policy "daily_reports_institution_read"
  on "public"."ct_daily_reports"
  as permissive
  for select
  to public
using (((teacher_id = auth.uid()) OR public.is_superadmin()));



  create policy "daily_reports_teacher_write"
  on "public"."ct_daily_reports"
  as permissive
  for insert
  to public
with check ((teacher_id = auth.uid()));



  create policy "Admins can read demo requests"
  on "public"."ct_demo_requests"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'it_director'::text]))))));



  create policy "Anyone can insert demo requests"
  on "public"."ct_demo_requests"
  as permissive
  for insert
  to public
with check (true);



  create policy "dm_insert"
  on "public"."ct_direct_messages"
  as permissive
  for insert
  to public
with check (((sender_id = auth.uid()) AND (institution_id = public.get_my_institution_id())));



  create policy "dm_participants_read"
  on "public"."ct_direct_messages"
  as permissive
  for select
  to public
using (((sender_id = auth.uid()) OR (recipient_id = auth.uid()) OR public.is_superadmin()));



  create policy "dm_select"
  on "public"."ct_direct_messages"
  as permissive
  for select
  to public
using (((sender_id = auth.uid()) OR (recipient_id = auth.uid())));



  create policy "ct_dp_all"
  on "public"."ct_discovery_profiles"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "rate_limits_service_only"
  on "public"."ct_email_rate_limits"
  as permissive
  for all
  to public
using (false)
with check (false);



  create policy "email_verifications_own"
  on "public"."ct_email_verifications"
  as permissive
  for select
  to public
using ((user_id = auth.uid()));



  create policy "ct_ct_engagement_points_open"
  on "public"."ct_engagement_points"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "institution_select"
  on "public"."ct_engagement_points"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "ct_engagement_scores_open"
  on "public"."ct_engagement_scores"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "institution_select"
  on "public"."ct_engagement_scores"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "staff_read_engagement"
  on "public"."ct_engagement_scores"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'teacher'::text, 'it_director'::text, 'coach'::text]))))));



  create policy "users_own_engagement"
  on "public"."ct_engagement_scores"
  as permissive
  for all
  to public
using ((user_id = auth.uid()));



  create policy "Admins read enrollments"
  on "public"."ct_enrollments"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.ct_users u
  WHERE ((u.id = auth.uid()) AND (u.role = ANY (ARRAY['admin'::text, 'it_director'::text, 'staff'::text]))))));



  create policy "Insert own enrollment"
  on "public"."ct_enrollments"
  as permissive
  for insert
  to authenticated
with check (((student_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.ct_users u
  WHERE ((u.id = auth.uid()) AND (u.role = ANY (ARRAY['admin'::text, 'teacher'::text, 'staff'::text])))))));



  create policy "Students read own enrollments"
  on "public"."ct_enrollments"
  as permissive
  for select
  to authenticated
using ((student_id = auth.uid()));



  create policy "Teachers read enrollments"
  on "public"."ct_enrollments"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM (public.ct_classes cl
     JOIN public.ct_courses co ON ((co.id = cl.course_id)))
  WHERE ((cl.id = ct_enrollments.class_id) AND (co.teacher_id = auth.uid())))));



  create policy "institution_select"
  on "public"."ct_error_logs"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "superadmin_error_logs"
  on "public"."ct_error_logs"
  as permissive
  for all
  to public
using (public.is_superadmin());



  create policy "All read RSVPs"
  on "public"."ct_event_rsvps"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Users manage own RSVPs"
  on "public"."ct_event_rsvps"
  as permissive
  for all
  to authenticated
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "ct_ct_event_rsvps_open"
  on "public"."ct_event_rsvps"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_rsvp_all"
  on "public"."ct_event_rsvps"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "staff_read_rsvps"
  on "public"."ct_event_rsvps"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'staff'::text, 'teacher'::text, 'it_director'::text]))))));



  create policy "users_can_rsvp"
  on "public"."ct_event_rsvps"
  as permissive
  for all
  to public
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "ct_ct_events_open"
  on "public"."ct_events"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_events_delete"
  on "public"."ct_events"
  as permissive
  for delete
  to authenticated
using ((created_by = auth.uid()));



  create policy "ct_events_insert"
  on "public"."ct_events"
  as permissive
  for insert
  to authenticated
with check ((created_by = auth.uid()));



  create policy "ct_events_read"
  on "public"."ct_events"
  as permissive
  for select
  to authenticated
using (true);



  create policy "ct_events_tenant"
  on "public"."ct_events"
  as permissive
  for all
  to authenticated
using ((org_id = public.auth_user_org_id()))
with check ((org_id = public.auth_user_org_id()));



  create policy "ct_events_update"
  on "public"."ct_events"
  as permissive
  for update
  to authenticated
using ((created_by = auth.uid()));



  create policy "events_institution_read"
  on "public"."ct_events"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "events_institution_rls"
  on "public"."ct_events"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "institution_members_read_events"
  on "public"."ct_events"
  as permissive
  for select
  to public
using (((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))) OR (status = ANY (ARRAY['active'::text, 'published'::text]))));



  create policy "institution_select"
  on "public"."ct_events"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "staff_can_manage_events"
  on "public"."ct_events"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.institution_id = ct_events.institution_id) AND (ct_users.role = ANY (ARRAY['admin'::text, 'staff'::text, 'teacher'::text, 'coach'::text, 'student_rep'::text, 'it_director'::text]))))));



  create policy "institution_select"
  on "public"."ct_feature_events"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "superadmin_read"
  on "public"."ct_feature_events"
  as permissive
  for select
  to public
using (public.is_superadmin());



  create policy "user_insert"
  on "public"."ct_feature_events"
  as permissive
  for insert
  to public
with check (true);



  create policy "superadmins_all_trial_requests"
  on "public"."ct_free_trial_requests"
  as permissive
  for all
  to public
using (public.is_superadmin());



  create policy "users_own_trial_requests"
  on "public"."ct_free_trial_requests"
  as permissive
  for all
  to public
using ((user_id = auth.uid()));



  create policy "ct_funding_requests_open"
  on "public"."ct_funding_requests"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "institution_select"
  on "public"."ct_funding_requests"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "games_read"
  on "public"."ct_games"
  as permissive
  for select
  to public
using (true);



  create policy "games_write"
  on "public"."ct_games"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "All read grades"
  on "public"."ct_grades"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Teachers manage grades"
  on "public"."ct_grades"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_ct_grades_open"
  on "public"."ct_grades"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "own_grades"
  on "public"."ct_grades"
  as permissive
  for select
  to public
using (((student_id = auth.uid()) OR (graded_by = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'teacher'::text, 'it_director'::text, 'parent'::text])))))));



  create policy "teachers_grade"
  on "public"."ct_grades"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'teacher'::text]))))));



  create policy "ct_ga_anon_read"
  on "public"."ct_group_activities"
  as permissive
  for select
  to anon
using ((status = 'open'::text));



  create policy "ct_group_activities_tenant"
  on "public"."ct_group_activities"
  as permissive
  for all
  to authenticated
using ((org_id = ( SELECT ct_org_users.org_id
   FROM public.ct_org_users
  WHERE (ct_org_users.user_id = (auth.uid())::text)
 LIMIT 1)))
with check ((org_id = ( SELECT ct_org_users.org_id
   FROM public.ct_org_users
  WHERE (ct_org_users.user_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "ct_gam_all"
  on "public"."ct_group_activity_members"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_gam_anon_insert"
  on "public"."ct_group_activity_members"
  as permissive
  for insert
  to anon
with check (true);



  create policy "admins_read_institution_requests"
  on "public"."ct_institution_requests"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users u
  WHERE ((u.id = auth.uid()) AND (u.role = ANY (ARRAY['admin'::text, 'it_director'::text]))))));



  create policy "superadmin_all_requests"
  on "public"."ct_institution_requests"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_superadmins
  WHERE (ct_superadmins.user_id = auth.uid()))));



  create policy "superadmins_all_requests"
  on "public"."ct_institution_requests"
  as permissive
  for all
  to public
using (public.is_superadmin());



  create policy "users_own_requests"
  on "public"."ct_institution_requests"
  as permissive
  for all
  to public
using ((user_id = auth.uid()));



  create policy "institution settings read"
  on "public"."ct_institution_settings"
  as permissive
  for select
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "institution settings update"
  on "public"."ct_institution_settings"
  as permissive
  for update
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "institution settings write"
  on "public"."ct_institution_settings"
  as permissive
  for insert
  to public
with check ((auth.role() = 'authenticated'::text));



  create policy "institution_select"
  on "public"."ct_institution_subscriptions"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "subscription_admin_insert"
  on "public"."ct_institution_subscriptions"
  as permissive
  for insert
  to public
with check ((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))));



  create policy "subscription_manage_admin"
  on "public"."ct_institution_subscriptions"
  as permissive
  for all
  to public
using (((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))) AND (EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'it_director'::text])))))));



  create policy "subscription_read_own_institution"
  on "public"."ct_institution_subscriptions"
  as permissive
  for select
  to public
using ((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))));



  create policy "superadmins_full_subscriptions"
  on "public"."ct_institution_subscriptions"
  as permissive
  for all
  to public
using (public.is_superadmin());



  create policy "admins_manage_institution"
  on "public"."ct_institutions"
  as permissive
  for update
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.institution_id = ct_institutions.id) AND (ct_users.role = ANY (ARRAY['admin'::text, 'it_director'::text]))))));



  create policy "allow_institution_insert"
  on "public"."ct_institutions"
  as permissive
  for insert
  to public
with check (true);



  create policy "ct_inst_public_read"
  on "public"."ct_institutions"
  as permissive
  for select
  to public
using (true);



  create policy "read_own_institution"
  on "public"."ct_institutions"
  as permissive
  for select
  to public
using (((id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))) OR true));



  create policy "superadmins_full_institutions"
  on "public"."ct_institutions"
  as permissive
  for all
  to public
using (public.is_superadmin());



  create policy "ct_io_all"
  on "public"."ct_interest_onboarding"
  as permissive
  for all
  to authenticated
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "users_own_interests"
  on "public"."ct_interest_onboarding"
  as permissive
  for all
  to public
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "match_participants_rls"
  on "public"."ct_match_participants"
  as permissive
  for all
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "ct_match_results_tenant"
  on "public"."ct_match_results"
  as permissive
  for all
  to authenticated
using ((org_id = ( SELECT ct_org_users.org_id
   FROM public.ct_org_users
  WHERE (ct_org_users.user_id = (auth.uid())::text)
 LIMIT 1)))
with check ((org_id = ( SELECT ct_org_users.org_id
   FROM public.ct_org_users
  WHERE (ct_org_users.user_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "ct_mr_anon"
  on "public"."ct_match_results"
  as permissive
  for insert
  to anon
with check (true);



  create policy "institution_select"
  on "public"."ct_note_requests"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "parent_manage_requests"
  on "public"."ct_note_requests"
  as permissive
  for all
  to public
using ((parent_id = auth.uid()));



  create policy "teacher_read_requests"
  on "public"."ct_note_requests"
  as permissive
  for select
  to public
using ((teacher_id = auth.uid()));



  create policy "teacher_update_requests"
  on "public"."ct_note_requests"
  as permissive
  for update
  to public
using ((teacher_id = auth.uid()));



  create policy "ct_np_own"
  on "public"."ct_notification_preferences"
  as permissive
  for all
  to authenticated
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "own prefs"
  on "public"."ct_notification_preferences"
  as permissive
  for all
  to public
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));



  create policy "Users own notif prefs"
  on "public"."ct_notification_prefs"
  as permissive
  for all
  to authenticated
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "Users read own notifications"
  on "public"."ct_notifications"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "Users update own notifications"
  on "public"."ct_notifications"
  as permissive
  for update
  to authenticated
using ((user_id = auth.uid()));



  create policy "auth_all_ct_notifications"
  on "public"."ct_notifications"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_ct_notifications_open"
  on "public"."ct_notifications"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_notif_all"
  on "public"."ct_notifications"
  as permissive
  for all
  to authenticated
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "ct_notifications_delete_own"
  on "public"."ct_notifications"
  as permissive
  for delete
  to authenticated
using ((user_id = auth.uid()));



  create policy "ct_notifications_insert_same_user_or_admin"
  on "public"."ct_notifications"
  as permissive
  for insert
  to authenticated
with check (((user_id = auth.uid()) OR (created_by = auth.uid())));



  create policy "ct_notifications_select_own"
  on "public"."ct_notifications"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "ct_notifications_update_own"
  on "public"."ct_notifications"
  as permissive
  for update
  to authenticated
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "institution_select"
  on "public"."ct_notifications"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "notifications_own_read"
  on "public"."ct_notifications"
  as permissive
  for select
  to public
using (((user_id = auth.uid()) OR public.is_superadmin()));



  create policy "notifications_own_update"
  on "public"."ct_notifications"
  as permissive
  for update
  to public
using ((user_id = auth.uid()));



  create policy "notifications_user_rls"
  on "public"."ct_notifications"
  as permissive
  for select
  to public
using (((user_id = auth.uid()) OR ((institution_id = public.get_my_institution_id()) AND public.is_superadmin())));



  create policy "users_own_notifications"
  on "public"."ct_notifications"
  as permissive
  for all
  to public
using ((user_id = auth.uid()));



  create policy "ct_onboarding_own"
  on "public"."ct_onboarding"
  as permissive
  for all
  to authenticated
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "ct_members_read"
  on "public"."ct_org_members"
  as permissive
  for select
  to authenticated
using (true);



  create policy "ct_members_write"
  on "public"."ct_org_members"
  as permissive
  for insert
  to authenticated
with check ((user_id = auth.uid()));



  create policy "ct_org_users_insert"
  on "public"."ct_org_users"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "ct_org_users_self"
  on "public"."ct_org_users"
  as permissive
  for select
  to authenticated
using ((user_id = (auth.uid())::text));



  create policy "ct_org_users_service"
  on "public"."ct_org_users"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "ct_organizations_insert"
  on "public"."ct_organizations"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "ct_organizations_tenant"
  on "public"."ct_organizations"
  as permissive
  for select
  to authenticated
using ((id = public.auth_user_org_id()));



  create policy "ct_organizations_update"
  on "public"."ct_organizations"
  as permissive
  for update
  to authenticated
using ((id = public.auth_user_org_id()));



  create policy "ct_orgs_read"
  on "public"."ct_organizations"
  as permissive
  for select
  to authenticated
using (true);



  create policy "ct_plinks_all"
  on "public"."ct_parent_links"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_parent_updates_open"
  on "public"."ct_parent_updates"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "institution_select"
  on "public"."ct_parent_updates"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "institution_select"
  on "public"."ct_payment_methods"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "payment_methods_institution_admin"
  on "public"."ct_payment_methods"
  as permissive
  for all
  to public
using (((user_id = auth.uid()) OR ((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))) AND (EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'it_director'::text]))))))));



  create policy "payment_methods_self_insert"
  on "public"."ct_payment_methods"
  as permissive
  for insert
  to public
with check (((user_id = auth.uid()) OR (institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid())))));



  create policy "payment_methods_self_read"
  on "public"."ct_payment_methods"
  as permissive
  for select
  to public
using (((user_id = auth.uid()) OR (institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid())))));



  create policy "payment_methods_self_update"
  on "public"."ct_payment_methods"
  as permissive
  for update
  to public
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "ct_pc_all"
  on "public"."ct_peer_connections"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "institution_select"
  on "public"."ct_performance_notes"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "parent_read_notes"
  on "public"."ct_performance_notes"
  as permissive
  for select
  to public
using (((send_to_parent = true) AND (is_sent = true)));



  create policy "student_read_notes"
  on "public"."ct_performance_notes"
  as permissive
  for select
  to public
using (((student_id = auth.uid()) AND (send_to_student = true) AND (is_sent = true)));



  create policy "teacher_manage_notes"
  on "public"."ct_performance_notes"
  as permissive
  for all
  to public
using ((teacher_id = auth.uid()));



  create policy "ct_platform_settings_open"
  on "public"."ct_platform_settings"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "auth insert participants"
  on "public"."ct_sport_challenge_participants"
  as permissive
  for insert
  to public
with check ((auth.uid() = user_id));



  create policy "auth read participants"
  on "public"."ct_sport_challenge_participants"
  as permissive
  for select
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "auth insert challenges"
  on "public"."ct_sport_challenges"
  as permissive
  for insert
  to public
with check ((auth.uid() = created_by));



  create policy "auth read challenges"
  on "public"."ct_sport_challenges"
  as permissive
  for select
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "institution_select"
  on "public"."ct_sport_challenges"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "ct_sp_all"
  on "public"."ct_sport_participants"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "institution_select"
  on "public"."ct_sport_participants"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "auth read rankings"
  on "public"."ct_sport_rankings"
  as permissive
  for select
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "institution_select"
  on "public"."ct_sport_rankings"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "ct_challenges_all"
  on "public"."ct_sports_challenges"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_sports_challenges_tenant"
  on "public"."ct_sports_challenges"
  as permissive
  for all
  to authenticated
using ((org_id = ( SELECT ct_org_users.org_id
   FROM public.ct_org_users
  WHERE (ct_org_users.user_id = (auth.uid())::text)
 LIMIT 1)))
with check ((org_id = ( SELECT ct_org_users.org_id
   FROM public.ct_org_users
  WHERE (ct_org_users.user_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "inst_sports_challenges"
  on "public"."ct_sports_challenges"
  as permissive
  for all
  to public
using ((institution_id = public.get_my_institution_id()));



  create policy "institution_select"
  on "public"."ct_sports_challenges"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "ct_ct_sports_games_open"
  on "public"."ct_sports_games"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "institution_select"
  on "public"."ct_sports_games"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "coaches_manage_leagues"
  on "public"."ct_sports_leagues"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.institution_id = ct_sports_leagues.institution_id) AND (ct_users.role = ANY (ARRAY['admin'::text, 'coach'::text, 'it_director'::text]))))));



  create policy "ct_ct_sports_leagues_open"
  on "public"."ct_sports_leagues"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "institution_select"
  on "public"."ct_sports_leagues"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "leagues_institution_read"
  on "public"."ct_sports_leagues"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "leagues_institution_rls"
  on "public"."ct_sports_leagues"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "read_institution_leagues"
  on "public"."ct_sports_leagues"
  as permissive
  for select
  to public
using ((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))));



  create policy "coaches_manage_teams"
  on "public"."ct_sports_teams"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.institution_id = ct_sports_teams.institution_id) AND (ct_users.role = ANY (ARRAY['admin'::text, 'coach'::text, 'it_director'::text]))))));



  create policy "ct_ct_sports_teams_open"
  on "public"."ct_sports_teams"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_st_all"
  on "public"."ct_sports_teams"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "institution_select"
  on "public"."ct_sports_teams"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "read_institution_teams"
  on "public"."ct_sports_teams"
  as permissive
  for select
  to public
using ((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))));



  create policy "teams_institution_read"
  on "public"."ct_sports_teams"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "teams_institution_rls"
  on "public"."ct_sports_teams"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "staff_reg_insert_public"
  on "public"."ct_staff_registrations"
  as permissive
  for insert
  to public
with check (true);



  create policy "staff_reg_select_own_org"
  on "public"."ct_staff_registrations"
  as permissive
  for select
  to public
using ((auth.uid() IN ( SELECT ct_students.user_id
   FROM public.ct_students
  WHERE (ct_students.org_id = ct_staff_registrations.org_id)
UNION
 SELECT auth.uid() AS uid)));



  create policy "staff_reg_update_own_org"
  on "public"."ct_staff_registrations"
  as permissive
  for update
  to public
using (true);



  create policy "stealth_sessions_superadmin"
  on "public"."ct_stealth_sessions"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_superadmins
  WHERE ((ct_superadmins.email = ( SELECT ct_users.email
           FROM public.ct_users
          WHERE (ct_users.id = auth.uid()))) AND (ct_superadmins.is_active = true)))));



  create policy "superadmin_stealth"
  on "public"."ct_stealth_sessions"
  as permissive
  for all
  to public
using (public.is_superadmin());



  create policy "Admins can view journey in their org"
  on "public"."ct_student_journey"
  as permissive
  for select
  to public
using ((org_id = ( SELECT ct_students.org_id
   FROM public.ct_students
  WHERE (ct_students.user_id = auth.uid())
 LIMIT 1)));



  create policy "Students can manage own journey"
  on "public"."ct_student_journey"
  as permissive
  for all
  to public
using ((student_id IN ( SELECT ct_students.id
   FROM public.ct_students
  WHERE (ct_students.user_id = auth.uid()))));



  create policy "student_notes_read"
  on "public"."ct_student_notes"
  as permissive
  for select
  to public
using (((teacher_id = auth.uid()) OR (student_id = auth.uid()) OR public.is_superadmin()));



  create policy "student_notes_write"
  on "public"."ct_student_notes"
  as permissive
  for insert
  to public
with check ((teacher_id = auth.uid()));



  create policy "ct_reg_org_delete"
  on "public"."ct_student_registrations"
  as permissive
  for delete
  to authenticated
using (true);



  create policy "ct_reg_org_read"
  on "public"."ct_student_registrations"
  as permissive
  for select
  to authenticated
using (true);



  create policy "ct_reg_org_update"
  on "public"."ct_student_registrations"
  as permissive
  for update
  to authenticated
using (true)
with check (true);



  create policy "ct_reg_public_insert"
  on "public"."ct_student_registrations"
  as permissive
  for insert
  to authenticated, anon
with check (true);



  create policy "ct_students_insert"
  on "public"."ct_students"
  as permissive
  for insert
  to authenticated
with check ((user_id = auth.uid()));



  create policy "ct_students_read"
  on "public"."ct_students"
  as permissive
  for select
  to authenticated
using (true);



  create policy "ct_students_tenant"
  on "public"."ct_students"
  as permissive
  for all
  to authenticated
using ((org_id = public.auth_user_org_id()))
with check ((org_id = public.auth_user_org_id()));



  create policy "ct_students_update"
  on "public"."ct_students"
  as permissive
  for update
  to authenticated
using ((user_id = auth.uid()));



  create policy "Students manage own submission files"
  on "public"."ct_submission_files"
  as permissive
  for all
  to authenticated
using (true);



  create policy "submissions_read"
  on "public"."ct_submissions"
  as permissive
  for select
  to public
using (((student_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM (public.ct_assignments a
     JOIN public.ct_classes cl ON ((cl.id = a.class_id)))
  WHERE ((a.id = ct_submissions.assignment_id) AND (cl.teacher_id = auth.uid())))) OR public.is_superadmin()));



  create policy "submissions_student_insert"
  on "public"."ct_submissions"
  as permissive
  for insert
  to public
with check ((student_id = auth.uid()));



  create policy "submissions_teacher_grade"
  on "public"."ct_submissions"
  as permissive
  for update
  to public
using (((EXISTS ( SELECT 1
   FROM (public.ct_assignments a
     JOIN public.ct_classes cl ON ((cl.id = a.class_id)))
  WHERE ((a.id = ct_submissions.assignment_id) AND (cl.teacher_id = auth.uid())))) OR public.is_superadmin()));



  create policy "superadmins_self_read"
  on "public"."ct_superadmins"
  as permissive
  for select
  to public
using ((email = ( SELECT ct_users.email
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))));



  create policy "ct_ct_survey_questions_open"
  on "public"."ct_survey_questions"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_sq_all"
  on "public"."ct_survey_questions"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_sq_anon_read"
  on "public"."ct_survey_questions"
  as permissive
  for select
  to anon
using (true);



  create policy "ct_ct_survey_responses_open"
  on "public"."ct_survey_responses"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_sr_delete"
  on "public"."ct_survey_responses"
  as permissive
  for delete
  to authenticated
using (true);



  create policy "ct_sr_insert"
  on "public"."ct_survey_responses"
  as permissive
  for insert
  to authenticated, anon
with check (true);



  create policy "ct_sr_read"
  on "public"."ct_survey_responses"
  as permissive
  for select
  to authenticated
using (true);



  create policy "staff_read_responses"
  on "public"."ct_survey_responses"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM (public.ct_users u
     JOIN public.ct_surveys s ON ((s.institution_id = u.institution_id)))
  WHERE ((u.id = auth.uid()) AND (s.id = ct_survey_responses.survey_id) AND (u.role = ANY (ARRAY['admin'::text, 'teacher'::text, 'it_director'::text]))))));



  create policy "ct_ct_surveys_open"
  on "public"."ct_surveys"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_surveys_all"
  on "public"."ct_surveys"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_surveys_anon_read"
  on "public"."ct_surveys"
  as permissive
  for select
  to anon
using ((status = 'Active'::text));



  create policy "ct_surveys_tenant"
  on "public"."ct_surveys"
  as permissive
  for all
  to authenticated
using ((org_id = ( SELECT ct_org_users.org_id
   FROM public.ct_org_users
  WHERE (ct_org_users.user_id = (auth.uid())::text)
 LIMIT 1)))
with check ((org_id = ( SELECT ct_org_users.org_id
   FROM public.ct_org_users
  WHERE (ct_org_users.user_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "institution_select"
  on "public"."ct_surveys"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "manage_surveys"
  on "public"."ct_surveys"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.institution_id = ct_surveys.institution_id) AND (ct_users.role = ANY (ARRAY['admin'::text, 'teacher'::text, 'it_director'::text, 'staff'::text]))))));



  create policy "read_institution_surveys"
  on "public"."ct_surveys"
  as permissive
  for select
  to public
using ((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))));



  create policy "surveys_institution_read"
  on "public"."ct_surveys"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "surveys_institution_rls"
  on "public"."ct_surveys"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "institution_select"
  on "public"."ct_teams"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "read_institution_teams"
  on "public"."ct_teams"
  as permissive
  for select
  to public
using ((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))));



  create policy "ticket_msg_access"
  on "public"."ct_ticket_messages"
  as permissive
  for all
  to public
using ((ticket_id IN ( SELECT ct_tickets.id
   FROM public.ct_tickets
  WHERE (ct_tickets.created_by = auth.uid())
UNION
 SELECT t.id
   FROM (public.ct_tickets t
     JOIN public.ct_users u ON ((u.id = auth.uid())))
  WHERE ((t.institution_id = u.institution_id) AND (u.role = ANY (ARRAY['admin'::text, 'it_director'::text, 'staff'::text]))))));



  create policy "ticket_msg_insert"
  on "public"."ct_ticket_messages"
  as permissive
  for insert
  to public
with check ((auth.uid() = sender_id));



  create policy "ticket_msg_select"
  on "public"."ct_ticket_messages"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_tickets t
  WHERE ((t.id = ct_ticket_messages.ticket_id) AND (public.is_superadmin() OR (t.institution_id = public.get_my_institution_id()))))));



  create policy "institution scoped tickets"
  on "public"."ct_tickets"
  as permissive
  for all
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "ticket_creator_access"
  on "public"."ct_tickets"
  as permissive
  for all
  to public
using ((created_by = auth.uid()));



  create policy "ticket_insert"
  on "public"."ct_tickets"
  as permissive
  for insert
  to public
with check (((institution_id = public.get_my_institution_id()) AND (auth.uid() = created_by)));



  create policy "ticket_institution_select"
  on "public"."ct_tickets"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "ticket_staff_institution"
  on "public"."ct_tickets"
  as permissive
  for all
  to public
using ((institution_id IN ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'it_director'::text, 'staff'::text]))))));



  create policy "ticket_update_assignee"
  on "public"."ct_tickets"
  as permissive
  for update
  to public
using ((public.is_superadmin() OR (assigned_to = auth.uid()) OR (institution_id = public.get_my_institution_id())));



  create policy "tickets_institution_read"
  on "public"."ct_tickets"
  as permissive
  for select
  to public
using (((created_by = auth.uid()) OR (assigned_to = auth.uid()) OR (institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "ct_tm_all"
  on "public"."ct_tournament_matches"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_tt_all"
  on "public"."ct_tournament_teams"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_ct_tournaments_open"
  on "public"."ct_tournaments"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_t_all"
  on "public"."ct_tournaments"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "coaches_manage_training"
  on "public"."ct_training_sessions"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND ((ct_users.role = ANY (ARRAY['admin'::text, 'coach'::text, 'it_director'::text])) OR (ct_users.roles && ARRAY['admin'::text, 'coach'::text, 'it_director'::text]))))));



  create policy "institution_select"
  on "public"."ct_training_sessions"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "read_institution_training"
  on "public"."ct_training_sessions"
  as permissive
  for select
  to public
using (((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))) OR (team_id IN ( SELECT ct_teams.id
   FROM public.ct_teams
  WHERE (ct_teams.institution_id = ( SELECT ct_users.institution_id
           FROM public.ct_users
          WHERE (ct_users.id = auth.uid())))))));



  create policy "own_trial_requests"
  on "public"."ct_trial_requests"
  as permissive
  for all
  to public
using ((user_id = auth.uid()));



  create policy "superadmin_trial_requests"
  on "public"."ct_trial_requests"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_superadmins
  WHERE (ct_superadmins.user_id = auth.uid()))));



  create policy "own_notifications"
  on "public"."ct_user_notifications"
  as permissive
  for all
  to public
using ((user_id = auth.uid()));



  create policy "staff_insert_notifications"
  on "public"."ct_user_notifications"
  as permissive
  for insert
  to public
with check (true);



  create policy "institution_select"
  on "public"."ct_user_seat_billing"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "seat_billing_admin_insert"
  on "public"."ct_user_seat_billing"
  as permissive
  for insert
  to public
with check (((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))) AND (EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'it_director'::text])))))));



  create policy "seat_billing_manage_admin"
  on "public"."ct_user_seat_billing"
  as permissive
  for all
  to public
using (((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))) AND (EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'it_director'::text])))))));



  create policy "seat_billing_read_institution"
  on "public"."ct_user_seat_billing"
  as permissive
  for select
  to public
using (((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))) AND ((user_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'it_director'::text]))))))));



  create policy "superadmins_full_seat_billing"
  on "public"."ct_user_seat_billing"
  as permissive
  for all
  to public
using (public.is_superadmin());



  create policy "ct_users_insert_own"
  on "public"."ct_users"
  as permissive
  for insert
  to public
with check ((id = auth.uid()));



  create policy "ct_users_read_own_institution"
  on "public"."ct_users"
  as permissive
  for select
  to public
using (((id = auth.uid()) OR (institution_id = public.get_my_institution_id())));



  create policy "ct_users_update_own"
  on "public"."ct_users"
  as permissive
  for update
  to public
using (((id = auth.uid()) OR ((institution_id = public.get_my_institution_id()) AND (EXISTS ( SELECT 1
   FROM public.ct_users u2
  WHERE ((u2.id = auth.uid()) AND (u2.role = ANY (ARRAY['it_director'::text, 'admin'::text])))))) OR public.is_superadmin()))
with check (((id = auth.uid()) OR ((institution_id = public.get_my_institution_id()) AND (EXISTS ( SELECT 1
   FROM public.ct_users u2
  WHERE ((u2.id = auth.uid()) AND (u2.role = ANY (ARRAY['it_director'::text, 'admin'::text])))))) OR public.is_superadmin()));



  create policy "superadmins_full_access_users"
  on "public"."ct_users"
  as permissive
  for all
  to public
using (public.is_superadmin());



  create policy "users_institution_isolation"
  on "public"."ct_users"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR (id = auth.uid()) OR public.is_superadmin()));



  create policy "users_select_institution"
  on "public"."ct_users"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (id = auth.uid()) OR (institution_id = public.get_my_institution_id())));



  create policy "ct_venue_booking_history_open"
  on "public"."ct_venue_booking_history"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_bookings_all"
  on "public"."ct_venue_bookings"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_ct_venue_bookings_open"
  on "public"."ct_venue_bookings"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_venue_bookings_tenant"
  on "public"."ct_venue_bookings"
  as permissive
  for all
  to authenticated
using ((org_id = ( SELECT ct_org_users.org_id
   FROM public.ct_org_users
  WHERE (ct_org_users.user_id = (auth.uid())::text)
 LIMIT 1)))
with check ((org_id = ( SELECT ct_org_users.org_id
   FROM public.ct_org_users
  WHERE (ct_org_users.user_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "manage_bookings"
  on "public"."ct_venue_bookings"
  as permissive
  for update
  to public
using (((booked_by = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'staff'::text, 'student_rep'::text, 'it_director'::text])))))));



  create policy "read_institution_bookings"
  on "public"."ct_venue_bookings"
  as permissive
  for select
  to public
using (((venue_id IN ( SELECT ct_venues.id
   FROM public.ct_venues
  WHERE (ct_venues.institution_id = ( SELECT ct_users.institution_id
           FROM public.ct_users
          WHERE (ct_users.id = auth.uid()))))) OR (booked_by = auth.uid())));



  create policy "users_can_book"
  on "public"."ct_venue_bookings"
  as permissive
  for insert
  to public
with check ((booked_by = auth.uid()));



  create policy "ct_ct_venues_open"
  on "public"."ct_venues"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_venues_read"
  on "public"."ct_venues"
  as permissive
  for select
  to authenticated
using (true);



  create policy "ct_venues_tenant"
  on "public"."ct_venues"
  as permissive
  for all
  to authenticated
using ((org_id = public.auth_user_org_id()))
with check ((org_id = public.auth_user_org_id()));



  create policy "ct_venues_write"
  on "public"."ct_venues"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "institution_select"
  on "public"."ct_venues"
  as permissive
  for select
  to public
using ((public.is_superadmin() OR (institution_id = public.get_my_institution_id())));



  create policy "manage_venues"
  on "public"."ct_venues"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.institution_id = ct_venues.institution_id) AND (ct_users.role = ANY (ARRAY['admin'::text, 'it_director'::text, 'staff'::text, 'student_rep'::text]))))));



  create policy "read_institution_venues"
  on "public"."ct_venues"
  as permissive
  for select
  to public
using ((institution_id = ( SELECT ct_users.institution_id
   FROM public.ct_users
  WHERE (ct_users.id = auth.uid()))));



  create policy "venues_institution_read"
  on "public"."ct_venues"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "venues_institution_rls"
  on "public"."ct_venues"
  as permissive
  for select
  to public
using (((institution_id = public.get_my_institution_id()) OR public.is_superadmin()));



  create policy "ct_checkins_all"
  on "public"."ct_wellbeing_checkins"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_ct_wellbeing_checkins_open"
  on "public"."ct_wellbeing_checkins"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "ct_wc_anon_insert"
  on "public"."ct_wellbeing_checkins"
  as permissive
  for insert
  to anon
with check (true);



  create policy "ct_wellbeing_checkins_tenant"
  on "public"."ct_wellbeing_checkins"
  as permissive
  for all
  to authenticated
using ((org_id = ( SELECT ct_org_users.org_id
   FROM public.ct_org_users
  WHERE (ct_org_users.user_id = (auth.uid())::text)
 LIMIT 1)))
with check ((org_id = ( SELECT ct_org_users.org_id
   FROM public.ct_org_users
  WHERE (ct_org_users.user_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "staff_read_wellbeing"
  on "public"."ct_wellbeing_checkins"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.ct_users
  WHERE ((ct_users.id = auth.uid()) AND (ct_users.role = ANY (ARRAY['admin'::text, 'teacher'::text, 'parent'::text, 'it_director'::text]))))));



  create policy "users_own_wellbeing"
  on "public"."ct_wellbeing_checkins"
  as permissive
  for all
  to public
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "service_role_bypass"
  on "public"."ct_wellbeing_checks"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "users_own_wellbeing_checks"
  on "public"."ct_wellbeing_checks"
  as permissive
  for all
  to public
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "users_own_wellness_checkins"
  on "public"."ct_wellness_checkins"
  as permissive
  for all
  to public
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "service role only"
  on "public"."demo_requests"
  as permissive
  for all
  to public
using (false);



  create policy "earnings_all_authenticated"
  on "public"."earnings"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "earnings_all_service"
  on "public"."earnings"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "earnings_manage_admin"
  on "public"."earnings"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "earnings_select_all"
  on "public"."earnings"
  as permissive
  for select
  to public
using (true);



  create policy "earnings_select_owner"
  on "public"."earnings"
  as permissive
  for select
  to authenticated
using (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "enterprise_invoices_auth"
  on "public"."enterprise_invoices"
  as permissive
  for all
  to authenticated
using ((((product = 'campus_tribe'::text) AND (EXISTS ( SELECT 1
   FROM public.ct_org_members m
  WHERE ((m.org_id = m.org_id) AND (m.user_id = auth.uid()))))) OR ((product = 'care_circle'::text) AND (EXISTS ( SELECT 1
   FROM public.cc_facility_members fm
  WHERE ((fm.facility_id = enterprise_invoices.org_id) AND (fm.user_id = auth.uid())))))))
with check (false);



  create policy "event_news_comments_delete_own"
  on "public"."event_news_comments"
  as permissive
  for delete
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "event_news_comments_insert_own"
  on "public"."event_news_comments"
  as permissive
  for insert
  to authenticated
with check ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "event_news_comments_select_public"
  on "public"."event_news_comments"
  as permissive
  for select
  to public
using (true);



  create policy "event_news_likes_delete_own"
  on "public"."event_news_likes"
  as permissive
  for delete
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "event_news_likes_insert_own"
  on "public"."event_news_likes"
  as permissive
  for insert
  to authenticated
with check ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "event_news_likes_select_public"
  on "public"."event_news_likes"
  as permissive
  for select
  to public
using (true);



  create policy "event_news_posts_delete_own"
  on "public"."event_news_posts"
  as permissive
  for delete
  to authenticated
using ((author_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "event_news_posts_insert_base_premium"
  on "public"."event_news_posts"
  as permissive
  for insert
  to authenticated
with check (((author_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) AND (EXISTS ( SELECT 1
   FROM public.profile_entitlements pe
  WHERE ((pe.profile_id = event_news_posts.author_profile_id) AND (pe.core_tier = ANY (ARRAY['base'::text, 'premium'::text])))))));



  create policy "event_news_posts_select_public"
  on "public"."event_news_posts"
  as permissive
  for select
  to public
using (true);



  create policy "event_news_posts_update_own"
  on "public"."event_news_posts"
  as permissive
  for update
  to authenticated
using ((author_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((author_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "Organizer can view registrations"
  on "public"."event_registrations"
  as permissive
  for select
  to public
using ((event_id IN ( SELECT events.id
   FROM public.events
  WHERE (events.organizer_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.auth_id = (auth.uid())::text))))));



  create policy "Users can cancel own event registration"
  on "public"."event_registrations"
  as permissive
  for update
  to public
using ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "Users can register for events"
  on "public"."event_registrations"
  as permissive
  for insert
  to public
with check ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "Users can view own event registrations"
  on "public"."event_registrations"
  as permissive
  for select
  to public
using (((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (event_id IN ( SELECT events.id
   FROM public.events
  WHERE (events.organizer_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.auth_id = (auth.uid())::text)))))));



  create policy "Organizer can manage own events"
  on "public"."events"
  as permissive
  for all
  to public
using ((organizer_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "Public can view active events"
  on "public"."events"
  as permissive
  for select
  to public
using ((is_active = true));



  create policy "events_v2_public_read"
  on "public"."events_v2"
  as permissive
  for select
  to public
using ((status = 'published'::public.event_status));



  create policy "favorites_all_authenticated"
  on "public"."favorites"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "favorites_all_service"
  on "public"."favorites"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "favorites_manage_owner"
  on "public"."favorites"
  as permissive
  for all
  to authenticated
using (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "favorites_select_all"
  on "public"."favorites"
  as permissive
  for select
  to public
using (true);



  create policy "group_members_delete"
  on "public"."group_conversation_members"
  as permissive
  for delete
  to authenticated
using (((profile_id = public.current_profile_id()) OR public.group_is_host(group_conversation_id)));



  create policy "group_members_insert"
  on "public"."group_conversation_members"
  as permissive
  for insert
  to authenticated
with check (((profile_id = public.current_profile_id()) OR public.group_is_host(group_conversation_id)));



  create policy "group_members_select"
  on "public"."group_conversation_members"
  as permissive
  for select
  to authenticated
using (((profile_id = public.current_profile_id()) OR public.group_is_member(group_conversation_id, public.current_profile_id()) OR public.group_is_host(group_conversation_id)));



  create policy "group_members_update"
  on "public"."group_conversation_members"
  as permissive
  for update
  to authenticated
using (((profile_id = public.current_profile_id()) OR public.group_is_host(group_conversation_id)))
with check (((profile_id = public.current_profile_id()) OR public.group_is_host(group_conversation_id)));



  create policy "group_conv_insert"
  on "public"."group_conversations"
  as permissive
  for insert
  to authenticated
with check (((created_by = public.current_profile_id()) OR public.activity_booking_exists_for_me(activity_id)));



  create policy "group_conv_select"
  on "public"."group_conversations"
  as permissive
  for select
  to authenticated
using (((created_by = public.current_profile_id()) OR public.group_is_member(id, public.current_profile_id()) OR public.activity_booking_exists_for_me(activity_id)));



  create policy "group_conv_update"
  on "public"."group_conversations"
  as permissive
  for update
  to authenticated
using ((created_by = public.current_profile_id()))
with check ((created_by = public.current_profile_id()));



  create policy "group_messages_insert"
  on "public"."group_messages"
  as permissive
  for insert
  to authenticated
with check (((sender_id = public.current_profile_id()) AND (public.group_is_host(group_conversation_id) OR public.group_is_member(group_conversation_id, public.current_profile_id()))));



  create policy "group_messages_select"
  on "public"."group_messages"
  as permissive
  for select
  to authenticated
using ((public.group_is_host(group_conversation_id) OR public.group_is_member(group_conversation_id, public.current_profile_id())));



  create policy "interests_select_public"
  on "public"."interests"
  as permissive
  for select
  to public
using (true);



  create policy "media_comments_manage_owner"
  on "public"."media_comments"
  as permissive
  for all
  to authenticated
using ((commented_by_user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((commented_by_user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "media_comments_select_public"
  on "public"."media_comments"
  as permissive
  for select
  to public
using (true);



  create policy "media_likes_manage_owner"
  on "public"."media_likes"
  as permissive
  for all
  to authenticated
using ((liked_by_user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((liked_by_user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "media_likes_select_public"
  on "public"."media_likes"
  as permissive
  for select
  to public
using (true);



  create policy "media_uploads_manage_owner"
  on "public"."media_uploads"
  as permissive
  for all
  to authenticated
using ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "media_uploads_select_owner"
  on "public"."media_uploads"
  as permissive
  for select
  to authenticated
using ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "Messages: INSERT sender"
  on "public"."messages"
  as permissive
  for insert
  to authenticated
with check (((sender_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) AND (EXISTS ( SELECT 1
   FROM public.conversations c
  WHERE ((c.id = messages.conversation_id) AND ((c.participant1_id = messages.sender_id) OR (c.participant2_id = messages.sender_id)))))));



  create policy "Messages: SELECT participants"
  on "public"."messages"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM (public.conversations c
     JOIN public.profiles p ON (((p.id = c.participant1_id) OR (p.id = c.participant2_id))))
  WHERE ((c.id = messages.conversation_id) AND (p.auth_id = (auth.uid())::text)))));



  create policy "messages_delete_sender"
  on "public"."messages"
  as permissive
  for delete
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = messages.sender_id) AND (p.auth_id = (auth.uid())::text)))));



  create policy "messages_insert_participant"
  on "public"."messages"
  as permissive
  for insert
  to authenticated
with check ((EXISTS ( SELECT 1
   FROM (public.conversations c
     JOIN public.profiles p ON ((p.auth_id = (auth.uid())::text)))
  WHERE ((c.id = messages.conversation_id) AND (p.id = messages.sender_id) AND ((p.id = c.participant1_id) OR (p.id = c.participant2_id)) AND public.can_message_between_profiles((c.participant1_id)::bigint, (c.participant2_id)::bigint)))));



  create policy "messages_insert_sender"
  on "public"."messages"
  as permissive
  for insert
  to authenticated
with check ((EXISTS ( SELECT 1
   FROM (public.conversations c
     JOIN public.profiles p ON (((p.id = c.participant1_id) OR (p.id = c.participant2_id))))
  WHERE ((c.id = messages.conversation_id) AND (p.auth_id = (auth.uid())::text) AND (p.id = messages.sender_id)))));



  create policy "messages_select_participant"
  on "public"."messages"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM (public.conversations c
     JOIN public.profiles p ON (((p.id = c.participant1_id) OR (p.id = c.participant2_id))))
  WHERE ((c.id = messages.conversation_id) AND (p.auth_id = (auth.uid())::text)))));



  create policy "messages_update_sender"
  on "public"."messages"
  as permissive
  for update
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = messages.sender_id) AND (p.auth_id = (auth.uid())::text)))))
with check ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = messages.sender_id) AND (p.auth_id = (auth.uid())::text)))));



  create policy "notifications_all_authenticated"
  on "public"."notifications"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "notifications_all_service"
  on "public"."notifications"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "notifications_manage_owner"
  on "public"."notifications"
  as permissive
  for all
  to authenticated
using (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "notifications_select_all"
  on "public"."notifications"
  as permissive
  for select
  to public
using (true);



  create policy "notifications_select_owner"
  on "public"."notifications"
  as permissive
  for select
  to authenticated
using (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "panicevents_insert_own"
  on "public"."panicEvents"
  as permissive
  for insert
  to authenticated
with check (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "panicevents_select_own"
  on "public"."panicEvents"
  as permissive
  for select
  to authenticated
using (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "Payments: self manage"
  on "public"."payment_methods"
  as permissive
  for all
  to public
using ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = current_setting('request.jwt.claim.sub'::text, true)))))
with check ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = current_setting('request.jwt.claim.sub'::text, true)))));



  create policy "payment_methods_manage_owner"
  on "public"."payment_methods"
  as permissive
  for all
  to authenticated
using ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "payment_methods_select_owner"
  on "public"."payment_methods"
  as permissive
  for select
  to authenticated
using ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "payments_all_authenticated"
  on "public"."payments"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "payments_all_service"
  on "public"."payments"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "payments_manage_admin"
  on "public"."payments"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "payments_select_all"
  on "public"."payments"
  as permissive
  for select
  to public
using (true);



  create policy "payments_select_booking_participant"
  on "public"."payments"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM (public.bookings b
     JOIN public.profiles p ON (((p.id = b.companion_id) OR (p.id = b.bouncer_id) OR (p.id = b.client_id))))
  WHERE ((b.id = payments."bookingId") AND (p.auth_id = (auth.uid())::text)))));



  create policy "photos_all_authenticated"
  on "public"."photos"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "photos_all_service"
  on "public"."photos"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "photos_manage_owner"
  on "public"."photos"
  as permissive
  for all
  to authenticated
using (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "photos_select_all"
  on "public"."photos"
  as permissive
  for select
  to public
using (true);



  create policy "photos_select_public"
  on "public"."photos"
  as permissive
  for select
  to public
using ((("isApproved" = true) AND ("isFlagged" = false)));



  create policy "profanity_terms_read"
  on "public"."profanity_terms"
  as permissive
  for select
  to authenticated
using (true);



  create policy "profanity_terms_select"
  on "public"."profanity_terms"
  as permissive
  for select
  to authenticated
using (false);



  create policy "profile_delete_backups_service_role_all"
  on "public"."profile_delete_backups"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "profile_likes_manage_owner"
  on "public"."profile_likes"
  as permissive
  for all
  to authenticated
using ((liked_by_user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((liked_by_user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "profile_likes_select_public"
  on "public"."profile_likes"
  as permissive
  for select
  to public
using (true);



  create policy "Media Owner Manage"
  on "public"."profile_media"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = profile_media.user_id) AND (profiles.auth_id = (auth.uid())::text)))));



  create policy "Media Public Read"
  on "public"."profile_media"
  as permissive
  for select
  to public
using (true);



  create policy "Users can manage their own media"
  on "public"."profile_media"
  as permissive
  for all
  to public
using ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = current_setting('request.jwt.claim.sub'::text, true)))))
with check ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = current_setting('request.jwt.claim.sub'::text, true)))));



  create policy "profile_media_delete_owner"
  on "public"."profile_media"
  as permissive
  for delete
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = profile_media.user_id) AND (p.auth_id = (auth.uid())::text)))));



  create policy "profile_media_insert_owner"
  on "public"."profile_media"
  as permissive
  for insert
  to authenticated
with check ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = profile_media.user_id) AND (p.auth_id = (auth.uid())::text)))));



  create policy "profile_media_select_public_or_owner"
  on "public"."profile_media"
  as permissive
  for select
  to public
using (((privacy_setting = 'public'::text) OR (EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = profile_media.user_id) AND (p.auth_id = (auth.uid())::text))))));



  create policy "profile_media_update_owner"
  on "public"."profile_media"
  as permissive
  for update
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = profile_media.user_id) AND (p.auth_id = (auth.uid())::text)))))
with check ((EXISTS ( SELECT 1
   FROM public.profiles p
  WHERE ((p.id = profile_media.user_id) AND (p.auth_id = (auth.uid())::text)))));



  create policy "profiles_authenticated_insert"
  on "public"."profiles"
  as permissive
  for insert
  to authenticated
with check ((((auth.uid())::text = COALESCE(auth_id, (auth.uid())::text)) OR (((auth.jwt() ->> 'email'::text) IS NOT NULL) AND ((auth.jwt() ->> 'email'::text) = email))));



  create policy "profiles_authenticated_select"
  on "public"."profiles"
  as permissive
  for select
  to authenticated
using ((((auth.uid())::text = auth_id) OR (is_public = true) OR ((account_type)::text = 'admin'::text)));



  create policy "profiles_authenticated_update"
  on "public"."profiles"
  as permissive
  for update
  to authenticated
using ((((auth.uid())::text = auth_id) OR (auth_id IS NULL) OR ((auth.jwt() ->> 'email'::text) = email)))
with check (((auth.uid())::text = COALESCE(auth_id, (auth.uid())::text)));



  create policy "profiles_select_public"
  on "public"."profiles"
  as permissive
  for select
  to anon
using ((is_public = true));



  create policy "profiles_service_role_all"
  on "public"."profiles"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "profiles_backup_read"
  on "public"."profiles_backup"
  as permissive
  for select
  to service_role
using (true);



  create policy "push_tokens_own"
  on "public"."push_tokens"
  as permissive
  for all
  to authenticated
using ((profile_id = (auth.uid())::text))
with check ((profile_id = (auth.uid())::text));



  create policy "reports_insert_own"
  on "public"."reports"
  as permissive
  for insert
  to authenticated
with check (("reporterId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "reports_select_own"
  on "public"."reports"
  as permissive
  for select
  to authenticated
using ((("reporterId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1)) OR ("targetUserId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1))));



  create policy "review_outbox_select"
  on "public"."review_notification_outbox"
  as permissive
  for select
  to authenticated
using (false);



  create policy "reviews_all_authenticated"
  on "public"."reviews"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "reviews_all_service"
  on "public"."reviews"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "reviews_manage_participant"
  on "public"."reviews"
  as permissive
  for all
  to authenticated
using ((("reviewerId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR ("revieweeId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)))))
with check (("reviewerId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "reviews_select_all"
  on "public"."reviews"
  as permissive
  for select
  to public
using (true);



  create policy "roles_authenticated_read"
  on "public"."roles"
  as permissive
  for select
  to authenticated
using (true);



  create policy "safetyflags_insert_own"
  on "public"."safetyFlags"
  as permissive
  for insert
  to authenticated
with check (("reporterId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "safetyflags_select_own"
  on "public"."safetyFlags"
  as permissive
  for select
  to authenticated
using ((("reporterId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1)) OR ("reportedUserId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1))));



  create policy "seo_ai_rank_snapshots_admin_read"
  on "public"."seo_ai_rank_snapshots"
  as permissive
  for select
  to authenticated
using (public.is_admin_user());



  create policy "seo_ai_rank_snapshots_public_select"
  on "public"."seo_ai_rank_snapshots"
  as permissive
  for select
  to anon
using (true);



  create policy "seo_ai_rank_snapshots_service_role_all"
  on "public"."seo_ai_rank_snapshots"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "seo_ai_tracking_queries_admin_read"
  on "public"."seo_ai_tracking_queries"
  as permissive
  for select
  to authenticated
using (public.is_admin_user());



  create policy "seo_ai_tracking_queries_public_select"
  on "public"."seo_ai_tracking_queries"
  as permissive
  for select
  to anon
using ((is_active = true));



  create policy "seo_ai_tracking_queries_service_role_all"
  on "public"."seo_ai_tracking_queries"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "sa_owner_all"
  on "public"."service_availability"
  as permissive
  for all
  to public
using ((provider_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "sa_public_read"
  on "public"."service_availability"
  as permissive
  for select
  to public
using ((available = true));



  create policy "Client can cancel own service booking"
  on "public"."service_bookings"
  as permissive
  for update
  to public
using (((client_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) AND (status = 'cancelled'::text)))
with check (((client_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) AND (status = 'cancelled'::text)));



  create policy "Provider can delete own service bookings"
  on "public"."service_bookings"
  as permissive
  for delete
  to public
using ((provider_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "Provider can update own service bookings"
  on "public"."service_bookings"
  as permissive
  for update
  to public
using ((provider_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((provider_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "Users can create service bookings"
  on "public"."service_bookings"
  as permissive
  for insert
  to public
with check ((client_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "Users can view own service bookings"
  on "public"."service_bookings"
  as permissive
  for select
  to public
using (((client_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (provider_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)))));



  create policy "Public can read service reviews"
  on "public"."service_reviews"
  as permissive
  for select
  to public
using (true);



  create policy "Users can create reviews for completed bookings"
  on "public"."service_reviews"
  as permissive
  for insert
  to public
with check (((reviewer_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) AND ((booking_id IS NULL) OR (booking_id IN ( SELECT service_bookings.id
   FROM public.service_bookings
  WHERE ((service_bookings.status = 'completed'::text) AND (service_bookings.client_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.auth_id = (auth.uid())::text)))))))));



  create policy "sr_owner_insert"
  on "public"."service_reviews"
  as permissive
  for insert
  to public
with check ((reviewer_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "sr_public_read"
  on "public"."service_reviews"
  as permissive
  for select
  to public
using (true);



  create policy "services_manage_own"
  on "public"."services"
  as permissive
  for all
  to authenticated
using (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1)))
with check (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "services_owner_all"
  on "public"."services"
  as permissive
  for all
  to public
using (((provider_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR ("userId" IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)))));



  create policy "services_public_read"
  on "public"."services"
  as permissive
  for select
  to public
using (((is_active = true) OR (is_active IS NULL) OR ("isActive" = true)));



  create policy "services_read_active"
  on "public"."services"
  as permissive
  for select
  to authenticated
using ((("isActive" = true) OR ("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1))));



  create policy "subscriptions_manage_own"
  on "public"."subscriptions"
  as permissive
  for all
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "subscriptions_select_own"
  on "public"."subscriptions"
  as permissive
  for select
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "Users can view own transactions"
  on "public"."transactions"
  as permissive
  for select
  to public
using ((user_id = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "transactions_v2_owner"
  on "public"."transactions_v2"
  as permissive
  for all
  to public
using (true);



  create policy "Interests: self manage"
  on "public"."user_interests"
  as permissive
  for all
  to public
using ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = current_setting('request.jwt.claim.sub'::text, true)))))
with check ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = current_setting('request.jwt.claim.sub'::text, true)))));



  create policy "user_interests_manage_owner"
  on "public"."user_interests"
  as permissive
  for all
  to authenticated
using ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "user_interests_select_owner"
  on "public"."user_interests"
  as permissive
  for select
  to authenticated
using ((user_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "users_all_authenticated"
  on "public"."users"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "users_all_service"
  on "public"."users"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "users_manage_owner"
  on "public"."users"
  as permissive
  for all
  to authenticated
using ((("openId")::text = (auth.uid())::text))
with check ((("openId")::text = (auth.uid())::text));



  create policy "users_select_all"
  on "public"."users"
  as permissive
  for select
  to public
using (true);



  create policy "verificationaudits_insert"
  on "public"."verificationAudits"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "verificationaudits_select"
  on "public"."verificationAudits"
  as permissive
  for select
  to authenticated
using (("reviewerId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "verificationRequests_all_authenticated"
  on "public"."verificationRequests"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "verificationRequests_all_service"
  on "public"."verificationRequests"
  as permissive
  for all
  to service_role
using (true)
with check (true);



  create policy "verificationRequests_select_all"
  on "public"."verificationRequests"
  as permissive
  for select
  to public
using (true);



  create policy "verification_requests_manage_owner"
  on "public"."verificationRequests"
  as permissive
  for all
  to authenticated
using (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "verification_requests_select_owner"
  on "public"."verificationRequests"
  as permissive
  for select
  to authenticated
using (("userId" = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "vip_accounts_admin_only"
  on "public"."vip_accounts"
  as permissive
  for all
  to public
using (false);



  create policy "voice_studio_clones_own"
  on "public"."voice_studio_clones"
  as permissive
  for all
  to public
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "voice_studio_jobs_own"
  on "public"."voice_studio_jobs"
  as permissive
  for all
  to public
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "voice_studio_usage_own"
  on "public"."voice_studio_usage"
  as permissive
  for all
  to public
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "waitlist_no_public_read"
  on "public"."waitlist"
  as permissive
  for select
  to public
using (false);



  create policy "waitlist_public_insert"
  on "public"."waitlist"
  as permissive
  for insert
  to public
with check (true);



  create policy "Users can update own wallet"
  on "public"."wallets"
  as permissive
  for update
  to public
using ((user_id = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "Users can view own wallet"
  on "public"."wallets"
  as permissive
  for select
  to public
using ((user_id = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "wallets_v2_owner"
  on "public"."wallets_v2"
  as permissive
  for all
  to public
using (true);



  create policy "wc_ai_cases_owner"
  on "public"."wc_ai_cases"
  as permissive
  for all
  to authenticated
using ((owner_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((owner_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "wc_ai_employees_all"
  on "public"."wc_ai_employees"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "wc_ai_staff_own"
  on "public"."wc_ai_staff"
  as permissive
  for all
  to public
using ((owner_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "wc_analytics_all"
  on "public"."wc_analytics"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "wc_calls_insert"
  on "public"."wc_calls"
  as permissive
  for insert
  to authenticated
with check ((caller_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "wc_calls_select"
  on "public"."wc_calls"
  as permissive
  for select
  to authenticated
using (((caller_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (callee_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)))));



  create policy "wc_calls_update"
  on "public"."wc_calls"
  as permissive
  for update
  to authenticated
using (((caller_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (callee_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)))));



  create policy "wc_contacts_owner"
  on "public"."wc_contacts"
  as permissive
  for all
  to public
using ((owner_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((owner_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "org members see departments"
  on "public"."wc_departments"
  as permissive
  for all
  to public
using ((business_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "wc_entitlements_all"
  on "public"."wc_entitlements"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "wc_messages_own"
  on "public"."wc_messages"
  as permissive
  for all
  to public
using (((from_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (to_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)))));



  create policy "wc_number_requests_owner"
  on "public"."wc_number_requests"
  as permissive
  for all
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "wc_org_settings_owner"
  on "public"."wc_org_settings"
  as permissive
  for all
  to authenticated
using ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))))
with check ((profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "org access"
  on "public"."wc_org_users"
  as permissive
  for all
  to public
using ((business_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "wc_participants_all"
  on "public"."wc_participants"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "org sees own numbers"
  on "public"."wc_phone_numbers"
  as permissive
  for all
  to public
using ((business_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "wc_queue_all"
  on "public"."wc_queue"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "wc_recordings_all"
  on "public"."wc_recordings"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "org members see roles"
  on "public"."wc_roles"
  as permissive
  for all
  to public
using ((business_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "wc_rooms_all"
  on "public"."wc_rooms"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "wc_rooms_authenticated"
  on "public"."wc_rooms"
  as permissive
  for all
  to authenticated, anon
using (true)
with check (true);



  create policy "wc_routing_edges_own"
  on "public"."wc_routing_edges"
  as permissive
  for all
  to public
using ((rule_id IN ( SELECT wc_routing_rules.id
   FROM public.wc_routing_rules
  WHERE (wc_routing_rules.business_profile_id IN ( SELECT profiles.id
           FROM public.profiles
          WHERE (profiles.auth_id = (auth.uid())::text))))));



  create policy "org sees own rules"
  on "public"."wc_routing_rules"
  as permissive
  for all
  to public
using ((business_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "wc_routing_steps_own"
  on "public"."wc_routing_steps"
  as permissive
  for all
  to public
using ((business_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "wc_signaling_all"
  on "public"."wc_signaling"
  as permissive
  for all
  to authenticated
using (((from_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (to_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)))))
with check ((from_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "wc_signaling_insert"
  on "public"."wc_signaling"
  as permissive
  for insert
  to public
with check ((from_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))));



  create policy "wc_signaling_select"
  on "public"."wc_signaling"
  as permissive
  for select
  to public
using (((from_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text))) OR (to_profile_id IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)))));



  create policy "wc_transcripts_all"
  on "public"."wc_transcripts"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "owner access"
  on "public"."wc_whatsapp_configs"
  as permissive
  for all
  to public
using ((profile_id = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "owner access"
  on "public"."wc_whatsapp_messages"
  as permissive
  for all
  to public
using ((profile_id = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = (auth.uid())::text)
 LIMIT 1)));



  create policy "webrtc_auth"
  on "public"."webrtc_signals"
  as permissive
  for all
  to authenticated
using (true)
with check (true);


CREATE TRIGGER trg_activity_booking_payout_lock BEFORE INSERT ON public.activity_bookings FOR EACH ROW EXECUTE FUNCTION public.set_activity_booking_host_and_payout_lock();

CREATE TRIGGER trg_enforce_activity_capacity BEFORE INSERT OR UPDATE ON public.activity_bookings FOR EACH ROW EXECUTE FUNCTION public.enforce_activity_capacity();

CREATE TRIGGER update_activity_bookings_updated_at BEFORE UPDATE ON public.activity_bookings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trg_enforce_no_profanity_activity_reviews BEFORE INSERT OR UPDATE ON public.activity_reviews FOR EACH ROW EXECUTE FUNCTION public.enforce_no_profanity_on_activity_reviews();

CREATE TRIGGER update_activity_reviews_updated_at BEFORE UPDATE ON public.activity_reviews FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trigger_increment_activity_share_count AFTER INSERT ON public.activity_shares FOR EACH ROW EXECUTE FUNCTION public.increment_activity_share_count();

CREATE TRIGGER trigger_increment_activity_view_count AFTER INSERT ON public.activity_views FOR EACH ROW EXECUTE FUNCTION public.increment_activity_view_count();

CREATE TRIGGER trg_audit_booking_review_media AFTER INSERT OR DELETE OR UPDATE ON public.booking_review_media FOR EACH ROW EXECUTE FUNCTION public.audit_booking_review_changes();

CREATE TRIGGER trg_booking_review_media_updated_at BEFORE UPDATE ON public.booking_review_media FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();

CREATE TRIGGER trg_audit_booking_review_responses AFTER INSERT OR DELETE OR UPDATE ON public.booking_review_responses FOR EACH ROW EXECUTE FUNCTION public.audit_booking_review_changes();

CREATE TRIGGER trg_booking_review_responses_updated_at BEFORE UPDATE ON public.booking_review_responses FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();

CREATE TRIGGER trg_lock_review_response_edit BEFORE UPDATE ON public.booking_review_responses FOR EACH ROW EXECUTE FUNCTION public.lock_response_edits_after_2d();

CREATE TRIGGER trg_audit_booking_reviews AFTER INSERT OR DELETE OR UPDATE ON public.booking_reviews FOR EACH ROW EXECUTE FUNCTION public.audit_booking_review_changes();

CREATE TRIGGER trg_booking_reviews_updated_at BEFORE UPDATE ON public.booking_reviews FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();

CREATE TRIGGER trg_enforce_booking_review_transitions BEFORE UPDATE ON public.booking_reviews FOR EACH ROW EXECUTE FUNCTION public.enforce_booking_review_transitions();

CREATE TRIGGER trg_review_submit_moderate_and_reveal BEFORE UPDATE OF status ON public.booking_reviews FOR EACH ROW EXECUTE FUNCTION public.on_review_submit_moderate_and_reveal();

CREATE TRIGGER trg_sync_approved_booking_to_availability AFTER UPDATE OF status ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.sync_approved_booking_to_availability();

CREATE TRIGGER trg_sync_booking_hours_duration BEFORE INSERT OR UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.sync_booking_hours_duration();

CREATE TRIGGER trigger_check_double_booking BEFORE INSERT OR UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.check_double_booking();

CREATE TRIGGER trigger_log_booking_status_change BEFORE UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.log_booking_status_change();

CREATE TRIGGER bouncer_services_updated_at BEFORE UPDATE ON public.bouncer_services FOR EACH ROW EXECUTE FUNCTION public.update_services_updated_at();

CREATE TRIGGER trg_campaigns_updated_at BEFORE UPDATE ON public.campaigns FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();

CREATE TRIGGER update_companion_activities_updated_at BEFORE UPDATE ON public.companion_activities FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER companion_services_updated_at BEFORE UPDATE ON public.companion_services FOR EACH ROW EXECUTE FUNCTION public.update_services_updated_at();

CREATE TRIGGER companions_updated_at BEFORE UPDATE ON public.companions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER ct_sync_announcement_compat_trigger BEFORE INSERT OR UPDATE ON public.ct_announcements FOR EACH ROW EXECUTE FUNCTION public.ct_sync_announcement_compat();

CREATE TRIGGER ct_sync_event_rsvp_compat_trigger BEFORE INSERT OR UPDATE ON public.ct_event_rsvps FOR EACH ROW EXECUTE FUNCTION public.ct_sync_event_rsvp_compat();

CREATE TRIGGER ct_sync_survey_question_compat_trigger BEFORE INSERT OR UPDATE ON public.ct_survey_questions FOR EACH ROW EXECUTE FUNCTION public.ct_sync_survey_question_compat();

CREATE TRIGGER ct_sync_survey_response_compat_trigger BEFORE INSERT OR UPDATE ON public.ct_survey_responses FOR EACH ROW EXECUTE FUNCTION public.ct_sync_survey_response_compat();

CREATE TRIGGER ct_sync_survey_compat_trigger BEFORE INSERT OR UPDATE ON public.ct_surveys FOR EACH ROW EXECUTE FUNCTION public.ct_sync_survey_compat();

CREATE TRIGGER on_ticket_message AFTER INSERT ON public.ct_ticket_messages FOR EACH ROW EXECUTE FUNCTION public.notify_ticket_update();

CREATE TRIGGER prevent_payment_bypass BEFORE UPDATE ON public.ct_users FOR EACH ROW EXECUTE FUNCTION public.prevent_payment_status_bypass();

CREATE TRIGGER prevent_role_escalation BEFORE UPDATE ON public.ct_users FOR EACH ROW EXECUTE FUNCTION public.prevent_self_role_escalation();

CREATE TRIGGER ct_prevent_overlapping_approved_venue_bookings_trigger BEFORE INSERT OR UPDATE OF venue_id, start_time, end_time, status ON public.ct_venue_bookings FOR EACH ROW EXECUTE FUNCTION public.ct_prevent_overlapping_approved_venue_bookings();

CREATE TRIGGER ct_venue_booking_history_trigger AFTER INSERT OR UPDATE OF status, notes, approved_by ON public.ct_venue_bookings FOR EACH ROW EXECUTE FUNCTION public.ct_log_venue_booking_history();

CREATE TRIGGER on_demo_request_insert AFTER INSERT ON public.demo_requests FOR EACH ROW EXECUTE FUNCTION public.notify_demo_request();

CREATE TRIGGER trg_enforce_no_profanity_event_news BEFORE INSERT OR UPDATE ON public.event_news_posts FOR EACH ROW EXECUTE FUNCTION public.enforce_no_profanity_on_event_news();

CREATE TRIGGER trg_event_news_posts_updated_at BEFORE UPDATE ON public.event_news_posts FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();

CREATE TRIGGER check_capacity_before_registration BEFORE INSERT ON public.event_registrations FOR EACH ROW EXECUTE FUNCTION public.check_event_capacity();

CREATE TRIGGER event_registrations_updated_at BEFORE UPDATE ON public.event_registrations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER events_updated_at BEFORE UPDATE ON public.events FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER tg_message_profanity BEFORE INSERT ON public.messages FOR EACH ROW EXECUTE FUNCTION public.on_message_check_profanity();

CREATE TRIGGER trg_enforce_no_profanity_messages BEFORE INSERT OR UPDATE ON public.messages FOR EACH ROW EXECUTE FUNCTION public.enforce_no_profanity_on_messages();

CREATE TRIGGER trg_sync_messages_legacy_columns BEFORE INSERT OR UPDATE ON public.messages FOR EACH ROW EXECUTE FUNCTION public.sync_messages_legacy_columns();

CREATE TRIGGER trg_sync_messages_legacy_fields BEFORE INSERT OR UPDATE ON public.messages FOR EACH ROW EXECUTE FUNCTION public.sync_messages_legacy_fields();

CREATE TRIGGER aaa_handle_new_user_subscription AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_subscription();

CREATE TRIGGER on_profile_created BEFORE INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.handle_new_profile();

CREATE TRIGGER on_profile_created_create_wallet AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.create_wallet_for_new_user();

CREATE TRIGGER profiles_updated_at_trigger BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_profiles_updated_at();

CREATE TRIGGER tg_profile_profanity BEFORE INSERT OR UPDATE OF bio, headline, full_name ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.on_profile_update_check_profanity();

CREATE TRIGGER trg_enforce_no_profanity_profiles BEFORE INSERT OR UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.enforce_no_profanity_on_profiles();

CREATE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trigger_backup_profile_before_delete BEFORE DELETE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.backup_profile_before_delete();

CREATE TRIGGER trigger_log_account_status_change BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.log_account_status_change();

CREATE TRIGGER zzz_handle_vip_user AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.handle_vip_user();

CREATE TRIGGER service_bookings_updated_at BEFORE UPDATE ON public.service_bookings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER service_reviews_updated_at BEFORE UPDATE ON public.service_reviews FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER services_updated_at BEFORE UPDATE ON public.services FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trg_subscription_change_refresh_payouts AFTER INSERT OR UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION public.on_subscription_change_refresh_payouts();

CREATE TRIGGER trg_subscriptions_updated_at BEFORE UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();

CREATE TRIGGER wallets_updated_at BEFORE UPDATE ON public.wallets FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


