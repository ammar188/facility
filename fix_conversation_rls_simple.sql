-- ============================================
-- Simple Fix for Conversation Table RLS
-- ============================================
-- Copy and paste this ENTIRE script into Supabase SQL Editor
-- Click "Run" to execute
-- ============================================

-- Step 1: Enable RLS
ALTER TABLE IF EXISTS public."Conversation" ENABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL existing policies (clean slate)
DROP POLICY IF EXISTS "Users can view their own conversations" ON public."Conversation";
DROP POLICY IF EXISTS "Users can create conversations" ON public."Conversation";
DROP POLICY IF EXISTS "Users can update their own conversations" ON public."Conversation";
DROP POLICY IF EXISTS "Allow authenticated users to insert" ON public."Conversation";
DROP POLICY IF EXISTS "Allow authenticated users to select" ON public."Conversation";
DROP POLICY IF EXISTS "Allow authenticated users to update" ON public."Conversation";

-- Step 3: Grant schema usage
GRANT USAGE ON SCHEMA public TO authenticated;

-- Step 4: Grant table permissions
GRANT SELECT, INSERT, UPDATE ON TABLE public."Conversation" TO authenticated;

-- Step 5: Create SELECT policy (users can view their own conversations)
CREATE POLICY "Users can view their own conversations"
ON public."Conversation"
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Step 6: Create INSERT policy (users can create conversations where they are the user)
CREATE POLICY "Users can create conversations"
ON public."Conversation"
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Step 7: Create UPDATE policy (users can update their own conversations)
CREATE POLICY "Users can update their own conversations"
ON public."Conversation"
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Step 8: Verify policies
SELECT 
  'Policies created:' as status,
  policyname,
  cmd as operation
FROM pg_policies
WHERE tablename = 'Conversation';

-- Step 9: Verify permissions
SELECT 
  'Permissions granted:' as status,
  grantee,
  privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
AND table_name = 'Conversation'
AND grantee = 'authenticated';

