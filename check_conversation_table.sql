-- ============================================
-- Check Conversation Table Structure
-- ============================================
-- Run this script to verify your Conversation table structure
-- ============================================

-- Step 1: Check if table exists
SELECT 
  'Table exists:' as status,
  tablename,
  schemaname
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'Conversation';

-- Step 2: Check table columns and their types
SELECT 
  'Table columns:' as status,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'Conversation'
ORDER BY ordinal_position;

-- Step 3: Check if ID column is auto-incrementing (SERIAL)
SELECT 
  'ID column info:' as status,
  column_name,
  data_type,
  column_default,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'Conversation'
AND column_name = 'id';

-- Step 4: Check for sequence (auto-increment)
SELECT 
  'Sequence info:' as status,
  sequence_name,
  data_type,
  start_value,
  increment
FROM information_schema.sequences
WHERE sequence_schema = 'public'
AND sequence_name LIKE '%Conversation%';

-- Step 5: Check RLS status
SELECT 
  'RLS Status:' as status,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'Conversation';

-- Step 6: Check existing data
SELECT 
  'Existing conversations:' as status,
  id,
  user_id,
  vendor_id,
  created_at
FROM public."Conversation"
ORDER BY id DESC
LIMIT 5;

-- Step 7: Test insert (this will fail if RLS blocks it, but won't insert if successful)
-- Uncomment the line below to test insert
-- INSERT INTO public."Conversation" (user_id, vendor_id) VALUES (auth.uid(), auth.uid()) RETURNING id;

