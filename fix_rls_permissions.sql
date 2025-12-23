-- ============================================
-- Complete RLS Fix Script
-- Run this ENTIRE script at once
-- ============================================

-- Step 1: Enable Row Level Security
ALTER TABLE "ChatMessage" ENABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL existing policies to start fresh
DROP POLICY IF EXISTS "Allow authenticated users to insert messages" ON "ChatMessage";
DROP POLICY IF EXISTS "Allow authenticated users to read messages" ON "ChatMessage";
DROP POLICY IF EXISTS "Users can read messages" ON "ChatMessage";
DROP POLICY IF EXISTS "Users can insert messages" ON "ChatMessage";
DROP POLICY IF EXISTS "Users can update their messages" ON "ChatMessage";
DROP POLICY IF EXISTS "Users can delete their own messages" ON "ChatMessage";

-- Step 3: Create INSERT policy (allows sending messages)
CREATE POLICY "Allow authenticated users to insert messages"
  ON "ChatMessage"
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Step 4: Create SELECT policy (allows reading messages)
CREATE POLICY "Allow authenticated users to read messages"
  ON "ChatMessage"
  FOR SELECT
  TO authenticated
  USING (true);

-- Step 5: Verify policies were created (this should show 2 policies)
SELECT 
  '✅ Policies Status' as status,
  policyname,
  cmd as operation,
  roles
FROM pg_policies 
WHERE tablename = 'ChatMessage';

