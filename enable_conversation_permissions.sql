-- ============================================
-- Enable All Permissions for Conversation Table
-- ============================================
-- Copy and paste this ENTIRE script into Supabase SQL Editor
-- Click "Run" to execute
-- This will fix all permission denied errors
-- ============================================

-- Step 1: Enable RLS (Row Level Security)
ALTER TABLE IF EXISTS public."Conversation" ENABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL existing policies to start fresh
DROP POLICY IF EXISTS "Users can view their own conversations" ON public."Conversation";
DROP POLICY IF EXISTS "Users can create conversations" ON public."Conversation";
DROP POLICY IF EXISTS "Users can update their own conversations" ON public."Conversation";
DROP POLICY IF EXISTS "Allow authenticated users to insert" ON public."Conversation";
DROP POLICY IF EXISTS "Allow authenticated users to select" ON public."Conversation";
DROP POLICY IF EXISTS "Allow authenticated users to update" ON public."Conversation";
DROP POLICY IF EXISTS "Enable insert for authenticated" ON public."Conversation";
DROP POLICY IF EXISTS "Enable select for authenticated" ON public."Conversation";
DROP POLICY IF EXISTS "Enable update for authenticated" ON public."Conversation";

-- Step 3: Grant USAGE on schema (required for any table access)
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;

-- Step 4: Grant table-level permissions to authenticated role
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public."Conversation" TO authenticated;
GRANT SELECT ON TABLE public."Conversation" TO anon;

-- Step 5: Grant sequence permissions (if ID is SERIAL/auto-increment)
DO $$
BEGIN
  -- Check and grant permissions for Conversation_id_seq if it exists
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'Conversation_id_seq') THEN
    GRANT USAGE, SELECT ON SEQUENCE public."Conversation_id_seq" TO authenticated;
    GRANT USAGE, SELECT ON SEQUENCE public."Conversation_id_seq" TO anon;
  END IF;
END $$;

-- Step 6: Create SELECT policy - Users can view their own conversations
CREATE POLICY "Users can view their own conversations"
ON public."Conversation"
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Step 7: Create INSERT policy - Users can create conversations where they are the user
CREATE POLICY "Users can create conversations"
ON public."Conversation"
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Step 8: Create UPDATE policy - Users can update their own conversations
CREATE POLICY "Users can update their own conversations"
ON public."Conversation"
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Step 9: Create DELETE policy (optional - users can delete their own conversations)
CREATE POLICY "Users can delete their own conversations"
ON public."Conversation"
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Step 10: Enable Realtime for the table (for real-time updates)
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

-- Step 11: Verify RLS is enabled
SELECT 
  '✓ RLS Status:' as status,
  tablename,
  CASE 
    WHEN rowsecurity THEN 'ENABLED ✓'
    ELSE 'DISABLED ✗'
  END as rls_status
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'Conversation';

-- Step 12: List all created policies
SELECT 
  '✓ Policies Created:' as status,
  policyname,
  cmd as operation,
  CASE cmd
    WHEN 'SELECT' THEN 'Users can view'
    WHEN 'INSERT' THEN 'Users can create'
    WHEN 'UPDATE' THEN 'Users can update'
    WHEN 'DELETE' THEN 'Users can delete'
    ELSE cmd
  END as description
FROM pg_policies
WHERE tablename = 'Conversation'
ORDER BY cmd;

-- Step 13: Verify table permissions
SELECT 
  '✓ Table Permissions:' as status,
  grantee,
  privilege_type,
  CASE 
    WHEN privilege_type = 'SELECT' THEN 'Can read ✓'
    WHEN privilege_type = 'INSERT' THEN 'Can create ✓'
    WHEN privilege_type = 'UPDATE' THEN 'Can update ✓'
    WHEN privilege_type = 'DELETE' THEN 'Can delete ✓'
    ELSE privilege_type
  END as description
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
AND table_name = 'Conversation'
AND grantee IN ('authenticated', 'anon')
ORDER BY grantee, privilege_type;

-- Step 14: Final verification summary
SELECT 
  '✓ Setup Complete!' as status,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'Conversation') as total_policies,
  (SELECT COUNT(*) FROM information_schema.role_table_grants 
   WHERE table_name = 'Conversation' AND grantee = 'authenticated') as permissions_count,
  CASE 
    WHEN (SELECT rowsecurity FROM pg_tables WHERE tablename = 'Conversation') 
    THEN 'RLS Enabled ✓'
    ELSE 'RLS Disabled ✗'
  END as rls_status,
  'You can now insert conversations from your Flutter app!' as message;

