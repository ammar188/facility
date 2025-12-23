-- ============================================
-- Fix Conversation Table RLS Policies
-- ============================================
-- Run this script if you're getting 404 or permission errors
-- even though the conversation table exists
-- ============================================

-- Step 1: Verify the table exists and check its name
SELECT 
  'Table Info:' as info,
  tablename,
  schemaname,
  rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND (tablename = 'conversation' OR tablename = 'Conversation')
ORDER BY tablename;

-- Step 2: Grant schema permissions (if missing)
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;

-- Step 3: Grant table permissions
-- Try lowercase first
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'conversation') THEN
    GRANT SELECT, INSERT, UPDATE ON TABLE public.conversation TO authenticated;
    GRANT SELECT, INSERT, UPDATE ON TABLE public.conversation TO anon;
    GRANT USAGE, SELECT ON SEQUENCE conversation_id_seq TO authenticated;
    RAISE NOTICE 'Permissions granted for conversation table';
  END IF;
END $$;

-- Step 4: Enable RLS (if not already enabled)
ALTER TABLE IF EXISTS public.conversation ENABLE ROW LEVEL SECURITY;

-- Step 5: Drop existing policies (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view their own conversations" ON public.conversation;
DROP POLICY IF EXISTS "Users can create conversations" ON public.conversation;
DROP POLICY IF EXISTS "Users can update their own conversations" ON public.conversation;
DROP POLICY IF EXISTS "Allow authenticated users to select" ON public.conversation;
DROP POLICY IF EXISTS "Allow authenticated users to insert" ON public.conversation;

-- Step 6: Create SELECT policy (allow users to see their conversations)
CREATE POLICY "Users can view their own conversations"
  ON public.conversation
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() = user1_id OR auth.uid() = user2_id
  );

-- Also allow for anon role (if needed)
CREATE POLICY "Anon can view conversations"
  ON public.conversation
  FOR SELECT
  TO anon
  USING (true);

-- Step 7: Create INSERT policy (allow users to create conversations)
CREATE POLICY "Users can create conversations"
  ON public.conversation
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user1_id OR auth.uid() = user2_id
  );

-- Also allow for anon role (if needed)
CREATE POLICY "Anon can create conversations"
  ON public.conversation
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Step 8: Create UPDATE policy
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

-- Step 9: Verify policies were created
SELECT 
  'Policies created:' as status,
  policyname,
  cmd as operation,
  roles::text as roles
FROM pg_policies 
WHERE tablename = 'conversation'
ORDER BY policyname;

-- Step 10: Test query (this should work after running the script)
-- Uncomment to test:
-- SELECT * FROM public.conversation LIMIT 1;

