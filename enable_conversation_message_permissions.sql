-- ============================================
-- Enable All Permissions for ConversationMessage Table
-- ============================================
-- Copy and paste this ENTIRE script into Supabase SQL Editor
-- Click "Run" to execute
-- This will fix permission issues for messages
-- ============================================

-- Step 1: Enable RLS (Row Level Security)
ALTER TABLE IF EXISTS public."ConversationMessage" ENABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL existing policies to start fresh
DROP POLICY IF EXISTS "Users can view messages in their conversations" ON public."ConversationMessage";
DROP POLICY IF EXISTS "Users can send messages" ON public."ConversationMessage";
DROP POLICY IF EXISTS "Users can update their own messages" ON public."ConversationMessage";
DROP POLICY IF EXISTS "Users can delete their own messages" ON public."ConversationMessage";
DROP POLICY IF EXISTS "Allow authenticated users to insert" ON public."ConversationMessage";
DROP POLICY IF EXISTS "Allow authenticated users to select" ON public."ConversationMessage";

-- Step 3: Grant USAGE on schema (required for any table access)
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;

-- Step 4: Grant table-level permissions to authenticated role
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public."ConversationMessage" TO authenticated;
GRANT SELECT ON TABLE public."ConversationMessage" TO anon;

-- Step 5: Grant sequence permissions (if ID is SERIAL/auto-increment)
DO $$
BEGIN
  -- Check and grant permissions for ConversationMessage_id_seq if it exists
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'ConversationMessage_id_seq') THEN
    GRANT USAGE, SELECT ON SEQUENCE public."ConversationMessage_id_seq" TO authenticated;
    GRANT USAGE, SELECT ON SEQUENCE public."ConversationMessage_id_seq" TO anon;
  END IF;
END $$;

-- Step 6: Create SELECT policy - Users can view messages in conversations they're part of
CREATE POLICY "Users can view messages in their conversations"
ON public."ConversationMessage"
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public."Conversation"
    WHERE "Conversation".id = "ConversationMessage".chat_id
    AND "Conversation".user_id = auth.uid()
  )
);

-- Step 7: Create INSERT policy - Users can send messages in their conversations
CREATE POLICY "Users can send messages"
ON public."ConversationMessage"
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = sender_id
  AND EXISTS (
    SELECT 1 FROM public."Conversation"
    WHERE "Conversation".id = "ConversationMessage".chat_id
    AND "Conversation".user_id = auth.uid()
  )
);

-- Step 8: Create UPDATE policy - Users can update their own messages
CREATE POLICY "Users can update their own messages"
ON public."ConversationMessage"
FOR UPDATE
TO authenticated
USING (auth.uid() = sender_id)
WITH CHECK (auth.uid() = sender_id);

-- Step 9: Create DELETE policy - Users can delete their own messages
CREATE POLICY "Users can delete their own messages"
ON public."ConversationMessage"
FOR DELETE
TO authenticated
USING (auth.uid() = sender_id);

-- Step 10: Enable Realtime for the table (for real-time message updates)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
    AND schemaname = 'public' 
    AND tablename = 'ConversationMessage'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE "ConversationMessage";
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
AND tablename = 'ConversationMessage';

-- Step 12: List all created policies
SELECT 
  '✓ Policies Created:' as status,
  policyname,
  cmd as operation,
  CASE cmd
    WHEN 'SELECT' THEN 'Users can view ✓'
    WHEN 'INSERT' THEN 'Users can send ✓'
    WHEN 'UPDATE' THEN 'Users can update ✓'
    WHEN 'DELETE' THEN 'Users can delete ✓'
    ELSE cmd
  END as description
FROM pg_policies
WHERE tablename = 'ConversationMessage'
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
AND table_name = 'ConversationMessage'
AND grantee IN ('authenticated', 'anon')
ORDER BY grantee, privilege_type;

-- Step 14: Final verification summary
SELECT 
  '✓ Setup Complete!' as status,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'ConversationMessage') as total_policies,
  (SELECT COUNT(*) FROM information_schema.role_table_grants 
   WHERE table_name = 'ConversationMessage' AND grantee = 'authenticated') as permissions_count,
  CASE 
    WHEN (SELECT rowsecurity FROM pg_tables WHERE tablename = 'ConversationMessage') 
    THEN 'RLS Enabled ✓'
    ELSE 'RLS Disabled ✗'
  END as rls_status,
  'You can now send and view messages from your Flutter app!' as message;

