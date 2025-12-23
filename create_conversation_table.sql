-- ============================================
-- Conversation Table Setup Script
-- ============================================
-- Copy and paste this entire script into your Supabase SQL Editor
-- Then click "Run" to execute it
-- ============================================

-- Step 1: Create the conversation table
CREATE TABLE IF NOT EXISTS public.conversation (
  id SERIAL PRIMARY KEY,
  user1_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user2_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user1_seen BOOLEAN DEFAULT false,
  user2_seen BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 2: Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_conversation_user1 ON public.conversation(user1_id);
CREATE INDEX IF NOT EXISTS idx_conversation_user2 ON public.conversation(user2_id);
CREATE INDEX IF NOT EXISTS idx_conversation_created_at ON public.conversation(created_at DESC);

-- Step 3: Enable Row Level Security (RLS)
ALTER TABLE public.conversation ENABLE ROW LEVEL SECURITY;

-- Step 4: Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view their own conversations" ON public.conversation;
DROP POLICY IF EXISTS "Users can create conversations" ON public.conversation;
DROP POLICY IF EXISTS "Users can update their own conversations" ON public.conversation;

-- Step 5: Create policy to allow authenticated users to view their conversations
CREATE POLICY "Users can view their own conversations"
  ON public.conversation
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() = user1_id OR auth.uid() = user2_id
  );

-- Step 6: Create policy to allow authenticated users to create conversations
CREATE POLICY "Users can create conversations"
  ON public.conversation
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user1_id OR auth.uid() = user2_id
  );

-- Step 7: Create policy to allow users to update their own conversations
CREATE POLICY "Users can update their own conversations"
  ON public.conversation
  FOR UPDATE
  TO authenticated
  USING (
    auth.uid() = user1_id OR auth.uid() = user2_id
  )
  WITH CHECK (
    auth.uid() = user1_id OR auth.uid() = user2_id
  );

-- Step 8: Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.conversation TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE conversation_id_seq TO authenticated;

-- Step 9: Enable Realtime for the table
ALTER PUBLICATION supabase_realtime ADD TABLE conversation;

-- Step 10: Verify the table was created
SELECT 
  'Table created successfully!' as status,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'conversation';

-- Step 11: Verify policies were created
SELECT 
  'Policies created:' as status,
  policyname,
  cmd as operation
FROM pg_policies 
WHERE tablename = 'conversation';

