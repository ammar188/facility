-- ============================================
-- Verify RLS Setup for Conversation Table
-- ============================================
-- Run this to check if RLS is properly configured
-- ============================================

-- Step 1: Check if RLS is enabled
SELECT 
  'RLS Status:' as check_type,
  tablename,
  rowsecurity as rls_enabled,
  CASE 
    WHEN rowsecurity THEN '✓ RLS is ENABLED'
    ELSE '✗ RLS is DISABLED - This is a security risk!'
  END as status
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'Conversation';

-- Step 2: List all policies
SELECT 
  'Policies:' as check_type,
  policyname,
  cmd as operation,
  CASE cmd
    WHEN 'SELECT' THEN '✓ Users can view'
    WHEN 'INSERT' THEN '✓ Users can create'
    WHEN 'UPDATE' THEN '✓ Users can update'
    ELSE cmd
  END as description,
  qual as using_clause,
  with_check as check_clause
FROM pg_policies
WHERE tablename = 'Conversation'
ORDER BY cmd;

-- Step 3: Check table permissions
SELECT 
  'Table Permissions:' as check_type,
  grantee,
  privilege_type,
  CASE 
    WHEN privilege_type = 'SELECT' THEN '✓ Can read'
    WHEN privilege_type = 'INSERT' THEN '✓ Can create'
    WHEN privilege_type = 'UPDATE' THEN '✓ Can update'
    ELSE privilege_type
  END as description
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
AND table_name = 'Conversation'
AND grantee = 'authenticated';

-- Step 4: Check schema permissions
SELECT 
  'Schema Permissions:' as check_type,
  grantee,
  privilege_type
FROM information_schema.usage_privileges
WHERE object_schema = 'public'
AND grantee = 'authenticated';

-- Step 5: Summary
SELECT 
  'Summary:' as check_type,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'Conversation') as policy_count,
  (SELECT COUNT(*) FROM information_schema.role_table_grants 
   WHERE table_name = 'Conversation' AND grantee = 'authenticated') as permission_count,
  CASE 
    WHEN (SELECT rowsecurity FROM pg_tables WHERE tablename = 'Conversation') 
    THEN '✓ RLS Enabled'
    ELSE '✗ RLS Disabled'
  END as rls_status;
