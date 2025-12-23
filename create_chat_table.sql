-- ============================================
-- Chat Messages Table Setup Script
-- ============================================
-- Copy and paste this entire script into your Supabase SQL Editor
-- Then click "Run" to execute it
-- ============================================

-- Step 1: Create the chat_messages table
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  user_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 2: Enable Row Level Security (RLS)
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- Step 3: Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can read messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can insert messages" ON public.chat_messages;

-- Step 4: Create policy to allow authenticated users to read messages
CREATE POLICY "Users can read messages"
  ON public.chat_messages
  FOR SELECT
  TO authenticated
  USING (true);

-- Step 5: Create policy to allow authenticated users to insert messages
CREATE POLICY "Users can insert messages"
  ON public.chat_messages
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Step 6: Enable Realtime for the table
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;

-- Step 7: Verify the table was created
SELECT 
  'Table created successfully!' as status,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'chat_messages';

-- Step 8: Verify policies were created
SELECT 
  'Policies created:' as status,
  policyname,
  cmd as operation
FROM pg_policies 
WHERE tablename = 'chat_messages';

