-- 023_add_recurring_flag.sql

-- Add is_recurring flag to donations table
ALTER TABLE public.donations
ADD COLUMN IF NOT EXISTS is_recurring BOOLEAN DEFAULT false;

-- Reload schema cache so PostgREST recognizes the new 'is_recurring' column
NOTIFY pgrst, 'reload schema';
