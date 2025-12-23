-- ============================================
-- Complete Diagnostic Script
-- Run each section separately to diagnose the issue
-- ============================================

-- ============================================
-- SECTION 1: Check Table and RLS Status
-- ============================================
SELECT 
  'Table and RLS Status' as check_type,
  tablename,
  rowsecurity as rls_enabled,
  CASE 
    WHEN rowsecurity THEN '✅ RLS Enabled'
    ELSE '❌ RLS Disabled'
  END as status
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'ChatMessage';

-- ============================================
-- SECTION 2: Check All Policies
-- ============================================
SELECT 
  'Current Policies' as check_type,
  policyname,
  cmd as operation,
  roles,
  qual as using_expression,
  with_check as with_check_expression,
  CASE 
    WHEN cmd = 'INSERT' AND 'authenticated' = ANY(roles) THEN '✅ INSERT policy exists'
    WHEN cmd = 'SELECT' AND 'authenticated' = ANY(roles) THEN '✅ SELECT policy exists'
    ELSE '⚠️ Check this policy'
  END as status
FROM pg_policies 
WHERE tablename = 'ChatMessage'
ORDER BY cmd;

-- ============================================
-- SECTION 3: Check Table Structure
-- ============================================
SELECT 
  'Table Structure' as check_type,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'ChatMessage'
ORDER BY ordinal_position;

-- ============================================
-- SECTION 4: Test INSERT with Service Role (Admin)
-- This will help determine if it's an RLS issue or something else
-- ============================================
-- NOTE: This requires service role key - only for testing!
-- You can't run this in SQL Editor with anon key
-- But it helps understand if the issue is RLS or table structure

-- ============================================
-- SECTION 5: Check if policies are actually working
-- ============================================
-- Try to see what the current user context is
SELECT 
  'Current Auth Context' as check_type,
  current_user as database_user,
  session_user as session_user;

-- ============================================
-- SECTION 6: Alternative Policy Setup (More Permissive)
-- Run this if the above shows policies exist but still not working
-- ============================================

-- Drop all existing policies
DROP POLICY IF EXISTS "Allow authenticated users to insert messages" ON "ChatMessage";
DROP POLICY IF EXISTS "Allow authenticated users to read messages" ON "ChatMessage";
DROP POLICY IF EXISTS "Users can read messages" ON "ChatMessage";
DROP POLICY IF EXISTS "Users can insert messages" ON "ChatMessage";
DROP POLICY IF EXISTS "Enable insert for authenticated" ON "ChatMessage";
DROP POLICY IF EXISTS "Enable select for authenticated" ON "ChatMessage";

-- Create policies with explicit role specification
CREATE POLICY "Enable insert for authenticated"
  ON "ChatMessage"
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Enable select for authenticated"
  ON "ChatMessage"
  FOR SELECT
  TO authenticated
  USING (true);

-- Verify new policies
SELECT 
  'New Policies Created' as check_type,
  policyname,
  cmd,
  roles
FROM pg_policies 
WHERE tablename = 'ChatMessage';

