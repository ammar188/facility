-- ============================================
-- Fix Conversation Table RLS and Permissions Script
-- ============================================
-- Copy and paste this entire script into your Supabase SQL Editor
-- Then click "Run" to execute it
-- ============================================
-- This script sets up RLS for the Conversation table with schema:
-- id, user_id, vendor_id, created_at, updated_at
-- ============================================

-- Step 1: Ensure RLS is enabled for the Conversation table
ALTER TABLE public."Conversation" ENABLE ROW LEVEL SECURITY;

-- Step 2: Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can view their own conversations" ON public."Conversation";
DROP POLICY IF EXISTS "Users can create conversations" ON public."Conversation";
DROP POLICY IF EXISTS "Users can update their own conversations" ON public."Conversation";
DROP POLICY IF EXISTS "Vendors can view conversations" ON public."Conversation";

-- Step 3: Policy to allow authenticated users to view their own conversations
-- Users can see conversations where they are the user_id
CREATE POLICY "Users can view their own conversations"
  ON public."Conversation"
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() = user_id
  );

-- Step 4: Policy to allow authenticated users to create conversations
-- Users can create conversations where they are the user_id
CREATE POLICY "Users can create conversations"
  ON public."Conversation"
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user_id
  );

-- Step 5: Policy to allow users to update their own conversations
-- Users can update conversations where they are the user_id
CREATE POLICY "Users can update their own conversations"
  ON public."Conversation"
  FOR UPDATE
  TO authenticated
  USING (
    auth.uid() = user_id
  )
  WITH CHECK (
    auth.uid() = user_id
  );

-- Step 6: Grant necessary schema permissions to authenticated role
GRANT USAGE ON SCHEMA public TO authenticated;

-- Step 7: Grant necessary table permissions to authenticated role
GRANT SELECT, INSERT, UPDATE ON TABLE public."Conversation" TO authenticated;

-- Step 8: Grant sequence permissions for auto-incrementing IDs (if using SERIAL)
-- Check if sequence exists first
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'Conversation_id_seq') THEN
    GRANT USAGE, SELECT ON SEQUENCE public."Conversation_id_seq" TO authenticated;
  END IF;
END $$;

-- Step 9: Enable Realtime for the table (if needed)
-- Note: This might already be enabled, but it's safe to run again
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
    AND schemaname = 'public' 
    AND tablename = 'Conversation'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE "Conversation";
  END IF;
END $$;

-- Step 10: Verify RLS status and policies
SELECT
  'RLS Status:' as status,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'Conversation';

-- Step 11: Verify policies were created
SELECT
  'Policies for Conversation table:' as status,
  policyname,
  cmd as operation,
  roles,
  qual as using_expression,
  with_check as check_expression
FROM pg_policies
WHERE tablename = 'Conversation';

-- Step 12: Verify permissions
SELECT
  'Table permissions:' as status,
  grantee,
  privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
AND table_name = 'Conversation'
AND grantee = 'authenticated';

