


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";





SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."Bangladesh_student_performance" (
    "Student_ID" bigint NOT NULL,
    "Gender" "text",
    "Age" bigint,
    "District" "text",
    "School_Type" "text",
    "Study_Hours_per_Week" bigint,
    "Attendance" bigint,
    "Parent_Education" "text",
    "Family_Income_BDT" bigint,
    "Internet_Access" "text",
    "Private_Tuition" "text",
    "Previous_GPA" double precision,
    "SSC_Result" double precision,
    "HSC_Result" double precision
);


ALTER TABLE "public"."Bangladesh_student_performance" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."shopping_trends" (
    "Customer ID" bigint NOT NULL,
    "Age" bigint,
    "Gender" "text",
    "Item Purchased" "text",
    "Category" "text",
    "Purchase Amount (USD)" bigint,
    "Location" "text",
    "Size" "text",
    "Color" "text",
    "Season" "text",
    "Review Rating" double precision,
    "Subscription Status" "text",
    "Payment Method" "text",
    "Shipping Type" "text",
    "Discount Applied" "text",
    "Promo Code Used" "text",
    "Previous Purchases" bigint,
    "Preferred Payment Method" "text",
    "Frequency of Purchases" "text"
);


ALTER TABLE "public"."shopping_trends" OWNER TO "postgres";


ALTER TABLE ONLY "public"."Bangladesh_student_performance"
    ADD CONSTRAINT "Bangladesh_student_performance_pkey" PRIMARY KEY ("Student_ID");



ALTER TABLE ONLY "public"."shopping_trends"
    ADD CONSTRAINT "shopping_trends_pkey" PRIMARY KEY ("Customer ID");



ALTER TABLE "public"."Bangladesh_student_performance" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."shopping_trends" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."shopping_trends";



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";





































































































































































GRANT ALL ON TABLE "public"."Bangladesh_student_performance" TO "anon";
GRANT ALL ON TABLE "public"."Bangladesh_student_performance" TO "authenticated";
GRANT ALL ON TABLE "public"."Bangladesh_student_performance" TO "service_role";



GRANT ALL ON TABLE "public"."shopping_trends" TO "anon";
GRANT ALL ON TABLE "public"."shopping_trends" TO "authenticated";
GRANT ALL ON TABLE "public"."shopping_trends" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































drop extension if exists "pg_net";


