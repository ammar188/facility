-- ============================================
-- Fix ConversationMessage Table RLS and Permissions Script
-- ============================================
-- Copy and paste this entire script into your Supabase SQL Editor
-- Then click "Run" to execute it
-- ============================================
-- This script sets up RLS for the ConversationMessage table
-- ============================================

-- Step 1: Ensure RLS is enabled for the ConversationMessage table
ALTER TABLE public."ConversationMessage" ENABLE ROW LEVEL SECURITY;

-- Step 2: Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can view messages in their conversations" ON public."ConversationMessage";
DROP POLICY IF EXISTS "Users can send messages" ON public."ConversationMessage";
DROP POLICY IF EXISTS "Users can update their own messages" ON public."ConversationMessage";

-- Step 3: Policy to allow authenticated users to view messages in their conversations
-- Users can see messages where they are part of the conversation
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

-- Step 4: Policy to allow authenticated users to send messages
-- Users can insert messages where they are the sender
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

-- Step 5: Policy to allow users to update their own messages (optional)
CREATE POLICY "Users can update their own messages"
  ON public."ConversationMessage"
  FOR UPDATE
  TO authenticated
  USING (
    auth.uid() = sender_id
  )
  WITH CHECK (
    auth.uid() = sender_id
  );

-- Step 6: Grant necessary schema permissions to authenticated role
GRANT USAGE ON SCHEMA public TO authenticated;

-- Step 7: Grant necessary table permissions to authenticated role
GRANT SELECT, INSERT, UPDATE ON TABLE public."ConversationMessage" TO authenticated;

-- Step 8: Grant sequence permissions for auto-incrementing IDs (if using SERIAL)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'ConversationMessage_id_seq') THEN
    GRANT USAGE, SELECT ON SEQUENCE public."ConversationMessage_id_seq" TO authenticated;
  END IF;
END $$;

-- Step 9: Enable Realtime for the table (if needed)
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

-- Step 10: Verify RLS status
SELECT
  'RLS Status:' as status,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'ConversationMessage';

-- Step 11: Verify policies were created
SELECT
  'Policies for ConversationMessage table:' as status,
  policyname,
  cmd as operation,
  roles,
  qual as using_expression,
  with_check as check_expression
FROM pg_policies
WHERE tablename = 'ConversationMessage';

